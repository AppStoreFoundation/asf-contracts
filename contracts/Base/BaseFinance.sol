pragma solidity ^0.4.24;

import "./Ownable.sol";
import "../AppCoins.sol";
import "../Advertisement.sol";


contract BaseFinance is Ownable {

    mapping (address => uint256) balanceUsers;
    mapping (address => bool) userExists;

    address[] users;

    address advertisementContract;
    address advStorageContract;

    AppCoins appc;

    modifier onlyAds() { 
        require(advertisementContract == msg.sender); 
        _; 
    }

    modifier onlyOwnerOrAds() { 
        require(msg.sender == owner || msg.sender == advertisementContract); 
        _; 
    }	

    /**
    @notice Constructor function
    @dev 
        Initializes contract with the AppCoins contract address
    @param _addrAppc Address of the AppCoins (ERC-20) contract
    */
    constructor (address _addrAppc) 
        public {
        appc = AppCoins(_addrAppc);
        advStorageContract = 0x0;
    }


    /**
    @notice Sets the Advertisement Storage contract address used by the Advertisement contract
    @dev
        The Advertisement Storage contract address is mostly used as part of a failsafe mechanism to
        ensure Advertisement contract upgrades are executed using the same Advertisement Storage 
        contract. This function returns every value of AppCoins stored in this contract to their 
        owners, thus requiring new campaigns to be created. This function can only be called by the 
        Advertisement Finance contract owner or by the Advertisement contract registered earlier in 
        this contract.
    @param _addrStorage Address of the new Advertisement Storage contract
    */
    function setAdsStorageAddress (address _addrStorage) external onlyOwnerOrAds {
        reset();
        advStorageContract = _addrStorage;
    }

        /**
    @notice Sets the Advertisement contract address to allow calls from Advertisement contract
    @dev
        This function is used for upgrading the Advertisement contract without need to redeploy 
        Advertisement Finance and Advertisement Storage contracts. The function can only be called 
        by this contract's owner. During the update of the Advertisement contract address, the 
        contract for Advertisement Storage used by the new Advertisement contract is checked. 
        This function reverts if the new Advertisement contract does not use the same Advertisement 
        Storage contract earlier registered in this Advertisement Finance contract.
    @param _addrAdvert Address of the new Advertisement contract 
    */
    function setAdsContractAddress (address _addrAdvert) external onlyOwner("setAdsContractAddress") {
        // Verify if the new Ads contract is using the same storage as before 
        if (advertisementContract != 0x0){
            Advertisement adsContract = Advertisement(advertisementContract);
            address adsStorage = adsContract.getAdvertisementStorageAddress();
            require (adsStorage == advStorageContract);
        }
        
        //Update contract
        advertisementContract = _addrAdvert;
    }

    /**
    @notice Increases balance of a user
    @dev
        This function can only be called by the registered Advertisement contract and increases the 
        balance of a specific user on this contract. This function does not transfer funds, 
        this step need to be done earlier by the Advertisement contract. This function can only be 
        called by the registered Advertisement contract.
    @param _user Address of the user who will receive a balance increase
    @param _value Value of coins to increase the user's balance
    */
    function increaseBalance(address _user, uint256 _value) 
        public onlyAds{

        if(userExists[_user] == false){
            users.push(_user);
            userExists[_user] = true;
        }

        balanceUsers[_user] += _value;
    }

     /**
    @notice Transfers coins from a certain user to a destination address
    @dev
        Used to release a certain value of coins from a certain user to a destination address.
        This function updates the user's balance in the contract. It can only be called by the 
        Advertisement contract registered.
    @param _user Address of the user from which the value will be subtracted
    @param _destination Address receiving the value transfered
    @param _value Value to be transfered in AppCoins
    */
    function pay(address _user, address _destination, uint256 _value) public onlyAds;

    /**
    @notice Withdraws a certain value from a user's balance back to the user's account
    @dev
        Can be called from the Advertisement contract registered or by this contract's owner.
    @param _user Address of the user
    @param _value Value to be transfered in AppCoins
    */
    function withdraw(address _user, uint256 _value) public onlyOwnerOrAds;


    /**
    @notice Resets this contract and returns every amount deposited to each user registered
    @dev
        This function is used in case a contract reset is needed or the contract needs to be 
        deactivated. Thus returns every fund deposited to it's respective owner.
    */
    function reset() public onlyOwnerOrAds {
        for(uint i = 0; i < users.length; i++){
            withdraw(users[i],balanceUsers[users[i]]);
        }
    }


      /**
    @notice Get balance of coins stored in the contract by a specific user
    @dev
        This function can only be called by the Advertisement contract
    @param _user Developer's address
    @return { '_balance' : 'Balance of coins deposited in the contract by the address' }
    */
    function getUserBalance(address _user) public view onlyAds returns(uint256 _balance){
        return balanceUsers[_user];
    }

    /**
    @notice Get list of users with coins stored in the contract 
    @dev
        This function can only be called by the Advertisement contract        
    @return { '_userList' : ' List of users registered in the contract'}
    */
    function getUserList() public view onlyAds returns(address[] _userList){
        return users;
    }
}