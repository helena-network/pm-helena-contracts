const AddressRegistry = artifacts.require('AddressRegistry')

contract('AddressRegistry', function(accounts) {
    let addressRegistry

    before(async () => {
        addressRegistry = await AddressRegistry.new()
    })

    it('should begin with no registered addresses', async () => {
        (await Promise.all(accounts.map(account => addressRegistry.mainnetAddressFor(account))))
        .forEach(registeredMainnetAddress => {
            assert.equal(registeredMainnetAddress, '0x0000000000000000000000000000000000000000')
        })
    })

    it('should register addresses', async () => {
        const addressForIndex = i => `0xcafebabedeadbeefc0ffee67ea1ceb00dabad${
            ('000' + i).substring(('' + i).length)
        }`

        const txResults = await Promise.all(accounts.map((account, i) => {
            return addressRegistry.register(addressForIndex(i), { from: account })
        }))
        
        txResults.forEach((txResult, i) => {
            assert.equal(txResult.logs.length, 1)
            assert.equal(txResult.logs[0].event, 'AddressRegistration')
            assert.equal(txResult.logs[0].args.registrant, accounts[i])
            assert.equal(txResult.logs[0].args.registeredMainnetAddress, addressForIndex(i))
        });

        (await Promise.all(accounts.map(account => addressRegistry.mainnetAddressFor(account))))
        .forEach((registeredMainnetAddress, i) => {
            assert.equal(registeredMainnetAddress, addressForIndex(i))
        })
    })
})
