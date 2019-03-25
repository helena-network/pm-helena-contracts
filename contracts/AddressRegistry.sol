pragma solidity ^0.4.24;

contract AddressRegistry {
    mapping (address => address) public mainnetAddressFor;

    event AddressRegistration(address registrant, address registeredMainnetAddress);

    function register(address mainnetAddress) public {
        emit AddressRegistration(msg.sender, mainnetAddress);
        mainnetAddressFor[msg.sender] = mainnetAddress;
    }
}
