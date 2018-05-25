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

    function getCampaignPriceById(bytes32 bidId)
        public
        view
        returns (uint) {
        return campaigns[bidId].price;
    }

    function setCampaignPriceById(bytes32 bidId, uint price)
        public
        {
        campaigns[bidId].price = price;
    }

    function getCampaignBudgetById(bytes32 bidId)
        public
        view
        returns (uint) {
        return campaigns[bidId].budget;
    }

    function setCampaignBudgetById(bytes32 bidId, uint newBudget)
        public
        {
        campaigns[bidId].budget = newBudget;
    }

    function getCampaignStartDateById(bytes32 bidId)
        public
        view
        returns (uint) {
        return campaigns[bidId].startDate;
    }

    function setCampaignStartDateById(bytes32 bidId, uint newStartDate)
        public
        {
        campaigns[bidId].startDate = newStartDate;
    }

    function getCampaignEndDateById(bytes32 bidId)
        public
        view
        returns (uint) {
        return campaigns[bidId].endDate;
    }

    function setCampaignEndDateById(bytes32 bidId, uint newEndDate)
        public
        {
        campaigns[bidId].endDate = newEndDate;
    }

    function getCampaignValidById(bytes32 bidId)
        public
        view
        returns (bool) {
        return campaigns[bidId].valid;
    }

    function setCampaignValidById(bytes32 bidId, bool isValid)
        public
        {
        campaigns[bidId].valid = isValid;
    }

    function getCampaignOwnerById(bytes32 bidId)
        public
        view
        returns (address) {
        return campaigns[bidId].owner;
    }

    function setCampaignOwnerById(bytes32 bidId, address newOwner)
        public
        {
        campaigns[bidId].owner = newOwner;
    }

    function getCampaignCountriesById(bytes32 bidId)
        public
        view
        returns (string) {
        return campaigns[bidId].filters.countries;
    }

    function setCampaignCountriesById(bytes32 bidId, string newCountries)
        public
        {
        campaigns[bidId].filters.countries = newCountries;
    }

    function getCampaignPackageNameById(bytes32 bidId)
        public
        view
        returns (string) {
        return campaigns[bidId].filters.packageName;
    }

    function setCampaignPackageNameById(bytes32 bidId, string newPackageName)
        public
        {
        campaigns[bidId].filters.packageName = newPackageName;
    }

    function getCampaignVercodesById(bytes32 bidId)
        public
        view
        returns (uint[]) {
        return campaigns[bidId].filters.vercodes;
    }

    function setCampaignVercodesById(bytes32 bidId, uint[] newVercodes)
        public
        {
        campaigns[bidId].filters.vercodes = newVercodes;
    }

    function getCampaignIpValidatorById(bytes32 bidId)
        public
        view
        returns (string) {
        return campaigns[bidId].ipValidator;
    }

    function setCampaignIpValidatorById(bytes32 bidId, string newIpValidator)
        public
        {
        campaigns[bidId].ipValidator = newIpValidator;
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
