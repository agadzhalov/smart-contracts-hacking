// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../src/access-control-2/ToTheMoon.sol";

/**
@dev run "forge test --match-contract AC2" 
*/
contract AccessControlTwo is Test {
    ToTheMoon ttm;

    uint128 public constant INITIAL_MINT = 1000 ether;
    uint128 public constant USER_MINT = 10 ether;
    uint128 public constant ATTACKER_MINT = 10000000 ether;

    uint256 init_attacker_bal;
    uint256 init_vault_bal;

    address deployer;
    address user1;
    address attacker;

    function setUp() public {
        deployer = address(1);
        user1 = address(2);
        attacker = address(3);

        vm.prank(deployer);
        ttm = new ToTheMoon(INITIAL_MINT);
    }

    function testACT2() public {
        vm.startPrank(attacker);
        ttm.mint(attacker, 100);
        vm.stopPrank();
        assertEq(ttm.balanceOf(attacker), 100);
    }
}