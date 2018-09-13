pragma solidity ^0.4.24;

import "./Base/BaseAdvertisement.sol";
import "./Base/Whitelist.sol";

contract ExtendedAdvertisement is Whitelist, BaseAdvertisement {

    function createCampaign (
        string packageName,
        uint[3] countries,
        uint[] vercodes,
        uint price,
        uint budget,
        uint startDate,
        uint endDate)
        external 
        onlyWhitelist(msg.sender)
        {
        emit Error("Function not implemented.");
        return;
    }

    function cancelCampaign(bidId) 
        public 
        onlyWhitelist(msg.sender)
        {
        emit Error("Function not implemented.");
        return;
    }

    function bulckRegisterPoA() 
        public 
        onlyWhitelist(msg.sender)
        {
        emit Error("Function not implemented.");
        return;
    }

}