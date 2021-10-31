// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./ERC165.sol";

/*
* VERSION 4
* The intent of this is to create a point messaging protocol that sends
* signed messages, verified by the originator's address
*/

// It works!
function recover_vrs(
    bytes32 _ethSignedMessageHash, 
    bytes32 r, 
    bytes32 s, 
    uint8 v
) pure returns (address) {
    return ecrecover(_ethSignedMessageHash, v, r, s);
}

function verify_signed_message(SignedMessage memory message) pure returns (bool) {
    return recover_vrs(message.eth_signed_message_hash, message.r, message.s, message.v) == message.originator;
}

struct SignedMessage {
    address originator;
    string message;
    bytes32 eth_signed_message_hash;
    bytes32 r;
    bytes32 s;
    uint8 v;
}

interface PMPS is ERC165 {
    function try_send_message(SignedMessage calldata message, address target) external returns (bool);
    function receive_message(SignedMessage calldata message) external returns (bool);
}

interface PubSub is PMPS {
    function extern_is_subscribed() external returns (bool);
    function extern_request_subscribe() external returns (bool);
    function extern_request_unsubscribe() external returns (bool);
}