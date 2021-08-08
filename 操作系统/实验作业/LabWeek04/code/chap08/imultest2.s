# imultest2.s - An example of detecting an IMUL overflow
.section .text
.globl _start
_start:
   nop
   movw $680, %ax
   movw $100, %cx
   imulw %cx
   jo over
   movl $1, %eax
   movl $0, %ebx
   int $0x80
over:
   movl $1, %eax
   movl $1, %ebx
   int $0x80
