const Proton = artifacts.require('PlayToken')

module.exports = function(deployer) {
    deployer.deploy(Proton, 'xProton', 'xP+',  20, [], 0);
}
