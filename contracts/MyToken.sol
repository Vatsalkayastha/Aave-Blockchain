// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract MyToken is ERC20 {
    address public lendContractAddress;

    constructor() ERC20("MyToken", "IBT") {
        _mint(msg.sender, 100000000 * (10 ** 18));
    }

    function setLendContractAddress(address _lendContractAddress) external {
        lendContractAddress = _lendContractAddress;
    }

    function approveLendContract(uint256 _tokenAmount) external {
        require(lendContractAddress != address(0), "Lend contract address not set");
        require(approve(lendContractAddress, _tokenAmount), "Approval failed");
    }
}