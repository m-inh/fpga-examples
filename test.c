#include <stdio.h>

void increase(int *n) {
    *n += 1;
    printf("n: %d   ---   ", *n);
}

void main() {
    int a = 3;
    increase(&a);

    printf("a: %d", a);
}