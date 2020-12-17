const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

const PensionScheme = artifacts.require("../contracts/PensionScheme.sol");

contract("PensionScheme", accounts => {
  let PensionSchemeInstance;
  let carol = accounts[0]
  let kemi = accounts[1]
  let abu = accounts[2]
  let deposit = web3.utils.toWei('1.0')
  let now = Date.now();
  let rTime = now + 6000000000;
  
  beforeEach(async () => {
    PensionSchemeInstance = await PensionScheme.new();
  })
  it('...Retirement Time cannot be less than now', async () => {
    expectRevert(PensionSchemeInstance.register.call(kemi, '1608111987', { from: abu}), 'RTIME_INVALID')
  })
  it("...Cannot register self", async () => {
     expectRevert(PensionSchemeInstance.register.call(abu, rTime, { from: abu}), 'SELF_REGISTER')
  })
  it("...Returns correct beneficiary ID", async () => {
    const id = await PensionSchemeInstance.register.call(abu, rTime, { from: kemi})
    expect(id.toNumber()).to.be.equal(2020)
      
  })
  it("...Cannot deposit into nonexistent pension", async()=>{
    
    expectRevert(PensionSchemeInstance.deposit.call(2020, {from: carol}), 'GHOST_BENEFICIARY')
  })
  it("...Deposit and total contributions should be zero", async () =>{
    let balance = await PensionSchemeInstance.balanceOf.call(2020, {from: carol})
    let a=balance[0]
    let b=balance[1]
    let c=balance[2]
    expect(a.toNumber()).to.be.equal(0)
    expect(b.toNumber()).to.be.equal(0)
    expect(c.toNumber()).to.be.equal(0)
  })
});
