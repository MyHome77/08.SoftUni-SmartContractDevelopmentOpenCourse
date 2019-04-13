var Marketplace = artifacts.require("Marketplace");
var ProductLib = artifacts.require("ProductLib");
var StoreLib = artifacts.require("StoreLib");

module.exports = function (deployer) {
  deployer.deploy(ProductLib);
  deployer.deploy(StoreLib);
  deployer.link(ProductLib,Marketplace);
  deployer.link(StoreLib,Marketplace);
  deployer.deploy(Marketplace);
};