// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../src/interfaces/ILendingPool.sol";
import {FlashLoan} from "src/flash-loan-2/FlashLoan.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract FL2Test is Test {

    address deployer = makeAddr("deployer");

    uint256 constant HUNDRED_USDC = 100e6; // 100 USDC
    address public immutable USDC_ADDRESS = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public immutable AAVE_LP_ADDRESS = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address public immutable WHALE_ADDRESS = address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);

    FlashLoan flashLoan;
    IERC20 usdc;

    function setUp() public {
        uint256 mainnetFork = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/EHvsIT5Aaj9GF6LX4s1Q6O_2PtVclUk1");
        vm.selectFork(mainnetFork);
        vm.rollFork(15969633);
        usdc = IERC20(USDC_ADDRESS);

        vm.deal(deployer, 100 ether);

        vm.prank(deployer);
        flashLoan = new FlashLoan(AAVE_LP_ADDRESS);
    }

    function testAaveInteraction() public {
        uint256 poolInitBalance = IERC20(USDC_ADDRESS).balanceOf(AAVE_LP_ADDRESS);
        vm.startPrank(WHALE_ADDRESS);
        usdc.transfer(address(flashLoan), HUNDRED_USDC);
        uint256 contractInitBalance = IERC20(USDC_ADDRESS).balanceOf(address(flashLoan));
        console.log(contractInitBalance, ILendingPool(AAVE_LP_ADDRESS).FLASHLOAN_PREMIUM_TOTAL() * 1e6);
        flashLoan.getFlashLoan(USDC_ADDRESS, HUNDRED_USDC);
        assertTrue(IERC20(USDC_ADDRESS).balanceOf(AAVE_LP_ADDRESS) >= poolInitBalance);
        assertEq(IERC20(USDC_ADDRESS).balanceOf(address(flashLoan)), contractInitBalance - (ILendingPool(AAVE_LP_ADDRESS).FLASHLOAN_PREMIUM_TOTAL() * 1e6)/100);
        vm.stopPrank();
    }


}