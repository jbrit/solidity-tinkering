// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract GasContract {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 paymentCounter;
    mapping(address => uint256) public balanceOf;
    address immutable contractOwner;
    mapping(uint256 => Payment) payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;

    struct Payment {
        address user;
        uint8 paymentType;
        uint256 amount;
    }

    struct Z {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    modifier onlyAdminOrOwner() {
        if (msg.sender != contractOwner) {
            if (checkNotAdmin(msg.sender)) revert();
        }
        _;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        administrators = _admins;
        balanceOf[msg.sender] = _totalSupply;
    }

    function unchecked_inc(uint256 a) private pure returns (uint256) {
        unchecked {
            return a + 1;
        }
    }

    function checkNotAdmin(address _user) private view returns (bool) {
        for (uint256 i; i < 5; i = unchecked_inc(i)) {
            if (administrators[i] == _user) {
                return false;
            }
        }
        return true;
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        // logic to get payments number
        payments_ = new Payment[](5);
        for (uint256 i = 1; i < paymentCounter + 1; i = unchecked_inc(i)) {
            if (payments[i].user == _user) {
                unchecked {
                    payments_[i - 1] = payments[i];
                }
            }
        }
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) external {
        balanceOf[msg.sender] -= _amount;
        balanceOf[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        uint256 _paymentCounter = ++paymentCounter;
        payments[_paymentCounter].user = msg.sender;
        payments[_paymentCounter].amount = _amount;
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        uint8 _type
    ) external onlyAdminOrOwner {
        payments[_ID] = Payment(_user, _type, _amount);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
        onlyAdminOrOwner
    {
        whitelist[_userAddrs] = _tier > 2 ? 3 : _tier;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        Z calldata
    ) external {
        uint256 diff = _amount - whitelist[msg.sender];
        if (balanceOf[msg.sender] >= _amount) {
            // whitelist > 0 if diff < _amount, would have been earlier revert if not
            balanceOf[_recipient] += diff;
            unchecked {
                balanceOf[msg.sender] -= diff;
            }
        }
    }
}
