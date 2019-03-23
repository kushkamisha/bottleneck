pragma solidity 0.5.6;

contract DPOS {
    struct Votes {
        bool initialized;
        uint count;
        mapping(address => bool) users;
    }

    mapping (address => bool) public voting;
    mapping (address => Votes) public votes;

    modifier notVoting(address _address) {
        require(!voting[_address], "Already vote");
        _;
    }

    modifier isVoting(address _address) {
        require(voting[_address], "Already vote");
        _;
    }

    modifier notOracle(address _address) {
        require(!votes[_address].initialized, "Already oracle");
        _;
    }

    modifier isOracle(address _address) {
        require(votes[_address].initialized, "Already oracle");
        _;
    }

    function stayOracle() notOracle(msg.sender) external returns(bool) {
        votes[msg.sender] = Votes(true, 0);
        return true;
    }

    function vote(address aspt) notVoting(msg.sender) isOracle(aspt) external returns(bool) {
        voting[msg.sender] = true;
        votes[aspt].count++;
        votes[aspt].users[msg.sender] = true;
        return true;
    }

    function unvote(address aspt) isVoting(msg.sender) isOracle(aspt) external returns(bool) {
        require(votes[aspt].users[msg.sender], "Your are not voting fot this oracle");
        voting[msg.sender] = false;
        votes[aspt].count--;
        votes[aspt].users[msg.sender] = false;
        return true;
    }
}
