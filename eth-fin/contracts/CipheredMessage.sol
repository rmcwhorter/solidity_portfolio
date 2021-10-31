// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./SignedMessage.sol";

enum BlockCipherAlgorithm {
    AES128,
    AES192,
    ASE256
}

struct CipheredMessage {
    address sender; // this is the person who encrypted the message.
    SignedMessage message;
    BlockCipherAlgorithm algorithm;
}

/*
* Here's the idea. Alice wants to send a ciphered message to Bob.
* So, Alice asks Bob for his public key.
* Alice then uses ECDH to establish a shared secret
* She hashes this shared secret with *something*
* She uses the hash and some block cipher to encrypt her message
* She the signs this message using the SignedMessage stuff we already established
* 
*/