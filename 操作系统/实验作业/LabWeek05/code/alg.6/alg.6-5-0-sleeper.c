/* gcc -o alg.6-5-0-sleeper.o alg.6-5-0-sleeper.c */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
    int secnd = 5;

    if (argc > 1) {
        secnd = atoi(argv[1]);
        if ( secnd <= 0 || secnd > 10)
            secnd = 5;
    }
    
    printf("\nsleeper pid = %d, ppid = %d\nsleeper is taking a nap for %d seconds\n", getpid(), getppid(), secnd); /* ppid - its parent pro id */

    sleep(secnd);
    printf("\nsleeper wakes up and returns\n");

    return 0;
}
