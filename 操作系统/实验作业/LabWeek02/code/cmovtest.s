# cmovtest.s - An example of the MOV instructions
.section .data
output:
	.asciz "The largest value is %d\n"
values:
	.int 105, 235, 61, 315, 134, 221, 53, 145, 117, 5
.section .text
.globl _start
_start:
	nop
	movl values, %ebx
	movl $1, %edi
loop:
	movl values(, %edi, 4), %eax
	cmp %ebx, %eax
	cmova %eax, %ebx
	inc %edi
	cmp $10, %edi
	jne loop
	
	pushl %ebx
	pushl $output
	#mov $output, %rdi 
	#movl %ebx, %esi 
	call printf
	addl $8, %esp
	
	pushl $0
	call exit
	#int $0x80
	
# 	as --32 -o cmovtest.o cmovtest.s
#	ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cmovtest -lc cmovtest.o
#	./cmovtest
