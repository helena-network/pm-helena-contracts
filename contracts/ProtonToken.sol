pragma solidity ^0.4.21;

import "./PlayToken.sol";

contract ProtonToken is PlayToken {
    /*
     *  Constants
     */
    string public constant name = "Proton";
    string public constant symbol = "P+";
    uint8 public constant decimals = 18;
}
