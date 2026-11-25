OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER (Z-BASIS), v1.1
// 11/22/2026 - Updated 11/24/2026
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
    CX                  A, 
                        B;
    PHASE(-THETA / 2)   B;
    CX                  A, 
                        B;
    PHASE(THETA / 2)    B;
}
// Inverse-Quantum Fourier Transform - converts the phase back into binary resulting in a clear measurement
gate QuFT_dagger        A, B, C, D 
{
    swap                B, 
                        C;
    swap                A, 
                        D;
    HADAMARD            A;
    // CONTROL-PHASE
    CP(-pi / 2)         A, 
                        B;
    HADAMARD            B;
    // CONTROL-PHASE 
    CP(-pi / 4)         A, 
                        C;
    // CONTROL-PHASE
    CP(-pi / 2)         B,
                        C;
    // CONTROL-PHASE
    CP(-pi / 8)         A,
                        D;
    HADAMARD            C;
    // CONTROL-PHASE
    CP(-pi / 4)         B,
                        D;
    // CONTROL-PHASE
    CP(-pi / 2)         C,
                        D;
    HADAMARD            D;
}
// X can be any float: negative counts down (best set in tick area), 
// 2.5 sits between 0x2 and 0x3, result will be coming from superposition in
// that case.
gate FLOATLOAD(X)            A, B, C, D 
{
    HADAMARD            A; 
    HADAMARD            B; 
    HADAMARD            C;
    HADAMARD            D;          // count = 0
    p(X * pi / 8)       A;          // then add X
    p(X * pi / 4)       B;
    p(X * pi / 2)       C;
    p(X * pi)           D;
}
// DEGLOAD - load raw phases, one angle per qubit (degrees)
gate DEGLOAD(T0, T1, T2, T3)  A, B, C, D
{
    HADAMARD            A;
    HADAMARD            B;
    HADAMARD            C;
    HADAMARD            D;
    p(T3 * pi / 180)    A;
    p(T2 * pi / 180)    B;
    p(T1 * pi / 180)    C;
    p(T0 * pi / 180)    D;
}
// RADLOAD - load raw phases, one angle per qubit (radians)
// Use decoder output directly: p(T0) A; - p(T3) D;
// MSB first: (phQ3, phQ2, phQ1, phQ0); k = 7 -> (pi, 3pi/2, 7pi/4, 7pi/8)
gate RADLOAD(T0, T1, T2, T3)  A, B, C, D
{
    HADAMARD            A;
    HADAMARD            B;
    HADAMARD            C;
    HADAMARD            D;
    p(T3)               A;
    p(T2)               B;
    p(T1)               C;
    p(T0)               D;
}
// TICK(N): add N to the count (N = 1 is a normal tick, N = -1 counts down).
gate TICK(N)            A, B, C, D 
{
    p(N * pi / 8)       A;
    p(N * pi / 4)       B;
    p(N * pi / 2)       C;
    p(N * pi)           D;
}
// -- END OF FUNCTIONS --
// VARIABLE REGISTER INSTANTIATION
qubit[4]                Q;
bit[4]                  COUNT;
//|MNEMONIC(PHASE)      |VARIABLES      |COMMENTS
///*
FLOATLOAD(6.5)          Q[0], 
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 1
//*/
/*
DEGLOAD(0, 180, 270, 135)
                        Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
*/
/*
RADLOAD(2 * pi, pi, 3 * pi / 2, 3 * pi / 4)
                        Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
*/
barrier                 Q;              // @phaseDisk

                                        // TICK - PASS 1
TICK(1)                 Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 2
barrier                 Q;              // @phaseDisk

                                        // TICK - PASS 2
TICK(1)                 Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 3
barrier                 Q;              // @phaseDisk

                                        // TICK - PASS 3
TICK(1)                 Q[0], 
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 4
barrier                 Q;              // @phaseDisk

                                        // TICK - PASS 4 - 16
TICK(13)                Q[0], 
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 5 - Flip Back to ORIGINAL VALUE

                                        // INVERSE-QUANTUM FOURIER TRANSFORM
QuFT_dagger             Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 6
barrier                 Q;              // @phaseDisk

                                        // BAR 7
barrier                 Q;
                                        // MEASURE
COUNT                   = measure Q;      // Measure Qubits 0-3, collapsing Superposition (if float) onto COUNT[0:3]
                                        // END OF FILE