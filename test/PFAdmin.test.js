const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const pfa = artifacts.require("../contracts/PFAdmin.sol");

contract("PensionFundAdmin", accounts => {
  let PensionAdminInstance;
  let carol = accounts[0]
  let kemi = accounts[1]
  let abu = accounts[2]
  
  beforeEach(async () => {
    PensionAdminInstance = await pfa.new(abu, carol);
  })
  it('... cannot increment counter', async () => {
      expectRevert.unspecified(PensionAdminInstance.annuitizedWithdraw.call({from : carol}))
  })
  it("...Only Owner Can Call", async () => {
     expectRevert(PensionAdminInstance.annuitizedWithdraw.call({from : kemi}), 'NOT_AUTHORIZED')
     expectRevert(PensionAdminInstance.lumpSumWithdraw.call({from : kemi}), 'NOT_AUTHORIZED')
     expectRevert(PensionAdminInstance.invest.call({from : kemi}), 'NOT_AUTHORIZED')
     
  })
  it("....revert when timelock active", async () => {
     expectRevert(PensionAdminInstance.annuitizedWithdraw.call({from : carol}), 'TIMELOCK_ACTIVE')
     expectRevert(PensionAdminInstance.lumpSumWithdraw.call({from : carol}), 'TIMELOCK_ACTIVE')
  })
  
});
