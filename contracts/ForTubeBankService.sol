pragma solidity 0.6.6;

import "./ForTubeBankAdapter.sol";

contract ForTubeBankService {
    address _owner;
    address _delegateContract;

    ForTubeBankAdapter _bankAdapter;

    constructor() public {
        _owner = msg.sender;
    }

    function TransferOwnership(address account) external onlyOwner() {
        if (_owner != address(0)) _owner = account;
    }

    function UpdateAdapter(address adapterAddress) external onlyOwner() {
        _bankAdapter = ForTubeBankAdapter(adapterAddress);
    }

    /*
        account: this is the owner of the DUSD token
    */
    /*
        -   Before calling this function, ensure that the msg.sender or caller has given this contract address
            approval to transfer money on its behalf to another address
    */
    function Save(uint256 amount) external {
        _bankAdapter.Save(amount, msg.sender);
    }

    function Withdraw(uint256 amount) external {
        _bankAdapter.Withdraw(amount, msg.sender);
    }

    function WithdrawByShares(uint256 amount, uint256 sharesAmount) external {
        _bankAdapter.WithdrawByShares(amount, msg.sender, sharesAmount);
    }

    function WithdrawBySharesOnly(uint256 sharesAmount) external {
        _bankAdapter.WithdrawBySharesOnly(msg.sender, sharesAmount);
    }

    function GetForTubeBankAdapterAddress() external view returns (address) {
        return address(_bankAdapter);
    }
    function GetPricePerFullShare() external view returns (uint256){
        
        return _bankAdapter.GetPricePerFullShare();
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Only owner can make this call");
        _;
    }
}
