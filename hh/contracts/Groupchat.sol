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
* -TODO- DONE: Subscribers and Subscriptions and Owners are arrays of addresses, but
* really should be mapping(address => bool). Would be much faster.
*/

/*
* TODO: We should probably send these guys a message that says 
* "Hey, you were added to this group chat by this dude" 
*
* TODO: Check PubSub impls
*/

/*
* A GroupChat is a contract that has members. 
* Every member is an owner.
* You cannot subscribe yourself to a group chat, an owner has to add you.
* You can, however, remove yourself from a group chat.
* A group chat does not subscribe to it's members. The members have to choose
* to send something to the groupchat.
* Group chats do not originate messages, they merely forward messages
* from members to members.
*/

contract GroupChat is PMPS, PubSub {
    address owner;
    IterableSet.Set private members; // members of the group chat

    constructor(address initilizer) {
        //IterableSet.add(members, msg.sender);
        owner = msg.sender;
        IterableSet.add(members, initilizer);
    }

    // basically a hack that makes <external> functions <internal>,
    // even tho they're externally visible.
    modifier self_only() {
        require(msg.sender == address(this), "This function is only accessible internally!");
        _;
    }

    // accessible either to members, or to self
    modifier members_or_self() {
        require(IterableSet.get(members, msg.sender) || (msg.sender == address(this)), "Non-member addresses (or self) cannot interact with this contract!");
        _;
    }

    // accessible to members only. 
    modifier members_only() {
        require(IterableSet.get(members, msg.sender), "Non-member addresses cannot interact with this contract!");
        _;
    }

    modifier owner_only() {
        require(msg.sender == owner, "This function is owner only!");
        _;
    }

    // the target needs to implement ERC-165 and PMPS
    function add_member(address target) external owner_only {
        console.log(address(this), ": [add_member]: ", target); // LOGGING
        require(ERC165Checker._supportsERC165(target), "Sender doesn't implement ERC-165!");
        require(ERC165Checker._supportsInterface(target, this.pmps_interface_id()), "Sender doesn't implement PMPS!");
        IterableSet.add(members, target);
        // We should probably send these guys a message that says "Hey, you were added to this group chat by this dude" 
        // TODO  
    }

    function status() external {
        console.log("\nMembers (",members.length,"):");
        for (uint i = 0; i < members.length; i++) {
            console.log("\t", IterableSet.index(members, i));
        }
    }

    // the purpose of this function is so that people can query us to ask if they are or aren't a member of the gc.
    function extern_is_subscribed() external override(PubSub) returns (bool) {
        console.log(address(this), ": [extern_is_subscribed]"); // LOGGING
        return IterableSet.get(members, msg.sender);
    }

    // this function should always return false. You can't add yourself to a GC
    function extern_request_subscribe() external override(PubSub) returns (bool) {
        // You shouldn't be able to add yourself to a GC, an owner has to add you
        // So, this function should auto deny everyone.
        // We don't even have to check if they implement PMPS or ERC-165 or anything
        console.log(address(this), ": [extern_request_subscribe]"); // LOGGING
        
        return false;
    }

    // you can, however, remove yourself from a gc
    function extern_request_unsubscribe() external override(PubSub) returns (bool) {
        // you should be able to unsubscribe from a group chat of your own accord
        // we unsubscribe this person if they aren't already in the list
        console.log(address(this), ": [extern_request_unsubscribe]"); // LOGGING

        if (IterableSet.get(members, msg.sender)) {
            // they are subscribed, so we'll unsub them
            IterableSet.remove(members, msg.sender);
            return true;
        } else {
            // they were never subscribed, return false
            return false;
        }
    }

    // Using the hacky external self_only shit
    function forward(
        SignedMessage calldata message
    ) external self_only returns (bool) {
        console.log(address(this), ": [forward]"); // LOGGING

        bool _flag = true;
        for (uint i = 0; i < members.length; i++) {
            console.log("Sending message to ", IterableSet.index(members, i));
            _flag = _flag && this.try_send_message(message, IterableSet.index(members, i));
        }

        return _flag; // returns true if we send to every person successfully. This might be too stringent. 
    }

    // Self only. Group Chats don't originate messages.
    // Kind of hacky. 
    function try_send_message(
        SignedMessage calldata message, 
        address target
    ) external self_only override(PMPS) returns (bool) {
        // first, we have to check that the target implements ERC165. 
        // second, we have to preform an ERC165 query to check that the target implements PMPS
        console.log(address(this), ": [try_send_message]"); // LOGGING

        /*
        require(ERC165Checker._supportsERC165(target), "Target doesn't implement ERC-165!");
        require(ERC165Checker._supportsInterface(target, this.pmps_interface_id()), "Target doesn't implement PMPS!");
        */

        // rather than using require for try_send_message, we check manually and return false if either impl fails

        if (ERC165Checker._supportsERC165(target)) {
            if (ERC165Checker._supportsInterface(target, this.pmps_interface_id())) {
                console.log(address(this), ": [try_send_message]: passed implementation checks");
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

    function receive_message(
        SignedMessage calldata message
    ) external override(PMPS) returns (bool) {
        console.log(address(this), ": [receive_message]"); // LOGGING

        bool auth = verify_signed_message(message);
        if (auth) {
            console.log("We received and validated a message originating from ", message.originator, ", immediately received from ", msg.sender);
            console.log("The message says \"", message.message, "\"");
            console.log("Forwarding the message!");
            return this.forward(message);
        } else {
            console.log("[WARNING]: We received a message from ", msg.sender, " which failed to authenticate!");
            console.log("[WARNING]: We are not forwarding this message!");
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