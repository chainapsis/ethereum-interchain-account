const Web3 = require("web3");
const InterchainAccountRouter = artifacts.require("InterchainAccountRouter");
const TestContract = artifacts.require("Test");

contract("InterchainAccountRouter", accounts => {
    it("should register interchain account", async () => {
        const web3 = getWeb3();
        const instance = getContractInstance(web3, InterchainAccountRouter);
        const result = await instance.methods.createAccount().send({
            from: accounts[0],
            gas: 600000,
        });
    });

    it("should run tx via registered interchain account", async () => {
        const web3 = getWeb3();

        const instance = getContractInstance(web3, InterchainAccountRouter);

        // Create new interchain account.
        let result = await instance.methods.createAccount().send({
            from: accounts[0],
            gas: 600000,
        });
        // Get interchain account's address from event.
        const interchainAccountAddress = result.events.InterchainAccountCreated.returnValues[0];

        const testContract = getContractInstance(web3, TestContract);
        await testContract.methods.increase(accounts[0]).send({
            from: accounts[0],
            gas: 50000,
        });

        // Remember previous seq in test contract.
        const prevSeq = await testContract.methods.seq().call();

        // Make function signature for increase method in test contract.
        // const increaseFunctionSignature = web3.eth.abi.encodeFunctionSignature("increase(address)", interchainAccountAddress);
        // const data = web.eth.abi.encodeParameters(["bytes", "address"], [increaseFunctionSignature, interchainAccountAddress]);
        const data = web3.eth.abi.encodeFunctionCall({
            name: "increase",
            type: "function",
            // Check that msg.sender is set to interchain account.
            inputs: [{
                type: "address",
                name: "sender"
            }]
        }, [interchainAccountAddress]);
        /*
          struct InterchainAccountTx {
            address from;
            address recipient;
            uint256 value;
            bytes data;
          }
         */
        // Make tx bytes for interchain account tx.
        const txBytes = web3.eth.abi.encodeParameters(["address", "address", "uint256", "bytes"], [interchainAccountAddress, testContract._address, 0, data]);
        // Assume that this relays run tx packet.
        result = await instance.methods.receiveRunTxPacket(txBytes).send({
            from: accounts[0],
            gas: 50000,
        });

        // Seq should be increased.
        assert.equal((parseInt(prevSeq)+1).toString(), await testContract.methods.seq().call())
    });
});

function getWeb3() {
    return new Web3(web3.currentProvider);
}

function getContractInstance(web3, contract) {
    const deployedAddress = contract.networks[contract.network_id].address;
    return new web3.eth.Contract(contract.abi, deployedAddress);
}
