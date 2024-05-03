const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Lendingpool", (m) => {
  const lendingpool = m.contract("Lend", []); // Pass constructor arguments if needed

  // Deploy the contract
  // m.call(apollo, "launch", []);

  return { lendingpool };
});