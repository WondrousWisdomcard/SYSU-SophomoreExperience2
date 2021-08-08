# addtest4.s - An example of detecting an overflow condition
.section .data
output:
   .asciz "The result is %d\n"
.section .text
.globl _start
_start:
   movl $-190876934, %ebx
   movl $-159230143, %eax
   addl %eax, %ebx
   jo over
   pushl %ebx
   pushl $output
   call printf
   add  $8, %esp
   pushl $0
   call exit
over:
   pushl $0
   pushl $output
   call printf
   add  $8, %esp
   pushl $0
   call exit
