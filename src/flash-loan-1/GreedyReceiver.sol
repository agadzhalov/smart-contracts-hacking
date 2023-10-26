// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/console.sol";

interface IPool {
    function flashLoan(uint256 amount) external;
}

/**
 * @title GreedyReceiver
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract GreedyReceiver {

    IPool pool;
    uint256 public amountToReturn;
    
    constructor(address _poolAddress) {
        pool = IPool(_poolAddress);
    }

    // TODO: Implement Receiver logic (Receiving a loan and paying it back)

    // TODO: Complete this function
    function flashLoan(uint256 amount) external {
        pool.flashLoan(amount);
    }

    // TODO: Complete getETH() payable function
    function getETH() external payable returns(bytes32) {
        // do something with money
        console.log("during greedy loan");
        return keccak256("Receiver.getETH");
    }

}