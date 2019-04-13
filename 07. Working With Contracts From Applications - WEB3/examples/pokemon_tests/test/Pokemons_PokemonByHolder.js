const Pokemons = artifacts.require("Pokemons.sol");

contract('Pokemons', (accounts) => {

  it('should match user pokemons and caught pokemons', async () => {
    const instancePokemons = await Pokemons.deployed();
    const catchPokemonTxReceipt = await instancePokemons.catchPokemon(2, {
      from: accounts[0]
    });
    const pokemonsByPerson = await instancePokemons.getPokemonsByPerson.call(accounts[0]);
    assert.equal(1, pokemonsByPerson.length, "User owns invalid count of pokemon");
  });
});