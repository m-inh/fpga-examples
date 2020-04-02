# Vector Add
This readme file for the Vector Add OpenCL Design Example contains information about the design example package


## Description
This example runs a basic OpenCL kernel that performs C = A + B where A, B and C are N-element vectors. The kernel is intentionally kept simple and not optimized to achieve maximum performance on the FPGA.

In addition to demonstrating the basic OpenCL API, this example supports partitioning the problem across multiple OpenCL devices, if available. If there are M available devices, the problem is divided so that each device operates on N/M points. The host program assumes that all devices are of the same type (that is, the same binary can be used, but the code can be generalized to support different device types easily.

## Compiling the OpenCL Kernel
The top-level OpenCL kernel file is device/vector_add.cl.

To compile the OpenCL kernel, run:
```
aoc device/vector_add.cl -o bin/vector_add.aocx --board=<board>
```
where <board> matches the board you want to target. The -o bin/vector_add.aocx argument is used to place the compiled binary in the location that the host program expects.

If you are unsure of the boards available, use the following command to list available boards:
```
aoc --list-boards
```

Compiling for Emulator
To use the emulation flow, the compilation command just needs to be modified slightly:
```
aoc -march=emulator device/vector_add.cl -o bin/vector_add.aocx
```

## Compiling the Host Program
To compile the host program, run:
```
make
```

The compiled host program will be located at bin/host.

## Running the Host Program
Before running the host program, you should have compiled the OpenCL kernel and the host program. Refer to the above sections if you have not completed those steps.

To run the host program on hardware, execute:
```
bin/host
```

The output will include a wall-clock time of the OpenCL execution time and the kernel time as reported by the OpenCL event profiling API. The host program includes verification against the host CPU, printing out "PASS" when the results match.

## Running with the Emulator
Prior to running the emulation flow, ensure that you have compiled the kernel for emulation. Refer to the above sections if you have not done so. Also, please set up your environment for emulation. Please see the Intel(R) FPGA SDK for OpenCL(TM) Programming Guide for more information.

For this example design, the suggested emulation command is:
```
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 bin/host -n=10000
```

Host Parameters
The general command-line for the host program is:
```
bin/host [-n=<integer>]
```

where the one parameter is:

Parameter|Type|Default|Description
|---|---|---|---|
-n=`integer`|Optional|100000|Number of values to add.