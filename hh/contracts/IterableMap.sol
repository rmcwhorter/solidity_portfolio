// SPDX-License-Identifier: MIT
// Taken from solidity-by-example.org/app/iterable-mapping/
pragma solidity ^0.8.3;

import "hardhat/console.sol"; // console.log();


// An unordered, iterable set
library IterableSet {

    // this thing is gonna be seriously gas expensive. 
    // we assert from the outset that indexer has keys equal to [0, size).
    // order doesn't matter, and we can abuse this in removal.
    // we also assert that indexer and inverse are inverses of each other.
    struct Set {
        mapping(address => bool) values;
        mapping(uint => address) indexer;
        mapping(address => uint) inverse;
        uint length;
    }

    function get(Set storage set, address target) public view returns (bool) {
        return set.values[target];
    }

    function index(Set storage set, uint idx) public view returns (address) {
        return set.indexer[idx];
    }

    function add(Set storage set, address target) public {
        if (set.values[target]) {
            // the address is already in the set
            // we just pass
        } else {
            // the address isn't already in the set
            // we add in address to values with value true
            // we add size => address in indexer
            // we add address => size in inverse
            // we increment size
            set.values[target] = true;
            set.indexer[set.length] = target;
            set.inverse[target] = set.length;
            set.length += 1;
        }
    }

    function remove(Set storage set, address target) public {
        if (set.values[target]) {
            // the address is in the set
            // we remove it from values
            // we set target's index to the address at the end of the indexer
            // 
            delete set.values[target];

            set.indexer[set.inverse[target]] = set.indexer[set.length - 1];
            delete set.indexer[set.length - 1];

            set.inverse[set.indexer[set.length - 1]] = set.inverse[target];
            delete set.inverse[target];

            set.length -= 1;
        } else {
            // the address doesn't exist in the set, we can just pass
        }
    }
}

/*
library IterableMapping {
    // Iterable mapping from address to bool;
    struct Map {
        address[] keys;
        mapping(address => bool) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (bool) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}*/