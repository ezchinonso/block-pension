const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const PensionScheme = artifacts.require("../contracts/PensionScheme.sol");
const PFAFactory = artifacts.require("../contracts/PFAFactory.sol");

contract("PensionScheme", accounts => {
  let PFAFactoryInstance;
  let PensionSchemeInstance;
  let carol = accounts[0]
  let kemi = accounts[1]
  let abu = accounts[2]
  let deposit = web3.utils.toWei('1.0')
  let now = Date.now();
  let rTime = now + 6000000000;
  
  beforeEach(async () => {
    PFAFactoryInstance = await PFAFactory.new();
    let pfa = PFAFactoryInstance.address;
    PensionSchemeInstance = await PensionScheme.new( pfa, {from:carol});
  })
  //check that retirement time > now
  it('...Retirement Time cannot be less than now', async () => {
    expectRevert(PensionSchemeInstance.register.call(kemi, '1608111987', { from: abu}), 'RTIME_INVALID')
  })
  //Check that you can't register yourself
  it("...Cannot register self", async () => {
     expectRevert(PensionSchemeInstance.register.call(abu, rTime, { from: abu}), 'SELF_REGISTER')
  })
  //ensure correct pension Id is returned
  it("...Returns correct pensions ID", async () => {
    const id = await PensionSchemeInstance.register.call(abu, rTime, { from: kemi})
    expect(id.toNumber()).to.be.equal(2020)
      
  })
  //check that deposits into nonexistent pensionId is reverted
  it("...Cannot deposit into nonexistent pension", async()=>{
    
    expectRevert(PensionSchemeInstance.deposit.call(2020, {from: carol}), 'GHOST_BENEFICIARY')
  })
  //Initial pension deposits and contributions should be zero
  it("...Deposit and total contributions should be zero", async () =>{
    let balance = await PensionSchemeInstance.balanceOf.call(2020, {from: carol})
    let a=balance[0]
    let b=balance[1]
    let c=balance[2]
    expect(a.toNumber()).to.be.equal(0)
    expect(b.toNumber()).to.be.equal(0)
    expect(c.toNumber()).to.be.equal(0)
  })
  it("....Cannot pause pfa", async()=>{
    expectRevert.unspecified(PensionSchemeInstance.emergencyPauseDeposit.call(2020, {from: abu}))
    expectRevert.unspecified(PensionSchemeInstance.emergencyPauseWithdraw.call(2020, {from: abu}))
    expectRevert.unspecified(PensionSchemeInstance.emergencyUnPauseDeposit.call(2020, {from: abu}))
    expectRevert.unspecified(PensionSchemeInstance.emergencyUnPauseWithdraw.call(2020, {from: abu}))
  })
});
