const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ATokenEth } = require("../../contracts/ATokenETH.sol");

module.exports = buildModule("Lock", (m) => {
  const lock = m.contract("ATokenETH", []); // Pass constructor arguments if needed

  // Deploy the contract
  // m.call(apollo, "launch", []);

  return { lock };
});