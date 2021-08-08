/* compliling: gcc -fopenmp */
/* omp works for matrix addition: when od = 122200 with 4 threads, system utility may have 30% improvment */
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <ctype.h>
#include <omp.h>
#define MAX_N 12288 

int a[MAX_N][MAX_N], b[MAX_N][MAX_N];
int ans[MAX_N][MAX_N];
int od = 10;

void matrixadd(void)
{   
    for(int i = 0; i < od; i++){
        for(int j = 0; j < od; j++){
            ans[i][j] = a[i][j] + b[j][j];
        }
    }
/*
    printf("Result:\n");
    for(int i = 0; i < od; i++){
        for(int j = 0; j < od; j++){
            printf("%d ", ans[i][j]);
        }
        putchar(10);
    } 
*/
    return;
}
 
int main(int argc, void *argv[])
{
    int i, iteration;

    if(argc > 1)
        od = atoi(argv[1]);
    if(od > MAX_N || od < 0)
        return 1;

    i = MAX_N;
    printf("MAX_N = %d, od = %d\n", i, od);

    for (int i = 0; i < od; i++)
        for (int j = 0; j < od; j++)
            a[i][j] = 20;   
    for (int i = 0; i < od; i++)
        for (int j = 0; j < od; j++)
            b[i][j] = 30;

      /* with no omp  */
    long start_us, end_us;
    struct timeval t;
    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;

    matrixadd();

    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    printf("Overhead time usec = %ld, with no omp\n", end_us-start_us);	

      /* with 2 threads */
    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    #pragma omp parallel num_threads(2)
    {
        matrixadd();
    }
    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    printf("Overhead time usec = %ld, omp thread = 2\n", end_us-start_us);	
    
      /* with 4 threads */
    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    #pragma omp parallel num_threads(4)
    {
        matrixadd();
    }
    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    printf("Overhead time usec = %ld, omp thread = 4\n", end_us-start_us);	
	
    return 0;
}

