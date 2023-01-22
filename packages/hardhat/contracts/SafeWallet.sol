//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

error NOT_AUTHORIZED();
error INVALID_ADDRESS();
error INVALID_AMOUNT();
error INSUFFICIENT_BALANCE();
error FAILED_TRANSACTION();


contract SafeWallet {
    // The address of the account owners
    address[] public owners;
    // Mapping of authorized signers
    mapping(address => mapping(address => bool)) public authorizedSigners;
    // Mapping of recovered addresses
    mapping(address => bool) public recovered;
    // Mapping of authorized recover addresses
    mapping(address => bool) public authorizedRecover;
    // Threshold number of authorized signers needed to recover the wallet
    mapping(address => uint256) public threshold;
    // Mapping to keep track of ETH balance
    mapping(address => uint256) public balance;


    event NewOwner(address _owner);
    event Deposit(address from, uint256 amount);
    event Withdraw(address to, uint256 amount);
    event Sent(address from, address to, uint256 amount);





    // constructor: sets the msg.sender as the owner and an authorized signer
    // sets the threshold to 2
    constructor() {
        owners.push(payable(msg.sender));
        authorizedSigners[msg.sender] = true;
        threshold = 2;
    }

    modifier onlyOwner() {
        if(owners[msg.sender]){
            _;
        } else {
            revert NOT_AUTHORIZED();
        }
    }

    function addOwner() external payable {
        require(!owners.contains(msg.sender));
        owners.push(payable(msg.sender));
        balance[msg.sender] = msg.value;
        emit NewOwner(msg.sender);
    }


    // Adds an address as an authorized signer
    function addAuthorizedSigner(address _signer) public onlyOwner {
        
        authorizedSigners[msg.sender][_signer] = true;
    }

    // Removes an address from the authorized signers
    function removeAuthorizedSigner(address _signer) public onlyOwner {
        authorizedSigners[msg.sender][_signer] = false;
    }

    // sets the threshold for the number of authorized signers needed to recover the wallet
    function setThreshold(uint _threshold) public onlyOwner {
        threshold = _threshold;
    }

    // Function to recover the wallet using a signed message
    function recover(bytes32 memory _signedMessage, uint8 v, bytes32 r, bytes32 s) public {
        // Only an address that has not recovered yet can call this function
        require(!recovered[msg.sender]);

        // Recover the address that signed the message
        bytes32 messageHash = keccak256(_signedMessage);
        address signer = ecrecover(messageHash, v, r, s);
        // Check that the signer is an authorized signer
        require(authorizedSigners[signer]);

        // Add the address trying to recover to the authorizedRecover mapping
        authorizedRecover[msg.sender] = true;
        // check if the threshold of authorized recover address is reached
        if (countAuthorizedRecover() >= threshold) {
            // Change the owner to the address that called the function
            owner = msg.sender;
            // mark the address as recovered
            recovered[msg.sender] = true;
        }
    }

    // Counts the number of authorized recover addresses
    function countAuthorizedRecover() public view returns (uint) {
    uint count = 0;
    address[] memory keys = authorizedRecover.keys();
    for (uint i = 0; i < keys.length; i++) {
        address a = keys[i];
        if (authorizedRecover[a]) {
            count++;
        }
    }
    return count;
}

     function getBalance() public view onlyOwner returns (uint) {
        return balance[msg.sender];
    }

    // Function to send ether to another address
    function send(address payable _to, uint _value) public payable onlyOwner {
        // Check that the destination address is valid
        if(_to == address(0)) revert INVALID_ADDRESS();
        // Check that the contract has enough ether to send
        if(_value > balance[msg.sender]) revert INSUFFICIENT_BALANCE();
        if(_to.transfer(_value)){
            balance[msg.sender] -= _value;
            emit Sent(msg.sender, _to, _value);
        } else {
            revert FAILED_TRANSACTION();
        }
    }

    function deposit() public payable {
        if(msg.value <= 0) revert INVALID_AMOUNT();
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public onlyOwner {
        if(balance[msg.sender] < _amount) revert INSUFFICIENT_BALANCE();
        owners[msg.sender].transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}
