OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER, Z-BASIS
// Written by Daniel J Lomis
// OPEN-QASM 3.0 BY IBM

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
// Inverse-Quantum Fourier Transform - converts the phase back into binary resulting in a clear measurement
gate QuFT_dagger        A, B, C, D 
{
    swap                B, C;
    swap                A, D;
    HADAMARD            A;
    // CONTROL-PHASE
    CP(-pi / 2)         A, B;
    HADAMARD            B;
    // CONTROL-PHASE 
    CP(-pi / 4)         A, C;
    // CONTROL-PHASE
    CP(-pi / 2)         B, C;
    // CONTROL-PHASE
    CP(-pi / 8)         A, D;
    HADAMARD            C;
    // CONTROL-PHASE
    CP(-pi / 4)         B, D;
    // CONTROL-PHASE
    CP(-pi / 2)         C, D;
    HADAMARD            D;
}
// X can be any number: negative counts down, 2.5 sits between 2 and 3.
gate LOAD(X)            A, B, C, D 
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
// TICK(N): add N to the count (N = 1 is a normal tick, N = -1 counts down).
gate TICK(N)            A, B, C, D 
{
    p(N * pi / 8)       A;
    p(N * pi / 4)       B;
    p(N * pi / 2)       C;
    p(N * pi)           D;
}
// -- END OF FUNCTIONS --
// VARIABLE REGISTER INSTANSIATION
qubit[4]                Q;
bit[4]                  PHASE_Z;
//|MNEMONIC(PHASE)      |VARIABLES      |COMMENTS
                                        // LOAD - USE ZERO FOR DEFAULT
LOAD(0)                 Q[0], 
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 1
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

                                        // INVERSE-QUANTUM FOURIER TRANSFORM
QuFT_dagger             Q[0],
                        Q[1],
                        Q[2],
                        Q[3];
                                        // BAR 5
barrier                 Q;              // @phaseDisk

                                        // BAR 6
barrier                 Q;
                                        // FAN OUT
PHASE_Z                 = measure Q;    // Measure Qubits 0-3, collapsing Superposition onto PHASE_Z[0:3]
                                        // END OF FILE