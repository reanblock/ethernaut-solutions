// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/MagicNum.sol";

/*
    Solution script for the Ethernaut Level 9: MagicNumber

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in MagicNumberScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/MagicNumber.s.sol:MagicNumberScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/MagicNumber.s.sol/11155111
*/


contract MagicNumberScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xa42Fcab60D2f27Ab327799C731457361338c9404;
    MagicNum level18 = MagicNum(instance);

    function run() external {
        vm.startBroadcast();

        /*
            The following bytes code include the initialization opcodes which is the first part:

            600a600c600039600a6000f3

            Followed by the runtime opcodes which is the second part: 

            602a60805260206080f3

            Try this in evm.codes playground and you will get the following output:

            PUSH1 0x2a
            PUSH1 0x80
            MSTORE
            PUSH1 0x20
            PUSH1 0x80
            RETURN

            This code loads 42 into memory via the stack and then returns it.
        */
        bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
        address solver;

        assembly {
            solver := create(0, add(code, 0x20), mload(code))
        }

        level18.setSolver(solver);

        vm.stopBroadcast();
    }
}