pragma solidity ^0.4.8;

contract AppCoins {
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
		bytes32 bidId;
		uint price;
		uint budget;
		uint startDate;
		uint endDate;
		string ipValidator;
		address  owner;
		Filters filters;
	}

	ValidationRules public rules;
	bytes32[] bidIdList;
	mapping (bytes32 => Campaign) campaigns;
	mapping (bytes => bytes32[]) campaignsByCountry;
	AppCoins appc;
	bytes2[] countryList;

	// This notifies clients about a newly created campaign
	event CampaignCreated(bytes32 bidId, string packageName,
							string countries, uint[] vercodes, 
							uint price, uint budget,
							uint startDate, uint endDate);

	event PoARegistered(bytes32 bidId, string packageName,
						uint[] timestampList,uint[] nonceList);
	/**
	* Constructor function
	*
	* Initializes contract with default validation rules
	*/
	function Advertisement () public {
		rules = ValidationRules(false,true,true,2,1);
	}


	/**
	* Sets AppCoins contract address to transfer AppCoins 
	* to contract on campaign creation
	*/
	function setAppCoinsAddress (address addrAppc) external {
		appc = AppCoins(addrAppc);
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
        require(appc.allowance(msg.sender, address(this)) >= budget);

        appc.transferFrom(msg.sender, address(this), budget);

		newCampaign.budget = budget;
		newCampaign.owner = msg.sender;

		newCampaign.bidId = uintToBytes(bidIdList.length);
		addCampaign(newCampaign);
	
		CampaignCreated(
			newCampaign.bidId,
			packageName,
			countries,
			vercodes,
			price,
			budget,
			startDate,
			endDate);
		
	}

	function addCampaign(Campaign campaign) internal {
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
	

	function addCampaignToCountryMap (Campaign newCampaign,bytes country) internal {
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

	function registerPoA (string packageName, bytes32 bidId, uint[] timestampList, uint[] nonces) external {
		
		require (timestampList.length == nonces.length);

		PoARegistered(bidId,packageName,timestampList,nonces);
		
	}
	

	function getCountryList () public view returns(bytes2[]) {
			return countryList;
	}
	
	function getCampaignsByCountry(string country) public view returns (bytes32[]){
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

	function getBidIdList ()  
			public view returns(bytes32[]) {
		return bidIdList;
	}
	
	function uintToBytes (uint256 i) constant returns(bytes32 b)  {
		b = bytes32(i);
	}

}
