const Pokemons = artifacts.require("Pokemons.sol");

contract("Pokemons", accounts => {
  it("should throw event pokemon caught if user can catch the pokemon", async () => {
    const instancePokemons = await Pokemons.deployed();
    const catchPokemonTxReceipt = await instancePokemons.catchPokemon(0, {
      from: accounts[0]
    });
    const msgSenderFromEvent = catchPokemonTxReceipt.logs[0].args.by;
    const pokemonFromEvent = catchPokemonTxReceipt.logs[0].args.pokemon;
    assert.equal(
      0,
      pokemonFromEvent,
      "Pokemon from the event does not match the cathed pokemon"
    );
    assert.equal(
      accounts[0],
      msgSenderFromEvent,
      "Msg sender from the event does not match the guy who catched pokemon"
    );
  });
});
