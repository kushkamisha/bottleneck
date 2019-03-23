pragma solidity 0.5.6;

contract DPOS {
    struct Votes {
        bool initialized;
        uint count;
        mapping(address => bool) users;
    }

    mapping (address => bool) public voting;
    mapping (address => Votes) public votes;

    uint public oreclesCount;
    address[] public oracles;

    constructor(uint _oreclesCount) public {
        oreclesCount = _oreclesCount;
        oracles = new address[](oreclesCount);
    }

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

    modifier isValidateOracle {
        require(checkOracle(msg.sender), "Already oracle");
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

        updateOreaclesList(aspt);
        return true;
    }

    function unvote(address aspt) isVoting(msg.sender) isOracle(aspt) external returns(bool) {
        require(votes[aspt].users[msg.sender], "Your are not voting fot this oracle");
        voting[msg.sender] = false;
        votes[aspt].count--;
        votes[aspt].users[msg.sender] = false;

        updateOreaclesList(aspt);
        return true;
    }

    function updateOreaclesList(address updatedAddress) private returns(bool) {
        uint worstId = getWorstOracle();
        if (votes[oracles[worstId]].count < votes[updatedAddress].count) {
            oracles[worstId] = updatedAddress;
        }
        
        return true;
    }

    function getWorstOracle() private view returns (uint id) {
        uint worstResult = 999999999;
        uint worstId = 0;
        for (uint i = 0; i < oreclesCount; i++) {
            uint oracleVotesCount = votes[oracles[i]].count;
            if (oracleVotesCount == 0) return i;
            
            if (oracleVotesCount < worstResult) {
                worstResult = oracleVotesCount;
                worstId = i;
            }
        }

        return worstId;
    }

    function checkOracle(address oracle) private view returns(bool) {
        for (uint i = 0; i < oreclesCount; i++) {
            if (oracles[i] == oracle) return true;
        }
        return false;
    }
}
