pragma solidity ^0.4.19;

import "./Base/BaseAdvertisementStorage.sol";

/**
@title Advertisement Storage contract
@author App Store Foundation
@dev The Advertisement Storage contract works as part of the user aquisition flow of the 
Advertisement contract. This contract is responsible from storing information regardign user 
aquisiton campaigns.
*/
contract AdvertisementStorage is BaseAdvertisementStorage() {
  
    /**
    @notice Get a Campaign information
    @dev 
        Based on a camapaign Id (bidId), returns all stored information for that campaign.
    @param campaignId Id of the campaign
    @return {
        "bidId" : "Id of the campaign",
        "price" : "Value to pay for each proof-of-attention",
        "budget" : "Total value avaliable to be spent on the campaign",
        "startDate" : "Start date of the campaign (in miliseconds)",
        "endDate" : "End date of the campaign (in miliseconds)"
        "valid" : "Boolean informing if the campaign is valid",
        "campOwner" : "Address of the campaing's owner"
    }
    */
    function getCampaign(bytes32 campaignId)
        public
        view
        returns (
            bytes32 bidId,
            uint price,
            uint budget,
            uint startDate,
            uint endDate,
            bool valid,
            address campOwner
        ) {

        CampaignLibrary.Campaign storage campaign = _getCampaign(campaignId);

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
        An event will be emited during this function's execution, a CampaignCreated event if the 
        campaign does not exist yet or a CampaignUpdated if the campaign id is already registered.

    @param bidId Id of the campaign
    @param price Value to pay for each proof-of-attention
    @param budget Total value avaliable to be spent on the campaign
    @param startDate Start date of the campaign (in miliseconds)
    @param endDate End date of the campaign (in miliseconds)
    @param valid Boolean informing if the campaign is valid
    @param owner Address of the campaing's owner
    */
    function setCampaign (
        bytes32 bidId,
        uint price,
        uint budget,
        uint startDate,
        uint endDate,
        bool valid,
        address owner
    )
    public
    onlyIfWhitelisted("setCampaign",msg.sender) {

        _setCampaign(bidId, price, budget, startDate, endDate, valid, owner);
    }
}
