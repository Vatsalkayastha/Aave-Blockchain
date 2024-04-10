// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LendingPool {
    // Address of the Matic token contract
    address public constant MATIC_TOKEN_ADDRESS = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0; // Matic Token address

    // Mapping to store deposited balances
    mapping(address => uint256) public depositedBalances;
    // Total reserves of the lending pool
    uint256 public totalReserves;

    // Event emitted when Matic is deposited
    event MaticDeposited(address indexed depositor, uint256 amount);

    // Function to deposit Matic into the lending pool from user's wallet
    function depositFromWallet(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer Matic from user's wallet to this contract
        IERC20(MATIC_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount);

        // Update deposited balances
        depositedBalances[msg.sender] += amount;
        // Update total reserves
        totalReserves += amount;

        // Emit event
        emit MaticDeposited(msg.sender, amount);
    }

    // Function to get the contract's Matic balance
    function getContractMaticBalance() public view returns (uint256) {
        return IERC20(MATIC_TOKEN_ADDRESS).balanceOf(address(this));
    }
}