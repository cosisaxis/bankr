// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Bank {
    address public owner;
    mapping(bytes32 => address) public whitelistedTokens;
    bytes32[] public whitelistedSymbols;

    mapping(address => mapping(bytes32 => uint256)) public balances;

    constructor() {
        owner = msg.sender;
    }

    function whitelistToken(bytes32 _symbol, address _tokenAddress) external {
        require(msg.sender == owner, "Only the owner can whitelist tokens.");

        whitelistedSymbols.push(_symbol);
        whitelistedTokens[_symbol] = _tokenAddress;
    }

    function getWhitelistedSymbols() external view returns (bytes32[] memory) {
        return whitelistedSymbols;
    }

    function getWhitelistedTokenAddress(bytes32 _symbol) external view returns (address) {
        return whitelistedTokens[_symbol];
    }

    function depositETH() external payable {
        balances[msg.sender]['ETH'] += msg.value;
    }

    function withdrawETH(uint256 _amount) external {
        require(balances[msg.sender]['ETH'] >= _amount, 'Insufficient funds.');

        balances[msg.sender]['ETH'] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function depositTokens(uint256 _amount, bytes32 _symbol) external {
        require(whitelistedTokens[_symbol] != address(0), "Token is not whitelisted.");

        IERC20 token = IERC20(whitelistedTokens[_symbol]);
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed.");

        balances[msg.sender][_symbol] += _amount;
    }

    function withdrawTokens(uint256 _amount, bytes32 _symbol) external {
        require(balances[msg.sender][_symbol] >= _amount, 'Insufficient funds.');

        IERC20 token = IERC20(whitelistedTokens[_symbol]);
        require(token.transfer(msg.sender, _amount), "Token transfer failed.");

        balances[msg.sender][_symbol] -= _amount;
    }

    function getTokenBalance(bytes32 _symbol) external view returns (uint256) {
        return balances[msg.sender][_symbol];
    }
}
