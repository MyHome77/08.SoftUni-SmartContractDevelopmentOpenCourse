const ethers = require("ethers");
const provider = require("./provider");
const contractInfo = require("./Pokemons.json");

const contractAddress = "0x4CA2bC7BE7ADdca7752263290115C091A37f79A4";
let privateKey = '0xb0c77dc4062219d77bbdc1517a5fe5689b699e94107cabb33bc454604856ed97';

const signer = new ethers.Wallet(privateKey, provider);

let contract = new ethers.Contract(
    contractAddress,
    contractInfo.abi, signer
);

// console.log(contract)

// contract.catchPokemon(5).then(console.log);

contract
    .getPokemonsByPerson("0xB4c9e32f9573C671D77dC4040aDB8CB60434de59")
    .then(console.log)

contract.getPokemonHolders(14).then(console.log);