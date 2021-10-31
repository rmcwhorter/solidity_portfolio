// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./SignedMessage.sol";

library Serialize {
    function SerializeSignedMessage(SignedMessage memory message) internal pure returns (bytes memory) {
        bytes memory orig;
        bytes memory mhash;
        bytes memory rlcl;
        bytes memory slcl;
        bytes memory vlcl;

        addressToBytes(0, message.originator, orig);
        bytes32ToBytes(0, message.eth_signed_message_hash, mhash);
        bytes32ToBytes(0, message.r, rlcl);
        bytes32ToBytes(0, message.s, slcl);
        uint8ToBytes(0, message.v, vlcl);
        
        bytes memory mstring = bytes(message.message);

        return bytes.concat(orig,mhash,rlcl,slcl,vlcl,mstring);
    }

    function addressToBytes(uint _offst, address _input, bytes memory _output) internal pure {
        assembly {
            mstore(add(_output, _offst), _input)
        }
    }

    function bytes32ToBytes(uint _offst, bytes32 _input, bytes memory _output) internal pure {
        assembly {
            mstore(add(_output, _offst), _input)
            mstore(add(add(_output, _offst),32), add(_input,32))
        }
    }

    function uint8ToBytes(uint _offst, uint8 _input, bytes memory _output) internal pure {
        assembly {
            mstore8(add(_output, _offst), _input)
        }
    }

    function stringToBytes(uint _offst, bytes memory _input, bytes memory _output) internal {
        uint256 stack_size = _input.length / 32;
        if(_input.length % 32 > 0) stack_size++;
        
        assembly {
            //let index := 0
            stack_size := add(stack_size,1)//adding because of 32 first bytes memory as the length
            
            for {let index := 0} lt(index,stack_size) {index := add(index ,1)}
            {
                mstore(add(_output, _offst), mload(add(_input,mul(index,32))))
                _offst := sub(_offst , 32)
            }
            
            /*loop:
            mstore(add(_output, _offst), mload(add(_input,mul(index,32))))
            _offst := sub(_offst , 32)
            index := add(index ,1)
            jumpi(loop , lt(index,stack_size))*/
        }
    }
}