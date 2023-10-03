// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TokensDepository} from "../../src/erc20-2/TokenDepository.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {rToken} from "../../src/erc20-2/rToken.sol";

contract TokenDepositoryTest is Test {

    address public constant AAVE_ADDRESS = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    address public constant UNI_ADDRESS = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant HOLDER = 0xA69babEF1cA67A37Ffaf7a485DfFF3382056e78C;

    uint256 public constant ONE_ETH = 1 ether;

    uint256 public constant AAVE_AMOUNT = 15 ether;
    uint256 public constant UNI_AMOUNT = 100 ether;
    uint256 public constant WETH_AMOUNT = 150 ether;

    uint256 public aaveInitialBalance;
    uint256 public uniInitialBalance;
    uint256 public wethInitialBalance;

    TokensDepository public depository;
    mapping(address => IERC20) supportedTokens;
    mapping(address => rToken) receiptTokens;

    function setUp() public {
        // deploy token
        depository = new TokensDepository(AAVE_ADDRESS, UNI_ADDRESS, WETH_ADDRESS);

        // load supported tokens
        supportedTokens[AAVE_ADDRESS] = IERC20(AAVE_ADDRESS);
        supportedTokens[UNI_ADDRESS] = IERC20(UNI_ADDRESS);
        supportedTokens[WETH_ADDRESS] = IERC20(WETH_ADDRESS);

        // load receipt tokens
        receiptTokens[AAVE_ADDRESS] = depository.receiptTokens(AAVE_ADDRESS);
        receiptTokens[UNI_ADDRESS] = depository.receiptTokens(UNI_ADDRESS);
        receiptTokens[WETH_ADDRESS] = depository.receiptTokens(WETH_ADDRESS);

        // send eth to holder in case it doesn't have any
        (bool success, ) = HOLDER.call{value: ONE_ETH}("");

        // set initial balances
        aaveInitialBalance = supportedTokens[AAVE_ADDRESS].balanceOf(HOLDER);
        uniInitialBalance = supportedTokens[UNI_ADDRESS].balanceOf(HOLDER);
        wethInitialBalance = supportedTokens[WETH_ADDRESS].balanceOf(HOLDER);
    }

    function testDeposit() public {
        vm.startPrank(HOLDER);
        // aave approve, transferFrom and assert
        supportedTokens[AAVE_ADDRESS].approve(address(depository), AAVE_AMOUNT);
        depository.deposit(AAVE_ADDRESS, AAVE_AMOUNT);

        // assert depository contract contains amount of supported aave token
        assertEq(supportedTokens[AAVE_ADDRESS].balanceOf(address(depository)), AAVE_AMOUNT);

        // assert minted receipt tokens to HOLDER
        assertEq(receiptTokens[AAVE_ADDRESS].balanceOf(HOLDER), AAVE_AMOUNT);

        // uni approve, transferFrom and assert
        supportedTokens[UNI_ADDRESS].approve(address(depository), UNI_AMOUNT);
        depository.deposit(UNI_ADDRESS, UNI_AMOUNT);
        assertEq(supportedTokens[UNI_ADDRESS].balanceOf(address(depository)), UNI_AMOUNT);
        assertEq(receiptTokens[UNI_ADDRESS].balanceOf(HOLDER), UNI_AMOUNT);

        // weth approve, transferFrom and assert
        supportedTokens[WETH_ADDRESS].approve(address(depository), WETH_AMOUNT);
        depository.deposit(WETH_ADDRESS, WETH_AMOUNT);
        assertEq(supportedTokens[WETH_ADDRESS].balanceOf(address(depository)), WETH_AMOUNT);
        assertEq(receiptTokens[WETH_ADDRESS].balanceOf(HOLDER), WETH_AMOUNT);

        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.startPrank(HOLDER);

        // before withrdrawing we have to deposit
        supportedTokens[AAVE_ADDRESS].approve(address(depository), AAVE_AMOUNT);
        supportedTokens[UNI_ADDRESS].approve(address(depository), UNI_AMOUNT);
        supportedTokens[WETH_ADDRESS].approve(address(depository), WETH_AMOUNT);

        depository.deposit(AAVE_ADDRESS, AAVE_AMOUNT);
        depository.deposit(UNI_ADDRESS, UNI_AMOUNT);
        depository.deposit(WETH_ADDRESS, WETH_AMOUNT);

        depository.withdraw(AAVE_ADDRESS, AAVE_AMOUNT);
        depository.withdraw(UNI_ADDRESS, UNI_AMOUNT);
        depository.withdraw(WETH_ADDRESS, WETH_AMOUNT);

        // assert depositor got back the assets
        assertEq(supportedTokens[AAVE_ADDRESS].balanceOf(HOLDER), aaveInitialBalance);
        assertEq(supportedTokens[UNI_ADDRESS].balanceOf(HOLDER), uniInitialBalance);
        assertEq(supportedTokens[WETH_ADDRESS].balanceOf(HOLDER), wethInitialBalance);
        
        // assert the right amount of tokens were burn
        assertEq(receiptTokens[AAVE_ADDRESS].balanceOf(HOLDER), 0);
        assertEq(receiptTokens[UNI_ADDRESS].balanceOf(HOLDER), 0);
        assertEq(receiptTokens[WETH_ADDRESS].balanceOf(HOLDER), 0);

        vm.stopPrank();
    }

}