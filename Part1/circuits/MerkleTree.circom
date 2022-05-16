pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2 ** n];
    signal output root;
    var hash[n+1][2 ** n];
    for (var i = 0; i < (2 ** n); i++) {
        hash[0][i] = leaves[i];
    }
    component hashes[2 ** n][2 ** n];
    for (var i = 1; i < (n + 1); i++) { // compute the hash of each level
        for (var j = 0; j < 2 ** (n - i); j++) {
            hashes[i][j] = Poseidon(2);
            hashes[i][j].inputs[0] <== hash[i - 1][2 * j];
            hashes[i][j].inputs[1] <== hash[i - 1][2 * j + 1];
            hash[i][j] <== hashes[i][j].out;
        }

    }
    root <== hash[n][0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    component hashes[n];
    for (var i = 0; i < n; i++) {
        hashes[i] = Poseidon(2);
        if (i == 0) {
            hashes[i].inputs[0] <== leaf;
            hashes[i].inputs[1] <== path_elements[i];
        } else {
            hashes[i].inputs[0] <== hashes[i - 1].out + (path_elements[i] - hashes[i - 1].out) * path_index[i];
            hashes[i].inputs[1] <== path_elements[i] - (path_elements[i] - hashes[i - 1].out) * path_index[i];
        }
    }
    root <== hashes[n - 1].out;
}