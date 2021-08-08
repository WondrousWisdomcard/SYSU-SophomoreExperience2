#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int i;
    
    i = 10;
	printf("ret = %d, i = %d\n", __sync_fetch_and_add(&i, 20), i);
    printf("i = %d\n", i);
    
    i = 10;
	printf("ret = %d, i = %d\n", __sync_add_and_fetch(&i, 20), i);
    printf("i = %d\n", i);

	return 0;
}


