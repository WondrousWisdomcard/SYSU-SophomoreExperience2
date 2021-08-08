/*  this version works properly */

#define BASE_ADDR 10
/* the first 10 units of the shared memory are reserved for ctln_pc_st, data start from the unit indexed 10
   circular data queue is indicated by (enqueue | dequeue) % buffer_size + BASE_ADDR */

struct ctln_pc_st
{
    int BUFFER_SIZE;  // unit number for data in the shared memory
    int MAX_ITEM_NUM; // number of items to be produced
    int THREAD_PRO;   // number of producers
    int THREAD_CONS;  // number of consumers
    sem_t sem_mutex;  // semophore for mutex, type of long int */
    sem_t stock;      // semophore for number of stocks in BUFFER
    sem_t emptyslot;  // semophore for number of empty units in BUFFER
    int item_num;     // total number of items having produced
    int consume_num;  // total number of items having consumed
    int enqueue;      // current position of PRO in buffer
    int dequeue;      // current positions of CONS in buffer
    int END_FLAG;     // producers met MAX_ITEM_NUM, finished their works 
}; /* 60 bytes */

struct data_pc_st
{
    int item_no;      // the item's serial number when it is made
    int pro_no;       // reserved
    long int pro_tid; // tid of the producer who made the item 
}; /* 16 bytes */
