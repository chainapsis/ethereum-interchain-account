pragma solidity ^0.5.12;

import "@openzeppelin/contracts/ownership/Ownable.sol";

/**
 * InterchainAccount contract represents the interchain account that is made by InterchainAccountRouter contract.
 * InterchainAccountRouter contract will make the InterchainAccount contract if RegisterIBCAccountPacket is delivered by IBC.
 * And returns the address of new InterchainAccount contract's address.
 * If InterchainAccountRouter contract get RunTxPacket via IBC, it will execute `runTx` in InterchainAccount.
 * `runTx` will execute `Call` with requested value and data.
 */
contract InterchainAccount is Ownable {
  /**
   * This method can be executed by only owner that is InterchainAccountRouter.
   */
  function runTx(address to, uint256 value, bytes memory data) public onlyOwner returns (bool, bytes memory) {
      return to.call.value(value)(data);
  }
}
