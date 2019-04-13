const ethers = require('ethers');

let url = "http://localhost:7545";
let provider = new ethers.providers.JsonRpcProvider(url);


module.exports = provider;