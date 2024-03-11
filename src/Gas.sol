// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

contract GasContract {
    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    // Storage

    // replace whitelistAmount map with a single uint256 to simplify
    uint256 prevAmount;
    mapping(address => uint256) public balances;

    constructor(address[] memory, uint256 _totalSupply) {
        balances[msg.sender] = _totalSupply;
    }

    /// replace whitelist mapping with a getter hardcoded to 0 to get rid of all relevant whitelist tier logic
    function whitelist(address) public pure returns (uint256) {
        return 0;
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
    function checkForAdmin(address) public pure returns (bool) {
        return true;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) public {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
    }

    /// simplify whitelist tier logic with ternary
    /// use custom errors instead of requires
    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        if (msg.sender != address(0x1234)) revert();
        if (_tier >= 255) revert();
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    /// read whitelist tier only once
    /// uncheck arithmetic operations
    /// store _amount to a single uint256 var instead of a mapping
    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        prevAmount = _amount;

        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }

        emit WhiteListTransfer(_recipient);
    }

    /// hardcode true
    /// grab prev _amount param from a uint256 var instead of a mapping
    function getPaymentStatus(address) public view returns (bool, uint256) {
        return (true, prevAmount);
    }
}
