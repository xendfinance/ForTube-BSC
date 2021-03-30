pragma solidity 0.6.6;

import "./IBank.sol";
import "./IFToken.sol";
import "./IBankController.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Exponential.sol";
import "./ReentrancyGuard.sol";
import "./SafeERC20.sol";

contract ForTubeBankAdapter is Ownable, Exponential, ReentrancyGuard {
    

    using SafeMath for uint256;
    
    using SafeERC20 for IERC20; 

    using SafeERC20 for IFToken; 

    IERC20 immutable _BUSD;

    IBank immutable _bank;

    IFToken immutable _fBUSD;  //  BUSD shares

    IBankController immutable _bankController;
    
    mapping(address => uint256) userBUSDdeposits;


    constructor(address payable serviceContract) public Ownable(serviceContract){
        _BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);  // Pegged-BUSD address on BSC Main Network
        _bank = IBank(0x0cEA0832e9cdBb5D476040D58Ea07ecfbeBB7672);              //  Bank Contract on BSC Main Network
        _fBUSD = IFToken(0x57160962Dc107C8FBC2A619aCA43F79Fd03E7556);           //  FToken - ForTube shares for BUSD Deposit
        _bankController = IBankController(0xc78248D676DeBB4597e88071D3d889eCA70E5469);      // Bank Controller Contract on BSC Main Network   
    }
    

    /*
        account: this is the owner of the DAi token
    */
    function Save(uint256 amount, address account)
        public nonReentrant
        onlyOwnerAndServiceContract
    {
        //  Give allowance that a spender can spend on behalf of the owner. NOTE: This approve function has to be called from outside this smart contract because if you call
        //  it from the smart contract, it will use the smart contract address as msg.sender which is not what we want,
        //  we want the address with the DAI token to be the one that will be msg.sender. Hence the line below will not work and needs to be called
        //  from Javascript or C# environment
        //   dai.approve(address(this),amount); (Not work)

        //  See example with Node.js below
        //  await daiContract.methods.approve("recipient(in our case, this smart contract address)",1000000).send({from: "wallet address with DAI"});

        //  Transfer BUSD from the account address to this smart contract address
        _BUSD.safeTransferFrom(account, address(this), amount);

        //  This gives the yDAI contract approval to invest our DAI
        _save(amount, account);
    }

    function GetPricePerFullShare() public view returns (uint256){

        return _fBUSD.exchangeRateStored();
    }

    //  This function returns your DAI balance + interest. NOTE: There is no function in Yearn finance that gives you the direct balance of DAI
    //  So you have to get it in two steps

    function GetGrossRevenue(address account) public view returns (uint256) {
        //  Get the price per full share
        uint256 price = GetPricePerFullShare();

        //  Get the balance of yDai in this users address
        uint256 balanceShares = _fBUSD.balanceOf(account);

        return balanceShares.mul(price);
    }

    function GetNetRevenue(address account) public view returns (uint256) {
        uint256 grossBalance = GetGrossRevenue(account);

        uint256 userBUSDdepositsBalance = userBUSDdeposits[account];

        if(grossBalance > userBUSDdepositsBalance){
        
            return grossBalance.sub(userBUSDdepositsBalance);
        }
        return 0;
    }

    function Withdraw(uint256 amount, address owner)
        public 
        nonReentrant onlyOwnerAndServiceContract
    {
        //  To withdraw our DAi amount, the amount argument is in DAi but the withdraw function of the vDai expects amount in vDai
        //  So we need to find our balance in vDai

        uint256 balanceShares = _fBUSD.balanceOf(owner);

        //  transfer vDai shares From owner to this contract address
        _fBUSD.safeTransferFrom(owner, address(this), balanceShares);

        //  We now call the withdraw function to withdraw the total DAi we have. This withdrawal is sent to this smart contract
        _withdrawBySharesAndAmount(owner,balanceShares,amount);

        //  If we have some DAi left after transferring a specified amount to a recipient, we can re-invest it in yearn finance
        uint256 balanceBUSD = _BUSD.balanceOf(address(this));

        if (balanceBUSD > 0) {
            //  This gives the _fBUSD contract approval to invest our DAi
            _save(balanceBUSD, owner);
        }
    }

    function WithdrawByShares(
        uint256 amount,
        address owner,
        uint256 sharesAmount
    ) public
    nonReentrant onlyOwnerAndServiceContract
    {
        //  To withdraw our DAI amount, the amount argument is in DAI but the withdraw function of the yDAI expects amount in yDAI token

        uint256 balanceShares = sharesAmount;

        //  transfer _fBUSD From owner to this contract address
        _fBUSD.safeTransferFrom(owner, address(this), balanceShares);

        //  We now call the withdraw function to withdraw the total DAi we have. This withdrawal is sent to this smart contract
        _withdrawBySharesAndAmount(owner,balanceShares,amount);

        //  If we have some DAI left after transferring a specified amount to a recipient, we can re-invest it in yearn finance
        uint256 balanceBUSD = _BUSD.balanceOf(address(this));

        if (balanceBUSD > 0) {
            //  This gives the yDAI contract approval to invest our DAI
            _save(balanceBUSD, owner);
        }
    }

    /*
        this function withdraws all the dai to this contract based on the sharesAmount passed
    */
    function WithdrawBySharesOnly(address owner, uint256 sharesAmount)
        public
        nonReentrant onlyOwnerAndServiceContract
    {
        uint256 balanceShares = sharesAmount;

        //  transfer _fBUSD shares From owner to this contract address
        _fBUSD.safeTransferFrom(owner, address(this), balanceShares);

        //  We now call the withdraw function to withdraw the total DAI we have. This withdrawal is sent to this smart contract
        _withdrawBySharesOnly(owner,balanceShares);

    }

    //  This function is an internal function that enabled DAI contract where user has money to approve the yDai contract address to invest the user's DAI
    //  and to send the yDai shares to the user's address
    function _save(uint256 amount, address account) internal {
        //  Approve Bank Controller Contract to be able to spend BUSD in this contract
        _BUSD.approve(address(_bankController),amount);

        //  deposit the BUSD on ForTube's Bank contract
        _bank.deposit(address(_BUSD),amount);

        //  call balanceOf and get the total balance of vDai shares in this contract
        uint256 shares = _fBUSD.balanceOf(address(this));

        //  transfer the _fBUSD shares to the user's address
        _fBUSD.safeTransfer(account, shares);

        //  add deposited dai to userBUSDdeposits mapping
        userBUSDdeposits[account] = userBUSDdeposits[account].add(amount);
    }   

    

    function GetBUSDBalance(address member) external view returns(uint256){
        return _BUSD.balanceOf(member);
    }
    
    function GetFBUSDBalance(address member) external view returns(uint256){
        return _fBUSD.balanceOf(member);
    }
    
    /**
        Gets the total BUSD the user has earned 
        
        Total BUSD = price per fBUSD * _fBUSD.balanceOf(address)
        
        This gives us the amount we deposited plus interest accrued
    */
    function CalculateTotalBUSDEarned(address member) external view returns (uint256 exchangeRate){
        uint fBUSDBalance = _fBUSD.balanceOf(member);
        uint currentPricePerFullShareOfFBUSD = _fBUSD.exchangeRateStored();
        return mulScalarTruncate(fBUSDBalance,currentPricePerFullShareOfFBUSD);
    }
    
        /**
        Gets the price per full share for the respective fToken 
    */
    function ExchangeRateStoredBUSD() external view returns (uint256 exchangeRate){
        return _fBUSD.exchangeRateStored();
    }

    function _withdrawBySharesOnly(address owner, uint256 balanceShares) internal {

        //  We now call the withdraw function to withdraw the total BUSD we have. This withdrawal is sent to this smart contract
        _bank.withdraw(address(_BUSD),balanceShares);

        uint256 contractBUSDBalance = _BUSD.balanceOf(address(this));

        //  Now all the DAI we have are in the smart contract wallet, we can now transfer the total amount to the recipient
        _BUSD.safeTransfer(owner, contractBUSDBalance);

        //   remove withdrawn dai of this owner from userBUSDdeposits mapping
        if (userBUSDdeposits[owner] >= contractBUSDBalance) {
            userBUSDdeposits[owner] = userBUSDdeposits[owner].sub(
                contractBUSDBalance
            );
        } else {
            userBUSDdeposits[owner] = 0;
        }
    }
    
    function _withdrawBySharesAndAmount(address owner, uint256 balanceShares, uint256 amount) internal {
        
        //  We now call the withdraw function to withdraw the total BUSD we have. This withdrawal is sent to this smart contract
        _bank.withdraw(address(_BUSD),balanceShares);

        //  Now all the DAi we have are in the smart contract wallet, we can now transfer the specified amount to a recipient of our choice
        _BUSD.safeTransfer(owner, amount);
        

        //   remove withdrawn DAi of this owner from userBUSDdeposits mapping
        if (userBUSDdeposits[owner] >= amount) {
            userBUSDdeposits[owner] = userBUSDdeposits[owner].sub(
                amount
            );
        } else {
            userBUSDdeposits[owner] = 0;
        }
    }

}