pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/utils/Pausable.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./interface/cToken.sol";
import "./Pausable.sol";

contract PFAdmin is Pausable{
    using SafeMath for uint;

    /**
    * @notice `beneficiary` - address to transfer funds to
    */
    address payable beneficiary;
    /**
    * @notice PFAdmin Owner(PensionScheme) 
    */
    address owner;
    /**
    * @notice compound token address on the Ropsten testnet
    */
    cToken c = cToken(0xBe839b6D93E3eA47eFFcCA1F27841C917a8794f3);
    /**
    * @notice counter to track payment of annuity 
    */
    uint public counter = 0;
    /**
    * @notice `time`- the least time withdrawal can take place 
    */
    uint private time = 0;
     /**
    * @notice timelock period for withdrawals 
    */
    uint private duration = 28 days;
    /**
    * @notice Maximum number of time annuity is paid
    */
    uint private withdrawalLimit = 23;
   

    /********************************* Events *********************************/
    /** 
    * @notice Emits when annuity is paid to beneficiary
    */
    event LogAnnuity(address beneficiary, uint counter, uint amount);

    /** 
    * @notice Emits when LumpSum is paid to beneficiary 
    */
    event LogLumpSumWithdraw(address beneficiary,  uint amount);
    /** 
    * @notice Emits when the Invest function is called
    */
    event LogInvest(address beneficiary, uint amount);


    /******************** Functions **********************/
    constructor(address payable _beneficiary, address _owner) public {
        beneficiary = _beneficiary;
        owner = _owner;
    }


    /**
    * @notice function to increment counter
    */
    function incrementCounter() private {
        counter.add(1);
    }
    /**
    * @notice pays annuity to beneficiary and selfdestructs if withdrawalLimit is reached. 
    *       Also Increments counter and resets withdrawal time.
    * @dev Throws if not withrawal period.
    * Throws if msg.sender not owner.
    */

    function annuitizedWithdraw() public whenWithdrawNotPaused(){
        require(owner == msg.sender,'NOT_AUTHORIZED');
        require(now > time, 'TIMELOCK_ACTIVE' );
        require(counter <= withdrawalLimit );
        uint totalBalance = getBalance();
        if (counter == withdrawalLimit){
            beneficiary.transfer(totalBalance);
            emit LogAnnuity(beneficiary, counter, totalBalance);
            selfdestruct(beneficiary);
        }else{
            uint balance = totalBalance.div(withdrawalLimit.sub(counter));
            redeemCEth(balance);
            beneficiary.transfer(balance);
            emit LogAnnuity(beneficiary, counter, balance); 
        }
        time = now.add(duration);
        incrementCounter();
    }

    /**
    * @notice pays lump sum to beneficiary and selfdestructs
    * @dev Throws if msg.sender not owner.
    * Throws if not withrawal period.
    */
    function lumpSumWithdraw() public whenWithdrawNotPaused(){
        require(owner == msg.sender, 'NOT_AUTHORIZED');
        require(now > time, 'TIMELOCK_ACTIVE');
        uint totalBalance = getBalance();
        redeemCEth(totalBalance); 
        beneficiary.transfer(totalBalance);
        emit LogLumpSumWithdraw(beneficiary, totalBalance);
        selfdestruct(beneficiary);
    }

    /**
    * @notice mints Compound Token
    * Throws if msg.sender not owner.
    * Throws if not withrawal period.
    * @return bool 
    */
    function invest() public payable  whenDepositNotPaused() returns(bool) {
        require(owner == msg.sender, 'NOT_AUTHORIZED');
        (bool success,) = address(c).call.value(msg.value)(abi.encodeWithSignature("mint()"));
        require(success);
        emit LogInvest(beneficiary, msg.value);
        return true;
    }

    /**
    * @notice Compound Token function to redeem underlying asset 
    * @return bool
    */    
    function redeemCEth(
        uint256 amount
    ) private returns (bool) {
        // Retrieve your asset based on an amount of the asset
        require(c.redeemUnderlying(amount) == 0, "REDEEM_UNSUCCESSFULL");

    }


    /**
    * @notice Gets balance of underlying asset
    * @return uint
    */
    function getBalance() public returns(uint){

        //uint balanceERC20 = address(c).balanceOf(address(this));
        //uint balance = balanceERC20.mul(address(c).exchangeRateCurrent());
        uint balance = c.balanceOfUnderlying(address(this));
        return balance;
        }
    
    /*************************************** View Function ******************************/
    function getCounter() external view returns(uint){
        return counter;
    }
    
        
    
    /************************************ Fallback Function *****************************/
    // This is needed to receive ETH when calling `redeemCEth`
    fallback () external payable {
    }

    function recieve() public {}

     /**********************************Emergency Functions ****************************/
    function emergencyPauseDeposit() external {
        require(owner == msg.sender);
        pauseDeposit();
    }
    function emergencyPauseWithdraw() external {
        require(owner == msg.sender);
        pauseWithdraw();
    }
    function emergencyUnPauseDeposit() external {
        require(owner == msg.sender);
        unpauseDeposit();
    }
    function emergencyUnPauseWithdraw() external {
        require(owner == msg.sender);
        unpauseWithdraw();
    }

}


