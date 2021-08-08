# sbbtest.s - An example of using the SBB instruction
.section .data
data1:
   .quad 7252051615
data2:
   .quad 5732348928
output:
   .asciz "The result is %qd\n"
.section .text
.globl _start
_start:
   nop
   movl data1, %ebx
   movl data1+4, %eax
   movl data2, %edx
   movl data2+4, %ecx
   subl %ebx, %edx
   sbbl %eax, %ecx
   pushl %ecx
   pushl %edx
   push $output
   call printf
   add  $12, %esp
   pushl $0
   call exit
