// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IReceiver {
    function getETH() external payable;
}

/**
 * @title Pool
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Pool {
    
    constructor() payable {}

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        uint256 initBalance = address(this).balance;
        require(initBalance >= amount, "not enough balance in pool");
        IReceiver(msg.sender).getETH{value: amount}();
        // sends assets
        require(initBalance >= address(this).balance, "receiver can't return the loan");
    }

    receive() external payable {}
}