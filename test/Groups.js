// const { assert } = require("console");

// const Groups = artifacts.require("Groups")

// contract("Groups", async (accounts) => {
//     let contractInstance;
    
//     beforeEach(async () => {
    
//         contractInstance = await Groups.new();
    
//     });

 

//     it("Should deploy the group smart contracts", async () => {
        
//         assert(contractInstance.address !== "", "contract address does not exist");
//     });

    

//     it("should activate storage oracle", async () => {

//         const instance = await Groups.new();

//         const result = await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         assert(result.receipt.status == true, "tx reciept status is true")
        
//     })

//     it("should deactivate storage oracle", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         const result = await instance.deactivateStorageOracle(accounts[1], {from :accounts[0]});

//         assert(result.receipt.status == true, "tx reciept is true")
//     })

//     it("should reassign storage oracle", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         const result = await instance.reAssignStorageOracle(accounts[3], {from : accounts[1]});

//         assert(result.receipt.status == true, "tx reciept is true")
//     })

//     it("should transfer ownership", async () => {

//         const result =  await contractInstance.transferOwnership(accounts[3], {from : accounts[0]});

//         assert(result.receipt.status == true, "tx reciept is true")

//     })

//     it("should create a group", async () => {
//         //arrange
//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         //act
//          await instance.createGroup("njokuAkawo", "N9", accounts[2], {from : accounts[1]})

//         const getGroup = await instance.getGroupById(1, {from: accounts[1]});

//         assert(getGroup[3] !== "", "group does not exist")

//         //assert
//         const groupIndexerResult = await instance.getGroupIndexer(1);

//         assert(groupIndexerResult.exist == true)

//         assert(groupIndexerResult.index.length !== null, "tx reciept status is true")
        
//         const getRecordIndexLengthForCreatorResult = await instance.getRecordIndexLengthForCreator(accounts[1])

//         assert(getRecordIndexLengthForCreatorResult.length !== null, "index record length is null");

//         // const getGroupForCreatorIndexer = await instance.getGroupForCreatorIndexer(accounts[1], 1);

//         // console.log(getGroupForCreatorIndexer)

//         const getGroupIndexerByName = await instance.getGroupIndexerByName("njokuAkawo");

//         assert(getGroupIndexerByName.exist == true, "indexer does not exist");

//     })

//     it("should create a group member", async () => {

//           //arrange
//           const instance = await Groups.new();

//           await instance.activateStorageOracle(accounts[1], {from :accounts[0]});
  
//           //act
//           await instance.createGroup("njokuAkawo", "N9", accounts[2], {from : accounts[1]})
  
//           const createMemberResult = await instance.createGroupMember(1, accounts[3], {from: accounts[1]});
          
//           const getGroupMemberResult = await instance.getGroupMember(0);

//           let depositorAddress = getGroupMemberResult._address;
        
//           const doesGroupMemberExistResult = await instance.doesGroupMemberExist(1, depositorAddress);

//           assert(doesGroupMemberExistResult == true, "group member does not exist");

//           assert(depositorAddress !== "", "depositor address is empty");

//           assert(createMemberResult.receipt.status == true, "tx reciept status is true");
  
//          const getGroupMembersDeepIndexerResult = await instance.getGroupMembersDeepIndexer(1, depositorAddress)

//          assert(getGroupMembersDeepIndexerResult.exists == true, "member deep indexer result does not exist");

//          const getRecordIndexLengthForGroupMembersIndexerResult = await instance.getRecordIndexLengthForGroupMembersIndexer(1)

//          assert(getRecordIndexLengthForGroupMembersIndexerResult.length !== null, "index length for group member indexer is null");

//          const getRecordIndexLengthForGroupMembersIndexerByDepositorResult = await instance.getRecordIndexLengthForGroupMembersIndexerByDepositor(depositorAddress);

//          assert(getRecordIndexLengthForGroupMembersIndexerByDepositorResult.length !== null, "indexer length by depositor is null");
//     })

//     it("should check length of token address used in deposit", async () => {
//         const result = await contractInstance.getLengthOfTokenAddressesUsedInDeposit({from: accounts[1]});

//         assert(result.length !== null, "token address is null");
//     })

//     it("should increment token deposit", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         //act

//         const result = await instance.incrementTokenDeposit(accounts[2], 10, {from : accounts[1]})

//         assert(result.receipt.status == true, "tx reciept status is true");

//     })

//     it("should decrement token deposit", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         //act
//          await instance.incrementTokenDeposit(accounts[2], 10, {from : accounts[1]})

//         const result = await instance.decrementTokenDeposit(accounts[2], 5, {from : accounts[1]})

//         assert(result.receipt.status == true, "tx reciept status is true");

//     })

//     it("should increment ether deposit", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         //act

//         const result = await instance.incrementEtherDeposit(15, {from : accounts[1]})

//         assert(result.receipt.status == true, "tx reciept status is true");

//     })

//     it("should decrement ether deposit", async () => {

//         const instance = await Groups.new();

//         await instance.activateStorageOracle(accounts[1], {from :accounts[0]});

//         //act

//         await instance.incrementEtherDeposit(15, {from : accounts[1]})

//         const result = await instance.decrementEtherDeposit(5, {from : accounts[1]})

//         assert(result.receipt.status == true, "tx reciept status is true");

//     })



// })