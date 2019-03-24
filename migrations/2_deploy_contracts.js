const Proton = artifacts.require('PlayToken')
//const args = require('yargs').argv;

module.exports = function(deployer) {
    deployer.deploy(Proton, "asdf", 'xProton', 'xP+',  20, operators, 0, 1000);
}
