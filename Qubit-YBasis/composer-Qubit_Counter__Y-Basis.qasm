OPENQASM 3.0;
include "stdgates.inc";
// QUBIT COUNTER (Y-BASIS)
// 11/23/2026
// Written by Daniel J Lomis
// Virginia Polytechnic Institute and State University
// CS 4134 - Quantum Computation and Information Processing
// OPENQASM 3.0 BY IBM

// Y-BASIS READS THE PHASE BUS: Each qubit is turned back by
// 90 deg (S_DAGGER), then rotated with a Hadamard, so that P(0) - P(1) on
// bit j gives <Y_j> = sin(phi_j), where phi_j = 2 * pi * COUNT * 2^j / 16.
// Together with the X-basis file: PHI = atan2(<Y>, <X>).
//
// EXPECTED (COUNT = 6.5)   |PHASE      |<Y> = sin(PHI) |P(1) ON PHASE_Y[j]
//  Q[0]                    | 146.25 deg|  +0.556       | 0.222
//  Q[1]                    | 292.50 deg|  -0.924       | 0.962
//  Q[2]                    | 225.00 deg|  -0.707       | 0.854
//  Q[3]                    |  90.00 deg|  +1.000       | 0.000

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
// S_DAGGER - Inverse S gate (S = square root of Z): turns the phase back by
// 90 deg (rewritten for traditional ALL-CAPs assembly)
gate S_DAGGER           A
{
	sdg                 A;
}
// X can be any positive float: negative counts down (best set in tick area),
// 2.5 sits between 0x2 and 0x3; in the Y-basis every value gives a clean phase.
gate LOAD(X)            A, B, C, D
{
	HADAMARD            A;
	HADAMARD            B;
	HADAMARD            C;
	HADAMARD            D;          // count = 0
	PHASE(X * pi / 8)   A;          // then add X
	PHASE(X * pi / 4)   B;
	PHASE(X * pi / 2)   C;
	PHASE(X * pi)       D;
}
// TICK(N): add N to the count (N = 1 is a normal tick, N = -1 counts down).
gate TICK(N)            A, B, C, D
{
	PHASE(N * pi / 8)   A;
	PHASE(N * pi / 4)   B;
	PHASE(N * pi / 2)   C;
	PHASE(N * pi)       D;
}
// -- END OF FUNCTIONS --
// VARIABLE REGISTER INSTANSIATION
qubit[4]                Q;
bit[4]                  PHASE_Y;
//|MNEMONIC(PHASE)      |VARIABLES      |COMMENTS
										// LOAD - USE ZERO FOR DEFAULT
LOAD(3.5)               Q[0],
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

										// S-DAGGER GATE (BASIS Y, STEP 1)
S_DAGGER                Q[0];           // every phase line turns back 90 deg
S_DAGGER                Q[1];
S_DAGGER                Q[2];
S_DAGGER                Q[3];
										// BAR 5
barrier                 Q;              // @phaseDisk

										// HADAMARD GATE (BASIS Y, STEP 2)
HADAMARD                Q[0];           // phase -> fill: P(1) = (1 - sin(PHI)) / 2
HADAMARD                Q[1];
HADAMARD                Q[2];
HADAMARD                Q[3];
										// BAR 6
barrier                 Q;              // @phaseDisk

										// MEASURE
PHASE_Y               = measure Q;      // Measure Qubits 0-3, P(0) - P(1) on each bit gives sin(PHI)
										// END OF FILE