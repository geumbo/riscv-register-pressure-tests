/* Large Variable Count Function (40 Variables) */
/* This tests if 32 Registers are enough when SW demand is 40. */

__attribute__((noinline)) int large_pressure(int seed, int iters)
{
    /* 40 Local Variables */
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

    int v20 = seed + 20;
    int v21 = seed + 21;
    int v22 = seed + 22;
    int v23 = seed + 23;
    int v24 = seed + 24;
    int v25 = seed + 25;
    int v26 = seed + 26;
    int v27 = seed + 27;
    int v28 = seed + 28;
    int v29 = seed + 29;
    int v30 = seed + 30;
    int v31 = seed + 31;
    int v32 = seed + 32;
    int v33 = seed + 33;
    int v34 = seed + 34;
    int v35 = seed + 35;
    int v36 = seed + 36;
    int v37 = seed + 37;
    int v38 = seed + 38;
    int v39 = seed + 39;

    for (volatile int i = 0; i < iters; i++) {
        /* Mix all 40 variables */
        v0 += (v39 ^ i);
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

        v20 += (v19 ^ i);
        v21 += (v20 ^ i);
        v22 += (v21 ^ i);
        v23 += (v22 ^ i);
        v24 += (v23 ^ i);
        v25 += (v24 ^ i);
        v26 += (v25 ^ i);
        v27 += (v26 ^ i);
        v28 += (v27 ^ i);
        v29 += (v28 ^ i);
        v30 += (v29 ^ i);
        v31 += (v30 ^ i);
        v32 += (v31 ^ i);
        v33 += (v32 ^ i);
        v34 += (v33 ^ i);
        v35 += (v34 ^ i);
        v36 += (v35 ^ i);
        v37 += (v36 ^ i);
        v38 += (v37 ^ i);
        v39 += (v38 ^ i);
    }

    return v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 +
           v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 + v21 + v22 + v23 +
           v24 + v25 + v26 + v27 + v28 + v29 + v30 + v31 + v32 + v33 + v34 +
           v35 + v36 + v37 + v38 + v39;
}
