// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AdvancedVault} from "src/flash-loan-attack-2/AdvancedVault.sol";
import {Attack} from "src/flash-loan-attack-2/Attack.sol";

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract AdvancedVaultTest is Test {

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    uint256 constant HUNDRED_ETH = 100 ether;

    AdvancedVault vault;
    Attack attack;

    function setUp() public {
        vm.deal(deployer, HUNDRED_ETH);

        vm.startPrank(deployer);
        vault = new AdvancedVault();
        //address(vault).call{value: HUNDRED_ETH}("");
        vault.depositETH{value: HUNDRED_ETH}();
        console.log(address(vault).balance);
        // send assets to Pool
        vm.stopPrank();
        
    }

    function testStealAllMoney() public {
        assertEq(user.balance, 0);
        vm.startPrank(user);    
        attack = new Attack(address(vault));
        attack.attack(HUNDRED_ETH);
        vm.stopPrank();
        assertEq(user.balance, HUNDRED_ETH);
    }

}