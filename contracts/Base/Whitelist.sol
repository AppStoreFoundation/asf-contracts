pragma solidity 0.4.24;

import "./Ownable.sol";
import "openzeppelin-solidity/contracts/access/rbac/RBAC.sol";
import "./ErrorThrower.sol";

/**
*  @title Whitelist
*  @dev The Whitelist contract is based on OpenZeppelin's Whitelist contract.
*       Has a whitelist of addresses and provides basic authorization control functions.
*       This simplifies the implementation of "user permissions". The main change from 
*       Whitelist's original contract (version 1.12.0) is the use of Error event instead of a revert.
 */

contract Whitelist is Ownable, RBAC {
    string public constant ROLE_WHITELISTED = "whitelist";

    /**
    * @dev Throws Error event if operator is not whitelisted.
    * @param _operator address
    */
    modifier onlyIfWhitelisted(string _funcname, address _operator) {
        if(!hasRole(_operator, ROLE_WHITELISTED)){
            emit Error(_funcname, "Operation can only be performed by Whitelisted Addresses");
            return;
        }
        _;
    }

    /**
    * @dev add an address to the whitelist
    * @param _operator address
    * @return true if the address was added to the whitelist, false if the address was already in the whitelist
    */
    function addAddressToWhitelist(address _operator)
        public
        onlyOwner("addAddressToWhitelist")
    {
        addRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev getter to determine if address is in whitelist
    */
    function whitelist(address _operator)
        public
        view
        returns (bool)
    {
        return hasRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev add addresses to the whitelist
    * @param _operators addresses
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */
    function addAddressesToWhitelist(address[] _operators)
        public
        onlyOwner("addAddressesToWhitelist")
    {
        for (uint256 i = 0; i < _operators.length; i++) {
            addAddressToWhitelist(_operators[i]);
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param _operator address
    * @return true if the address was removed from the whitelist,
    * false if the address wasn't in the whitelist in the first place
    */
    function removeAddressFromWhitelist(address _operator)
        public
        onlyOwner("removeAddressFromWhitelist")
    {
        removeRole(_operator, ROLE_WHITELISTED);
    }

    /**
    * @dev remove addresses from the whitelist
    * @param _operators addresses
    * @return true if at least one address was removed from the whitelist,
    * false if all addresses weren't in the whitelist in the first place
    */
    function removeAddressesFromWhitelist(address[] _operators)
        public
        onlyOwner("removeAddressesFromWhitelist")
    {
        for (uint256 i = 0; i < _operators.length; i++) {
            removeAddressFromWhitelist(_operators[i]);
        }
    }

}