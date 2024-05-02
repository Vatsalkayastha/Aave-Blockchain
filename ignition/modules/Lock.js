const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Lock", (m) => {
  const lock = m.contract("LendingPool", []); // Pass constructor arguments if needed

  // Deploy the contract
  // m.call(apollo, "launch", []);

  return { lock };
});