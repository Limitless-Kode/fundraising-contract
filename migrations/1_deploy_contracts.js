const Helper = artifacts.require("Helper");
const Lottery = artifacts.require("Lottery");

module.exports = function(deployer) {
  deployer.deploy(Helper);
  deployer.link(Helper, Lottery);
  deployer.deploy(Lottery);
};
