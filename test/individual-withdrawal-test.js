const { assert } = require("console");

const Web3 = require('web3');

const web3 = new Web3("HTTP://127.0.0.1:8545");

const GroupsContract = artifacts.require("Groups");

const TreasuryContract = artifacts.require("Treasury");

const CyclesContract = artifacts.require("Cycles");

const utils = require("./helpers/utils");

const ClientRecordContract = artifacts.require("ClientRecord");

const SavingsConfigContract = artifacts.require("SavingsConfig");

const RewardConfigContract = artifacts.require("RewardConfig");

const xendTokenContract = artifacts.require("XendToken");

const EsusuServiceContract = artifacts.require("EsusuService");

const FortubeAdapterHackContract = artifacts.require("ForTubeBankAdapterHack");

const FortubeServiceContract = artifacts.require("ForTubeBankService");

const XendFinanceIndividual_Yearn_V1 = artifacts.require(
  "XendFinanceIndividual_Yearn_V1"
);

const busdContractAddress = "0x3b1F033dD955f3BE8649Cc9825A2e3E194765a3F";

const fBusdContractAddress = "0x6112a45160b2058C6402a5bfBE3A446c8fD4fb45";

const DaiContractABI = require('./abi/BEP20ABI.json');

const daiContract = new web3.eth.Contract(DaiContractABI, busdContractAddress);




contract("XendFinanceIndividual_Yearn_V1", (accounts) => {
  let contractInstance = null;
 

  before(async () => {

  let clientRecord = await ClientRecordContract.deployed();

  let savingsConfig =  await SavingsConfigContract.deployed();

  let groups = await GroupsContract.deployed();

  let treasury = await TreasuryContract.deployed();

  let esusuService = await EsusuServiceContract.deployed();

  let rewardConfig = await RewardConfigContract.deployed(
    esusuService.address,
    groups.address
  );
  let fortubeService = await FortubeServiceContract.deployed();

    let fortubeAdapter = await FortubeAdapterHackContract.deployed(fortubeService.address);

    contractInstance = await XendFinanceIndividual_Yearn_V1.deployed(
        fortubeAdapter.address,
        fortubeService.address,
        busdContractAddress,
        clientRecord.address,
        savingsConfig.address,
        fBusdContractAddress,
        treasury.address
    );
  });

  it("Should deploy the XendFinanceIndividual_Yearn_V1 smart contracts", async () => {

    console.log(contractInstance.address, 'lol')
    assert(contractInstance.address !== "");
  });

  it("should throw error because no client records exist", async () => {
      
      await  utils.shouldThrow(contractInstance.getClientRecord(accounts[1]));
      
  })
  it("should check if client records exist", async () => {
      const doesClientRecordExistResult = await contractInstance.doesClientRecordExist(accounts[1]);

      assert(doesClientRecordExistResult == false);
  })



   it("should deposit and withdraw", async () => {

    let clientRecord = await ClientRecordContract.deployed();

    let savingsConfig =  await SavingsConfigContract.deployed();
  
    let groups = await GroupsContract.deployed();
  
    let esusuService = await EsusuServiceContract.deployed();
  
    let treasury = await TreasuryContract.deployed();
  
    let rewardConfig = await RewardConfigContract.deployed(
      esusuService.address,
      groups.address
    );

    let fortubeService = await FortubeServiceContract.deployed();

    let fortubeAdapter = await FortubeAdapterHackContract.deployed(fortubeService.address);
  
  
      const individualContractInstance = await XendFinanceIndividual_Yearn_V1.deployed(
        fortubeAdapter.address,
        fortubeService.address,
        busdContractAddress,
        clientRecord.address,
        savingsConfig.address,
        fBusdContractAddress,
        treasury.address
      );

        await clientRecord.activateStorageOracle(individualContractInstance.address, {from :accounts[0]});

        await savingsConfigContract.createRule("XEND_FINANCE_COMMISION_DIVISOR", 0, 0, 100, 1)

        await savingsConfigContract.createRule("XEND_FINANCE_COMMISION_DIVIDEND", 0, 0, 1, 1)
    
        await savingsConfigContract.createRule("PERCENTAGE_PAYOUT_TO_USERS", 0, 0, 0, 1)
    
        await savingsConfigContract.createRule("PERCENTAGE_AS_PENALTY", 0, 0, 1, 1);

        //approve an amount

        var amount = BigInt(100000000000000000000);
        
        await daiContract.methods.approve(individualContractInstance.address, amount).send({ from: accounts[0] });
        
        console.log(`Address ${individualContractInstance.address}  has been approved to spend ${amount} x 10^-18 Dai by Owner:  ${accounts[0]}`);
        
        

        const depositResult = await instance.deposit({from : accounts[0]});

        console.log(depositResult, 'deposit tx');

        assert(depositResult.receipt.status == true, "tx receipt status is true")

        const withdrawResult = await instance.withdraw(amount);

        console.log(withdrawResult, ' withdrawal tx')

        // assert(withdrawResult.receipt.status == true, "tx receipt status is true")


   })


});
