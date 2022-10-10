// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract SubOverflow {
    // Modify this function so that on overflow it returns the value 0
    // otherwise it should return x - y
    function subtract(uint256 x, uint256 y) public pure returns (uint256) {
        // Write assembly code that handles overflows
        assembly {
            if lt(x, y) {
                return(0, 0)
            }
            mstore(0,sub(x,y))
            return (0, 0x20)
        }
    }
}
