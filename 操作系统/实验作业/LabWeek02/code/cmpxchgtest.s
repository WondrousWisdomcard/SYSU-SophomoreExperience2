# cmpxchg.s - An example of the cmpxchg instruction
.section .data
data:
	.int 10
.section .text
.globl _start
_start:
	nop
	movl $10, %eax
	movl $5, %ebx
	cmpxchg %ebx, data
	movl $1, %eax
	int $0x80
	
#as -o cmpxchgtest.o cmpxchgtest.s
#ld -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o cmpxchgtest cmpxchgtest.o
#./cmpxchgtest
