// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    uint256 public immutable totalSupply; // cannot be updated
    uint256 paymentCounter;
    mapping(address => uint256) balances;
    address immutable contractOwner;
    mapping(address => Payment[]) payments;
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
        uint256 paymentID;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
        uint256 amount;
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
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external returns (bool status_) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name;
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        return true;
    }

    function updatePayment(
        address _user,
        uint256 _ID,
        uint256 _amount,
        PaymentType _type
    ) external onlyAdminOrOwner {
        require(_ID > 0);
        require(_amount > 0);
        require(_user != address(0));

        for (uint256 i; i < payments[_user].length; i++) {
            if (payments[_user][i].paymentID == _ID) {
                payments[_user][i].adminUpdated = true;
                payments[_user][i].admin = _user;
                payments[_user][i].paymentType = _type;
                payments[_user][i].amount = _amount;

                History memory history;
                history.blockNumber = uint32(block.number);
                history.lastUpdate = uint64(block.timestamp);
                history.updatedBy = _user;
                paymentHistory.push(history);
            }
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
