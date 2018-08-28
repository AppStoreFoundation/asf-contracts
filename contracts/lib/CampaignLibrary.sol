pragma solidity ^0.4.19;


library CampaignLibrary {

    struct Campaign {
        bytes32 bidId;
        uint price;
        uint budget;
        uint startDate;
        uint endDate;
        bool valid;
        address  owner;
    }

    /**
    @notice Converts country index list into 3 uints
    @dev  
        Expects a list of country indexes such that the 2 digit country code is converted to an 
        index. Countries are expected to be indexed so a "AA" country code is mapped to index 0 and 
        "ZZ" country is mapped to index 675.
    @param countries List of country indexes
    @return {
        "countries1" : "First third of the byte array converted in a 256 bytes uint",
        "countries2" : "Second third of the byte array converted in a 256 bytes uint",
        "countries3" : "Third third of the byte array converted in a 256 bytes uint"
    }
    */
    function convertCountryIndexToBytes(uint[] countries) public 
        returns (uint countries1,uint countries2,uint countries3){
        countries1 = 0;
        countries2 = 0;
        countries3 = 0;
        for(uint i = 0; i < countries.length; i++){
            uint index = countries[i];

            if(index<256){
                countries1 = countries1 | uint(1) << index;
            } else if (index<512) {
                countries2 = countries2 | uint(1) << (index - 256);
            } else {
                countries3 = countries3 | uint(1) << (index - 512);
            }
        }

        return (countries1,countries2,countries3);
    }

    
}
