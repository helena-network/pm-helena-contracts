pragma solidity ^0.4.24;


import { ERC777ERC20BaseToken } from "./ERC777/ERC777ERC20BaseToken.sol";
import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract PlayToken is ERC777ERC20BaseToken, Ownable {

    event ERC20Enabled();
    event ERC20Disabled();
    event Issuance(address indexed owner, uint amount);

    mapping (address => bool) public whitelist;
    mapping (address => bool) public admins;
    mapping (address => bool) public burnOperators;
    mapping (address => bool) public mintOperators;

    modifier onlyAdmin { 
        require(msg.sender == owner || admins[msg.sender] == true, "Not Admin");
        _;
    }

    modifier onlyBurnOperator { 
        require(msg.sender == owner || burnOperators[msg.sender] == true, "Not Burn Operator");
        _;
    }

    modifier onlyMintOperator { 
        require(msg.sender == owner || mintOperators[msg.sender] == true, "Not Mint Operator");
        _;
    }

    constructor(
        string _name,
        string _symbol,
        uint256 _granularity,
        address[] _defaultOperators,
        uint256 _initialSupply
    )
        public ERC777ERC20BaseToken(_name, _symbol, _granularity, _defaultOperators)
    {
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

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _admins Addresses to be added as admin role
    function addAdmin(address[] _admins) public onlyOwner {
        for(uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = true;
        }
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _burnOperators Addresses to be added as burn role
    function addBurnOperator(address[] _burnOperators) public onlyOwner {
        for(uint i = 0; i < _burnOperators.length; i++) {
            burnOperators[_burnOperators[i]] = true;
        }
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _mintOperators Addresses to be added as admin role
    function addMintOperator(address[] _mintOperators) public onlyOwner {
        for(uint i = 0; i < _mintOperators.length; i++) {
            mintOperators[_mintOperators[i]] = true;
        }
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _admins Addresses to be added as admin role
    function revokedmin(address[] _admins) public onlyOwner {
        for(uint i = 0; i < _admins.length; i++) {
            admins[_admins[i]] = false;
        }
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _burnOperators Addresses to be added as burn role
    function revokeBurnOperator(address[] _burnOperators) public onlyOwner {
        for(uint i = 0; i < _burnOperators.length; i++) {
            burnOperators[_burnOperators[i]] = false;
        }
    }

    /// @dev Allows creator to add admins that can whitelist addresses.
    /// @param _mintOperators Addresses to be added as admin role
    function revokeMintOperator(address[] _mintOperators) public onlyOwner {
        for(uint i = 0; i < _mintOperators.length; i++) {
            mintOperators[_mintOperators[i]] = false;
        }
    }

    /// @notice Allows creator to mark addresses as whitelisted for transfers to and from those addresses.
    /// @param allowed Addresses to be added to the whitelist
    function allowTransfers(address[] allowed) public onlyAdmin {
        for(uint i = 0; i < allowed.length; i++) {
            whitelist[allowed[i]] = true;
        }
    }

    /// @notice Allows creator to remove addresses from being whitelisted for transfers to and from those addresses.
    /// @param disallowed Addresses to be removed from the whitelist
    function disallowTransfers(address[] disallowed) public onlyAdmin {
        for(uint i = 0; i < disallowed.length; i++) {
            whitelist[disallowed[i]] = false;
        }
    }

    /// @notice Overrides transfer function to only allow whitelisted accounts.
    function transfer(address to, uint256 value) public returns (bool) {
        require(whitelist[msg.sender] || whitelist[to]);
        super.transfer(to, value);
    } 
    
    /// @notice Allows creator to add admins that can whitelist addresses.
    /// @notice _admins Addresses to be added as admin role
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(whitelist[from] || whitelist[to]);
        return super.transferFrom(from, to, value);
    }

    /// @notice Allows mintOperator to issue tokens. Will reject if msg.sender isn't the creator.
    /// @param recipients Addresses of recipients
    /// @param amount Number of tokens to issue each recipient
    /// @param _operatorData Data that will be passed to the recipient as a first transfer

    function issue(address[] recipients, uint256 amount, bytes _operatorData) public onlyMintOperator {
        for(uint i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            doMint(recipient, amount, _operatorData);
            emit Issuance(recipient, amount);
        }
    }
 
    /// @notice Generates `_amount` tokens to be assigned to `_tokenHolder`
    /// Sample mint function to showcase the use of the `Minted` event and the logic to notify the recipient.
    /// @param _tokenHolder The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @param _operatorData Data that will be passed to the recipient as a first transfer

    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public onlyMintOperator{
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

    function operatorBurn(address _tokenHolder, uint256 _amount, bytes _data, bytes _operatorData) public onlyBurnOperator {
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
