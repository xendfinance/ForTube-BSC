// const { assert } = require("console");

// const Cycles = artifacts.require("Cycles")

// contract("Cycles", async (accounts) => {
//     let contractInstance;
    
//     beforeEach(async () => {
    
//         contractInstance = await Cycles.new();
    
//     });

 

//     it("Should deploy the cycles smart contracts", async () => {
        
//         assert(contractInstance.address !== "");
//     });

//     it("should create a cycle", async () => {

//           //arrange
//           const instance = await Cycles.new();

//           await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//           let startTimeStamp = 4 * 86400;

//           let duration = 100 * 86400;

//           const createCycleResult = await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from:accounts[1]})

//           assert(createCycleResult.receipt.status == true, "tx reciept status is true")

//           const getCycleIndexResult = await instance.getCycleIndex(1);

//           assert(getCycleIndexResult.length !== null, "cycle index result is null")

//           const getCycleInfoByIdResult = await instance.getCycleInfoById(1);

//           assert(getCycleInfoByIdResult.id.length > 0, "cycle info exists")

//           const getCycleInfoByIndexResult = await instance.getCycleInfoByIndex(0);

//           assert(getCycleInfoByIndexResult.id.length > 0, "cycle info exists");

//     })

//     it("should create cycle financials", async () => {
//         //arrange
//         const instance = await Cycles.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         let startTimeStamp = 4 * 86400;

//         let duration = 100 * 86400;

//         await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from : accounts[1]})

//         const createCycleFinancialsResult = await instance.createCycleFinancials(1, 1, 0, 0, 0, 0, 0, 0, {from : accounts[1]})

//         assert(createCycleFinancialsResult.receipt.status == true, "tx reciept status is true")

//         const getCycleFinancialIndexResult = await instance.getCycleFinancialIndex(1);

//         assert(getCycleFinancialIndexResult.length !== null, "cycle financial index is null")

//         const getCycleFinancialsByIndexResult = await instance.getCycleFinancialsByIndex(0);

//         assert(getCycleFinancialsByIndexResult.length !== null, "cycle financials exist");

//         const getCycleFinancialsByCycleIdResult = await instance.getCycleFinancialsByCycleId(1);
        
//         assert(getCycleFinancialsByCycleIdResult.length !== null, "cycle financials exist")

//     })

//     it("should update a cycle", async () => {

//         //arrange
//         const instance = await Cycles.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         let startTimeStamp = 4 * 86400;

//         let duration = 100 * 86400;
        
//         await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from:accounts[1]})

//         const updateCycleResult = await instance.updateCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from:accounts[1]})

//         assert(updateCycleResult.receipt.status == true, "tx receipt status is true")

//   })


//     it("should update cycle financials", async () => {
//         //arrange
//         const instance = await Cycles.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         let startTimeStamp = 4 * 86400;

//         let duration = 100 * 86400;

//         await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from : accounts[1]})

//         await instance.createCycleFinancials(1, 1, 0, 0, 0, 0, 0, 0, {from : accounts[1]})

//         const updateCycleFinancialsResult = await instance.updateCycleFinancials(1, 0, 0, 0, 0, 0, 0, {from : accounts[1]})

//         assert(updateCycleFinancialsResult.receipt.status == true, "tx reciept status is true")

//     })    

//     it("should create a cycle member", async () => {
        
//         const instance = await Cycles.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         let startTimeStamp = 4 * 86400;

//         let duration = 100 * 86400;

//         await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from : accounts[1]})

//         let depositor = accounts[3];

//         const createCycleMemberResult = await instance.createCycleMember(1, 1, depositor, 0, 1, 0, false, {from: accounts[1]})

//         assert(createCycleMemberResult.receipt.status == true, "tx receipt is true");

//         const getCycleMemberResult = await instance.getCycleMember(0);

//         assert(getCycleMemberResult.length !== null, "cycle member result is null");
//     })

//     it("should update a cycle member", async () => {
        
//         const instance = await Cycles.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         let startTimeStamp = 4 * 86400;

//         let duration = 100 * 86400;

//         await instance.createCycle(1, 0, startTimeStamp, duration, 10, true, 100, 0, 0, 0, 0, {from : accounts[1]})

//         let depositor = accounts[3];
        
//         await instance.createCycleMember(1, 1, depositor, 0, 1, 0, false, {from: accounts[1]})

//         const updateCycleMemberResult = await instance.updateCycleMember(1, depositor, 0, 1, 0, false, {from: accounts[1]});

//         assert(updateCycleMemberResult.receipt.status == true, "tx receipt status is true");
//     })


// })