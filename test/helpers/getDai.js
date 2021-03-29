const Web3 = require('web3');

const DaiContractABI = require('../abi/DaiContract.json');
const YDaiContractABI = require('../abi/YDAIContractABI.json');

const DaiContractAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const yDaiContractAddress = "0xC2cB1040220768554cf699b0d863A3cd4324ce32";

const recipientAddress = "0xdBC7893df0cc71172C4b0F882e7Be98746b81E5d";    // Unlocked recipient address
// const recipientAddress = "0x1dcf9AE235BbA490BA243a06197802dd9125D4aE"; // locked recipient address. NOTE: Ganache must unlock recipient address before it can receive tokens
const unlockedAddress = "0xdcd024536877075bfb2ffb1db9655ae331045b4e";   //  Has lots of DAI
const unlockedYDaiSenderAddress = "0x66c57bF505A85A74609D2C83E94Aabb26d691E1F";
const yDaiRecipientAddress = "0xD5f5d60C9ccbBa834C1b22739Df0b0556787D4aB";

const web3 = new Web3("HTTP://127.0.0.1:8545");
const daiContract = new web3.eth.Contract(DaiContractABI,DaiContractAddress);
const yDaiContract = new web3.eth.Contract(YDaiContractABI,yDaiContractAddress);

const init = async () => {

    
    let unlockedAddressBalance = await daiContract.methods.balanceOf(unlockedAddress).call();
    let recipientBalance = await daiContract.methods.balanceOf(recipientAddress).call();
    console.log("Unlocked Address Balance: " + unlockedAddressBalance);
    console.log(`Recipient Adress Balance: ${recipientBalance}`);
}

async function run (){


    //  DAI Balance operations
    await daiBalance();

    // //  YDai Balance operations
     await yDaiBalance();

    // //  Approve a contract-address or normal address to spend amount in dai
    // if(true){
    //     var approvedAmountToSpend = BigInt(100000000000000000000000); //   100000 Dai
    //     approve("0x095A5e3343Fe457F9cc7746BB7aCEa76e9CECEA7","0x6ED9978CA98DAbeCb135e10A1cc904d36D86C831",approvedAmountToSpend);
    // }

    // //  Approve a contract-address or normal address to spend amount in YDai
    // if(false){
    //     var approvedAmountToSpend = BigInt(100000000000000000000000); //   100000 YDai
    //     approveYDai("0x05fd1Add42DEF24AfcbD461495d4527925649fE8","0xe22653088394A7283cEa78e4389D863053DE96A3",approvedAmountToSpend);
    // }
    //  Dai Transfer Operation
    if(true){
        var amountToSend = BigInt(90000000000000000000000); //   10000 Dai
        sendDai(amountToSend,recipientAddress);
       sendYDai(amountToSend, yDaiRecipientAddress);
    }


    //  YDai Transfer Operation
     //   await yDaiContract.methods.transfer(yDaiRecipientAddress,4000).send({from: unlockedYDaiSenderAddress});

    //  Get YDai Balance
    //    await yDaiBalance();

};

//  Send Dai from our constant unlocked address
async function sendDai(amount, recipient){

    var amountToSend = BigInt(amount); //  1000 Dai

    console.log(`Sending  ${ amountToSend } x 10^-18 Dai to  ${recipient}`);

    await daiContract.methods.transfer(recipient,amountToSend).send({from: unlockedAddress});

    let recipientBalance = await daiContract.methods.balanceOf(recipient).call();
    
    console.log(`Recipient Balance: ${recipientBalance}`);


}
async function sendYDai(amount, recipient){

    var amountToSend = BigInt(amount); //  1000 Dai

    console.log(`Sending  ${ amountToSend } x 10^-18 Dai to  ${recipient}`);

    await yDaiContract.methods.transfer(recipient,amountToSend).send({from: unlockedYDaiSenderAddress});

    let recipientBalance = await yDaiContract.methods.balanceOf(recipient).call();
    
    console.log(`Recipient Y Balance: ${recipientBalance}`);


}



async function daiBalance(){

    let unlockedAddressBalance = await daiContract.methods.balanceOf(unlockedAddress).call();
    let recipientBalance = await daiContract.methods.balanceOf('0x6123661e433988E1958F32bB400F21e511B079d1').call();

    console.log("Unlocked Address Balance: " + unlockedAddressBalance);
    console.log(`dai lending service Adress Balance: ${recipientBalance}`);
};

async function yDaiBalance(){
    //let unlockedYDaiSenderBalance = await yDaiContract.methods.balanceOf(unlockedYDaiSenderAddress).call();
    let unlockedYDaiRecipientBalance = await yDaiContract.methods.balanceOf(yDaiRecipientAddress).call();

    //console.log("Unlocked YDai Sender Address Balance: " + unlockedYDaiSenderBalance);
    console.log("Unlocked YDai Recipient Address Balance: " + unlockedYDaiRecipientBalance);
};

//  Approve a smart contract address or normal address to spend on behalf of the owner
// async function approve(spender,  owner,  amount){

//     await daiContract.methods.approve(spender,amount).send({from: owner});

//     console.log(`Address ${spender}  has been approved to spend ${ amount } x 10^-18 Dai by Owner:  ${owner}`);

// };

// //  Approve a smart contract address or normal address to spend on behalf of the owner
// async function approveYDai(spender,  owner,  amount){

//     await yDaiContract.methods.approve(spender,amount).send({from: owner});

//     console.log(`Address ${spender}  has been approved to spend ${ amount } x 10^-18 YDai by Owner:  ${owner}`);

// };
//init();
run();
