// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./PMPS.sol"; // PointMessagingProtocol
import "./ERC165.sol"; // ERC165
import "./ERC165Checker.sol"; // Library to interact with ERC165
import "./IterableMap.sol"; // Library for Iterable Maps

import "hardhat/console.sol"; // console.log();

/*
* TODO: Stuff of this form target.call(); often depends upon the bool 
* returned by the function call, not the actual return value of 
* the function we're calling. 
* 
* TODO: Subscribers and Subscriptions and Owners are arrays of addresses, but
* really should be mapping(address => bool). Would be much faster.
* -- Actually you really shouldn't do this - we need to iterate over these
* things and the iterable mapping contract I wrote is super memory inefficient
*/

contract Timeline is PMPS, PubSub {
    SignedMessage[] private timeline; // subscriptions only
    SignedMessage[] private unsub_msgs; // messages from people we don't subscribe to

    IterableSet.Set private owners;
    IterableSet.Set private subscribers;
    IterableSet.Set private subscriptions;

    //mapping(address => bool) private owners; // who owns the contract
    //mapping(address => bool) private subscribers; // who subscribes to us?
    //mapping(address => bool) private subscriptions; // who do we subscribe to? 

    //address[] private owners; 
    //address[] private subscribers; // Maybe this should be a mapping
    //address[] private subscriptions; // Maybe this should be a mapping

    constructor() {
        // owners[msg.sender] = true;
        IterableSet.add(owners, msg.sender);
        //owners.add(msg.sender);
    }

    modifier owners_or_self() {
        require(IterableSet.get(owners, msg.sender) || (msg.sender == address(this)), "Non-owner addresses cannot interact with this contract!");
        _;
    }

    modifier owners_only() {
        /*bool valid_recipient = false;

        for (uint i = 0; (i < owners.length) && !valid_recipient; i++) {
            // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            valid_recipient = valid_recipient || (msg.sender == owners[i]);
        }*/

        require(IterableSet.get(owners, msg.sender), "Non-owner addresses cannot interact with this contract!");
        _;
    }

    function add_owner(address target) external owners_only {
        console.log(address(this), ": [add_owner]"); // LOGGING

        IterableSet.add(owners, target);
    }

    function status() external {
        console.log("\nOwners (",owners.length,"):");
        for (uint i = 0; i < owners.length; i++) {
            console.log("\t", IterableSet.index(owners, i));
        }
        console.log("\nSubscribers (",subscribers.length,"):");
        for (uint i = 0; i < subscribers.length; i++) {
            console.log("\t", IterableSet.index(subscribers, i));
        }
        console.log("\nSubscriptions (",subscriptions.length,"):");
        for (uint i = 0; i < subscriptions.length; i++) {
            console.log("\t", IterableSet.index(subscriptions, i));
        }
    }

    // Owners Only
    function intern_request_subscribe(address target) external owners_only returns (bool) {
        console.log(address(this), ": [intern_request_subscribe]"); // LOGGING
        /*
        * We try to subscribe to the contract in question
        */

        // first, the target has to be ERC-165
        // second, the target has to be PubSub
        // then, we're good to make the request

        require(ERC165Checker._supportsERC165(target), "Target doesn't implement ERC-165!");
        require(ERC165Checker._supportsInterface(target, this.pubsub_interface_id()), "Target doesn't implement PubSub!");

        // if we get this far, they do implement pubsub, so lets go
        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(this.extern_request_subscribe.selector));

        if (success) {
            // we successfully subscribed ourselves to the target
            IterableSet.add(subscriptions, target);
        } else {
            console.log("We failed to subscribe to the target!");
        }

        return success; // this only represents whether the function call was successful, not whether we're actually subscribed to these people now. This needs to change but it's low priority
    }

    // the purpose of this function is so that people can query us to ask if they are or aren't subscribed to us. 
    function extern_is_subscribed() external override(PubSub) returns (bool) {
        console.log(address(this), ": [extern_is_subscribed]"); // LOGGING
        return IterableSet.get(subscribers, msg.sender);
    }

    function extern_request_subscribe() external override(PubSub) returns (bool) {
        // we subscribe this person if they aren't already in the list
        // they have to be ERC-165 and PMPS though, because we have to send them messages
        console.log(address(this), ": [extern_request_subscribe]"); // LOGGING
        require(ERC165Checker._supportsERC165(msg.sender), "Sender doesn't implement ERC-165!");
        require(ERC165Checker._supportsInterface(msg.sender, this.pmps_interface_id()), "Sender doesn't implement PMPS!");

        /*bool _flag = false;
        for (uint i = 0; (i < subscribers.length) && !_flag; i++) {
            _flag = _flag || (subscribers[i] == msg.sender);
        }

        // if this person isn't on the list, the loop ends and _flag is still false.
        if (!_flag) {
            subscribers.push(msg.sender);
            return true;
        } else {
            return false;
        }*/

        if (IterableSet.get(subscribers, msg.sender)) {
            // you're already subscribed
            return true;
        } else {
            // you aren't, so we'll add you
            IterableSet.add(subscribers, msg.sender);
            //subscribers.add(msg.sender);
            return true;
        }
    }

    function extern_request_unsubscribe() external override(PubSub) returns (bool) {
        // we unsubscribe this person if they aren't already in the list
        console.log(address(this), ": [extern_request_unsubscribe]"); // LOGGING

        if (IterableSet.get(subscribers, msg.sender)) {
            // they are subscribed, so we'll unsub them
            IterableSet.remove(subscribers, msg.sender);
            //subscribers.remove(msg.sender);
            return true;
        } else {
            // they were never subscribed, return false
            return false;
        }
    }

    // Owners Only
    function try_send_message(
        SignedMessage calldata message, 
        address target
    ) public owners_or_self override(PMPS) returns (bool) {
        // first, we have to check that the target implements ERC165. 
        // second, we have to preform an ERC165 query to check that the target implements PMPS
        console.log(address(this), ": [try_send_message]"); // LOGGING

        if (ERC165Checker._supportsERC165(target)) {
            if (ERC165Checker._supportsInterface(target, this.pmps_interface_id())) {
                (bool success, bytes memory data) = target.call(abi.encodeWithSelector(this.receive_message.selector, message));

                return success;
            } else {
                console.log(address(this), ": [try_send_message] [WARNING]: target address does not suppose PMPS!");
                return false;
            }
        } else {
                console.log(address(this), ": [try_send_message] [WARNING]: target address does not suppose ERC-165!");
                return false;
        }
    }

    // Owners Only
    function publish(
        SignedMessage calldata message
    ) public owners_or_self returns (bool) {
        console.log(address(this), ": [publish]"); // LOGGING

        bool _flag = true;
        for (uint i = 0; i < subscribers.length; i++) {
            _flag = _flag && this.try_send_message(message, IterableSet.index(subscribers, i));
        }

        return _flag; // returns true if we send to every person successfully. This might be too stringent. 
    }

    // Owners Only
    function publish_helper(
        address originator,
        string calldata message,
        bytes32 eth_signed_message_hash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external owners_only returns (bool) {
        console.log(address(this), ": [publish_helper]"); // LOGGING

        SignedMessage memory itrmsg = SignedMessage(originator, message, eth_signed_message_hash, r, s, v);

        require(verify_signed_message(itrmsg), "Message fails to verify!");

        return this.publish(itrmsg);
    }

    // Owners Only
    function send_helper(
        address originator,
        string calldata message,
        bytes32 eth_signed_message_hash,
        bytes32 r,
        bytes32 s,
        uint8 v,
        address target
    ) external owners_only returns (bool) {
        console.log(address(this), ": [send_helper]"); // LOGGING

        SignedMessage memory itrmsg = SignedMessage(originator, message, eth_signed_message_hash, r, s, v);

        require(verify_signed_message(itrmsg), "Message fails to verify!");

        return this.try_send_message(itrmsg, target);
    }

    

    function receive_message(
        SignedMessage calldata message
    ) external override(PMPS) returns (bool) {
        console.log(address(this), ": [receive_message]"); // LOGGING

        bool auth = verify_signed_message(message);
        if (auth) {
            console.log("We received and validated a message originating from ", message.originator, ", immediately received from ", msg.sender);
            console.log("The message says \"", message.message, "\"");
        } else {
            console.log("[WARNING]: We received a message from ", msg.sender, " which failed to authenticate!");
            return false;
        }
    }

    function pubsub_interface_id() public view returns (bytes4) {
        return this.extern_request_subscribe.selector ^ this.extern_request_unsubscribe.selector ^ this.extern_is_subscribed.selector;
    }

    function pmps_interface_id() public view returns (bytes4) {
        return this.receive_message.selector ^ this.try_send_message.selector;
    }

    // ERC-165 compat
    function supportsInterface(
        bytes4 interfaceID
    ) external override(ERC165) view returns (bool) {
        return (interfaceID == this.supportsInterface.selector) || // ERC165
          (interfaceID == this.pmps_interface_id()) || (interfaceID == this.pubsub_interface_id());
    }
}