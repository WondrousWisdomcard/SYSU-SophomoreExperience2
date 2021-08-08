# convtest.s - An example of data conversion
.section .data
value1:
   .float 1.25, 124.79, 200.0, -312.5
value2:
   .int 1, -435, 0, -25
.section .bss
   .lcomm data2, 16
.section .text
.globl _start
_start:
   nop
   cvtps2dq value1, %xmm0
   cvttps2dq value1, %xmm1
   cvtdq2ps value2, %xmm2
   movdqu %xmm0, data2

   movl $1, %eax
   movl $0, %ebx
   int $0x80
