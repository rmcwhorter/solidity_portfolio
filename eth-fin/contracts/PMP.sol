// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "hardhat/console.sol"; // console.log();

import "./SignedMessage.sol";
import "./CipheredMessage.sol";
import "./ERC165.sol";

interface PMP is ERC165 {
    function receive_plain_message(SignedMessage calldata message) external returns (bool);
    function receive_ciphered_message(CipheredMessage calldata message) external returns (bool);
    function request_public_key() external returns (bool);
}

/*
* How do we securely pass messages between smart contracts?
* Let's say that 
*/

/*
* Suppose I try to forward a message to someone.
* What could happen?
* There are two things here - there's me, and there's the 
* originator of the message (could also be me).
* Let's say 
*/

enum PMP_Status_Code {
    ConnectionRejected,
    ReceivedVerified,
    ReceivedUnverified
}
