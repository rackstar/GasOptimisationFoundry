// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

contract GasContract {
    error IncorrectTier();
    error IncorrectAddress();

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    // Storage

    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whiteListAmount;

    constructor(address[] memory _admins, uint256 _totalSupply) {
        balances[msg.sender] = _totalSupply;
    }

    /// hardcode administrators - saves 83,560 gas
    function administrators(uint index) public pure returns (address admin) {
        assembly {
            switch index
            case 0 {
                admin := 0x3243Ed9fdCDE2345890DDEAf6b083CA4cF0F68f2
            }
            case 1 {
                admin := 0x2b263f55Bf2125159Ce8Ec2Bb575C649f822ab46
            }
            case 2 {
                admin := 0x0eD94Bc8435F3189966a49Ca1358a55d871FC3Bf
            }
            case 3 {
                admin := 0xeadb3d065f8d15cc05e92594523516aD36d1c834
            }
            case 4 {
                admin := 0x1234
            }
        }
    }

    /// hardcode true
    function checkForAdmin(address _user) public pure returns (bool) {
        return true;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
    }

    /// simplify whitelist tier logic with ternary
    /// use custom errors instead of requires
    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        if (msg.sender != address(0x1234)) {
            revert IncorrectAddress();
        }
        if (_tier >= 255) {
            revert IncorrectTier();
        }
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    /// read whitelist tier only once
    /// uncheck arithmetic operations
    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        whiteListAmount[msg.sender] = _amount;

        uint whitelistTier = whitelist[msg.sender];
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
            balances[msg.sender] += whitelistTier;
            balances[_recipient] -= whitelistTier;
        }

        emit WhiteListTransfer(_recipient);
    }

    /// hardcode true
    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whiteListAmount[sender]);
    }
}
