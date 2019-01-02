pragma solidity ^0.4.24;

import "./Base/StorageUser.sol";
import "./Base/Whitelist.sol";
import "./Base/BaseAdvertisement.sol";
import "./ExtendedAdvertisementStorage.sol";
import "./ExtendedFinance.sol";


contract ExtendedAdvertisement is BaseAdvertisement, Whitelist {

    event BulkPoARegistered(bytes32 _bidId, bytes _rootHash, bytes _signature, uint256 _newHashes, uint256 _effectiveConversions);
    event SinglePoARegistered(bytes32 _bidId, bytes _timestampAndHash, bytes _signature);
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes
    );
    event ExtendedCampaignInfo
        (
            bytes32 bidId,
            address rewardManager,
            string endPoint
    );

    constructor(address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public
        BaseAdvertisement(_addrAppc,_addrAdverStorage,_addrAdverFinance) {
        addAddressToWhitelist(msg.sender);
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
    @param rewardManager Entity receiving rewards considering a single register PoA submission
    */
    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate,
        address rewardManager,
        string endPoint)
        external
        {

        CampaignLibrary.Campaign memory newCampaign = _generateCampaign(packageName, countries, vercodes, price, budget, startDate, endDate);

        if(newCampaign.owner == 0x0){
            // campaign was not generated correctly (revert)
            return;
        }

        _getBidIdList().push(newCampaign.bidId);

        ExtendedAdvertisementStorage(address(_getStorage())).setCampaign(
            newCampaign.bidId,
            newCampaign.price,
            newCampaign.budget,
            newCampaign.startDate,
            newCampaign.endDate,
            newCampaign.valid,
            newCampaign.owner,
            rewardManager,
            endPoint);

        emit CampaignInformation(
            newCampaign.bidId,
            newCampaign.owner,
            "", // ipValidator field
            packageName,
            countries,
            vercodes);

        emit ExtendedCampaignInfo(newCampaign.bidId, rewardManager, endPoint);
    }

    /**
    @notice Function to submit in bulk PoAs
    @dev
        This function can only be called by whitelisted addresses and provides a cost efficient
        method to submit a batch of validates PoAs at once. This function emits a PoaRegistered
        event containing the campaign id, root hash, signed root hash, number of new hashes since
        the last submission and the effective number of conversions.

    @param _bidId Campaign id for which the Proof of attention root hash refferes to
    @param _rootHash Root hash of all submitted proof of attention to a given campaign
    @param _signature Root hash signed by the signing service of the campaign
    @param _newHashes Number of new proof of attention hashes since last submission
    */
    function bulkRegisterPoA(bytes32 _bidId, bytes _rootHash, bytes _signature, uint256 _newHashes)
        public
        onlyIfWhitelisted("createCampaign", msg.sender)
        {

        /* address addressSig = recoverSigner(rootHash, signedRootHash); */

        /* if (msg.sender != addressSig) {
            emit Error("bulkRegisterPoA","Invalid signature");
            return;
        } */

        uint price = _getStorage().getCampaignPriceById(_bidId);
        uint budget = _getStorage().getCampaignBudgetById(_bidId);
        address owner = _getStorage().getCampaignOwnerById(_bidId);
        uint maxConversions = division(budget,price);
        uint effectiveConversions;
        uint totalPay;
        uint newBudget;

        if (maxConversions >= _newHashes){
            effectiveConversions = _newHashes;
        } else {
            effectiveConversions = maxConversions;
        }

        totalPay = price*effectiveConversions;
        newBudget = budget - totalPay;

        _getFinance().pay(owner, msg.sender, totalPay);
        _getStorage().setCampaignBudgetById(_bidId, newBudget);

        if(newBudget < price){
            _getStorage().setCampaignValidById(_bidId, false);
        }

        emit BulkPoARegistered(_bidId, _rootHash, _signature, _newHashes, effectiveConversions);
    }

    /**
    @notice Function for single PoA submission
    @dev
        This function can be called by anyone and provides a mean for a user to submit a signed PoA.
        This function emits a SinglePoARegistered event. The reward's funds are transfered to a
        reward manager address, owned by the entity responsible for managing rewards.
    @param _bidId Id of the Campaign
    @param _timestampAndHash byte array containing the timestamp of the  signature and the hash of the PoA
    @param _signature signature of the timestamp and Hash bytearray
    */
    function registerPoA(bytes32 _bidId,bytes _timestampAndHash,bytes _signature)
        public
        {

        bool valid = _getStorage().getCampaignValidById(_bidId);

        if(!valid){
            emit Error("registerPoA","Campaign is not valid");
            return;
        }

        address addressSig = recoverSigner(hashPersonalMessage(_timestampAndHash), _signature);

        address rewardManager = ExtendedAdvertisementStorage(address(_getStorage())).getRewardManagerById(_bidId);

        if (rewardManager != addressSig) {
            emit Error("registerPoA","Invalid signature");
            return;
        }

        uint price = _getStorage().getCampaignPriceById(_bidId);
        uint budget = _getStorage().getCampaignBudgetById(_bidId);
        uint newBudget = budget - price;
        address owner = _getStorage().getCampaignOwnerById(_bidId);

        _getFinance().pay(owner,rewardManager,price);
        _getStorage().setCampaignBudgetById(_bidId,newBudget);

        if(newBudget < price){
            _getStorage().setCampaignValidById(_bidId,false);
        }

        emit SinglePoARegistered(_bidId, _timestampAndHash, _signature);
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
        uint256 balance = ExtendedFinance(address(_getFinance())).getRewardsBalance(msg.sender);
        ExtendedFinance(address(_getFinance())).withdrawRewards(msg.sender,balance);
    }
    /**
    @notice Get user's balance of funds obtainded by rewards
    @dev
        Anyone can call this function and get the rewards balance of a certain user.
    @param _user Address from which the balance refers to
    @return { "_balance" : "" } */
    function getRewardsBalance(address _user) public view returns (uint256 _balance) {
        return ExtendedFinance(address(_getFinance())).getRewardsBalance(_user);
    }

    /**
    @notice Returns the signing Endpoint of a camapign
    @dev
        Function returning the Webservice URL responsible for validating and signing a PoA
    @param bidId Campaign id to which the Endpoint is associated
    @return { "url" : "Validation and signature endpoint"}
    */

    function getEndPointOfCampaign (bytes32 bidId) public view returns (string url){
        return ExtendedAdvertisementStorage(address(_getStorage())).getCampaignEndPointById(bidId);
    }
}
