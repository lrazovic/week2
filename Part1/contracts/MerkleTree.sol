//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        hashes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        init();
    }

    // `init()` keeps the tree updated
    function init() internal {
        uint256[4] memory level1;
        uint256[2] memory level2;
        for (uint256 i = 0; i < 8; i += 2) {
            level1[i / 2] = PoseidonT3.poseidon([hashes[i], hashes[i + 1]]);
        }

        for (uint256 i = 0; i < 4; i += 2) {
            level2[i / 2] = PoseidonT3.poseidon([level1[i], level1[i + 1]]);
        }

        root = PoseidonT3.poseidon([level2[0], level2[1]]);

        hashes[8] = level1[0];
        hashes[9] = level1[1];
        hashes[10] = level1[2];
        hashes[11] = level1[3];
        hashes[12] = level2[0];
        hashes[13] = level2[1];
    }

    // Add a new leaf and update the tree
    // Merkle tree of 3 levels have up to 8 leaves)
    function addLeaf(uint256 hashedLeaf) public returns (uint256) {
        require(index < 8, "merkle tree is full!");
        uint256 prevIndex = index;
        hashes[index] = hashedLeaf;
        index++;
        init();
        return prevIndex;
    }

    function verify(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        return verifyProof(a, b, c, input);
    }
}
