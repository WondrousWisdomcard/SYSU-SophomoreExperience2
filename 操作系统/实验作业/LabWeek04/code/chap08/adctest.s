# adctest.s - An example of using the ADC instruction
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
   movl data1, %ebx
   movl data1+4, %eax
   movl data2, %edx
   movl data2+4, %ecx
   addl %ebx, %edx
   adcl %eax, %ecx
   pushl %ecx
   pushl %edx
   push $output
   call printf
   addl $12, %esp
   pushl $0
   call exit
