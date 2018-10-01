pragma solidity ^0.4.24;

interface StorageUser {
    function getStorageAddress() external view returns(address _storage);
}