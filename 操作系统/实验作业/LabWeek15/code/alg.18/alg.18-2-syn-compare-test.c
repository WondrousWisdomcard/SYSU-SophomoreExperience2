#include <stdio.h>
#include <stdlib.h>

int main(void)
{
    int value, oldval, newval;
    int ret;

    value = 200000; oldval = 123456; newval = 654321;
    printf("value = %d, oldval = %d, newval = %d\n", value, oldval, newval);
    printf("ret = __sync_bool_compare_and_swap(&value, oldval, newval)\n");
    ret =  __sync_bool_compare_and_swap(&value, oldval, newval);
    printf("ret = %d, value = %d, oldval = %d, newval = %d\n\n", ret, value, oldval, newval);

    value = 200000; oldval = 200000; newval = 654321;
    printf("value = %d, oldval = %d, newval = %d\n", value, oldval, newval);
    printf("ret = __sync_bool_compare_and_swap(&value, oldval, newval)\n");
    ret =  __sync_bool_compare_and_swap(&value, oldval, newval);
    printf("ret = %d, value = %d, oldval = %d, newval = %d\n\n", ret, value, oldval, newval);

    value = 200000; oldval = 123456; newval = 654321;
    printf("value = %d, oldval = %d, newval = %d\n", value, oldval, newval);
    printf("ret = ___sync_val_compare_and_swap(&value, oldval, newval)\n");
    ret =  __sync_val_compare_and_swap(&value, oldval, newval);
    printf("ret = %d, value = %d, oldval = %d, newval = %d\n\n", ret, value, oldval, newval);

    value = 200000; oldval = 200000; newval = 654321;
    printf("value = %d, oldval = %d, newval = %d\n", value, oldval, newval);
    printf("ret = ___sync_val_compare_and_swap(&value, oldval, newval)\n");
    ret =  __sync_val_compare_and_swap(&value, oldval, newval);
    printf("ret = %d, value = %d, oldval = %d, newval = %d\n\n", ret, value, oldval, newval);

    value = 200000; newval = 654321;
    printf("value = %d, newval = %d\n", value,  newval);
    printf("ret = __sync_lock_test_and_set(&value, newval)\n");
    ret =  __sync_lock_test_and_set(&value, newval);
    printf("ret = %d, value = %d, newval = %d\n\n", ret, value, newval);

    value = 200000;
    printf("value = %d\n", value);
    printf("ret = __sync_lock_release(&value)\n");
    __sync_lock_release(&value); /* no return value */
    printf("value = %d\n", value);

    return 0;
}

