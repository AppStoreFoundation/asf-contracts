pragma solidity ^0.4.19;


contract AppCoinsAddresses {

    struct ContractAddress {
        uint id;
        string name;
        address at;
        uint createdTime;
        uint updatedTime;
    }

    address public owner;
    mapping(uint => ContractAddress) private appcoinsAddresses;
    uint[] public availableIds;

    string public constant APPCOINS_ADDRESS_INDEX = "appcoins";
    string public constant ADVERTISEMENT_ADDRESS_INDEX = "advertisement";
    string public constant APPCOINSIAB_ADDRESS_INDEX = "appcoinsiab";

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event AddressCreated(uint id, string name, address at);
    event AddressUpdated(uint id, string name, address at);


    function AppCoinsAddresses() public {
        owner = msg.sender;
    }

    function getAvailableIds() public view returns (uint[]) {
        return availableIds;
    }

    function addAddress(string name, address newAddress) public onlyOwner {
        //  find if there is a contract with the same name
        uint contractId;
        bool found;

        (contractId, found) = getContractIdByName(name);

        uint nowInMilliseconds = now * 1000;
        if (!found) {

            ContractAddress memory newContractAddress;
            uint newId = availableIds.length;
            newContractAddress.id = newId;
            newContractAddress.name = name;
            newContractAddress.at = newAddress;
            newContractAddress.createdTime = nowInMilliseconds;
            newContractAddress.updatedTime = nowInMilliseconds;
            availableIds.push(newId);
            appcoinsAddresses[newId] = newContractAddress;
            emit AddressCreated(newContractAddress.id, newContractAddress.name, newContractAddress.at);

        } else {
            ContractAddress storage contAdd = appcoinsAddresses[contractId];
            contAdd.at = newAddress;
            contAdd.updatedTime = nowInMilliseconds;
            emit AddressUpdated(contAdd.id, contAdd.name, contAdd.at);
        }

    }

    function getContractAddressById(uint id) public view returns(address) {
        return appcoinsAddresses[id].at;
    }

    function getContractAddressByName(string name) public view returns(address) {
        //  find if there is a contract with the same name
        uint contractId;
        bool found;

        (contractId, found) = getContractIdByName(name);
        if (!found) {
            revert();
        }

        return getContractAddressById(contractId);
    }

    function setAppCoinsAddress(address newAddress) public {
        addAddress(APPCOINS_ADDRESS_INDEX, newAddress);
    }

    function getAppCoinsAddress() public view returns(address) {
        return getContractAddressByName(APPCOINS_ADDRESS_INDEX);
    }

    function setAdvertisementAddress(address newAddress) public {
        addAddress(ADVERTISEMENT_ADDRESS_INDEX, newAddress);
    }

    function getAdvertisementAddress() public view returns(address) {
        return getContractAddressByName(ADVERTISEMENT_ADDRESS_INDEX);
    }

    function setAppCoinsIABAddress(address newAddress) public {
        addAddress(APPCOINSIAB_ADDRESS_INDEX, newAddress);
    }

    function getAppCoinsIABAddress() public view returns(address) {
        return getContractAddressByName(APPCOINSIAB_ADDRESS_INDEX);
    }

    //  @dev Does a byte-by-byte lexicographical comparison of two strings.
    //  @return a negative number if `_a` is smaller, zero if they are equal
    //  and a positive numbe if `_b` is smaller.
    function compare(string _a, string _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    // @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) internal pure returns (bool) {
        return compare(_a, _b) == 0;
    }

    function getContractIdByName(string name) internal view returns(uint, bool) {
        bool found = false;
        uint contractId = 0;
        for (uint i = 0; i < availableIds.length; i++) {
            if (equal(appcoinsAddresses[availableIds[i]].name, name)) {
                found = true;
                contractId = appcoinsAddresses[availableIds[i]].id;
            }
        }

        return (contractId, found);
    }
}
