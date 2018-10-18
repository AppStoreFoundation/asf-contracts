pragma solidity ^0.4.24;


import "./Base/BaseFinance.sol";
/**
@title Advertisement Finance contract
@author App Store Foundation
@dev The Advertisement Finance contract works as part of the user aquisition flow of the
Advertisemnt contract. This contract is responsible for storing all the amount of AppCoins destined
to user aquisition campaigns.
*/
contract ExtendedFinance is BaseFinance {

    mapping ( address => uint256 ) rewardedBalance;

    constructor(address _appc) public BaseFinance(_appc){

    }


    function pay(address _user, address _destination, uint256 _value)
        public onlyAllowed{

        require(balanceUsers[_user] >= _value);

        balanceUsers[_user] -= _value;
        rewardedBalance[_destination] += _value;
    }


    function withdraw(address _user, uint256 _value) public onlyOwnerOrAllowed {

        require(balanceUsers[_user] >= _value);

        appc.transfer(_user, _value);
        balanceUsers[_user] -= _value;

    }

    function withdrawRewards(address _user, uint256 _value) public onlyOwnerOrAllowed {
        require(rewardedBalance[_user] >= _value);

        appc.transfer(_user, _value);
        rewardedBalance[_user] -= _value;
    }

    function getRewardsBalance(address _user) public onlyOwnerOrAllowed returns (uint256) {
        return rewardedBalance[_user];
    }

}
