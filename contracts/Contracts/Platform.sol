pragma solidity 0.5.6;

import "browser/DPOS.sol";

interface PlatformInterface {
    function withdrawOracleReward(uint amount) external payable returns(bool);
}

contract Platform is PlatformInterface, DPOS {

    uint16 mRevardMultiplier = 100; // revardMultiplier in milli (10e3)
    mapping (address => uint) public oraclesBalance;

    event WithdrawOracleReward(address oracle, uint amount);

    function withdrawOracleReward(uint amount) external payable returns(bool) {
        if (oraclesBalance[msg.sender] > amount) {
            oraclesBalance[msg.sender] = oraclesBalance[msg.sender].sub(amount);

            emit WithdrawOracleReward(msg.sender, amount);
            msg.sender.transfer(amount);
        }

        return true;
    }
}
