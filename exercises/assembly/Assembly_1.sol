// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Intro {
    function intro() public pure returns (uint16) {
        assembly {
            let mol := 420
            mstore(0, mol)
            return (0, 0x20)
        }
    }
}
