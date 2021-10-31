pragma solidity ^0.8.3;

import "./PointMessagingProtocol.sol";
import "hardhat/console.sol";


contract Accumulator is PMPF {
    address private owner;
    address[] private subscribers;
    address[] private subscriptions;

    constructor() {
        owner = msg.sender;
    }

    modifier subscripts_only() {
        bool valid_recipient = false;

        for (uint i = 0; i < subscriptions.length; i++) {
            // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            valid_recipient = valid_recipient || (msg.sender == subscriptions[i]);
        }

        require(valid_recipient, "If this contract doesn't subscribe to you, you can't send it a message!");
        _;
    }

    modifier owner_only() {
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    function add_target_subscript(address target) external owner_only returns (bool) {
        bool _flag = false;
        for (uint i = 0; i < subscriptions.length; i++) {
            _flag = _flag || (subscriptions[i] == target);
        }

        // if we don't already subscribe to this person
        if (!_flag) {
            subscriptions.push(target);
            return true;
        } else {
            return false;
        }
    }

    // function remove_target_subscript(address calldata target) external owner_only returns (bool) {}

    // returns true if you were added to the list, false otherwise.
    function request_sub() external returns (bool) {
        // if the person isn't already in subscribers, we add them to it.
        bool _flag = false;
        for (uint i = 0; i < subscribers.length; i++) {
            _flag = _flag || (subscribers[i] == msg.sender);
        }

        if (!_flag) {
            subscribers.push(msg.sender);
            return true;
        } else {
            return false;
        }
    }

    // returns true if you were removed from the list, false otherwise.
    function remove_sub() external returns (bool) {
        // if the person is in the array, we remove them and compact the array.
        bool _flag = false;
        for (uint i = 0; i < subscribers.length; i++) {
            if (subscribers[i] == msg.sender) {
                subscribers[i] = subscribers[subscribers.length - 1];
                subscribers.pop();
                _flag = true;
                break;
            }
        }
        return _flag;
    }

    function send(MSG calldata message, address target) private returns (bool) {
        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("receive(MSG)", message));

        console.log(address(this), ": send returns ", success);

        return success;
    }

    function receive(MSG calldata message) external subscripts_only override(PMPF) {
        console.log("We received a message!");
        
        for (uint i = 0; i < subscribers.length; i++) {
            send(message, subscribers[i]);
        }
    }
}

contract GC is PMPF {
    address[] private members; // order doesn't matter

    constructor(address[] memory _members) {
        members = _members;
        console.log("\nGroup Chat deployed with members");
        for (uint i = 0; i < members.length; i++) {
            console.log("\t", members[i]);
        }
    }

    modifier members_only() {
        console.log("[GC]: members_only was called");
        bool is_valid_recipient = false;

        for (uint i = 0; (i < members.length) && !is_valid_recipient; i++) {
            is_valid_recipient = is_valid_recipient || (msg.sender == members[i]);
        }

        require(is_valid_recipient, "Non-GC member addresses cannot interact with this contract!");
        _;
    }

    function add_member(address member) external members_only returns (bool) {
        // you can add someone to the groupchat if you're a member
        // we only add them to the gc if they aren't already here
        // return true if successful, false otherwise

        bool is_in = false;
        for (uint i = 0; (i < members.length) && !is_in; i++) {
            // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            is_in = is_in || (members[i] == member);
        }

        if (!is_in) {
            members.push(member);
            return true;
        } else {
            return false;
        }

    }

    function leave_group() external members_only returns (bool) {
        for (uint i = 0; i < members.length; i++) {
            // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            if (members[i] == msg.sender) {
                members[i] = members[members.length - 1];
                members.pop();
                return true;
            }
        }

        return false;
    }

    function send(MSG calldata message, address target) private returns (bool) {
        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("receive(MSG)", message));

        console.log(address(this), ": send returns ", success);

        return success;
    }

    function receive(MSG calldata message) external members_only override(PMPF) {
        console.log("We received a message!");
        
        for (uint i = 0; i < members.length; i++) {
            if (members[i] != msg.sender) {
                send(message, members[i]);
            }
        }
    }
}

contract Member is PMPF {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier owner_only() {
        console.log("[Member]: owner_only called: ", msg.sender == owner);
        require(msg.sender == owner, "Not owner");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    function send(string calldata message, address target) external owner_only returns (bool) {
        //(bool success, bytes memory data) = target.call(abi.encodeWithSignature("receive(MSG)", MSG(address(this), message)));

        //PMPF(target).receive(MSG(address(this), message));

        //console.log(address(this), ": send returns ", success);

        return false;
    }

    function receive(MSG calldata message) external override(PMPF) {
        console.log("We received a message!");
        console.log(message.value);
    }
}