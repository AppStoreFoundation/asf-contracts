pragma solidity ^0.4.19;


contract AppcoinsAddresses {

    address private owner;
    mapping (string => address) private appcoinsAddresses;

    string public constant APPCOINS_ADDRESS_INDEX = "appcoins";
    string public constant ADVERTISEMENT_ADDRESS_INDEX = "advertisement";
    string public constant APPCOINSIAB_ADDRESS_INDEX = "appcoinsiab";

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event NewAddress(string index, address newAddress);

    function AppcoinsAddresses() public {
        owner = msg.sender;
    }

    function setAddress(string index, address newAddress) public onlyOwner {
        appcoinsAddresses[index] = newAddress;
        emit NewAddress(index, newAddress);
    }

    function getAddress(string index) public view returns(address) {
        return appcoinsAddresses[index];
    }

    function setAppCoinsAddress(address newAddress) public onlyOwner {
        setAddress(APPCOINS_ADDRESS_INDEX, newAddress);
    }

    function getAppCoinsAddress() public view returns(address) {
        return getAddress(APPCOINS_ADDRESS_INDEX);
    }

    function setAdvertisementAddress(address newAddress) public onlyOwner {
        setAddress(ADVERTISEMENT_ADDRESS_INDEX, newAddress);
    }

    function getAdvertisementAddress() public view returns(address) {
        return getAddress(ADVERTISEMENT_ADDRESS_INDEX);
    }

    function setAppCoinsIABAddress(address newAddress) public onlyOwner {
        setAddress(APPCOINSIAB_ADDRESS_INDEX, newAddress);
    }

    function getAppCoinsIABAddress() public view returns(address) {
        return getAddress(APPCOINSIAB_ADDRESS_INDEX);
    }
}
