// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/dos-3/FlashLoanUser.sol";
import "src/dos-3/ShibaPool.sol";
import "src/dos-3/ShibaToken.sol";

/**
@dev run "forge test --match-contract DoS3 -vvv" 
*/
contract TestDoS3 is Test {
    ShibaToken token;
    ShibaPool pool;
    FlashLoanUser userContract;

    uint constant INITIAL_SUPPLY = 1000000 ether; // 1 Million
    uint constant TOKENS_IN_POOL = 100000 ether; // 100K
    uint constant ATTACKER_TOKENS = 10 ether; // 10

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(deployer);
        // Deploy contracts
        token = new ShibaToken(INITIAL_SUPPLY + 100000 ether);
        pool = new ShibaPool(address(token));
        token.transfer(user, 1);

        // Send tokens
        token.transfer(address(attacker), ATTACKER_TOKENS);
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);
        vm.stopPrank();

        // Balances Check
        assertEq(token.balanceOf(address(attacker)), ATTACKER_TOKENS);
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);

        // FlashLoan Check
        vm.startPrank(user);
        userContract = new FlashLoanUser(address(pool), address(token));
        token.transfer(address(userContract), 1);

        userContract.requestFlashLoan(10);
        vm.stopPrank();
    }

    function test_Attack() public {
        /** CODE YOUR SOLUTION HERE */
        vm.startPrank(attacker);

        //token.transfer(address(pool), ATTACKER_TOKENS);

        vm.stopPrank();

        /** SUCCESS CONDITIONS */
        vm.expectRevert();
        vm.prank(user);
        userContract.requestFlashLoan(10);
    }
}