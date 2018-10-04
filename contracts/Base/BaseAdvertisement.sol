pragma solidity ^0.4.24;

import "../AppCoins.sol";
import "./BaseFinance.sol";
import "./BaseAdvertisementStorage.sol";
import "./StorageUser.sol";
import "./Ownable.sol";

/**
@title Base Advertisement contract
@author App Store Foundation
@dev Abstract contract for user aquisition campaign contracts.
 */
contract BaseAdvertisement is StorageUser,Ownable {
    
    AppCoins appc;
    BaseFinance advertisementFinance;
    BaseAdvertisementStorage advertisementStorage;

    mapping( bytes32 => mapping(address => uint256)) userAttributions;

    bytes32[] bidIdList;
    bytes32 lastBidId = 0x0;


    /**
    @notice Constructor function
    @dev
        Initializes contract with default validation rules
    @param _addrAppc Address of the AppCoins (ERC-20) contract
    @param _addrAdverStorage Address of the Advertisement Storage contract to be used
    @param _addrAdverFinance Address of the Advertisement Finance contract to be used
    */
    constructor(address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public {
        appc = AppCoins(_addrAppc);

        advertisementStorage = BaseAdvertisementStorage(_addrAdverStorage);
        advertisementFinance = BaseFinance(_addrAdverFinance);
        lastBidId = advertisementStorage.getLastBidId();
    }


    /**
    @notice Upgrade finance contract used by this contract
    @dev
        This function is part of the upgrade mechanism avaliable to the advertisement contracts.
        Using this function it is possible to update to a new Advertisement Finance contract without
        the need to cancel avaliable campaigns.
        Upgrade finance function can only be called by the Advertisement contract owner.
    @param addrAdverFinance Address of the new Advertisement Finance contract
    */
    function upgradeFinance (address addrAdverFinance) public onlyOwner("upgradeFinance") {
        BaseFinance newAdvFinance = BaseFinance(addrAdverFinance);

        address[] memory devList = advertisementFinance.getUserList();

        for(uint i = 0; i < devList.length; i++){
            uint balance = advertisementFinance.getUserBalance(devList[i]);
            advertisementFinance.pay(devList[i],address(newAdvFinance),balance);
            newAdvFinance.increaseBalance(devList[i],balance);
        }


        uint256 oldBalance = appc.balances(address(advertisementFinance));

        require(oldBalance == 0);

        advertisementFinance = newAdvFinance;
    }

    /**
    @notice Upgrade storage contract used by this contract
    @dev
        Upgrades Advertisement Storage contract addres with no need to redeploy
        Advertisement contract. However every campaign in the old contract will
        be canceled.
        This function can only be called by the Advertisement contract owner.
    @param addrAdverStorage Address of the new Advertisement Storage contract
    */

    function upgradeStorage (address addrAdverStorage) public onlyOwner("upgradeStorage") {
        for(uint i = 0; i < bidIdList.length; i++) {
            cancelCampaign(bidIdList[i]);
        }
        delete bidIdList;

        lastBidId = advertisementStorage.getLastBidId();
        advertisementFinance.setAdsStorageAddress(addrAdverStorage);
        advertisementStorage = BaseAdvertisementStorage(addrAdverStorage);
    }


    /**
    @notice Get Advertisement Storage Address used by this contract
    @dev
        This function is required to upgrade Advertisement contract address on Advertisement
        Finance contract. This function can only be called by the Advertisement Finance
        contract registered in this contract.
    @return {
        "storageContract" : "Address of the Advertisement Storage contract used by this contract"
        }
    */

    function getStorageAddress() public view returns(address storageContract) {
        require (msg.sender == address(advertisementFinance));

        return address(advertisementStorage);
    }


    /**
    @notice Creates a campaign 
    @dev 
        Method to create a campaign of user aquisition for a certain application.
        This method will emit a Campaign Information event with every information 
        provided in the arguments of this method.
    @param packageName Package name of the appication subject to the user aquisition campaign
    @param countries Encoded list of 3 integers intended to include every 
    county where this campaign will be avaliable.
    For more detain on this encoding refer to wiki documentation.
    @param vercodes List of version codes to which the user aquisition campaign is applied.
    @param price Value (in wei) the campaign owner pays for each proof-of-attention.
    @param budget Total budget (in wei) the campaign owner will deposit 
    to pay for the proof-of-attention.
    @param startDate Date (in miliseconds) on which the campaign will start to be 
    avaliable to users.
    @param endDate Date (in miliseconds) on which the campaign will no longer be avaliable to users.
    */

    function _generateCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        internal returns (CampaignLibrary.Campaign memory) {

        require(budget >= price);
        require(endDate >= startDate);



        //Transfers the budget to contract address
        if(appc.allowance(msg.sender, address(this)) < budget){
            emit Error("createCampaign","Not enough allowance");
            return;
        }

        appc.transferFrom(msg.sender, address(advertisementFinance), budget);

        advertisementFinance.increaseBalance(msg.sender,budget);

        uint newBidId = bytesToUint(lastBidId);
        lastBidId = uintToBytes(++newBidId);
        

        CampaignLibrary.Campaign memory newCampaign;
        newCampaign.price = price;
        newCampaign.startDate = startDate;
        newCampaign.endDate = endDate;
        newCampaign.budget = budget;
        newCampaign.owner = msg.sender;
        newCampaign.valid = true;
        newCampaign.bidId = lastBidId;

        return newCampaign;
    }

    function _getStorage() internal returns (BaseAdvertisementStorage) {
        return advertisementStorage;
    }

    function _getFinance() internal returns (BaseFinance) {
        return advertisementFinance;
    }

    function _setUserAttribution(bytes32 _bidId,address _user,uint256 _attributions) internal{
        userAttributions[_bidId][_user] = _attributions;
    }


    function getUserAttribution(bytes32 _bidId,address _user) internal returns (uint256) {
        return userAttributions[_bidId][_user];
    }

    /**
    @notice Cancel a campaign and give the remaining budget to the campaign owner
    @dev
        When a campaing owner wants to cancel a campaign, the campaign owner needs
        to call this function. This function can only be called either by the campaign owner or by
        the Advertisement contract owner. This function results in campaign cancelation and
        retreival of the remaining budget to the respective campaign owner.
    @param bidId Campaign id to which the cancelation referes to
     */
    function cancelCampaign (bytes32 bidId) public {
        address campaignOwner = getOwnerOfCampaign(bidId);

		// Only contract owner or campaign owner can cancel a campaign
        require(owner == msg.sender || campaignOwner == msg.sender);
        uint budget = getBudgetOfCampaign(bidId);

        advertisementFinance.withdraw(campaignOwner, budget);

        advertisementStorage.setCampaignBudgetById(bidId, 0);
        advertisementStorage.setCampaignValidById(bidId, false);
    }

     /**
    @notice Get a campaign validity state
    @param bidId Campaign id to which the query refers
    @return { "state" : "Validity of the campaign"}
    */
    function getCampaignValidity(bytes32 bidId) public view returns(bool state){
        return advertisementStorage.getCampaignValidById(bidId);
    }

    /**
    @notice Get the price of a campaign
    @dev
        Based on the Campaign id return the value paid for each proof of attention registered.
    @param bidId Campaign id to which the query refers
    @return { "price" : "Reward (in wei) for each proof of attention registered"}
    */
    function getPriceOfCampaign (bytes32 bidId) public view returns(uint price) {
        return advertisementStorage.getCampaignPriceById(bidId);
    }

    /**
    @notice Get the start date of a campaign
    @dev
        Based on the Campaign id return the value (in miliseconds) corresponding to the start Date
        of the campaign.
    @param bidId Campaign id to which the query refers
    @return { "startDate" : "Start date (in miliseconds) of the campaign"}
    */
    function getStartDateOfCampaign (bytes32 bidId) public view returns(uint startDate) {
        return advertisementStorage.getCampaignStartDateById(bidId);
    }

    /**
    @notice Get the end date of a campaign
    @dev
        Based on the Campaign id return the value (in miliseconds) corresponding to the end Date
        of the campaign.
    @param bidId Campaign id to which the query refers
    @return { "endDate" : "End date (in miliseconds) of the campaign"}
    */
    function getEndDateOfCampaign (bytes32 bidId) public view returns(uint endDate) {
        return advertisementStorage.getCampaignEndDateById(bidId);
    }

    /**
    @notice Get the budget avaliable of a campaign
    @dev
        Based on the Campaign id return the total value avaliable to pay for proofs of attention.
    @param bidId Campaign id to which the query refers
    @return { "budget" : "Total value (in wei) spendable in proof of attention rewards"}
    */
    function getBudgetOfCampaign (bytes32 bidId) public view returns(uint budget) {
        return advertisementStorage.getCampaignBudgetById(bidId);
    }


    /**
    @notice Get the owner of a campaign
    @dev
        Based on the Campaign id return the address of the campaign owner
    @param bidId Campaign id to which the query refers
    @return { "campaignOwner" : "Address of the campaign owner" }
    */
    function getOwnerOfCampaign (bytes32 bidId) public view returns(address campaignOwner) {
        return advertisementStorage.getCampaignOwnerById(bidId);
    }

    /**
    @notice Get the list of Campaign BidIds registered in the contract
    @dev
        Returns the list of BidIds of the campaigns ever registered in the contract
    @return { "bidIds" : "List of BidIds registered in the contract" }
    */
    function getBidIdList() public view returns(bytes32[] bidIds) {
        return bidIdList;
    }

    function _getBidIdList() internal returns(bytes32[] storage bidIds){
        return bidIdList;
    }

    /**
    @notice Check if a certain campaign is still valid
    @dev
        Returns a boolean representing the validity of the campaign
        Has value of True if the campaign is still valid else has value of False
    @param bidId Campaign id to which the query refers
    @return { "valid" : "validity of the campaign" }
    */
    function isCampaignValid(bytes32 bidId) public view returns(bool valid) {
        uint startDate = advertisementStorage.getCampaignStartDateById(bidId);
        uint endDate = advertisementStorage.getCampaignEndDateById(bidId);
        bool validity = advertisementStorage.getCampaignValidById(bidId);

        uint nowInMilliseconds = now * 1000;
        return validity && startDate < nowInMilliseconds && endDate > nowInMilliseconds;
    }

     /**
    @notice Returns the division of two numbers
    @dev
        Function used for division operations inside the smartcontract
    @param numerator Numerator part of the division
    @param denominator Denominator part of the division
    @return { "result" : "Result of the division"}
    */
    function division(uint numerator, uint denominator) public view returns (uint result) {
        uint _quotient = numerator / denominator;
        return _quotient;
    }

    /**
    @notice Converts a uint256 type variable to a byte32 type variable
    @dev
        Mostly used internaly
    @param i number to be converted
    @return { "b" : "Input number converted to bytes"}
    */
    function uintToBytes (uint256 i) public view returns(bytes32 b) {
        b = bytes32(i);
    }

    function bytesToUint(bytes32 b) public view returns (uint) 
    {
        return uint(b) & 0xfff;
    }

}