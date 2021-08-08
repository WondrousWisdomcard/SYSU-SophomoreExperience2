# test_long.s Test whether sizes + 8 can get the second long element 2
.section .data
output:
	.asciz "The second element is '%d'\n"
sizes:
	.int 1,2
.section .text
.globl _start
_start:
	
	movl $1, %eax
	movl $4, %ebx
	int $0x80
	

#as -gstabs+ -o test_long.o test_long.s
#ld -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o test_long test_long.o
#./test_long
