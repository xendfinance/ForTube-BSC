// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IClientRecordSchema.sol";
import "./IGroupSchema.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";
// import "./IDaiLendingService.sol";
import "./IClientRecord.sol";
// import "./IERC20.sol";
import "./Address.sol";
import "./ISavingsConfig.sol";
import "./ISavingsConfigSchema.sol";
import "./ITreasury.sol";
import "./IRewardConfig.sol";
import "./IBEP20.sol";
import "./IForTubeBankService.sol";
import "./IFToken.sol";
import "./IXendToken.sol";
import "./IGroups.sol";

pragma experimental ABIEncoderV2;


contract XendFinanceIndividual_Yearn_V1 is
    Ownable,
    IClientRecordSchema,
    ISavingsConfigSchema
{
    using SafeMath for uint256;
    
    using SafeERC20 for IFToken;
    
    using SafeERC20 for IBEP20;

    using Address for address payable;

    event UnderlyingAssetDeposited(
        address payable user,
        uint256 underlyingAmount,
        uint256 derivativeAmount,
        uint256 balance
    );

    event DerivativeAssetWithdrawn(
        address payable user,
        uint256 underlyingAmount,
        uint256 derivativeAmount,
        uint256 balance
    );
    
    event DerivativeAssetWithdrawnFromFixed(
          address payable user,
        uint256 underlyingAmount,
        uint256 derivativeAmount        );
    
      event XendTokenReward (
        uint date,
        address payable indexed member,
        uint amount
    );
    
   
    uint minLockPeriod = 7890000;
    
    
  

    IForTubeBankService fortubeService;
    IBEP20 busdToken;      //  BEP20 - ForTube BUSD Testnet TODO: change to live when moving to mainnet 
    IFToken fBusdToken;   //  BEP20 - fBUSD Testnet TODO: change to mainnet
    IClientRecord clientRecordStorage;
    IGroups groupStorage;
    ISavingsConfig savingsConfig;
    IRewardConfig rewardConfig;
    IXendToken xendToken;
    ITreasury treasury;

    bool isDeprecated = false;

    //address LendingAdapterAddress;

    address FortubeBankAdapter;
    address TokenAddress;


    string constant XEND_FINANCE_COMMISION_DIVISOR = "XEND_FINANCE_COMMISION_DIVISOR";
    string constant XEND_FINANCE_COMMISION_DIVIDEND = "XEND_FINANCE_COMMISION_DIVIDEND";
    
    mapping(address=>uint) MemberToXendTokenRewardMapping;  //  This tracks the total amount of xend token rewards a member has received
    
    uint256 lastRecordId;
    
     uint256 _totalTokenReward;      //  This tracks the total number of token rewards distributed on the individual savings

    constructor(
        //address fortubeBankAdapterAddress,
        address fortubeServiceAddress,
        address tokenAddress,
        address clientRecordStorageAddress,
        address groupStorageAddress,
        address savingsConfigAddress,
        address derivativeTokenAddress,
        address rewardConfigAddress,
        address treasuryAddress,
        address xendTokenAddress
    ) public {
        fortubeService = IForTubeBankService(fortubeServiceAddress);
        busdToken = IBEP20(tokenAddress);
        TokenAddress = tokenAddress;
        clientRecordStorage = IClientRecord(clientRecordStorageAddress);
        groupStorage = IGroups(groupStorageAddress);
        savingsConfig = ISavingsConfig(savingsConfigAddress);
        fBusdToken = IFToken(derivativeTokenAddress);
        rewardConfig = IRewardConfig(rewardConfigAddress);
        treasury = ITreasury(treasuryAddress);
        xendToken = IXendToken(xendTokenAddress);
    }

    function deprecateContract(address newServiceAddress)
        external
        onlyOwner
        onlyNonDeprecatedCalls
    {
        isDeprecated = true;
        clientRecordStorage.reAssignStorageOracle(newServiceAddress);
        groupStorage.reAssignStorageOracle(newServiceAddress);

        uint256 derivativeTokenBalance = fBusdToken.balanceOf(
            address(this)
        );
        fBusdToken.transfer(newServiceAddress, derivativeTokenBalance);
         uint256 tokenBalance = busdToken.balanceOf(
            address(this)
        );
        busdToken.transfer(newServiceAddress,tokenBalance);
    }
   

       function GetTotalTokenRewardDistributed() external view returns(uint256){
            return _totalTokenReward;
        }
      function _UpdateMemberToXendTokeRewardMapping(address member, uint rewardAmount) internal onlyNonDeprecatedCalls {
        MemberToXendTokenRewardMapping[member] = MemberToXendTokenRewardMapping[member].add(rewardAmount);
    }

        function GetMemberXendTokenReward(address member) external view returns(uint) {
        return MemberToXendTokenRewardMapping[member];
    }
    
    function doesClientRecordExist(address depositor)
        external
        view
        onlyNonDeprecatedCalls
        returns (bool)
    {
        return clientRecordStorage.doesClientRecordExist(depositor);
    }
    
    function getAdapterAddress() external  {
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();
    }

    function getClientRecord(address depositor)
        external
        view
        onlyNonDeprecatedCalls
        returns (
            address payable _address,
            uint256 underlyingTotalDeposits,
            uint256 underlyingTotalWithdrawn,
            uint256 derivativeBalance,
            uint256 derivativeTotalDeposits,
            uint256 derivativeTotalWithdrawn
        )
    {
        ClientRecord memory clientRecord = _getClientRecordByAddress(depositor);
        return (
            clientRecord._address,
            clientRecord.underlyingTotalDeposits,
            clientRecord.underlyingTotalWithdrawn,
            clientRecord.derivativeBalance,
            clientRecord.derivativeTotalDeposits,
            clientRecord.derivativeTotalWithdrawn
        );
    }

    function getClientRecord()
        external
        view
        onlyNonDeprecatedCalls
        returns (
            address payable _address,
            uint256 underlyingTotalDeposits,
            uint256 underlyingTotalWithdrawn,
            uint256 derivativeBalance,
            uint256 derivativeTotalDeposits,
            uint256 derivativeTotalWithdrawn
        )
    {
        ClientRecord memory clientRecord = _getClientRecordByAddress(
            msg.sender
        );

        return (
            clientRecord._address,
            clientRecord.underlyingTotalDeposits,
            clientRecord.underlyingTotalWithdrawn,
            clientRecord.derivativeBalance,
            clientRecord.derivativeTotalDeposits,
            clientRecord.derivativeTotalWithdrawn
        );
    }

    function getClientRecordByIndex(uint256 index)
        external
        view
        onlyNonDeprecatedCalls
        returns (
            address payable _address,
            uint256 underlyingTotalDeposits,
            uint256 underlyingTotalWithdrawn,
            uint256 derivativeBalance,
            uint256 derivativeTotalDeposits,
            uint256 derivativeTotalWithdrawn
        )
    {
        ClientRecord memory clientRecord = _getClientRecordByIndex(index);
        return (
            clientRecord._address,
            clientRecord.underlyingTotalDeposits,
            clientRecord.underlyingTotalWithdrawn,
            clientRecord.derivativeBalance,
            clientRecord.derivativeTotalDeposits,
            clientRecord.derivativeTotalWithdrawn
        );
    }

    function _getClientRecordByIndex(uint256 index)
        internal
        view
        returns (ClientRecord memory)
    {
        (
            address payable _address,
            uint256 underlyingTotalDeposits,
            uint256 underlyingTotalWithdrawn,
            uint256 derivativeBalance,
            uint256 derivativeTotalDeposits,
            uint256 derivativeTotalWithdrawn
        ) = clientRecordStorage.getClientRecordByIndex(index);
        return
            ClientRecord(
                true,
                _address,
                underlyingTotalDeposits,
                underlyingTotalWithdrawn,
                derivativeBalance,
                derivativeTotalDeposits,
                derivativeTotalWithdrawn
            );
    }

    function _getClientRecordByAddress(address member)
        internal
        view
        returns (ClientRecord memory)
    {
        (
            address payable _address,
            uint256 underlyingTotalDeposits,
            uint256 underlyingTotalWithdrawn,
            uint256 derivativeBalance,
            uint256 derivativeTotalDeposits,
            uint256 derivativeTotalWithdrawn
        ) = clientRecordStorage.getClientRecordByAddress(member);

        return
            ClientRecord(
                true,
                _address,
                underlyingTotalDeposits,
                underlyingTotalWithdrawn,
                derivativeBalance,
                derivativeTotalDeposits,
                derivativeTotalWithdrawn
            );
    }
    
    function setMinimumLockPeriod (uint minimumLockPeriod) external onlyNonDeprecatedCalls onlyOwner {
        minLockPeriod = minimumLockPeriod;
    }
    
    function _getFixedDepositRecordById(uint recordId) internal returns (FixedDepositRecord memory) {
        (uint recordId, address payable depositorId, uint amount, uint depositDateInSeconds, uint lockPeriodInSeconds, bool hasWithdrawn) = clientRecordStorage.GetRecordById(recordId);
    }
    
   

    function withdraw(uint256 derivativeAmount)
        external
        onlyNonDeprecatedCalls
    {
      address payable recipient = msg.sender;
      
      _withdraw(recipient, derivativeAmount);
    }

    function withdrawDelegate(
        address payable recipient,
        uint256 derivativeAmount
    ) external onlyNonDeprecatedCalls onlyOwner {
        _withdraw(recipient, derivativeAmount);
    }
    
    function withdrawByShares(uint256 derivativeAmount) external {
        
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();
        
        fBusdToken.approve(FortubeBankAdapter, derivativeAmount);
        
        fortubeService.WithdrawBySharesOnly(derivativeAmount);
    }

    function _withdraw(address payable recipient, uint256 derivativeAmount)
        internal
    {
        _validateUserBalanceIsSufficient(recipient, derivativeAmount);

        uint256 balanceBeforeWithdraw = fortubeService.UserBUSDBalance(address(this));
        
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();

         bool isApprovalSuccessful = fBusdToken.approve(FortubeBankAdapter,derivativeAmount);
         
         require(isApprovalSuccessful == true, 'could not approve fbusd token for adapter contract');
        
         fortubeService.WithdrawBySharesOnly(derivativeAmount);

        uint256 balanceAfterWithdraw = fortubeService.UserBUSDBalance(address(this));

        require(balanceAfterWithdraw>balanceBeforeWithdraw, "Balance before needs to be greater than balance after");

        uint256 amountOfUnderlyingAssetWithdrawn =  balanceAfterWithdraw.sub(
            balanceBeforeWithdraw
        );
        

        uint256 commissionFees = _computeXendFinanceCommisions(
            amountOfUnderlyingAssetWithdrawn
        );

        require(amountOfUnderlyingAssetWithdrawn>commissionFees, "Amount to be withdrawn must be greater than commision fees");
        uint256 amountToSendToDepositor = amountOfUnderlyingAssetWithdrawn.sub(
            commissionFees
        );
            
        //busdToken.approve(recipient, amountToSendToDepositor);

        bool isSuccessful = busdToken.transfer(
            recipient,
            amountToSendToDepositor
        );

        require(isSuccessful == true, "Could not complete withdrawal");

        if (commissionFees > 0) {
            busdToken.approve(address(treasury), commissionFees);
            treasury.depositToken(address(busdToken));
        }

        ClientRecord memory clientRecord = _updateClientRecordAfterWithdrawal(
            recipient,
            amountOfUnderlyingAssetWithdrawn,
            derivativeAmount
        );
        _updateClientRecord(clientRecord);

        emit DerivativeAssetWithdrawn(
            recipient,
            amountOfUnderlyingAssetWithdrawn,
            derivativeAmount,
            clientRecord.derivativeBalance
        );
    }

    function _validateUserBalanceIsSufficient(
        address payable recipient,
        uint256 derivativeAmount
    ) internal view returns (uint256) {
        ClientRecord memory clientRecord = _getClientRecordByAddress(recipient);

        uint256 derivativeBalance = clientRecord.derivativeBalance;

        require(
            derivativeBalance >= derivativeAmount,
            "Withdrawal cannot be processe, reason: Insufficient Balance"
        );
    }
    
  
    
    function _validateLockTimeHasElapsedAndHasNotWithdrawn (uint256 recordId, uint256 derivativeAmount) internal {
        
     FixedDepositRecord memory depositRecord =
            _getFixedDepositRecordById(recordId);

        uint256 lockPeriod = depositRecord.lockPeriodInSeconds;
        uint256 maturityDate =
            depositRecord.depositDateInSeconds.add(lockPeriod);

        bool hasWithdrawn = depositRecord.hasWithdrawn;

        require(!hasWithdrawn, "Individual has already withdrawn");

        uint256 currentTimeStamp = now;

        require(
            currentTimeStamp >= maturityDate,
            "Funds are still locked, wait until lock period expires"
        );
    
    }

    function _computeXendFinanceCommisions(uint256 worthOfMemberDepositNow)
        internal
        returns (uint256)
    {
        uint256 dividend = _getDividend();
        uint256 divisor = _getDivisor();

        require(
            worthOfMemberDepositNow > 0,
            "member deposit really isn't worth much"
        );

        return worthOfMemberDepositNow.mul(dividend).div(divisor);
    }

    function _getDivisor() internal returns (uint256) {
        (
            uint256 minimumDivisor,
            uint256 maximumDivisor,
            uint256 exactDivisor,
            bool appliesDivisor,
            RuleDefinition ruleDefinitionDivisor
        ) = savingsConfig.getRuleSet(XEND_FINANCE_COMMISION_DIVISOR);

        require(
            appliesDivisor == true,
            "unsupported rule defintion for rule set"
        );

        require(
            ruleDefinitionDivisor == RuleDefinition.VALUE,
            "unsupported rule defintion for penalty percentage rule set"
        );
        return exactDivisor;
    }

    function _getDividend() internal returns (uint256) {
        (
            uint256 minimumDividend,
            uint256 maximumDividend,
            uint256 exactDividend,
            bool appliesDividend,
            RuleDefinition ruleDefinitionDividend
        ) = savingsConfig.getRuleSet(XEND_FINANCE_COMMISION_DIVIDEND);

        require(
            appliesDividend == true,
            "unsupported rule defintion for rule set"
        );

        require(
            ruleDefinitionDividend == RuleDefinition.VALUE,
            "unsupported rule defintion for penalty percentage rule set"
        );
        return exactDividend;
    }

    function deposit() external onlyNonDeprecatedCalls {
        address payable depositor = msg.sender;
        _deposit(depositor);
    }

    function depositDelegate(address payable depositorAddress)
        external
        onlyNonDeprecatedCalls
        onlyOwner
    {
        _deposit(depositorAddress);
    }
    
    function FixedDeposit(uint256 depositDateInSeconds, uint256 lockPeriodInSeconds) external onlyNonDeprecatedCalls {
        address payable depositorAddress = msg.sender;
        
        address recipient = address(this);
        
         uint256 amountTransferrable = busdToken.allowance(
            depositorAddress,
            recipient
        );
        
        require(lockPeriodInSeconds >= minLockPeriod, "Minimum lock period must be 3 months");

        require(
            amountTransferrable > 0,
            "Approve an amount > 0 for token before proceeding"
        );
        bool isSuccessful = busdToken.transferFrom(
            depositorAddress,
            recipient,
            amountTransferrable
        );
        require(
            isSuccessful == true,
            "Could not complete deposit process from token contract"
        );
       

        uint256 balanceBeforeDeposit = fortubeService.UserShares(address(this));
        
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();

         busdToken.approve(FortubeBankAdapter, amountTransferrable);

        fortubeService.Save(amountTransferrable);

        uint256 balanceAfterDeposit = fortubeService.UserShares(address(this));

        uint256 amountOfyDai = balanceAfterDeposit.sub(balanceBeforeDeposit);
        
        
    
        clientRecordStorage.CreateDepositRecordMapping(amountTransferrable,amountOfyDai, lockPeriodInSeconds, depositDateInSeconds, depositorAddress, false);
        
        clientRecordStorage.CreateDepositorToDepositRecordIndexToRecordIDMapping(depositorAddress, clientRecordStorage.GetRecordId());
        
        clientRecordStorage.CreateDepositorAddressToDepositRecordMapping(depositorAddress, clientRecordStorage.GetRecordId(), amountTransferrable,amountOfyDai, lockPeriodInSeconds, depositDateInSeconds, false);
            

      
        emit UnderlyingAssetDeposited(
            depositorAddress,
            amountTransferrable,
            amountOfyDai,
            amountTransferrable
        );
        
    }
    
    function WithdrawFromFixedDeposit (uint recordId, uint amount, uint256 depositDateInSeconds, uint256 lockPeriodInSeconds) external onlyNonDeprecatedCalls {
        
        address payable recipient = msg.sender;
        
         FixedDepositRecord memory depositRecord = _getFixedDepositRecordById(recordId);
          
         
          
          uint256 depositDate = depositDateInSeconds;
          
          uint256 lockPeriod = lockPeriodInSeconds;
          
           _validateLockTimeHasElapsedAndHasNotWithdrawn(recordId, amount);
           
           

        uint256 balanceBeforeWithdraw = fortubeService.UserBUSDBalance(address(this));
        
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();

         bool isApprovalSuccessful = fBusdToken.approve(FortubeBankAdapter,amount);
         
         require(isApprovalSuccessful == true, 'could not approve fbusd token for adapter contract');
        
         fortubeService.WithdrawBySharesOnly(amount);

        uint256 balanceAfterWithdraw = fortubeService.UserBUSDBalance(address(this));

        require(balanceAfterWithdraw>balanceBeforeWithdraw, "Balance after needs to be greater than balance before");

        uint256 amountOfUnderlyingAssetWithdrawn =  balanceAfterWithdraw.sub(
            balanceBeforeWithdraw
        );
        

        uint256 commissionFees = _computeXendFinanceCommisions(
            amountOfUnderlyingAssetWithdrawn
        );

        require(amountOfUnderlyingAssetWithdrawn>commissionFees, "Amount to be withdrawn must be greater than commision fees");
        
    
        uint256 amountToSendToDepositor = amountOfUnderlyingAssetWithdrawn.sub(
            commissionFees
        );
            
        //busdToken.approve(recipient, amountToSendToDepositor);

       busdToken.transfer(
            recipient,
            amountToSendToDepositor
        );

        if (commissionFees > 0) {
            busdToken.approve(address(treasury), commissionFees);
            treasury.depositToken(address(busdToken));
        }
       clientRecordStorage.UpdateDepositRecordMapping(recordId, amount,0, lockPeriod, depositDate, msg.sender, true);
       clientRecordStorage.CreateDepositorAddressToDepositRecordMapping(recipient, depositRecord.recordId, depositRecord.amount, 0,lockPeriod, depositDate, true);
    
        
        _rewardUserWithTokens(
        lockPeriod,
        amount,
        recipient
        );


        emit DerivativeAssetWithdrawnFromFixed(
            recipient,
            amountOfUnderlyingAssetWithdrawn,
            amount
        );
    }
    
   
    

    function _deposit(address payable depositorAddress) internal {
        address recipient = address(this);
        uint256 amountTransferrable = busdToken.allowance(
            depositorAddress,
            recipient
        );

        require(
            amountTransferrable > 0,
            "Approve an amount > 0 for token before proceeding"
        );
        bool isSuccessful = busdToken.transferFrom(
            depositorAddress,
            recipient,
            amountTransferrable
        );
        require(
            isSuccessful == true,
            "Could not complete deposit process from token contract"
        );

       

        uint256 balanceBeforeDeposit = fBusdToken.balanceOf(address(this));
        
        FortubeBankAdapter = fortubeService.GetForTubeAdapterAddress();

         busdToken.approve(FortubeBankAdapter, amountTransferrable);

        fortubeService.Save(amountTransferrable);

        uint256 balanceAfterDeposit = fBusdToken.balanceOf(address(this));

        uint256 amountOfyDai = balanceAfterDeposit.sub(balanceBeforeDeposit);
        ClientRecord memory clientRecord = _updateClientRecordAfterDeposit(
            depositorAddress,
            amountTransferrable,
            amountOfyDai
        );

        bool exists = clientRecordStorage.doesClientRecordExist(
            depositorAddress
        );

        if (exists) _updateClientRecord(clientRecord);
        else {
            clientRecordStorage.createClientRecord(
                clientRecord._address,
                clientRecord.underlyingTotalDeposits,
                clientRecord.underlyingTotalWithdrawn,
                clientRecord.derivativeBalance,
                clientRecord.derivativeTotalDeposits,
                clientRecord.derivativeTotalWithdrawn
            );
        }

        _updateTotalTokenDepositAmount(amountTransferrable);


        emit UnderlyingAssetDeposited(
            depositorAddress,
            amountTransferrable,
            amountOfyDai,
            clientRecord.derivativeBalance
        );
    }
     function _updateTotalTokenDepositAmount(uint256 amount) internal {
        groupStorage.incrementTokenDeposit(TokenAddress, amount);
    }

    function _updateClientRecordAfterDeposit(
        address payable client,
        uint256 underlyingAmountDeposited,
        uint256 derivativeAmountDeposited
    ) internal returns (ClientRecord memory) {
        bool exists = clientRecordStorage.doesClientRecordExist(client);
        if (!exists) {
            ClientRecord memory record = ClientRecord(
                true,
                client,
                underlyingAmountDeposited,
                0,
                derivativeAmountDeposited,
                derivativeAmountDeposited,
                0
            );

           
            return record;
        } else {
            ClientRecord memory record = _getClientRecordByAddress(client);

            record.underlyingTotalDeposits = record.underlyingTotalDeposits.add(
                underlyingAmountDeposited
            );
            record.derivativeTotalDeposits = record.derivativeTotalDeposits.add(
                derivativeAmountDeposited
            );
            record.derivativeBalance = record.derivativeBalance.add(
                derivativeAmountDeposited
            );

            return record;
        }
    }

    function _updateClientRecordAfterWithdrawal(
        address payable client,
        uint256 underlyingAmountWithdrawn,
        uint256 derivativeAmountWithdrawn
    ) internal returns (ClientRecord memory) {
        ClientRecord memory record = _getClientRecordByAddress(client);

        record.underlyingTotalWithdrawn = record.underlyingTotalWithdrawn.add(
            underlyingAmountWithdrawn
        );

        record.derivativeTotalWithdrawn = record.derivativeTotalWithdrawn.add(
            derivativeAmountWithdrawn
        );
        record.derivativeBalance = record.derivativeBalance.sub(
            derivativeAmountWithdrawn
        );

        return record;
    }
    
     function _emitXendTokenReward(address payable member, uint256 amount) internal {
    emit XendTokenReward(now, member, amount);
}

function _rewardUserWithTokens(
    uint256 totalLockPeriod,
    uint256 amountDeposited,
    address payable recipient
) internal {
    uint256 numberOfRewardTokens = rewardConfig
        .CalculateIndividualSavingsReward(
        totalLockPeriod,
        amountDeposited
    );

    if (numberOfRewardTokens > 0) {
        xendToken.mint(recipient, numberOfRewardTokens);
        _UpdateMemberToXendTokeRewardMapping(recipient,numberOfRewardTokens);
         //  increase the total number of xend token rewards distributed
            _totalTokenReward = _totalTokenReward.add(numberOfRewardTokens);
          _emitXendTokenReward(recipient, numberOfRewardTokens);

    }

}

    function _updateClientRecord(ClientRecord memory clientRecord) internal {
        clientRecordStorage.updateClientRecord(
            clientRecord._address,
            clientRecord.underlyingTotalDeposits,
            clientRecord.underlyingTotalWithdrawn,
            clientRecord.derivativeBalance,
            clientRecord.derivativeTotalDeposits,
            clientRecord.derivativeTotalWithdrawn
        );
    }

    modifier onlyNonDeprecatedCalls() {
        require(isDeprecated == false, "Service contract has been deprecated");
        _;
    }
}