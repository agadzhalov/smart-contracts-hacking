// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ChainLend} from "../../src/Reentrancy-3/ChainLend.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ChainLendTest is Test {

    ChainLend chainlend;

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    address constant imBTC_ADDRESS = 0x3212b29E33587A00FB1C83346f5dBFA69A458923;
    address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant imBTC_WHALE = 0x3212b29E33587A00FB1C83346f5dBFA69A458923;
    address constant USDC_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    uint256 constant INIT_BALANCE = 100 * 1e18;
    uint256 constant USDC_IN_CHAINLEND = 1000000 / 1e6;

    function setUp() public {
        vm.deal(deployer, INIT_BALANCE);
        vm.deal(attacker, INIT_BALANCE);
        

        vm.startPrank(deployer);
        chainlend = new ChainLend(imBTC_ADDRESS, USDC_ADDRESS);
        vm.stopPrank();

        // Send some ETH for whales for tx fees
        imBTC_WHALE.call{value: 2 * 1e18}("");
        USDC_WHALE.call{value: 2 * 1e18}("");

        // Impersonate imBTC Whale and send 1 imBTC to attacker
        vm.startPrank(imBTC_WHALE);
        IERC20(imBTC_ADDRESS).transfer(attacker, 1);
        vm.stopPrank();

        // Impersonate USDC Whale and send 1M USDC to ChainLend
        vm.startPrank(USDC_WHALE);
        IERC20(USDC_ADDRESS).transfer(address(chainlend), USDC_IN_CHAINLEND);
        vm.stopPrank();

        // vm.startPrank(attacker);
        // attack = new Attack(address(apes));
        // vm.stopPrank();
    }

    function testInitialSetup() public {
        assertEq(IERC20(imBTC_ADDRESS).balanceOf(address(attacker)), 1);
        assertEq(IERC20(USDC_ADDRESS).balanceOf(address(chainlend)), USDC_IN_CHAINLEND);
    }

    function testReentrancyChainLend() public {
        assertEq(INIT_BALANCE, 100 ether);
    }

}