/* compliling: gcc -fopenmp */

#include <stdio.h>
#include <omp.h>
#include <unistd.h>

#define __NR_gettid 186 /* 186 for x86-64; 224 for i386-32 */
#define gettid() syscall(__NR_gettid)

int main()
{
    #pragma omp parallel
    {
        printf("parallel region 1. pid = %d, tid = %ld\n", getpid(), gettid());
    }

    #pragma omp parallel num_threads(2)
    {
        printf("parallel region 2 with num_thread(2). pid = %d, tid = %ld\n", getpid(), gettid());
    }

    #pragma omp parallel num_threads(4)
    {
        printf("parallel region 3 with num_thread(4). pid = %d, tid = %ld\n", getpid(), gettid());
    }

    #pragma omp parallel num_threads(6)
    {
        printf("parallel region 4 with num_thread(6). pid = %d, tid = %ld\n", getpid(), gettid());
    }

    return 0;
}
