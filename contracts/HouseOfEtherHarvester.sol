// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4;

/**
 * @title House of Ether - Harvester contract!
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
 
contract HouseOfEtherHarvester {

    struct User {
        address userAddress;
        string userMessage;
    }

    mapping(address user => string user_message) public userMessages;
    address[] public userAddresses;
    address payable public admin;
    bool public acceptingEntries = true;

    //This is used for functions that only the creator is allowed to use. Simply add the modifier at the function's declaration.
    modifier onlyOwner {
        require(
            msg.sender == admin, 
            "Only the owner can call this function."
        );
        _;
    }

    constructor() {
        admin = payable(msg.sender); // 'msg.sender' is sender of the current call. Since this is the constructor, the msg.sender is the contract deployer, i.e. sfounis :-D
        //emit OwnerSet(address(0), owner);
    }

    //Function to deposit Ether into this contract.
    //Call this function along with some Ether!
    //The balance of this contract will be automatically updated.
    function depositSomeEthers() public payable {}

    /**
     * @dev Set the flag of accepting new entries or not. Keep in mind, this test contract should be paused at some time, as the address array can grow arbitrarily long!
        Plus, the House of Ether workshops in Kavala (1st iteration) should finish by 2025, so they won't run forever!
        The flag is only changeable by the contract's deployer
     * @param flag to set the `acceptingEntries` variable to.
     */
    function setAcceptingNewEntries(bool flag) public onlyOwner {
        acceptingEntries = flag;
    }

    /**
     * @dev Store a message and the sender address in the contract.
     * @param message (as a simple string) to store
     */
    function storeMessage(string memory message) public {
        require(
            bytes(userMessages[msg.sender]).length == 0,
            "You've already stored a message in the past, sorry!"
        );
        //Add the address to our list of addresses recorded
        userAddresses.push(msg.sender);
        //Aaaaaaaaaand add the message to the mapping!
        userMessages[msg.sender] = message;
    }

    /**
     * @dev Get the full list of addresess that have previously participated (registered) in the Harvester contract.
     */
    function getOnlyAddressList() public view 
            returns (address[] memory addressList)
    {
        return userAddresses;
    }

    function getOnlyAddressListLength() public view 
            returns (uint256 length)
    {
        return userAddresses.length;
    }

    /**
     * @dev Get all addresses & their associated user messages from the Harvester contract
     */
    function getFullAddressListAndMessages() public view 
            returns (User[] memory addressListWithMessages)
    {
        //Initialize our dynamic array according to however many address+message pairs (tuples) we've got
        User[] memory toReturn = new User[](userAddresses.length);
        //Iterate and populate the toReturn array
        for(uint i = 0; i < userAddresses.length; i++) {
            toReturn[i].userAddress = userAddresses[i];
            toReturn[i].userMessage = userMessages[userAddresses[i]];
        }
        //Finally, throw it back to the user
        return toReturn;
    }

    function distributeTestEtherToMembers() public onlyOwner {
        //Only begin this operation if the contract has enough balance for every participant to receive 5 Sepolia Ethers.
        require(userAddresses.length > 0, "Nobody has participated yet, I've got no-one to send ethers to!");
        require(address(this).balance >= userAddresses.length * 5000000000000000000, "The contract doesn't have enough ether to send 5 Ethers to every participant!");

        //Now, iterate through every address in our storage and send 5 ethers to everyone. We should have enough, as we passed the previous require statements.
        for(uint i=0; i < userAddresses.length; i++)
        {
            (bool success, ) = payable(userAddresses[i]).call{value: 5000000000000000000}(""); //Enjoy the 5 Ethers == 5000000000000000000 wei :-)
            require(success, "Something went wrong when batch-transfering!");
        }
    }

    function emergencySiphon() public onlyOwner {
        //Get current balance held in the contract...
        uint256 amount = address(this).balance;
        // send all Ether to the admin, because he probably fucked up and wants to try again.
        (bool success,) = admin.call{value: amount}("");
        require(success, "Failed to send Ether :-(");
    }

}