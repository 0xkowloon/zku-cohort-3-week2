pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var numberOfLeafHashers = 2 ** n - 1;

    var numberOfHashes = 0;
    for (var i = 0; i < n; i++) {
        numberOfHashes += 2 ** i;
    }

    component hashers[numberOfHashes];

    for (var i = 0; i < numberOfHashes; i++) {
        hashers[i] = Poseidon(2);
    }

    for (var i = 0; i < numberOfLeafHashers; i++) {
        for (var j = 0; j < 2; j++) {
            hashers[i].inputs[j] <== leaves[i * 2 + j];
        }
    }

    var k = 0;
    for (var i = numberOfLeafHashers; i < numberOfHashes; i++) {
        for (var j = 0; j < 2; j++) {
            hashers[i].inputs[j] <== hashers[k * 2 + j].out;
        }
        k++;
    }

    root <== hashers[numberOfHashes-1].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    signal paths[n+1];
    paths[0] <== leaf;

    component hashes[n];
    component switchers[n];

    for (var i = 0; i < n; i++) {
        switchers[i] = Switcher();
        switchers[i].sel <== path_index[i];
        switchers[i].L <== paths[i];
        switchers[i].R <== path_elements[i];

        hashes[i] = Poseidon(2);
        hashes[i].inputs[0] <== switchers[i].outL;
        hashes[i].inputs[1] <== switchers[i].outR;

        paths[i+1] <== hashes[i].out;
    }

    root <== paths[n];
}