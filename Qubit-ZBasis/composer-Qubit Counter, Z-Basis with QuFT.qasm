OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER, Z-BASIS 
// OPEN-QASM 3.0 BY IBM
gate HADAMARD() A
{
    h A;
} 
gate PHASE(THETA) A
{
    p(THETA) A;
}
gate CP(THETA) A, B
{
    PHASE(THETA / 2) A;
    CX A, B;
    PHASE(-THETA / 2) B;
    CX A, B;
    PHASE(THETA / 2) B;
}
gate QuFT_dagger A, B, C, D 
{
    swap B, C;
    swap A, D;
    HADAMARD A;
    // CONTROL-PHASE
    CP(-pi / 2) A, B;
    HADAMARD B;
    // CONTROL-PHASE 
    CP(-pi / 4) A, C;
    // CONTROL-PHASE
    CP(-pi / 2) B, C;
    // CONTROL-PHASE
    CP(-pi / 8) A, D;
    HADAMARD C;
    // CONTROL-PHASE
    CP(-pi / 4) B, D;
    // CONTROL-PHASE
    CP(-pi / 2) C, D;
    HADAMARD D;
}
// VARIABLE REGISTER INSTANSIATION
qubit[4]        Q;
bit[4]          PHASE_Z;
// HADAMARD GATE - PASS 1
HADAMARD        Q[0];
HADAMARD        Q[1];
HADAMARD        Q[2];
HADAMARD        Q[3];
// BAR 1 - RESET
barrier         Q;    //   @phaseDisk

// PHASE - PASS 1
PHASE(pi / 8)   Q[0];
PHASE(pi / 4)   Q[1];
PHASE(pi / 2)   Q[2];
PHASE(pi / 1)   Q[3];
// BAR 2 - TICK +1
barrier         Q;    //   @phaseDisk

// PHASE - PASS 2
PHASE(pi / 8)   Q[0];
PHASE(pi / 4)   Q[1];
PHASE(pi / 2)   Q[2];
PHASE(pi / 1)   Q[3];
// BAR 3 - TICK +1
barrier         Q;    //   @phaseDisk

// PHASE - PASS 3
PHASE(pi / 8)   Q[0];
PHASE(pi / 4)   Q[1];
PHASE(pi / 2)   Q[2];
PHASE(pi / 1)   Q[3];
// BAR 4 - TICK +1
barrier         Q;    //   @phaseDisk

// QUANTUM FOURIER TRANSFORM - DAGGER
QuFT_dagger     Q[0], 
                Q[1], 
                Q[2],
                Q[3];
// BAR 5 - POST-QFT DAGGER PHASE DISK
barrier         Q;    //   @phaseDisk

// BAR 6 - FANOUT
barrier         Q[0];
barrier         Q[1];
barrier         Q[2];
barrier         Q[3];
// FAN OUT
PHASE_Z = measure Q;
// END OF FILE