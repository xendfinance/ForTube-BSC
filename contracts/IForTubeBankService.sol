pragma solidity >=0.6.6;


interface IForTubeBankService {

    function Save(uint256 amount) external;
    
    function Withdraw(uint256 amount) external;

    function WithdrawByShares(uint256 amount, uint256 sharesAmount) external;

    function WithdrawBySharesOnly(uint256 sharesAmount) external;

    function GetForTubeAdapterAddress() external view returns (address);

    function UserShares(address user) external view returns (uint256);

    function UserBUSDBalance(address user) external view returns (uint256);

    function TransferAdapterContractOwnership(address payable newServiceContract) external;
    
    function CalculateTotalBUSDEarned(address member) external view returns (uint256 exchangeRate);
    
    function TransferCapitalBack (uint depositAmount, address member) external;

}