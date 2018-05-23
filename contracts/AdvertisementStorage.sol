pragma solidity ^0.4.19;

import  { CampaignLibrary } from "./CampaignLibrary.sol";


contract AdvertisementStorage {

    mapping (bytes32 => CampaignLibrary.Campaign) campaigns;

    event CampaignCreated
        (
            bytes32 bidId,
            uint price,
            uint budget,
            uint startDate,
            uint endDate,
            bool valid,
            address  owner,
            string ipValidator,
            string packageName,
            string countries,
            uint[] vercodes
    );

    event CampaignUpdated
        (
            bytes32 bidId,
            uint price,
            uint budget,
            uint startDate,
            uint endDate,
            bool valid,
            address  owner,
            string ipValidator,
            string packageName,
            string countries,
            uint[] vercodes
    );
    function getCampaign(bytes32 campaignId)
        internal
        view
        returns (CampaignLibrary.Campaign) {

        return campaigns[campaignId];
    }


    function setCampaign(CampaignLibrary.Campaign campaign) internal {

        if (campaigns[campaign.bidId].bidId == 0x0) {
            emit CampaignCreated(
                campaign.bidId,
                campaign.price,
                campaign.budget,
                campaign.startDate,
                campaign.endDate,
                campaign.valid,
                campaign.owner,
                campaign.ipValidator,
                campaign.filters.packageName,
                campaign.filters.countries,
                campaign.filters.vercodes
            );
        } else {
            emit CampaignUpdated(
                campaign.bidId,
                campaign.price,
                campaign.budget,
                campaign.startDate,
                campaign.endDate,
                campaign.valid,
                campaign.owner,
                campaign.ipValidator,
                campaign.filters.packageName,
                campaign.filters.countries,
                campaign.filters.vercodes
            );
        }

        campaigns[campaign.bidId] = campaign;
    }
}
