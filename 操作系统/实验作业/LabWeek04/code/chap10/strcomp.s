# strcomp.s - An example of comparing strings
.section .data
string1:
   .ascii "test"
length1:
   .int 4
string2:
   .ascii "test1"
length2:
   .int 5
.section .text
.globl _start
_start:
   nop
   lea string1, %esi
   lea string2, %edi
   movl length1, %ecx
   movl length2, %eax
   cmpl %eax, %ecx
   ja longer
   xchg %ecx, %eax
longer:
   cld
   repe cmpsb
   je equal
   jg greater
less:
   movl $1, %eax
   movl $255, %ebx
   int $0x80
greater:
   movl $1, %eax
   movl $1, %ebx
   int $0x80
equal:
   movl length1, %ecx
   movl length2, %eax
   cmpl %ecx, %eax
   jg greater
   jl less
   movl $1, %eax
   movl $0, %ebx
   int $0x80
