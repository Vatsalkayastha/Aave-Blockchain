const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Lock", (m) => {
const token = m.contract("NewLendingPool");
  return { token };
});