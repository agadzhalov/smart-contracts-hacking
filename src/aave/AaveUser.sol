// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.18;

import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AaveInterfaces.sol";

contract AaveUser is Ownable {

    // TODO: Complete state variables
    IPool private pool;
    IERC20 private immutable usdcToken;
    IERC20 private immutable daiToken;

    mapping(address user => mapping(address token => uint256)) public depositedAmount;
    mapping(address user => mapping(address token => uint256)) public borrowedAmount;
    
    // TODO: Complete the constructor
    constructor(address _pool, address _usdc, address _dai) {
        pool = IPool(_pool);
        usdcToken = IERC20(_usdc);
        daiToken = IERC20(_dai);
    }

    // Deposit USDC in AAVE Pool
    function depositUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        require(usdcToken.balanceOf(msg.sender) >= _amount, "insufficient balance");
    
        // TODO: Update depositedamount state var
        depositedAmount[msg.sender][address(usdcToken)] += _amount;

        // TODO: Transfer from the sender the USDC to this contract
        usdcToken.transferFrom(msg.sender, address(this), _amount);

        // TODO: Supply USDC to aavePool Pool
        usdcToken.approve(address(pool), _amount);
        pool.supply(address(usdcToken), _amount, msg.sender, 0);
        
    }

    // Withdraw USDC
    function withdrawUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        
        // TODO: Revert if the user is trying to withdraw more than the deposited amount
        require(depositedAmount[msg.sender][address(usdcToken)] >= _amount, "insufficient deposit");
        
        // TODO: Update depositedamount state var
        depositedAmount[msg.sender][address(usdcToken)] -= _amount;

        // TODO: Withdraw the USDC tokens, send them directly to the user
        pool.withdraw(address(usdcToken), _amount, msg.sender);
    }

    // Borrow DAI From aave, send DAI to the user (msg.sender)
    function borrowDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function

        // TODO: Update borrowedAmmount state var

        // TODO: Borrow the DAI tokens in variable interest mode

        // TODO: Transfer DAI token to the user

    }

    // Repay the borrowed DAI to AAVE
    function repayDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function

        // TODO: Revert if the user is trying to repay more tokens that he borrowed

        // TODO: Update borrowedAmmount state var
        
        // TODO: Transfer the DAI tokens from the user to this contract

        // TODO: Approve AAVE Pool to spend the DAI tokens

        // TODO: Repay the loan
        
    }

    function depositedBalance(address _user, address _token) external returns(uint256) {
        return depositedAmount[_user][_token];
    }
}