pragma solidity ^0.4.21;


import  { CampaignLibrary } from "./lib/CampaignLibrary.sol";
import "./Base/ErrorThrower.sol";
import "./Base/StorageUser.sol";
import "./AdvertisementStorage.sol";
import "./AdvertisementFinance.sol";
import "./Base/BaseFinance.sol";
import "./Base/BaseAdvertisement.sol";
import "./AppCoins.sol";

/**
@title Advertisement contract
@author App Store Foundation
@dev The Advertisement contract collects campaigns registered by developers and executes payments
to users using campaign registered applications after proof of Attention.
 */
contract Advertisement is BaseAdvertisement {

    struct ValidationRules {
        bool vercode;
        bool ipValidation;
        bool country;
        uint constipDailyConversions;
        uint walletDailyConversions;
    }

    uint constant expectedPoALength = 12;

    ValidationRules public rules;

    event PoARegistered(bytes32 bidId, string packageName,uint64[] timestampList,uint64[] nonceList,string walletName, bytes2 countryCode);
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes
    );

   
    function Advertisement (address _addrAppc, address _addrAdverStorage, address _addrAdverFinance) public 
        BaseAdvertisement(_addrAppc,_addrAdverStorage,_addrAdverFinance) {
        rules = ValidationRules(false, true, true, 2, 1);
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
            
        CampaignLibrary.Campaign memory newCampaign = _generateCampaign(packageName, countries, vercodes, price, budget, startDate, endDate);
        
        _getBidIdList().push(newCampaign.bidId);

        AdvertisementStorage(address(_getStorage())).setCampaign(
            newCampaign.bidId,
            newCampaign.price,
            newCampaign.budget,
            newCampaign.startDate,
            newCampaign.endDate,
            newCampaign.valid,
            newCampaign.owner);

        emit CampaignInformation(
            newCampaign.bidId,
            newCampaign.owner,
            "", // ipValidator field
            packageName,
            countries,
            vercodes);
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
        
        // using the same variable as to the for loop to avoid stack too deep error
        i = getUserAttribution(bidId,msg.sender);
        
        if(i>0){
            emit Error(
                "registerPoA","User already registered a proof of attention for this campaign");
            return;
        }

        _setUserAttribution(bidId, msg.sender, ++i);

        payFromCampaign(bidId, msg.sender, appstore, oem);

        emit PoARegistered(bidId, packageName, timestampList, nonces, walletName, countryCode);
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
    function payFromCampaign (bytes32 bidId, address user, address appstore, address oem) internal {
        uint devShare = 85;
        uint appstoreShare = 10;
        uint oemShare = 5;

        //Search bid price
        uint price = _getStorage().getCampaignPriceById(bidId);
        uint budget = _getStorage().getCampaignBudgetById(bidId);
        address campaignOwner = _getStorage().getCampaignOwnerById(bidId);

        require(budget > 0);
        require(budget >= price);

        //transfer to user, appstore and oem
        _getFinance().pay(campaignOwner,user,division(price * devShare, 100));
        _getFinance().pay(campaignOwner,appstore,division(price * appstoreShare, 100));
        _getFinance().pay(campaignOwner,oem,division(price * oemShare, 100));

        //subtract from campaign
        uint newBudget = budget - price;

        _getStorage().setCampaignBudgetById(bidId, newBudget);


        if (newBudget < price) {
            _getStorage().setCampaignValidById(bidId, false);
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

    function upgradeFinance (address addrAdverFinance) public onlyOwner("upgradeFinance") {
        BaseFinance newContract =  super._upgradeFinance(addrAdverFinance);
   
        uint256 oldBalance = appc.balances(address(advertisementFinance));

        require(oldBalance == 0);
        advertisementFinance = newContract;
    }
}
