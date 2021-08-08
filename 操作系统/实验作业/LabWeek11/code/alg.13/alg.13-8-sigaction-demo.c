#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
 
void my_handler(int signo)  /* user signal handler */
{
    printf("\nhere is my_handler");
    printf("\nsignal catched: signo = %d", signo);
    printf("\nCtrl+\\ is masked");
    printf("\nsleeping for 10 seconds ... \n");
    sleep(10); 
    printf("my_handler finished\n");
    printf("after returned to the main(), Ctrl+\\ is unmasked\n");
    return;
}

int main(void)
{
    int ret;
    struct sigaction newact;
 
    newact.sa_handler = my_handler; /* set the user handler */
    sigemptyset(&newact.sa_mask); /* clear the mask */
    sigaddset(&newact.sa_mask, SIGQUIT); /* sa_mask, set signo=3 (SIGQUIT:Ctrl+\) */
    newact.sa_flags = 0; /* default */

    printf("now start catching Ctrl+c\n");

    ret = sigaction(SIGINT, &newact, NULL); /* register signo=2 (SIGINT:Ctrl+C) */
    if(ret == -1) {
        perror("sigaction()");
        exit(1);
    }
 
    while (1);
 
    return 0;
}
