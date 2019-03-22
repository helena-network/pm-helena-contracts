/**
* @dev Includes all necessary functions to make a token compatible with an Apollo competition  
* 
*/

contract IApolloToken { 
    bool public constant isPlayToken = true;
    function issue(address[] recipients, uint amount) public;
    function allowTransfers(address[] allowed) public;
    function disallowTransfers(address[] disallowed) public;
    function addAdmin(address[] _admins) public;
    function removeAdmin(address[] _admins) public;
}