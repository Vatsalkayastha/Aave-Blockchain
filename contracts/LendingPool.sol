// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./Erc20.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LendingPool {
    mapping(address => uint256) public matic_balances;
    mapping(address => uint256) public ibt_balances;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public borrowedAmounts;
    mapping(address => bool) public isBorrower;
    mapping(address => uint256) public timestamp_borrow;
    mapping(address => bool) public isFirstRepay;
    mapping(address => uint256) public repayable_interest;
    uint256 public MTC_price;
    uint256 public matic_totalDeposits;
    uint256 public ibt_totalDeposits;
    mapping(address => uint256) public matic_interest_balances;
    mapping(address => uint256) public matic_deposit_timestamp;
    mapping(address => uint256) public matic_accruedInterest;
    mapping(address => uint256) public ibt_interest_balances;
    mapping(address => uint256) public ibt_deposit_timestamp;
    mapping(address => uint256) public ibt_accruedInterest;
    bool public ibt_isFirstWithdraw;
    bool public matic_isFirstWithdraw;
    mapping(address => uint256) public ibt_withdrawInterest;
    mapping(address => uint256) public matic_withdrawInterest;
    mapping(address => uint256) public borrowable_amount;

    AToken public token; // Token contract address
    ERC20 public mytoken_address;

    event Deposit(address indexed user, uint256 amount, uint256 tokensMinted);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);


    constructor() {
        token = new AToken();
        mytoken_address = ERC20(0xA7385B18BD0609551bE8BC4be1aF38D54C6c1720);
    }

    event BalanceAfterDeposit(address account, uint256 balance);
    event BalanceAfterWithdrawal(address account, uint256 balance);

    // Deposit funds into the lending pool and mint tokens
    function depositMATIC() external payable {
        uint256 _maticAmount = msg.value;
        MTC_price = 0.72 * (10 ** 18);
        require(_maticAmount > 0, "Amount must be greater than 0");

        token.mintTokenswithMTC(msg.sender, _maticAmount); // Mint tokens directly to the user
        matic_balances[msg.sender] += _maticAmount;

        borrowable_amount[msg.sender] =
            (matic_balances[msg.sender] * (7) * (MTC_price)) /
            10;
        matic_totalDeposits += _maticAmount;
        if (matic_balances[msg.sender] == _maticAmount) {
            matic_isFirstWithdraw = true;
            matic_deposit_timestamp[msg.sender] = block.timestamp;
            matic_accruedInterest[msg.sender] = 0;
            matic_interest_balances[msg.sender] = _maticAmount;
        } else {
            matic_accruedInterest[msg.sender] +=
                ((block.timestamp - matic_deposit_timestamp[msg.sender]) *
                    matic_balances[msg.sender]) /
                1000000;
            matic_deposit_timestamp[msg.sender] = block.timestamp;
            matic_interest_balances[msg.sender] += _maticAmount;
        }
        console.log(matic_balances[msg.sender]);
        console.log(matic_deposit_timestamp[msg.sender]);
        console.log(matic_accruedInterest[msg.sender]);

        emit Deposit(msg.sender, _maticAmount, _maticAmount);
        emit BalanceAfterDeposit(msg.sender, matic_balances[msg.sender]);
    }

    function depositIBT() external payable {
        uint256 _ibtAmount = msg.value;
        require(_ibtAmount > 0, "Amount must be greater than 0");
        require(
            mytoken_address.transferFrom(msg.sender, address(this), _ibtAmount),
            "Transfer failed"
        );

        token.mintTokensWithUSD(msg.sender, _ibtAmount); // Mint tokens directly to the user
        ibt_balances[msg.sender] += _ibtAmount;
        ibt_totalDeposits += _ibtAmount;
        if (ibt_balances[msg.sender] == _ibtAmount) {
            ibt_isFirstWithdraw = true;
            ibt_deposit_timestamp[msg.sender] = block.timestamp;
            ibt_accruedInterest[msg.sender] = 0;
            ibt_interest_balances[msg.sender] = _ibtAmount;
        } else {
            ibt_accruedInterest[msg.sender] +=
                ((block.timestamp - ibt_deposit_timestamp[msg.sender]) *
                    ibt_balances[msg.sender]) /
                1000000;
            ibt_deposit_timestamp[msg.sender] = block.timestamp;
            ibt_interest_balances[msg.sender] += _ibtAmount;
        }
        console.log(ibt_balances[msg.sender]);
        console.log(ibt_deposit_timestamp[msg.sender]);
        console.log(ibt_accruedInterest[msg.sender]);

        emit Deposit(msg.sender, _ibtAmount, _ibtAmount);
        emit BalanceAfterDeposit(msg.sender, ibt_balances[msg.sender]);
    }

    function withdrawIBT(uint256 _amount) external {
        uint256 time_now;
        time_now = block.timestamp;
        console.log(ibt_balances[msg.sender]);
        require(ibt_balances[msg.sender] >= _amount, "Insufficient balance");

        require(mytoken_address.transfer(msg.sender, _amount), "Transfer failed");
        if (ibt_isFirstWithdraw) {
            ibt_withdrawInterest[msg.sender] = ((
                ibt_accruedInterest[msg.sender]
            ) +
                ((time_now - ibt_deposit_timestamp[msg.sender]) *
                    ibt_balances[msg.sender]) /
                1000000);
            console.log(ibt_withdrawInterest[msg.sender]);
            payable(msg.sender).transfer(
                _amount + ibt_withdrawInterest[msg.sender]
            );
            ibt_withdrawInterest[msg.sender] = 0;

            ibt_interest_balances[msg.sender] -= _amount;
            ibt_isFirstWithdraw = false;
        } else if (!ibt_isFirstWithdraw) {
            ibt_withdrawInterest[msg.sender] = (((time_now -
                ibt_deposit_timestamp[msg.sender]) * ibt_balances[msg.sender]) /
                1000000);
            console.log(ibt_withdrawInterest[msg.sender]);
            payable(msg.sender).transfer(
                _amount + ibt_withdrawInterest[msg.sender]
            );
            ibt_interest_balances[msg.sender] -= _amount;
            ibt_withdrawInterest[msg.sender] = 0;
        }

        ibt_deposit_timestamp[msg.sender] = time_now;
        token.burnTokensWithUSD(msg.sender, _amount);
        ibt_balances[msg.sender] -= _amount;
        ibt_totalDeposits -= _amount;
        console.log("Balances Left :");
        console.log(ibt_balances[msg.sender]);

        emit Withdraw(msg.sender, _amount);
    }

    function withdrawMATIC(uint256 _amount) external {
        uint256 time_now;
        time_now = block.timestamp;
        console.log(matic_balances[msg.sender]);
        require(matic_balances[msg.sender] >= _amount, "Insufficient balance");

        if (matic_isFirstWithdraw) {
            matic_withdrawInterest[msg.sender] = ((
                matic_accruedInterest[msg.sender]
            ) +
                ((time_now - matic_deposit_timestamp[msg.sender]) *
                    matic_balances[msg.sender]) /
                1000000);
            console.log(matic_withdrawInterest[msg.sender]);
            payable(msg.sender).transfer(
                _amount + matic_withdrawInterest[msg.sender]
            );
            matic_withdrawInterest[msg.sender] = 0;

            matic_interest_balances[msg.sender] -= _amount;
            matic_isFirstWithdraw = false;
        } else if (!matic_isFirstWithdraw) {
            matic_withdrawInterest[msg.sender] = (((time_now -
                matic_deposit_timestamp[msg.sender]) *
                matic_balances[msg.sender]) / 1000000);
            console.log(matic_withdrawInterest[msg.sender]);
            payable(msg.sender).transfer(
                _amount + matic_withdrawInterest[msg.sender]
            );
            matic_interest_balances[msg.sender] -= _amount;
            matic_withdrawInterest[msg.sender] = 0;
        }

        matic_deposit_timestamp[msg.sender] = time_now;
        token.burnTokenswithMTC(msg.sender, _amount);
        matic_balances[msg.sender] -= _amount;
        borrowable_amount[msg.sender] =
            (matic_balances[msg.sender] * (MTC_price) * 7) /
            10;
        matic_totalDeposits -= _amount;
        console.log("Balances Left :");
        console.log(matic_balances[msg.sender]);

        emit Withdraw(msg.sender, _amount);
    }
}
