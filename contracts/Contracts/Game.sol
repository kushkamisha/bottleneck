pragma solidity 0.5.6;

import "browser/Platform.sol";

interface GameInterface {
    function createAction(uint _timestamp, uint16 _mCoeficient, uint8 _range, bytes32 _hashOfDescription) external returns(uint256);
    function submitAction(uint actionId) external returns(bool);
    function makeBet(uint8 bet, uint actionId) external payable returns(bool);
    function submitResult(uint8 result, uint actionId) external returns(bool);
}

contract Game is Platform, GameInterface {

    struct Bet {
        address payable wallet;
        uint8 bet;
        uint amount;
    }

    struct Action {
        uint timestamp;
        uint16 mCoeficient; // coeficient in milli (10e3)
        uint8 range;
        bytes32 hashOfDescription;

        uint8 votesForAction;

        mapping(address => bool) isVotedForAction;
        mapping(address => bool) isVotedForResult;

        mapping(uint => Bet) bets;
        uint playersCount;

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

    event CreateAction(uint actionId);
    event SubmitAction(address oracle, uint actionId);
    event MakeBet(uint8 bet, address player, uint actionId);
    event SubmitResult(uint8 result, address oracle, uint actionId);
    event GetOracleReward(address oracle, uint amount);
    event GetPlayerReward(address player, uint amount);

    function createAction(uint _timestamp, uint16 _mCoeficient, uint8 _range, bytes32 _hashOfDescription) external isOracle returns(uint256) {
        actions.push(Action(_timestamp, _mCoeficient, _range, _hashOfDescription, 0, 1, 0));

        emit CreateAction(actions.length - 1);
        return (actions.length - 1);
    }

    function submitAction(uint actionId) external isOracle notVotedForAction(actionId) returns(bool) {
        actions[actionId].votesForAction++;
        actions[actionId].isVotedForAction[msg.sender] = true;

        emit SubmitAction(msg.sender, actionId);
        return true;
    }

    function makeBet(uint8 bet, uint actionId) external payable submitedAction(actionId) isBetInRange() returns(bool) {
        actions[actionId].bets[actions[actionId].playersCount] = Bet(msg.sender, bet, msg.value);
        getOraclesReward(msg.value);

        emit MakeBet(bet, msg.sender, actionId);
        return true;
    }

    function submitResult(uint8 result, uint actionId) external submitedAction(actionId) notVotedForResult(actionId) isOracle returns(bool) {
        actions[actionId].isVotedForResult[msg.sender] = true;
        actions[actionId].results[result]++; 
        
        if (actions[actionId].results[result] >= oraclesCount / 2 + 1) {
            getPlayersReward(actionId, actions[actionId].results[result]);
            actions[actionId].result = actions[actionId].results[result];
        }

        emit SubmitResult(result, msg.sender, actionId);
        return true;
    }

    function getOraclesReward(uint totalReward) private returns(bool) {
        uint oracleRevard = totalReward.div(oraclesCount).mul(mRevardMultiplier).div(1000);
        for (uint8 i = 0; i < oraclesCount; i++) {
            oraclesBalance[oraclesList[i]] = oraclesBalance[oraclesList[i]].add(oracleRevard);
            emit GetOracleReward(oraclesList[i], oracleRevard);
        }

        return true;
    }

    function getPlayersReward(uint actionId, uint8 result) private returns(bool) {
        for (uint8 i = 0; i < actions[actionId].playersCount; i++) {
            if (actions[actionId].bets[i].bet == result) {
                uint winAmount = actions[actionId].bets[i].amount.mul(uint(actions[actionId].mCoeficient).div(1000));
                actions[actionId].bets[i].wallet.transfer(winAmount);
                emit GetPlayerReward(actions[actionId].bets[i].wallet, winAmount);
            }
        }
        
        return true;
    }
}
