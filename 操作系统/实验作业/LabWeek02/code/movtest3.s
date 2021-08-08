# movetest1.s - Another example of using indexed memory locations
.section .data
	output:
		.asciz "The value is %d\n"
	values: 
		.int 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
.section .text
.globl _start
_start:
	nop
	movl $0, %edi
loop:
	movl values(, %edi, 4), %eax
	pushl %eax
	pushl $output
	call printf
	addl $8, %esp
	inc %edi
	cmpl $11, %edi
	jne loop
	movl $0, %ebx
	movl $1, %eax
	int $0x80
	
