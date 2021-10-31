// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

library Deserialize {
    function bytesToAddress(uint _offst, bytes memory _input) public pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) public pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }

    function bytesToUint8(uint _offst, bytes memory _input) public pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function getStringSize(uint _offst, bytes memory _input) public pure returns(uint size){
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) public  {

        uint size = 32;
        assembly {
            
                  
            let chunk_count
            
            size := mload(add(_input,_offst))
            chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {
                chunk_count := add(chunk_count,1)  // chunk_count++
            }
                
            //let loop_index:= 0

            for {let loop_index := 0} lt(loop_index , chunk_count) {loop_index := add(loop_index, 1)}
            {
                mstore(add(_output,mul(loop_index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
            }
            /*loop:

                mstore(add(_output,mul(loop_index,32)),mload(add(_input,_offst)))
                _offst := sub(_offst,32)           // _offst -= 32
                loop_index := add(loop_index,1)
                jumpi(loop , lt(loop_index , chunk_count))*/
            
        }
    }
}

library Serialize {
    function addressToBytes(uint _offst, address _input, bytes memory _output) public pure {
        assembly {
            mstore(add(_output, _offst), _input)
        }
    }

    function bytes32ToBytes(uint _offst, bytes32 _input, bytes memory _output) public pure {
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

