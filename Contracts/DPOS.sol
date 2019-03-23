pragma solidity 0.5.6;

contract DPOS {
    struct Votes {
        bool initialized;
        uint count;
        address[] users;
    }

    mapping (address => bool) public voting;
    mapping (address => Votes) public votes;

    modifier notVoting(address _address) {
        require(!voting[_address], "Already vote");
        _;
    }

    modifier notOracle(address _address) {
        require(!votes[_address].initialized, "Already oracle");
        _;
    }

    function stayOracle() notOracle(msg.sender) external returns(bool) {
        votes[msg.sender] = Votes(true, 0, new address[](0));
        return true;
    }
}
