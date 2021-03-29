// const { assert } = require("console");

// const ClientRecord = artifacts.require("ClientRecord")

// contract("ClientRecord", async (accounts) => {
//     let contractInstance;
    
//     beforeEach(async () => {
    
//         contractInstance = await ClientRecord.new();
    
//     });

 

//     it("Should deploy the ClientRecord smart contracts", async () => {
        
//         assert(contractInstance.address !== "");
//     });

//     it("Should create client record", async () => {
//         //arrange
//         const instance = await ClientRecord.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         const createClientRecordResult = await instance.createClientRecord(accounts[2], 0, 0, 0, 0, 0, {from: accounts[1]});

//         assert(createClientRecordResult.receipt.status == true, "tx reciept status is true")

//         let depositor = accounts[2]

//         const doesClientRecordExistResult = await instance.doesClientRecordExist(depositor);

//         assert(doesClientRecordExistResult == true, "client record does not exust");

//         const getRecordIndexResult = await instance.getRecordIndex(depositor);

//         assert(getRecordIndexResult.length !== null, "record is empty")

//         const getClientRecordByIndexResult = await instance.getClientRecordByIndex(0);

//         assert(getClientRecordByIndexResult.length !== null, "client record is not null");

//         const getClientRecordByAddressResult = await instance.getClientRecordByAddress(depositor);

//         assert(getClientRecordByAddressResult.length !== null, "client record is null");
//     })

//     it("Should update a client record", async () => {
//         const instance = await ClientRecord.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         await instance.createClientRecord(accounts[2], 0, 0, 0, 0, 0, {from: accounts[1]});

//         const updateClientRecordResult = await instance.updateClientRecord(accounts[2], 0, 0, 0, 0, 0, {from: accounts[1]});

//         assert(updateClientRecordResult.receipt.status == true, "tx receipt status is true")
//     })

//     it("should get length of client record", async () => {

//         const getLengthOfClientRecordsResult = await contractInstance.getLengthOfClientRecords();

//         assert(getLengthOfClientRecordsResult.length !== null, "client records does not exist");

//     })

// })