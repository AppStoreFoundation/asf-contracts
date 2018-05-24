pragma solidity ^0.4.19;


library CampaignLibrary {

    struct Filters {
        string countries;
        string packageName;
        uint[] vercodes;
    }

    struct Campaign {
        bytes32 bidId;
        uint price;
        uint budget;
        uint startDate;
        uint endDate;
        bool valid;
        address  owner;
        Filters filters;
        string ipValidator;
    }


    function getCampaignId(Campaign campaign)
        internal
        pure
        returns (bytes32) {
        return campaign.bidId;
    }

    function setCampaignId(Campaign campaign, bytes32 newId)
        internal
        pure
        {
        campaign.bidId = newId;
    }

    function getCampaignPrice(Campaign campaign)
        internal
        pure
        returns (uint) {
        return campaign.price;
    }

    function setCampaignPrice(Campaign campaign, uint newPrice)
        internal
        pure
        {
        campaign.price = newPrice;
    }

    function getCampaignBudget(Campaign campaign)
        internal
        pure
        returns (uint) {
        return campaign.budget;
    }

    function setCampaignBudget(Campaign campaign, uint newBudget)
        internal
        pure
        {
        campaign.budget = newBudget;
    }

    function getCampaignStartDate(Campaign campaign)
        internal
        pure
        returns (uint) {
        return campaign.startDate;
    }

    function setCampaignStartDate(Campaign campaign, uint newStartDate)
        internal
        pure
        {
        campaign.startDate = newStartDate;
    }

    function getCampaignEndDate(Campaign campaign)
        internal
        pure
        returns (uint) {
        return campaign.endDate;
    }

    function setCampaignEndDate(Campaign campaign, uint newEndDate)
        internal
        pure
        {
        campaign.endDate = newEndDate;
    }

    function getCampaignValid(Campaign campaign)
        internal
        pure
        returns (bool) {
        return campaign.valid;
    }

    function setCampaignValid(Campaign campaign, bool isValid)
        internal
        pure
        {
        campaign.valid = isValid;
    }

    function getCampaignOwner(Campaign campaign)
        internal
        pure
        returns (address) {
        return campaign.owner;
    }

    function setCampaignOwner(Campaign campaign, address newOwner)
        internal
        pure
        {
        campaign.owner = newOwner;
    }

    function getCampaignCountries(Campaign campaign)
        internal
        pure
        returns (string) {
        return campaign.filters.countries;
    }

    function setCampaignCountries(Campaign campaign, string newCountries)
        internal
        pure
        {
        campaign.filters.countries = newCountries;
    }


    function getCampaignPackageName(Campaign campaign)
        internal
        pure
        returns (string) {
        return campaign.filters.packageName;
    }

    function setCampaignPackageName(Campaign campaign, string newPackageName)
        internal
        pure
        {
        campaign.filters.packageName = newPackageName;
    }

    function getCampaignVercodes(Campaign campaign)
        internal
        pure
        returns (uint[]) {
        return campaign.filters.vercodes;
    }

    function setCampaignVercodes(Campaign campaign, uint[] newVercodes)
        internal
        pure
        {
        campaign.filters.vercodes = newVercodes;
    }

    function getCampaignIpValidator(Campaign campaign)
        internal
        pure
        returns (string) {
        return campaign.ipValidator;
    }

    function setCampaignIpValidator(Campaign campaign, string newIpValidator)
        internal
        pure
        {
        campaign.ipValidator = newIpValidator;
    }
}
