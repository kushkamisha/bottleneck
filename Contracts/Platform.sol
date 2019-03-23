pragma solidity 0.5.6;

import "browser/DPOS.sol";

interface PlatformInterface {
    function withdrawOraclesReward(uint amount) external payable returns(bool);
}

contract Platform is PlatformInterface, DPOS {

    uint16 mRevardMultiplier = 100; // revardMultiplier in milli (10e3)
    mapping (address => uint) public oraclesBalance;

    event WithdrawOraclesReward(address oracle, uint amount);

    function withdrawOraclesReward(uint amount) external payable returns(bool) {
        if (oraclesBalance[msg.sender] > amount) {
            oraclesBalance[msg.sender] = oraclesBalance[msg.sender].sub(amount);
            msg.sender.transfer(amount);

            emit WithdrawOraclesReward(msg.sender, amount);
        }

        return true;
    }
}
