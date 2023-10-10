// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title EtherBank
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract EtherBank is ReentrancyGuard {

    mapping(address => uint256) public balances;
    bool private locked;

    modifier protected() {
        require(!locked, "no reentrancy");
        // before starting the execution we set the flag to true
        locked = true;
        _;
        // after the execution of the function we set the flag to false
        locked = false;
    }

    function depositETH() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawETH() public nonReentrant {
        uint256 balance = balances[msg.sender];

        // Update Balance
        balances[msg.sender] = 0;

        // Send ETH 
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdraw failed");
    }
}