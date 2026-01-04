EMU ?= ./rv32emu

# Add -fstack-usage to generate .su files
CFLAGS = -O2 -march=rv32i_zicsr -fstack-usage
LINKER_SCRIPT = linker.ld
LDFLAGS = -T $(LINKER_SCRIPT)
EXEC = test.elf

CROSS_COMPILE = riscv-none-elf-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJDUMP = $(CROSS_COMPILE)objdump

BUILD_DIR = build

# Link all objects
OBJS = $(BUILD_DIR)/start.o $(BUILD_DIR)/main.o $(BUILD_DIR)/perfcounter.o \
       $(BUILD_DIR)/normal_func.o \
       $(BUILD_DIR)/light_func.o \
       $(BUILD_DIR)/middle_func.o \
       $(BUILD_DIR)/heavy_func.o \
       $(BUILD_DIR)/restricted_func.o \
       $(BUILD_DIR)/large_func.o \
       $(BUILD_DIR)/unroll_normal_func.o \
       $(BUILD_DIR)/unroll_restricted_func.o

# --- Register Restriction Flags ---
# Total User Registers: ~27 (32 - zero,ra,sp,gp,tp)

# 1. Normal: 0 Fixed. Avail: ~27. (Vars: 20). Status: SAFE.

# 2. Light: Fix 4 (t0-t3). Avail: ~23. Status: SAFE.
LIGHT_FLAGS = -ffixed-t0 -ffixed-t1 -ffixed-t2 -ffixed-t3

# 3. Middle: Fix 7 (t0-t6). Avail: ~20. Status: EDGE (Should start showing overhead).
MIDDLE_FLAGS = -ffixed-t0 -ffixed-t1 -ffixed-t2 -ffixed-t3 -ffixed-t4 -ffixed-t5 -ffixed-t6

# 4. Heavy: Fix 11 (t0-t6, s2-s5). Avail: ~16. Status: SPILLING.
HEAVY_FLAGS = \
    -ffixed-t0 -ffixed-t1 -ffixed-t2 -ffixed-t3 -ffixed-t4 -ffixed-t5 -ffixed-t6 \
    -ffixed-s2 -ffixed-s3 -ffixed-s4 -ffixed-s5

# 5. Restricted: Fix 17. Avail: ~10. Status: HEAVY SPILLING.
RESTRICTED_FLAGS = \
    -ffixed-s2 -ffixed-s3 -ffixed-s4 -ffixed-s5 -ffixed-s6 \
    -ffixed-s7 -ffixed-s8 -ffixed-s9 -ffixed-s10 -ffixed-s11 \
    -ffixed-t0 -ffixed-t1 -ffixed-t2 -ffixed-t3 -ffixed-t4 -ffixed-t5 -ffixed-t6

.PHONY: all dump clean report directories

all: directories $(EXEC)

directories:
	@mkdir -p $(BUILD_DIR)

$(EXEC): $(OBJS)
	$(LD) -T $(LINKER_SCRIPT) -o $(BUILD_DIR)/$@ $^

$(OBJS): | directories

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) $< -o $@ -c

$(BUILD_DIR)/%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

# --- Compilation Rules for Sweep ---

# 1. Normal
$(BUILD_DIR)/normal_func.o: pressure_func.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=normal_pressure $< -o $@ -c
$(BUILD_DIR)/normal_func.S: pressure_func.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=normal_pressure -S $< -o $@

# 2. Light
$(BUILD_DIR)/light_func.o: pressure_func.c
	$(CC) $(CFLAGS) $(LIGHT_FLAGS) -DTEST_FUNC_NAME=light_pressure $< -o $@ -c
$(BUILD_DIR)/light_func.S: pressure_func.c
	$(CC) $(CFLAGS) $(LIGHT_FLAGS) -DTEST_FUNC_NAME=light_pressure -S $< -o $@

# 3. Middle
$(BUILD_DIR)/middle_func.o: pressure_func.c
	$(CC) $(CFLAGS) $(MIDDLE_FLAGS) -DTEST_FUNC_NAME=middle_pressure $< -o $@ -c
$(BUILD_DIR)/middle_func.S: pressure_func.c
	$(CC) $(CFLAGS) $(MIDDLE_FLAGS) -DTEST_FUNC_NAME=middle_pressure -S $< -o $@

# 4. Heavy
$(BUILD_DIR)/heavy_func.o: pressure_func.c
	$(CC) $(CFLAGS) $(HEAVY_FLAGS) -DTEST_FUNC_NAME=heavy_pressure $< -o $@ -c
$(BUILD_DIR)/heavy_func.S: pressure_func.c
	$(CC) $(CFLAGS) $(HEAVY_FLAGS) -DTEST_FUNC_NAME=heavy_pressure -S $< -o $@

# 5. Restricted
$(BUILD_DIR)/restricted_func.o: pressure_func.c
	$(CC) $(CFLAGS) $(RESTRICTED_FLAGS) -DTEST_FUNC_NAME=restricted_pressure $< -o $@ -c
$(BUILD_DIR)/restricted_func.S: pressure_func.c
	$(CC) $(CFLAGS) $(RESTRICTED_FLAGS) -DTEST_FUNC_NAME=restricted_pressure -S $< -o $@

# 6. Large (40 Vars, Normal Flags)
$(BUILD_DIR)/large_func.o: pressure_large.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=large_pressure $< -o $@ -c
$(BUILD_DIR)/large_func.S: pressure_large.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=large_pressure -S $< -o $@

# 7. Unrolled Normal
$(BUILD_DIR)/unroll_normal_func.o: pressure_unroll.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=unroll_normal_pressure $< -o $@ -c
$(BUILD_DIR)/unroll_normal_func.S: pressure_unroll.c
	$(CC) $(CFLAGS) -DTEST_FUNC_NAME=unroll_normal_pressure -S $< -o $@

# 8. Unrolled Restricted
$(BUILD_DIR)/unroll_restricted_func.o: pressure_unroll.c
	$(CC) $(CFLAGS) $(RESTRICTED_FLAGS) -DTEST_FUNC_NAME=unroll_restricted_pressure $< -o $@ -c
$(BUILD_DIR)/unroll_restricted_func.S: pressure_unroll.c
	$(CC) $(CFLAGS) $(RESTRICTED_FLAGS) -DTEST_FUNC_NAME=unroll_restricted_pressure -S $< -o $@


dump: $(EXEC)
	$(OBJDUMP) -D $(BUILD_DIR)/$(EXEC) > test.asm

# Generate assembly files for analysis (in build dir)


# Comprehensive Report Target
report: directories $(BUILD_DIR)/normal_func.S $(BUILD_DIR)/light_func.S $(BUILD_DIR)/middle_func.S $(BUILD_DIR)/heavy_func.S $(BUILD_DIR)/restricted_func.S $(BUILD_DIR)/large_func.S $(BUILD_DIR)/unroll_normal_func.S $(BUILD_DIR)/unroll_restricted_func.S $(EXEC)
	@# Checks
	@test -f $(EMU) || (echo "Error: $(EMU) not found" && exit 1)
	@grep -q "ENABLE_ELF_LOADER=1" ./.config || (echo "Error: ENABLE_ELF_LOADER=1 not set" && exit 1)
	
	@# Run Experiment and Capture Output
	@$(EMU) $(BUILD_DIR)/$(EXEC) > $(BUILD_DIR)/run.log 2>&1
	
	@echo ""
	@echo "================================================================================================================="
	@echo "                          EXPERIMENT 1: REGISTER SUPPLY SWEEP (THE CLIFF)                                        "
	@echo "================================================================================================================="
	@printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "METRIC" "NORMAL" "LIGHT" "MIDDLE" "HEAVY" "RESTRICT"
	@printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "" "(32 Regs)" "(~28 Regs)" "(~24 Regs)" "(~20 Regs)" "(~16 Regs)"
	@echo "--------------------|--------------|--------------|--------------|--------------|--------------"
	@\
	C1=$$(grep "Normal Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	C2=$$(grep "Light Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	C3=$$(grep "Middle Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	C4=$$(grep "Heavy Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	C5=$$(grep "Restricted Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "Cycles" "$$C1" "$$C2" "$$C3" "$$C4" "$$C5"; \
	\
	S1="1.00x"; \
	S2=$$(awk "BEGIN {printf \"%.2fx\", $$C1/$$C2}"); \
	S3=$$(awk "BEGIN {printf \"%.2fx\", $$C1/$$C3}"); \
	S4=$$(awk "BEGIN {printf \"%.2fx\", $$C1/$$C4}"); \
	S5=$$(awk "BEGIN {printf \"%.2fx\", $$C1/$$C5}"); \
	printf "%-20s| %12s | %12s | \033[1;33m%12s\033[0m | %12s | \033[1;31m%12s\033[0m\n" "Relative Perf" "$$S1" "$$S2" "$$S3" "$$S4" "$$S5"; \
	\
	M1=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/normal_func.S | grep -E "lw|sw" | wc -l); \
	M2=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/light_func.S | grep -E "lw|sw" | wc -l); \
	M3=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/middle_func.S | grep -E "lw|sw" | wc -l); \
	M4=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/heavy_func.S | grep -E "lw|sw" | wc -l); \
	M5=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/restricted_func.S | grep -E "lw|sw" | wc -l); \
	printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "Loop Mem Acc. (Inst)" "$$M1" "$$M2" "$$M3" "$$M4" "$$M5"; \
	\
	S1=$$(cut -f2 $(BUILD_DIR)/normal_func.su | cut -d' ' -f1); \
	S2=$$(cut -f2 $(BUILD_DIR)/light_func.su | cut -d' ' -f1); \
	S3=$$(cut -f2 $(BUILD_DIR)/middle_func.su | cut -d' ' -f1); \
	S4=$$(cut -f2 $(BUILD_DIR)/heavy_func.su | cut -d' ' -f1); \
	S5=$$(cut -f2 $(BUILD_DIR)/restricted_func.su | cut -d' ' -f1); \
	printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "Stack Size (Bytes)" "$$S1" "$$S2" "$$S3" "$$S4" "$$S5"; \
	\
	Z1=$$(wc -c < $(BUILD_DIR)/normal_func.S); \
	Z2=$$(wc -c < $(BUILD_DIR)/light_func.S); \
	Z3=$$(wc -c < $(BUILD_DIR)/middle_func.S); \
	Z4=$$(wc -c < $(BUILD_DIR)/heavy_func.S); \
	Z5=$$(wc -c < $(BUILD_DIR)/restricted_func.S); \
	printf "%-20s| %12s | %12s | %12s | %12s | %12s\n" "Code Size (Bytes)" "$$Z1" "$$Z2" "$$Z3" "$$Z4" "$$Z5"
	@echo "================================================================================================================="
	@echo ""
	@echo "================================================================================================================="
	@echo "                          EXPERIMENT 2: VARIABLE DEMAND (THE OVERLOAD)                                           "
	@echo "================================================================================================================="
	@printf "%-20s| %16s | %16s | %16s\n" "METRIC" "LARGE (40 Vars)" "NORMAL (20 Vars)" "IMPACT"
	@echo "--------------------|------------------|------------------|------------------"
	@\
	L_CYCLES=$$(grep "Large Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	N_CYCLES=$$(grep "Normal Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	FACTOR=$$(awk "BEGIN {printf \"%.1fx Slower\", $$L_CYCLES/$$N_CYCLES}"); \
	printf "%-20s| %16s | %16s | \033[1;31m%16s\033[0m\n" "Cycles" "$$L_CYCLES" "$$N_CYCLES" "$$FACTOR"; \
	\
	L_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/large_func.S | grep -E "lw|sw" | wc -l); \
	N_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/normal_func.S | grep -E "lw|sw" | wc -l); \
	D_LN_MEM=$$(echo "$$L_MEM - $$N_MEM" | bc 2>/dev/null || echo "$$(($$L_MEM - $$N_MEM))"); \
	printf "%-20s| %16s | %16s | %16s\n" "Loop Mem Acc. (Inst)" "$$L_MEM" "$$N_MEM" "+$$D_LN_MEM"; \
	\
	L_STACK=$$(cut -f2 $(BUILD_DIR)/large_func.su | cut -d' ' -f1); \
	N_STACK=$$(cut -f2 $(BUILD_DIR)/normal_func.su | cut -d' ' -f1); \
	D_LN_STACK=$$(echo "$$L_STACK - $$N_STACK" | bc 2>/dev/null || echo "$$(($$L_STACK - $$N_STACK))"); \
	printf "%-20s| %16s | %16s | %16s\n" "Stack Size (Bytes)" "$$L_STACK" "$$N_STACK" "+$$D_LN_STACK"; \
	\
	L_SIZE=$$(wc -c < $(BUILD_DIR)/large_func.S); \
	N_SIZE=$$(wc -c < $(BUILD_DIR)/normal_func.S); \
	D_LN_SIZE=$$(echo "$$L_SIZE - $$N_SIZE" | bc 2>/dev/null || echo "$$(($$L_SIZE - $$N_SIZE))"); \
	printf "%-20s| %16s | %16s | %16s\n" "Code Size (Bytes)" "$$L_SIZE" "$$N_SIZE" "+$$D_LN_SIZE"
	@echo "================================================================================================================="
	@echo ""
	@echo "================================================================================================================="
	@echo "                          EXPERIMENT 3: OPTIMIZATION FREEDOM (UNROLLING)                                         "
	@echo "================================================================================================================="
	@printf "%-20s| %23s | %23s \n" "METRIC" "NORMAL (32 Regs)" "RESTRICTED (16 Regs)"
	@printf "%-20s| %10s | %10s | %10s | %10s \n" "" "Base" "Unrolled" "Base" "Unrolled"
	@echo "--------------------|------------|------------|------------|------------"
	@\
	N_BASE=$$(grep "Normal Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	N_UNROLL=$$(grep "Unroll N Cycles:" $(BUILD_DIR)/run.log | awk '{print $$4}'); \
	R_BASE=$$(grep "Restricted Cycles:" $(BUILD_DIR)/run.log | awk '{print $$3}'); \
	R_UNROLL=$$(grep "Unroll R Cycles:" $(BUILD_DIR)/run.log | awk '{print $$4}'); \
	printf "%-20s| %10s | %10s | %10s | %10s \n" "Cycles" "$$N_BASE" "$$N_UNROLL" "$$R_BASE" "$$R_UNROLL"; \
	\
	N_FACTOR=$$(awk "BEGIN {printf \"%.2fx\", $$N_BASE/$$N_UNROLL}"); \
	R_FACTOR=$$(awk "BEGIN {printf \"%.2fx\", $$R_BASE/$$R_UNROLL}"); \
	printf "%-20s| %10s | \033[1;33m%10s\033[0m | %10s | \033[1;31m%10s\033[0m \n" "Speedup Factor" "/" "$$N_FACTOR" "/" "$$R_FACTOR"; \
	\
	N_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/normal_func.S | grep -E "lw|sw" | wc -l); \
	NU_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/unroll_normal_func.S | grep -E "lw|sw" | wc -l); \
	R_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/restricted_func.S | grep -E "lw|sw" | wc -l); \
	RU_MEM=$$(awk '/^\.L3:/{flag=1} flag; /blt.*\.L3/{flag=0}' $(BUILD_DIR)/unroll_restricted_func.S | grep -E "lw|sw" | wc -l); \
	printf "%-20s| %10s | \033[1;31m%10s\033[0m | %10s | \033[1;31m%10s\033[0m \n" "Loop Mem Acc. (Inst)" "$$N_MEM" "$$NU_MEM" "$$R_MEM" "$$RU_MEM"; \
	\
	STACK_N32=$$(awk '{print $$2}' $(BUILD_DIR)/normal_func.su); \
	STACK_N32_U=$$(awk '{print $$2}' $(BUILD_DIR)/unroll_normal_func.su); \
	STACK_R16=$$(awk '{print $$2}' $(BUILD_DIR)/restricted_func.su); \
	STACK_R16_U=$$(awk '{print $$2}' $(BUILD_DIR)/unroll_restricted_func.su); \
	printf "%-20s| %10s | %10s | %10s | \033[1;31m%10s\033[0m \n" "Stack Size (Bytes)" "$$STACK_N32" "$$STACK_N32_U" "$$STACK_R16" "$$STACK_R16_U"; \
	\
	N_SIZE=$$(wc -c < $(BUILD_DIR)/normal_func.S); \
	NU_SIZE=$$(wc -c < $(BUILD_DIR)/unroll_normal_func.S); \
	R_SIZE=$$(wc -c < $(BUILD_DIR)/restricted_func.S); \
	RU_SIZE=$$(wc -c < $(BUILD_DIR)/unroll_restricted_func.S); \
	printf "%-20s| %10s | %10s | %10s | %10s \n" "Code Size (Bytes)" "$$N_SIZE" "$$NU_SIZE" "$$R_SIZE" "$$RU_SIZE"
	@echo "================================================================================================================="

clean:
	rm -rf $(BUILD_DIR)