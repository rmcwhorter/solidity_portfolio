//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

struct Profile {
    address owner;
    string salt;
    uint256 psk_hash;
    string json_data; // should be valid JSON always
    bool is_value;
}

contract ENS {
    address admin;
    mapping(string=>Profile) profiles;

    constructor() {
        admin = msg.sender;
    }   

    // modified from stack overflow: https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    // supposedly really cheap
    function concat(string memory left, string memory right) private pure returns (string memory) {
        return string(abi.encodePacked(left,right));
    }

    function verify_password(string calldata profile, string calldata password) external view returns (bool) {
        return profiles[profile].psk_hash == uint256(keccak256(bytes(concat(password, profiles[profile].salt))));
    }

    function create_profile(string calldata profile_name, string calldata salt, uint256 password_hash, string calldata json_data) external returns (bool) {
        if (profiles[profile_name].is_value) {
            // the profile exists already, exit
            return false; 
        } else {
            // we're all good
            profiles[profile_name] = Profile(msg.sender, salt, password_hash, json_data, true);
            return true;
        }
    }

    function update_password(string calldata profile_name, string calldata new_salt, uint256 new_psk_hash) external returns (bool) {
        if (msg.sender != profiles[profile_name].owner) {
            // you can't modify a profile that isn't yours, exit
            return false;
        } else {
            profiles[profile_name].salt = new_salt;
            profiles[profile_name].psk_hash = new_psk_hash;
            return true;
        }
    }

    function update_json(string calldata profile_name, string calldata json_data) external returns (bool) {
        if (profiles[profile_name].owner == msg.sender) {
            // you've got to own the profile to modify it
            profiles[profile_name].json_data = json_data;
            return true;
        } else {
            // you don't own the profile, you can't modify it
            return false; 
        }
    }

    function get_profile(string calldata profile_name) external view returns (Profile memory) {
        return profiles[profile_name];
    }
}
