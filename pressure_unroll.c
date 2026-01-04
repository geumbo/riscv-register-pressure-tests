/* Unrolled Function (4x Loop Unrolling) */
/* Tests if Register Count affects the viability of Loop Unrolling optimization.
 */

#ifndef TEST_FUNC_NAME
#define TEST_FUNC_NAME unroll_pressure
#endif

__attribute__((noinline)) int TEST_FUNC_NAME(int seed, int iters)
{
    int v0 = seed;
    int v1 = seed + 1;
    int v2 = seed + 2;
    int v3 = seed + 3;
    int v4 = seed + 4;
    int v5 = seed + 5;
    int v6 = seed + 6;
    int v7 = seed + 7;
    int v8 = seed + 8;
    int v9 = seed + 9;
    int v10 = seed + 10;
    int v11 = seed + 11;
    int v12 = seed + 12;
    int v13 = seed + 13;
    int v14 = seed + 14;
    int v15 = seed + 15;
    int v16 = seed + 16;
    int v17 = seed + 17;
    int v18 = seed + 18;
    int v19 = seed + 19;

    /* Unrolled 4x: Standard optimization to reduce branch overhead */
    /* Only beneficial if registers can handle the pressure */
    for (volatile int i = 0; i < iters; i += 4) {
        /* Iteration 1 */
        v0 += (v19 ^ i);
        v1 += (v0 ^ i);
        v2 += (v1 ^ i);
        v3 += (v2 ^ i);
        v4 += (v3 ^ i);
        v5 += (v4 ^ i);
        v6 += (v5 ^ i);
        v7 += (v6 ^ i);
        v8 += (v7 ^ i);
        v9 += (v8 ^ i);
        v10 += (v9 ^ i);
        v11 += (v10 ^ i);
        v12 += (v11 ^ i);
        v13 += (v12 ^ i);
        v14 += (v13 ^ i);
        v15 += (v14 ^ i);
        v16 += (v15 ^ i);
        v17 += (v16 ^ i);
        v18 += (v17 ^ i);
        v19 += (v18 ^ i);

        /* Iteration 2 */
        v0 += (v19 ^ (i + 1));
        v1 += (v0 ^ (i + 1));
        v2 += (v1 ^ (i + 1));
        v3 += (v2 ^ (i + 1));
        v4 += (v3 ^ (i + 1));
        v5 += (v4 ^ (i + 1));
        v6 += (v5 ^ (i + 1));
        v7 += (v6 ^ (i + 1));
        v8 += (v7 ^ (i + 1));
        v9 += (v8 ^ (i + 1));
        v10 += (v9 ^ (i + 1));
        v11 += (v10 ^ (i + 1));
        v12 += (v11 ^ (i + 1));
        v13 += (v12 ^ (i + 1));
        v14 += (v13 ^ (i + 1));
        v15 += (v14 ^ (i + 1));
        v16 += (v15 ^ (i + 1));
        v17 += (v16 ^ (i + 1));
        v18 += (v17 ^ (i + 1));
        v19 += (v18 ^ (i + 1));

        /* Iteration 3 */
        v0 += (v19 ^ (i + 2));
        v1 += (v0 ^ (i + 2));
        v2 += (v1 ^ (i + 2));
        v3 += (v2 ^ (i + 2));
        v4 += (v3 ^ (i + 2));
        v5 += (v4 ^ (i + 2));
        v6 += (v5 ^ (i + 2));
        v7 += (v6 ^ (i + 2));
        v8 += (v7 ^ (i + 2));
        v9 += (v8 ^ (i + 2));
        v10 += (v9 ^ (i + 2));
        v11 += (v10 ^ (i + 2));
        v12 += (v11 ^ (i + 2));
        v13 += (v12 ^ (i + 2));
        v14 += (v13 ^ (i + 2));
        v15 += (v14 ^ (i + 2));
        v16 += (v15 ^ (i + 2));
        v17 += (v16 ^ (i + 2));
        v18 += (v17 ^ (i + 2));
        v19 += (v18 ^ (i + 2));

        /* Iteration 4 */
        v0 += (v19 ^ (i + 3));
        v1 += (v0 ^ (i + 3));
        v2 += (v1 ^ (i + 3));
        v3 += (v2 ^ (i + 3));
        v4 += (v3 ^ (i + 3));
        v5 += (v4 ^ (i + 3));
        v6 += (v5 ^ (i + 3));
        v7 += (v6 ^ (i + 3));
        v8 += (v7 ^ (i + 3));
        v9 += (v8 ^ (i + 3));
        v10 += (v9 ^ (i + 3));
        v11 += (v10 ^ (i + 3));
        v12 += (v11 ^ (i + 3));
        v13 += (v12 ^ (i + 3));
        v14 += (v13 ^ (i + 3));
        v15 += (v14 ^ (i + 3));
        v16 += (v15 ^ (i + 3));
        v17 += (v16 ^ (i + 3));
        v18 += (v17 ^ (i + 3));
        v19 += (v18 ^ (i + 3));
    }
    return v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 +
           v13 + v14 + v15 + v16 + v17 + v18 + v19;
}
