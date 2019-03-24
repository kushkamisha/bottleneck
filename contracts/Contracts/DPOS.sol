pragma solidity 0.5.6;

import "browser/SafeMath.sol";

interface DPOSInterface {
    function becomeCandidateToOracles() external returns(bool);
    function vote(address candidate) external returns(bool);
    function unvote(address candidate) external returns(bool);
}

contract DPOS is DPOSInterface {

    using SafeMath for uint;

    struct Votes {
        bool initialized;
        uint count;
        mapping(address => bool) users;
    }

    mapping (address => bool) public votedForCandidate;
    mapping (address => Votes) public votes;

    uint8 constant public oraclesCount = 3;
    address[] public oraclesList;

    constructor() public {
        oraclesList = new address[](oraclesCount);
    }

    modifier notVoted {
        require(!votedForCandidate[msg.sender], "You've already voted");
        _;
    }

    modifier haveVoted(address candidate) {
        require(votes[candidate].users[msg.sender], "You've not voted for this candidate");
        _;
    }

    modifier notCandidateToOracles {
        require(!votes[msg.sender].initialized, "This address is already candidate to oracles");
        _;
    }

    modifier isCandidateToOracles(address _address) {
        require(votes[_address].initialized, "This address is not candidate to oracles");
        _;
    }

    modifier isOracle {
        require(isValidOracle(msg.sender), "You're not oracle");
        _;
    }

    event BecomeCandidateToOracles(address candidate);
    event Vote(address voter, address candidate);
    event Unvote(address voter, address candidate);
    event UpdateOreaclesList(address newOracle, address oldOracle);

    function becomeCandidateToOracles() external notCandidateToOracles returns(bool) {
        votes[msg.sender] = Votes(true, 0);

        emit BecomeCandidateToOracles(msg.sender);
        return true;
    }

    function vote(address candidate) external notVoted isCandidateToOracles(candidate) returns(bool) {
        votedForCandidate[msg.sender] = true;
        votes[candidate].count = votes[candidate].count.add(1);
        votes[candidate].users[msg.sender] = true;

        if (!isValidOracle(msg.sender)) updateOreaclesList(candidate);

        emit Vote(msg.sender, candidate);
        return true;
    }

    function unvote(address candidate) external isCandidateToOracles(candidate) haveVoted(candidate) returns(bool) {
        votedForCandidate[msg.sender] = false;
        votes[candidate].count = votes[candidate].count.sub(1);
        votes[candidate].users[msg.sender] = false;

        updateOreaclesList(candidate);

        emit Unvote(msg.sender, candidate);
        return true;
    }

    function updateOreaclesList(address updatedAddress) private returns(bool) {
        uint worstId = getWorstOracle();
        if (votes[oraclesList[worstId]].count < votes[updatedAddress].count) {
            oraclesList[worstId] = updatedAddress;
            emit UpdateOreaclesList(updatedAddress, oraclesList[worstId]);
        }

        return true;
    }

    function getWorstOracle() private view returns(uint id) {
        uint worstId = 0;
        uint worstResult = votes[oraclesList[worstId]].count;

        for (uint i = 1; i < oraclesCount; i++) {
            uint oracleVotesCount = votes[oraclesList[i]].count;
            if (oracleVotesCount == 0) return i;
            
            if (oracleVotesCount < worstResult) {
                worstResult = oracleVotesCount;
                worstId = i;
            }
        }

        return worstId;
    }

    function isValidOracle(address oracle) private view returns(bool) {
        for (uint i = 0; i < oraclesCount; i++) {
            if (oraclesList[i] == oracle) return true;
        }
        return false;
    }
}
