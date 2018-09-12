pragma solidity ^0.4.24;

import "../AppCoins.sol";


contract BaseAdvertisement {
    
    AppCoins appc;

    mapping( bytes32 => mapping(address => uint256)) userAttributions;

    bytes32[] bidIdList;

    event PoARegistered(bytes32 bidId, string packageName,uint64[] timestampList,uint64[] nonceList,string walletName, bytes2 countryCode);
    
    event CampaignInformation
        (
            bytes32 bidId,
            address  owner,
            string ipValidator,
            string packageName,
            uint[3] countries,
            uint[] vercodes
    );

    constructor(address _addrAppc) public {
        appc = AppCoins(_addrAppc);
    }

    /**
    @notice Creates a campaign 
    @dev 
        Method to create a campaign of user aquisition for a certain application.
        This method will emit a Campaign Information event with every information 
        provided in the arguments of this method.
    @param packageName Package name of the appication subject to the user aquisition campaign
    @param countries Encoded list of 3 integers intended to include every 
    county where this campaign will be avaliable.
    For more detain on this encoding refer to wiki documentation.
    @param vercodes List of version codes to which the user aquisition campaign is applied.
    @param price Value (in wei) the campaign owner pays for each proof-of-attention.
    @param budget Total budget (in wei) the campaign owner will deposit 
    to pay for the proof-of-attention.
    @param startDate Date (in miliseconds) on which the campaign will start to be 
    avaliable to users.
    @param endDate Date (in miliseconds) on which the campaign will no longer be avaliable to users.
    */

    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        external;

    /**
    @notice Cancel a campaign and give the remaining budget to the campaign owner
    @dev
        When a campaing owner wants to cancel a campaign, the campaign owner needs 
        to call this function. This function can only be called either by the campaign owner or by 
        the Advertisement contract owner. This function results in campaign cancelation and 
        retreival of the remaining budged to the respective campaign owner.
    @param bidId Campaign id to which the cancelation referes to 
     */
    function cancelCampaign (bytes32 bidId) public;

    /**
    @notice Get the list of Campaign BidIds registered in the contract
    @dev
        Returns the list of BidIds of the campaigns ever registered in the contract
    @return { "bidIds" : "List of BidIds registered in the contract" }
    */
    function getBidIdList() public view returns(bytes32[] bidIds) {
        return bidIdList;
    }

}