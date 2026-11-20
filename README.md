# CS: 4134, Optional Final Project (QuBit Counter, XYZ-Basis)
## Written By Daniel J. Lomis

### A Description

The Qubit Counter is a quantum version of a binary counter that stores its count in the phases of its qubits instead of in bits. A classical counter records a number by which bits are 1. Here, each of the four qubits holds part of the number as an angle, and together the angles encode the count. A reset (a Hadamard on every qubit) sets the count to zero. Each tick then turns every qubit by a fixed angle (π/8, π/4, π/2 and π for qubits 0 to 3), so the top qubit flips every tick, the next every two ticks, and so on, like the divide-by-two chain of a ripple counter. Because every qubit updates independently, the counter needs no carry chain. It wraps around modulo 16 on its own, counts down with negative angles, and can even hold fractional counts.

To read the count, the program applies the inverse quantum Fourier transform, which converts the angles back into an ordinary binary number before measurement. Integer counts are read exactly. A fractional count spreads over the two nearest integers in the pattern that phase estimation predicts. The program can also read the phases directly through a second output, the "phase bus," by measuring each qubit in the X and Y bases. That shows the angle on each qubit as the counter runs.

The code is written in Assembly, more specifically IBM's OpenQASM 3.0. Currently, testing is done through IBM Quantum Composer. Eventually, the project will be retooled for IBM's Qiskit, which allows the use of customized experiments on a simulator, which compare the results with the theoretical predictions, and saves figures and tables of the outcomes. Currently, no error is baked into the simulator at the moment. Once error is added via a special noisy file, then those errors will come from the readout's two-qubit gates, since each tick uses only single-qubit gates.

### The Math

## The math

**Storing the count.** A 4-qubit counter (N = 2⁴ = 16) holds the count x as one angle per qubit:

    φⱼ = 2π · x · 2ʲ / 16  (mod 2π)        j = 0, 1, 2, 3  (q[0] is the least significant)

Each qubit is in the state (|0⟩ + e^{iφⱼ}|1⟩)/√2, so measuring it directly gives 0 or 1 with
50% each. The count is stored only in the phases.

**Reset, load and tick.**

| Operation | Gates | Effect on the phases |
|---|---|---|
| Reset | H on every qubit | φⱼ = 0 (count = 0) |
| Tick by c | P(2π · c · 2ʲ / 16) on qubit j | φⱼ → φⱼ + 2π · c · 2ʲ / 16 (count += c) |
| Load x | reset, then tick by x | count = x |

For c = 1 the tick angles are π/8, π/4, π/2, π for q[0] to q[3]. The angles wrap at 2π, so the
count wraps modulo 16 with no carry logic, and a negative c counts down.

**Reading the count.** The inverse QFT (QFT†) maps the phases back to the binary number x,
which is then measured. For a total count c, the probability of reading y is

    P(y | c) = | (1/16) · Σₓ e^{2πi · x · (c − y) / 16} |²        (sum over x = 0 … 15)

If c is a whole number, P(c mod 16) = 1: the count is read exactly. If c is fractional, the
probability spreads over the nearest whole numbers (for c = 2.37: P(2) = 0.624, P(3) = 0.216).

**From the 4-bit output back to the phases.** For a measured output y:

    φⱼ = 2π · y · 2ʲ / 16  (mod 2π)  =  22.5° · y · 2ʲ  (mod 360°)

Equivalently, qubit j's phase, as a fraction of a full turn, is the binary fraction formed by
the lowest 4 − j bits of y. Example, y = 3 = 0011:

| Qubit | Binary fraction | Phase |
|---|---|---|
| q[3] | 0.1₂ = 1/2 turn | 180° |
| q[2] | 0.11₂ = 3/4 turn | 270° |
| q[1] | 0.011₂ = 3/8 turn | 135° |
| q[0] | 0.0011₂ = 3/16 turn | 67.5° |
