pragma solidity 0.5.6;

import "browser/Platform.sol";

contract Game is Platform {
    struct Bet {
        address payable wallet;
        uint8 bet;
        uint amount;
    }

    struct Action {
        uint timestamp;
        uint16 mCoeficient; // coeficient in milli (10e3)
        uint8 range;
        
        uint8 votesForAction;
        
        mapping(address => bool) isVotedForAction;
        mapping(address => bool) isVotedForResult;
        
        Bet[] bets;
        mapping(uint8 => uint8) results;
        uint8 result;
    }

    Action[] public actions;
    
    uint256 constant public minBet = 0.01 ether;
    uint256 constant public maxBet = 1 ether;

    modifier notVotedForAction(uint actionId) {
        require(!actions[actionId].isVotedForAction[msg.sender], "Already voting for action");
        _;
    }

    modifier notVotedForResult(uint actionId) {
        require(!actions[actionId].isVotedForResult[msg.sender], "Already voting for result");
        _;
    }

    modifier submitedAction(uint actionId) {
        require(actions[actionId].votesForAction >= oraclesCount / 2 + 1, "Not submitted action");
        _;
    }

    modifier isBetInRange {
        require(minBet <= msg.value && msg.value <= maxBet, "Bet isn't in range");
        _;
    }

    function createAction(uint _timestamp, uint16 _mCoeficient, uint8 _range) external isOracle returns(uint256) {
        actions.push(Action(_timestamp, _mCoeficient, _range, 0, new Bet[](0), 0));
        return (actions.length - 1);
    }

    function submitAction(uint actionId) external isOracle notVotedForAction(actionId) returns(bool) {
        actions[actionId].votesForAction++;
        actions[actionId].isVotedForAction[msg.sender] = true;
        
        return true;
    }

    function makeBet(uint8 bet, uint actionId) external payable submitedAction(actionId) isBetInRange() returns(bool) {
        actions[actionId].bets.push(Bet(msg.sender, bet, msg.value));
        getOraclesReward(msg.value);
        
        return true;
    }

    function submitEvent(uint8 result, uint actionId) external submitedAction(actionId) notVotedForResult(actionId) isOracle returns(bool) {
        actions[actionId].isVotedForResult[msg.sender] = true;
        actions[actionId].results[result]++; 
        
        if (actions[actionId].results[result] >= oraclesCount / 2 + 1) {
            payForUsers(actionId, actions[actionId].results[result]);
            actions[actionId].result = actions[actionId].results[result];
        }
        
        return true;
    }

    function getOraclesReward(uint totalReward) private returns(bool) {
        uint oracleRevard = (totalReward / oraclesCount) * mRevardMultiplier / 1000;
        for (uint8 i = 0; i < oraclesCount; i++) {
            oraclesBalance[oracles[i]] += oracleRevard;
            emit GetOraclesReward(oracles[i], oracleRevard);
        }

        return true;
    }

    function payForUsers(uint actionId, uint8 result) private returns(bool) {
        for (uint8 i = 0; i < actions[actionId].bets.length; i++) {
            if (actions[actionId].bets[i].bet == result) {
                actions[actionId].bets[i].wallet.transfer(actions[actionId].bets[i].amount * actions[actionId].mCoeficient / 1000);
            }
        }

        return true;
    }
}
