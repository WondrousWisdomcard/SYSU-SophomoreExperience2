# calltest.s -– An example of using the CALL instruction
.section .data
output:
   .asciz "This is section %d\n"
.section .text
.globl _start
_start:
   pushl $1
   pushl $output
   call printf
   add  $8, %esp
   call overhere
   pushl $3
   pushl $output
   call printf
   add  $8, %esp
   pushl $0
   call exit
overhere:
   pushl %ebp
   movl %esp, %ebp
   pushl $2
   pushl $output
   call printf
   add  $8, %esp
   movl %ebp, %esp
   popl %ebp
   ret
