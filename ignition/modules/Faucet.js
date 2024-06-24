const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");


module.exports = buildModule("FaucetModule", (m) => {
  const faucet = m.contract("Faucet", ["0x458213f469e0E97579b798178eBf9F1110D3A9Ba"]);

  return { faucet };
});
