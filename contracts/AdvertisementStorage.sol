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
        return CampaignLibrary.getCampaignPrice(campaigns[bidId]);
    }

    function setCampaignPriceById(bytes32 bidId, uint price)
        public
        view
        {
        CampaignLibrary.setCampaignPrice(campaigns[bidId], price);
    }

    function getCampaignBudgetById(bytes32 bidId)
        public
        view
        returns (uint) {
        return CampaignLibrary.getCampaignBudget(campaigns[bidId]);
    }

    function setCampaignBudgetById(bytes32 bidId, uint newBudget)
        public
        view
        {
        CampaignLibrary.setCampaignBudget(campaigns[bidId], newBudget);
    }

    function getCampaignStartDateById(bytes32 bidId)
        public
        view
        returns (uint) {
        return CampaignLibrary.getCampaignStartDate(campaigns[bidId]);
    }

    function setCampaignStartDateById(bytes32 bidId, uint newStartDate)
        public
        view
        {
        CampaignLibrary.setCampaignStartDate(campaigns[bidId], newStartDate);
    }

    function getCampaignEndDateById(bytes32 bidId)
        public
        view
        returns (uint) {
        return CampaignLibrary.getCampaignEndDate(campaigns[bidId]);
    }

    function setCampaignEndDateById(bytes32 bidId, uint newEndDate)
        public
        view
        {
        CampaignLibrary.setCampaignEndDate(campaigns[bidId], newEndDate);
    }

    function getCampaignValidById(bytes32 bidId)
        public
        view
        returns (bool) {
        return CampaignLibrary.getCampaignValid(campaigns[bidId]);
    }

    function setCampaignValidById(bytes32 bidId, bool isValid)
        public
        view
        {
        CampaignLibrary.setCampaignValid(campaigns[bidId], isValid);
    }

    function getCampaignOwnerById(bytes32 bidId)
        public
        view
        returns (address) {
        return CampaignLibrary.getCampaignOwner(campaigns[bidId]);
    }

    function setCampaignOwnerById(bytes32 bidId, address newOwner)
        public
        view
        {
        CampaignLibrary.setCampaignOwner(campaigns[bidId], newOwner);
    }

    function getCampaignCountriesById(bytes32 bidId)
        public
        view
        returns (string) {
        return CampaignLibrary.getCampaignCountries(campaigns[bidId]);
    }

    function setCampaignCountriesById(bytes32 bidId, string newCountries)
        public
        view
        {
        CampaignLibrary.setCampaignCountries(campaigns[bidId], newCountries);
    }

    function getCampaignPackageNameById(bytes32 bidId)
        public
        view
        returns (string) {
        return CampaignLibrary.getCampaignPackageName(campaigns[bidId]);
    }

    function setCampaignPackageNameById(bytes32 bidId, string newPackageName)
        public
        view
        {
        CampaignLibrary.setCampaignPackageName(campaigns[bidId], newPackageName);
    }

    function getCampaignVercodesById(bytes32 bidId)
        public
        view
        returns (uint[]) {
        return CampaignLibrary.getCampaignVercodes(campaigns[bidId]);
    }

    function setCampaignVercodesById(bytes32 bidId, uint[] newVercodes)
        public
        view
        {
        CampaignLibrary.setCampaignVercodes(campaigns[bidId], newVercodes);
    }

    function getCampaignIpValidatorById(bytes32 bidId)
        public
        view
        returns (string) {
        return CampaignLibrary.getCampaignIpValidator(campaigns[bidId]);
    }

    function setCampaignIpValidatorById(bytes32 bidId, string newIpValidator)
        public
        view
        {
        CampaignLibrary.setCampaignIpValidator(campaigns[bidId], newIpValidator);
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
