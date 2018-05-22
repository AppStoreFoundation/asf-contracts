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
		string ipValidator;
		bool valid;
		address  owner;
		Filters filters;
	}

}


/**
 * The Advertisement contract collects campaigns registered by developers
 * and executes payments to users using campaign registered applications
 * after proof of Attention.
 */
contract AdvertisementStorage {

		struct ValidationRules {
			bool vercode;
			bool ipValidation;
			bool country;
			uint constipDailyConversions;
			uint walletDailyConversions;
		}

		ValidationRules public rules;
		bytes32[] bidIdList;
		mapping (bytes32 => CampaignLibrary.Campaign) campaigns;
		mapping (bytes => bytes32[]) campaignsByCountry;
		bytes2[] countryList;
	  address public owner;
		mapping (address => mapping (bytes32 => bool)) userAttributions;

    /**
    * Constructor function
    *
    * Initializes contract with default validation rules
    */
    function AdvertisementStorage () public {
        owner = msg.sender;
    }

		function addCampaign(CampaignLibrary.Campaign campaign) internal {

				//Add to bidIdList
				bidIdList.push(campaign.bidId);

				//Add to campaign map
				campaigns[campaign.bidId] = campaign;

				//Assuming each country is represented in ISO country codes
				bytes memory country =  new bytes(2);
				bytes memory countriesInBytes = bytes(campaign.filters.countries);
				uint countryLength = 0;

				for (uint i=0; i<countriesInBytes.length; i++){

					//if ',' is found, new country ahead
					if(countriesInBytes[i]=="," || i == countriesInBytes.length-1){

						if(i == countriesInBytes.length-1){
							country[countryLength]=countriesInBytes[i];
						}

						addCampaignToCountryMap(campaign,country);

						country =  new bytes(2);
						countryLength = 0;
					} else {
						country[countryLength]=countriesInBytes[i];
						countryLength++;
					}
				}
		}


	function addCampaignToCountryMap (CampaignLibrary.Campaign newCampaign,bytes country) internal {
		// Adds a country to countryList if the country is not in this list
		if (campaignsByCountry[country].length == 0){
			bytes2 countryCode;
			assembly {
			       countryCode := mload(add(country, 32))
			}

			countryList.push(countryCode);
		}

		//Adds Campaign to campaignsByCountry map
		campaignsByCountry[country].push(newCampaign.bidId);

	}

	function cancelCampaign (bytes32 bidId) external {
		address campaignOwner = getOwnerOfCampaign(bidId);

		// Only contract owner or campaign owner can cancel a campaign
		require (owner == msg.sender || campaignOwner == msg.sender);
		uint budget = getBudgetOfCampaign(bidId);

		appc.transfer(campaignOwner, budget);

		setBudgetOfCampaign(bidId,0);
		setCampaignValidity(bidId,false);

	}

	function setBudgetOfCampaign (bytes32 bidId, uint budget) internal {
		campaigns[bidId].budget = budget;
	}

    function setCampaignValidity (bytes32 bidId, bool val) internal {
        campaigns[bidId].valid = val;
    }

	function getCampaignValidity(bytes32 bidId) public view returns(bool){
		return campaigns[bidId].valid;
	}


	function getCountryList () public view returns(bytes2[]) {
			return countryList;
	}

	function getCampaignsByCountry(string country)
			public view returns (bytes32[]){
		bytes memory countryInBytes = bytes(country);

		return campaignsByCountry[countryInBytes];
	}


	function getTotalCampaignsByCountry (string country)
			public view returns (uint){
		bytes memory countryInBytes = bytes(country);

		return campaignsByCountry[countryInBytes].length;
	}

	function getPackageNameOfCampaign (bytes32 bidId)
			public view returns(string) {

		return campaigns[bidId].filters.packageName;
	}

	function getCountriesOfCampaign (bytes32 bidId)
			public view returns(string){

		return campaigns[bidId].filters.countries;
	}

	function getVercodesOfCampaign (bytes32 bidId)
			public view returns(uint[]) {

		return campaigns[bidId].filters.vercodes;
	}

	function getPriceOfCampaign (bytes32 bidId)
			public view returns(uint) {

		return campaigns[bidId].price;
	}

	function getStartDateOfCampaign (bytes32 bidId)
			public view returns(uint) {

		return campaigns[bidId].startDate;
	}

	function getEndDateOfCampaign (bytes32 bidId)
			public view returns(uint) {

		return campaigns[bidId].endDate;
	}

	function getBudgetOfCampaign (bytes32 bidId)
			public view returns(uint) {

		return campaigns[bidId].budget;
	}

	function getOwnerOfCampaign (bytes32 bidId)
			public view returns(address) {

		return campaigns[bidId].owner;
	}

	function getBidIdList () public view returns(bytes32[]) {
		return bidIdList;
	}

	function division(uint numerator, uint denominator) public constant returns (uint) {
		uint _quotient = numerator / denominator;
		return _quotient;
  }

	function uintToBytes (uint256 i) constant returns(bytes32 b)  {
		b = bytes32(i);
	}

}
