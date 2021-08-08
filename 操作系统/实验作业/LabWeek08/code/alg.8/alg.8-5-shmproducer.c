/* gcc -lrt */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "alg.8-0-shmdata.h"

int main(int argc, char *argv[])
{
    int fd, shmsize, ret;
    void *shmptr;
    const char *message_0 = "Hello World!";
    
    fd = shm_open(argv[1], O_RDWR, 0666); /* /dev/shm/filename as the shared object */
    if(fd == -1) {
        ERR_EXIT("producer: shm_open()");
    } 
    
    /* set shared size to 1.8GB; near the upper bound of 90% phisical memory size of 2G
       shmsize = 1.8*1024*1024*1024; */

    shmsize = TEXT_NUM*sizeof(struct shared_struct);
    shmptr = (char *)mmap(0, shmsize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("producer: mmap()");
    }

    sprintf(shmptr,"%s",message_0);
    printf("produced message: %s\n", (char *)shmptr);

    return EXIT_SUCCESS;
}
