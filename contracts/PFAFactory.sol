pragma solidity ^0.6.0;

import "./PFAdmin.sol";
contract PFAFactory{

    address[] private  addr;
    constructor() public {
    }

    function deployPFA(address payable _beneficiary, address _owner) public returns(address payable) {
        PFAdmin pfa = new PFAdmin(_beneficiary, _owner);
        addr.push(address(pfa));
        return address(pfa);
    }
}
