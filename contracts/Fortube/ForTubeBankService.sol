pragma solidity >=0.6.6;

import "./ForTubeBankAdapterHack.sol";

contract ForTubeBankService {
    address _owner;
    address  _delegateContract;
    
    FortubeBankAdapterHack _bankAdapter;

    constructor() public {
        _owner = msg.sender;
        
    }

    function transferOwnership(address account) external onlyOwner() {
        if (_owner != address(0)) _owner = account;
    }

    function updateAdapter(address adapterAddress) external onlyOwner() {
        _bankAdapter = FortubeBankAdapterHack(adapterAddress);
    }
    
    function updateWithdrawalDelegrateContract (address withdrawalDelegateAddress) external onlyOwner() {
        _delegateContract = withdrawalDelegateAddress;
    }


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
    
     function TransferCapitalBack (uint depositAmount, address member) external onlyOwnerAndDelegateContract {
            _bankAdapter.TransferCapitalBack(depositAmount, member);
    }
    
    

    function WithdrawByShares(uint256 amount, uint256 sharesAmount) external {
        _bankAdapter.WithdrawByShares(amount, msg.sender, sharesAmount);
    }

    function WithdrawBySharesOnly(uint256 sharesAmount) external {
        _bankAdapter.WithdrawBySharesOnly(msg.sender, sharesAmount);
    }

    function GetForTubeAdapterAddress() external view returns (address) {
        return address(_bankAdapter);
    }

    function TransferAdapterContractOwnership(address payable newServiceContract) external onlyOwner {
        _bankAdapter.transferContractOwnership(newServiceContract);
    }
    
    function UserShares(address user) external view returns (uint256) {
    return _bankAdapter.GetFBUSDBalance(user);
}

function UserBUSDBalance(address user) external view returns (uint256) {
    return _bankAdapter.GetBUSDBalance(user);
}

function Save(uint256 amount, address user) external {
    _bankAdapter.Save(amount, user);
}

function Withdraw(uint256 amount, address user) external {
    _bankAdapter.Withdraw(amount, user);
}

    modifier onlyOwner() {
        require(_owner == msg.sender, "Only owner can make this call");
        _;
    }
    
     modifier onlyOwnerAndDelegateContract() {
        require(
            msg.sender == _owner || msg.sender == _delegateContract,
            "Unauthorized access to contract"
        );
        _;
    }
}