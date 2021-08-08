# subtest2.s - An example of a subtraction carry
.section .text
.globl _start
_start:
   nop
   movl $5, %eax
   movl $2, %ebx
   subl %eax, %ebx
   jc under
   movl $1, %eax
   int $0x80
under:
   movl $1, %eax
   movl $0, %ebx
   int $0x80
