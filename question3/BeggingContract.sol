// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BeggingContract{

    mapping(address => uint256) private donations;
    address[] private keys;
    address private owner;
    uint256 private lockTime;// 时间显示，单位为秒
    uint256 private deploymentTimestamp;// 部署合约时间戳

    event Donation(address, uint256);// 捐款事件

    constructor(uint256 _lockTime){
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    function donate() external payable {
        require(block.timestamp < deploymentTimestamp + lockTime, "the windows closed");
        if (donations[msg.sender] == 0){
            keys.push(msg.sender);
        }
        donations[msg.sender] += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    function withdraw() external payable onlyOwner {
        require(block.timestamp >= deploymentTimestamp + lockTime, "the windows opening");
        payable(owner).transfer(address(this).balance);
    }

    function getDonation(address account) external view returns(uint256){
        return donations[account];
    }

    // 获取捐款前三的人的地址
    function getTop() external view  returns(address[3] memory){
        address[3] memory topAddress;
        uint256 max;
        uint256 middle;
        uint256 min;
        for (uint256 i = 0; i < keys.length; i++) 
        {
            address user = keys[i];
            uint256 amount = donations[user];
            if (amount > max){
                min = middle;
                middle = max;
                max = amount;
                topAddress[2] = topAddress[1];
                topAddress[1] = topAddress[0];
                topAddress[0] = user;
            } else if(amount > middle){
                min = middle;
                middle = amount;
                topAddress[2] = topAddress[1];
                topAddress[1] = user;
            } else if(amount > min){
                min = amount;
                topAddress[2] = user;
            }

        }
        return topAddress;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "No Permissions");
        _;
    }
}