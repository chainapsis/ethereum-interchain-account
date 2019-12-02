const InterchainAccountRouter = artifacts.require("InterchainAccountRouter");
const Test = artifacts.require("Test");

module.exports = function(deployer) {
    deployer.deploy(InterchainAccountRouter);
    deployer.deploy(Test);
};
