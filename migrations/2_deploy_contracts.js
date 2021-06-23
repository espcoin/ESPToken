const EspToken = artifacts.require("./EspToken.sol");

module.exports = function (deployer) {
  deployer.deploy(EspToken, 500000, 50000);
};
