pragma solidity ^0.5.12;

import "./InterchainAccount.sol";

contract InterchainAccountRouter {
  event InterchainAccountCreated(address);

  struct InterchainAccountTx {
    address from;
    address to;
    uint256 value;
    bytes data;
  }

  mapping (address => bool) interchainAccounts;

  // If RegisterIBCAccountPacket is delivered from IBC, `createAccount` will create new interchain account and returns its address to sending chain.
  function createAccount() public returns (address) {
    InterchainAccount iaContract = new InterchainAccount();
    interchainAccounts[address(iaContract)] = true;
    emit InterchainAccountCreated(address(iaContract));
    return address(iaContract);
  }
  // TODO: using salt by CREATE2 opcode.
  // generateAddress(identifier: Identifier, salt: Uint8Array): Uint8Array

  // Mockup for receiving run tx packet.
  function receiveRunTxPacket(bytes memory txBytes) public {
    InterchainAccountTx memory interchainAccountTx = deserializeTx(txBytes);
    authenticateTx(interchainAccountTx);
    require(runTx(interchainAccountTx));
  }

  function deserializeTx(bytes memory txBytes) private pure returns (InterchainAccountTx memory) {
    address from;
    address to;
    uint256 value;
    bytes memory data;
    (from, to, value, data) = abi.decode(txBytes, (address, address, uint256, bytes));
    InterchainAccountTx memory interchainAccountTx;
    interchainAccountTx.from = from;
    interchainAccountTx.to = to;
    interchainAccountTx.value = value;
    interchainAccountTx.data = data;
    return interchainAccountTx;
  }

  function authenticateTx(InterchainAccountTx memory interchainAccountTx) private view returns (bool) {
    require(interchainAccounts[interchainAccountTx.from]);
    return true;
  }

  function runTx(InterchainAccountTx memory interchainAccountTx) private returns (bool) {
    (bool success, bytes memory _) = InterchainAccount(interchainAccountTx.from).runTx(interchainAccountTx.to, interchainAccountTx.value, interchainAccountTx.data);
    return success;
  }
}
