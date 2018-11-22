pragma solidity ^0.4.24;

import "./AppCoins.sol";
import "./Base/Whitelist.sol";

contract AppCoinsCreditsBalance is Whitelist {

    // AppCoins token
    AppCoins private appc;

    // balance proof
    bytes balanceProof;

    // balance
    uint balance;

    event BalanceProof(bytes _merkleTreeHash);
    event Deposit(uint _amount);
    event Withdraw(uint _amount);

    constructor(
        address _addrAppc
    )
    public
    {
        appc = AppCoins(_addrAppc);
    }

    /**
    *@notice Get the balance
    *@dev
    *    returns the balance
    *@return {"balance" : "balance"}
    */
    function getBalance() public view returns(uint256) {
        return balance;
    }

    /**
    *@notice Get the balance proof
    *@dev
    *    returns the balance proof
    *@return {"balanceProof" : "balance proof"}
    */
    function getBbalanceProof() public view returns(bytes) {
        return balanceProof;
    }



    function registerBalanceProof(bytes _merkleTreeHash)
        public
        onlyIfWhitelisted("registerBalanceProof",msg.sender){

        balanceProof = _merkleTreeHash;

        emit BalanceProof(_merkleTreeHash);
    }

    function depositFunds(uint _amount)
        public
        onlyIfWhitelisted("depositFunds", msg.sender){
        require(appc.allowance(msg.sender, address(this)) >= _amount);
        appc.transferFrom(msg.sender, address(this), _amount);
        balance = balance + _amount;
        emit Deposit(_amount);
    }

    function withdrawFunds(uint _amount)
        public
        onlyIfWhitelisted("withdrawFunds",msg.sender){
        require(balance >= _amount);
        appc.transfer(msg.sender, _amount);
        balance = balance - _amount;
        emit Withdraw(_amount);
    }

}
