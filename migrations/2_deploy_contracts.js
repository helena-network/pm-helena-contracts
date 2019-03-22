const Proton = artifacts.require('ReferenceToken')
//const args = require('yargs').argv;

module.exports = function(deployer) {
    deployer.deploy(Proton, "asdf", "asdf", 20, ['0x08c9906A56b7D6EC75676Db0E307921ED7438989'], '0x08c9906A56b7D6EC75676Db0E307921ED7438989', 1000);
}
