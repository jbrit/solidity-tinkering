// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 paymentCounter;
    mapping(address => uint256) balances;
    address immutable contractOwner;
    mapping(address =>  mapping(uint256 => Payment)) payments;
    mapping(uint256 => PaymentMap) paymentMaps;
    mapping(address =>  uint256) count;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    enum PaymentType {
        BasicPayment,
        Unknown,
        Refund,
        Dividend,
        GroupPayment
    }

    History[] paymentHistory; // when a payment was updated

    struct Payment {
        PaymentType paymentType;
        uint256 amount;
    }

    struct PaymentMap {
        address user;
        uint256 id;
    }

    struct History {
        address updatedBy;
        uint64 lastUpdate;
        uint32 blockNumber;
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

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 i; i < 5; i++) {
            administrators[i] = _admins[i];
            if (_admins[i] == msg.sender) balances[msg.sender] = _totalSupply;
        }
    }

    function getPaymentHistory()
        external
        view
        returns (History[] memory paymentHistory_)
    {
        return paymentHistory;
    }

    function checkNotAdmin(address _user) private view returns (bool) {
        for (uint256 i; i < 5; i++) {
            if (administrators[i] == _user) {
                return false;
            }
        }
        return true;
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() external pure returns (bool) {
        return true;
    }

    function getPayments(address _user)
        external
        view
        returns (Payment[] memory payments_)
    {
        uint256 count_ = count[_user];
        payments_ = new Payment[](count_);
        for (uint256 i; i < count_; i++) {
            payments_[i] = payments[_user][i];
        }
        return payments_;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external{
        uint256 balance = balances[msg.sender];
        require(balance >= _amount);
        balances[msg.sender] = balance - _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        uint256 count_ = count[msg.sender]++;
        uint256 _paymentCounter = ++paymentCounter;
        paymentMaps[_paymentCounter].user = msg.sender;
        paymentMaps[_paymentCounter].id = count_;

        payments[msg.sender][count_].amount = _amount;
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external onlyAdminOrOwner {
        require(_ID > 0);
        require(_amount > 0);
        // require(_user != address(0));
        
        address user = paymentMaps[_ID].user;
        uint256 id = paymentMaps[_ID].id;
        if (user == _user){
            payments[_user][id].amount = _amount;
            payments[_user][id].paymentType = _type;
        } else {
            if(count[user]!=0) count[user]--;
            uint256 count_ = count[_user]++;
            payments[_user][count_].amount = _amount;
            payments[_user][count_].paymentType = _type;
            paymentMaps[_ID] = PaymentMap(_user, count_);
        }

    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        external
        onlyAdminOrOwner
    {
        if (_tier > 2) {
            whitelist[_userAddrs] = 3;
        } else {
            whitelist[_userAddrs] = _tier;
        }
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        Z calldata
    ) external {
        // whitelist > 0 if diff < _amount
        uint256 diff = _amount - whitelist[msg.sender];
        if (balances[msg.sender] >= _amount) {
            if (diff < _amount) {
                balances[_recipient] += diff;
                balances[msg.sender] -= diff;
            }
        }
    }
}
