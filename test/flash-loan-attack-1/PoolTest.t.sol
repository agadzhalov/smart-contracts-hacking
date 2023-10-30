// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pool} from "src/flash-loan-attack-1/Pool.sol";
import {Token} from "src/flash-loan-attack-1/Token.sol";
import {Attack} from "src/flash-loan-attack-1/Attack.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract PoolTest is Test {

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    uint256 constant HUNDRED_ETH = 100 ether;

    Pool pool;
    Token token;
    Attack attack;

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
        vm.startPrank(user);    
        attack = new Attack(address(pool));
        attack.attack(type(uint256).max);
        vm.stopPrank();
        console.log("Pool balance", IERC20(address(token)).balanceOf(address(pool)));
        assertEq(token.balanceOf(address(pool)),0);
        assertEq(token.balanceOf(user), type(uint256).max);
    }

}