// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ERC20Demo{

    mapping(address => uint256) private balances;
    uint256 private total;
    mapping(address => mapping(address => uint256)) private approves;// 我授权给某人一笔金额可以帮我转账
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    event Approve(address owner, address spender, uint256 amount);

    event Transfer(address from, address to, uint256 amount);

    function mint(address account, uint256 amount) external onlyOwner {
        total += amount;
        balances[account] += amount;
    }

    function balanceOf(address account) external view returns(uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) external {
        require(to != address(0), "empty address");
        require(balances[msg.sender] >= amount, "The balance is insufficient");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external {
        // 先校验是否可以帮人转账
        address threeParty = msg.sender;
        uint256 balance = approves[from][threeParty];
        require(balance >= amount, "The balance is insufficient");
        require(balances[from] >= amount, "The balance is insufficient");

        approves[from][threeParty] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function approve(address threeParty, uint256 amount) external {
        approves[msg.sender][threeParty] = amount;
        emit Approve(msg.sender, threeParty, amount);
    }

    function balanceOfApprove(address threeParty) external view returns(uint256){
        return approves[msg.sender][threeParty];
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }
}