// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../src/interfaces/IPair.sol";
import {FlashSwap} from "src/flash-loan-3/FlashSwap.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract FL3Test is Test {

    address deployer = makeAddr("deployer");

    uint256 constant HUNDRED_USDC = 100e6; // 100 USDC
    address public immutable USDC_ADDRESS = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public immutable USDC_WETH_PAIR = address(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    address public immutable WHALE_ADDRESS = address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);

    FlashSwap flashSwap;
    IERC20 usdc;

    function setUp() public {
        uint256 mainnetFork = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/EHvsIT5Aaj9GF6LX4s1Q6O_2PtVclUk1");
        vm.selectFork(mainnetFork);
        vm.rollFork(15969633);
        usdc = IERC20(USDC_ADDRESS);

        vm.deal(deployer, 100 ether);

        vm.prank(deployer);
        flashSwap = new FlashSwap(USDC_WETH_PAIR);
    }

    function testUniswapV2Swap() public {
        vm.startPrank(WHALE_ADDRESS);
        uint256 initPoolToken = usdc.balanceOf(USDC_WETH_PAIR);
        // to have to pay the fee
        usdc.transfer(address(flashSwap), HUNDRED_USDC);
        flashSwap.executeFlashSwap(USDC_ADDRESS, HUNDRED_USDC);
        assertGt(usdc.balanceOf(USDC_WETH_PAIR), initPoolToken);
        vm.stopPrank();
    }


}