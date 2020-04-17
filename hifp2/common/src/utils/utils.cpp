#include "utils/utils.h"

namespace my_utils
{
void print_array(int *arr, int n)
{
    printf("\n=============================\n");
    printf("(Debug only) \n");
    for (int i = 0; i < n; i++)
    {
        printf("%d ", arr[i]);
    }
    printf("\n");
    printf("=============================");
}

void print_array(unsigned int *arr, int n)
{
    printf("\n=============================\n");
    printf("(Debug only) \n");
    for (int i = 0; i < n; i++)
    {
        printf("%u ", arr[i]);
    }
    printf("\n");
    printf("=============================");
}
} // namespace utils