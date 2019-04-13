const Migrations = artifacts.require("Migrations");
const SimpleBank = artifacts.require("SimpleBank");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(SimpleBank);
};
