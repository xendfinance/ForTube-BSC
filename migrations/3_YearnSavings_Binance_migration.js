const Web3 = require("web3");
const GroupsContract = artifacts.require("Groups");
const TreasuryContract = artifacts.require("Treasury");
const CyclesContract = artifacts.require("Cycles");
const ClientRecordContract = artifacts.require("ClientRecord");
const SavingsConfigContract = artifacts.require("SavingsConfig");
const XendFinanceIndividual_Yearn_V1Contract = artifacts.require(
  "XendFinanceIndividual_Yearn_V1"
);
const EsusuAdapterContract = artifacts.require('EsusuAdapter');
const EsusuAdapterWithdrawalDelegateContract = artifacts.require('EsusuAdapterWithdrawalDelegate');
const EsusuStorageContract = artifacts.require('EsusuStorage');
const RewardConfigContract = artifacts.require("RewardConfig");
const XendTokenContract = artifacts.require("XendToken");
const EsusuServiceContract = artifacts.require("EsusuService");
const ForTubeBankAdapterContract = artifacts.require("ForTubeBankAdapter");
const ForTubeBankServiceContract = artifacts.require("ForTubeBankService");

// const BUSDContractABI = require('./BEP20ABI.json');
// const FBUSDContractABI = require('./BEP20ABI.json');    // FBUSD and BUSD can use the same ABI since we are just calling basic BEP20 functions for this test

const BUSDContractAddress = "0x3b1F033dD955f3BE8649Cc9825A2e3E194765a3F";  // This is a custom BUSD for ForTube, you will not find it on BSC Faucet
const FBUSDContractAddress = "0x6112a45160b2058C6402a5bfBE3A446c8fD4fb45";  // This is the FToken shares a user will receive when they deposit BUSD




module.exports = function (deployer) {
  
  console.log("********************** Running BSC Migrations *****************************");

  deployer.then(async () => {


     await deployer.deploy(GroupsContract);

     await deployer.deploy(TreasuryContract);

     await deployer.deploy(CyclesContract);

    await deployer.deploy(ClientRecordContract);

     await deployer.deploy(SavingsConfigContract);

     await deployer.deploy(ForTubeBankServiceContract);

     await deployer.deploy(ForTubeBankAdapterContract,ForTubeBankServiceContract.address);

     await deployer.deploy(XendTokenContract, "Xend Token Shares", "$XEND","18","200000000000000000000000000");

     await deployer.deploy(EsusuServiceContract);
    
     await deployer.deploy(RewardConfigContract,EsusuServiceContract.address, GroupsContract.address);
    
     await deployer.deploy(EsusuStorageContract);

    //  address payable serviceContract, address esusuStorageContract, address esusuAdapterContract, 
    //                 string memory feeRuleKey, address treasuryContract, address rewardConfigContract, address xendTokenContract

     await deployer.deploy(EsusuAdapterContract,
                            EsusuServiceContract.address,
                            SavingsConfigContract.address,
                            GroupsContract.address,
                            EsusuStorageContract.address);

      await deployer.deploy(EsusuAdapterWithdrawalDelegateContract,
                              EsusuServiceContract.address, 
                              EsusuStorageContract.address,
                              EsusuAdapterContract.address,
                              "esusufee",
                              TreasuryContract.address,
                              RewardConfigContract.address,
                              XendTokenContract.address,
                              SavingsConfigContract.address);

                              // await deployer.deploy(
                              //   XendFinanceIndividual_Yearn_V1Contract,
                              //   ForTubeBankServiceContract.address,
                              //   ForTubeBankAdapterContract.address,
                              //   BUSDContractAddress,
                              //   ClientRecordContract.address,
                              //   SavingsConfigContract.address,
                              //   FBUSDContractAddress,
                              //   TreasuryContract.address
                              // );
                              
     console.log("Groups Contract address", "",  GroupsContract.address);

     console.log("Treasury Contract address:,", " ", TreasuryContract.address);

     console.log("SavingsConfig Contract address:,", " ", SavingsConfigContract.address);

     console.log("ForTubeBankService Contract address: " + ForTubeBankServiceContract.address);

     console.log("ForTubeBankAdapter Contract address:,", " ", ForTubeBankAdapterContract.address );

     console.log("XendToken Contract address:,", " ", XendTokenContract.address );

     console.log("EsusuService Contract address:,", " ", EsusuServiceContract.address );

     console.log("EsusuStorage Contract address:,", " ", EsusuStorageContract.address );

     console.log("EsusuAdapterWithdrawalDelegate Contract address:,", " ", EsusuAdapterWithdrawalDelegateContract.address );

     console.log("RewardConfig Contract address:,", " ", RewardConfigContract.address );

     console.log("EsusuAdapter Contract address:,", " ", EsusuAdapterContract.address );

     console.log("ClientRecordContract address", ClientRecordContract.address);

     console.log("Xend finance indidvual contract", XendFinanceIndividual_Yearn_V1Contract.address)

     let savingsConfigContract = null;
     let esusuAdapterContract = null;
     let esusuServiceContract = null;
     let groupsContract = null;
     let xendTokenContract = null;
     let esusuAdapterWithdrawalDelegateContract = null;
     let esusuStorageContract = null;
     let fortubeService = null;
     let clientRecord = null;
     let rewardConfigContract = null;

     savingsConfigContract = await SavingsConfigContract.deployed();
     esusuAdapterContract = await EsusuAdapterContract.deployed();
     esusuServiceContract = await EsusuServiceContract.deployed();
     groupsContract = await GroupsContract.deployed();
     xendTokenContract = await XendTokenContract.deployed();
     esusuAdapterWithdrawalDelegateContract = await EsusuAdapterWithdrawalDelegateContract.deployed();
     esusuStorageContract = await EsusuStorageContract.deployed();
     fortubeService = await ForTubeBankServiceContract.deployed();
     clientRecord = await ClientRecordContract.deployed();
     rewardConfigContract = await RewardConfigContract.deployed();
     
     
    
    

     //1. Create SavingsConfig rules

     await clientRecord.activateStorageOracle(XendFinanceIndividual_Yearn_V1Contract.address);
     
     await savingsConfigContract.createRule("XEND_FINANCE_COMMISION_DIVISOR", 0, 0, 100, 1)

     await savingsConfigContract.createRule("XEND_FINANCE_COMMISION_DIVIDEND", 0, 0, 1, 1)
 
     await savingsConfigContract.createRule("PERCENTAGE_PAYOUT_TO_USERS", 0, 0, 0, 1)
 
     await savingsConfigContract.createRule("PERCENTAGE_AS_PENALTY", 0, 0, 1, 1);

     //1. Create SavingsConfig rules
     await savingsConfigContract.createRule("esusufee",0,0,1000,1);

     console.log("1->Savings Config Rule Created ...");
     
     //0. update fortube adapter
     await fortubeService.updateAdapter(ForTubeBankAdapterContract.address)
 
      //3. Update the fortube service Address in the EsusuAdapter Contract
      await esusuAdapterContract.UpdateForTubeBankService(ForTubeBankServiceContract.address);
      console.log("3->Fortube service Address Updated In EsusuAdapter ...");
 
      //4. Update the EsusuAdapter Address in the EsusuService Contract
      await esusuServiceContract.UpdateAdapter(esusuAdapterContract.address);
      console.log("4->EsusuAdapter Address Updated In EsusuService ...");
 
      //5. Activate the storage oracle in Groups.sol with the Address of the EsusuApter
      await  groupsContract.activateStorageOracle(esusuAdapterContract.address);
      console.log("5->EsusuAdapter Address Updated In Groups contract ...");
 
      //6. Xend Token Should Grant access to the  Esusu Adapter Contract
      await xendTokenContract.grantAccess(esusuAdapterContract.address);
      console.log("6->Xend Token Has Given access To Esusu Adapter to transfer tokens ...");
 
      //7. Esusu Adapter should Update Esusu Adapter Withdrawal Delegate
      await esusuAdapterContract.UpdateEsusuAdapterWithdrawalDelegate(esusuAdapterWithdrawalDelegateContract.address);
      console.log("7->EsusuAdapter Has Updated Esusu Adapter Withdrawal Delegate Address ...");
 
      //8. Esusu Adapter Withdrawal Delegate should Update Fortube Lending Service
      await esusuAdapterWithdrawalDelegateContract.UpdateForTubeBankService(ForTubeBankServiceContract.address);
      console.log("8->Esusu Adapter Withdrawal Delegate Has Updated Dai Lending Service ...");
 
      //9. Esusu Service should update esusu adapter withdrawal delegate
      await esusuServiceContract.UpdateAdapterWithdrawalDelegate(esusuAdapterWithdrawalDelegateContract.address);
      console.log("9->Esusu Service Contract Has Updated  Esusu Adapter Withdrawal Delegate Address ...");
 
      //10. Esusu Storage should Update Adapter and Adapter Withdrawal Delegate
      await esusuStorageContract.UpdateAdapterAndAdapterDelegateAddresses(esusuAdapterContract.address,esusuAdapterWithdrawalDelegateContract.address);
      console.log("10->Esusu Storage Contract Has Updated  Esusu Adapter and Esusu Adapter Withdrawal Delegate Address ...");
 
      //11. Xend Token Should Grant access to the  Esusu Adapter Withdrawal Delegate Contract
      await xendTokenContract.grantAccess(esusuAdapterWithdrawalDelegateContract.address);
      console.log("11->Xend Token Has Given access To Esusu Adapter Withdrawal Delegate to transfer tokens ...");

      //12.
     await rewardConfigContract.SetRewardParams("100000000000000000000000000", "10000000000000000000000000", "2", "7", "10","15", "4","60", "4");

     //13. 
     await rewardConfigContract.SetRewardActive(true);
      
  
  })
  
};

    

    // await deployer.deploy(
    //   XendFinanceGroup_Yearn_V1Contract,
    //   DaiLendingServiceContract.address,
    //   DaiLendingAdapter.address,
    //   YDaiToken.address,
    //   GroupsContract.address,
    //   CyclesContract.address,
    //   TreasuryContract.address,
    //   SavingsConfigContract.address,
    //   RewardConfigContract.address,
    //   xendTokenContract.address,
    //   DaiToken.address
    // );

 
