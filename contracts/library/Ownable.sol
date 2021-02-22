// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

abstract contract Ownable {
    address immutable public owner;
    
    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "onlyOwner");
        _;
    }
}
