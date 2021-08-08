# paritytest.s - An example of testing the parity flag
.section .text
.globl _start
_start:
   movl $1, %eax
   movl $4, %ebx
   subl $1, %ebx
   jp overhere
   int $0x80
overhere:
   movl $100, %ebx
   int $0x80
