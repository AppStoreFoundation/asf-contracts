pragma solidity ^0.4.24;

import "./AppCoins.sol";

/**
 * @title AppCoinsTimelock
 * @dev AppCoinsTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 * based on https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/TokenTimelock.sol
 */
contract AppCoinsTimelock {

  // AppCoins token
  AppCoins private appc;

  // beneficiary of tokens before they are released
  mapping (address => uint) balances;

  // timestamp when token release is enabled
  uint private releaseTime;

  event NewFundsAllocated(address _address,  uint _amount);

  constructor(
    address _addrAppc,
    uint256 _releaseTime
  )
    public
  {
    appc = AppCoins(_addrAppc);
    releaseTime = _releaseTime;
  }

  /**
   * @return the time when the tokens are released.
   */
  function getReleaseTime() public view returns(uint256) {
    return releaseTime;
  }

  /**
   * @dev get the address' balances
   */
  function getBalanceOf(address _address) public view returns(uint256){
      return balances[_address];
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function allocateFunds(address _address, uint256 amount) public {
    require(appc.allowance(msg.sender, address(this)) >= amount);
    appc.transferFrom(msg.sender, address(this), amount);
    balances[_address] = balances[_address] + amount;
    emit NewFundsAllocated(_address, balances[_address]);
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function allocateFundsBulk(address[] _addresses, uint256[] amounts) public {
    require(_addresses.length == amounts.length);
    for(uint i = 0; i < _addresses.length; i++){
        allocateFunds(_addresses[i], amounts[i]);
    }
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release(address _address) public {
    uint nowInMilliseconds = block.timestamp * 1000;

    require(nowInMilliseconds >= releaseTime);

    appc.transfer(_address, balances[_address]);
    balances[_address] = 0;
  }
}
