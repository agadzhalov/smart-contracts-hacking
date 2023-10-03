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

    }

    function testDeposit() public {
        
    }

    function testWithdraw() public {

    }

}