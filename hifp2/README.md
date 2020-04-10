# HiFP2.0

## Compiling the OpenCL Kernel
The top-level OpenCL kernel file is kernel/dwt1.cl.

To compile the OpenCL kernel, run:
```
aoc kernel/dwt1.cl -o bin/dwt1.aocx --board=<board>
```
where <board> matches the board you want to target. The -o bin/dwt1.aocx argument is used to place the compiled binary in the location that the host program expects.

If you are unsure of the boards available, use the following command to list available boards:
```
aoc --list-boards
```

Compiling for Emulator
To use the emulation flow, the compilation command just needs to be modified slightly:
```
aoc -march=emulator kernel/dwt1.cl -o bin/dwt1.aocx
```

## Compiling the Host Program
To compile the host program, run:
```
make
```

The compiled host program will be located at bin/host.

Plain make command:
```
g++ -O2 -fPIC -I./common/inc \
    -I/root/inteldevstack/intelFPGA_pro/hld/host/include \
    host/src/main.cpp common/src/AOCLUtils/opencl.cpp common/src/AOCLUtils/options.cpp \
    -L/root/inteldevstack/intelFPGA_pro/hld/linux64/lib \
    -L/root/inteldevstack/a10_gx_pac_ias_1_2_pv/opencl/opencl_bsp/linux64/lib \
    -L/root/inteldevstack/intelFPGA_pro/hld/host/linux64/lib \
    -Wl,--no-as-needed -lalteracl  -lintel_opae_mmd -lrt -lelf \
    -lrt -lpthread \
	-o bin/host
```

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
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 bin/host
```

Host Parameters
The general command-line for the host program is:
```
bin/host 
```