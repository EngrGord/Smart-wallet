//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SafeWallet {
    // The address of the wallet owner
    address payable public owner;
    // Mapping of authorized signers
    mapping(address => bool) public authorizedSigners;
    // Mapping of recovered addresses
    mapping(address => bool) public recovered;
    // Mapping of authorized recover addresses
    mapping(address => bool) public authorizedRecover;
    // Threshold number of authorized signers needed to recover the wallet
    uint public threshold;

    // Mapping to keep track of ETH balance
    mapping(address => uint) public balance;


    // constructor: sets the msg.sender as the owner and an authorized signer
    // sets the threshold to 2
    constructor() {
        owner = payable(msg.sender);
        authorizedSigners[msg.sender] = true;
        threshold = 2;
    }

    // Adds an address as an authorized signer
    function addAuthorizedSigner(address _signer) public {
        require(msg.sender == owner);
        authorizedSigners[_signer] = true;
    }

    // Removes an address from the authorized signers
    function removeAuthorizedSigner(address _signer) public {
        require(msg.sender == owner);
        authorizedSigners[_signer] = false;
    }

    // sets the threshold for the number of authorized signers needed to recover the wallet
    function setThreshold(uint _threshold) public {
        require(msg.sender == owner);
        threshold = _threshold;
    }

    // Function to recover the wallet using a signed message
    function recover(bytes memory _signedMessage, bytes memory sig) public {
        // Only an address that has not recovered yet can call this function
        require(!recovered[msg.sender]);

        // Recover the address that signed the message
        // bytes32 messageHash = keccak256(_signedMessage);
        // address signer = ecrecover(messageHash, sig);
        // Check that the signer is an authorized signer
        // require(authorizedSigners[signer]);

        // Add the address trying to recover to the authorizedRecover mapping
        authorizedRecover[msg.sender] = true;
        // check if the threshold of authorized recover address is reached
        // if (countAuthorizedRecover() >= threshold) {
        //     // Change the owner to the address that called the function
        //     owner = msg.sender;
        //     // mark the address as recovered
        //     recovered[msg.sender] = true;
        // }
    }

    // Counts the number of authorized recover addresses
    // function countAuthorizedRecover() public view returns (uint) {
    //     uint count = 0;
    //     for (address a in authorizedRecover) {
    //         if (authorizedRecover[a]) {
    //             count++;
    //         }
    //     }
    //     return count;
    // }

    // Function to send ether to another address
    function send(address _to, uint _value) public {
        // Only the owner or an authorized signer can call this function
        require(msg.sender == owner || authorizedSigners[msg.sender]);
        // Check that the destination address is valid
        require(_to != address(0));
        // Check that the contract has enough ether to send
        require(_value <= address(this).balance);        
        balance[msg.sender] -= _value;
        balance[_to] += _value;
    }

    function deposit() public payable {
        require(msg.value > 0);
        balance[owner] += msg.value;
    }

    function withdraw(uint _amount) public {
        require(msg.sender == owner);
        require(balance[msg.sender] >= _amount);
        owner.transfer(_amount);
        balance[msg.sender] -= _amount;
    }

    // Allow directly receiving ETH by default.
    receive() external payable {}
}
