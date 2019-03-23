pragma solidity 0.5.6;

import "browser/DPOS.sol";

interface PlatformInterface {
    function withdrawOraclesReward(uint amount) external payable returns(bool);
}

contract Platform is PlatformInterface, DPOS {

    uint16 mRevardMultiplier = 100; // revardMultiplier in milli (10e3)
    mapping (address => uint) public oraclesBalance;
    
    event GetOraclesReward(address oracle, uint amount);
    event WithdrawOraclesReward(address oracle, uint amount);

    function getOraclesReward(uint totalReward) private returns(bool) {
        uint oracleRevard = (totalReward / oraclesCount) * mRevardMultiplier / 1000;
        for (uint8 i = 0; i < oraclesCount; i++) {
            oraclesBalance[oracles[i]] += oracleRevard;
            emit GetOraclesReward(oracles[i], oracleRevard);
        }

        return true;
    }

    function withdrawOraclesReward(uint amount) external payable returns(bool) {
        if (oraclesBalance[msg.sender] > amount) {
            oraclesBalance[msg.sender] -= amount;
            msg.sender.transfer(amount);
            
            emit WithdrawOraclesReward(msg.sender, amount);
        }
        
        return true;
    }
}
