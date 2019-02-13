pragma solidity 0.4.24;

import "./Ownable.sol";

contract SingleAllowance is Ownable {

    address public allowedAddress;

    modifier onlyAllowed() {
        require(allowedAddress == msg.sender);
        _;
    }

    modifier onlyOwnerOrAllowed() {
        require(owner == msg.sender || allowedAddress == msg.sender);
        _;
    }

    function setAllowedAddress(address _addr) public onlyOwner("setAllowedAddress"){
        allowedAddress = _addr;
    }
}