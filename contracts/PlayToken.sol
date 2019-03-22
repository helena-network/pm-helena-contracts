/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */
pragma solidity ^0.4.24;

/// @title ERC777 ReferenceToken Contract
/// @author Jordi Baylina, Jacques Dafflon
/// @dev This token contract's goal is to give an example implementation
///  of ERC777 with ERC20 compatiblity using the base ERC777 and ERC20
///  implementations provided with the erc777 package.
///  This contract does not define any standard, but can be taken as a reference
///  implementation in case of any ambiguity into the standard


import { ERC777ERC20BaseToken } from "./ERC777/ERC777ERC20BaseToken.sol";
import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract PlayToken is ERC777ERC20BaseToken, Ownable {

    event ERC20Enabled();
    event ERC20Disabled();
    event Issuance(address indexed owner, uint amount);

    mapping (address => bool) public whitelist;
    mapping (address => bool) public admins;
    address private mBurnOperator;

    modifier isAdmin { 
        require(msg.sender == owner || admins[msg.sender] == true);
        _;
    }

    constructor(
        string _name,
        string _symbol,
        uint256 _granularity,
        address[] _defaultOperators,
        address _burnOperator,
        uint256 _initialSupply
    )
        public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators)
    {
        mBurnOperator = _burnOperator;
        doMint(msg.sender, _initialSupply, "");
    }

    /// @notice Disables the ERC20 interface. This function can only be called
    ///  by the owner.
    function disableERC20() public  onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", 0x0);
        emit ERC20Disabled();
    }

    /// @notice Re enables the ERC20 interface. This function can only be called
    ///  by the owner.
    function enableERC20() public  onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
        emit ERC20Enabled();
    }


    /// @notice Allows creator to mark addresses as whitelisted for transfers to and from those addresses.
    /// @param allowed Addresses to be added to the whitelist
    function allowTransfers(address[] allowed) public isAdmin {
        for(uint i = 0; i < allowed.length; i++) {
            whitelist[allowed[i]] = true;
        }
    }

    /// @notice Allows creator to remove addresses from being whitelisted for transfers to and from those addresses.
    /// @param disallowed Addresses to be removed from the whitelist
    function disallowTransfers(address[] disallowed) public isAdmin {
        for(uint i = 0; i < disallowed.length; i++) {
            whitelist[disallowed[i]] = false;
        }
    }

    function transfer(address to, uint value) public returns (bool) {
        require(whitelist[msg.sender] || whitelist[to]);
        super.transfer(to, value);
    } 
    
    
    function transferFrom(address from, address to, uint value) public returns (bool) {
        require(whitelist[from] || whitelist[to]);
        return super.transferFrom(from, to, value);
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _admins Addresses to be added as admin role
    function addAdmin(address[] _admins) public onlyOwner {
        for(uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    /// @dev Allows creator to issue tokens. Will reject if msg.sender isn't the creator.
    /// @param recipients Addresses of recipients
    /// @param amount Number of tokens to issue each recipient
    function issue(address[] recipients, uint amount) public onlyOwner {
        for(uint i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            mBalances[recipient] = mBalances[recipient].add(amount);
            emit Issuance(recipient, amount);
        }
        mTotalSupply = mTotalSupply.add(amount.mul(recipients.length));
    }

    /* -- Mint And Burn Functions (not part of the ERC777 standard, only the Events/tokensReceived call are) -- */
    //
    /// @notice Generates `_amount` tokens to be assigned to `_tokenHolder`
    /// Sample mint function to showcase the use of the `Minted` event and the logic to notify the recipient.
    /// @param _tokenHolder The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @param _operatorData Data that will be passed to the recipient as a first transfer

    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public  onlyOwner{
        doMint(_tokenHolder, _amount, _operatorData);
    }

    /// @notice Burns `_amount` tokens from `msg.sender`
    ///  Silly example of overriding the `burn` function to only let the owner burn its tokens.
    ///  Do not forget to override the `burn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _amount The quantity of tokens to burn

    function burn(uint256 _amount, bytes _data) public onlyOwner{
        super.burn(_amount, _data);
    }

    /// @notice Burns `_amount` tokens from `_tokenHolder` by `_operator`
    ///  Silly example of overriding the `operatorBurn` function to only let a specific operator burn tokens.
    ///  Do not forget to override the `operatorBurn` function in your token contract if you want to prevent users from
    ///  burning their tokens.
    /// @param _tokenHolder The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData) public {
        require(msg.sender == mBurnOperator, "Not a burn operator");
        super.operatorBurn(_tokenHolder, _amount, _data, _operatorData);
    }

    function doMint(address _tokenHolder, uint256 _amount, bytes _operatorData) private {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, 0x0, _tokenHolder, _amount, "", _operatorData, true);

        emit Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { emit Transfer(0x0, _tokenHolder, _amount); }
    }
}
