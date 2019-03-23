pragma solidity 0.5.6;

import "browser/BottleNeck.sol";

contract Actions is DPOS {
    struct Action {
        uint256 timestamp;
        
        uint submitActionCount;
        uint submitEventCount;
        
        uint coef;
        
        mapping(address => bool) agreements;
        mapping(address => bool) votes;
        
        address[] users;
    }

    Action[] actions;

    modifier submitedActions(uint actionId) {
        require(actions[actionId].submitActionCount >= oreclesCount / 2 + 1, "Not submitted action");
        _;
    }

    function createAction(uint _timestamp, uint _coef) isValidateOracle external returns(bool) {
        actions.push(Action(_timestamp, 0, 0, _coef, new address[](0)));
        return true;
    }

    function submitAction(uint actionId) isValidateOracle external returns(bool) {
        require(!actions[actionId].agreements[msg.sender], "Already submiting");
        
        actions[actionId].submitActionCount++;
        actions[actionId].agreements[msg.sender] = true;
        return true;
    }
}
