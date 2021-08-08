#swaptest.s - An example of using the bswap instruction
.section .text
.globl _start
_start:
	nop
	movl $0x12345678, %ebx
	bswap %ebx
	movl $1, %eax
	int $0x80
	
#as -o swaptest.o swaptest.s
#ld -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o swaptest swaptest.o
#./swaptest
