pragma solidity ^0.4.24;

import "./Base/StorageUser.sol";
import "./Base/Whitelist.sol";
import "./Base/BaseAdvertisement.sol";
import "./ExtendedAdvertisementStorage.sol";
import "./ExtendedFinance.sol";


contract ExtendedAdvertisement is BaseAdvertisement, Whitelist {

    event PoARegistered(bytes32 bidId,bytes32 rootHash,bytes32 signedrootHash,uint256 newPoAs,uint256 convertedPoAs);
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes,
            string endpoint
    );

    constructor(address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public 
        BaseAdvertisement(_addrAppc,_addrAdverStorage,_addrAdverFinance) {
    }


    /**
    @notice Creates an extebded campaign
    @dev
        Method to create an extended campaign of user aquisition for a certain application.
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
    @param endPoint URL of the signing serivce
    */
    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate,
        string endPoint)
        external 
        {
        
        CampaignLibrary.Campaign memory newCampaign = _generateCampaign(packageName, countries, vercodes, price, budget, startDate, endDate);
        
        _getBidIdList().push(newCampaign.bidId);

        ExtendedAdvertisementStorage(address(_getStorage())).setCampaign(
            newCampaign.bidId,
            newCampaign.price,
            newCampaign.budget,
            newCampaign.startDate,
            newCampaign.endDate,
            newCampaign.valid,
            newCampaign.owner,
            endPoint);

        emit CampaignInformation(
            newCampaign.bidId,
            newCampaign.owner,
            "", // ipValidator field
            packageName,
            countries,
            vercodes,
            endPoint);
    }   

    /**
    @notice Function to submit in bulk PoAs
    @dev
        This function can only be called by whitelisted addresses and provides a cost efficient 
        method to submit a batch of validates PoAs at once. This function emits a PoaRegistered 
        event containing the campaign id, root hash, signed root hash, number of new hashes since 
        the last submission and the effective number of conversions.

    @param bidId Campaign id for which the Proof of attention root hash refferes to
    @param rootHash Root hash of all submitted proof of attention to a given campaign
    @param signedRootHash Root hash signed by the signing service of the campaign
    @param newHashes Number of new proof of attention hashes since last submission
    */
    function bulkRegisterPoA(bytes32 bidId,bytes32 rootHash,bytes32 signedRootHash, uint256 newHashes) 
        public 
        onlyIfWhitelisted("createCampaign",msg.sender)
        {
        uint price = _getStorage().getCampaignPriceById(bidId);
        uint budget = _getStorage().getCampaignBudgetById(bidId);
        address owner = _getStorage().getCampaignOwnerById(bidId);
        uint maxConversions = division(budget,price);
        uint effectiveConversions;
        uint totalPay;
        uint newBudget;

        if (maxConversions >= newHashes){
            effectiveConversions = newHashes;
        } else {
            effectiveConversions = maxConversions;
        }

        totalPay = price*effectiveConversions;
        newBudget = budget - totalPay;

        _getFinance().pay(owner,msg.sender,totalPay);
        _getStorage().setCampaignBudgetById(bidId,newBudget);

        emit PoARegistered(bidId,rootHash,signedRootHash,newHashes,effectiveConversions);
    }

    /**
    @notice Function to withdraw PoA convertions
    @dev
        This function is restricted to addresses allowed to submit bulk PoAs and enable those 
        addresses to withdraw funds previously collected by bulk PoA submissions
    */

    function withdraw() 
        public 
        onlyIfWhitelisted("withdraw",msg.sender)
        {
        uint256 balance = _getFinance().getUserBalance(msg.sender);
        _getFinance().withdraw(msg.sender,balance);
    }


    function getEndPointOfCampaign (bytes32 bidId) public view returns (string url){
        return ExtendedAdvertisementStorage(address(_getStorage())).getCampaignEndPointById(bidId);
    }

}