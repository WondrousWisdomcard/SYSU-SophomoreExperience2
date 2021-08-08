/* compiling: gcc -phread */
#include<stdio.h>  
#include<pthread.h>  
  
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;  
pthread_cond_t  cond  = PTHREAD_COND_INITIALIZER;  
  
int count = 0;  
	  
void *decrement(void *arg)
{  
    for (int i = 0; i < 4; i++) {
    	pthread_mutex_lock(&mutex);  
    	while (count <= 0)  /* wait until count > 0 */
            pthread_cond_wait(&cond, &mutex);  
    	count--;  
    	printf("\t\t\t\tcount = %d.\n", count);  
    	printf("\t\t\t\tUnlock decrement.\n");  
    	pthread_mutex_unlock(&mutex);  
    }
    return NULL;
}  
	  
void *increment(void *arg) 
{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 10000; j++) ; /* sleep for a while */
        pthread_mutex_lock(&mutex);  
    	count++;  
    	printf("count = %d.\n", count);
    	if (count > 0)  
            pthread_cond_signal(&cond);  
    	printf("Unlock increment.\n");  
    	pthread_mutex_unlock(&mutex);  
    }
    return NULL;
}  
	  
int main(int argc, char *argv[]) 
{  
    pthread_t ptid_in, ptid_de;  

    pthread_create(&ptid_de, NULL, &decrement, NULL);  
    pthread_create(&ptid_in, NULL, &increment, NULL);  

    pthread_join(ptid_de, NULL);  
    pthread_join(ptid_in, NULL);  
    pthread_mutex_destroy(&mutex);  
    pthread_cond_destroy(&cond);  

    return 0;  
}  
