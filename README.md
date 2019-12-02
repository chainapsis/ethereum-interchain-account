# Specifications
## Introduction
Interchain account is system that allows other chain to manage the accounts on another chain via [Inter-Blockchain Communication](https://github.com/cosmos/ics) (IBC).  
Interchain accounts are managed by another chain while retaining all the capabilities of a normal account. While an Ethereum CA's contract logic is performed within Ethereum's EVM, Interchain accounts are managed by another chain via IBC in a trustless way.
  
## Implementation
This repo is on proof-of-concept level yet. And, IBC on Ethereum is not implemented yet. Currently, this implements only the interface needed to implement an interchain account.

#### InterchainAccount Contract
InterchainAccount is ownable contract. And, owner will be the InterchainAccountRouter that creates this InterchainAccount contract.  
Owner can request a tx by `runTx` method in InterchainAccount contract. `runTx` will execute transaction to `to` address with requested `value` (ether) and `data`.
`data` can be made by [ABI specification](https://solidity.readthedocs.io/en/v0.5.3/abi-spec.html).
```solidity
function runTx(address to, uint256 value, bytes memory data) public onlyOwner returns (bool, bytes memory) {
    return to.call(data);
}
```

#### InterchainAccountRouter Contract
InterchainAccountRouter is responsible to generate the interchain account and deserialize the interchain account tx and execute it.

If RegisterIBCAccountPacket is delivered from IBC, `createAccount` will create new interchain account and returns its address to sending chain.
`RegisterIBCAccountPacket` includes the salt to help the receiving chain to create an address and sending chain can calculate the address to be generated in advance.  
But, currently, solidity supports [CREATE2](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1014.md) as only assembly code. So generating new address with salt deterministically is not easy. This feature will be implemented in near future. 
```solidity
function createAccount() public returns (address) {
    InterchainAccount iaContract = new InterchainAccount();
    interchainAccounts[address(iaContract)] = true;
    emit InterchainAccountCreated(address(iaContract));
    return address(iaContract);
}
```
`receiveRunTxPacket` method in InterchainAccountRouter contract is mockup method for mocking the process in receiving `RunTxPacket`.  
This will deserialize the tx bytes by ABI and check authentication and execute tx.
```solidity
function receiveRunTxPacket(bytes memory txBytes) public {
    InterchainAccountTx memory interchainAccountTx = deserializeTx(txBytes);
    authenticateTx(interchainAccountTx);
    require(runTx(interchainAccountTx));
}
```

```solidity
struct InterchainAccountTx {
    address from;
    address to;
    uint256 value;
    bytes data;
}
```
`deserializeTx` will deserialize tx bytes by ABI.  
You can make tx bytes by encoding [from, to, value, data] by ABI in order.
```solidity
function deserializeTx(bytes memory txBytes) private returns (InterchainAccountTx memory) {
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
    emit InterchainAccountDeserialzed(from, to, value, data);
    return interchainAccountTx;
}
```

