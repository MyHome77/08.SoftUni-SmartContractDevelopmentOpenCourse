const Migrations = artifacts.require("Migrations");
const Pokemons = artifacts.require("Pokemons");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Pokemons);
};
