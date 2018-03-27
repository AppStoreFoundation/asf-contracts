pragma solidity ^0.4.8;
/**
 * The AdCampaign contract does this and that...
 */
contract Advertisement {

	struct Filters {
		string countries; 
		string packageName;
		uint[] vercodes;
	}

	struct ValidationRules {
		bool vercode;
		bool ipValidation;
		bool country;
		uint constipDailyConversions;
		uint walletDailyConversions;
	}

	struct Campaign {	
		bytes8 bid_id;
		uint price;
		uint budget;
		uint startDate;
		uint endDate;
		string ipValidator;
		address  owner;
		Filters filters;
	}

	ValidationRules public rules;
	mapping (bytes => Campaign[]) campaigns;

	event CampaignCreated(string packageName, string countries, 
							uint[] vercodes, uint price, uint budget,
							uint startDate, uint endDate);

	function Advertisement () public {
		rules = ValidationRules(false,true,true,2,1);
	}


	function createCampaign (string packageName, string countries, 
							uint[] vercodes, uint price, 
							uint startDate, uint endDate) public payable {
		Campaign memory newCampaign;
		newCampaign.filters.packageName = packageName;
		newCampaign.filters.countries = countries;
		newCampaign.filters.vercodes = vercodes;
		newCampaign.price = price;
		newCampaign.startDate = startDate;
		newCampaign.endDate = endDate;
		
		//Transfers the budget to contract address
		newCampaign.budget = msg.value;
		newCampaign.owner = msg.sender;

		bytes memory country =  new bytes(32);
		bytes memory countriesInBytes = bytes(countries);
		uint countryLength = 0;
		for (uint i=0; i<countriesInBytes.length; i++){

			//if ',' is found, new country ahead
			if(countriesInBytes[i]=="," || i == countriesInBytes.length-1){
			
				if(i == countriesInBytes.length-1){
					country[countryLength]=countriesInBytes[i];
				}

				campaigns[country].push(newCampaign);
				country = new bytes(32);
				countryLength = 0;
			} else {
				country[countryLength]=countriesInBytes[i];
				
				countryLength++;
			}

		}
		
		CampaignCreated(
			packageName,
			countries,
			vercodes,
			price,
			newCampaign.budget,
			startDate,
			endDate);
	}

	function getTotalCampaignsByCountry (string country) returns (uint total) {
		bytes memory countryInBytes = bytes(country);
		total = campaigns[countryInBytes].length;
	}

	function getPackageNameOfCampaign (string country, uint index) 
			returns(string packageName) {
		bytes memory countryInBytes = bytes(country);
	
		packageName = campaigns[countryInBytes][index].filters.packageName;		
	}

	function getCountriesOfCampaign (string country, uint index) 
			returns(string countries){
		bytes memory countryInBytes = bytes(country);
		
		countries = campaigns[countryInBytes][index].filters.countries;
	}

	function getVercodesOfCampaign (string country, uint index) 
			returns(uint[] vercodes) {
		bytes memory countryInBytes = bytes(country);

		vercodes = campaigns[countryInBytes][index].filters.vercodes;
	}

	function getPriceOfCampaign (string country, uint index) 
			returns(uint price) {
		bytes memory countryInBytes = bytes(country);

		price = campaigns[countryInBytes][index].price;		
	}
	
	function getStartDateOfCampaign (string country, uint index) 
			returns(uint startDate) {
		bytes memory countryInBytes = bytes(country);
		
		startDate = campaigns[countryInBytes][index].startDate;		
	}
	
	function getEndDateOfCampaign (string country, uint index) 
			returns(uint endDate) {
		bytes memory countryInBytes = bytes(country);
		
		endDate = campaigns[countryInBytes][index].endDate;		
	}
	
	function getBudgetOfCampaign (string country, uint index) 
			returns(uint budget) {
		bytes memory countryInBytes = bytes(country);

		budget = campaigns[countryInBytes][index].budget;
	}

	function getOwnerOfCampaign (string country, uint index) 
			returns(address owner) {
		bytes memory countryInBytes = bytes(country);

		owner = campaigns[countryInBytes][index].owner;
	}
}
