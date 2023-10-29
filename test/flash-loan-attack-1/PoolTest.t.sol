// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pool} from "src/flash-loan-attack-1/Pool.sol";
import {Token} from "src/flash-loan-attack-1/Token.sol";


/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract PoolTest is Test {

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    uint256 constant HUNDRED_ETH = 100 ether;

    Pool pool;
    Token token;

    function setUp() public {
        vm.deal(deployer, HUNDRED_ETH);

        vm.startPrank(deployer);
        token = new Token();
        pool = new Pool(address(token));
        // send assets to Pool
        token.transfer(address(pool), type(uint256).max);
        vm.stopPrank();
        
    }

    function testStealAllMoney() public {
        console.log(IERC20(address(token)).balanceOf(address(pool)));
    }

}