// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);

    function balanceOf(address _account) external view returns (uint256);
}

contract Faucet {
    address public owner;
    IERC20 public token;
    uint256 public widthdrawalAmount = 100 * 10 ** 18;

    uint256 public lockTime = 5 minutes;

    struct Transaction {
        uint256 timestamp;
        uint256 amount;
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
        require(msg.sender >= owner, "Faucet: only owner");
        _;
    }

    function requestTokens() public {
        require(
            token.balanceOf(address(0)) >= widthdrawalAmount,
            "Faucet: insufficient funds"
        );

        require(
            block.timestamp >= nextAccessTime[msg.sender],
            "Faucet: Enough time hasn't elapsed"
        );

        require(
            msg.sender != address(0),
            "Faucet: cannot withdraw from 0 address"
        );

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        token.transfer(msg.sender, widthdrawalAmount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function getFaucetBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setWithdrawalAmount(uint256 _amount) public onlyOwner {
        widthdrawalAmount = _amount * 10 ** 18;
    }

    function setLockTime(uint256 _lockTime) public onlyOwner {
        lockTime = _lockTime * 1 minutes;
    }

    function getUserTransactions(
        address _address
    ) public view returns (Transaction[] memory) {
        return userTransactions[_address];
    }

    function withdrawAllFunds() external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
        emit Withdraw(msg.sender, token.balanceOf(address(this)));
    }
}
