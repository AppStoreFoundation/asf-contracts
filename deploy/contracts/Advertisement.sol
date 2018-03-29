pragma solidity ^0.4.8;

contract AppCoins2 {
    mapping (address => mapping (address => uint256)) public allowance;
    function balanceOf (address _owner) public constant returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (uint);
}

/**
 * The Advertisement contract collects campaigns registered by developers
 * and executes payments to users using campaign registered applications 
 * after proof of Attention.
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
	AppCoins2 appc2;

	// This notifies clients about a newly created campaign
	event CampaignCreated(string packageName, string countries, 
							uint[] vercodes, uint price, uint budget,
							uint startDate, uint endDate);
	/**
	* Constructor function
	*
	* Initializes contract with default validation rules
	*/
	function Advertisement () public {
		rules = ValidationRules(false,true,true,2,1);
	}


	/**
	* Sets AppCoin2 contract address to transfer AppCoins 
	* to contract on campaign creation
	*/
	function setAppCoins2Address (address addrAppc) external {
		appc2 = AppCoins2(addrAppc);
	}
	

	/**
	* Creates a campaign for a certain package name with
	* a defined price and budget and emits a CampaignCreated event
	*/
	function createCampaign (string packageName, string countries, 
							uint[] vercodes, uint price, uint budget, 
							uint startDate, uint endDate) external {
		Campaign memory newCampaign;
		newCampaign.filters.packageName = packageName;
		newCampaign.filters.countries = countries;
		newCampaign.filters.vercodes = vercodes;
		newCampaign.price = price;
		newCampaign.startDate = startDate;
		newCampaign.endDate = endDate;
		
		//Transfers the budget to contract address
        require(appc2.allowance(msg.sender, address(this)) >= budget);

        appc2.transferFrom(msg.sender, address(this), budget);

		newCampaign.budget = budget;
		newCampaign.owner = msg.sender;

		//Assuming each country is represented in ISO country codes
		bytes memory country =  new bytes(2);
		bytes memory countriesInBytes = bytes(countries);
		uint countryLength = 0;

		for (uint i=0; i<countriesInBytes.length; i++){

			//if ',' is found, new country ahead
			if(countriesInBytes[i]=="," || i == countriesInBytes.length-1){
			
				if(i == countriesInBytes.length-1){
					country[countryLength]=countriesInBytes[i];
				}

				campaigns[country].push(newCampaign);

				country =  new bytes(2);
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

	function getTotalCampaignsByCountry (string country) 
			public view returns (uint){
		bytes memory countryInBytes = bytes(country);

		return campaigns[countryInBytes].length;
	}

	function getPackageNameOfCampaign (string country, uint index) 
			public view returns(string) {
		bytes memory countryInBytes = bytes(country);
	
		return campaigns[countryInBytes][index].filters.packageName;		
	}

	function getCountriesOfCampaign (string country, uint index) 
			public view returns(string){
		bytes memory countryInBytes = bytes(country);
		
		return campaigns[countryInBytes][index].filters.countries;
	}

	function getVercodesOfCampaign (string country, uint index) 
			public view returns(uint[]) {
		bytes memory countryInBytes = bytes(country);

		return campaigns[countryInBytes][index].filters.vercodes;
	}

	function getPriceOfCampaign (string country, uint index) 
			public view returns(uint) {
		bytes memory countryInBytes = bytes(country);

		return campaigns[countryInBytes][index].price;		
	}
	
	function getStartDateOfCampaign (string country, uint index) 
			public view returns(uint) {
		bytes memory countryInBytes = bytes(country);
		
		return campaigns[countryInBytes][index].startDate;		
	}
	
	function getEndDateOfCampaign (string country, uint index) 
			public view returns(uint) {
		bytes memory countryInBytes = bytes(country);
		
		return campaigns[countryInBytes][index].endDate;		
	}
	
	function getBudgetOfCampaign (string country, uint index) 
			public view returns(uint) {
		bytes memory countryInBytes = bytes(country);

		return campaigns[countryInBytes][index].budget;
	}

	function getOwnerOfCampaign (string country, uint index) 
			public view returns(address) {
		bytes memory countryInBytes = bytes(country);

		return campaigns[countryInBytes][index].owner;
	}
}
