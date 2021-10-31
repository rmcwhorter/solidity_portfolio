pragma solidity ^0.8.3;

import "./PointMessagingProtocol.sol";
import "hardhat/console.sol";



contract GroupChat is PMP {
    address[] private members;

    constructor(address[] memory _members) {
        members = _members;
    }

    modifier members_only() {
        bool valid_recipient = false;

        for (uint i = 0; i < members.length; i++) {
            // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            valid_recipient = valid_recipient || (msg.sender == members[i]);
        }

        require(valid_recipient, "Non-GC member addresses cannot interact with this contract!");
        _;
    }

    function send(string calldata message, address target) external override(PMPS) returns (bool) {
        //console.log("[send] was called by ", msg.sender, " with message ", message);

        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("receive(string)", message));

        //console.log("[send]: returns ", success);

        return success;
    }

    function receive(string calldata message) external members_only override(PMPR) {
        console.log("The GC received \"", message, "\" from ", msg.sender);
        
        for (uint i = 0; i < members.length; i++) {
        // we receive a message, and forward it to everyone in the GC who isn't the person who sent the message. 
            if (msg.sender != members[i]) {
                this.send(message, members[i]);
            }
        }
    }


}

contract Chatter is PMP {
    MSG[] private messages;

    constructor() {}

    function status() external {
        console.log(address(this), " has ", messages.length, " messages.");

        for (uint idx = 0; idx < messages.length; idx++) {
            console.log("[READ]: ", messages[idx].originator, " says ", messages[idx].value);
        }
    }

    function send(string calldata message, address target) external override(PMPS) returns (bool) {
        console.log("[send] was called by ", msg.sender, " with message ", message);

        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("receive(string)", message));

        console.log(address(this), ": send returns ", success);

        return success;
    }

    function receive(string calldata message) external override(PMPR) {
        console.log("[receive] was called by with message ", message);
        //messages.push(MSG(message, msg.sender));
        //return PMPState.Success;
    }

}