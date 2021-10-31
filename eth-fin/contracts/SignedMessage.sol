// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Ser.sol";
import "./De.sol";

struct SignedMessage {
    address originator;
    bytes32 eth_signed_message_hash;
    bytes32 r;
    bytes32 s;
    uint8 v;
    string message;
}

/*
function DeserializeSignedMessage(bytes memory input) pure returns (SignedMessage memory) {
    address orig = address(input[]);


    return 
}*/

function verify_signed_message(SignedMessage memory message) pure returns (bool) {
    return ecrecover(message.eth_signed_message_hash, message.v, message.r, message.s) == message.originator;
}

