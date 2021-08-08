# movetest1.s - An example of moving data from register to memory
.section .data
	value: 
		.int 1
.section .text
.globl _start
_start:
	nop
	movl $100, %eax
	movl %eax, value
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
#as -gstabs -o movtest2.o movtest2.s
#ld -o movtest2 movtest2.o
#gdb -q movtest2
#break *_start+1
#run
#x/d &value
#s
#s
#x/d &value

