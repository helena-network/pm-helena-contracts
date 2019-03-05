const Proton = artifacts.require('ProtonToken')
const args = require('yargs').argv;

module.exports = function(deployer) {
    deployer
        .deploy(Proton)
        .then(
            deployedToken => {
                if (args.admins) {
                    return Proton.deployed().then(
                        protonInstance => {
                            const admins = args.admins.split(',')
                            console.log("Adding admins...", admins)
                            return protonInstance.addAdmin(admins)
                        }
                    )
                }
            }
        )
}
