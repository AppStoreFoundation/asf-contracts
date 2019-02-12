pragma solidity ^0.4.24;


import "./Base/BaseFinance.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
/**
@title Advertisement Finance contract
@author App Store Foundation
@dev The Advertisement Finance contract works as part of the user aquisition flow of the
Advertisemnt contract. This contract is responsible for storing all the amount of AppCoins destined
to user aquisition campaigns.
*/
contract ExtendedFinance is BaseFinance {

    mapping ( address => uint256 ) public rewardedBalance;

    constructor(address _appc) public BaseFinance(_appc){

    }


    function pay(address _user, address _destination, uint256 _value)
        public onlyAllowed{

        require(balanceUsers[_user] >= _value);

        balanceUsers[_user] = SafeMath.sub(balanceUsers[_user], _value);
        rewardedBalance[_destination] = SafeMath.add(rewardedBalance[_destination],_value);
    }


    function withdraw(address _user, uint256 _value) public onlyOwnerOrAllowed {

        require(balanceUsers[_user] >= _value);

        balanceUsers[_user] = SafeMath.sub(balanceUsers[_user], _value);
        appc.transfer(_user, _value);

    }

    /**
    @notice Withdraws user's rewards
    @dev
        Function to transfer a certain user's rewards to his address 
    @param _user Address who's rewards will be withdrawn
    @param _value Value of the withdraws which will be transfered to the user 
    */
    function withdrawRewards(address _user, uint256 _value) public onlyOwnerOrAllowed {
        require(rewardedBalance[_user] >= _value);

        rewardedBalance[_user] = SafeMath.sub(rewardedBalance[_user],_value);
        appc.transfer(_user, _value);
    }
    /**
    @notice Get user's rewards balance
    @dev
        Function returning a user's rewards balance not yet withdrawn
    @param _user Address of the user
    @return { "_balance" : "Rewards balance of the user" }
    */
    function getRewardsBalance(address _user) public onlyOwnerOrAllowed returns (uint256 _balance) {
        return rewardedBalance[_user];
    }

}
