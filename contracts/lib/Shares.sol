pragma solidity 0.4.24;

library Shares {
    uint256 constant dev_share = 85;
    uint256 constant appstore_share = 10;
    uint256 constant oem_share = 5;

    function getDevShare() public pure returns(uint256 _share){
        return dev_share;
    }

    function getAppStoreShare() public pure returns(uint256 _share){
        return appstore_share;
    }

    function getOEMShare() public pure returns(uint256 _share){
        return oem_share;
    }
}