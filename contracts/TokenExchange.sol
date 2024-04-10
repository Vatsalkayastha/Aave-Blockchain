// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenExchange {
    // Matic token address
    address public constant MATIC_TOKEN_ADDRESS = 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0; // Matic Token address

    // Custom token details
    string public name;
    string public symbol;
    uint8 public decimals;

    // Event emitted when tokens are exchanged
    event TokensExchanged(address indexed user, uint256 maticAmount, uint256 tokenAmount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    // Function to exchange Matic for custom tokens
    function exchangeMaticForTokens(uint256 maticAmount) external payable {
        require(msg.value == 0, "ETH sent with the transaction");
        require(maticAmount > 0, "Amount must be greater than 0");

        // Transfer Matic from user to contract
        require(IERC20(MATIC_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), maticAmount), "Matic transfer failed");

        // Mint equivalent amount of custom tokens
        uint256 tokenAmount = maticAmount; // Assuming 1:1 exchange rate
        _mint(msg.sender, tokenAmount);

        // Emit event
        emit TokensExchanged(msg.sender, maticAmount, tokenAmount);
    }

    // Internal function to mint tokens
    function _mint(address account, uint256 amount) internal {
        ERC20 _token = new ERC20(name, symbol);
        _token._mint(account, amount);
    }
}
