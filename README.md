# RISC-V Register Pressure Tests

A hands-on experiment demonstrating how **Register File Size** impacts compiler optimization and software performance.

Using [`rv32emu`](https://github.com/sysprog21/rv32emu) and GCC register-fixing flags (`-ffixed-reg`), we simulate processors with varying register counts (32 down to 16) to verify the performance "Cliff".

## Usage

To compile the experiments and generate the full ASCII report:

```bash
make clean && make report
```

Expected Output:

```text
=================================================================================================================
                          EXPERIMENT 1: REGISTER SUPPLY SWEEP (THE CLIFF)                                        
=================================================================================================================
METRIC              |       NORMAL |        LIGHT |       MIDDLE |        HEAVY |     RESTRICT
                    |    (32 Regs) |   (~28 Regs) |   (~24 Regs) |   (~20 Regs) |   (~16 Regs)
--------------------|--------------|--------------|--------------|--------------|--------------
Cycles              |        65075 |        65079 |        73086 |        84086 |        99086
Relative Perf       |        1.00x |        1.00x |        0.89x |        0.77x |        0.66x
Loop Mem Acc. (Inst)|           23 |           23 |           31 |           42 |           57
Stack Size (Bytes)  |           64 |           64 |           80 |           80 |           96
Code Size (Bytes)   |         2209 |         2307 |         2516 |         2663 |         2854
=================================================================================================================

=================================================================================================================
                          EXPERIMENT 2: VARIABLE DEMAND (THE OVERLOAD)                                           
=================================================================================================================
METRIC              |  LARGE (40 Vars) | NORMAL (20 Vars) |           IMPACT
--------------------|------------------|------------------|------------------
Cycles              |           167152 |            65075 |      2.6x Slower
Loop Mem Acc. (Inst)|               85 |               23 |              +62
Stack Size (Bytes)  |              144 |               64 |              +80
Code Size (Bytes)   |             4848 |             2209 |            +2639
=================================================================================================================

=================================================================================================================
                          EXPERIMENT 3: OPTIMIZATION FREEDOM (UNROLLING)                                         
=================================================================================================================
METRIC              |        NORMAL (32 Regs) |    RESTRICTED (16 Regs) 
                    |       Base |   Unrolled |       Base |   Unrolled 
--------------------|------------|------------|------------|------------
Cycles              |      65075 |      76329 |      99086 |     109347 
Speedup Factor      |          / |      0.85x |          / |      0.91x 
Loop Mem Acc. (Inst)|         23 |         83 |         57 |        215 
Stack Size (Bytes)  |         64 |         64 |         96 |        144 
Code Size (Bytes)   |       2209 |       5672 |       2854 |       7825 
=================================================================================================================
```
