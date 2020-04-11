#include <stdio.h>

int main()
{
    FILE *fp;
    unsigned int c;
    int count = 0;

    fp = fopen("/Users/minhnguyen/Documents/fp/c-implementation/distorted-fp/S0000.wav.raw", "r");

    while (1)
    {
        c = fgetc(fp);
        if (feof(fp))
        {
            break;
        }
        printf("%d ", c);
        count++;
    }

    printf("-----%d----", count);
    fclose(fp);
    return (0);
}