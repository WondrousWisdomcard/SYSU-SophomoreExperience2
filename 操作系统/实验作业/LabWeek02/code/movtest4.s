# movetest4.s - Another example of indirect addressing
.section .data
	values: 
		.int 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
.section .text
.globl _start
_start:
	nop
	movl values, %eax
	mov $values, %rdi
	
	movl $100, 4(%rdi)
	mov $1, %rdi
	movl values(, %rdi, 4), %ebx
	movl $1, %eax
	int $0x80
	


#as -o movtest4.o movtest4.s
#ld -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o movtest4 movtest4.o
#./movtest4
