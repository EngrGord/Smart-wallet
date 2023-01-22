import "github.com/filecoin-project/lotus/chain/address";

contract FilecoinSignatureHolder {
    // mapping to store the signatures of the signers, mapping key is the account to recover and the value is a mapping of signers addresses and their signatures
    mapping(address.Address => mapping(address.Address => (bytes32, uint8, bytes32, bytes32)[]) public signatures;
    // mapping to keep track of whether the threshold of signatures was reached
    mapping(address.Address => bool) public thresholdReached;
    // threshold of signatures required to recover the account
    uint threshold;
    // owner of the contract
    address.Address owner;

    // constructor: sets the msg.sender as the owner of the contract
    constructor() {
        owner = toAddress(msg.sender);
    }

    // function to add a signature to the contract
    function addSignature(address.Address accountToRecover, address.Address signer, bytes32 signedMessage, uint8 v, bytes32 r, bytes32 s) public {
        // store the signature in the mapping
        signatures[accountToRecover][signer].push((signedMessage, v, r, s));
        // check if the threshold is reached 
        checkThresholdReached(accountToRecover);
    }

    // function to check if the threshold of signatures was reached
    function checkThresholdReached(address.Address accountToRecover) public {
        if (signatures[accountToRecover].length >= threshold) {
            thresholdReached[accountToRecover] = true;
        }
    }

    // function to get all the stored signatures
    function getSignatures(address.Address accountToRecover) public view returns (bytes32[], uint8[], bytes32[], bytes32[]) {
    require(thresholdReached[accountToRecover]);
    bytes32[] memory signedMessages;
    uint8[] memory v;
    bytes32[] memory r;
    bytes32[] memory s;
    for (uint i = 0; i < signatures[accountToRecover].length; i++) {
        (signedMessages[i], v[i], r[i], s[i]) = signatures[accountToRecover][i];
    }
    scheduleDelete(accountToRecover);
    return (signedMessages, v, r, s);
}

function scheduleDelete(address.Address accountToRecover) internal {
    address payable self = address(this);
    require(msg.sender == self);
    bytes32 memory  scheduledDel = self.schedule(7200, self.delegatecall, abi.encodeWithSignature("deleteSignatures(address.Address)", accountToRecover));
}

function deleteSignatures(address.Address accountToRecover) internal {
    delete signatures[accountToRecover];
}

    // function to set the threshold of signatures required to recover the account
    function setThreshold(uint _threshold) public onlyOwner {
        threshold = _threshold;
    }

    // function to convert address payable to address.Address
    function toAddress(address payable a) public pure returns (address.Address) {
        return address.new(a);
    }

    // modifier to check if the msg.sender is the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
}

}