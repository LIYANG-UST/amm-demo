// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

contract MultiSig {
    // ********** STATE VARIABLES ********** //

    address[] public owners;
    mapping(address => bool) public isOwner;

    // The number of confirmations required to execute a transaction
    uint256 public requiredConfirmations;

    // Transactions to be executed
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    mapping(uint256 txIndex => mapping(address owner => bool)) public isConfirmed;

    Transaction[] public transactions;

    // ********** EVENTS & ERRORS ********** //

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event TransactionSubmitted(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );
    event TransactionConfirmed(address indexed owner, uint256 indexed txIndex);
    event TransactionExecuted(address indexed owner, uint256 indexed txIndex);
    event TransactionRevoked(address indexed owner, uint256 indexed txIndex);

    // ********** MODIFIERS ********** //

    modifier notExecutedTx(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx not exist");
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    // ********** CONSTRUCTOR ********** //
    constructor(address[] memory _owners, uint256 _requiredConfirmations) {
        require(_owners.length > 0, "no owners");
        require(
            _requiredConfirmations > 0 && _requiredConfirmations <= _owners.length,
            "invalid required confirmations"
        );

        uint256 numOwners = _owners.length;
        for (uint256 i; i < numOwners; ) {
            address owner = _owners[i];

            // Should not be the zero address and should not be an owner already
            require(owner != address(0), "invalid owner address");
            require(!isOwner[owner], "already owner");

            isOwner[owner] = true;
            owners.push(owner);

            unchecked {
                ++i;
            }
        }

        requiredConfirmations = _requiredConfirmations;
    }

    // ********** GETTER FUCTIONS ********** //
    function getAllOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTotalTransactions() public view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(
        uint256 _txIndex
    ) public view returns (address to, uint256 value, bytes memory data, bool executed, uint256 numConfirmations) {
        Transaction memory transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    // ********** MAIN FUCTIONS ********** //

    function submitTransaction(address _to, uint256 _value, bytes memory _data) public onlyOwner {
        uint256 txIndex = transactions.length;

        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, numConfirmations: 0}));

        emit TransactionSubmitted(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint256 _txIndex) public notExecutedTx(_txIndex) onlyOwner {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit TransactionConfirmed(msg.sender, _txIndex);
    }

    function executeTransaction(uint256 _txIndex) public notExecutedTx(_txIndex) onlyOwner {
        Transaction storage transaction = transactions[_txIndex];

        require(transaction.numConfirmations >= requiredConfirmations, "cannot execute tx");

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit TransactionExecuted(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint256 _txIndex) public onlyOwner notExecutedTx(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit TransactionRevoked(msg.sender, _txIndex);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}
