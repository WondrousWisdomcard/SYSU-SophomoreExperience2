# cpuidtest.s - An example of using the TEST instruction
.section .data
output_cpuid:
   .asciz "This processor supports the CPUID instruction\n"
output_nocpuid:
   .asciz "This processor does not support the CPUID instruction\n"
.section .text
.globl _start
_start:
   nop
   pushfl
   popl %eax
   movl %eax, %edx
   xor $0x00200000, %eax
   pushl %eax
   popfl
   pushfl
   popl %eax
   xor %edx, %eax
   test $0x00200000, %eax
   jnz cpuid
   pushl $output_nocpuid
   call printf
   add  $4, %esp
   pushl $0
   call exit
cpuid:
   pushl $output_cpuid
   call printf
   add  $4, %esp
   pushl $0
   call exit
