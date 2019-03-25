'use strict'

const util = require('util')

const _ = require('lodash')
const { wait } = require('@digix/tempo')(web3);


let owner = web3.eth.accounts[0]
let admins = web3.eth.accounts.slice(1, 2)
let operators = web3.eth.accounts.slice(3, 4)
let candidateAccounts = web3.eth.accounts.slice(5, 6)
let recipients = web3.eth.accounts.slice(7,14)

const ProtonToken = artifacts.require('ProtonToken')
const PlayToken = artifacts.require('PlayToken')
const RewardClaimHandler = artifacts.require('RewardClaimHandler')
const RewardToken = artifacts.require('RewardToken')

async function throwUnlessRejects(q) {
    let res
    try {
        res = await q
    } catch(e) {
        return e
    }
    throw new Error(`got result ${ res } from ${ q }`)
}

const getBlock = util.promisify(web3.eth.getBlock.bind(web3.eth))

contract('OlympiaToken', function(accounts) {
    let ProtonTokenInstance

    before(async () => {
        ProtonTokenInstance = await ProtonToken.deployed()
    })
})

contract('PlayToken', function(accounts) {
    let playToken

    before(async () => {
        playToken = await PlayToken.new('xProton', 'xP+',  20, operators, 0, { from: owner })
    })

    it('should allow the contract owner to issue tokens', async () => {
        assert.equal(await playToken.owner(), owner)
        assert.equal(await playToken.totalSupply(), 0)

        const startingBalances = (await Promise.all(recipients.map((r) => playToken.balanceOf(r)))).map((v) => v.valueOf())
        startingBalances.forEach((b, i) => assert.equal(b, 0, `recipient ${recipients[i]} balance`))

        await playToken.issue(recipients, 1e18, "")

        const endingBalances =  (await Promise.all(recipients.map((r) => playToken.balanceOf(r)))).map((v) => v.valueOf())
        endingBalances.forEach((b, i) => assert.equal(b, 1e18, `recipient ${recipients[i]} balance`))

        let supply = await playToken.totalSupply()
        assert.equal(await supply.toNumber(), 1e18 * recipients.length)
    })

    const [giver, getter, approver, spender, whitelisted1, whitelisted2, whitelisted3] = recipients

    it('should forbid tokens from being transferred', async () => {
        await throwUnlessRejects(playToken.transfer(getter, 1e16, { from: giver }))
    })

    it('should forbid tokens from being transferFromed', async () => {
        await playToken.approve(spender, 1e16, { from: approver })
        await throwUnlessRejects(playToken.transferFrom(approver, getter, 1e16, { from: spender }))
    })

    it('should allow only the contract owner to whitelist addresses for transfers from and to those addresses', async () => {
        await throwUnlessRejects(playToken.allowTransfers([getter], { from: getter }))
        await playToken.allowTransfers([whitelisted1, whitelisted2, whitelisted3], { from: owner })

        for(let whitelisted of [whitelisted1, whitelisted2, whitelisted3]) {
            await throwUnlessRejects(playToken.transfer(getter, 1e16, { from: giver }))
            await playToken.transfer(getter, 1e16, { from: whitelisted })
            await playToken.transfer(whitelisted, 1e16, { from: giver })

            await playToken.approve(spender, 1e16, { from: approver })
            await throwUnlessRejects(playToken.transferFrom(approver, getter, 1e16, { from: spender }))
            await playToken.transferFrom(approver, whitelisted, 1e16, { from: spender })
            await playToken.approve(spender, 1e16, { from: whitelisted })
            await playToken.transferFrom(whitelisted, getter, 1e16, { from: spender })
        }
    })

    it('should allow only the contract owner to take addresses off the whitelist', async () => {
        await throwUnlessRejects(playToken.disallowTransfers([whitelisted1], { from: getter }))
        // NOTE: specifying somebody not on the whitelist basically does nothing, but is otherwise valid
        await playToken.disallowTransfers([getter, whitelisted2, whitelisted3], { from: owner })

        await playToken.transfer(getter, 1e16, { from: whitelisted1 })
        await playToken.transfer(whitelisted1, 1e16, { from: giver })
        await playToken.approve(spender, 1e16, { from: approver })
        await playToken.transferFrom(approver, whitelisted1, 1e16, { from: spender })
        await playToken.approve(spender, 1e16, { from: whitelisted1 })
        await playToken.transferFrom(whitelisted1, getter, 1e16, { from: spender })

        for(let unwhitelisted of [whitelisted2, whitelisted3]) {
            await throwUnlessRejects(playToken.transfer(getter, 1e16, { from: unwhitelisted }))
            await throwUnlessRejects(playToken.transfer(unwhitelisted, 1e16, { from: giver }))
            await playToken.approve(spender, 1e16, { from: approver })
            await throwUnlessRejects(playToken.transferFrom(approver, unwhitelisted, 1e16, { from: spender }))
            await playToken.approve(spender, 1e16, { from: unwhitelisted })
            await throwUnlessRejects(playToken.transferFrom(unwhitelisted, getter, 1e16, { from: spender }))
        }
    })

    it('should allow only the contract owner to add/remove admins', async () => {
        // non owner cannot add admin
        await throwUnlessRejects(playToken.addAdmin([whitelisted1], { from: getter }))
        // non admin cannot allow transfers
        await throwUnlessRejects(playToken.allowTransfers([whitelisted2], { from: whitelisted1 }))
        // owner can add admins
        const admin = whitelisted1
        await playToken.addAdmin([admin], { from: owner })
        // admin can allow transfers
        await playToken.allowTransfers([whitelisted2], { from: admin })

        // non owners, cannot remove admins
        await throwUnlessRejects(playToken.addAdmin([whitelisted1], { from: getter }))
    })

     it('should have the right name, symbol, and decimals', async () => {
        assert.equal(await playToken.name(), 'xProton')
        assert.equal(await playToken.symbol(), 'xP+')
        assert.equal(await playToken.decimals(), 18)
    })
/** 
    it('admins should be able to be specified during the migration', async () => {
        const nonAdminsNorCreator = accounts.slice(1).filter(account => admins.indexOf(account) === -1)
        const admin = whitelisted1;

        await playToken.allowTransfers(nonAdminsNorCreator[0], { from: owner })
        
        await throwUnlessRejects(playToken.allowTransfers(nonAdminsNorCreator, { from: getter }))
    })
**/
})

