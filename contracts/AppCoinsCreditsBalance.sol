pragma solidity ^0.4.24;

import "./AppCoins.sol";
import "./Base/Whitelist.sol";

contract AppCoinsCreditsBalance is Whitelist {

    // AppCoins token
    AppCoins private appc;

    // balance proof
    bytes private balanceProof;

    // balance
    uint private balance;

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
    @notice Get the balance
    @dev
         returns the balance
    @return {"balance" : "balance"}
    */
    function getBalance() public view returns(uint256) {
        return balance;
    }

    /**
    @notice Get the balance proof
    @dev
        returns the balance proof
    @return {"balanceProof" : "balance proof"}
    */
    function getBalanceProof() public view returns(bytes) {
        return balanceProof;
    }

    /**
    @notice Register balance proof
    @param _merkleTreeHash (bytes) the merkle tree root hash
    @return {"balanceProof" : "balance proof"}
    */
    function registerBalanceProof(bytes _merkleTreeHash)
        internal{

        balanceProof = _merkleTreeHash;

        emit BalanceProof(_merkleTreeHash);
    }

    /**
    @notice Register balance proof
    @param _amount (unit) amount to be deposited
    @param _merkleTreeHash (bytes) the merkle tree root hash
    */
    function depositFunds(uint _amount, bytes _merkleTreeHash)
        public
        onlyIfWhitelisted("depositFunds", msg.sender){
        require(appc.allowance(msg.sender, address(this)) >= _amount);
        registerBalanceProof(_merkleTreeHash);
        appc.transferFrom(msg.sender, address(this), _amount);
        balance = balance + _amount;
        emit Deposit(_amount);
    }

    /**
    @notice Withdraw funds
    @param _amount (unit) amount to be withdraw
    @param _merkleTreeHash (bytes) the merkle tree root hash
    */
    function withdrawFunds(uint _amount, bytes _merkleTreeHash)
        public
        onlyIfWhitelisted("withdrawFunds",msg.sender){
        require(balance >= _amount);
        registerBalanceProof(_merkleTreeHash);
        appc.transfer(msg.sender, _amount);
        balance = balance - _amount;
        emit Withdraw(_amount);
    }

}
