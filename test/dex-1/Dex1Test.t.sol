// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Chocolate} from "../../src/dex-1/Chocolate.sol";
import {IUniswapV2Pair} from "src/interfaces/IUniswapV2.sol";

contract Dex1Test is Test {

    Chocolate chocolate;
    IUniswapV2Pair pair;

    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant RICH_SIGNER = address(0x8EB8a3b98659Cce290402893d0123abb75E3ab28);

    uint128 constant ETH_BALANCE = 300 ether;
    uint128 constant INITIAL_MINT = 1000000 ether;
    uint128 constant INITIAL_LIQUIDITY = 100000 ether;
    uint128 constant ETH_IN_LIQUIDITY = 100 ether;

    uint128 constant TEN_ETH = 10 ether;
    uint128 constant HUNDRED_CHOCOLATES = 100 ether;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    IERC20 weth = IERC20(WETH_ADDRESS);

    function setUp() public {
        vm.deal(deployer, ETH_BALANCE);
        vm.deal(user, ETH_BALANCE);
        vm.startPrank(deployer);
        chocolate = new Chocolate(INITIAL_MINT);
        pair = IUniswapV2Pair(chocolate.uniswapV2Pair());
    }

    function testAddLiquidity() public {
        // add liquidity tests
        // add liquidity of 100,000 tokens and 100 ETH (1 token = 0.001 ETH)
        vm.startPrank(deployer);
        chocolate.approve(address(chocolate), INITIAL_LIQUIDITY);
        chocolate.addChocolateLiquidity{value: HUNDRED_CHOCOLATES}(INITIAL_LIQUIDITY);

        // print the amount of LP tokens the deployer owns
        console.log("LP Tokens: ", pair.balanceOf(deployer));

        vm.stopPrank();
    }

    function testSwap() public {
        _setup_addLiquidity();
        // From user swap 10 eth to chocolate

        vm.startPrank(user);
        chocolate.swapChocolates{value: TEN_ETH}(WETH_ADDRESS, TEN_ETH);
        console.log("Eth of user: ", user.balance);
        console.log("wEth of user: ", weth.balanceOf(user));
        console.log("Chocolates of user: ", chocolate.balanceOf(user));

        console.log("-------------------");
        
        // From user swap 100 chocolates to ETH
        chocolate.approve(address(chocolate), HUNDRED_CHOCOLATES);
        chocolate.swapChocolates(address(chocolate), HUNDRED_CHOCOLATES);
        console.log("Eth of user: ", user.balance);
        console.log("wEth of user: ", weth.balanceOf(user));
        console.log("Chocolates of user: ", chocolate.balanceOf(user));

        vm.stopPrank();
    }

    function _setup_addLiquidity() private {
        vm.startPrank(deployer);
        chocolate.approve(address(chocolate), INITIAL_LIQUIDITY);
        chocolate.addChocolateLiquidity{value: HUNDRED_CHOCOLATES}(INITIAL_LIQUIDITY);
        vm.stopPrank();
    }
}