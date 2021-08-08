# movsxtest2.s - Another example using the MOVSX instruction
.section .text
.globl _start
_start:
   nop
   movw $79, %cx
   xor %ebx, %ebx
   movw %cx, %bx
   movsx %cx, %eax
   movl $1, %eax
   movl $0, %ebx
   int $0x80
