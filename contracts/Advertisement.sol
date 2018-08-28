pragma solidity ^0.4.21;


import  { CampaignLibrary } from "./lib/CampaignLibrary.sol";
import "./AdvertisementStorage.sol";
import "./AdvertisementFinance.sol";
import "./AppCoins.sol";

/**
@title Advertisement contract
@author App Store Foundation
@dev The Advertisement contract collects campaigns registered by developers and executes payments 
to users using campaign registered applications after proof of Attention.
 */
contract Advertisement {

    struct ValidationRules {
        bool vercode;
        bool ipValidation;
        bool country;
        uint constipDailyConversions;
        uint walletDailyConversions;
    }

    uint constant expectedPoALength = 12;

    ValidationRules public rules;
    bytes32[] bidIdList;
    AppCoins appc;
    AdvertisementStorage advertisementStorage;
    AdvertisementFinance advertisementFinance;
    address public owner;
    mapping (address => mapping (bytes32 => bool)) userAttributions;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    event PoARegistered(bytes32 bidId, string packageName,uint64[] timestampList,uint64[] nonceList,string walletName, bytes2 countryCode);
    event Error(string func, string message);
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes
    );

    /**
    @notice Constructor function
    @dev
        Initializes contract with default validation rules
    @param _addrAppc Address of the AppCoins (ERC-20) contract
    @param _addrAdverStorage Address of the Advertisement Storage contract to be used
    @param _addrAdverFinance Address of the Advertisement Finance contract to be used
    */
    function Advertisement (address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public {
        rules = ValidationRules(false, true, true, 2, 1);
        owner = msg.sender;
        appc = AppCoins(_addrAppc);
        advertisementStorage = AdvertisementStorage(_addrAdverStorage);
        advertisementFinance = AdvertisementFinance(_addrAdverFinance);
    }

    struct Map {
        mapping (address => uint256) balance;
        address[] devs;
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
    function upgradeFinance (address addrAdverFinance) public onlyOwner {
        AdvertisementFinance newAdvFinance = AdvertisementFinance(addrAdverFinance);
        Map storage devBalance;    

        for(uint i = 0; i < bidIdList.length; i++) {
            address dev = advertisementStorage.getCampaignOwnerById(bidIdList[i]);
            
            if(devBalance.balance[dev] == 0){
                devBalance.devs.push(dev);
            }
            
            devBalance.balance[dev] += advertisementStorage.getCampaignBudgetById(bidIdList[i]);
        }        

        for(i = 0; i < devBalance.devs.length; i++) {
            advertisementFinance.pay(devBalance.devs[i],address(newAdvFinance),devBalance.balance[devBalance.devs[i]]);
            newAdvFinance.increaseBalance(devBalance.devs[i],devBalance.balance[devBalance.devs[i]]);
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

    function upgradeStorage (address addrAdverStorage) public onlyOwner {
        for(uint i = 0; i < bidIdList.length; i++) {
            cancelCampaign(bidIdList[i]);
        }
        delete bidIdList;
        advertisementFinance.reset();
        advertisementFinance.setAdsStorageAddress(addrAdverStorage);
        advertisementStorage = AdvertisementStorage(addrAdverStorage);
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

    function getAdvertisementStorageAddress() public view returns(address storageContract) {
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

    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        external {

        require(budget >= price);
        require(endDate >= startDate);

        CampaignLibrary.Campaign memory newCampaign;

        newCampaign.price = price;
        newCampaign.startDate = startDate;
        newCampaign.endDate = endDate;

        //Transfers the budget to contract address
        if(appc.allowance(msg.sender, address(this)) < budget){
            emit Error("createCampaign","Not enough allowance");
            return;
        }

        appc.transferFrom(msg.sender, address(advertisementFinance), budget);

        advertisementFinance.increaseBalance(msg.sender,budget);

        newCampaign.budget = budget;
        newCampaign.owner = msg.sender;
        newCampaign.valid = true;
        newCampaign.bidId = uintToBytes(bidIdList.length);
        addCampaign(newCampaign);

        emit CampaignInformation(
            newCampaign.bidId,
            newCampaign.owner,
            "", // ipValidator field
            packageName,
            countries,
            vercodes);
    }

    /** 
    @notice Add Campaign to Advertisement Storage contract
    @dev
        Internal function executed when a campaign is created that adds the campaign 
        information to Advertisement Storage contract.
    @param campaign Structure containing every information necessary to create and 
    maintain a campaign avaliable.
    */

    function addCampaign(CampaignLibrary.Campaign campaign) internal {

		//Add to bidIdList
        bidIdList.push(campaign.bidId);

		//Add to campaign map
        advertisementStorage.setCampaign(
            campaign.bidId,
            campaign.price,
            campaign.budget,
            campaign.startDate,
            campaign.endDate,
            campaign.valid,
            campaign.owner
        );

    }

    /**
    @notice Register a proof of attention
    @dev
        This function verifies the campaign avaliability as well as the validity of 
        the proof of attention submited. In case any of the verifications fails, the function will 
        be stopped and an Error event will be emitted with further error information.
        A PoARegistered event with the same information submited as arguments of this function will 
        be emmited if the proof of attention is processed correctly.
        For more information on the proof of attention design refer to the wiki documentation or to 
        Appcoins Protocol Whitepaper.

    @param packageName Package name of the application from which the proof of attention refers to.
    @param bidId Campaign id of the campaign to which the proof of attention is submitted
    @param timestampList List of 12 timestamps generated 10 seconds apart from each other, 
    as part of the proof of attention. The timestamp list should be arranged in ascending order
    @param nonces List of 12 nonces generated during the proof of attention. The index of each 
    nounce should be acording to the corresponding timestamp index on the timestamp list submitted
    @param appstore Address of the Appstore receiving part of the proof of attention reward
    @param oem Address of the OEM receiving part of the proof of attention reward
    @param walletName Package name of the wallet submitting the proof of attention
    @param countryCode String with the 2 character identifying the country from which the 
    proof of attention was processed
    */

    function registerPoA (
        string packageName, bytes32 bidId,
        uint64[] timestampList, uint64[] nonces,
        address appstore, address oem,
        string walletName, bytes2 countryCode) external {

        if(!isCampaignValid(bidId)){
            emit Error(
                "registerPoA","Registering a Proof of attention to a invalid campaign");
            return;
        }

        if(timestampList.length != expectedPoALength){
            emit Error("registerPoA","Proof-of-attention should have exactly 12 proofs");
            return;
        }

        if(timestampList.length != nonces.length){
            emit Error(
                "registerPoA","Nounce list and timestamp list must have same length");
            return;
        }
        //Expect ordered array arranged in ascending order
        for (uint i = 0; i < timestampList.length - 1; i++) {
            uint timestampDiff = (timestampList[i+1]-timestampList[i]);
            if((timestampDiff / 1000) != 10){
                emit Error(
                    "registerPoA","Timestamps should be spaced exactly 10 secounds");
                return;
            }
        }

        /* if(!areNoncesValid(bytes(packageName), timestampList, nonces)){
            emit Error(
                "registerPoA","Incorrect nounces for submited proof of attention");
            return;
        } */

        if(userAttributions[msg.sender][bidId]){
            emit Error(
                "registerPoA","User already registered a proof of attention for this campaign");
            return;
        }
        //atribute
        userAttributions[msg.sender][bidId] = true;

        payFromCampaign(bidId, appstore, oem);

        emit PoARegistered(bidId, packageName, timestampList, nonces, walletName, countryCode);
    }

    /**
    @notice Cancel a campaign and give the remaining budget to the campaign owner
    @dev
        When a campaing owner wants to cancel a campaign, the campaign owner needs 
        to call this function. This function can only be called either by the campaign owner or by 
        the Advertisement contract owner. This function results in campaign cancelation and 
        retreival of the remaining budged to the respective campaign owner.
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
    @notice Internal function to distribute payouts
    @dev
        Distributes the value defined in the campaign for a Proof-of-attention to the user, 
        Appstore and OEM ajusted to their respective shares.
    @param bidId Campaign id from which a payment will be made
    @param appstore Address of the Appstore receiving it's share
    @param oem Address of the OEM receiving it's share
    */
    function payFromCampaign (bytes32 bidId, address appstore, address oem) internal {
        uint devShare = 85;
        uint appstoreShare = 10;
        uint oemShare = 5;

        //Search bid price
        uint price = advertisementStorage.getCampaignPriceById(bidId);
        uint budget = advertisementStorage.getCampaignBudgetById(bidId);
        address campaignOwner = advertisementStorage.getCampaignOwnerById(bidId);

        require(budget > 0);
        require(budget >= price);

        //transfer to user, appstore and oem
        advertisementFinance.pay(campaignOwner,msg.sender,division(price * devShare, 100));
        advertisementFinance.pay(campaignOwner,appstore,division(price * appstoreShare, 100));
        advertisementFinance.pay(campaignOwner,oem,division(price * oemShare, 100));

        //subtract from campaign
        uint newBudget = budget - price;

        advertisementStorage.setCampaignBudgetById(bidId, newBudget);


        if (newBudget < price) {
            advertisementStorage.setCampaignValidById(bidId, false);
        }
    }

    /**
    @notice Checks if a given list of nonces is valid for a certain proof-of-attention
    @dev
        Internal function that checks if the submitted nonces are valid
        It's part of the proof-of-attention validation process on the blockchain
    @param packageName Package name to which the proof-of-attention refers to
    @param timestampList List of timestamps used to compute the proof-of-attention
    @param nonces List of nonces generated based on the packageName and timestamp list
    @return { "valid" : "Returns True if all nonces are valid else it returns False"}
    
    */
    function areNoncesValid (bytes packageName,uint64[] timestampList, uint64[] nonces) 
        internal returns(bool valid) {

        for(uint i = 0; i < nonces.length; i++){
            bytes8 timestamp = bytes8(timestampList[i]);
            bytes8 nonce = bytes8(nonces[i]);
            bytes memory byteList = new bytes(packageName.length + timestamp.length);

            for(uint j = 0; j < packageName.length;j++){
                byteList[j] = packageName[j];
            }

            for(j = 0; j < timestamp.length; j++ ){
                byteList[j + packageName.length] = timestamp[j];
            }

            bytes32 result = sha256(byteList);

            bytes memory noncePlusHash = new bytes(result.length + nonce.length);

            for(j = 0; j < nonce.length; j++){
                noncePlusHash[j] = nonce[j];
            }

            for(j = 0; j < result.length; j++){
                noncePlusHash[j + nonce.length] = result[j];
            }

            result = sha256(noncePlusHash);

            bytes2[1] memory leadingBytes = [bytes2(0)];
            bytes2 comp = 0x0000;

            assembly{
            	mstore(leadingBytes,result)
            }

            if(comp != leadingBytes[0]){
                return false;
            }

        }
        return true;
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

}
