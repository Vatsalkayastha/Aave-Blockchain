// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ATokenETH is ERC20 {
    address public owner;
    uint256 constant private AAVE_PRICE_USD = 88.53 * (10 ** 18); 
    uint256 constant private ETH_PRICE_USD = 3171.83 * (10 ** 18); 

    uint256 public ethToUsd;
    uint256 public aaveToUsd;
    constructor() ERC20("aToken Ethereum", "anewETH") {
        owner = msg.sender;
        ethToUsd = (10 ** 36) / ETH_PRICE_USD; 
        aaveToUsd = AAVE_PRICE_USD; 
    }

    function mintTokens(address recipient, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint tokens");
        uint256 aaveAmount = (amount * ethToUsd) / aaveToUsd;
        _mint(recipient, aaveAmount);
        uint256 balanceAfterMint = balanceOf(recipient);
        emit BalanceAfterMint(recipient, balanceAfterMint);
        emit TokensMinted(recipient, amount, aaveAmount);
    }
    event BalanceAfterMint(address indexed recipient, uint256 balance);

    function burnTokens(address /*tokenowner*/, uint256 amount) external {
    require(msg.sender == owner, "Only owner can burn tokens");
    uint256 ethAmount = (amount * ethToUsd) / aaveToUsd;
    require(balanceOf(msg.sender) >= ethAmount, "Insufficient balance");

     
    _burn(msg.sender, amount); 
    payable(msg.sender).transfer(ethAmount); 
    emit TokensBurned(msg.sender, amount, ethAmount);
    }


    event TokensMinted(address indexed recipient, uint256 amount, uint256 aaveAmount);
    event TokensBurned(address indexed burner, uint256 amount, uint256 ethAmount);
    
}