OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER DECODER
// 11/24/2026
// Written by Daniel J Lomis
// Virginia Polytechnic Institute and State University
// CS 4134 - Quantum Computation and Information Processing
// OPENQASM 3.0 BY IBM

// Hadamard Gate - H gate (rewritten for traditional ALL-CAPs assembly)
gate HADAMARD           A 
{
    h                   A;
}
// PHASE - Phase Gate (rewritten for traditional ALL-CAPs assembly)
gate PHASE(THETA)       A
{
    p(THETA)            A;
}
// CP - Control-Phase performs phase change depending on I/O
gate CP(THETA)          A, B 
{
    PHASE(THETA / 2)    A;
    CX                  A, B;
    PHASE(-THETA / 2)   B;
    CX                  A, B;
    PHASE(THETA / 2)    B;
}
// LOAD - binary input, one bit per qubit (0 or 1)
// U(pi, 0, pi) = X exactly, U(0, 0, pi) = identity
gate LOAD(B0, B1, B2, B3) A, B, C, D
{
    U(B3 * pi, 0, pi)   A;
    U(B2 * pi, 0, pi)   B;
    U(B1 * pi, 0, pi)   C;
    U(B0 * pi, 0, pi)   D;
}

// -- END OF FUNCTIONS --
// VARIABLE REGISTER INSTANTIATION
qubit[4]                Q;
//|MNEMONIC(PHASE)      |VARIABLES      |COMMENTS
                                        // LOAD(B0..B3), MSB first; (0,1,1,1) = 7
LOAD(0, 1, 1, 0)                 
                        Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
                                        // Barrier Gate - Separation of Decoder Function (QFT)
barrier                 Q;
                                        // Quantum Fourier Transform (QFT)
HADAMARD                Q[3];
CP(pi / 2)              Q[2],
                        Q[3];
CP(pi / 4)              Q[1],
                        Q[3];
CP(pi / 8)              Q[0],
                        Q[3];
barrier                 Q;

HADAMARD                Q[2];
CP(pi / 2)              Q[1],
                        Q[2];
CP(pi / 4)              Q[0],
                        Q[2];
barrier                 Q;

HADAMARD                Q[1];
CP(pi / 2)              Q[0],
                        Q[1];
barrier                 Q;

HADAMARD                Q[0];
barrier                 Q;

swap                    Q[0], 
                        Q[3];
swap                    Q[1], 
                        Q[2];
                                        // END OF FILE