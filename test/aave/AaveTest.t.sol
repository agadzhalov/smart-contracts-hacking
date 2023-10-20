// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AaveUser} from "../../src/aave/AaveUser.sol";
import "../../src/aave/AaveInterfaces.sol";

contract AaveTest is Test {

    address public immutable aaveV3Pool_Addr = address(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);
    address public immutable USDC_Addr = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public immutable DAI_Addr = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public immutable aUSDC_Addr = address(0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c);
    address public immutable debtDai_Addr = address(0xcF8d0c70c850859266f5C338b38F9D663181C314);
    address public immutable whaleAccount = address(0xF977814e90dA44bFA03b6295A0616a897441aceC);

    AaveUser aave;
    address user = makeAddr("user");

    uint256 constant HUNDRED_ETH = 100 ether;

    function setUp() public {
        vm.deal(user, 2 ether);
        vm.deal(whaleAccount, 2 ether);

        IERC20 usdc = IERC20(USDC_Addr);
        // transfer USDC to user
        vm.startPrank(whaleAccount);
        usdc.transfer(user, usdc.balanceOf(whaleAccount));
        vm.stopPrank();

        // deploy contract
        vm.startPrank(user);
        aave = new AaveUser(aaveV3Pool_Addr, USDC_Addr, DAI_Addr);
        vm.stopPrank();
    }

    function testAaveInteraction() public {
        IERC20 usdc = IERC20(USDC_Addr);
        vm.startPrank(user);
        // approve usdc
        usdc.approve(address(aave), 100e6);
        // deposit usdc
        aave.depositUSDC(100e6);

        // asserts receipt tokens were minted
        assertTrue(aave.depositedBalance(user, USDC_Addr) == 100e6);
        assertEq(IERC20(aUSDC_Addr).balanceOf(user), 100e6);

        // withdraw
        //aave.withdrawUSDC(100e6);

        vm.stopPrank();

    }
  
}