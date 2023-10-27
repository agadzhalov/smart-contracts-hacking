// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../interfaces/ILendingPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FlashLoan
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashLoan {

    ILendingPool pool;

    constructor(address _pool) {
        pool = ILendingPool(_pool);
    }

    // TODO: Implement this function
    function getFlashLoan(address token, uint amount) external {

    }

    // TODO: Implement this function
    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory params
    ) public returns (bool) {

    }
}