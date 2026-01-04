__attribute__((noinline)) int TEST_FUNC_NAME(int seed, int iters)
{
    // 20 variables
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

    for (volatile int i = 0; i < iters; i++) {
        // Circular dependency to keep all alive
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
    }

    int sum = v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 +
              v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19;
    return sum;
}
