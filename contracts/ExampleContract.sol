// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract ExampleContract {
    
    //State variables go here
    uint256 private number;
    
    function setNumber(uint256 given_number) public  {
        number = given_number;
    }

    // Helper function defined outside of a contract
    function getNumber() public view returns (uint256) {
        return number;
    }
}