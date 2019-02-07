pragma solidity 0.4.24;

library ExtendedCampaignLibrary {
    struct ExtendedInfo{
        bytes32 bidId;
        address rewardManager;
        string endpoint;
    }

    /**
    @notice Set extended campaign id
    @param _bidId Id of the campaign
     */
    function setBidId(ExtendedInfo storage _extendedInfo, bytes32 _bidId) internal {
        _extendedInfo.bidId = _bidId;
    }
    
    /**
    @notice Get extended campaign id
    @return {'_bidId' : 'Id of the campaign'}
    */
    function getBidId(ExtendedInfo storage _extendedInfo) internal view returns(bytes32 _bidId){
        return _extendedInfo.bidId;
    }

    /**
    @notice Set reward manager address 
    @param _rewardManager Address of the reward manager
    */
    function setRewardManager(ExtendedInfo storage _extendedInfo,  address _rewardManager) internal {
        _extendedInfo.rewardManager = _rewardManager;
    }

    /**
    @notice Get reward manager address
    @return {'_rewardManager' : 'Address of the reward manager'} 
    */
    function getRewardManager(ExtendedInfo storage _extendedInfo) internal view returns(address _rewardManager) {
        return _extendedInfo.rewardManager;
    }

    /**
    @notice Set URL of the signing serivce
    @param _endpoint URL of the signing serivce
    */
    function setEndpoint(ExtendedInfo storage _extendedInfo, string  _endpoint) internal {
        _extendedInfo.endpoint = _endpoint;
    }

    /**
    @notice Get URL of the signing service
    @return {'_endpoint' : 'URL of the signing serivce'} 
    */
    function getEndpoint(ExtendedInfo storage _extendedInfo) internal view returns (string _endpoint) {
        return _extendedInfo.endpoint;
    }
}