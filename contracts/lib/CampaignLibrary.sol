pragma solidity ^0.4.19;


library CampaignLibrary {

    struct Filters {
        uint[3] countries;
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

    function convertCountryIndexToBytes(uint[] countryIndexes) internal returns (uint[3]){
        uint[3] memory countries;
        for(uint i = 0; i < countries.length; i++){
            uint index = countries[i];

            if(index<256){
                countries[0] = countries[0] | uint(1) << index;
            } else if (index<512) {
                countries[1] = countries[1] | uint(1) << (index - 256);
            } else {
                countries[2] = countries[2] | uint(1) << (index - 512);
            }
        }

        return countries;
    }
    
}
