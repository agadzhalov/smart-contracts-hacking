// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IReceiver {
    function getETH() external payable returns(bytes32);
}

/**
 * @title Pool
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Pool {
    bytes32 public immutable CALLBACKK_SUCCES = keccak256("Receiver.getETH");
    uint256 public amountToReturn;
    
    constructor() payable {}

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        uint256 initBalance = address(this).balance;
        require(initBalance >= amount, "not enough balance in pool");
        require(IReceiver(msg.sender).getETH{value: amount}() == CALLBACKK_SUCCES, "callback failure");
        // sends assets
        require(initBalance <= address(this).balance, "receiver can't return the loan");
    }

    receive() external payable {
        amountToReturn = msg.value;
    }
}