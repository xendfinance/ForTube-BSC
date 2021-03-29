pragma solidity >=0.6.6;

import "./IBEP20.sol";


interface IFToken is IBEP20{
    
    function underlying() external view returns (address);
    function exchangeRateCurrent() external view returns (uint256 exchangeRate);
    function exchangeRateStored() external view returns (uint256 exchangeRate);
    function APY() external view returns (uint256);
    function APR() external view returns (uint256);

}