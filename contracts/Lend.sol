// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./ERC20.sol";
import "hardhat/console.sol";

contract Lend {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    IERC20 public token; // Token contract address

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount);

    constructor() {
        token = IERC20(0xB201a3dE10285b201Cfc7aE245F6b40F721C7A5b);
    }

    event BalanceAfterDeposit(address account, uint256 balance);
    event BalanceAfterWithdrawal(address account, uint256 balance);

    // Deposit tokens into the lending pool and mint tokens
    function depositTokens(uint256 _tokenAmount) external {
        require(_tokenAmount > 0, "Amount must be greater than 0");

        // Transfer tokens from the user to the contract
        token.transferFrom(msg.sender, address(this), _tokenAmount);

        // Update balances and totalDeposits
        balances[msg.sender] += _tokenAmount;
        totalDeposits += _tokenAmount;

        emit Deposit(msg.sender, _tokenAmount, _tokenAmount);
        emit BalanceAfterDeposit(msg.sender, balances[msg.sender]);
    }

    // Withdraw tokens from the lending pool
    function withdrawTokens(uint256 _tokenAmount) external {
        require(balances[msg.sender] >= _tokenAmount, "Insufficient balance");

        // Transfer tokens from the contract to the user
        token.transfer(msg.sender, _tokenAmount);

        // Update balances and totalDeposits
        balances[msg.sender] -= _tokenAmount;
        totalDeposits -= _tokenAmount;

        emit Withdraw(msg.sender, _tokenAmount);
        emit BalanceAfterWithdrawal(msg.sender, balances[msg.sender]);
    }
}
