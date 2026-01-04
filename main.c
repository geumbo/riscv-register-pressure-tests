#include <stdbool.h>
#include <stdint.h>
#include <string.h>

/* User provided macros and helpers */
#define printstr(ptr, length)                   \
    do {                                        \
        asm volatile(                           \
            "add a7, x0, 0x40;"                 \
            "add a0, x0, 0x1;" /* stdout */     \
            "add a1, x0, %0;"                   \
            "mv a2, %1;" /* length character */ \
            "ecall;"                            \
            :                                   \
            : "r"(ptr), "r"(length)             \
            : "a0", "a1", "a2", "a7");          \
    } while (0)

#define TEST_OUTPUT(msg, length) printstr(msg, length)

#define TEST_LOGGER(msg) TEST_OUTPUT(msg, sizeof(msg) - 1)

extern uint64_t get_cycles(void);
extern uint64_t get_instret(void);

/* Software division for RV32I (no M extension) */
static unsigned long udiv(unsigned long dividend, unsigned long divisor)
{
    if (divisor == 0)
        return 0;

    unsigned long quotient = 0;
    unsigned long remainder = 0;

    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;

        if (remainder >= divisor) {
            remainder -= divisor;
            quotient |= (1UL << i);
        }
    }

    return quotient;
}

static unsigned long umod(unsigned long dividend, unsigned long divisor)
{
    if (divisor == 0)
        return 0;

    unsigned long remainder = 0;

    for (int i = 31; i >= 0; i--) {
        remainder <<= 1;
        remainder |= (dividend >> i) & 1;

        if (remainder >= divisor) {
            remainder -= divisor;
        }
    }

    return remainder;
}

/* Simple integer to decimal string conversion */
static void print_dec(unsigned long val)
{
    static char buf[20]; /* Static to avoid stack I/O issues */
    char *p = buf + sizeof(buf) - 1;
    *p = '\n';
    p--;

    if (val == 0) {
        *p = '0';
        p--;
    } else {
        while (val > 0) {
            *p = '0' + umod(val, 10);
            p--;
            val = udiv(val, 10);
        }
    }

    p++;
    printstr(p, (buf + sizeof(buf) - p));
}

// ---------------------------------------------------------
// Experiment Functions
// ---------------------------------------------------------

extern int restricted_pressure(int seed, int iters); /* 16 */
extern int heavy_pressure(int seed, int iters);      /* 20 */
extern int middle_pressure(int seed, int iters);     /* 24 */
extern int light_pressure(int seed, int iters);      /* 28 */
extern int normal_pressure(int seed, int iters);     /* 32 */
extern int large_pressure(int seed, int iters);      /* 40 Vars */
extern int unroll_normal_pressure(int seed, int iters);
extern int unroll_restricted_pressure(int seed, int iters);

int main(void)
{
    uint64_t start_cycles, end_cycles, cycles_elapsed;
    int iters = 1000;

    TEST_LOGGER("=== Register Spilling Sweep ===\n");

    /* 1. Normal (32) */
    start_cycles = get_cycles();
    normal_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Normal Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 2. Light (28) */
    start_cycles = get_cycles();
    light_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Light Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 3. Middle (24) */
    start_cycles = get_cycles();
    middle_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Middle Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 4. Heavy (20) */
    start_cycles = get_cycles();
    heavy_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Heavy Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 5. Restricted (16) */
    start_cycles = get_cycles();
    restricted_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Restricted Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 6. Large (40 Vars, 32 Regs) */
    start_cycles = get_cycles();
    large_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Large Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 7. Unrolled Normal */
    start_cycles = get_cycles();
    unroll_normal_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Unroll N Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    /* 8. Unrolled Restricted */
    start_cycles = get_cycles();
    unroll_restricted_pressure(0, iters);
    end_cycles = get_cycles();
    cycles_elapsed = end_cycles - start_cycles;
    TEST_LOGGER("Unroll R Cycles: ");
    print_dec((unsigned long) cycles_elapsed);

    return 0;
}