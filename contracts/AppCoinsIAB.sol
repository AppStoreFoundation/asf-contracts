pragma solidity ^0.4.19;

import "./Base/Whitelist.sol";
import { Shares } from "./lib/Shares.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract AppCoins {
    mapping (address => mapping (address => uint256)) public allowance;
    function balanceOf (address _owner) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (uint);
}
/**
@title AppCoinsIAB Interface
@author App Store Foundation
@dev Base interface to implement In-app-billing functions.
*/
contract AppCoinsIABInterface {

    /**
    @notice Function to register a in-app-billing operation
    @dev
        Registers a in-app-billing operation with the needed information and transfers the correct 
        amount from the user to the developer and remaining parties.
    @param _packageName Package name of the application from which the in-app-billing was generated
    @param _sku Item id for the item bought inside the specified application
    @param _amount Value (in wei) of AppCoins to be paid for the item
    @param _addr_appc Address of the AppCoins (ERC-20) contract to be used
    @param _dev Address of the application's developer
    @param _appstore Address of the appstore to receive part of the share
    @param _oem Address of the OEM to receive part of the share
    @param _countryCode Country code of the country from which the transaction was issued
    @return {"result" : "True if the transaction was successfull"}
    */
    function buy(
        string _packageName, string _sku, uint256 _amount, address _addr_appc, address _dev, 
        address _appstore, address _oem, bytes2 _countryCode) 
        public view 
        returns (bool result);
}


contract AppCoinsIAB is AppCoinsIABInterface, Whitelist {

    event Buy(string packageName, string _sku, uint _amount, address _from, address _dev, address _appstore, address _oem, bytes2 countryCode);
    event OffChainBuy(address _wallet, bytes32 _rootHash);
    
    /**
    @notice Constructor function
    @dev
        Initializes contract and registers the contract owner.
    */
    function AppCoinsIAB() public {
        addAddressToWhitelist(msg.sender);
    }

    /**
    @notice Emmits an event informing offchain transactions for in-app-billing
    @dev
        For each wallet passed as argument, the specified roothash is emited in a OffChainBuy event.
        This function is only avaliable to a set of allowed adresses. This function will emit an 
        Error event when the list of wallets passed as argument does not have the same length 
        as the list of roothashs given.

    @param _walletList List of wallets for which a OffChainBuy event will be issued
    @param _rootHashList List of roothashs for given transactions
    */
    function informOffChainBuy(address[] _walletList, bytes32[] _rootHashList) 
        public 
        onlyIfWhitelisted("informOffChainBuy",msg.sender) 
    {
        if(_walletList.length != _rootHashList.length){
            emit Error("informOffChainTransaction", "Wallet list and Roothash list must have the same lengths");
            return;
        }
        for(uint i = 0; i < _walletList.length; i++){
            emit OffChainBuy(_walletList[i],_rootHashList[i]);
        }
    }

    function buy(string _packageName, string _sku, uint256 _amount, address _addr_appc, address _dev, address _appstore, address _oem, bytes2 _countryCode) public view returns (bool) {
        require(_addr_appc != 0x0);
        require(_dev != 0x0);
        require(_appstore != 0x0);
        require(_oem != 0x0);

        AppCoins appc = AppCoins(_addr_appc);
        uint256 aux = appc.allowance(msg.sender, address(this));
        if(aux < _amount){
            emit Error("buy","Not enough allowance");
            return false;
        }

        uint[] memory amounts = new uint[](3);
        amounts[0] = SafeMath.div(_amount * Shares.getDevShare(), 100);
        amounts[1] = SafeMath.div(_amount * Shares.getAppStoreShare(), 100);
        amounts[2] = SafeMath.div(_amount * Shares.getOEMShare(), 100);

        uint remaining = _amount - (amounts[0] + amounts[1] + amounts[2]);

        appc.transferFrom(msg.sender, _dev, amounts[0] + remaining);
        appc.transferFrom(msg.sender, _appstore, amounts[1]);
        appc.transferFrom(msg.sender, _oem, amounts[2]);

        emit Buy(_packageName, _sku, _amount, msg.sender, _dev, _appstore, _oem, _countryCode);

        return true;
    }
}
