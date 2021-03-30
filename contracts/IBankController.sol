// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

import "./IFToken.sol";

interface IBankController{
    
    // Pass the address of a token or fToken and check if it is valid
    function isFTokenValid(address fToken) external view returns (bool);
    
    //  retuns all the supported FToken addresses
    function getAllMarkets() external view returns (IFToken[] memory);
    
    /**
        underlying is the main token address eg BUSD
        This function will return the corresponding fToken when you pass the token address 
        Eg when you pass BUSD you will get address of fBUSD 
    */
     function getFTokeAddress(address underlying)
        external
        view
        returns (address);
}