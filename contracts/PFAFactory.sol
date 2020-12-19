pragma solidity ^0.6.0;

import "./PFAdmin.sol";
contract PFAFactory{

    address[] addr;

    event PFADeployed(address indexed pfa, address indexed _beneficiary);
    constructor() public {

    }

    function lengthPFA() public returns(uint) {
        return addr.length;
    }
    function deployPFA(address payable _beneficiary, address _owner) external returns(address payable) {
        PFAdmin pfa = new PFAdmin(_beneficiary, _owner);
        addr.push(address(pfa));
        emit PFADeployed(address(pfa), _beneficiary);
        return address(pfa);
    }
}
