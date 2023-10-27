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
        address[] memory assets = new address[](1);
        assets[0] = token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount; 
        uint256[] memory interestRateModes = new uint256[](1);
        interestRateModes[0] = 0; 

        console.log("Pool before: ", IERC20(token).balanceOf(address(pool)));
        console.log("Contract before: ", IERC20(token).balanceOf(address(this)));

        pool.flashLoan(address(this),assets,amounts,interestRateModes,address(0),"",0);

        console.log("Pool after: ", IERC20(token).balanceOf(address(pool)));
        console.log("Contract after: ", IERC20(token).balanceOf(address(this)));
    }

    // TODO: Implement this function
    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory params
    ) public returns (bool) {

        console.log("Pool during", IERC20(assets[0]).balanceOf(address(pool)));
        console.log("Contract during: ", IERC20(assets[0]).balanceOf(address(this)));

        // @TODO add for loop to iterate over all assets and amount

        address usdc = assets[0];
        uint256 amount = amounts[0];
        uint toBeReturned = amount + premiums[0]; // premius[0] is the fee
        IERC20(usdc).approve(address(pool), toBeReturned);
        return true;
    }
}