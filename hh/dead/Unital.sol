pragma solidity ^0.8.3;

import "./Message.sol";
import "hardhat/console.sol";

contract Sender is EMPS {
    function send(string calldata _message) external override(EMPS) returns (bool) {
        console.log("[send] was called with message ", _message);
        return true;
    }

    constructor(string memory _message) public {
        send(_message);
    }
}