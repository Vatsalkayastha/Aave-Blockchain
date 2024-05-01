// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./ATokenETH.sol";

contract LendingPool {
    mapping(address => uint256) public balances;
    // mapping(address => uint256) public borrowedAmounts;
    // mapping(address => bool) public isBorrower;

    uint256 public totalDeposits;
   

    ATokenETH public token; // Token contract address

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount);
    // event Borrow(address indexed user, uint256 amount);
    // event Repay(address indexed user, uint256 amount);

    constructor() {
        token = new ATokenETH();
    }
    event BalanceAfterDeposit(address account, uint256 balance);
    event BalanceAfterWithdrawal(address account, uint256 balance);
    // Deposit funds into the lending pool and mint tokens
    function depositETH(uint256 _ethAmount) external payable {
        
        require(_ethAmount > 0, "Amount must be greater than 0");

        token.mintTokens(msg.sender,  _ethAmount); // Mint tokens directly to the user
        balances[msg.sender] += _ethAmount;
        totalDeposits += _ethAmount;
        emit Deposit(msg.sender, _ethAmount,  _ethAmount);
        emit BalanceAfterDeposit(msg.sender, balances[msg.sender]);
    }
//     function withdraw(uint256 _amount) external payable {
//     emit BalanceAfterWithdrawal(msg.sender, balances[msg.sender]);
//     require(balances[msg.sender] >= _amount, "Insufficient balance");
    
//     // Burn tokens from the user's account
//     token.burnTokens(msg.sender, _amount);

//     // Update balances and totalDeposits
//     balances[msg.sender] -= _amount;
//     totalDeposits -= _amount;

//     emit Withdraw(msg.sender, _amount);
    
// }

    function withdraw(uint256 _amount) external payable {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        token.burnTokens(msg.sender,  _amount);
        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;
        
        emit Withdraw(msg.sender, _amount);
    }

}
