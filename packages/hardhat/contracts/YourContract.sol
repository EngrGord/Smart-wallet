//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Wallet {
    address payable public owner;
    mapping(address => uint) public balance;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() public payable {
        require(msg.value > 0);
        balance[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public {
        require(balance[msg.sender] >= _amount);
        require(msg.sender == owner);
        owner.transfer(_amount);
        balance[msg.sender] -= _amount;
    }

    function transfer(address _to, uint _amount) public {
        require(balance[msg.sender] >= _amount);
        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
    }

    // Allow directly receiving ETH by default.
    receive() external payable {}
}
