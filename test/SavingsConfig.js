// const { assert } = require("console");

// const SavingsConfig = artifacts.require("SavingsConfig")

// contract("SavingsConfig", async (accounts) => {
//     let contractInstance;
    
//     beforeEach(async () => {
    
//         contractInstance = await SavingsConfig.new();
    
//     });

 

//     it("Should deploy the SavingsConfig smart contracts", async () => {
        
//         assert(contractInstance.address !== "");
//     });

//     it("should create a rule", async () => {
        
//         const createRuleResult = await contractInstance.createRule("njoku rule", 0, 0, 0, 0, {from : accounts[1]});

//         assert(createRuleResult.receipt.status == true, "tx receipt status is true");

//         const getRuleSetResult = await contractInstance.getRuleSet("njoku rule");

//         assert(getRuleSetResult.length !== null, "rule set is null");

//         const getRuleManagerResult = await contractInstance.getRuleManager("njoku rule");

//         assert(getRuleManagerResult.address !== '', "rule manager address is empty");

//         const disableRuleResult = await contractInstance.disableRule("njoku rule");

//         assert(disableRuleResult.receipt.status == true, "tx receipt status for disable ryles is true");

//         const enableRuleResult = await contractInstance.enableRule("njoku rule")

//         assert(enableRuleResult.receipt.status == true, "tx receipt status for enable rules is true");
        
//     })

//     it("should change rule creator", async () => {

//         await contractInstance.createRule("njoku rule", 0, 0, 0, 0, {from : accounts[1]});

//         let ruleCreator = accounts[1];

//         const changeRuleCreatorResult = await contractInstance.changeRuleCreator("njoku rule", accounts[2], {from : ruleCreator});

//         assert(changeRuleCreatorResult.receipt.status == true, "tx reciept status is true")

//     })
// })