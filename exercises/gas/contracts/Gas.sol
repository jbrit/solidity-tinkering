// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;


contract GasContract {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 paymentCounter;
    mapping(address => uint256) public balanceOf;
    address immutable contractOwner;
    mapping(uint256 => Payment) payments;
    mapping(address => uint256) public whitelist;

    address immutable admin0;
    address immutable admin1;
    address immutable admin2;
    address immutable admin3;

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
        if (msg.sender != contractOwner)
            if (msg.sender != admin0)
                if (msg.sender != admin1)
                    if (msg.sender != admin2)
                        if (msg.sender != admin3) revert();
        _;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[5] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;
        admin0 = _admins[0];
        admin1 = _admins[1];
        admin2 = _admins[2];
        admin3 = _admins[3];
        balanceOf[msg.sender] = _totalSupply;
    }

    function unchecked_inc(uint256 a) private pure returns (uint256) {
        unchecked {
            return a + 1;
        }
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function administrators(uint256 id) external view returns (address) {
        if(id==0)  return admin0;
        if(id==1)  return admin1;
        if(id==2)  return admin2;
        if(id==3)  return admin3;
        return contractOwner;
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        uint256 count;
        for (uint256 i = 1; i < paymentCounter + 1; i = unchecked_inc(i)) {
            if (payments[i].user == _user) {
                count += 1;
            }
        }

        // logic to get payments number
        payments_ = new Payment[](count);
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
