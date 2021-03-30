
//  1. Ensure you have done truffle compile to ensure the contract ABI has been added to the artifact
const ForTubeBankAdapter = artifacts.require("ForTubeBankAdapter");
const ForTubeBankService = artifacts.require("ForTubeBankService");

module.exports = function (deployer) {
  
  console.log("********************** Running ForTube Migrations *****************************");

  deployer.then(async () => {

     await deployer.deploy(ForTubeBankService);

     await deployer.deploy(ForTubeBankAdapter,ForTubeBankService.address);

     console.log("ForTube Bank Service Contract address: " + ForTubeBankService.address);

     console.log("ForTube Bank Adapter address: "+ForTubeBankAdapter.address );
  })
  
};


