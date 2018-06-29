pragma solidity ^0.4.21;

import "./AppCoins.sol";

/**
 * The AdvertisementFinance contract is responsible for keeping track of the 
 * AppCoins transfered by developers when creating campaings
 */
contract AdvertisementFinance {

    mapping (address => uint256) balanceDevelopers;
    address[] developers;
    address owner;
    address advertisementContract;
    AppCoins appc;

    modifier onlyOwner() { 
        require(owner == msg.sender); 
        _; 
    }

    modifier onlyAds() { 
        require(advertisementContract == msg.sender); 
        _; 
    }

    modifier onlyOwnerOrAds() { 
        require(msg.sender == owner || msg.sender == advertisementContract); 
        _; 
    }	

    function AdvertisementFinance (address _addrAppc) 
        public {
        owner = msg.sender;
        appc = AppCoins(_addrAppc);
    }

    function setAdsContractAddress (address _addrAdvert) external {
        
        advertisementContract = _addrAdvert;
    }
    

    function increaseBalance(address _developer, uint256 _value) 
        public onlyAds{
        developers.push(_developer);
        balanceDevelopers[_developer] += _value;

    }

    function pay(address _developer, address _destination, uint256 _value) 
        public onlyAds{

        appc.transfer( _destination, _value);
        balanceDevelopers[_developer] -= _value;
    }

    function withdraw(address _developer, uint256 _value) public onlyOwnerOrAds {

        require(balanceDevelopers[_developer] >= _value);
        
        appc.transfer(_developer, _value);
        balanceDevelopers[_developer] = 0;	
    }

    function reset() public onlyOwnerOrAds {
        for(uint i = 0; i < developers.length; i++){
            withdraw(developers[i],balanceDevelopers[developers[i]]);
        }
    }

    function updateAdvertisementAddress (address _ads) external onlyOwner{
        advertisementContract = _ads;	
    }	

}	

