const Pokemons = artifacts.require("Pokemons.sol");

contract('Pokemons', (accounts) => {

  it('should match pokemon holder', async () => {
    const instancePokemons = await Pokemons.deployed();
    const catchPokemonTxReceipt = await instancePokemons.catchPokemon(2, {
      from: accounts[0]
    });
    const pokemonHolders = await instancePokemons.getPokemonHolders.call(2);
    console.log(pokemonHolders);
    assert.equal(accounts[0], pokemonHolders[0], "Pokemon Holder is Invalid");
  });
});