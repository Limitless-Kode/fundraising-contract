const ClaverToken = artifacts.require("ClaverToken");
const Fundraising = artifacts.require("Fundraising");

module.exports = async function (deployer) {
  await deployer.deploy(ClaverToken);
  const token = await ClaverToken.deployed();

  await deployer.deploy(Fundraising);
  const fundraising = await Fundraising.deployed();
  await token.transfer(fundraising.address, (1000000 * 10 ** 18).toString());
};
