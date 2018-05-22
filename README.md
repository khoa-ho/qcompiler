QCompiler
=========

Author
------

Khoa Ho [hokhoa@grinnell.edu], Jeung Rac Lee [leejeung@grinnell.edu]


Overview
--------

A compiler translating a mock-up quantum programming language into a quantum assembly language, QASM.
Our mock-up language is very similar to QASM, but functional aspect is added to the gate application.

Refer to this paper for more details about QASM:
https://arxiv.org/pdf/1707.03429.pdf


Usage
-----

### Requirements:
OCaml (>= 4.02.3) [https://ocaml.org/docs/install.html]

### Build
Following are useful Makefile commands

'make (make all)': build the project
'make test': build and run the test suite
'make clean': clean the binaries

### Execute
First, build the project

'$ make'

Then run the compiler,

'$ ./compiler.native [source_file_paths]'

### Supporting Open QASM statements

|Statement                       | Description                        |
|--------------------------------|------------------------------------|
|OPENQASM 2.0;                   | Denotes a file in Open QASM format |
|qreg name[size];                | Declare a named register of qubits |
|creg name[size];                | Declare a named register of bits   |
|include "filename";             | Open and parse another source file |
|gate name(params) qargs { body }| Declare a unitary gate             |
|CX qubit|qreg,qubit|qreg;       | Apply built-in CNOT gate(s)        |
|measure qubit|qreg -> bit|creg; | Make measurement(s) in Z basis     |

### Examples

## Sample quantunm algorithms

# Deutsch–Jozsa algorithm in QASM,
from https://github.com/QISKit/openqasm/blob/master/examples/ibmqx2/Deutsch_Algorithm.qasm
```
OPENQASM 2.0;
include "qelib1.inc";

qreg q[5];
creg c[5];

x q[4];
h q[3];
h q[4];
cx q[3],q[4];
h q[3];
measure q[3] -> c[3];
```

Compiled version is,
```
OPENQASM 2.0;
include "qelib1.inc";

qreg q[5];
creg c[5];

q[4] > x > h;
q[3] > h;
cx q[3],q[4];
q[3] > h;
measure q[3] -> c[3];
```

# Grover's Algorithm in QASM,
from https://github.com/sampaio96/Quantum-Computing/blob/master/Grover's%20Algorithm/Grover_N_2_A_00.qasm

Note: Clifford gate, s, needs to be supported in order to compile this code.

```
OPENQASM 2.0;
include "qelib1.inc";


qreg q[5];
creg c[5];

h q[1];
h q[2];
s q[1];
s q[2];
h q[2];
cx q[1],q[2];
h q[2];
s q[1];
s q[2];
h q[1];
h q[2];
x q[1];
x q[2];
h q[2];
cx q[1],q[2];
h q[2];
x q[1];
x q[2];
h q[1];
h q[2];
measure q[1] -> c[1];
measure q[2] -> c[2];
```

Compiled version will be, when Clifford operations are supported,
```
OPENQASM 2.0;
include "qelib1.inc";


qreg q[5];
creg c[5];

q[1] > h > s;
q[2] > h > s > h;
cx q[1],q[2];
q[2] > h > s > h > x > h;
q[1] > s > h > x;
cx q[1],q[2];
q[2] > h > x > h;
q[1] > x > h;
measure q[1] -> c[1];
measure q[2] -> c[2];
```
