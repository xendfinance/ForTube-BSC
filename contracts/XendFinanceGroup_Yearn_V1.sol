        // SPDX-License-Identifier: MIT
        
        pragma solidity ^0.6.6;
        import "./ISavingsConfig.sol";
        import "./ITreasury.sol";
        // import "./Ownable.sol";
        import "./IGroups.sol";
        import "./SafeERC20.sol";

        import "./ICycle.sol";
        import "./IGroupSchema.sol";
        import "./IForTubeBankService.sol";
        import "./IERC20.sol";
        import "./IFToken.sol";
        //import "./Address.sol";
        import "./IRewardConfig.sol";
        import "./SafeMath.sol";
        import "./IXendToken.sol";
        
        contract XendFinanceGroupContainer_Yearn_V1 is IGroupSchema {
        struct CycleDepositResult {
        Group group;
        Member member;
        GroupMember groupMember;
        CycleMember cycleMember;
        uint256 underlyingAmountDeposited;
        }
        
        struct WithdrawalResolution {
            uint256 amountToSendToMember;
            uint256 amountToSendToTreasury;
        }
         event GroupCreated(
                uint256 indexed groupId,
                address payable indexed groupCreator
            );
        
            event CycleCreated(
                uint256 indexed cycleId,
                uint256 maximumSlots,
                bool hasMaximumSlots,
                uint256 stakeAmount,
                uint256 expectedCycleStartTimeStamp,
                uint256 cycleDuration
            );
            
            event CycleStarted(
                uint256 indexed cycleId,
                uint256 cycleStartTimeStamp
                );
            
        event UnderlyingAssetDeposited(
            uint256 indexed cycleId,
            address payable indexed memberAddress,
            uint256 groupId,
            uint256 underlyingAmount,
            address indexed tokenAddress
        );
        
          event XendTokenReward (
                uint date,
                address payable indexed member,
                uint amount
            );
        
      
        
        
        
        IForTubeBankService forTubeBankService;
        IERC20 busdToken;
        IGroups groupStorage;
        ICycles cycleStorage;
        ITreasury treasury;
        ISavingsConfig savingsConfig;
        IRewardConfig rewardConfig;
        IXendToken xendToken;
        IFToken fbusdToken;
        
        address ForTubeBankAdapterAddress;
        address TokenAddress;
        address TreasuryAddress;
        
        string constant PERCENTAGE_PAYOUT_TO_USERS = "PERCENTAGE_PAYOUT_TO_USERS";
        string constant PERCENTAGE_AS_PENALTY = "PERCENTAGE_AS_PENALTY";
        
        string constant XEND_FINANCE_COMMISION_DIVISOR = "XEND_FINANCE_COMMISION_DIVISOR";
        string constant XEND_FINANCE_COMMISION_DIVIDEND = "XEND_FINANCE_COMMISION_DIVIDEND";
        
        bool isDeprecated = false;
        
        uint256 _groupCreatorRewardPercent;
        
        uint256 _totalTokenReward;      //  This tracks the total number of token rewards distributed on the individual savings
        
        uint256 _feePrecision = 10;
        
        modifier onlyNonDeprecatedCalls() {
            require(isDeprecated == false, "Service contract has been deprecated");
            _;
        }
        }
        
        contract XendFinanceCycleExternalClientHelpers is
        XendFinanceGroupContainer_Yearn_V1
        {
        function getCycleMemberByCycleId(
        uint256 _cycleId,
        uint256 indexerRecordLocation
        )
        external
        view
        returns (
        uint256 cycleId,
        uint256 groupId,
        address payable _address,
        uint256 totalLiquidityAsPenalty,
        uint256 numberOfCycleStakes,
        uint256 stakesClaimed,
        bool hasWithdrawn
        )
        {
        (bool exists, uint256 index) = cycleStorage
        .getRecordIndexForCycleMembersIndexerByDepositor(
        _cycleId,
        indexerRecordLocation
        );
        require(exists == true, "Index location record does not exist");
        return cycleStorage.getCycleMember(index);
        }
        
        
        
        function getCycleByGroup(uint256 _groupId, uint256 indexerRecordLocation)
            external
            view
            returns (
                uint256 id,
                uint256 groupId,
                uint256 numberOfDepositors,
                uint256 cycleStartTimeStamp,
                uint256 cycleDuration,
                uint256 maximumSlots,
                bool hasMaximumSlots,
                uint256 cycleStakeAmount,
                uint256 totalStakes,
                uint256 stakesClaimed,
                CycleStatus cycleStatus,
                uint256 stakesClaimedBeforeMaturity
            )
        {
            uint256 index = _getIndexLocation(_groupId, indexerRecordLocation);
            return cycleStorage.getCycleInfoByIndex(index);
        }
        
        function _getIndexLocation(uint256 _groupId, uint256 indexerRecordLocation)
            internal
            view
            returns (uint256)
        {
            (bool exists, uint256 index) = cycleStorage.getRecordIndexForGroupCycle(
                _groupId,
                indexerRecordLocation
            );
            require(exists == true, "Index location record does not exist");
            return index;
        }
        }
        
        contract XendFinanceGroupExternalClientHelpers is
        XendFinanceGroupContainer_Yearn_V1
        {
        function getGroupsByCreator(
        address groupCreator,
        uint256 indexRecordPosition
        )
        external
        view
        returns (
        uint256 groupId,
        string memory name,
        string memory symbol,
        address payable creatorAddress
        )
        {
        (bool exists, uint256 index) = groupStorage.getGroupForCreatorIndexer(
        groupCreator,
        indexRecordPosition
        );
        require(exists == true, "Index record location does not exist");
        return groupStorage.getGroupByIndex(index);
        }
        }
        
        contract XendFinanceGroupHelpers is XendFinanceGroupContainer_Yearn_V1 {
        function _updateGroup(Group memory group) internal {
        (
        uint256 id,
        string memory name,
        string memory symbol,
        address payable groupCreator
        ) = (group.id, group.name, group.symbol, group.creatorAddress);
        
            groupStorage.updateGroup(id, name, symbol, groupCreator);
        }
        
        function _getGroupById(uint256 _groupId)
            internal
            view
            returns (Group memory)
        {
            (
                uint256 groupId,
                string memory name,
                string memory symbol,
                address payable creatorAddress
            ) = groupStorage.getGroupById(_groupId);
        
            Group memory group = Group(true, groupId, name, symbol, creatorAddress);
            return group;
        }
        
        function _getGroupByIndex(uint256 index)
            internal
            view
            returns (Group memory)
        {
            (
                uint256 groupId,
                string memory name,
                string memory symbol,
                address payable creatorAddress
            ) = groupStorage.getGroupByIndex(index);
        
            Group memory group = Group(true, groupId, name, symbol, creatorAddress);
            return group;
        }
        
        function _getGroupIndex(uint256 groupId) internal view returns (uint256) {
            return groupStorage.getGroupIndex(groupId);
        }
        
        function _createMemberIfNotExist(address payable depositor)
            internal
            returns (Member memory)
        {
            Member memory member = _getMember(depositor, false);
            return member;
        }
        
        function _createGroupMemberIfNotExist(
            address payable depositor,
            uint256 groupId
        ) internal returns (GroupMember memory) {
            GroupMember memory groupMember = _getGroupMember(
                depositor,
                groupId,
                false
            );
            return groupMember;
        }
        
        function _getMember(address payable depositor, bool throwOnNotFound)
            internal
            returns (Member memory)
        {
            bool memberExists = groupStorage.doesMemberExist(depositor);
            if (throwOnNotFound) require(memberExists == true, "Member not found");
        
            if (!memberExists) {
                groupStorage.createMember(depositor);
            }
        
            return Member(true, depositor);
        }
        
        function _getGroupMember(
            address payable depositor,
            uint256 groupId,
            bool throwOnNotFound
        ) internal returns (GroupMember memory) {
            bool groupMemberExists = groupStorage.doesGroupMemberExist(
                groupId,
                depositor
            );
        
            if (throwOnNotFound)
                require(groupMemberExists == true, "Member not found");
        
            if (!groupMemberExists) {
                groupStorage.createGroupMember(groupId, depositor);
            }
        
            return GroupMember(true, depositor, groupId);
        }
        
        function _getGroup(uint256 groupId) internal view returns (Group memory) {
            return _getGroupById(groupId);
        }
        
        modifier onlyGroupCreator(uint256 groupId) {
            Group memory group = _getGroup(groupId);
        
            require(
                msg.sender == group.creatorAddress,
                "unauthorized access to contract"
            );
            _;
        }
        }
        
        contract XendFinanceCycleHelpers is XendFinanceGroupHelpers {
        using SafeMath for uint256;

        function _updateCycleMember(CycleMember memory cycleMember) internal {
            (
                uint256 cycleId,
                address payable depositor,
                uint256 totalLiquidityAsPenalty,
                uint256 numberOfCycleStakes,
                uint256 stakesClaimed,
                bool hasWithdrawn
            ) = (
                cycleMember.cycleId,
                cycleMember._address,
                cycleMember.totalLiquidityAsPenalty,
                cycleMember.numberOfCycleStakes,
                cycleMember.stakesClaimed,
                cycleMember.hasWithdrawn
            );
            cycleStorage.updateCycleMember(
                cycleId,
                depositor,
                totalLiquidityAsPenalty,
                numberOfCycleStakes,
                stakesClaimed,
                hasWithdrawn
            );
        }
        
        function _validateCycleCreationActionValid(
            uint256 groupId,
            uint256 maximumsSlots,
            bool hasMaximumSlots
        ) internal {
            bool doesGroupExist = groupStorage.doesGroupExist(groupId);
        
            require(doesGroupExist == true, "Group not found");
        
            if (hasMaximumSlots == true) {
                require(maximumsSlots > 0, "Maximum slot settings cannot be empty");
            }
        }
        
        function _getCycleGroup(uint256 cycleId)
            internal
            view
            returns (Group memory)
        {
            Cycle memory cycle = _getCycleById(cycleId);
        
            return _getGroupById(cycle.groupId);
        }
        
        function _getCycleById(uint256 cycleId)
            internal
            view
            returns (Cycle memory)
        {
            (
                uint256 id,
                uint256 groupId,
                uint256 numberOfDepositors,
                uint256 cycleStartTimeStamp,
                uint256 cycleDuration,
                uint256 maximumSlots,
                bool hasMaximumSlots,
                uint256 cycleStakeAmount,
                uint256 totalStakes,
                uint256 stakesClaimed,
                CycleStatus cycleStatus,
                uint256 stakesClaimedBeforeMaturity
            ) = cycleStorage.getCycleInfoById(cycleId);
        
            Cycle memory cycleInfo = Cycle(
                true,
                id,
                groupId,
                numberOfDepositors,
                cycleStartTimeStamp,
                cycleDuration,
                maximumSlots,
                hasMaximumSlots,
                cycleStakeAmount,
                totalStakes,
                stakesClaimed,
                cycleStatus,
                stakesClaimedBeforeMaturity
            );
        
            return cycleInfo;
        }
        
        function _getCycleByIndex(uint256 index)
            internal
            view
            returns (Cycle memory)
        {
            (
                uint256 id,
                uint256 groupId,
                uint256 numberOfDepositors,
                uint256 cycleStartTimeStamp,
                uint256 cycleDuration,
                uint256 maximumSlots,
                bool hasMaximumSlots,
                uint256 cycleStakeAmount,
                uint256 totalStakes,
                uint256 stakesClaimed,
                CycleStatus cycleStatus,
                uint256 stakesClaimedBeforeMaturity
            ) = cycleStorage.getCycleInfoByIndex(index);
        
            Cycle memory cycleInfo = Cycle(
                true,
                id,
                groupId,
                numberOfDepositors,
                cycleStartTimeStamp,
                cycleDuration,
                maximumSlots,
                hasMaximumSlots,
                cycleStakeAmount,
                totalStakes,
                stakesClaimed,
                cycleStatus,
                stakesClaimedBeforeMaturity
            );
        
            return cycleInfo;
        }
        
        function _getCycleFinancialByCycleId(uint256 cycleId)
            internal
            view
            returns (CycleFinancial memory)
        {
            (
                uint256 underlyingTotalDeposits,
                uint256 underlyingTotalWithdrawn,
                uint256 underlyingBalance,
                uint256 derivativeBalance,
                uint256 underylingBalanceClaimedBeforeMaturity,
                uint256 derivativeBalanceClaimedBeforeMaturity
            ) = cycleStorage.getCycleFinancialsByCycleId(cycleId);
        
            return
                CycleFinancial(
                    true,
                    cycleId,
                    underlyingTotalDeposits,
                    underlyingTotalWithdrawn,
                    underlyingBalance,
                    derivativeBalance,
                    underylingBalanceClaimedBeforeMaturity,
                    derivativeBalanceClaimedBeforeMaturity
                );
        }
        
        function _getCycleIndex(uint256 cycleId) internal view returns (uint256) {
            return cycleStorage.getCycleIndex(cycleId);
        }
        
        function _getCycleMemberIndex(
            uint256 cycleId,
            address payable memberAddress
        ) internal view returns (uint256) {
            return cycleStorage.getCycleMemberIndex(cycleId, memberAddress);
        }
        
        function _getCycleMember(address payable depositor, uint256 _cycleId)
            internal
            view
            returns (CycleMember memory)
        {
            bool cycleMemberExists = cycleStorage.doesCycleMemberExist(
                _cycleId,
                depositor
            );
        
            require(cycleMemberExists == true, "Cycle Member not found");
        
            uint256 index = _getCycleMemberIndex(_cycleId, depositor);
        
            CycleMember memory cycleMember = _getCycleMember(index);
            return cycleMember;
        }
        
        function _CreateCycleMember(CycleMember memory cycleMember)
            internal
            returns (CycleMember memory)
        {
            cycleStorage.createCycleMember(
                cycleMember.cycleId,
                cycleMember.groupId,
                cycleMember._address,
                cycleMember.totalLiquidityAsPenalty,
                cycleMember.numberOfCycleStakes,
                cycleMember.stakesClaimed,
                cycleMember.hasWithdrawn
            );
        }
        
        function getCycleMember(address payable _depositorAddress, uint256 _cycleId)
            external
            view
            returns (
                uint256 cycleId,
                uint256 groupId,
                address payable _address,
                uint256 totalLiquidityAsPenalty,
                uint256 numberOfCycleStakes,
                uint256 stakesClaimed,
                bool hasWithdrawn
            )
        {
            CycleMember memory cycleMember = _getCycleMember(
                _depositorAddress,
                _cycleId
            );
            return (
                cycleMember.cycleId,
                cycleMember.groupId,
                cycleMember._address,
                cycleMember.totalLiquidityAsPenalty,
                cycleMember.numberOfCycleStakes,
                cycleMember.stakesClaimed,
                cycleMember.hasWithdrawn
            );
        }
        
        function getCycleMember(uint256 index)
            external
            view
            returns (
                uint256 cycleId,
                uint256 groupId,
                address payable _address,
                uint256 totalLiquidityAsPenalty,
                uint256 numberOfCycleStakes,
                uint256 stakesClaimed,
                bool hasWithdrawn
            )
        {
            return cycleStorage.getCycleMember(index);
        }
        
        function _getCycleMember(uint256 index)
            internal
            view
            returns (CycleMember memory)
        {
            (
                uint256 cycleId,
                uint256 groupId,
                address payable _address,
                uint256 totalLiquidityAsPenalty,
                uint256 numberOfCycleStakes,
                uint256 stakesClaimed,
                bool hasWithdrawn
            ) = cycleStorage.getCycleMember(index);
        
            return
                CycleMember(
                    true,
                    cycleId,
                    groupId,
                    _address,
                    totalLiquidityAsPenalty,
                    numberOfCycleStakes,
                    stakesClaimed,
                    hasWithdrawn
                );
        }
        
        function _startCycle(Cycle memory cycle) internal {
            cycle.cycleStatus = CycleStatus.ONGOING;
            _updateCycle(cycle);
        }
        
        function _endCycle(Cycle memory cycle) internal {
            cycle.cycleStatus = CycleStatus.ENDED;
            _updateCycle(cycle);
        }
        
        function _updateCycle(Cycle memory cycle) internal {
            cycleStorage.updateCycle(
                cycle.id,
                cycle.numberOfDepositors,
                cycle.cycleStartTimeStamp,
                cycle.cycleDuration,
                cycle.maximumSlots,
                cycle.hasMaximumSlots,
                cycle.cycleStakeAmount,
                cycle.totalStakes,
                cycle.stakesClaimed,
                cycle.cycleStatus,
                cycle.stakesClaimedBeforeMaturity
            );
        }
        
        function getAllowanceForBusd() external view returns (uint){
            return _getAllowanceForBusd();
        }
        
        
        
        function _lendCycleDeposit(uint allowance,uint amountToDeductFromClient)
            internal
            returns (uint256)
        {
          require(allowance>=amountToDeductFromClient,"Approve an amount to cover for stake purchase [1]");
          
        
          bool isSuccessful = busdToken.transferFrom(msg.sender, address(this), amountToDeductFromClient);
          
          require(isSuccessful==true,"Could not transfer tokens to contract");
         
        
          isSuccessful = busdToken.approve(forTubeBankService.GetForTubeAdapterAddress(), amountToDeductFromClient);
        
          uint256 balanceBeforeDeposit = fbusdToken.balanceOf(address(this));
        
        
          forTubeBankService.Save(amountToDeductFromClient);
        
          uint256 balanceAfterDeposit = fbusdToken.balanceOf(address(this));
        
          uint256 amountOfyDai = balanceAfterDeposit.sub(balanceBeforeDeposit);
        
          return amountOfyDai;
        
        }
        
        function _getAllowanceForBusd() internal view returns (uint){
            address recipient = address(this);
            uint256 amountDepositedByUser = busdToken.allowance(msg.sender, recipient);
            require(amountDepositedByUser>0, "Approve an amount to cover for stake purchase [0]");
        
            return amountDepositedByUser;
        }
        
        
        // function uintToStr(uint _i) internal pure returns (string memory _uintAsString) {
        //         uint number = _i;
        //         if (number == 0) {
        //             return "0";
        //         }
        //         uint j = number;
        //         uint len;
        //         while (j != 0) {
        //             len++;
        //             j /= 10;
        //         }
        //         bytes memory bstr = new bytes(len);
        //         uint k = len - 1;
        //         while (number != 0) {
        //             bstr[k--] = byte(uint8(48 + number % 10));
        //             number /= 10;
        //         }
        //         return string(bstr);
        //     }
        
        
        
        
        function _updateCycleFinancials(CycleFinancial memory cycleFinancial)
            internal
        {
            cycleStorage.updateCycleFinancials(
                cycleFinancial.cycleId,
                cycleFinancial.underlyingTotalDeposits,
                cycleFinancial.underlyingTotalWithdrawn,
                cycleFinancial.underlyingBalance,
                cycleFinancial.derivativeBalance,
                cycleFinancial.underylingBalanceClaimedBeforeMaturity,
                cycleFinancial.derivativeBalanceClaimedBeforeMaturity
            );
        }
        
        function getAmountToBillClient(uint cycleId,uint numberOfStakes) external view returns (uint){
            Cycle memory cycle = _getCycleById(cycleId);
            
            uint amountToDeductFromClient = cycle.cycleStakeAmount.mul(numberOfStakes);
            return amountToDeductFromClient;
        
        }
        
        function _joinCycle(
            uint256 cycleId,
            uint256 numberOfStakes,
            uint allowance,
            address payable depositorAddress
        ) internal {
            require(numberOfStakes > 0, "Minimum stakes that can be acquired is 1");
        
            Group memory group = _getCycleGroup(cycleId);
            Cycle memory cycle = _getCycleById(cycleId);
            CycleFinancial memory cycleFinancial = _getCycleFinancialByCycleId(
                cycleId
            );
        
            bool didCycleMemberExistBeforeNow = cycleStorage.doesCycleMemberExist(
                cycleId,
                depositorAddress
            );
            
            bool didGroupMemberExistBeforeNow = groupStorage.doesGroupMemberExist(
                group.id,
                depositorAddress
            );
        
            _validateCycleDepositCriteriaAreMet(
                cycle,
                didCycleMemberExistBeforeNow
            );
            
            uint amountToDeductFromClient = cycle.cycleStakeAmount.mul(numberOfStakes);
        
            CycleDepositResult memory result = _addDepositorToCycle(
                cycleId,
                cycle.cycleStakeAmount,
                numberOfStakes,
                amountToDeductFromClient,
                depositorAddress
            );
            
            
        
            uint256 derivativeAmount = _lendCycleDeposit(allowance,amountToDeductFromClient);
        
        
            cycle = _updateCycleStakeDeposit(cycle, cycleFinancial, numberOfStakes);
        
        
            cycleFinancial.derivativeBalance = cycleFinancial.derivativeBalance.add(
                derivativeAmount
            );
        
             _updateCycleFinancials(cycleFinancial);
        
            emit UnderlyingAssetDeposited(
                cycle.id,
                depositorAddress,
                result.group.id,
                result.underlyingAmountDeposited,
                TokenAddress
            );
        
            if (!didCycleMemberExistBeforeNow) {
                cycle.numberOfDepositors = cycle.numberOfDepositors.add(1);
        
            }
        
            if (!didGroupMemberExistBeforeNow) {
            }
        
            _updateCycle(cycle);
        }
        
        function _updateCycleStakeDeposit(
            Cycle memory cycle,
            CycleFinancial memory cycleFinancial,
            uint256 numberOfCycleStakes
        ) internal returns (Cycle memory) {
            cycle.totalStakes = cycle.totalStakes.add(numberOfCycleStakes);
        
            uint256 depositAmount = cycle.cycleStakeAmount.mul(numberOfCycleStakes);
            cycleFinancial.underlyingTotalDeposits = cycleFinancial
                .underlyingTotalDeposits
                .add(depositAmount);
            _updateCycleFinancials(cycleFinancial);
            _updateTotalTokenDepositAmount(depositAmount);
            return cycle;
        }
        
        function _updateTotalTokenDepositAmount(uint256 amount) internal {
            groupStorage.incrementTokenDeposit(TokenAddress, amount);
        }
        
        function _validateCycleDepositCriteriaAreMet(
            Cycle memory cycle,
            bool didCycleMemberExistBeforeNow
        ) internal view {
            bool hasMaximumSlots = cycle.hasMaximumSlots;
            if (hasMaximumSlots == true && didCycleMemberExistBeforeNow == false) {
                require(
                    cycle.numberOfDepositors < cycle.maximumSlots,
                    "Maximum slot for depositors has been reached"
                );
            }
        
            require(
                cycle.cycleStatus == CycleStatus.NOT_STARTED,
                "This cycle is not accepting deposits anymore"
            );
        }
        
        function _addDepositorToCycle(
            uint256 cycleId,
            uint256 cycleAmountForStake,
            uint256 numberOfStakes,
            uint256 amountToDeductFromClient,
            address payable depositorAddress
        ) internal returns (CycleDepositResult memory) {
            Group memory group = _getCycleGroup(cycleId);
        
            Member memory member = _createMemberIfNotExist(depositorAddress);
            GroupMember memory groupMember = _createGroupMemberIfNotExist(
                depositorAddress,
                group.id
            );
        
            bool doesCycleMemberExist = cycleStorage.doesCycleMemberExist(
                cycleId,
                depositorAddress
            );
        
            CycleMember memory cycleMember = CycleMember(
                true,
                cycleId,
                group.id,
                depositorAddress,
                0,
                0,
                0,
                false
            );
        
            if (doesCycleMemberExist) {
                cycleMember = _getCycleMember(depositorAddress, cycleId);
            }
        
            uint256 underlyingAmount = amountToDeductFromClient;
        
            cycleMember = _saveMemberDeposit(
                doesCycleMemberExist,
                cycleMember,
                numberOfStakes
            );
        
            CycleDepositResult memory result = CycleDepositResult(
                group,
                member,
                groupMember,
                cycleMember,
                underlyingAmount
            );
        
            return result;
        }
        
        function _saveMemberDeposit(
            bool didCycleMemberExistBeforeNow,
            CycleMember memory cycleMember,
            uint256 numberOfCycleStakes
        ) internal returns (CycleMember memory) {
            cycleMember.numberOfCycleStakes = cycleMember.numberOfCycleStakes.add(
                numberOfCycleStakes
            );
        
            if (didCycleMemberExistBeforeNow == true)
                _updateCycleMember(cycleMember);
            else _CreateCycleMember(cycleMember);
        
            return cycleMember;
        }
        
        // function _processMemberDeposit(
        //     uint256 numberOfStakes,
        //     uint256 amountForStake,
        //     address payable depositorAddress
        // ) internal returns (uint256 underlyingAmount) {
        //     uint256 expectedAmount = numberOfStakes.mul(amountForStake);
        
        //     address recipient = address(this);
        //     uint256 amountTransferrable = busdToken.allowance(
        //         depositorAddress,
        //         recipient
        //     );
        
        //     require(
        //         amountTransferrable > 0,
        //         "Approve an amount > 0 for token before proceeding"
        //     );
        //     require(
        //         amountTransferrable >= expectedAmount,
        //         "Token allowance does not cover stake claim"
        //     );
        
        //     bool isSuccessful = busdToken.transferFrom(
        //         depositorAddress,
        //         recipient,
        //         expectedAmount
        //     );
        //     require(
        //         isSuccessful == true,
        //         "Could not complete deposit process from token contract"
        //     );
        
        //     return expectedAmount;
        // }
        
        function _endCycle(uint256 cycleId)
            internal
            returns (Cycle memory, CycleFinancial memory)
        {
            bool isCycleReadyToBeEnded = _isCycleReadyToBeEnded(cycleId);
            require(isCycleReadyToBeEnded == true, "Cycle is still ongoing");
        
            Cycle memory cycle = _getCycleById(cycleId);
            CycleFinancial memory cycleFinancial = _getCycleFinancialByCycleId(
                cycleId
            );
        
            uint256 derivativeBalanceToWithdraw = cycleFinancial.derivativeBalance -
                cycleFinancial.derivativeBalanceClaimedBeforeMaturity;
                
                //ForTubeBankAdapterAddress = forTubeBankService.GetForTubeAdapterAddress();
        
            fbusdToken.approve(
                ForTubeBankAdapterAddress,
                derivativeBalanceToWithdraw
            );
        
            uint256 underlyingAmount = _redeemLending(derivativeBalanceToWithdraw);
        
            cycleFinancial.underlyingBalance = cycleFinancial.underlyingBalance.add(
                underlyingAmount
            );
        
            cycle.cycleStatus = CycleStatus.ENDED;
        
            return (cycle, cycleFinancial);
        }
        
        function _isCycleReadyToBeEnded(uint256 cycleId)
            internal
            view
            returns (bool)
        {
            Cycle memory cycle = _getCycleById(cycleId);
        
            if (cycle.cycleStatus != CycleStatus.ONGOING) return false;
        
            uint256 currentTimeStamp = now;
            uint256 cycleEndTimeStamp = cycle.cycleStartTimeStamp +
                cycle.cycleDuration;
        
            if (currentTimeStamp >= cycleEndTimeStamp) return true;
            else return false;
        }
        
        function _redeemLending(uint256 derivativeBalance)
            internal
            returns (uint256)
        {
            require(derivativeBalance>0,"Derivative balance must be greater than 0");
            
            uint256 balanceBeforeWithdraw = forTubeBankService.UserBUSDBalance(address(this));
            
           // ForTubeBankAdapterAddress = forTubeBankService.GetForTubeAdapterAddress();
            
            bool isSuccessful = fbusdToken.approve(ForTubeBankAdapterAddress,derivativeBalance);
            
            require(isSuccessful==true,"Approval for withdrawal failed");
            
            forTubeBankService.WithdrawBySharesOnly(derivativeBalance);
        
            uint256 balanceAfterWithdraw = forTubeBankService.UserBUSDBalance(address(this));
        
            uint256 amountOfUnderlyingAssetWithdrawn = balanceAfterWithdraw.sub(
                balanceBeforeWithdraw
            );
        
            return amountOfUnderlyingAssetWithdrawn;
           
         
        }
        
        modifier onlyCycleCreator(uint256 cycleId) {
            Group memory group = _getCycleGroup(cycleId);
        
            bool isCreatorOrMember = (msg.sender == group.creatorAddress);
        
            if (isCreatorOrMember == false) {
                uint256 index = _getCycleMemberIndex(cycleId, msg.sender);
                CycleMember memory cycleMember = _getCycleMember(index);
        
                isCreatorOrMember = (cycleMember._address == msg.sender);
            }
        
            require(isCreatorOrMember == true, "unauthorized access to contract");
            _;
        }
        }
        
        contract XendFinanceGroup_Yearn_V1 is
        XendFinanceGroupExternalClientHelpers,
        XendFinanceCycleExternalClientHelpers,
        XendFinanceCycleHelpers,
        ISavingsConfigSchema,
        Ownable
        {
        using SafeMath for uint256;
        using SafeERC20 for IERC20;
        using SafeERC20 for IFToken;


        
        using Address for address payable;
        
        constructor(
            address forTubeBankServiceAddress,
            address tokenAddress,
            address groupStorageAddress,
            address cycleStorageAddress,
            address treasuryAddress,
            address savingsConfigAddress,
            address rewardConfigAddress,
            address xendTokenAddress,
            address derivativeTokenAddress
        ) public {
            forTubeBankService = IForTubeBankService(forTubeBankServiceAddress);
            busdToken = IERC20(tokenAddress);
            groupStorage = IGroups(groupStorageAddress);
            cycleStorage = ICycles(cycleStorageAddress);
            treasury = ITreasury(treasuryAddress);
            savingsConfig = ISavingsConfig(savingsConfigAddress);
            rewardConfig = IRewardConfig(rewardConfigAddress);
            xendToken = IXendToken(xendTokenAddress);
            fbusdToken = IFToken(derivativeTokenAddress);
            TokenAddress = tokenAddress;
            TreasuryAddress = treasuryAddress;
        }
        
         

       function GetTotalTokenRewardDistributed() external view returns(uint256){
            return _totalTokenReward;
        }
        
        function setGroupCreatorRewardPercent (uint percent) external onlyOwner {
            _groupCreatorRewardPercent = percent;
            
        }
        
            function UpdateFeePrecision(uint256 feePrecision) onlyOwner external{
            _feePrecision = feePrecision;
        }
        
        function setAdapterAddress() onlyOwner external {
            ForTubeBankAdapterAddress = forTubeBankService.GetForTubeAdapterAddress();
        }
        
        function withdrawFromCycleWhileItIsOngoing(uint256 cycleId)
            external
            onlyNonDeprecatedCalls
        {
            address payable memberAddress = msg.sender;
            _withdrawFromCycleWhileItIsOngoing(cycleId, memberAddress);
        }
        
        function _withdrawFromCycleWhileItIsOngoing(
            uint256 cycleId,
            address payable memberAddress
        ) internal {
            bool isCycleReadyToBeEnded = _isCycleReadyToBeEnded(cycleId);
        
            require(
                isCycleReadyToBeEnded == false,
                "Cycle has already ended, use normal withdrawl route"
            );
        
            Cycle memory cycle = _getCycleById(cycleId);
            CycleFinancial memory cycleFinancial = _getCycleFinancialByCycleId(
                cycleId
            );
            bool memberExistInCycle = cycleStorage.doesCycleMemberExist(
                cycleId,
                memberAddress
            );
        
            require(
                memberExistInCycle == true,
                "You are not a member of this cycle"
            );
        
            uint256 index = _getCycleMemberIndex(cycle.id, memberAddress);
        
            CycleMember memory cycleMember = _getCycleMember(index);
        
            require(
                cycleMember.hasWithdrawn == false,
                "Funds have already been withdrawn"
            );
        
            //uint256 numberOfStakesByMember = cycleMember.numberOfCycleStakes;
            //uint256 pricePerFullShare = lendingService.getPricePerFullShare();
        
            // get's the worth of one stake of the cycle in the derivative amount e.g yDAI
            uint256 derivativeAmountForStake = cycleFinancial.derivativeBalance.div(
                cycle.totalStakes
            );
        
            //get's how much of a crypto asset the user has deposited. e.g yDAI
            uint256 derivativeBalanceForMember = derivativeAmountForStake.mul(
                cycleMember.numberOfCycleStakes
            );
            
            uint outstandingStakesBalance = cycleMember.numberOfCycleStakes - cycleMember.stakesClaimed;
        
           
            //get's the crypto equivalent of a members derivative balance. Crytpo here refers to DAI. this is gotten after the user's ydai balance has been converted to dai
            uint256 underlyingAmountThatMemberDepositIsWorth = cycleFinancial.underlyingBalance.div(outstandingStakesBalance);
            
            //members capital
            
            //get member cycle stake and multiply it by stake amount 
            
           
            
            //uint256 membersDeposit = cycleFinancial.derivativeBalance.div(cycle.numberOfDepositors);
        
            uint256 initialUnderlyingDepositByMember = cycleMember.numberOfCycleStakes.mul(
                cycle.cycleStakeAmount
            );
        
            //deduct charges for early withdrawal
            uint256 amountToChargeAsPenalites = _computeAmountToChargeAsPenalites(
                underlyingAmountThatMemberDepositIsWorth
            );
            
            
        
            //deduct xend finance fees
            // uint256 amountToChargeAsFees = _computeXendFinanceCommisions(
            //     underlyingAmountThatMemberDepositIsWorth
            // );
        
           
            underlyingAmountThatMemberDepositIsWorth -= amountToChargeAsPenalites;
        
        
                WithdrawalResolution memory withdrawalResolution
             = _computeAmountToSendToParties(
                initialUnderlyingDepositByMember,
                underlyingAmountThatMemberDepositIsWorth
            );
        
            withdrawalResolution.amountToSendToTreasury = withdrawalResolution
                .amountToSendToTreasury
                .add(amountToChargeAsPenalites);
        
            if (withdrawalResolution.amountToSendToTreasury > 0) {
                busdToken.approve(
                    TreasuryAddress,
                    withdrawalResolution.amountToSendToTreasury
                );
                treasury.depositToken(TokenAddress);
            }
        
            require(
                withdrawalResolution.amountToSendToMember > 0,
                "After deducting early withdrawal penalties and fees, there's nothing left for you"
            );
            if (withdrawalResolution.amountToSendToMember > 0) {
                busdToken.transfer(
                    cycleMember._address,
                    withdrawalResolution.amountToSendToMember
                );
            }
        
            uint256 totalUnderlyingAmountSentOut = withdrawalResolution
                .amountToSendToTreasury + withdrawalResolution.amountToSendToMember;
        
            cycle.stakesClaimedBeforeMaturity += cycleMember.numberOfCycleStakes;
            cycleFinancial
                .underylingBalanceClaimedBeforeMaturity += totalUnderlyingAmountSentOut;
            cycleFinancial
                .derivativeBalanceClaimedBeforeMaturity += derivativeBalanceForMember;
        
            cycleMember.hasWithdrawn = true;
            cycleMember.stakesClaimed += cycleMember.numberOfCycleStakes;
        
            _updateCycle(cycle);
            _updateCycleMember(cycleMember);
            _updateCycleFinancials(cycleFinancial);
        }
        
        function getDerivativeAmountForUserStake(
            uint256 cycleId,
            address payable memberAddress
        ) external view returns (uint256) {
            Cycle memory cycle = _getCycleById(cycleId);
            CycleFinancial memory cycleFinancial = _getCycleFinancialByCycleId(
                cycleId
            );
            bool memberExistInCycle = cycleStorage.doesCycleMemberExist(
                cycleId,
                memberAddress
            );
        
            require(
                memberExistInCycle == true,
                "You are not a member of this cycle"
            );
        
            uint256 index = _getCycleMemberIndex(cycle.id, memberAddress);
        
            CycleMember memory cycleMember = _getCycleMember(index);
        
            uint256 numberOfStakesByMember = cycleMember.numberOfCycleStakes;
        
            // get's the worth of one stake of the cycle in the derivative amount e.g yDAI
            uint256 derivativeAmountForStake = cycleFinancial.derivativeBalance.div(
                cycle.totalStakes
            );
        
            //get's how much of a crypto asset the user has deposited. e.g yDAI
            uint256 derivativeBalanceForMember = derivativeAmountForStake.mul(
                numberOfStakesByMember
            );
            return derivativeBalanceForMember;
        }
        
        function withdrawFromCycle(uint256 cycleId, uint256 groupId)
            external
            onlyNonDeprecatedCalls
        {
            address payable memberAddress = msg.sender;
            uint256 amountToSendToMember = _withdrawFromCycle(
                cycleId,
                memberAddress
            );
          
        }
        
        function withdrawFromCycle(uint256 cycleId, address payable memberAddress, uint256 groupId)
            external
            onlyNonDeprecatedCalls
        {
            uint256 amountToSendToMember = _withdrawFromCycle(
                cycleId,
                memberAddress
            );
        
          
        }
        
        
    
        
        function _withdrawFromCycle(uint256 cycleId, address payable memberAddress)
            internal
            returns (uint256 amountToSendToMember)
        {
            Cycle memory cycle;
            CycleFinancial memory cycleFinancial;
        
            if (_isCycleReadyToBeEnded(cycleId)) {
                (cycle, cycleFinancial) = _endCycle(cycleId);
            } else {
                cycle = _getCycleById(cycleId);
                cycleFinancial = _getCycleFinancialByCycleId(cycleId);
            }
        
          bool memberExistInCycle = cycleStorage.doesCycleMemberExist(
                cycleId,
                memberAddress
            );
        
            require(
                memberExistInCycle == true,
                "You are not a member of this cycle"
            );
        
            uint256 index = _getCycleMemberIndex(cycleId, memberAddress);
            CycleMember memory cycleMember = _getCycleMember(index);
        
            require(
                cycleMember.hasWithdrawn == false,
                "Funds have already been withdrawn"
            );
        
            //how many stakes a cycle member has
            uint256 stakesHoldings = cycleMember.numberOfCycleStakes;
        
            //getting the underlying asset amount that backs 1 stake amount
            uint256 totalStakesLeftWhenTheCycleEnded = cycle.totalStakes -
                cycle.stakesClaimedBeforeMaturity;
            uint256 underlyingAssetForStake = cycleFinancial.underlyingBalance.div(
                totalStakesLeftWhenTheCycleEnded
            );
        
            //cycle members stake amount current worth
        
        
                uint256 underlyingAmountThatMemberDepositIsWorth
             = underlyingAssetForStake.mul(stakesHoldings);
        
            uint256 initialUnderlyingDepositByMember = stakesHoldings.mul(
                cycle.cycleStakeAmount
            );
        
           
        
            //deduct xend finance fees
            uint256 amountToChargeAsFees = _computeXendFinanceCommisions(
                underlyingAmountThatMemberDepositIsWorth
            );
         uint256 creatorReward =  amountToChargeAsFees.mul(_groupCreatorRewardPercent).div(_feePrecision.mul(100));
         
         uint256 finalAmountToChargeAsPenalties = amountToChargeAsFees.sub(creatorReward);
         
            underlyingAmountThatMemberDepositIsWorth = underlyingAmountThatMemberDepositIsWorth
                .sub(finalAmountToChargeAsPenalties.add(creatorReward));
        
        
                WithdrawalResolution memory withdrawalResolution
             = _computeAmountToSendToParties(
                initialUnderlyingDepositByMember,
                underlyingAmountThatMemberDepositIsWorth
            );
        
            withdrawalResolution.amountToSendToTreasury = withdrawalResolution
                .amountToSendToTreasury
                .add(finalAmountToChargeAsPenalties);
        
            if (withdrawalResolution.amountToSendToTreasury > 0) {
                busdToken.approve(
                    TreasuryAddress,
                    withdrawalResolution.amountToSendToTreasury
                );
                treasury.depositToken(TokenAddress);
                
                 busdToken.transfer(_getGroupCreator(cycleMember.groupId), creatorReward);
            }
        
            if (withdrawalResolution.amountToSendToMember > 0) {
                busdToken.transfer(
                    cycleMember._address,
                    withdrawalResolution.amountToSendToMember
                );
            }
        
            uint256 totalUnderlyingAmountSentOut = withdrawalResolution
                .amountToSendToTreasury + withdrawalResolution.amountToSendToMember;
        
            cycle.stakesClaimed += stakesHoldings;
            cycleFinancial.underlyingTotalWithdrawn += totalUnderlyingAmountSentOut;
        
            cycleMember.hasWithdrawn = true;
            cycleMember.stakesClaimed += stakesHoldings;
          //  uint256 amountDeposited = cycle.cycleStakeAmount.mul(stakesHoldings);
            
            _rewardUserWithTokens(
                cycle.cycleDuration,
                initialUnderlyingDepositByMember,
                cycleMember._address
            );
        
            _updateCycle(cycle);
            _updateCycleFinancials(cycleFinancial);
            _updateCycleMember(cycleMember);
        
            return withdrawalResolution.amountToSendToMember;
        }
          function _getGroupCreator(uint256 groupId) internal returns (address) {
          Group memory group = _getGroup(groupId);

        address groupCreator = group.creatorAddress;

        return groupCreator;
    }
        function deprecateContract(address newServiceAddress)
            external
            onlyOwner
            onlyNonDeprecatedCalls
        {
            isDeprecated = true;
            groupStorage.reAssignStorageOracle(newServiceAddress);
            cycleStorage.reAssignStorageOracle(newServiceAddress);
            uint256 derivativeTokenBalance = fbusdToken.balanceOf(
                address(this)
            );
            fbusdToken.transfer(newServiceAddress, derivativeTokenBalance);
            busdToken.safeTransfer(newServiceAddress, busdToken.balanceOf(address(this)));

        }
        
         function _emitXendTokenReward(address payable member, uint256 amount) internal {
            emit XendTokenReward(now, member, amount);
        }
        
        function _rewardUserWithTokens(
            uint256 totalCycleTimeInSeconds,
            uint256 amountDeposited,
            address payable cycleMemberAddress
        ) internal {
            uint256 numberOfRewardTokens = rewardConfig
                .CalculateCooperativeSavingsReward(
                totalCycleTimeInSeconds,
                amountDeposited
            );
            
           
        
            if (numberOfRewardTokens > 0) {
                 
                xendToken.mint(cycleMemberAddress, numberOfRewardTokens);
                
                 groupStorage.setXendTokensReward(cycleMemberAddress, numberOfRewardTokens);
                 
                  _emitXendTokenReward(cycleMemberAddress, numberOfRewardTokens);
        
            }
        
        }
        
        function _computeAmountToChargeAsPenalites(uint256 worthOfMemberDepositNow)
            internal
            returns (uint256)
        {
            (
                uint256 minimum,
                uint256 maximum,
                uint256 exact,
                bool applies,
                RuleDefinition ruleDefinition
            ) = savingsConfig.getRuleSet(PERCENTAGE_AS_PENALTY);
        
            require(applies == true, "unsupported rule defintion for rule set");
        
            require(
                ruleDefinition == RuleDefinition.VALUE,
                "unsupported rule defintion for penalty percentage rule set"
            );
        
            require(
                worthOfMemberDepositNow > 0,
                "member deposit really isn't worth much"
            );
        
            uint256 amountToChargeAsPenalites = worthOfMemberDepositNow
                .mul(exact)
                .div(100);
            return amountToChargeAsPenalites;
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
        
        //Determines how much we send to the treasury and how much we send to the member
        function _computeAmountToSendToParties(
            uint256 totalUnderlyingAmountMemberDeposited,
            uint256 worthOfMemberDepositNow
        ) internal returns (WithdrawalResolution memory) {
            (
                uint256 minimum,
                uint256 maximum,
                uint256 exact,
                bool applies,
                RuleDefinition ruleDefinition
            ) = savingsConfig.getRuleSet(PERCENTAGE_PAYOUT_TO_USERS);
        
            require(applies == true, "unsupported rule defintion for rule set");
        
            require(
                ruleDefinition == RuleDefinition.VALUE,
                "unsupported rule defintion for payout  percentage rule set"
            );
        
            //ensures we send what the user's investment is currently worth when his original deposit did not appreciate in value
            if (totalUnderlyingAmountMemberDeposited >= worthOfMemberDepositNow) {
                return WithdrawalResolution(worthOfMemberDepositNow, 0);
            } else {
        
                    uint256 maxAmountUserCanBePaid
                 = _getMaxAmountUserCanBePaidConsideringInterestLimit(
                    exact,
                    totalUnderlyingAmountMemberDeposited
                );
        
                if (worthOfMemberDepositNow > maxAmountUserCanBePaid) {
                    uint256 amountToSendToTreasury = worthOfMemberDepositNow.sub(
                        maxAmountUserCanBePaid
                    );
                    return
                        WithdrawalResolution(
                            maxAmountUserCanBePaid,
                            amountToSendToTreasury
                        );
                } else {
                    return WithdrawalResolution(worthOfMemberDepositNow, 0);
                }
            }
        }
        
        function _getMaxAmountUserCanBePaidConsideringInterestLimit(
            uint256 maxPayoutPercentage,
            uint256 totalUnderlyingAmountMemberDeposited
        ) internal returns (uint256) {
            uint256 percentageConsideration = 100 + maxPayoutPercentage;
            return
                totalUnderlyingAmountMemberDeposited
                    .mul(percentageConsideration)
                    .div(100);
        }
        
        function getRecordIndexLengthForCycleMembers(uint256 cycleId)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            return cycleStorage.getRecordIndexLengthForCycleMembers(cycleId);
        }
        
        function getRecordIndexLengthForCycleMembersByDepositor(
            address depositorAddress
        ) external view onlyNonDeprecatedCalls returns (uint256) {
            return
                cycleStorage.getRecordIndexLengthForCycleMembersByDepositor(
                    depositorAddress
                );
        }
        
        function getRecordIndexLengthForGroupMembers(uint256 groupId)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            return groupStorage.getRecordIndexLengthForGroupMembersIndexer(groupId);
        }
        
        function getRecordIndexLengthForGroupMembersByDepositor(
            address depositorAddress
        ) external view onlyNonDeprecatedCalls returns (uint256) {
            return
                groupStorage.getRecordIndexLengthForGroupMembersIndexerByDepositor(
                    depositorAddress
                );
        }
        
        function getRecordIndexLengthForGroupCycles(uint256 groupId)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            return cycleStorage.getRecordIndexLengthForGroupCycleIndexer(groupId);
        }
        
        function getRecordIndexLengthForCreator(address groupCreator)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            return groupStorage.getRecordIndexLengthForCreator(groupCreator);
        }
        
        function getSecondsLeftForCycleToEnd(uint256 cycleId)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            Cycle memory cycle = _getCycleById(cycleId);
            require(cycle.cycleStatus == CycleStatus.ONGOING);
            uint256 cycleEndTimeStamp = cycle.cycleStartTimeStamp +
                cycle.cycleDuration;
        
            if (cycleEndTimeStamp >= now) return cycleEndTimeStamp - now;
            else return 0;
        }
        
        function getSecondsLeftForCycleToStart(uint256 cycleId)
            external
            view
            onlyNonDeprecatedCalls
            returns (uint256)
        {
            Cycle memory cycle = _getCycleById(cycleId);
            require(cycle.cycleStatus == CycleStatus.NOT_STARTED);
        
            if (cycle.cycleStartTimeStamp >= now)
                return cycle.cycleStartTimeStamp - now;
            else return 0;
        }
        
        function activateCycle(uint256 cycleId)
            external
            onlyNonDeprecatedCalls
            onlyCycleCreator(cycleId)
        {
            Cycle memory cycle = _getCycleById(cycleId);
            CycleFinancial memory cycleFinancial = _getCycleFinancialByCycleId(
                cycleId
            );
        
            uint256 currentTimeStamp = now;
            require(
                cycle.cycleStatus == CycleStatus.NOT_STARTED,
                "Cannot activate a cycle not in the 'NOT_STARTED' state"
            );
            require(
                cycle.numberOfDepositors > 0,
                "Cannot activate cycle that has no depositors"
            );
        
            require(
                cycle.cycleStartTimeStamp <= currentTimeStamp,
                "Cycle start time has not been reached"
            );
        
        
        
            cycle.cycleStartTimeStamp = currentTimeStamp;
            _startCycle(cycle);
            //_updateCycleFinancials(cycleFinancial);
        
            uint256 blockNumber = block.number;
            uint256 blockTimestamp = currentTimeStamp;
            
            emit CycleStarted(cycleId, cycle.cycleStartTimeStamp);
        
           
        }
        
        function endCycle(uint256 cycleId) external onlyNonDeprecatedCalls {
            _endCycle(cycleId);
        }
        
        
        function createGroup(string calldata name, string calldata symbol)
            external
            onlyNonDeprecatedCalls
        {
            _validateGroupNameAndSymbolIsAvailable(name, symbol);
        
            uint256 groupId = groupStorage.createGroup(name, symbol, msg.sender);
            
            emit GroupCreated(groupId, msg.sender);
        
            
        }
        
        function _validateGroupNameAndSymbolIsAvailable(
            string memory name,
            string memory symbol
        ) internal {
            bytes memory nameInBytes = bytes(name); // Uses memory
            bytes memory symbolInBytes = bytes(symbol); // Uses memory
        
            require(nameInBytes.length > 0, "Group name cannot be empty");
            require(symbolInBytes.length > 0, "Group sysmbol cannot be empty");
        
            bool nameExist = groupStorage.doesGroupExist(name);
        
            require(nameExist == false, "Group name has already been used");
        }
        
        function createCycle(
            uint256 groupId,
            uint256 startTimeStamp,
            uint256 duration,
            uint256 maximumSlots,
            bool hasMaximumSlots,
            uint256 cycleStakeAmount
        ) external onlyNonDeprecatedCalls onlyGroupCreator(groupId) {
            _validateCycleCreationActionValid(
                groupId,
                maximumSlots,
                hasMaximumSlots
            );
        
            uint256 cycleId = cycleStorage.createCycle(
                groupId,
                0,
                startTimeStamp,
                duration,
                maximumSlots,
                hasMaximumSlots,
                cycleStakeAmount,
                0,
                0,
                CycleStatus.NOT_STARTED,
                0
            );
        
            cycleStorage.createCycleFinancials(cycleId, groupId, 0, 0, 0, 0, 0, 0);
            
             emit CycleCreated(
                    cycleId,
                    maximumSlots,
                    hasMaximumSlots,
                    cycleStakeAmount,
                    startTimeStamp,
                    duration
                );
        
          
        }
        
        function joinCycle(uint256 cycleId, uint256 numberOfStakes)
            external
            onlyNonDeprecatedCalls
        {
            address payable depositorAddress = msg.sender;
            uint allowance = _getAllowanceForBusd();
        
            _joinCycle(cycleId, numberOfStakes,allowance, depositorAddress);
        }
        
        function joinCycleDelegate(
            uint256 cycleId,
            uint256 numberOfStakes,
            address payable depositorAddress
        ) external onlyNonDeprecatedCalls {
            uint allowance = _getAllowanceForBusd();
        
            _joinCycle(cycleId, numberOfStakes,allowance, depositorAddress);
        }
        }