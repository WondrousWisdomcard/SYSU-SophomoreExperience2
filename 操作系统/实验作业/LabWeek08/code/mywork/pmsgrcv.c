/* gcc -lrt */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <mqueue.h>

#include "pmsgdata.h"

#define NUM 6	

int main(int argc, char *argv[])
{   
    char pathname[80];
    struct stat fileattr;
    mqd_t mqID; 
    struct msg_struct data;
    char buffer[TEXT_SIZE];
    int ret, count = 0; 
    unsigned prio = 1;
    
    if(argc < 2) {
        printf("Usage: ./b.out pathname msg_type\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);
    if(stat(pathname, &fileattr) == -1) {
        ERR_EXIT("pmsgrcv: Shared file object stat error");
    }
    
    mqID = mq_open(argv[1], O_RDONLY|O_NONBLOCK);
    if(mqID == -1) {
        ERR_EXIT("pmsgrcv: mq_open()");
    }

	printf("pmsgrcv: mqID is %d\n",mqID);
    struct mq_attr mqAttr;
    ret = mq_getattr(mqID, &mqAttr);
    
    if(ret == -1) {
        ERR_EXIT("pmsgrcv: mq_getattr()");
    }
    
    printf("\npmsgrcv: mq_maxmsg:%ld mq_msgsize:%ld mq_curmsgs: %ld\n\n", mqAttr.mq_maxmsg, mqAttr.mq_msgsize, mqAttr.mq_curmsgs);

	int i = NUM;
    while (i--) {
        ret = mq_receive(mqID, (char *)&data, mqAttr.mq_msgsize, NULL); /* Non_blocking receive */
        if(ret == -1) { /* end of this msgtype */
        	//ERR_EXIT("pmsgrcv: mq_receive()");
            printf("pmsgrcv: Number of received messages = %d\n", count);
            break;
        }
        
        printf("pmsgrcv: receive %s\n", data.mtext);
        count++;
    }
    
    //sleep(1);
    
    ret = mq_getattr(mqID, &mqAttr);
    if(ret == -1){
    	ERR_EXIT("pmsgrcv: mq_getattr()");
    }

    printf("pmsgrcv: Number of messages remainding = %ld\n", mqAttr.mq_curmsgs); 

    if(mqAttr.mq_curmsgs == 0) {
        printf("pmsgrcv: Do you want to delete this msg queue?(y/n)");
        if(getchar() == 'y') {
            if(mq_unlink(pathname) == -1)
                perror("pmsgrcv: mq_pathname()");
        }
    }
    else{
		ret = mq_close(mqID); // message-passing quene can be removed by any process knew the filename
        if(ret == -1) {
            ERR_EXIT("pmsgrcv: mq_close()");
        }  
	}
	
    
    return EXIT_SUCCESS;
}

