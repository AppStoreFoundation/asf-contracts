pragma solidity ^0.4.19;

import  { CampaignLibrary } from "./lib/CampaignLibrary.sol";


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
        public
        view
        returns (
                bytes32,
                uint,
                uint,
                uint,
                uint,
                bool,
                address,
                string,
                string,
                string,
                uint[]
            ) {

        CampaignLibrary.Campaign storage campaign = campaigns[campaignId];

        return (
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


    function setCampaign (
        bytes32 bidId,
        uint price,
        uint budget,
        uint startDate,
        uint endDate,
        bool valid,
        address owner,
        string ipValidator
    ) public {

        CampaignLibrary.Campaign memory campaign = campaigns[campaign.bidId];

        campaign = CampaignLibrary.Campaign({
            bidId: bidId,
            price: price,
            budget: budget,
            startDate: startDate,
            endDate: endDate,
            valid: valid,
            owner: owner,
            ipValidator: ipValidator,
            filters: campaign.filters
        });

        emitEvent(campaigns[campaign.bidId]);

        campaigns[campaign.bidId] = campaign;
    }

    function setCampaignFilters (
        bytes32 bidId,
        string packageName,
        string countries,
        uint[] vercodes
    ) public {

        CampaignLibrary.Campaign memory campaign = campaigns[bidId];

        campaign.filters.packageName = packageName;
        campaign.filters.countries = countries;
        campaign.filters.vercodes = vercodes;

        emitEvent(campaigns[campaign.bidId]);

        campaigns[campaign.bidId] = campaign;
    }

    function emitEvent(CampaignLibrary.Campaign campaign) private {

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
    }
}
