# ssefloat.s - An example of moving SSE FP data types
.section .data
value1:
   .float 12.34, 2345.543, -3493.2, 0.44901
value2:
   .float -5439.234, 32121.4, 1.0094, 0.000003
.section .bss
   .lcomm data, 16
.section .text
.globl _start
_start:
   nop
   movups value1, %xmm0
   movups value2, %xmm1
   movups %xmm0, %xmm2
   movups %xmm0, data

   movl $1, %eax
   movl $0, %ebx
   int $0x80
