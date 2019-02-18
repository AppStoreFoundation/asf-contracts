pragma solidity 0.4.24;

import "./Base/BaseAdvertisementStorage.sol";
import { ExtendedCampaignLibrary } from "./lib/ExtendedCampaign.sol";

contract ExtendedAdvertisementStorage is BaseAdvertisementStorage {
    using ExtendedCampaignLibrary for ExtendedCampaignLibrary.ExtendedInfo;

    mapping (bytes32 => ExtendedCampaignLibrary.ExtendedInfo) public extendedCampaignInfo;
    
    event ExtendedCampaignCreated(
        bytes32 bidId,
        string endPoint
    );

    event ExtendedCampaignUpdated(
        bytes32 bidId,
        string endPoint
    );

    /**
    @notice Get a Campaign information
    @dev 
        Based on a camapaign Id (bidId), returns all stored information for that campaign.
    @param _campaignId Id of the campaign
    @return {
        "_bidId" : "Id of the campaign",
        "_price" : "Value to pay for each proof-of-attention",
        "_budget" : "Total value avaliable to be spent on the campaign",
        "_startDate" : "Start date of the campaign (in miliseconds)",
        "_endDate" : "End date of the campaign (in miliseconds)"
        "_valid" : "Boolean informing if the campaign is valid",
        "_campOwner" : "Address of the campaing's owner",
    }
    */
    function getCampaign(bytes32 _campaignId)
        public
        view
        returns (
            bytes32 _bidId,
            uint _price,
            uint _budget,
            uint _startDate,
            uint _endDate,
            bool _valid,
            address _campOwner
        ) {

        CampaignLibrary.Campaign storage campaign = _getCampaign(_campaignId);

        return (
            campaign.getBidId(),
            campaign.getPrice(),
            campaign.getBudget(),
            campaign.getStartDate(),
            campaign.getEndDate(),
            campaign.getValidity(),
            campaign.getOwner()
        );
    }

    /**
    @notice Add or update a campaign information
    @dev
        Based on a campaign Id (bidId), a campaign can be created (if non existent) or updated.
        This function can only be called by the set of allowed addresses registered earlier.
        An event will be emited during this function's execution, a CampaignCreated and a 
        ExtendedCampaignEndPointCreated event if the campaign does not exist yet or a 
        CampaignUpdated and a ExtendedCampaignEndPointUpdated event if the campaign id is already 
        registered.

    @param _bidId Id of the campaign
    @param _price Value to pay for each proof-of-attention
    @param _budget Total value avaliable to be spent on the campaign
    @param _startDate Start date of the campaign (in miliseconds)
    @param _endDate End date of the campaign (in miliseconds)
    @param _valid Boolean informing if the campaign is valid
    @param _owner Address of the campaing's owner
    @param _endPoint URL of the signing serivce
    */
    function setCampaign (
        bytes32 _bidId,
        uint _price,
        uint _budget,
        uint _startDate,
        uint _endDate,
        bool _valid,
        address _owner,
        string _endPoint
    )
    public
    onlyIfWhitelisted("setCampaign",msg.sender) {
        
        bool newCampaign = (getCampaignOwnerById(_bidId) == 0x0);
        _setCampaign(_bidId, _price, _budget, _startDate, _endDate, _valid, _owner);
        
        ExtendedCampaignLibrary.ExtendedInfo storage extendedInfo = extendedCampaignInfo[_bidId];
        extendedInfo.setBidId(_bidId);
        extendedInfo.setEndpoint(_endPoint);

        extendedCampaignInfo[_bidId] = extendedInfo;

        if(newCampaign){
            emit ExtendedCampaignCreated(_bidId,_endPoint);
        } else {
            emit ExtendedCampaignUpdated(_bidId,_endPoint);
        }
    }

    /**
    @notice Get campaign signing web service endpoint
    @dev
        Get the end point to which the user should submit the proof of attention to be signed
    @param _bidId Id of the campaign
    @return { "_endPoint": "URL for the signing web service"}
    */

    function getCampaignEndPointById(bytes32 _bidId) 
        public returns (string _endPoint){
        return extendedCampaignInfo[_bidId].getEndpoint();
    }

    /**
    @notice Set campaign signing web service endpoint
    @dev
        Sets the webservice's endpoint to which the user should submit the proof of attention
    @param _bidId Id of the campaign
    @param _endPoint URL for the signing web service
    */
    function setCampaignEndPointById(bytes32 _bidId, string _endPoint) 
        public 
        onlyIfCampaignExists("setCampaignEndPointById",_bidId)
        onlyIfWhitelisted("setCampaignEndPointById",msg.sender) 
        {
        extendedCampaignInfo[_bidId].setEndpoint(_endPoint);
        emit ExtendedCampaignUpdated(_bidId, _endPoint);
    }

}