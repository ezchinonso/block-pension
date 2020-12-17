pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./PFAdmin.sol";
import "./PFAFactory.sol";

//import "./PFCustodian.sol";

contract PensionScheme is PFAFactory, ReentrancyGuard{
    using SafeMath for uint256;


    mapping(uint => Pension) private pensions;
    
    /**
    * @notice instanceof Pension fund admin 
    */
    //PFAdmin private admin;

    /**
    * @notice  beneficiary id counter
    */
    uint public pensionID;

    
    /**
    * @notice Container/Struct for Pension info
    * beneficiary - The address of the beneficiary to enjoy pension benefits
    * sponsor - The address that contributes to the `beneficiary` pension benefits - Usually an employer 
    * retirementTime - The unix timestamp for when the `beneficiary` retires
    * pAmount - The minimum amount of money the `sponsor` is required to contribute to the `beneficiary` pension
    * vpAmount - The amount of money the `beneficiary` voluntarily contributes to their pension.
    * remainingBalance - Keeps track of beneficiary's contribution and withdrawals
    */
    struct Pension {
        address payable beneficiary;
        address sponsor;
        //address payable pCustodian
        PFAdmin pfAdmin;
        uint retirementTime;
        // pAmount means pension amount
        uint pAmount;
        // vpAmount means voluntary pension amount 
        uint vpAmount;
        uint totalContribution;
        bool annuitizeWithdrawals;
        bool exists;
    }

    /********************************* Events *********************************/
    /** 
    * @notice Emits when a beneficiary is registered 
    */
    event Register(uint indexed pensionID, address beneficiary, address sponsor);

    /** 
    * @notice Emits when a deposit is made 
    */
    event Deposit(uint indexed pensionID, address sender, uint amount, uint contributions );

     /** 
    * @notice Emits when withdrawal Type is changed
    */
    event WithdrawalTypeChanged(uint pensionID);
    
    /**
    * @notice Emits when a beneficiary makes a withdrawal
    */
    event Withdraw(uint indexed beneficiaryID, uint amount);

    /**
    * @notice Emits when a beneficiary changes PFA
    event NewPFA(uint indexed pensionID, address oldPFA, address newPFA)
    */

    /********************************* Modifiers ****************************/

    /** 
    * @dev Throws if caller is not beneficiary 
    */
    modifier onlyBeneficiary(uint id) {
        require(msg.sender == pensions[id].beneficiary, 'CALLER_IS_NOT_BENEFICIARY');
        _;
    }

    /**
    * @dev Throws if beneficiary is not yet retired  
    */
    modifier isRetired(uint id){
        require(now >= pensions[id].retirementTime, 'NOT_RETIRED');
        _; 
    }
    
     /**
    * @dev Throws if beneficiary is retired  
    */
    modifier isNotRetired(uint id){
        require(now < pensions[id].retirementTime, 'RETIRED');
        _;
    }

    /**
    * @dev Throws if beneficiary does not exist
    */
    modifier pensionExists(uint id){
        require(pensions[id].exists == true, "GHOST_BENEFICIARY");
        _;
    }

    /**
    * @dev Throws if pensions contribution doesn't matchup! 
    modifier checkBalance(uint id){
        _;
        require(pensions[id].pAmount.add(pensions[id].vpAmount) == pensions[id].totalContribution);
    };
    */

    /************************** Functions ****************************/
    constructor() public {
        pensionID = 2020;
    }

    /**
    * @notice `sponsor` registers `beneficiary` into the pension scheme
    * Throws if beneficiary is zero address, the contract itself or msg.sender
    * Throws if pension amount is less than zero
    * @param _beneficiary The address to enjoy pension benefits
    * @param rTime The unix timestamp of when beneficiary retires
    * @return uint id of the beneficiary
    */
    function register(address payable _beneficiary, uint rTime)
      public payable
      returns(uint) 
      {
        require(_beneficiary != address(0x00), 'INVALID_ADDR');
        require(_beneficiary != address(this), 'INVALID_ADDR');
        require(_beneficiary != msg.sender, 'SELF_REGISTER');
        require(rTime >= now, 'RTIME_INVALID');
        address payable admin = deployPFA(_beneficiary, address(this));
        uint id = pensionID;
        pensions[id] = Pension({
            beneficiary: _beneficiary,
            sponsor: msg.sender,
            //pCustodian: pfc,
            pfAdmin: PFAdmin(admin),
            retirementTime: rTime,
            pAmount: 0,
            vpAmount: 0,
            totalContribution: 0,
            exists: true,
            annuitizeWithdrawals: true
        });
        emit Register(id, _beneficiary, msg.sender);
        pensionID = id.add(1);
        return id;
    }

    /**
    * @notice Allows deposits to be made by anyone into beneficiary's pension fund and 
    *  Transfers the amount to the beneficiary's pension fund administrator.
    * @dev Throws if deposit is less than msg.value or zero
    * Throws if call to pension fund admin is not successful
    * @param id The pension id of the beneficiary
    * @return The total contribution made to the beneficiary pension
    */
    function deposit(uint id) 
      public payable pensionExists(id)
      returns(uint){
        uint256 amount = msg.value;
        require(amount >= 0, "INVALID_AMT");
        if(msg.sender == pensions[id].sponsor){
            
            /**IERC20(DAI).transferFrom(msg.sender, address(this), amount), "TRANSFER_FAILURE");*/
            (bool success,) = address(pensions[id].pfAdmin).call.value(amount)(abi.encodeWithSignature("invest()"));
            require(success, "DEPOSIT_FAILED");
            pensions[id].pAmount = (pensions[id].pAmount).add(amount);
            pensions[id].totalContribution = pensions[id].pAmount.add(pensions[id].vpAmount);
            emit Deposit(id, msg.sender, amount, pensions[id].totalContribution);
            return pensions[id].totalContribution;
        }else {
            
            /**IERC20(DAI).transferFrom(msg.sender, address(this), amount), "TRANSFER_FAILURE");*/
            (bool success,) = address(pensions[id].pfAdmin).call.value(amount)(abi.encodeWithSignature("invest()"));
            require(success, "DEPOSIT_FAILED");
            pensions[id].vpAmount = (pensions[id].vpAmount).add(amount);
            pensions[id].totalContribution = pensions[id].pAmount.add(pensions[id].vpAmount);
            emit Deposit(id, msg.sender, amount, pensions[id].totalContribution);
            return pensions[id].totalContribution;
        }
    }

     /**
    * @notice Change the type of withdrawal to lumpSum withdraw
    * @dev Throws if pension id doesn't exist
    * Throws if caller is beneficiary
    * @param id The pension id of the beneficiary
    */
    function changeWithdrawalType(uint id) public pensionExists(id) onlyBeneficiary(id) {
        require(pensions[id].annuitizeWithdrawals);
        pensions[id].annuitizeWithdrawals = false;
        emit WithdrawalTypeChanged(id);
    }

    /** 
    * @notice Enables `beneficiary` to withdraw pension after retirement
    * @dev Throws if caller is not beneficiary. 
    * Throws if beneficiary is not retired
    * Throws if pension id is invalid i.e Doesn't exist 
    * Throws if call is reentrant
    * Throws if contract is paused
    * @param id The pension id of the beneficiary
    */
    function withdrawPension(uint id) 
      public payable isRetired(id) onlyBeneficiary(id) pensionExists(id) nonReentrant()
      {
          require(pensions[id].totalContribution > 0, 'ZERO_CONTRIBUTIONS');
          
          if(pensions[id].annuitizeWithdrawals){
              if (getCount(id) == 23){
                  delete pensions[id];
              }
              (bool success,) = address(pensions[id].pfAdmin).call.value(0)(abi.encodeWithSignature('annuitizedWithdraw()'));
              require(success, "ANNUITY_WITHDRAW_FAILED");
          }else{
              (bool success,) = address(pensions[id].pfAdmin).call.value(0)(abi.encodeWithSignature('lumpSumWithdraw()'));
              require(success, "LUMPSUM_WITHDRAW_FAILED");
              delete pensions[id];
          }

          emit Withdraw(id, msg.value);
    }

    /** 
    * @notice changes pension sponsor
    * @dev Throws if pensioner(pension id) doesn't exist
    * @param id The pension id of the beneficiary
    * @param newSponsor new sponsor
    */
    function changeSponsor(uint id, address newSponsor) public pensionExists(id) onlyBeneficiary(id) {
        pensions[id].sponsor = newSponsor;
    }

    


    /********************************* view functions **********************/

    /** 
    * @notice Returns beneficiary balances. Returns (0,0,0) if no deposit has being made.
    * @dev Throws if pension id is invalid i.e Doesn't exist 
    * @param id The id of the beneficiary
    * @return a b c
    */
    function balanceOf(uint id) public view 
        returns(
            uint a, 
            uint b, 
            uint c){
            a = pensions[id].pAmount;
            b = pensions[id].vpAmount;
            c = pensions[id].totalContribution;
    }

    /** 
    * @notice returns PFA address
    * @dev Throws if pensioner(pension id) doesn't exist
    * @param id The pension id of the beneficiary
    * @return address
    */
    function getPFA(uint id) public view pensionExists(id) returns(address){
        return address(pensions[id].pfAdmin);
    }

    /** 
    * @notice Checks if beneficiary is retired
    * @dev Throws if pensioner(pension id) doesn't exist
    * @param id The pension id of the beneficiary
    * @return bool object, true=if beneficiary is retired, otherwise false
    */
    function checkRetired(uint id) public view pensionExists(id) returns(bool) {
        Pension memory pension = pensions[id];
        if(now > pension.retirementTime){
            return true;
        } else {
            return false;
        }
    }

    function getPensionInfo(uint id) public view returns(address beneficiary, address sponsor, uint rTime, uint totalContribution, bool exist){
        beneficiary= pensions[id].beneficiary;
        sponsor= pensions[id].sponsor;
        rTime= pensions[id].retirementTime;
        totalContribution= pensions[id].totalContribution;
        exist= pensions[id].exists;
        return (beneficiary, sponsor, rTime, totalContribution, exist);
    }

    function getCount(uint id) public view returns(uint) {
        
        return pensions[id].pfAdmin.getCounter();
    }
    

    /** Recieve Ether function */
    function recieve() public {}

     /************************ NOT IMPLEMENTED ******************/
    /**
    *function changePFA(uint id, address addr) public 
    *  onlyBeneficiary(id){
    *   pensions[id].pfAdmin = addr;
    *}; 
    */
    /** 
     *function _claimBenefits() public {}

     *function _calculateAnnuity() public view returns(uint){
     */
    
    
}