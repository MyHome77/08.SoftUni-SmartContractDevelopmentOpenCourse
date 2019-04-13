const ethers = require('ethers');
const provider = require('./provider')

const address = '0xB4c9e32f9573C671D77dC4040aDB8CB60434de59';

// provider.getBalance(address).then((balance) => {
//     // balance is a BigNumber (in wei); format is as a sting (in ether)
//     let etherString = ethers.utils.formatEther(balance);
//     console.log("Balance: " + etherString);
// })

// provider.getTransactionCount(address).then((transactionCount) => {
//     console.log("Total Transactions Ever Sent: " + transactionCount);
// });

// provider.getBlockNumber().then((blockNumber) => {
//     console.log("Current block number: " + blockNumber);
// });

// provider.getGasPrice().then((gasPrice) => {
//     // gasPrice is a BigNumber; convert it to a decimal string
//     gasPriceString = gasPrice.toString();

//     console.log("Current gas price: " + gasPriceString);
// });


// Block Number
// provider.getBlock(0).then((block) => {
//     console.log(block);
//     console.log(block.gasLimit.toString());
// });

// Block Hash
// let blockHash = "0xd0db555209effd2dc2d514180b0b3da6da6af6ffa738c3e20560605ae5d2439d";
// provider.getBlock(blockHash).then((block) => {
//     console.log(block);
// });

// let transactionHash = "0xd0db555209effd2dc2d514180b0b3da6da6af6ffa738c3e20560605ae5d2439d"

// provider.getTransaction(transactionHash).then((transaction) => {
//     console.log(transaction);
// });

// provider.getTransactionReceipt(transactionHash).then((receipt) => {
//     console.log(receipt);
// });