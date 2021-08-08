.section .data
data: 
	.int 125
	
.section .text
.globl _start
_start:
	nop
	movl $24420, %ecx
	movw $350, %bx
	movb $100, %eax
	pushl %ecx
	pushw %bx
	pushl %eax
	pushl data
	pushl $data
pop:
	popl %eax
	popl %eax
	popl %eax
	popw %ax
	popl %eax
	movl $0, %ebx
stop:
	movl $1, %eax
	int $0x80

#as pushpop.s -o pushpop.o --32
#ld -m elf_i386 pushpop.o -o pushpop
#./pushpop
