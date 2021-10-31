// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Ser.sol";
import "./De.sol";
import "./SignedMessage.sol";

import "hardhat/console.sol"; // console.log();

contract Test {
    constructor() {
        address n = msg.sender;

        console.log(n);

        bytes memory b = new bytes(0);

        Serialize.addressToBytes(0, n, b);

        address t = Deserialize.bytesToAddress(0, b);

        console.log(t);

        /*
        address t = msg.sender;

        console.log(t);

        bytes memory b = new bytes(20);

        console.log(b.length);

        Serialize.addressToBytes(0, t, b);

        for (uint i = 0; i < b.length; i++) {
            bytes1 tmp = b[i];
            console.log(tmp);
        }

        address out = Deserialize.bytesToAddress(0, b);

        console.log(out);*/

    }

    function b32(bytes32 input) external {
        bytes memory b = new bytes(0);
        Serialize.bytes32ToBytes(0, input, b);

        bytes32 o;
        Deserialize.bytesToBytes32(0, b, o);
        console.log(input == o);
    }

    function test_ser() external {
        bytes32 a = "asdf";
        SignedMessage memory message = SignedMessage(msg.sender, a, a, a, 27, "");

        bytes memory serialized = Serialize.SerializeSignedMessage(message);

        console.log(serialized.length);
    }

    
}