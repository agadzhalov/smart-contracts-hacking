// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {FlashLoan} from "src/flash-loan-2/FlashLoan.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract FL2Test is Test {

    address deployer = makeAddr("deployer");

    uint256 constant HUNDRED_ETH = 100 ether;
    address public immutable USDC_ADDRESS = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public immutable AAVE_LP_ADDRESS = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address public immutable WHALE_ADDRESS = address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);

    FlashLoan flashLoan;
    IERC721 usdc;

    function setUp() public {
        uint256 mainnetFork = vm.createFork("");
        vm.selectFork(mainnetFork);
        vm.rollFork(15969633);
        usdc = IERC721(USDC_ADDRESS);

        vm.deal(deployer, HUNDRED_ETH);

        vm.prank(deployer);
        flashLoan = new FlashLoan(AAVE_LP_ADDRESS);
        
        vm.prank(WHALE_ADDRESS);
        console.log(usdc.balanceOf(WHALE_ADDRESS));
    }

    function testAaveInteraction() public {
        
    }


}