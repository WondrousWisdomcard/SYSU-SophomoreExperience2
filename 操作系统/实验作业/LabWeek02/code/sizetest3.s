# sizetest3.s - A sample program to view the excutable size
.section .data
buffer:
	.fill 10000
.section .text
.globl _start
_start:
movl $1, %eax
movl $0, %ebx
int $0x80

# as -o sizetest3.o sizetest3.s
# ld -o sizetest3 sizetest3.o
# ls -al sizetest3

