#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

// Length of vectors
#define N 100

int main(int argc, char *argv[])
{
    long start, end, exe_time;
    start = (long)time(0);

    // Size, in bytes, of each vector
    size_t v_size = N * sizeof(float);

    // Allocate memory for each vector on host
    float h_a[v_size];
    float h_b[v_size];
    float h_c[v_size];

    // Initialize vectors on host
    for (int i = 0; i < N; i++)
    {
        h_a[i] = 1.1;
        h_b[i] = 2.2;
    }

    // Perform addition on host
    for (int i = 0; i < N; i++)
    {
        h_c[i] = h_a[i] + h_b[i];
    }

    // Print output vector
    printf("final result: ");
    for (int i = 0; i < N; i++)
    {
        printf("%f ", h_c[i]);
    }

    end = (long)time(0);
    exe_time = (end - start) / 1e6;
    printf("\n executed time = %ld msec\n", exe_time);

    return 0;
}