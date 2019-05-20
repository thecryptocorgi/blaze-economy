pragma solidity ^0.4.23;

import './SafeMath.sol';

contract BlazeToken {

    using SafeMath for uint;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    string private _name;
    string private _symbol;
    uint private _decimals;
    uint private _totalSupply;
    uint private _circulatingSupply;

    address private _officer;
    address private _economy;

    bool private _locked;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowed;
    
    constructor() public {
        _officer = msg.sender;
        _name = "BLAZE";
        _symbol = "BLAZE";
        _decimals = 6;
        _totalSupply = 100 * 1000000 * 1000000;
        _circulatingSupply = 0;
        _locked = true;
    }

    function changeEconomy(address account) public {
        require(msg.sender == _officer, "unauthorized");
        _economy = account;
    }

    function changeLock(bool lock) public {
        require(msg.sender == _officer, "unauthorized");
        _locked = lock;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function circulatingSupply() public view returns (uint) {
        return _circulatingSupply;
    }

    function balanceOf(address owner) public view returns (uint) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint value) public returns (bool) {
        send(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns (bool) {
        require(_locked == false, "locked");
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(_locked == false, "locked");
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        send(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        require(_locked == false, "locked");
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        require(_locked == false, "locked");
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function mint(address to, uint value) public returns (bool) {
        require(msg.sender == _economy, "invalid caller");
        require(_totalSupply > _circulatingSupply.add(value));
        _circulatingSupply = _circulatingSupply.add(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(address(0), to, value);
        return true;
    }

    function burn(address from, uint value) public returns (bool) {
        require(msg.sender == _economy, "invalid caller");
        require(_circulatingSupply >= value);
        _circulatingSupply = _circulatingSupply.sub(value);
        _balances[from] = _balances[from].sub(value);
        emit Transfer(from, address(0), value);
        return true;
    }

    function freeze(address spender, uint value) public returns (bool) {
        require(msg.sender == _economy, "invalid caller");
        send(spender, msg.sender, value);
        return true;
    }

    function unfreeze(address spender, uint value) public returns (bool) {
        require(msg.sender == _economy, "invalid caller");
        send(msg.sender, spender, value);
        return true;
    }

    function send(address from, address to, uint value) private {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function name() public view returns (string) {
        return _name;
    }

    function symbol() public view returns (string) {
        return _symbol;
    }

    function decimals() public view returns (uint) {
        return _decimals;
    }
}