    // TODO
    //  should send dai to account 1 and account 2 before this whole tests - Done
    //  should get yDai balance of account - DaiLending Adapter - Done
    //  should get dai balance of account - DaiLending Adapter - Done
    //  should save - DaiLending Service
    //  should withdraw - DaiLending Service
    //  should withdraw by shares - DaiLending Service
    //  should withdraw by exact amount - DaiLending Service

    console.log("********************** Running Venus Lending Deployments Test *****************************");
    const Web3 = require('web3');
    const { assert } = require('console');
    const web3 = new Web3("HTTP://127.0.0.1:8545");
    
    const ForTubeBankAdapter = artifacts.require("ForTubeBankAdapter");
    const ForTubeBankService = artifacts.require("ForTubeBankService");
    
    
    /** External contracts definition for DAI and YDAI
     *  1. I have unlocked an address from Ganache-cli that contains a lot of dai
     *  2. We will use the DAI contract to enable transfer and also balance checking of the generated accounts
     *  3. We will use the YDAI contract to enable transfer and also balance checking of the generated accounts
    */
    const BUSDContractABI = require("../abi/DAIContract.json");
    const VBUSDContractABI = require("../abi/YDAIContractABI.json");
    
    const BUSDContractAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
    const vBUSDContractAddress = "0x57160962Dc107C8FBC2A619aCA43F79Fd03E7556"
    const unlockedAddress = "0x631fc1ea2270e98fbd9d92658ece0f5a269aa161";   //  Has lots of Binance Pegged - BUSD
    
    const BUSDContract = new web3.eth.Contract(BUSDContractABI,BUSDContractAddress);
    const vBUSDContract = new web3.eth.Contract(VBUSDContractABI,vBUSDContractAddress);
    
    
    var account1;   
    var account2;
    
    var account1Balance;
    var account2Balance;
    
    
    //  Send Dai from our constant unlocked address to any recipient
    async function sendBUSD(amount, recipient){
    
        var amountToSend = BigInt(amount); //  1000 Dai
    
        console.log(`Sending  ${ amountToSend } x 10^-18 Dai to  ${recipient}`);
    
        await BUSDContract.methods.transfer(recipient,amountToSend).send({from: unlockedAddress});
    
        let recipientBalance = await BUSDContract.methods.balanceOf(recipient).call();
        
        console.log(`Recipient: ${recipient} DAI Balance: ${recipientBalance}`);
    
    
    }
    
    //  Approve a smart contract address or normal address to spend on behalf of the owner
    async function approveBUSD(spender,  owner,  amount){
    
        await BUSDContract.methods.approve(spender,amount).send({from: owner});
    
        console.log(`Address ${spender}  has been approved to spend ${ amount } x 10^-18 BUSD by Owner:  ${owner}`);
    
    };
    
    //  Approve a smart contract address or normal address to spend on behalf of the owner
    async function approveVBUSD(spender,  owner,  amount){
    
        await vBUSDContract.methods.approve(spender,amount).send({from: owner});
    
        console.log(`Address ${spender}  has been approved to spend ${ amount } x 10^-18 vBUSD by Owner:  ${owner}`);
    
    };
    
    
    contract('ForTubeBankService', () => {
        let forTubeBankAdapter = null;
        let forTubeBankService = null;
    
        before(async () =>{
            forTubeBankAdapter = await ForTubeBankAdapter.deployed();
            forTubeBankService = await ForTubeBankService.deployed();
    
            //  Update the adapter
            await forTubeBankService.UpdateAdapter(forTubeBankAdapter.address);
    
    
            //  Get the addresses and Balances of at least 2 accounts to be used in the test
            //  Send DAI to the addresses
            web3.eth.getAccounts().then(function(accounts){
    
                account1 = accounts[0];
                account2 = accounts[1];
    
                //  send money from the unlocked dai address to accounts 1 and 2
                var amountToSend = BigInt(10000000000000000000000); //   10,000 Dai
    
                //  get the eth balance of the accounts
                web3.eth.getBalance(account1, function(err, result) {
                    if (err) {
                        console.log(err)
                    } else {
            
                        account1Balance = web3.utils.fromWei(result, "ether");
                        console.log("Account 1: "+ accounts[0] + "  Balance: " + account1Balance + " ETH");
                        sendBUSD(amountToSend,account1);
    
                    }
                });
        
                web3.eth.getBalance(account2, function(err, result) {
                    if (err) {
                        console.log(err)
                    } else {
                        account2Balance = web3.utils.fromWei(result, "ether");
                        console.log("Account 2: "+ accounts[1] + "  Balance: " + account2Balance + " ETH");
                        sendBUSD(amountToSend,account2);                              
    
                    }
                });
    
    
            });
    
    
        });
    
        it('ForTubeBankService Contract: Should deploy  smart contract properly', async () => {
            console.log(forTubeBankService.address);
            assert(forTubeBankService.address !== '');
        });
    
        
        it('ForTubeBankService Contract: Should Get Current Price Per Full Share', async () => {
    
            var price = await forTubeBankService.GetPricePerFullShare();
            console.log(`Current Price Per Full Share: ${price}`);

            var value = BigInt(price);

            let apy = web3.utils.fromWei(price, "ether")
    
            console.log(apy, 'price');

            assert(value > 0);
 
        });
 

        it('Should ensure we have BNB on each generated account', async () => {
            
            assert(account1Balance > 0);
            assert(account2Balance > 0);
    
        });
    


        it('ForTubeBankService Contract: Should Save some BUSD in ForTube', async() => {
    
            //  First we have to approve the adapter to spend money on behlaf of the owner of the DAI, in this case account 1 and 2
            var approvedAmountToSpend = BigInt(10000000000000000000000); //   10,000 Dai
            await approveBUSD(forTubeBankAdapter.address,account1,approvedAmountToSpend);
            await approveBUSD(forTubeBankAdapter.address,account2,approvedAmountToSpend);
    
            //  Save 10,000 BUSD
            //  Amount is deducted from sender which is account 1
            //  TODO: find a way to make request from account 2
            var approvedAmountToSave = "10000000000000000000000"; // NOTE: Use amount as string. It is a bug from web3.js. If you use BigInt it will fail
            await forTubeBankService.Save(approvedAmountToSave, {from : account1}); 

            var pricePerFullShare1 = await forTubeBankService.GetPricePerFullShare();
            console.log(`Price Per Full Share After Account 1 Saves:  ${pricePerFullShare1}`);

            var approvedAmountToSave = "5000000000000000000000"; // NOTE: Use amount as string. It is a bug from web3.js. If you use BigInt it will fail
            await forTubeBankService.Save(approvedAmountToSave, {from : account2}); 
    
            var pricePerFullShare2 = await forTubeBankService.GetPricePerFullShare();
            console.log(`Price Per Full Share After Account 2 Saves:  ${pricePerFullShare2}`);

            //  Get vBUSD Shares balance and BUSD balance after saving
            var fBUSDBalanceAfterSaving = BigInt(await forTubeBankAdapter.GetFBUSDBalance(account1));
            var BUSDBalanceAfterSaving = BigInt(await forTubeBankAdapter.GetBUSDBalance(account1));

            var price = await forTubeBankService.GetPricePerFullShare();

            console.log(fBUSDBalanceAfterSaving * BigInt(price), 'share balance multiplied by price per full share')
    
    
            console.log("ForTubeBankService Contract - FBUSD Balance After Saving: "+fBUSDBalanceAfterSaving);
            console.log("ForTubeBankService Contract - BUSD Balance After Saving: "+BUSDBalanceAfterSaving);
    
            assert(fBUSDBalanceAfterSaving > 0);
            assert(BUSDBalanceAfterSaving >= 0);
        });
    
       
        it('ForTubeBankService Contract: Should give us gross balance per account after saving', async () => {
    
            var price = await forTubeBankService.GetPricePerFullShare();
            var pricePerFullShareValue = BigInt(price);

            let pricePerFullShare = web3.utils.fromWei(price, "ether")
    
            console.log(`Current Price Per Full Share:  ${pricePerFullShare}`);

            //  Get YDai Shares balance and Dai balance after saving
            var account1fBUSDBalanceAfterSaving = BigInt(await forTubeBankAdapter.GetFBUSDBalance(account1));
            var account2fBUSDBalanceAfterSaving = BigInt(await forTubeBankAdapter.GetFBUSDBalance(account2));

            var account1GrossBalance = ( pricePerFullShareValue * account1fBUSDBalanceAfterSaving )
            var account2GrossBalance = ( pricePerFullShareValue * account2fBUSDBalanceAfterSaving )


            console.log(`Account 1 Gross Balance:  ${account1GrossBalance}`);
            console.log(`Account 2 Gross Balance:  ${account2GrossBalance}`);

        });


        it('forTubeBankService Contract: Should Withdraw BUSD From Venus', async() => {
    
            //  Get YDai Shares balance
            var fBUSDBalanceBeforeWithdrawal = BigInt(await forTubeBankAdapter.GetFBUSDBalance(account1));
            
            //  Run this test only if we have yDai shares already in the address
            if(fBUSDBalanceBeforeWithdrawal > 0){
                
                //  First we have to approve the adapter to spend money on behlaf of the owner of the YDAI, in this case account 1 and 2
                var approvedAmountToSpend = BigInt(10000000000000000000000); //   10,000 YDai
                await approveVBUSD(forTubeBankAdapter.address,account1,approvedAmountToSpend);
                await approveVBUSD(forTubeBankAdapter.address,account2,approvedAmountToSpend);
    
                //  Get Dai balance before withdrawal
                var balanceBeforeWithdrawal = BigInt(await forTubeBankAdapter.GetBUSDBalance(account1));
    
                //  Withdraw 2,000  Dai. 
                //  TODO: find a way to make request from account 2
                var approvedAmountToWithdraw = "2000000000000000000000"; // NOTE: Use amount as string. It is a bug from web3.js. If you use BigInt it will fail
                await forTubeBankService.Withdraw(approvedAmountToWithdraw);
    
                //  Get Dai balance after withdrawal
                var balanceAfterWithdrawal = BigInt(await forTubeBankAdapter.GetBUSDBalance(account1));
                
                assert(balanceBeforeWithdrawal >= 0);
                assert(balanceAfterWithdrawal > 0);
                assert(balanceAfterWithdrawal > balanceBeforeWithdrawal);
                console.log("balance before withdrawal: " + balanceBeforeWithdrawal);
                console.log("Withdrawing:  " + approvedAmountToWithdraw + " BUSD");
                console.log("balance after withdrawal: " + balanceAfterWithdrawal);
            }else{
                console.log("Savings has not been made!!!")
            }
    
        });
    
         //  Check for account 1 gross and net balance
         it('forTubeBankAdapter Contract: Should Display Gross and Net Balance For User Account', async () => {
            
            //  Get BUSD balance before withdrawal
            var grossRevenueForAccount1 = BigInt(await forTubeBankAdapter.GetGrossRevenue(account1));
            console.log(`Gross revenue : ${grossRevenueForAccount1}`);

            var netRevenueForAccount1 = BigInt(await forTubeBankAdapter.GetNetRevenue(account1));
            console.log(`Net revenue : ${netRevenueForAccount1}`);

        });

        // it('forTubeBankService Contract: Should Withdraw By Specifying VBUSD Shares Amount Only', async() => {
        //     //  This function is used when you need to only specify the share amount 
    
        //     //  Get YDai Shares balance
        //     var vBUSDBalanceBeforeWithdrawal = BigInt(await forTubeBankAdapter.GetVBUSDBalance(account1));
            
        //     //  Run this test only if we have yDai shares already in the address
        //     if(vBUSDBalanceBeforeWithdrawal > 0){
                
        //         //  First we have to approve the adapter to spend money on behlaf of the owner of the YDAI, in this case account 1 and 2
        //         var approvedAmountToSpend = BigInt(9000000000000000000000); //   10,000 YDai
        //         await approveVBUSD(forTubeBankAdapter.address,account1,approvedAmountToSpend);
        //         await approveVBUSD(forTubeBankAdapter.address,account2,approvedAmountToSpend);
    
        //         //  Get Dai balance before withdrawal
        //         var balanceBeforeWithdrawal = BigInt(await forTubeBankAdapter.GetBUSDBalance(account1));
    
        //         //  Withdraw  
        //         //  TODO: find a way to make request from account 2
        //         var YDaibalanceOfAddress = BigInt(await forTubeBankAdapter.GetVBUSDBalance(account1));
        //         await forTubeBankService.WithdrawBySharesOnly(YDaibalanceOfAddress.toString());
    
        //         //  Get Dai balance after withdrawal
        //         var balanceAfterWithdrawal = BigInt(await forTubeBankAdapter.GetBUSDBalance(account1));
                
        //         assert(balanceBeforeWithdrawal > 0);
        //         assert(balanceAfterWithdrawal > 0);
        //         assert(balanceAfterWithdrawal > balanceBeforeWithdrawal);
        //         console.log("balance before withdrawal by shares: " + balanceBeforeWithdrawal);
        //         console.log("Withdrawing Everything Plus Interest :D");
        //         console.log("balance after withdrawal by shares: " + balanceAfterWithdrawal);  
    
        //     }else{
        //         console.log("Savings has not been made!!!")
        //     }
    
        // });

        //  //  Check for account 1 gross and net balance
        //  it('forTubeBankAdapter Contract: Should Display Gross and Net Balance For User Account', async () => {
            
        //     //  Get BUSD balance before withdrawal
        //     var grossRevenueForAccount1 = BigInt(await forTubeBankAdapter.GetGrossRevenue(account1));
        //     console.log(`Gross revenue : ${grossRevenueForAccount1}`);

        //     var netRevenueForAccount1 = BigInt(await forTubeBankAdapter.GetNetRevenue(account1));
        //     console.log(`Net revenue : ${netRevenueForAccount1}`);

        // });

    });
    