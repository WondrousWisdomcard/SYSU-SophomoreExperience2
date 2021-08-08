# movetest1.s - An example of moving data from memroy to a register
.section .data
	value: 
		.int 1
.section .text
.globl _start
_start:
	nop
	movl value, %ecx
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
#as -gstabs -o movtest1.o movtest1.s
#ld -o movtest1 movtest1.o
#gdb -q movtest1
#break *_start+1
#run
#print/x $ecx
#next
#print/x $ecx
