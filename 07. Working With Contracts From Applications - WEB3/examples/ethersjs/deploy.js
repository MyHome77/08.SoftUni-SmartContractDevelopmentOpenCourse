const ethers = require('ethers');
const contractInfo = require('./Pokemons.json')
const provider = require('./provider')

// Load the wallet to deploy the contract with
let privateKey = '0xb0c77dc4062219d77bbdc1517a5fe5689b699e94107cabb33bc454604856ed97';
let wallet = new ethers.Wallet(privateKey, provider);

// console.log(wallet)

// Deployment is asynchronous, so we use an async IIFE
(async function () {

    // Create an instance of a Contract Factory
    let factory = new ethers.ContractFactory(contractInfo.abi, contractInfo.bytecode, wallet);

    // Notice we pass in "Hello World" as the parameter to the constructor
    let contract = await factory.deploy();

    // The address the Contract WILL have once mined
    // See: https://ropsten.etherscan.io/address/0x2bd9aaa2953f988153c8629926d22a6a5f69b14e
    console.log(contract.address);
    // "0x4CA2bC7BE7ADdca7752263290115C091A37f79A4"

    // The transaction that was sent to the network to deploy the Contract
    // See: https://ropsten.etherscan.io/tx/0x159b76843662a15bd67e482dcfbee55e8e44efad26c5a614245e12a00d4b1a51
    console.log(contract.deployTransaction.hash);
    // "0xbb333052250cc243eac791c30cd829ae5398bec511ac97f74a766b9e98f69d2b"

    // The contract is NOT deployed yet; we must wait until it is mined
    await contract.deployed()

    // Done! The contract is deployed.
})();