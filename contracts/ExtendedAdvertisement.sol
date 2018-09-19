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
        onlyIfWhitelisted("createCampaign",msg.sender)
        {
        emit Error("createCampaign","Function not implemented.");
        return;
    }

    function cancelCampaign(bytes32 bidId) 
        public 
        onlyIfWhitelisted("createCampaign",msg.sender)
        {
        emit Error("createCampaign","Function not implemented.");
        return;
    }

    function bulckRegisterPoA() 
        public 
        onlyIfWhitelisted("createCampaign",msg.sender)
        {
        emit Error("createCampaign","Function not implemented.");
        return;
    }

}