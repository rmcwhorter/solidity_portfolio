// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

function gated_append(address target_addr, address[] storage target_array) returns (bool) {
    bool is_in = false;

    for (uint idx=0; idx < target_array.length; idx++) {
        is_in = is_in || (target_addr == target_array[idx]);
    }


    if (!is_in) {
        target_array.push(target_addr);
        return true;
    } else {
        return false;
    }
}