// const { assert } = require("console");

// const Web3 = require('web3');

// const web3 = new Web3("HTTP://127.0.0.1:8545");

// const GroupsContract = artifacts.require("Groups");

// const TreasuryContract = artifacts.require("Treasury");

// const CyclesContract = artifacts.require("Cycles");

// const utils = require("./helpers/utils");

// const ClientRecordContract = artifacts.require("ClientRecord");

// const SavingsConfigContract = artifacts.require("SavingsConfig");

// const DaiLendingAdapterContract = artifacts.require("DaiLendingAdapter");

// const DaiLendingServiceContract = artifacts.require("DaiLendingService");

// const XendFinanceIndividual_Yearn_V1 = artifacts.require(
//   "XendFinanceIndividual_Yearn_V1"
// );

// const RewardConfigContract = artifacts.require("RewardConfig");

// const xendTokenContract = artifacts.require("XendToken");

// const yxendTokenContract = artifacts.require("YXendToken");

// const EsusuServiceContract = artifacts.require("EsusuService");

// const DaiContractABI = require('./abi/DaiContract.json');

// const YDaiContractABI = require('./abi/YDaiContractABI.json');

// const DaiContractAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

// const yDaiContractAddress = "0xC2cB1040220768554cf699b0d863A3cd4324ce32";

// const daiContract = new web3.eth.Contract(DaiContractABI,DaiContractAddress);
    
// const yDaiContract = new web3.eth.Contract(YDaiContractABI,yDaiContractAddress);

// const unlockedAddress = "0x1eC32Bfdbdbd40C0D3ec0fe420EBCfEEb2D56917";


// //  Approve a smart contract address or normal address to spend on behalf of the owner
// async function approveDai(spender,  owner,  amount){

//   await daiContract.methods.approve(spender,amount).send({from: owner});

//   console.log(`Address ${spender}  has been approved to spend ${ amount } x 10^-18 Dai by Owner:  ${owner}`);

// };


   
// //  Send Dai from our constant unlocked address to any recipient
// async function sendDai(amount, recipient){
    
//   var amountToSend = BigInt(amount); //  1000 Dai

//   console.log(`Sending  ${ amountToSend } x 10^-18 Dai to  ${recipient}`);

//   await daiContract.methods.transfer(recipient,amountToSend).send({from: unlockedAddress});

//   let recipientBalance = await daiContract.methods.balanceOf(recipient).call();
  
//   console.log(`Recipient: ${recipient} DAI Balance: ${recipientBalance}`);


// }



// contract("XendFinanceIndividual_Yearn_V1", async (accounts) => {
//   let contractInstance;
 

//   beforeEach(async () => {

//   let clientRecord = await ClientRecordContract.deployed();

//   let savingsConfig =  await SavingsConfigContract.deployed();

//   let groups = await GroupsContract.deployed();

//   let treasury = await TreasuryContract.deployed();

//   let esusuService = await EsusuServiceContract.deployed();

//   let rewardConfig = await RewardConfigContract.deployed(
//     esusuService.address,
//     groups.address
//   );

//   let xendToken = await xendTokenContract.deployed("Xend Token", "XTK", 18, 2000000);

//   let yXend = await yxendTokenContract.deployed("YXend Token", "YXTK", 18, 2000000);

//   let daiLendingService = await DaiLendingServiceContract.deployed();

//   let daiLendingAdapter = await DaiLendingAdapterContract.deployed(DaiLendingServiceContract.address);

//     contractInstance = await XendFinanceIndividual_Yearn_V1.new(
//       daiLendingAdapter.address,
//       daiLendingService.address,
//       xendToken.address,
//       clientRecord.address,
//       savingsConfig.address,
//       yXend.address,
//       treasury.address
//     );
//   });

//   it("Should deploy the XendFinanceIndividual_Yearn_V1 smart contracts", async () => {
//     assert(contractInstance.address !== "");
//   });

//   it("should throw error because no client records exist", async () => {
      
//       await  utils.shouldThrow(contractInstance.getClientRecord(accounts[1]));
      
//   })
//   it("should check if client records exist", async () => {
//       const doesClientRecordExistResult = await contractInstance.doesClientRecordExist(accounts[1]);

//       assert(doesClientRecordExistResult == false);
//   })

//   it("should get a client record", async () => {
    
//     let clientRecord = await ClientRecordContract.deployed();

//   let savingsConfig =  await SavingsConfigContract.deployed();

//   let groups = await GroupsContract.deployed();

//   let esusuService = await EsusuServiceContract.deployed();

//   let treasury = await TreasuryContract.deployed();

//   let rewardConfig = await RewardConfigContract.deployed(
//     esusuService.address,
//     groups.address
//   );

//   let xendToken = await xendTokenContract.deployed("Xend Token", "XTK", 18, 2000000);

//   let yXend = await yxendTokenContract.deployed("YXend Token", "YXTK", 18, 2000000);

//   let daiLendingService = await DaiLendingServiceContract.deployed();

//   let daiLendingAdapter = await DaiLendingAdapterContract.deployed(DaiLendingServiceContract.address);

//     const instance = await XendFinanceIndividual_Yearn_V1.new(
//       daiLendingAdapter.address,
//       daiLendingService.address,
//       xendToken.address,
//       clientRecord.address,
//       savingsConfig.address,
//       yXend.address,
//       treasury.address
//     );

//     console.log(instance.address);


//   await clientRecord.activateStorageOracle(accounts[3], {from :accounts[0]});

//   await clientRecord.createClientRecord(accounts[2], 0, 0, 0, 0, 0, {from : accounts[3]});

//   const getClientRecordResult = await instance.getClientRecord(accounts[2])

//   assert(getClientRecordResult.receipt.status == true, "tx reciept status is true");

//   const getClientRecordByIndexResult = await instance.getClientRecordByIndex(0);

//   assert(getClientRecordByIndexResult.receipt.status == true, "tx reciept status is true");



//    });

//    it("should deposit and withdraw", async () => {

//     let clientRecord = await ClientRecordContract.deployed();

//     let savingsConfig =  await SavingsConfigContract.deployed();
  
//     let groups = await GroupsContract.deployed();
  
//     let esusuService = await EsusuServiceContract.deployed();
  
//     let treasury = await TreasuryContract.deployed();
  
//     let rewardConfig = await RewardConfigContract.deployed(
//       esusuService.address,
//       groups.address
//     );
  
//     let xendToken = await xendTokenContract.deployed("Xend Token", "XTK", 18, 2000000);
  
//     let yXend = await yxendTokenContract.deployed("YXend Token", "YXTK", 18, 2000000);
  
//     let daiLendingService = await DaiLendingServiceContract.deployed();
  
//     let daiLendingAdapter = await DaiLendingAdapterContract.deployed(DaiLendingServiceContract.address);
  
//       const instance = await XendFinanceIndividual_Yearn_V1.new(
//         daiLendingAdapter.address,
//         daiLendingService.address,
//         xendToken.address,
//         clientRecord.address,
//         savingsConfig.address,
//         yXend.address,
//         treasury.address
//       );
  
       
//      let amountToApprove = BigInt(100000000000000000000000);
  
//        let amountToSend = BigInt(100000000000000000000000);
      
//         await sendDai(amountToSend, accounts[0]);
      
//         await approveDai(instance.address, accounts[0], amountToApprove);

//         await clientRecord.activateStorageOracle(instance.address, {from :accounts[0]});

//         await clientRecord.createClientRecord(accounts[2], 0, 0, 0, 0, 0, {from : accounts[3]})

//         const depositResult = await instance.deposit({from : accounts[0]});

//         assert(depositResult.receipt.status == true, "tx receipt status is true")

//         const withdrawResult = await instance.withdraw(10);

//         assert(withdrawResult.receipt.status == true, "tx receipt status is true")


//    })


// });
