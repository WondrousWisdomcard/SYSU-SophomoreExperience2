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

int main(int argc, char *argv[])
{   
    char pathname[80];
    struct stat fileattr;
    mqd_t mqID; 
    struct msg_struct data;
    char buffer[TEXT_SIZE];
    int ret, count = 0; 
    unsigned prio = 1;
    FILE *fp;
    
    if(argc < 2) {
        printf("Usage: ./b.out pathname msg_type\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);
    if(stat(pathname, &fileattr) == -1) {
        ERR_EXIT("pmsgsnd: shared file object stat error");
    }
    
    mqID = mq_open(argv[1], O_WRONLY);
    if(mqID == -1) {
        ERR_EXIT("pmsgsnd: mq_open()");
    }
    
    printf("pmsgrcv: mqID is %d\n",mqID);
    
    fp = fopen("./pmsgsnd.txt", "rb");
    if(!fp) {
        ERR_EXIT("pmsgsnd: source data file: ./pmsgdata.txt fopen()");
    }

    struct mq_attr mqAttr;
    ret = mq_getattr(mqID, &mqAttr);
    if(ret == -1) {
        ERR_EXIT("pmsgsnd: mq_getattr()");
    }
    printf("\npmsgsnd: mq_maxmsg:%ld mq_msgsize:%ld mq_curmsgs: %ld\n\n", mqAttr.mq_maxmsg, mqAttr.mq_msgsize, mqAttr.mq_curmsgs);
    
    /*
    ret = mq_close(mqID);
	if(ret == -1) {
		ERR_EXIT("pmsgsnd: mq_close()");
	}
	return EXIT_SUCCESS;
	//*/
			
    printf("pmsgsnd: Blocking Sending ... \n");
    while (!feof(fp)) {
        ret = fscanf(fp, "%s", buffer);
        if(ret == EOF) {
            break;
        }
        printf("pmsgsnd: send %s\n", buffer);
                        
        strcpy(data.mtext, buffer);

        ret = mq_send(mqID, (void *)&data, TEXT_SIZE, 0); 
        if(ret == -1) {
            ERR_EXIT("pmsgsnd: mq_send()");
        }
        count++;
    }

    printf("pmsgsnd: Number of sent messages = %d\n", count);
	
	mqAttr.mq_curmsgs = count;
	
	printf("\npmsgsnd: mq_maxmsg:%ld mq_msgsize:%ld mq_curmsgs: %ld\n\n", mqAttr.mq_maxmsg, mqAttr.mq_msgsize, mqAttr.mq_curmsgs);
    
    return EXIT_SUCCESS;
}

