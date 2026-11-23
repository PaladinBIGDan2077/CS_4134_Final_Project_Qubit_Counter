OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER (Z-BASIS)
// 11/20/2026
// Written by Daniel J Lomis
// Virginia Polytechnic Institute and State University
// CS 4134 - Quantum Computation and Information Processing
// OPENQASM 3.0 BY IBM

// BASIC COUNTER: reset to 0, three ticks of +1, inverse QFT, measure.
// EXPECTED: COUNT = 0x3  ->  100% on 0011 (Q[0] is the rightmost bit)

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
// -- END OF FUNCTIONS --
// VARIABLE REGISTER INSTANSIATION
qubit[4]                Q;
bit[4]                  COUNT;
//|MNEMONIC(PHASE)      |VARIABLES      |COMMENTS
										// HADAMARD GATE - RESET (COUNT = 0)
HADAMARD                Q[0];
HADAMARD                Q[1];
HADAMARD                Q[2];
HADAMARD                Q[3];
										// BAR 1
barrier                 Q;              // @phaseDisk

										// PHASE - PASS 1 (TICK +1)
PHASE(pi / 8)           Q[0];
PHASE(pi / 4)           Q[1];
PHASE(pi / 2)           Q[2];
PHASE(pi / 1)           Q[3];
										// BAR 2
barrier                 Q;              // @phaseDisk

										// PHASE - PASS 2 (TICK +1)
PHASE(pi / 8)           Q[0];
PHASE(pi / 4)           Q[1];
PHASE(pi / 2)           Q[2];
PHASE(pi / 1)           Q[3];
										// BAR 3
barrier                 Q;              // @phaseDisk

										// PHASE - PASS 3 (TICK +1)
PHASE(pi / 8)           Q[0];
PHASE(pi / 4)           Q[1];
PHASE(pi / 2)           Q[2];
PHASE(pi / 1)           Q[3];
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
										// MEASURE
COUNT                   = measure Q;      // Measure Qubits 0-3 onto COUNT[0:3]
										// END OF FILE
