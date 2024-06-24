// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);

    function balanceOf(address _account) external view returns (uint256);
}

contract Faucet {
    address public owner;
    IERC20 public token;
    uint256 public withdrawalAmount = 100 * 10 ** 18;

    uint256 public lockTime = 5 minutes;

    struct Transaction {
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint256) public nextAccessTime;
    mapping(address => Transaction[]) public userTransactions;

    event Deposit(address indexed _account, uint256 indexed _amount);
    event Withdraw(address indexed _account, uint256 indexed _amount);

    constructor(address _tokenAddress) {
        owner = payable(msg.sender);
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Faucet: only owner");
        _;
    }

    function requestTokens(address _account) public {
        require(
            token.balanceOf(address(this)) >= withdrawalAmount,
            "Faucet: insufficient funds"
        );
        require(
            block.timestamp >= nextAccessTime[_account],
            "Faucet: Enough time hasn't elapsed"
        );
        require(
            msg.sender != address(0),
            "Faucet: cannot withdraw from 0 address"
        );

        nextAccessTime[_account] = block.timestamp + lockTime;
        userTransactions[_account].push(
            Transaction(_account, withdrawalAmount, block.timestamp)
        );

        token.transfer(_account, withdrawalAmount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function getFaucetBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setWithdrawalAmount(uint256 _amount) public onlyOwner {
        withdrawalAmount = _amount;
    }

    function setLockTime(uint256 _lockTime) public onlyOwner {
        lockTime = _lockTime;
    }

    function getUserTransactions(
        address _address
    ) public view returns (Transaction[] memory) {
        return userTransactions[_address];
    }

    function withdrawAllFunds() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
        emit Withdraw(msg.sender, balance);
    }
}
