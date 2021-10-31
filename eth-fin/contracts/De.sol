// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

library Deserialize {
    function bytesToAddress(uint _offst, bytes memory _input) internal pure returns (address _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    }

    function bytesToBytes32(uint _offst, bytes memory  _input, bytes32 _output) internal pure {
        
        assembly {
            mstore(_output , add(_input, _offst))
            mstore(add(_output,32) , add(add(_input, _offst),32))
        }
    }

    function bytesToUint8(uint _offst, bytes memory _input) internal pure returns (uint8 _output) {
        
        assembly {
            _output := mload(add(_input, _offst))
        }
    } 

    function getStringSize(uint _offst, bytes memory _input) internal pure returns(uint size){
        
        assembly{
            
            size := mload(add(_input,_offst))
            let chunk_count := add(div(size,32),1) // chunk_count = size/32 + 1
            
            if gt(mod(size,32),0) {// if size%32 > 0
                chunk_count := add(chunk_count,1)
            } 
            
             size := mul(chunk_count,32)// first 32 bytes reseves for size in strings
        }
    }

    function bytesToString(uint _offst, bytes memory _input, bytes memory _output) internal  {

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