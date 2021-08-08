
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 b0 11 40       	mov    $0x4011b000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 b0 11 00       	mov    %eax,0x11b000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 a0 11 00       	mov    $0x11a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	f3 0f 1e fb          	endbr32 
  10003a:	55                   	push   %ebp
  10003b:	89 e5                	mov    %esp,%ebp
  10003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100040:	b8 88 df 11 00       	mov    $0x11df88,%eax
  100045:	2d 36 aa 11 00       	sub    $0x11aa36,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 aa 11 00 	movl   $0x11aa36,(%esp)
  10005d:	e8 d4 5b 00 00       	call   105c36 <memset>

    cons_init();                // init the console
  100062:	e8 54 16 00 00       	call   1016bb <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 60 64 10 00 	movl   $0x106460,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 7c 64 10 00 	movl   $0x10647c,(%esp)
  10007c:	e8 49 02 00 00       	call   1002ca <cprintf>

    print_kerninfo();
  100081:	e8 07 09 00 00       	call   10098d <print_kerninfo>

    grade_backtrace();
  100086:	e8 9a 00 00 00       	call   100125 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 b1 33 00 00       	call   103441 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 a1 17 00 00       	call   101836 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 21 19 00 00       	call   1019bb <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 63 0d 00 00       	call   100e02 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 de 18 00 00       	call   101982 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
	lab1_switch_test();
  1000a4:	e8 87 01 00 00       	call   100230 <lab1_switch_test>
	
    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	f3 0f 1e fb          	endbr32 
  1000af:	55                   	push   %ebp
  1000b0:	89 e5                	mov    %esp,%ebp
  1000b2:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000bc:	00 
  1000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c4:	00 
  1000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000cc:	e8 1b 0d 00 00       	call   100dec <mon_backtrace>
}
  1000d1:	90                   	nop
  1000d2:	c9                   	leave  
  1000d3:	c3                   	ret    

001000d4 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000d4:	f3 0f 1e fb          	endbr32 
  1000d8:	55                   	push   %ebp
  1000d9:	89 e5                	mov    %esp,%ebp
  1000db:	53                   	push   %ebx
  1000dc:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000df:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000e5:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1000eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000f7:	89 04 24             	mov    %eax,(%esp)
  1000fa:	e8 ac ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000ff:	90                   	nop
  100100:	83 c4 14             	add    $0x14,%esp
  100103:	5b                   	pop    %ebx
  100104:	5d                   	pop    %ebp
  100105:	c3                   	ret    

00100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  100106:	f3 0f 1e fb          	endbr32 
  10010a:	55                   	push   %ebp
  10010b:	89 e5                	mov    %esp,%ebp
  10010d:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100110:	8b 45 10             	mov    0x10(%ebp),%eax
  100113:	89 44 24 04          	mov    %eax,0x4(%esp)
  100117:	8b 45 08             	mov    0x8(%ebp),%eax
  10011a:	89 04 24             	mov    %eax,(%esp)
  10011d:	e8 b2 ff ff ff       	call   1000d4 <grade_backtrace1>
}
  100122:	90                   	nop
  100123:	c9                   	leave  
  100124:	c3                   	ret    

00100125 <grade_backtrace>:

void
grade_backtrace(void) {
  100125:	f3 0f 1e fb          	endbr32 
  100129:	55                   	push   %ebp
  10012a:	89 e5                	mov    %esp,%ebp
  10012c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10012f:	b8 36 00 10 00       	mov    $0x100036,%eax
  100134:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10013b:	ff 
  10013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100147:	e8 ba ff ff ff       	call   100106 <grade_backtrace0>
}
  10014c:	90                   	nop
  10014d:	c9                   	leave  
  10014e:	c3                   	ret    

0010014f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10014f:	f3 0f 1e fb          	endbr32 
  100153:	55                   	push   %ebp
  100154:	89 e5                	mov    %esp,%ebp
  100156:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100159:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10015c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10015f:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100162:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100165:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100169:	83 e0 03             	and    $0x3,%eax
  10016c:	89 c2                	mov    %eax,%edx
  10016e:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100173:	89 54 24 08          	mov    %edx,0x8(%esp)
  100177:	89 44 24 04          	mov    %eax,0x4(%esp)
  10017b:	c7 04 24 81 64 10 00 	movl   $0x106481,(%esp)
  100182:	e8 43 01 00 00       	call   1002ca <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100187:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10018b:	89 c2                	mov    %eax,%edx
  10018d:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100192:	89 54 24 08          	mov    %edx,0x8(%esp)
  100196:	89 44 24 04          	mov    %eax,0x4(%esp)
  10019a:	c7 04 24 8f 64 10 00 	movl   $0x10648f,(%esp)
  1001a1:	e8 24 01 00 00       	call   1002ca <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  1001a6:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  1001aa:	89 c2                	mov    %eax,%edx
  1001ac:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b9:	c7 04 24 9d 64 10 00 	movl   $0x10649d,(%esp)
  1001c0:	e8 05 01 00 00       	call   1002ca <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001c5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001c9:	89 c2                	mov    %eax,%edx
  1001cb:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001d8:	c7 04 24 ab 64 10 00 	movl   $0x1064ab,(%esp)
  1001df:	e8 e6 00 00 00       	call   1002ca <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001e8:	89 c2                	mov    %eax,%edx
  1001ea:	a1 00 d0 11 00       	mov    0x11d000,%eax
  1001ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001f7:	c7 04 24 b9 64 10 00 	movl   $0x1064b9,(%esp)
  1001fe:	e8 c7 00 00 00       	call   1002ca <cprintf>
    round ++;
  100203:	a1 00 d0 11 00       	mov    0x11d000,%eax
  100208:	40                   	inc    %eax
  100209:	a3 00 d0 11 00       	mov    %eax,0x11d000
}
  10020e:	90                   	nop
  10020f:	c9                   	leave  
  100210:	c3                   	ret    

00100211 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100211:	f3 0f 1e fb          	endbr32 
  100215:	55                   	push   %ebp
  100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  100218:	83 ec 08             	sub    $0x8,%esp
  10021b:	cd 78                	int    $0x78
  10021d:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  10021f:	90                   	nop
  100220:	5d                   	pop    %ebp
  100221:	c3                   	ret    

00100222 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100222:	f3 0f 1e fb          	endbr32 
  100226:	55                   	push   %ebp
  100227:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  100229:	cd 79                	int    $0x79
  10022b:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  10022d:	90                   	nop
  10022e:	5d                   	pop    %ebp
  10022f:	c3                   	ret    

00100230 <lab1_switch_test>:


static void
lab1_switch_test(void) {
  100230:	f3 0f 1e fb          	endbr32 
  100234:	55                   	push   %ebp
  100235:	89 e5                	mov    %esp,%ebp
  100237:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10023a:	e8 10 ff ff ff       	call   10014f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10023f:	c7 04 24 c8 64 10 00 	movl   $0x1064c8,(%esp)
  100246:	e8 7f 00 00 00       	call   1002ca <cprintf>
    lab1_switch_to_user();
  10024b:	e8 c1 ff ff ff       	call   100211 <lab1_switch_to_user>
    lab1_print_cur_status();
  100250:	e8 fa fe ff ff       	call   10014f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100255:	c7 04 24 e8 64 10 00 	movl   $0x1064e8,(%esp)
  10025c:	e8 69 00 00 00       	call   1002ca <cprintf>
    lab1_switch_to_kernel();
  100261:	e8 bc ff ff ff       	call   100222 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100266:	e8 e4 fe ff ff       	call   10014f <lab1_print_cur_status>
}
  10026b:	90                   	nop
  10026c:	c9                   	leave  
  10026d:	c3                   	ret    

0010026e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10026e:	f3 0f 1e fb          	endbr32 
  100272:	55                   	push   %ebp
  100273:	89 e5                	mov    %esp,%ebp
  100275:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100278:	8b 45 08             	mov    0x8(%ebp),%eax
  10027b:	89 04 24             	mov    %eax,(%esp)
  10027e:	e8 69 14 00 00       	call   1016ec <cons_putc>
    (*cnt) ++;
  100283:	8b 45 0c             	mov    0xc(%ebp),%eax
  100286:	8b 00                	mov    (%eax),%eax
  100288:	8d 50 01             	lea    0x1(%eax),%edx
  10028b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10028e:	89 10                	mov    %edx,(%eax)
}
  100290:	90                   	nop
  100291:	c9                   	leave  
  100292:	c3                   	ret    

00100293 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100293:	f3 0f 1e fb          	endbr32 
  100297:	55                   	push   %ebp
  100298:	89 e5                	mov    %esp,%ebp
  10029a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10029d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  1002b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002b9:	c7 04 24 6e 02 10 00 	movl   $0x10026e,(%esp)
  1002c0:	e8 dd 5c 00 00       	call   105fa2 <vprintfmt>
    return cnt;
  1002c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002c8:	c9                   	leave  
  1002c9:	c3                   	ret    

001002ca <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  1002ca:	f3 0f 1e fb          	endbr32 
  1002ce:	55                   	push   %ebp
  1002cf:	89 e5                	mov    %esp,%ebp
  1002d1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1002d4:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1002e4:	89 04 24             	mov    %eax,(%esp)
  1002e7:	e8 a7 ff ff ff       	call   100293 <vcprintf>
  1002ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002f2:	c9                   	leave  
  1002f3:	c3                   	ret    

001002f4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002f4:	f3 0f 1e fb          	endbr32 
  1002f8:	55                   	push   %ebp
  1002f9:	89 e5                	mov    %esp,%ebp
  1002fb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100301:	89 04 24             	mov    %eax,(%esp)
  100304:	e8 e3 13 00 00       	call   1016ec <cons_putc>
}
  100309:	90                   	nop
  10030a:	c9                   	leave  
  10030b:	c3                   	ret    

0010030c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10030c:	f3 0f 1e fb          	endbr32 
  100310:	55                   	push   %ebp
  100311:	89 e5                	mov    %esp,%ebp
  100313:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100316:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10031d:	eb 13                	jmp    100332 <cputs+0x26>
        cputch(c, &cnt);
  10031f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100323:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100326:	89 54 24 04          	mov    %edx,0x4(%esp)
  10032a:	89 04 24             	mov    %eax,(%esp)
  10032d:	e8 3c ff ff ff       	call   10026e <cputch>
    while ((c = *str ++) != '\0') {
  100332:	8b 45 08             	mov    0x8(%ebp),%eax
  100335:	8d 50 01             	lea    0x1(%eax),%edx
  100338:	89 55 08             	mov    %edx,0x8(%ebp)
  10033b:	0f b6 00             	movzbl (%eax),%eax
  10033e:	88 45 f7             	mov    %al,-0x9(%ebp)
  100341:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100345:	75 d8                	jne    10031f <cputs+0x13>
    }
    cputch('\n', &cnt);
  100347:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10034a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10034e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100355:	e8 14 ff ff ff       	call   10026e <cputch>
    return cnt;
  10035a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10035d:	c9                   	leave  
  10035e:	c3                   	ret    

0010035f <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10035f:	f3 0f 1e fb          	endbr32 
  100363:	55                   	push   %ebp
  100364:	89 e5                	mov    %esp,%ebp
  100366:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100369:	90                   	nop
  10036a:	e8 be 13 00 00       	call   10172d <cons_getc>
  10036f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100372:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100376:	74 f2                	je     10036a <getchar+0xb>
        /* do nothing */;
    return c;
  100378:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037b:	c9                   	leave  
  10037c:	c3                   	ret    

0010037d <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10037d:	f3 0f 1e fb          	endbr32 
  100381:	55                   	push   %ebp
  100382:	89 e5                	mov    %esp,%ebp
  100384:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100387:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10038b:	74 13                	je     1003a0 <readline+0x23>
        cprintf("%s", prompt);
  10038d:	8b 45 08             	mov    0x8(%ebp),%eax
  100390:	89 44 24 04          	mov    %eax,0x4(%esp)
  100394:	c7 04 24 07 65 10 00 	movl   $0x106507,(%esp)
  10039b:	e8 2a ff ff ff       	call   1002ca <cprintf>
    }
    int i = 0, c;
  1003a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  1003a7:	e8 b3 ff ff ff       	call   10035f <getchar>
  1003ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  1003af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1003b3:	79 07                	jns    1003bc <readline+0x3f>
            return NULL;
  1003b5:	b8 00 00 00 00       	mov    $0x0,%eax
  1003ba:	eb 78                	jmp    100434 <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  1003bc:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  1003c0:	7e 28                	jle    1003ea <readline+0x6d>
  1003c2:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  1003c9:	7f 1f                	jg     1003ea <readline+0x6d>
            cputchar(c);
  1003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003ce:	89 04 24             	mov    %eax,(%esp)
  1003d1:	e8 1e ff ff ff       	call   1002f4 <cputchar>
            buf[i ++] = c;
  1003d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d9:	8d 50 01             	lea    0x1(%eax),%edx
  1003dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003e2:	88 90 20 d0 11 00    	mov    %dl,0x11d020(%eax)
  1003e8:	eb 45                	jmp    10042f <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
  1003ea:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003ee:	75 16                	jne    100406 <readline+0x89>
  1003f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f4:	7e 10                	jle    100406 <readline+0x89>
            cputchar(c);
  1003f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003f9:	89 04 24             	mov    %eax,(%esp)
  1003fc:	e8 f3 fe ff ff       	call   1002f4 <cputchar>
            i --;
  100401:	ff 4d f4             	decl   -0xc(%ebp)
  100404:	eb 29                	jmp    10042f <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
  100406:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  10040a:	74 06                	je     100412 <readline+0x95>
  10040c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  100410:	75 95                	jne    1003a7 <readline+0x2a>
            cputchar(c);
  100412:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100415:	89 04 24             	mov    %eax,(%esp)
  100418:	e8 d7 fe ff ff       	call   1002f4 <cputchar>
            buf[i] = '\0';
  10041d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100420:	05 20 d0 11 00       	add    $0x11d020,%eax
  100425:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100428:	b8 20 d0 11 00       	mov    $0x11d020,%eax
  10042d:	eb 05                	jmp    100434 <readline+0xb7>
        c = getchar();
  10042f:	e9 73 ff ff ff       	jmp    1003a7 <readline+0x2a>
        }
    }
}
  100434:	c9                   	leave  
  100435:	c3                   	ret    

00100436 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100436:	f3 0f 1e fb          	endbr32 
  10043a:	55                   	push   %ebp
  10043b:	89 e5                	mov    %esp,%ebp
  10043d:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100440:	a1 20 d4 11 00       	mov    0x11d420,%eax
  100445:	85 c0                	test   %eax,%eax
  100447:	75 5b                	jne    1004a4 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  100449:	c7 05 20 d4 11 00 01 	movl   $0x1,0x11d420
  100450:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100453:	8d 45 14             	lea    0x14(%ebp),%eax
  100456:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100459:	8b 45 0c             	mov    0xc(%ebp),%eax
  10045c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100460:	8b 45 08             	mov    0x8(%ebp),%eax
  100463:	89 44 24 04          	mov    %eax,0x4(%esp)
  100467:	c7 04 24 0a 65 10 00 	movl   $0x10650a,(%esp)
  10046e:	e8 57 fe ff ff       	call   1002ca <cprintf>
    vcprintf(fmt, ap);
  100473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100476:	89 44 24 04          	mov    %eax,0x4(%esp)
  10047a:	8b 45 10             	mov    0x10(%ebp),%eax
  10047d:	89 04 24             	mov    %eax,(%esp)
  100480:	e8 0e fe ff ff       	call   100293 <vcprintf>
    cprintf("\n");
  100485:	c7 04 24 26 65 10 00 	movl   $0x106526,(%esp)
  10048c:	e8 39 fe ff ff       	call   1002ca <cprintf>
    
    cprintf("stack trackback:\n");
  100491:	c7 04 24 28 65 10 00 	movl   $0x106528,(%esp)
  100498:	e8 2d fe ff ff       	call   1002ca <cprintf>
    print_stackframe();
  10049d:	e8 3d 06 00 00       	call   100adf <print_stackframe>
  1004a2:	eb 01                	jmp    1004a5 <__panic+0x6f>
        goto panic_dead;
  1004a4:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  1004a5:	e8 e4 14 00 00       	call   10198e <intr_disable>
    while (1) {
        kmonitor(NULL);
  1004aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1004b1:	e8 5d 08 00 00       	call   100d13 <kmonitor>
  1004b6:	eb f2                	jmp    1004aa <__panic+0x74>

001004b8 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  1004b8:	f3 0f 1e fb          	endbr32 
  1004bc:	55                   	push   %ebp
  1004bd:	89 e5                	mov    %esp,%ebp
  1004bf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  1004c2:	8d 45 14             	lea    0x14(%ebp),%eax
  1004c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  1004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  1004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004d6:	c7 04 24 3a 65 10 00 	movl   $0x10653a,(%esp)
  1004dd:	e8 e8 fd ff ff       	call   1002ca <cprintf>
    vcprintf(fmt, ap);
  1004e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1004ec:	89 04 24             	mov    %eax,(%esp)
  1004ef:	e8 9f fd ff ff       	call   100293 <vcprintf>
    cprintf("\n");
  1004f4:	c7 04 24 26 65 10 00 	movl   $0x106526,(%esp)
  1004fb:	e8 ca fd ff ff       	call   1002ca <cprintf>
    va_end(ap);
}
  100500:	90                   	nop
  100501:	c9                   	leave  
  100502:	c3                   	ret    

00100503 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100503:	f3 0f 1e fb          	endbr32 
  100507:	55                   	push   %ebp
  100508:	89 e5                	mov    %esp,%ebp
    return is_panic;
  10050a:	a1 20 d4 11 00       	mov    0x11d420,%eax
}
  10050f:	5d                   	pop    %ebp
  100510:	c3                   	ret    

00100511 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100511:	f3 0f 1e fb          	endbr32 
  100515:	55                   	push   %ebp
  100516:	89 e5                	mov    %esp,%ebp
  100518:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100523:	8b 45 10             	mov    0x10(%ebp),%eax
  100526:	8b 00                	mov    (%eax),%eax
  100528:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10052b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100532:	e9 ca 00 00 00       	jmp    100601 <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
  100537:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10053a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10053d:	01 d0                	add    %edx,%eax
  10053f:	89 c2                	mov    %eax,%edx
  100541:	c1 ea 1f             	shr    $0x1f,%edx
  100544:	01 d0                	add    %edx,%eax
  100546:	d1 f8                	sar    %eax
  100548:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10054b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10054e:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100551:	eb 03                	jmp    100556 <stab_binsearch+0x45>
            m --;
  100553:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100559:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10055c:	7c 1f                	jl     10057d <stab_binsearch+0x6c>
  10055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100561:	89 d0                	mov    %edx,%eax
  100563:	01 c0                	add    %eax,%eax
  100565:	01 d0                	add    %edx,%eax
  100567:	c1 e0 02             	shl    $0x2,%eax
  10056a:	89 c2                	mov    %eax,%edx
  10056c:	8b 45 08             	mov    0x8(%ebp),%eax
  10056f:	01 d0                	add    %edx,%eax
  100571:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100575:	0f b6 c0             	movzbl %al,%eax
  100578:	39 45 14             	cmp    %eax,0x14(%ebp)
  10057b:	75 d6                	jne    100553 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
  10057d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100580:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100583:	7d 09                	jge    10058e <stab_binsearch+0x7d>
            l = true_m + 1;
  100585:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100588:	40                   	inc    %eax
  100589:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10058c:	eb 73                	jmp    100601 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
  10058e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100595:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100598:	89 d0                	mov    %edx,%eax
  10059a:	01 c0                	add    %eax,%eax
  10059c:	01 d0                	add    %edx,%eax
  10059e:	c1 e0 02             	shl    $0x2,%eax
  1005a1:	89 c2                	mov    %eax,%edx
  1005a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1005a6:	01 d0                	add    %edx,%eax
  1005a8:	8b 40 08             	mov    0x8(%eax),%eax
  1005ab:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005ae:	76 11                	jbe    1005c1 <stab_binsearch+0xb0>
            *region_left = m;
  1005b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005b6:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1005b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1005bb:	40                   	inc    %eax
  1005bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1005bf:	eb 40                	jmp    100601 <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
  1005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c4:	89 d0                	mov    %edx,%eax
  1005c6:	01 c0                	add    %eax,%eax
  1005c8:	01 d0                	add    %edx,%eax
  1005ca:	c1 e0 02             	shl    $0x2,%eax
  1005cd:	89 c2                	mov    %eax,%edx
  1005cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1005d2:	01 d0                	add    %edx,%eax
  1005d4:	8b 40 08             	mov    0x8(%eax),%eax
  1005d7:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005da:	73 14                	jae    1005f0 <stab_binsearch+0xdf>
            *region_right = m - 1;
  1005dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005df:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005e2:	8b 45 10             	mov    0x10(%ebp),%eax
  1005e5:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1005e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005ea:	48                   	dec    %eax
  1005eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005ee:	eb 11                	jmp    100601 <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005f6:	89 10                	mov    %edx,(%eax)
            l = m;
  1005f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005fe:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  100601:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100604:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100607:	0f 8e 2a ff ff ff    	jle    100537 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
  10060d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100611:	75 0f                	jne    100622 <stab_binsearch+0x111>
        *region_right = *region_left - 1;
  100613:	8b 45 0c             	mov    0xc(%ebp),%eax
  100616:	8b 00                	mov    (%eax),%eax
  100618:	8d 50 ff             	lea    -0x1(%eax),%edx
  10061b:	8b 45 10             	mov    0x10(%ebp),%eax
  10061e:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  100620:	eb 3e                	jmp    100660 <stab_binsearch+0x14f>
        l = *region_right;
  100622:	8b 45 10             	mov    0x10(%ebp),%eax
  100625:	8b 00                	mov    (%eax),%eax
  100627:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  10062a:	eb 03                	jmp    10062f <stab_binsearch+0x11e>
  10062c:	ff 4d fc             	decl   -0x4(%ebp)
  10062f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100632:	8b 00                	mov    (%eax),%eax
  100634:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100637:	7e 1f                	jle    100658 <stab_binsearch+0x147>
  100639:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10063c:	89 d0                	mov    %edx,%eax
  10063e:	01 c0                	add    %eax,%eax
  100640:	01 d0                	add    %edx,%eax
  100642:	c1 e0 02             	shl    $0x2,%eax
  100645:	89 c2                	mov    %eax,%edx
  100647:	8b 45 08             	mov    0x8(%ebp),%eax
  10064a:	01 d0                	add    %edx,%eax
  10064c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100650:	0f b6 c0             	movzbl %al,%eax
  100653:	39 45 14             	cmp    %eax,0x14(%ebp)
  100656:	75 d4                	jne    10062c <stab_binsearch+0x11b>
        *region_left = l;
  100658:	8b 45 0c             	mov    0xc(%ebp),%eax
  10065b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10065e:	89 10                	mov    %edx,(%eax)
}
  100660:	90                   	nop
  100661:	c9                   	leave  
  100662:	c3                   	ret    

00100663 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100663:	f3 0f 1e fb          	endbr32 
  100667:	55                   	push   %ebp
  100668:	89 e5                	mov    %esp,%ebp
  10066a:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10066d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100670:	c7 00 58 65 10 00    	movl   $0x106558,(%eax)
    info->eip_line = 0;
  100676:	8b 45 0c             	mov    0xc(%ebp),%eax
  100679:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100680:	8b 45 0c             	mov    0xc(%ebp),%eax
  100683:	c7 40 08 58 65 10 00 	movl   $0x106558,0x8(%eax)
    info->eip_fn_namelen = 9;
  10068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10068d:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100694:	8b 45 0c             	mov    0xc(%ebp),%eax
  100697:	8b 55 08             	mov    0x8(%ebp),%edx
  10069a:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10069d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006a0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  1006a7:	c7 45 f4 74 77 10 00 	movl   $0x107774,-0xc(%ebp)
    stab_end = __STAB_END__;
  1006ae:	c7 45 f0 94 44 11 00 	movl   $0x114494,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  1006b5:	c7 45 ec 95 44 11 00 	movl   $0x114495,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1006bc:	c7 45 e8 16 70 11 00 	movl   $0x117016,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1006c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1006c9:	76 0b                	jbe    1006d6 <debuginfo_eip+0x73>
  1006cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006ce:	48                   	dec    %eax
  1006cf:	0f b6 00             	movzbl (%eax),%eax
  1006d2:	84 c0                	test   %al,%al
  1006d4:	74 0a                	je     1006e0 <debuginfo_eip+0x7d>
        return -1;
  1006d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006db:	e9 ab 02 00 00       	jmp    10098b <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1006e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1006e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1006ea:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1006ed:	c1 f8 02             	sar    $0x2,%eax
  1006f0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006f6:	48                   	dec    %eax
  1006f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1006fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  100701:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100708:	00 
  100709:	8d 45 e0             	lea    -0x20(%ebp),%eax
  10070c:	89 44 24 08          	mov    %eax,0x8(%esp)
  100710:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100713:	89 44 24 04          	mov    %eax,0x4(%esp)
  100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10071a:	89 04 24             	mov    %eax,(%esp)
  10071d:	e8 ef fd ff ff       	call   100511 <stab_binsearch>
    if (lfile == 0)
  100722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100725:	85 c0                	test   %eax,%eax
  100727:	75 0a                	jne    100733 <debuginfo_eip+0xd0>
        return -1;
  100729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10072e:	e9 58 02 00 00       	jmp    10098b <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100736:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100739:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10073f:	8b 45 08             	mov    0x8(%ebp),%eax
  100742:	89 44 24 10          	mov    %eax,0x10(%esp)
  100746:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10074d:	00 
  10074e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100751:	89 44 24 08          	mov    %eax,0x8(%esp)
  100755:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100758:	89 44 24 04          	mov    %eax,0x4(%esp)
  10075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075f:	89 04 24             	mov    %eax,(%esp)
  100762:	e8 aa fd ff ff       	call   100511 <stab_binsearch>

    if (lfun <= rfun) {
  100767:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10076d:	39 c2                	cmp    %eax,%edx
  10076f:	7f 78                	jg     1007e9 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100771:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100774:	89 c2                	mov    %eax,%edx
  100776:	89 d0                	mov    %edx,%eax
  100778:	01 c0                	add    %eax,%eax
  10077a:	01 d0                	add    %edx,%eax
  10077c:	c1 e0 02             	shl    $0x2,%eax
  10077f:	89 c2                	mov    %eax,%edx
  100781:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100784:	01 d0                	add    %edx,%eax
  100786:	8b 10                	mov    (%eax),%edx
  100788:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10078b:	2b 45 ec             	sub    -0x14(%ebp),%eax
  10078e:	39 c2                	cmp    %eax,%edx
  100790:	73 22                	jae    1007b4 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100795:	89 c2                	mov    %eax,%edx
  100797:	89 d0                	mov    %edx,%eax
  100799:	01 c0                	add    %eax,%eax
  10079b:	01 d0                	add    %edx,%eax
  10079d:	c1 e0 02             	shl    $0x2,%eax
  1007a0:	89 c2                	mov    %eax,%edx
  1007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a5:	01 d0                	add    %edx,%eax
  1007a7:	8b 10                	mov    (%eax),%edx
  1007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007ac:	01 c2                	add    %eax,%edx
  1007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b1:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1007b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007b7:	89 c2                	mov    %eax,%edx
  1007b9:	89 d0                	mov    %edx,%eax
  1007bb:	01 c0                	add    %eax,%eax
  1007bd:	01 d0                	add    %edx,%eax
  1007bf:	c1 e0 02             	shl    $0x2,%eax
  1007c2:	89 c2                	mov    %eax,%edx
  1007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c7:	01 d0                	add    %edx,%eax
  1007c9:	8b 50 08             	mov    0x8(%eax),%edx
  1007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007cf:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d5:	8b 40 10             	mov    0x10(%eax),%eax
  1007d8:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1007db:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1007e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1007e7:	eb 15                	jmp    1007fe <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ec:	8b 55 08             	mov    0x8(%ebp),%edx
  1007ef:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  100801:	8b 40 08             	mov    0x8(%eax),%eax
  100804:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10080b:	00 
  10080c:	89 04 24             	mov    %eax,(%esp)
  10080f:	e8 96 52 00 00       	call   105aaa <strfind>
  100814:	8b 55 0c             	mov    0xc(%ebp),%edx
  100817:	8b 52 08             	mov    0x8(%edx),%edx
  10081a:	29 d0                	sub    %edx,%eax
  10081c:	89 c2                	mov    %eax,%edx
  10081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100821:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100824:	8b 45 08             	mov    0x8(%ebp),%eax
  100827:	89 44 24 10          	mov    %eax,0x10(%esp)
  10082b:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100832:	00 
  100833:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100836:	89 44 24 08          	mov    %eax,0x8(%esp)
  10083a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  10083d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100844:	89 04 24             	mov    %eax,(%esp)
  100847:	e8 c5 fc ff ff       	call   100511 <stab_binsearch>
    if (lline <= rline) {
  10084c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100852:	39 c2                	cmp    %eax,%edx
  100854:	7f 23                	jg     100879 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
  100856:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100859:	89 c2                	mov    %eax,%edx
  10085b:	89 d0                	mov    %edx,%eax
  10085d:	01 c0                	add    %eax,%eax
  10085f:	01 d0                	add    %edx,%eax
  100861:	c1 e0 02             	shl    $0x2,%eax
  100864:	89 c2                	mov    %eax,%edx
  100866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100869:	01 d0                	add    %edx,%eax
  10086b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10086f:	89 c2                	mov    %eax,%edx
  100871:	8b 45 0c             	mov    0xc(%ebp),%eax
  100874:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100877:	eb 11                	jmp    10088a <debuginfo_eip+0x227>
        return -1;
  100879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10087e:	e9 08 01 00 00       	jmp    10098b <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100883:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100886:	48                   	dec    %eax
  100887:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10088a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10088d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100890:	39 c2                	cmp    %eax,%edx
  100892:	7c 56                	jl     1008ea <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
  100894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100897:	89 c2                	mov    %eax,%edx
  100899:	89 d0                	mov    %edx,%eax
  10089b:	01 c0                	add    %eax,%eax
  10089d:	01 d0                	add    %edx,%eax
  10089f:	c1 e0 02             	shl    $0x2,%eax
  1008a2:	89 c2                	mov    %eax,%edx
  1008a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008a7:	01 d0                	add    %edx,%eax
  1008a9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008ad:	3c 84                	cmp    $0x84,%al
  1008af:	74 39                	je     1008ea <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1008b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b4:	89 c2                	mov    %eax,%edx
  1008b6:	89 d0                	mov    %edx,%eax
  1008b8:	01 c0                	add    %eax,%eax
  1008ba:	01 d0                	add    %edx,%eax
  1008bc:	c1 e0 02             	shl    $0x2,%eax
  1008bf:	89 c2                	mov    %eax,%edx
  1008c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008c4:	01 d0                	add    %edx,%eax
  1008c6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008ca:	3c 64                	cmp    $0x64,%al
  1008cc:	75 b5                	jne    100883 <debuginfo_eip+0x220>
  1008ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d1:	89 c2                	mov    %eax,%edx
  1008d3:	89 d0                	mov    %edx,%eax
  1008d5:	01 c0                	add    %eax,%eax
  1008d7:	01 d0                	add    %edx,%eax
  1008d9:	c1 e0 02             	shl    $0x2,%eax
  1008dc:	89 c2                	mov    %eax,%edx
  1008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e1:	01 d0                	add    %edx,%eax
  1008e3:	8b 40 08             	mov    0x8(%eax),%eax
  1008e6:	85 c0                	test   %eax,%eax
  1008e8:	74 99                	je     100883 <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008f0:	39 c2                	cmp    %eax,%edx
  1008f2:	7c 42                	jl     100936 <debuginfo_eip+0x2d3>
  1008f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f7:	89 c2                	mov    %eax,%edx
  1008f9:	89 d0                	mov    %edx,%eax
  1008fb:	01 c0                	add    %eax,%eax
  1008fd:	01 d0                	add    %edx,%eax
  1008ff:	c1 e0 02             	shl    $0x2,%eax
  100902:	89 c2                	mov    %eax,%edx
  100904:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100907:	01 d0                	add    %edx,%eax
  100909:	8b 10                	mov    (%eax),%edx
  10090b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10090e:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100911:	39 c2                	cmp    %eax,%edx
  100913:	73 21                	jae    100936 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100915:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100918:	89 c2                	mov    %eax,%edx
  10091a:	89 d0                	mov    %edx,%eax
  10091c:	01 c0                	add    %eax,%eax
  10091e:	01 d0                	add    %edx,%eax
  100920:	c1 e0 02             	shl    $0x2,%eax
  100923:	89 c2                	mov    %eax,%edx
  100925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100928:	01 d0                	add    %edx,%eax
  10092a:	8b 10                	mov    (%eax),%edx
  10092c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10092f:	01 c2                	add    %eax,%edx
  100931:	8b 45 0c             	mov    0xc(%ebp),%eax
  100934:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100936:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100939:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10093c:	39 c2                	cmp    %eax,%edx
  10093e:	7d 46                	jge    100986 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
  100940:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100943:	40                   	inc    %eax
  100944:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100947:	eb 16                	jmp    10095f <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100949:	8b 45 0c             	mov    0xc(%ebp),%eax
  10094c:	8b 40 14             	mov    0x14(%eax),%eax
  10094f:	8d 50 01             	lea    0x1(%eax),%edx
  100952:	8b 45 0c             	mov    0xc(%ebp),%eax
  100955:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100958:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10095b:	40                   	inc    %eax
  10095c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10095f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100962:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100965:	39 c2                	cmp    %eax,%edx
  100967:	7d 1d                	jge    100986 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100969:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10096c:	89 c2                	mov    %eax,%edx
  10096e:	89 d0                	mov    %edx,%eax
  100970:	01 c0                	add    %eax,%eax
  100972:	01 d0                	add    %edx,%eax
  100974:	c1 e0 02             	shl    $0x2,%eax
  100977:	89 c2                	mov    %eax,%edx
  100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097c:	01 d0                	add    %edx,%eax
  10097e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100982:	3c a0                	cmp    $0xa0,%al
  100984:	74 c3                	je     100949 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
  100986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10098b:	c9                   	leave  
  10098c:	c3                   	ret    

0010098d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10098d:	f3 0f 1e fb          	endbr32 
  100991:	55                   	push   %ebp
  100992:	89 e5                	mov    %esp,%ebp
  100994:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100997:	c7 04 24 62 65 10 00 	movl   $0x106562,(%esp)
  10099e:	e8 27 f9 ff ff       	call   1002ca <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  1009a3:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1009aa:	00 
  1009ab:	c7 04 24 7b 65 10 00 	movl   $0x10657b,(%esp)
  1009b2:	e8 13 f9 ff ff       	call   1002ca <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1009b7:	c7 44 24 04 5a 64 10 	movl   $0x10645a,0x4(%esp)
  1009be:	00 
  1009bf:	c7 04 24 93 65 10 00 	movl   $0x106593,(%esp)
  1009c6:	e8 ff f8 ff ff       	call   1002ca <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1009cb:	c7 44 24 04 36 aa 11 	movl   $0x11aa36,0x4(%esp)
  1009d2:	00 
  1009d3:	c7 04 24 ab 65 10 00 	movl   $0x1065ab,(%esp)
  1009da:	e8 eb f8 ff ff       	call   1002ca <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1009df:	c7 44 24 04 88 df 11 	movl   $0x11df88,0x4(%esp)
  1009e6:	00 
  1009e7:	c7 04 24 c3 65 10 00 	movl   $0x1065c3,(%esp)
  1009ee:	e8 d7 f8 ff ff       	call   1002ca <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009f3:	b8 88 df 11 00       	mov    $0x11df88,%eax
  1009f8:	2d 36 00 10 00       	sub    $0x100036,%eax
  1009fd:	05 ff 03 00 00       	add    $0x3ff,%eax
  100a02:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100a08:	85 c0                	test   %eax,%eax
  100a0a:	0f 48 c2             	cmovs  %edx,%eax
  100a0d:	c1 f8 0a             	sar    $0xa,%eax
  100a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a14:	c7 04 24 dc 65 10 00 	movl   $0x1065dc,(%esp)
  100a1b:	e8 aa f8 ff ff       	call   1002ca <cprintf>
}
  100a20:	90                   	nop
  100a21:	c9                   	leave  
  100a22:	c3                   	ret    

00100a23 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100a23:	f3 0f 1e fb          	endbr32 
  100a27:	55                   	push   %ebp
  100a28:	89 e5                	mov    %esp,%ebp
  100a2a:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100a30:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a37:	8b 45 08             	mov    0x8(%ebp),%eax
  100a3a:	89 04 24             	mov    %eax,(%esp)
  100a3d:	e8 21 fc ff ff       	call   100663 <debuginfo_eip>
  100a42:	85 c0                	test   %eax,%eax
  100a44:	74 15                	je     100a5b <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100a46:	8b 45 08             	mov    0x8(%ebp),%eax
  100a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a4d:	c7 04 24 06 66 10 00 	movl   $0x106606,(%esp)
  100a54:	e8 71 f8 ff ff       	call   1002ca <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a59:	eb 6c                	jmp    100ac7 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a62:	eb 1b                	jmp    100a7f <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
  100a64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6a:	01 d0                	add    %edx,%eax
  100a6c:	0f b6 10             	movzbl (%eax),%edx
  100a6f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a78:	01 c8                	add    %ecx,%eax
  100a7a:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a7c:	ff 45 f4             	incl   -0xc(%ebp)
  100a7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a85:	7c dd                	jl     100a64 <print_debuginfo+0x41>
        fnname[j] = '\0';
  100a87:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a90:	01 d0                	add    %edx,%eax
  100a92:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a98:	8b 55 08             	mov    0x8(%ebp),%edx
  100a9b:	89 d1                	mov    %edx,%ecx
  100a9d:	29 c1                	sub    %eax,%ecx
  100a9f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100aa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100aa5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100aa9:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100aaf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100ab3:	89 54 24 08          	mov    %edx,0x8(%esp)
  100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100abb:	c7 04 24 22 66 10 00 	movl   $0x106622,(%esp)
  100ac2:	e8 03 f8 ff ff       	call   1002ca <cprintf>
}
  100ac7:	90                   	nop
  100ac8:	c9                   	leave  
  100ac9:	c3                   	ret    

00100aca <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100aca:	f3 0f 1e fb          	endbr32 
  100ace:	55                   	push   %ebp
  100acf:	89 e5                	mov    %esp,%ebp
  100ad1:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100ad4:	8b 45 04             	mov    0x4(%ebp),%eax
  100ad7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100ada:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100add:	c9                   	leave  
  100ade:	c3                   	ret    

00100adf <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100adf:	f3 0f 1e fb          	endbr32 
  100ae3:	55                   	push   %ebp
  100ae4:	89 e5                	mov    %esp,%ebp
  100ae6:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100ae9:	89 e8                	mov    %ebp,%eax
  100aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100aee:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();
  100af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100af4:	e8 d1 ff ff ff       	call   100aca <read_eip>
  100af9:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100afc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100b03:	e9 84 00 00 00       	jmp    100b8c <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b16:	c7 04 24 34 66 10 00 	movl   $0x106634,(%esp)
  100b1d:	e8 a8 f7 ff ff       	call   1002ca <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b25:	83 c0 08             	add    $0x8,%eax
  100b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100b2b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100b32:	eb 24                	jmp    100b58 <print_stackframe+0x79>
            cprintf("0x%08x ", args[j]);
  100b34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b41:	01 d0                	add    %edx,%eax
  100b43:	8b 00                	mov    (%eax),%eax
  100b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b49:	c7 04 24 50 66 10 00 	movl   $0x106650,(%esp)
  100b50:	e8 75 f7 ff ff       	call   1002ca <cprintf>
        for (j = 0; j < 4; j ++) {
  100b55:	ff 45 e8             	incl   -0x18(%ebp)
  100b58:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b5c:	7e d6                	jle    100b34 <print_stackframe+0x55>
        }
        cprintf("\n");
  100b5e:	c7 04 24 58 66 10 00 	movl   $0x106658,(%esp)
  100b65:	e8 60 f7 ff ff       	call   1002ca <cprintf>
        print_debuginfo(eip - 1);
  100b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b6d:	48                   	dec    %eax
  100b6e:	89 04 24             	mov    %eax,(%esp)
  100b71:	e8 ad fe ff ff       	call   100a23 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b79:	83 c0 04             	add    $0x4,%eax
  100b7c:	8b 00                	mov    (%eax),%eax
  100b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b84:	8b 00                	mov    (%eax),%eax
  100b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100b89:	ff 45 ec             	incl   -0x14(%ebp)
  100b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b90:	74 0a                	je     100b9c <print_stackframe+0xbd>
  100b92:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b96:	0f 8e 6c ff ff ff    	jle    100b08 <print_stackframe+0x29>
    }
}
  100b9c:	90                   	nop
  100b9d:	c9                   	leave  
  100b9e:	c3                   	ret    

00100b9f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b9f:	f3 0f 1e fb          	endbr32 
  100ba3:	55                   	push   %ebp
  100ba4:	89 e5                	mov    %esp,%ebp
  100ba6:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100ba9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bb0:	eb 0c                	jmp    100bbe <parse+0x1f>
            *buf ++ = '\0';
  100bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb5:	8d 50 01             	lea    0x1(%eax),%edx
  100bb8:	89 55 08             	mov    %edx,0x8(%ebp)
  100bbb:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc1:	0f b6 00             	movzbl (%eax),%eax
  100bc4:	84 c0                	test   %al,%al
  100bc6:	74 1d                	je     100be5 <parse+0x46>
  100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  100bcb:	0f b6 00             	movzbl (%eax),%eax
  100bce:	0f be c0             	movsbl %al,%eax
  100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bd5:	c7 04 24 dc 66 10 00 	movl   $0x1066dc,(%esp)
  100bdc:	e8 93 4e 00 00       	call   105a74 <strchr>
  100be1:	85 c0                	test   %eax,%eax
  100be3:	75 cd                	jne    100bb2 <parse+0x13>
        }
        if (*buf == '\0') {
  100be5:	8b 45 08             	mov    0x8(%ebp),%eax
  100be8:	0f b6 00             	movzbl (%eax),%eax
  100beb:	84 c0                	test   %al,%al
  100bed:	74 65                	je     100c54 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bef:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bf3:	75 14                	jne    100c09 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bf5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100bfc:	00 
  100bfd:	c7 04 24 e1 66 10 00 	movl   $0x1066e1,(%esp)
  100c04:	e8 c1 f6 ff ff       	call   1002ca <cprintf>
        }
        argv[argc ++] = buf;
  100c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c0c:	8d 50 01             	lea    0x1(%eax),%edx
  100c0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100c12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100c19:	8b 45 0c             	mov    0xc(%ebp),%eax
  100c1c:	01 c2                	add    %eax,%edx
  100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  100c21:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100c23:	eb 03                	jmp    100c28 <parse+0x89>
            buf ++;
  100c25:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100c28:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2b:	0f b6 00             	movzbl (%eax),%eax
  100c2e:	84 c0                	test   %al,%al
  100c30:	74 8c                	je     100bbe <parse+0x1f>
  100c32:	8b 45 08             	mov    0x8(%ebp),%eax
  100c35:	0f b6 00             	movzbl (%eax),%eax
  100c38:	0f be c0             	movsbl %al,%eax
  100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c3f:	c7 04 24 dc 66 10 00 	movl   $0x1066dc,(%esp)
  100c46:	e8 29 4e 00 00       	call   105a74 <strchr>
  100c4b:	85 c0                	test   %eax,%eax
  100c4d:	74 d6                	je     100c25 <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c4f:	e9 6a ff ff ff       	jmp    100bbe <parse+0x1f>
            break;
  100c54:	90                   	nop
        }
    }
    return argc;
  100c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c58:	c9                   	leave  
  100c59:	c3                   	ret    

00100c5a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c5a:	f3 0f 1e fb          	endbr32 
  100c5e:	55                   	push   %ebp
  100c5f:	89 e5                	mov    %esp,%ebp
  100c61:	53                   	push   %ebx
  100c62:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c65:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  100c6f:	89 04 24             	mov    %eax,(%esp)
  100c72:	e8 28 ff ff ff       	call   100b9f <parse>
  100c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c7e:	75 0a                	jne    100c8a <runcmd+0x30>
        return 0;
  100c80:	b8 00 00 00 00       	mov    $0x0,%eax
  100c85:	e9 83 00 00 00       	jmp    100d0d <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c91:	eb 5a                	jmp    100ced <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c93:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c99:	89 d0                	mov    %edx,%eax
  100c9b:	01 c0                	add    %eax,%eax
  100c9d:	01 d0                	add    %edx,%eax
  100c9f:	c1 e0 02             	shl    $0x2,%eax
  100ca2:	05 00 a0 11 00       	add    $0x11a000,%eax
  100ca7:	8b 00                	mov    (%eax),%eax
  100ca9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100cad:	89 04 24             	mov    %eax,(%esp)
  100cb0:	e8 1b 4d 00 00       	call   1059d0 <strcmp>
  100cb5:	85 c0                	test   %eax,%eax
  100cb7:	75 31                	jne    100cea <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
  100cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cbc:	89 d0                	mov    %edx,%eax
  100cbe:	01 c0                	add    %eax,%eax
  100cc0:	01 d0                	add    %edx,%eax
  100cc2:	c1 e0 02             	shl    $0x2,%eax
  100cc5:	05 08 a0 11 00       	add    $0x11a008,%eax
  100cca:	8b 10                	mov    (%eax),%edx
  100ccc:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100ccf:	83 c0 04             	add    $0x4,%eax
  100cd2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100cd5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100cdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ce3:	89 1c 24             	mov    %ebx,(%esp)
  100ce6:	ff d2                	call   *%edx
  100ce8:	eb 23                	jmp    100d0d <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cea:	ff 45 f4             	incl   -0xc(%ebp)
  100ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cf0:	83 f8 02             	cmp    $0x2,%eax
  100cf3:	76 9e                	jbe    100c93 <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cfc:	c7 04 24 ff 66 10 00 	movl   $0x1066ff,(%esp)
  100d03:	e8 c2 f5 ff ff       	call   1002ca <cprintf>
    return 0;
  100d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d0d:	83 c4 64             	add    $0x64,%esp
  100d10:	5b                   	pop    %ebx
  100d11:	5d                   	pop    %ebp
  100d12:	c3                   	ret    

00100d13 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100d13:	f3 0f 1e fb          	endbr32 
  100d17:	55                   	push   %ebp
  100d18:	89 e5                	mov    %esp,%ebp
  100d1a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100d1d:	c7 04 24 18 67 10 00 	movl   $0x106718,(%esp)
  100d24:	e8 a1 f5 ff ff       	call   1002ca <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100d29:	c7 04 24 40 67 10 00 	movl   $0x106740,(%esp)
  100d30:	e8 95 f5 ff ff       	call   1002ca <cprintf>

    if (tf != NULL) {
  100d35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d39:	74 0b                	je     100d46 <kmonitor+0x33>
        print_trapframe(tf);
  100d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  100d3e:	89 04 24             	mov    %eax,(%esp)
  100d41:	e8 3a 0e 00 00       	call   101b80 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100d46:	c7 04 24 65 67 10 00 	movl   $0x106765,(%esp)
  100d4d:	e8 2b f6 ff ff       	call   10037d <readline>
  100d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d59:	74 eb                	je     100d46 <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
  100d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  100d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d65:	89 04 24             	mov    %eax,(%esp)
  100d68:	e8 ed fe ff ff       	call   100c5a <runcmd>
  100d6d:	85 c0                	test   %eax,%eax
  100d6f:	78 02                	js     100d73 <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
  100d71:	eb d3                	jmp    100d46 <kmonitor+0x33>
                break;
  100d73:	90                   	nop
            }
        }
    }
}
  100d74:	90                   	nop
  100d75:	c9                   	leave  
  100d76:	c3                   	ret    

00100d77 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d77:	f3 0f 1e fb          	endbr32 
  100d7b:	55                   	push   %ebp
  100d7c:	89 e5                	mov    %esp,%ebp
  100d7e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d88:	eb 3d                	jmp    100dc7 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d8d:	89 d0                	mov    %edx,%eax
  100d8f:	01 c0                	add    %eax,%eax
  100d91:	01 d0                	add    %edx,%eax
  100d93:	c1 e0 02             	shl    $0x2,%eax
  100d96:	05 04 a0 11 00       	add    $0x11a004,%eax
  100d9b:	8b 08                	mov    (%eax),%ecx
  100d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100da0:	89 d0                	mov    %edx,%eax
  100da2:	01 c0                	add    %eax,%eax
  100da4:	01 d0                	add    %edx,%eax
  100da6:	c1 e0 02             	shl    $0x2,%eax
  100da9:	05 00 a0 11 00       	add    $0x11a000,%eax
  100dae:	8b 00                	mov    (%eax),%eax
  100db0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100db4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100db8:	c7 04 24 69 67 10 00 	movl   $0x106769,(%esp)
  100dbf:	e8 06 f5 ff ff       	call   1002ca <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100dc4:	ff 45 f4             	incl   -0xc(%ebp)
  100dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100dca:	83 f8 02             	cmp    $0x2,%eax
  100dcd:	76 bb                	jbe    100d8a <mon_help+0x13>
    }
    return 0;
  100dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dd4:	c9                   	leave  
  100dd5:	c3                   	ret    

00100dd6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100dd6:	f3 0f 1e fb          	endbr32 
  100dda:	55                   	push   %ebp
  100ddb:	89 e5                	mov    %esp,%ebp
  100ddd:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100de0:	e8 a8 fb ff ff       	call   10098d <print_kerninfo>
    return 0;
  100de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dea:	c9                   	leave  
  100deb:	c3                   	ret    

00100dec <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100dec:	f3 0f 1e fb          	endbr32 
  100df0:	55                   	push   %ebp
  100df1:	89 e5                	mov    %esp,%ebp
  100df3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100df6:	e8 e4 fc ff ff       	call   100adf <print_stackframe>
    return 0;
  100dfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e00:	c9                   	leave  
  100e01:	c3                   	ret    

00100e02 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100e02:	f3 0f 1e fb          	endbr32 
  100e06:	55                   	push   %ebp
  100e07:	89 e5                	mov    %esp,%ebp
  100e09:	83 ec 28             	sub    $0x28,%esp
  100e0c:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100e12:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100e1e:	ee                   	out    %al,(%dx)
}
  100e1f:	90                   	nop
  100e20:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100e26:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e2a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e2e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e32:	ee                   	out    %al,(%dx)
}
  100e33:	90                   	nop
  100e34:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e3a:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e3e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e42:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e46:	ee                   	out    %al,(%dx)
}
  100e47:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e48:	c7 05 0c df 11 00 00 	movl   $0x0,0x11df0c
  100e4f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e52:	c7 04 24 72 67 10 00 	movl   $0x106772,(%esp)
  100e59:	e8 6c f4 ff ff       	call   1002ca <cprintf>
    pic_enable(IRQ_TIMER);
  100e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e65:	e8 95 09 00 00       	call   1017ff <pic_enable>
}
  100e6a:	90                   	nop
  100e6b:	c9                   	leave  
  100e6c:	c3                   	ret    

00100e6d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e6d:	55                   	push   %ebp
  100e6e:	89 e5                	mov    %esp,%ebp
  100e70:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e73:	9c                   	pushf  
  100e74:	58                   	pop    %eax
  100e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e7b:	25 00 02 00 00       	and    $0x200,%eax
  100e80:	85 c0                	test   %eax,%eax
  100e82:	74 0c                	je     100e90 <__intr_save+0x23>
        intr_disable();
  100e84:	e8 05 0b 00 00       	call   10198e <intr_disable>
        return 1;
  100e89:	b8 01 00 00 00       	mov    $0x1,%eax
  100e8e:	eb 05                	jmp    100e95 <__intr_save+0x28>
    }
    return 0;
  100e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e95:	c9                   	leave  
  100e96:	c3                   	ret    

00100e97 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e97:	55                   	push   %ebp
  100e98:	89 e5                	mov    %esp,%ebp
  100e9a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100ea1:	74 05                	je     100ea8 <__intr_restore+0x11>
        intr_enable();
  100ea3:	e8 da 0a 00 00       	call   101982 <intr_enable>
    }
}
  100ea8:	90                   	nop
  100ea9:	c9                   	leave  
  100eaa:	c3                   	ret    

00100eab <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100eab:	f3 0f 1e fb          	endbr32 
  100eaf:	55                   	push   %ebp
  100eb0:	89 e5                	mov    %esp,%ebp
  100eb2:	83 ec 10             	sub    $0x10,%esp
  100eb5:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ebb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ebf:	89 c2                	mov    %eax,%edx
  100ec1:	ec                   	in     (%dx),%al
  100ec2:	88 45 f1             	mov    %al,-0xf(%ebp)
  100ec5:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100ecb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100ecf:	89 c2                	mov    %eax,%edx
  100ed1:	ec                   	in     (%dx),%al
  100ed2:	88 45 f5             	mov    %al,-0xb(%ebp)
  100ed5:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100edb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100edf:	89 c2                	mov    %eax,%edx
  100ee1:	ec                   	in     (%dx),%al
  100ee2:	88 45 f9             	mov    %al,-0x7(%ebp)
  100ee5:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100eeb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100eef:	89 c2                	mov    %eax,%edx
  100ef1:	ec                   	in     (%dx),%al
  100ef2:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100ef5:	90                   	nop
  100ef6:	c9                   	leave  
  100ef7:	c3                   	ret    

00100ef8 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100ef8:	f3 0f 1e fb          	endbr32 
  100efc:	55                   	push   %ebp
  100efd:	89 e5                	mov    %esp,%ebp
  100eff:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100f02:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100f09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f0c:	0f b7 00             	movzwl (%eax),%eax
  100f0f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100f13:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f16:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100f1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f1e:	0f b7 00             	movzwl (%eax),%eax
  100f21:	0f b7 c0             	movzwl %ax,%eax
  100f24:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100f29:	74 12                	je     100f3d <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100f2b:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100f32:	66 c7 05 46 d4 11 00 	movw   $0x3b4,0x11d446
  100f39:	b4 03 
  100f3b:	eb 13                	jmp    100f50 <cga_init+0x58>
    } else {
        *cp = was;
  100f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f40:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100f44:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100f47:	66 c7 05 46 d4 11 00 	movw   $0x3d4,0x11d446
  100f4e:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100f50:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f57:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f5b:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f5f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f63:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f67:	ee                   	out    %al,(%dx)
}
  100f68:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f69:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f70:	40                   	inc    %eax
  100f71:	0f b7 c0             	movzwl %ax,%eax
  100f74:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f78:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f7c:	89 c2                	mov    %eax,%edx
  100f7e:	ec                   	in     (%dx),%al
  100f7f:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f82:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f86:	0f b6 c0             	movzbl %al,%eax
  100f89:	c1 e0 08             	shl    $0x8,%eax
  100f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f8f:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100f96:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f9a:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f9e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fa2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fa6:	ee                   	out    %al,(%dx)
}
  100fa7:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100fa8:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  100faf:	40                   	inc    %eax
  100fb0:	0f b7 c0             	movzwl %ax,%eax
  100fb3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fb7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fbb:	89 c2                	mov    %eax,%edx
  100fbd:	ec                   	in     (%dx),%al
  100fbe:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100fc1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100fc5:	0f b6 c0             	movzbl %al,%eax
  100fc8:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100fce:	a3 40 d4 11 00       	mov    %eax,0x11d440
    crt_pos = pos;
  100fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100fd6:	0f b7 c0             	movzwl %ax,%eax
  100fd9:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
}
  100fdf:	90                   	nop
  100fe0:	c9                   	leave  
  100fe1:	c3                   	ret    

00100fe2 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100fe2:	f3 0f 1e fb          	endbr32 
  100fe6:	55                   	push   %ebp
  100fe7:	89 e5                	mov    %esp,%ebp
  100fe9:	83 ec 48             	sub    $0x48,%esp
  100fec:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100ff2:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ff6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100ffa:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100ffe:	ee                   	out    %al,(%dx)
}
  100fff:	90                   	nop
  101000:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  101006:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10100a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10100e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101012:	ee                   	out    %al,(%dx)
}
  101013:	90                   	nop
  101014:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  10101a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10101e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101022:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101026:	ee                   	out    %al,(%dx)
}
  101027:	90                   	nop
  101028:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  10102e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101032:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101036:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  10103a:	ee                   	out    %al,(%dx)
}
  10103b:	90                   	nop
  10103c:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  101042:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101046:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10104a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10104e:	ee                   	out    %al,(%dx)
}
  10104f:	90                   	nop
  101050:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  101056:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10105a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10105e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101062:	ee                   	out    %al,(%dx)
}
  101063:	90                   	nop
  101064:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  10106a:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10106e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101072:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101076:	ee                   	out    %al,(%dx)
}
  101077:	90                   	nop
  101078:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10107e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101082:	89 c2                	mov    %eax,%edx
  101084:	ec                   	in     (%dx),%al
  101085:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101088:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10108c:	3c ff                	cmp    $0xff,%al
  10108e:	0f 95 c0             	setne  %al
  101091:	0f b6 c0             	movzbl %al,%eax
  101094:	a3 48 d4 11 00       	mov    %eax,0x11d448
  101099:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10109f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1010a3:	89 c2                	mov    %eax,%edx
  1010a5:	ec                   	in     (%dx),%al
  1010a6:	88 45 f1             	mov    %al,-0xf(%ebp)
  1010a9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1010af:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1010b3:	89 c2                	mov    %eax,%edx
  1010b5:	ec                   	in     (%dx),%al
  1010b6:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  1010b9:	a1 48 d4 11 00       	mov    0x11d448,%eax
  1010be:	85 c0                	test   %eax,%eax
  1010c0:	74 0c                	je     1010ce <serial_init+0xec>
        pic_enable(IRQ_COM1);
  1010c2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1010c9:	e8 31 07 00 00       	call   1017ff <pic_enable>
    }
}
  1010ce:	90                   	nop
  1010cf:	c9                   	leave  
  1010d0:	c3                   	ret    

001010d1 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  1010d1:	f3 0f 1e fb          	endbr32 
  1010d5:	55                   	push   %ebp
  1010d6:	89 e5                	mov    %esp,%ebp
  1010d8:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1010e2:	eb 08                	jmp    1010ec <lpt_putc_sub+0x1b>
        delay();
  1010e4:	e8 c2 fd ff ff       	call   100eab <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010e9:	ff 45 fc             	incl   -0x4(%ebp)
  1010ec:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  1010f2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1010f6:	89 c2                	mov    %eax,%edx
  1010f8:	ec                   	in     (%dx),%al
  1010f9:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1010fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101100:	84 c0                	test   %al,%al
  101102:	78 09                	js     10110d <lpt_putc_sub+0x3c>
  101104:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10110b:	7e d7                	jle    1010e4 <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	0f b6 c0             	movzbl %al,%eax
  101113:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101119:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10111c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101120:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101124:	ee                   	out    %al,(%dx)
}
  101125:	90                   	nop
  101126:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  10112c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101130:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101134:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101138:	ee                   	out    %al,(%dx)
}
  101139:	90                   	nop
  10113a:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101140:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101144:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101148:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10114c:	ee                   	out    %al,(%dx)
}
  10114d:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10114e:	90                   	nop
  10114f:	c9                   	leave  
  101150:	c3                   	ret    

00101151 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101151:	f3 0f 1e fb          	endbr32 
  101155:	55                   	push   %ebp
  101156:	89 e5                	mov    %esp,%ebp
  101158:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10115b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10115f:	74 0d                	je     10116e <lpt_putc+0x1d>
        lpt_putc_sub(c);
  101161:	8b 45 08             	mov    0x8(%ebp),%eax
  101164:	89 04 24             	mov    %eax,(%esp)
  101167:	e8 65 ff ff ff       	call   1010d1 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10116c:	eb 24                	jmp    101192 <lpt_putc+0x41>
        lpt_putc_sub('\b');
  10116e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101175:	e8 57 ff ff ff       	call   1010d1 <lpt_putc_sub>
        lpt_putc_sub(' ');
  10117a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101181:	e8 4b ff ff ff       	call   1010d1 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101186:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10118d:	e8 3f ff ff ff       	call   1010d1 <lpt_putc_sub>
}
  101192:	90                   	nop
  101193:	c9                   	leave  
  101194:	c3                   	ret    

00101195 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101195:	f3 0f 1e fb          	endbr32 
  101199:	55                   	push   %ebp
  10119a:	89 e5                	mov    %esp,%ebp
  10119c:	53                   	push   %ebx
  10119d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1011a3:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011a8:	85 c0                	test   %eax,%eax
  1011aa:	75 07                	jne    1011b3 <cga_putc+0x1e>
        c |= 0x0700;
  1011ac:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1011b6:	0f b6 c0             	movzbl %al,%eax
  1011b9:	83 f8 0d             	cmp    $0xd,%eax
  1011bc:	74 72                	je     101230 <cga_putc+0x9b>
  1011be:	83 f8 0d             	cmp    $0xd,%eax
  1011c1:	0f 8f a3 00 00 00    	jg     10126a <cga_putc+0xd5>
  1011c7:	83 f8 08             	cmp    $0x8,%eax
  1011ca:	74 0a                	je     1011d6 <cga_putc+0x41>
  1011cc:	83 f8 0a             	cmp    $0xa,%eax
  1011cf:	74 4c                	je     10121d <cga_putc+0x88>
  1011d1:	e9 94 00 00 00       	jmp    10126a <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
  1011d6:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011dd:	85 c0                	test   %eax,%eax
  1011df:	0f 84 af 00 00 00    	je     101294 <cga_putc+0xff>
            crt_pos --;
  1011e5:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1011ec:	48                   	dec    %eax
  1011ed:	0f b7 c0             	movzwl %ax,%eax
  1011f0:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f9:	98                   	cwtl   
  1011fa:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011ff:	98                   	cwtl   
  101200:	83 c8 20             	or     $0x20,%eax
  101203:	98                   	cwtl   
  101204:	8b 15 40 d4 11 00    	mov    0x11d440,%edx
  10120a:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  101211:	01 c9                	add    %ecx,%ecx
  101213:	01 ca                	add    %ecx,%edx
  101215:	0f b7 c0             	movzwl %ax,%eax
  101218:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10121b:	eb 77                	jmp    101294 <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
  10121d:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101224:	83 c0 50             	add    $0x50,%eax
  101227:	0f b7 c0             	movzwl %ax,%eax
  10122a:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101230:	0f b7 1d 44 d4 11 00 	movzwl 0x11d444,%ebx
  101237:	0f b7 0d 44 d4 11 00 	movzwl 0x11d444,%ecx
  10123e:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101243:	89 c8                	mov    %ecx,%eax
  101245:	f7 e2                	mul    %edx
  101247:	c1 ea 06             	shr    $0x6,%edx
  10124a:	89 d0                	mov    %edx,%eax
  10124c:	c1 e0 02             	shl    $0x2,%eax
  10124f:	01 d0                	add    %edx,%eax
  101251:	c1 e0 04             	shl    $0x4,%eax
  101254:	29 c1                	sub    %eax,%ecx
  101256:	89 c8                	mov    %ecx,%eax
  101258:	0f b7 c0             	movzwl %ax,%eax
  10125b:	29 c3                	sub    %eax,%ebx
  10125d:	89 d8                	mov    %ebx,%eax
  10125f:	0f b7 c0             	movzwl %ax,%eax
  101262:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
        break;
  101268:	eb 2b                	jmp    101295 <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10126a:	8b 0d 40 d4 11 00    	mov    0x11d440,%ecx
  101270:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101277:	8d 50 01             	lea    0x1(%eax),%edx
  10127a:	0f b7 d2             	movzwl %dx,%edx
  10127d:	66 89 15 44 d4 11 00 	mov    %dx,0x11d444
  101284:	01 c0                	add    %eax,%eax
  101286:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101289:	8b 45 08             	mov    0x8(%ebp),%eax
  10128c:	0f b7 c0             	movzwl %ax,%eax
  10128f:	66 89 02             	mov    %ax,(%edx)
        break;
  101292:	eb 01                	jmp    101295 <cga_putc+0x100>
        break;
  101294:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101295:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  10129c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1012a1:	76 5d                	jbe    101300 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1012a3:	a1 40 d4 11 00       	mov    0x11d440,%eax
  1012a8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1012ae:	a1 40 d4 11 00       	mov    0x11d440,%eax
  1012b3:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1012ba:	00 
  1012bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  1012bf:	89 04 24             	mov    %eax,(%esp)
  1012c2:	e8 b2 49 00 00       	call   105c79 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012c7:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1012ce:	eb 14                	jmp    1012e4 <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
  1012d0:	a1 40 d4 11 00       	mov    0x11d440,%eax
  1012d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1012d8:	01 d2                	add    %edx,%edx
  1012da:	01 d0                	add    %edx,%eax
  1012dc:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012e1:	ff 45 f4             	incl   -0xc(%ebp)
  1012e4:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1012eb:	7e e3                	jle    1012d0 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
  1012ed:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  1012f4:	83 e8 50             	sub    $0x50,%eax
  1012f7:	0f b7 c0             	movzwl %ax,%eax
  1012fa:	66 a3 44 d4 11 00    	mov    %ax,0x11d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101300:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  101307:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  10130b:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10130f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101313:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101317:	ee                   	out    %al,(%dx)
}
  101318:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  101319:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101320:	c1 e8 08             	shr    $0x8,%eax
  101323:	0f b7 c0             	movzwl %ax,%eax
  101326:	0f b6 c0             	movzbl %al,%eax
  101329:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  101330:	42                   	inc    %edx
  101331:	0f b7 d2             	movzwl %dx,%edx
  101334:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101338:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10133b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10133f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101343:	ee                   	out    %al,(%dx)
}
  101344:	90                   	nop
    outb(addr_6845, 15);
  101345:	0f b7 05 46 d4 11 00 	movzwl 0x11d446,%eax
  10134c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  101350:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101354:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101358:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10135c:	ee                   	out    %al,(%dx)
}
  10135d:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  10135e:	0f b7 05 44 d4 11 00 	movzwl 0x11d444,%eax
  101365:	0f b6 c0             	movzbl %al,%eax
  101368:	0f b7 15 46 d4 11 00 	movzwl 0x11d446,%edx
  10136f:	42                   	inc    %edx
  101370:	0f b7 d2             	movzwl %dx,%edx
  101373:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101377:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10137a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10137e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101382:	ee                   	out    %al,(%dx)
}
  101383:	90                   	nop
}
  101384:	90                   	nop
  101385:	83 c4 34             	add    $0x34,%esp
  101388:	5b                   	pop    %ebx
  101389:	5d                   	pop    %ebp
  10138a:	c3                   	ret    

0010138b <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10138b:	f3 0f 1e fb          	endbr32 
  10138f:	55                   	push   %ebp
  101390:	89 e5                	mov    %esp,%ebp
  101392:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101395:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10139c:	eb 08                	jmp    1013a6 <serial_putc_sub+0x1b>
        delay();
  10139e:	e8 08 fb ff ff       	call   100eab <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1013a3:	ff 45 fc             	incl   -0x4(%ebp)
  1013a6:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013ac:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013b0:	89 c2                	mov    %eax,%edx
  1013b2:	ec                   	in     (%dx),%al
  1013b3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013b6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1013ba:	0f b6 c0             	movzbl %al,%eax
  1013bd:	83 e0 20             	and    $0x20,%eax
  1013c0:	85 c0                	test   %eax,%eax
  1013c2:	75 09                	jne    1013cd <serial_putc_sub+0x42>
  1013c4:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1013cb:	7e d1                	jle    10139e <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
  1013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1013d0:	0f b6 c0             	movzbl %al,%eax
  1013d3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1013d9:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1013dc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1013e0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1013e4:	ee                   	out    %al,(%dx)
}
  1013e5:	90                   	nop
}
  1013e6:	90                   	nop
  1013e7:	c9                   	leave  
  1013e8:	c3                   	ret    

001013e9 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1013e9:	f3 0f 1e fb          	endbr32 
  1013ed:	55                   	push   %ebp
  1013ee:	89 e5                	mov    %esp,%ebp
  1013f0:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1013f3:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1013f7:	74 0d                	je     101406 <serial_putc+0x1d>
        serial_putc_sub(c);
  1013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1013fc:	89 04 24             	mov    %eax,(%esp)
  1013ff:	e8 87 ff ff ff       	call   10138b <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101404:	eb 24                	jmp    10142a <serial_putc+0x41>
        serial_putc_sub('\b');
  101406:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10140d:	e8 79 ff ff ff       	call   10138b <serial_putc_sub>
        serial_putc_sub(' ');
  101412:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101419:	e8 6d ff ff ff       	call   10138b <serial_putc_sub>
        serial_putc_sub('\b');
  10141e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101425:	e8 61 ff ff ff       	call   10138b <serial_putc_sub>
}
  10142a:	90                   	nop
  10142b:	c9                   	leave  
  10142c:	c3                   	ret    

0010142d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10142d:	f3 0f 1e fb          	endbr32 
  101431:	55                   	push   %ebp
  101432:	89 e5                	mov    %esp,%ebp
  101434:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101437:	eb 33                	jmp    10146c <cons_intr+0x3f>
        if (c != 0) {
  101439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10143d:	74 2d                	je     10146c <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
  10143f:	a1 64 d6 11 00       	mov    0x11d664,%eax
  101444:	8d 50 01             	lea    0x1(%eax),%edx
  101447:	89 15 64 d6 11 00    	mov    %edx,0x11d664
  10144d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101450:	88 90 60 d4 11 00    	mov    %dl,0x11d460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101456:	a1 64 d6 11 00       	mov    0x11d664,%eax
  10145b:	3d 00 02 00 00       	cmp    $0x200,%eax
  101460:	75 0a                	jne    10146c <cons_intr+0x3f>
                cons.wpos = 0;
  101462:	c7 05 64 d6 11 00 00 	movl   $0x0,0x11d664
  101469:	00 00 00 
    while ((c = (*proc)()) != -1) {
  10146c:	8b 45 08             	mov    0x8(%ebp),%eax
  10146f:	ff d0                	call   *%eax
  101471:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101474:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101478:	75 bf                	jne    101439 <cons_intr+0xc>
            }
        }
    }
}
  10147a:	90                   	nop
  10147b:	90                   	nop
  10147c:	c9                   	leave  
  10147d:	c3                   	ret    

0010147e <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10147e:	f3 0f 1e fb          	endbr32 
  101482:	55                   	push   %ebp
  101483:	89 e5                	mov    %esp,%ebp
  101485:	83 ec 10             	sub    $0x10,%esp
  101488:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10148e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101492:	89 c2                	mov    %eax,%edx
  101494:	ec                   	in     (%dx),%al
  101495:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101498:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10149c:	0f b6 c0             	movzbl %al,%eax
  10149f:	83 e0 01             	and    $0x1,%eax
  1014a2:	85 c0                	test   %eax,%eax
  1014a4:	75 07                	jne    1014ad <serial_proc_data+0x2f>
        return -1;
  1014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014ab:	eb 2a                	jmp    1014d7 <serial_proc_data+0x59>
  1014ad:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014b3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1014b7:	89 c2                	mov    %eax,%edx
  1014b9:	ec                   	in     (%dx),%al
  1014ba:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1014bd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1014c1:	0f b6 c0             	movzbl %al,%eax
  1014c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1014c7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1014cb:	75 07                	jne    1014d4 <serial_proc_data+0x56>
        c = '\b';
  1014cd:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1014d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1014d7:	c9                   	leave  
  1014d8:	c3                   	ret    

001014d9 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1014d9:	f3 0f 1e fb          	endbr32 
  1014dd:	55                   	push   %ebp
  1014de:	89 e5                	mov    %esp,%ebp
  1014e0:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1014e3:	a1 48 d4 11 00       	mov    0x11d448,%eax
  1014e8:	85 c0                	test   %eax,%eax
  1014ea:	74 0c                	je     1014f8 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  1014ec:	c7 04 24 7e 14 10 00 	movl   $0x10147e,(%esp)
  1014f3:	e8 35 ff ff ff       	call   10142d <cons_intr>
    }
}
  1014f8:	90                   	nop
  1014f9:	c9                   	leave  
  1014fa:	c3                   	ret    

001014fb <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1014fb:	f3 0f 1e fb          	endbr32 
  1014ff:	55                   	push   %ebp
  101500:	89 e5                	mov    %esp,%ebp
  101502:	83 ec 38             	sub    $0x38,%esp
  101505:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10150e:	89 c2                	mov    %eax,%edx
  101510:	ec                   	in     (%dx),%al
  101511:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  101514:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101518:	0f b6 c0             	movzbl %al,%eax
  10151b:	83 e0 01             	and    $0x1,%eax
  10151e:	85 c0                	test   %eax,%eax
  101520:	75 0a                	jne    10152c <kbd_proc_data+0x31>
        return -1;
  101522:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101527:	e9 56 01 00 00       	jmp    101682 <kbd_proc_data+0x187>
  10152c:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101532:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101535:	89 c2                	mov    %eax,%edx
  101537:	ec                   	in     (%dx),%al
  101538:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10153b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  10153f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101542:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101546:	75 17                	jne    10155f <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
  101548:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10154d:	83 c8 40             	or     $0x40,%eax
  101550:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  101555:	b8 00 00 00 00       	mov    $0x0,%eax
  10155a:	e9 23 01 00 00       	jmp    101682 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  10155f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101563:	84 c0                	test   %al,%al
  101565:	79 45                	jns    1015ac <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101567:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10156c:	83 e0 40             	and    $0x40,%eax
  10156f:	85 c0                	test   %eax,%eax
  101571:	75 08                	jne    10157b <kbd_proc_data+0x80>
  101573:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101577:	24 7f                	and    $0x7f,%al
  101579:	eb 04                	jmp    10157f <kbd_proc_data+0x84>
  10157b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10157f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101582:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101586:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  10158d:	0c 40                	or     $0x40,%al
  10158f:	0f b6 c0             	movzbl %al,%eax
  101592:	f7 d0                	not    %eax
  101594:	89 c2                	mov    %eax,%edx
  101596:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10159b:	21 d0                	and    %edx,%eax
  10159d:	a3 68 d6 11 00       	mov    %eax,0x11d668
        return 0;
  1015a2:	b8 00 00 00 00       	mov    $0x0,%eax
  1015a7:	e9 d6 00 00 00       	jmp    101682 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1015ac:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1015b1:	83 e0 40             	and    $0x40,%eax
  1015b4:	85 c0                	test   %eax,%eax
  1015b6:	74 11                	je     1015c9 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1015b8:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1015bc:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1015c1:	83 e0 bf             	and    $0xffffffbf,%eax
  1015c4:	a3 68 d6 11 00       	mov    %eax,0x11d668
    }

    shift |= shiftcode[data];
  1015c9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015cd:	0f b6 80 40 a0 11 00 	movzbl 0x11a040(%eax),%eax
  1015d4:	0f b6 d0             	movzbl %al,%edx
  1015d7:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1015dc:	09 d0                	or     %edx,%eax
  1015de:	a3 68 d6 11 00       	mov    %eax,0x11d668
    shift ^= togglecode[data];
  1015e3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015e7:	0f b6 80 40 a1 11 00 	movzbl 0x11a140(%eax),%eax
  1015ee:	0f b6 d0             	movzbl %al,%edx
  1015f1:	a1 68 d6 11 00       	mov    0x11d668,%eax
  1015f6:	31 d0                	xor    %edx,%eax
  1015f8:	a3 68 d6 11 00       	mov    %eax,0x11d668

    c = charcode[shift & (CTL | SHIFT)][data];
  1015fd:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101602:	83 e0 03             	and    $0x3,%eax
  101605:	8b 14 85 40 a5 11 00 	mov    0x11a540(,%eax,4),%edx
  10160c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101610:	01 d0                	add    %edx,%eax
  101612:	0f b6 00             	movzbl (%eax),%eax
  101615:	0f b6 c0             	movzbl %al,%eax
  101618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  10161b:	a1 68 d6 11 00       	mov    0x11d668,%eax
  101620:	83 e0 08             	and    $0x8,%eax
  101623:	85 c0                	test   %eax,%eax
  101625:	74 22                	je     101649 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101627:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  10162b:	7e 0c                	jle    101639 <kbd_proc_data+0x13e>
  10162d:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101631:	7f 06                	jg     101639 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101633:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101637:	eb 10                	jmp    101649 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101639:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10163d:	7e 0a                	jle    101649 <kbd_proc_data+0x14e>
  10163f:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101643:	7f 04                	jg     101649 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  101645:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101649:	a1 68 d6 11 00       	mov    0x11d668,%eax
  10164e:	f7 d0                	not    %eax
  101650:	83 e0 06             	and    $0x6,%eax
  101653:	85 c0                	test   %eax,%eax
  101655:	75 28                	jne    10167f <kbd_proc_data+0x184>
  101657:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10165e:	75 1f                	jne    10167f <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101660:	c7 04 24 8d 67 10 00 	movl   $0x10678d,(%esp)
  101667:	e8 5e ec ff ff       	call   1002ca <cprintf>
  10166c:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101672:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101676:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10167a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10167d:	ee                   	out    %al,(%dx)
}
  10167e:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101682:	c9                   	leave  
  101683:	c3                   	ret    

00101684 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101684:	f3 0f 1e fb          	endbr32 
  101688:	55                   	push   %ebp
  101689:	89 e5                	mov    %esp,%ebp
  10168b:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10168e:	c7 04 24 fb 14 10 00 	movl   $0x1014fb,(%esp)
  101695:	e8 93 fd ff ff       	call   10142d <cons_intr>
}
  10169a:	90                   	nop
  10169b:	c9                   	leave  
  10169c:	c3                   	ret    

0010169d <kbd_init>:

static void
kbd_init(void) {
  10169d:	f3 0f 1e fb          	endbr32 
  1016a1:	55                   	push   %ebp
  1016a2:	89 e5                	mov    %esp,%ebp
  1016a4:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1016a7:	e8 d8 ff ff ff       	call   101684 <kbd_intr>
    pic_enable(IRQ_KBD);
  1016ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1016b3:	e8 47 01 00 00       	call   1017ff <pic_enable>
}
  1016b8:	90                   	nop
  1016b9:	c9                   	leave  
  1016ba:	c3                   	ret    

001016bb <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1016bb:	f3 0f 1e fb          	endbr32 
  1016bf:	55                   	push   %ebp
  1016c0:	89 e5                	mov    %esp,%ebp
  1016c2:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1016c5:	e8 2e f8 ff ff       	call   100ef8 <cga_init>
    serial_init();
  1016ca:	e8 13 f9 ff ff       	call   100fe2 <serial_init>
    kbd_init();
  1016cf:	e8 c9 ff ff ff       	call   10169d <kbd_init>
    if (!serial_exists) {
  1016d4:	a1 48 d4 11 00       	mov    0x11d448,%eax
  1016d9:	85 c0                	test   %eax,%eax
  1016db:	75 0c                	jne    1016e9 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  1016dd:	c7 04 24 99 67 10 00 	movl   $0x106799,(%esp)
  1016e4:	e8 e1 eb ff ff       	call   1002ca <cprintf>
    }
}
  1016e9:	90                   	nop
  1016ea:	c9                   	leave  
  1016eb:	c3                   	ret    

001016ec <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1016ec:	f3 0f 1e fb          	endbr32 
  1016f0:	55                   	push   %ebp
  1016f1:	89 e5                	mov    %esp,%ebp
  1016f3:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  1016f6:	e8 72 f7 ff ff       	call   100e6d <__intr_save>
  1016fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  1016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  101701:	89 04 24             	mov    %eax,(%esp)
  101704:	e8 48 fa ff ff       	call   101151 <lpt_putc>
        cga_putc(c);
  101709:	8b 45 08             	mov    0x8(%ebp),%eax
  10170c:	89 04 24             	mov    %eax,(%esp)
  10170f:	e8 81 fa ff ff       	call   101195 <cga_putc>
        serial_putc(c);
  101714:	8b 45 08             	mov    0x8(%ebp),%eax
  101717:	89 04 24             	mov    %eax,(%esp)
  10171a:	e8 ca fc ff ff       	call   1013e9 <serial_putc>
    }
    local_intr_restore(intr_flag);
  10171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101722:	89 04 24             	mov    %eax,(%esp)
  101725:	e8 6d f7 ff ff       	call   100e97 <__intr_restore>
}
  10172a:	90                   	nop
  10172b:	c9                   	leave  
  10172c:	c3                   	ret    

0010172d <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10172d:	f3 0f 1e fb          	endbr32 
  101731:	55                   	push   %ebp
  101732:	89 e5                	mov    %esp,%ebp
  101734:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10173e:	e8 2a f7 ff ff       	call   100e6d <__intr_save>
  101743:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101746:	e8 8e fd ff ff       	call   1014d9 <serial_intr>
        kbd_intr();
  10174b:	e8 34 ff ff ff       	call   101684 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101750:	8b 15 60 d6 11 00    	mov    0x11d660,%edx
  101756:	a1 64 d6 11 00       	mov    0x11d664,%eax
  10175b:	39 c2                	cmp    %eax,%edx
  10175d:	74 31                	je     101790 <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
  10175f:	a1 60 d6 11 00       	mov    0x11d660,%eax
  101764:	8d 50 01             	lea    0x1(%eax),%edx
  101767:	89 15 60 d6 11 00    	mov    %edx,0x11d660
  10176d:	0f b6 80 60 d4 11 00 	movzbl 0x11d460(%eax),%eax
  101774:	0f b6 c0             	movzbl %al,%eax
  101777:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  10177a:	a1 60 d6 11 00       	mov    0x11d660,%eax
  10177f:	3d 00 02 00 00       	cmp    $0x200,%eax
  101784:	75 0a                	jne    101790 <cons_getc+0x63>
                cons.rpos = 0;
  101786:	c7 05 60 d6 11 00 00 	movl   $0x0,0x11d660
  10178d:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  101790:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101793:	89 04 24             	mov    %eax,(%esp)
  101796:	e8 fc f6 ff ff       	call   100e97 <__intr_restore>
    return c;
  10179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10179e:	c9                   	leave  
  10179f:	c3                   	ret    

001017a0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1017a0:	f3 0f 1e fb          	endbr32 
  1017a4:	55                   	push   %ebp
  1017a5:	89 e5                	mov    %esp,%ebp
  1017a7:	83 ec 14             	sub    $0x14,%esp
  1017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1017ad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1017b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1017b4:	66 a3 50 a5 11 00    	mov    %ax,0x11a550
    if (did_init) {
  1017ba:	a1 6c d6 11 00       	mov    0x11d66c,%eax
  1017bf:	85 c0                	test   %eax,%eax
  1017c1:	74 39                	je     1017fc <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
  1017c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1017c6:	0f b6 c0             	movzbl %al,%eax
  1017c9:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1017cf:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017d2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017d6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017da:	ee                   	out    %al,(%dx)
}
  1017db:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  1017dc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1017e0:	c1 e8 08             	shr    $0x8,%eax
  1017e3:	0f b7 c0             	movzwl %ax,%eax
  1017e6:	0f b6 c0             	movzbl %al,%eax
  1017e9:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  1017ef:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017f2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1017f6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1017fa:	ee                   	out    %al,(%dx)
}
  1017fb:	90                   	nop
    }
}
  1017fc:	90                   	nop
  1017fd:	c9                   	leave  
  1017fe:	c3                   	ret    

001017ff <pic_enable>:

void
pic_enable(unsigned int irq) {
  1017ff:	f3 0f 1e fb          	endbr32 
  101803:	55                   	push   %ebp
  101804:	89 e5                	mov    %esp,%ebp
  101806:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101809:	8b 45 08             	mov    0x8(%ebp),%eax
  10180c:	ba 01 00 00 00       	mov    $0x1,%edx
  101811:	88 c1                	mov    %al,%cl
  101813:	d3 e2                	shl    %cl,%edx
  101815:	89 d0                	mov    %edx,%eax
  101817:	98                   	cwtl   
  101818:	f7 d0                	not    %eax
  10181a:	0f bf d0             	movswl %ax,%edx
  10181d:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  101824:	98                   	cwtl   
  101825:	21 d0                	and    %edx,%eax
  101827:	98                   	cwtl   
  101828:	0f b7 c0             	movzwl %ax,%eax
  10182b:	89 04 24             	mov    %eax,(%esp)
  10182e:	e8 6d ff ff ff       	call   1017a0 <pic_setmask>
}
  101833:	90                   	nop
  101834:	c9                   	leave  
  101835:	c3                   	ret    

00101836 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101836:	f3 0f 1e fb          	endbr32 
  10183a:	55                   	push   %ebp
  10183b:	89 e5                	mov    %esp,%ebp
  10183d:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  101840:	c7 05 6c d6 11 00 01 	movl   $0x1,0x11d66c
  101847:	00 00 00 
  10184a:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  101850:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101854:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101858:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  10185c:	ee                   	out    %al,(%dx)
}
  10185d:	90                   	nop
  10185e:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101864:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101868:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10186c:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101870:	ee                   	out    %al,(%dx)
}
  101871:	90                   	nop
  101872:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101878:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10187c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101880:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101884:	ee                   	out    %al,(%dx)
}
  101885:	90                   	nop
  101886:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  10188c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101890:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101894:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101898:	ee                   	out    %al,(%dx)
}
  101899:	90                   	nop
  10189a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1018a0:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018a4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1018a8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1018ac:	ee                   	out    %al,(%dx)
}
  1018ad:	90                   	nop
  1018ae:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1018b4:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018b8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1018bc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1018c0:	ee                   	out    %al,(%dx)
}
  1018c1:	90                   	nop
  1018c2:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1018c8:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018cc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1018d0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1018d4:	ee                   	out    %al,(%dx)
}
  1018d5:	90                   	nop
  1018d6:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1018dc:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018e0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1018e4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1018e8:	ee                   	out    %al,(%dx)
}
  1018e9:	90                   	nop
  1018ea:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1018f0:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018f4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1018f8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1018fc:	ee                   	out    %al,(%dx)
}
  1018fd:	90                   	nop
  1018fe:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101904:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101908:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10190c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101910:	ee                   	out    %al,(%dx)
}
  101911:	90                   	nop
  101912:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101918:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10191c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101920:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101924:	ee                   	out    %al,(%dx)
}
  101925:	90                   	nop
  101926:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10192c:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101930:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101934:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101938:	ee                   	out    %al,(%dx)
}
  101939:	90                   	nop
  10193a:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  101940:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101944:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101948:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10194c:	ee                   	out    %al,(%dx)
}
  10194d:	90                   	nop
  10194e:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  101954:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101958:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10195c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101960:	ee                   	out    %al,(%dx)
}
  101961:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101962:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  101969:	3d ff ff 00 00       	cmp    $0xffff,%eax
  10196e:	74 0f                	je     10197f <pic_init+0x149>
        pic_setmask(irq_mask);
  101970:	0f b7 05 50 a5 11 00 	movzwl 0x11a550,%eax
  101977:	89 04 24             	mov    %eax,(%esp)
  10197a:	e8 21 fe ff ff       	call   1017a0 <pic_setmask>
    }
}
  10197f:	90                   	nop
  101980:	c9                   	leave  
  101981:	c3                   	ret    

00101982 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101982:	f3 0f 1e fb          	endbr32 
  101986:	55                   	push   %ebp
  101987:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101989:	fb                   	sti    
}
  10198a:	90                   	nop
    sti();
}
  10198b:	90                   	nop
  10198c:	5d                   	pop    %ebp
  10198d:	c3                   	ret    

0010198e <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10198e:	f3 0f 1e fb          	endbr32 
  101992:	55                   	push   %ebp
  101993:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101995:	fa                   	cli    
}
  101996:	90                   	nop
    cli();
}
  101997:	90                   	nop
  101998:	5d                   	pop    %ebp
  101999:	c3                   	ret    

0010199a <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  10199a:	f3 0f 1e fb          	endbr32 
  10199e:	55                   	push   %ebp
  10199f:	89 e5                	mov    %esp,%ebp
  1019a1:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1019a4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1019ab:	00 
  1019ac:	c7 04 24 c0 67 10 00 	movl   $0x1067c0,(%esp)
  1019b3:	e8 12 e9 ff ff       	call   1002ca <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1019b8:	90                   	nop
  1019b9:	c9                   	leave  
  1019ba:	c3                   	ret    

001019bb <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1019bb:	f3 0f 1e fb          	endbr32 
  1019bf:	55                   	push   %ebp
  1019c0:	89 e5                	mov    %esp,%ebp
  1019c2:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1019c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1019cc:	e9 c4 00 00 00       	jmp    101a95 <idt_init+0xda>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1019d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d4:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  1019db:	0f b7 d0             	movzwl %ax,%edx
  1019de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e1:	66 89 14 c5 80 d6 11 	mov    %dx,0x11d680(,%eax,8)
  1019e8:	00 
  1019e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ec:	66 c7 04 c5 82 d6 11 	movw   $0x8,0x11d682(,%eax,8)
  1019f3:	00 08 00 
  1019f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019f9:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101a00:	00 
  101a01:	80 e2 e0             	and    $0xe0,%dl
  101a04:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101a0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a0e:	0f b6 14 c5 84 d6 11 	movzbl 0x11d684(,%eax,8),%edx
  101a15:	00 
  101a16:	80 e2 1f             	and    $0x1f,%dl
  101a19:	88 14 c5 84 d6 11 00 	mov    %dl,0x11d684(,%eax,8)
  101a20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a23:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101a2a:	00 
  101a2b:	80 e2 f0             	and    $0xf0,%dl
  101a2e:	80 ca 0e             	or     $0xe,%dl
  101a31:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a3b:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101a42:	00 
  101a43:	80 e2 ef             	and    $0xef,%dl
  101a46:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a50:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101a57:	00 
  101a58:	80 e2 9f             	and    $0x9f,%dl
  101a5b:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101a62:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a65:	0f b6 14 c5 85 d6 11 	movzbl 0x11d685(,%eax,8),%edx
  101a6c:	00 
  101a6d:	80 ca 80             	or     $0x80,%dl
  101a70:	88 14 c5 85 d6 11 00 	mov    %dl,0x11d685(,%eax,8)
  101a77:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a7a:	8b 04 85 e0 a5 11 00 	mov    0x11a5e0(,%eax,4),%eax
  101a81:	c1 e8 10             	shr    $0x10,%eax
  101a84:	0f b7 d0             	movzwl %ax,%edx
  101a87:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a8a:	66 89 14 c5 86 d6 11 	mov    %dx,0x11d686(,%eax,8)
  101a91:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101a92:	ff 45 fc             	incl   -0x4(%ebp)
  101a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a98:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a9d:	0f 86 2e ff ff ff    	jbe    1019d1 <idt_init+0x16>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101aa3:	a1 c4 a7 11 00       	mov    0x11a7c4,%eax
  101aa8:	0f b7 c0             	movzwl %ax,%eax
  101aab:	66 a3 48 da 11 00    	mov    %ax,0x11da48
  101ab1:	66 c7 05 4a da 11 00 	movw   $0x8,0x11da4a
  101ab8:	08 00 
  101aba:	0f b6 05 4c da 11 00 	movzbl 0x11da4c,%eax
  101ac1:	24 e0                	and    $0xe0,%al
  101ac3:	a2 4c da 11 00       	mov    %al,0x11da4c
  101ac8:	0f b6 05 4c da 11 00 	movzbl 0x11da4c,%eax
  101acf:	24 1f                	and    $0x1f,%al
  101ad1:	a2 4c da 11 00       	mov    %al,0x11da4c
  101ad6:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  101add:	24 f0                	and    $0xf0,%al
  101adf:	0c 0e                	or     $0xe,%al
  101ae1:	a2 4d da 11 00       	mov    %al,0x11da4d
  101ae6:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  101aed:	24 ef                	and    $0xef,%al
  101aef:	a2 4d da 11 00       	mov    %al,0x11da4d
  101af4:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  101afb:	0c 60                	or     $0x60,%al
  101afd:	a2 4d da 11 00       	mov    %al,0x11da4d
  101b02:	0f b6 05 4d da 11 00 	movzbl 0x11da4d,%eax
  101b09:	0c 80                	or     $0x80,%al
  101b0b:	a2 4d da 11 00       	mov    %al,0x11da4d
  101b10:	a1 c4 a7 11 00       	mov    0x11a7c4,%eax
  101b15:	c1 e8 10             	shr    $0x10,%eax
  101b18:	0f b7 c0             	movzwl %ax,%eax
  101b1b:	66 a3 4e da 11 00    	mov    %ax,0x11da4e
  101b21:	c7 45 f8 60 a5 11 00 	movl   $0x11a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b2b:	0f 01 18             	lidtl  (%eax)
}
  101b2e:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
  101b2f:	90                   	nop
  101b30:	c9                   	leave  
  101b31:	c3                   	ret    

00101b32 <trapname>:

static const char *
trapname(int trapno) {
  101b32:	f3 0f 1e fb          	endbr32 
  101b36:	55                   	push   %ebp
  101b37:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101b39:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3c:	83 f8 13             	cmp    $0x13,%eax
  101b3f:	77 0c                	ja     101b4d <trapname+0x1b>
        return excnames[trapno];
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	8b 04 85 20 6b 10 00 	mov    0x106b20(,%eax,4),%eax
  101b4b:	eb 18                	jmp    101b65 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101b4d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101b51:	7e 0d                	jle    101b60 <trapname+0x2e>
  101b53:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101b57:	7f 07                	jg     101b60 <trapname+0x2e>
        return "Hardware Interrupt";
  101b59:	b8 ca 67 10 00       	mov    $0x1067ca,%eax
  101b5e:	eb 05                	jmp    101b65 <trapname+0x33>
    }
    return "(unknown trap)";
  101b60:	b8 dd 67 10 00       	mov    $0x1067dd,%eax
}
  101b65:	5d                   	pop    %ebp
  101b66:	c3                   	ret    

00101b67 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b67:	f3 0f 1e fb          	endbr32 
  101b6b:	55                   	push   %ebp
  101b6c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  101b71:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b75:	83 f8 08             	cmp    $0x8,%eax
  101b78:	0f 94 c0             	sete   %al
  101b7b:	0f b6 c0             	movzbl %al,%eax
}
  101b7e:	5d                   	pop    %ebp
  101b7f:	c3                   	ret    

00101b80 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b80:	f3 0f 1e fb          	endbr32 
  101b84:	55                   	push   %ebp
  101b85:	89 e5                	mov    %esp,%ebp
  101b87:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b91:	c7 04 24 1e 68 10 00 	movl   $0x10681e,(%esp)
  101b98:	e8 2d e7 ff ff       	call   1002ca <cprintf>
    print_regs(&tf->tf_regs);
  101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba0:	89 04 24             	mov    %eax,(%esp)
  101ba3:	e8 8d 01 00 00       	call   101d35 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bab:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101baf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb3:	c7 04 24 2f 68 10 00 	movl   $0x10682f,(%esp)
  101bba:	e8 0b e7 ff ff       	call   1002ca <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 42 68 10 00 	movl   $0x106842,(%esp)
  101bd1:	e8 f4 e6 ff ff       	call   1002ca <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be1:	c7 04 24 55 68 10 00 	movl   $0x106855,(%esp)
  101be8:	e8 dd e6 ff ff       	call   1002ca <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101bed:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf8:	c7 04 24 68 68 10 00 	movl   $0x106868,(%esp)
  101bff:	e8 c6 e6 ff ff       	call   1002ca <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101c04:	8b 45 08             	mov    0x8(%ebp),%eax
  101c07:	8b 40 30             	mov    0x30(%eax),%eax
  101c0a:	89 04 24             	mov    %eax,(%esp)
  101c0d:	e8 20 ff ff ff       	call   101b32 <trapname>
  101c12:	8b 55 08             	mov    0x8(%ebp),%edx
  101c15:	8b 52 30             	mov    0x30(%edx),%edx
  101c18:	89 44 24 08          	mov    %eax,0x8(%esp)
  101c1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  101c20:	c7 04 24 7b 68 10 00 	movl   $0x10687b,(%esp)
  101c27:	e8 9e e6 ff ff       	call   1002ca <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2f:	8b 40 34             	mov    0x34(%eax),%eax
  101c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c36:	c7 04 24 8d 68 10 00 	movl   $0x10688d,(%esp)
  101c3d:	e8 88 e6 ff ff       	call   1002ca <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101c42:	8b 45 08             	mov    0x8(%ebp),%eax
  101c45:	8b 40 38             	mov    0x38(%eax),%eax
  101c48:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4c:	c7 04 24 9c 68 10 00 	movl   $0x10689c,(%esp)
  101c53:	e8 72 e6 ff ff       	call   1002ca <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101c58:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c63:	c7 04 24 ab 68 10 00 	movl   $0x1068ab,(%esp)
  101c6a:	e8 5b e6 ff ff       	call   1002ca <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c72:	8b 40 40             	mov    0x40(%eax),%eax
  101c75:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c79:	c7 04 24 be 68 10 00 	movl   $0x1068be,(%esp)
  101c80:	e8 45 e6 ff ff       	call   1002ca <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c8c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c93:	eb 3d                	jmp    101cd2 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c95:	8b 45 08             	mov    0x8(%ebp),%eax
  101c98:	8b 50 40             	mov    0x40(%eax),%edx
  101c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c9e:	21 d0                	and    %edx,%eax
  101ca0:	85 c0                	test   %eax,%eax
  101ca2:	74 28                	je     101ccc <print_trapframe+0x14c>
  101ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ca7:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101cae:	85 c0                	test   %eax,%eax
  101cb0:	74 1a                	je     101ccc <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
  101cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cb5:	8b 04 85 80 a5 11 00 	mov    0x11a580(,%eax,4),%eax
  101cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc0:	c7 04 24 cd 68 10 00 	movl   $0x1068cd,(%esp)
  101cc7:	e8 fe e5 ff ff       	call   1002ca <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ccc:	ff 45 f4             	incl   -0xc(%ebp)
  101ccf:	d1 65 f0             	shll   -0x10(%ebp)
  101cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cd5:	83 f8 17             	cmp    $0x17,%eax
  101cd8:	76 bb                	jbe    101c95 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101cda:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdd:	8b 40 40             	mov    0x40(%eax),%eax
  101ce0:	c1 e8 0c             	shr    $0xc,%eax
  101ce3:	83 e0 03             	and    $0x3,%eax
  101ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cea:	c7 04 24 d1 68 10 00 	movl   $0x1068d1,(%esp)
  101cf1:	e8 d4 e5 ff ff       	call   1002ca <cprintf>

    if (!trap_in_kernel(tf)) {
  101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf9:	89 04 24             	mov    %eax,(%esp)
  101cfc:	e8 66 fe ff ff       	call   101b67 <trap_in_kernel>
  101d01:	85 c0                	test   %eax,%eax
  101d03:	75 2d                	jne    101d32 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101d05:	8b 45 08             	mov    0x8(%ebp),%eax
  101d08:	8b 40 44             	mov    0x44(%eax),%eax
  101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0f:	c7 04 24 da 68 10 00 	movl   $0x1068da,(%esp)
  101d16:	e8 af e5 ff ff       	call   1002ca <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101d22:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d26:	c7 04 24 e9 68 10 00 	movl   $0x1068e9,(%esp)
  101d2d:	e8 98 e5 ff ff       	call   1002ca <cprintf>
    }
}
  101d32:	90                   	nop
  101d33:	c9                   	leave  
  101d34:	c3                   	ret    

00101d35 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101d35:	f3 0f 1e fb          	endbr32 
  101d39:	55                   	push   %ebp
  101d3a:	89 e5                	mov    %esp,%ebp
  101d3c:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d42:	8b 00                	mov    (%eax),%eax
  101d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d48:	c7 04 24 fc 68 10 00 	movl   $0x1068fc,(%esp)
  101d4f:	e8 76 e5 ff ff       	call   1002ca <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101d54:	8b 45 08             	mov    0x8(%ebp),%eax
  101d57:	8b 40 04             	mov    0x4(%eax),%eax
  101d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d5e:	c7 04 24 0b 69 10 00 	movl   $0x10690b,(%esp)
  101d65:	e8 60 e5 ff ff       	call   1002ca <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6d:	8b 40 08             	mov    0x8(%eax),%eax
  101d70:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d74:	c7 04 24 1a 69 10 00 	movl   $0x10691a,(%esp)
  101d7b:	e8 4a e5 ff ff       	call   1002ca <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d80:	8b 45 08             	mov    0x8(%ebp),%eax
  101d83:	8b 40 0c             	mov    0xc(%eax),%eax
  101d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d8a:	c7 04 24 29 69 10 00 	movl   $0x106929,(%esp)
  101d91:	e8 34 e5 ff ff       	call   1002ca <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d96:	8b 45 08             	mov    0x8(%ebp),%eax
  101d99:	8b 40 10             	mov    0x10(%eax),%eax
  101d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da0:	c7 04 24 38 69 10 00 	movl   $0x106938,(%esp)
  101da7:	e8 1e e5 ff ff       	call   1002ca <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101dac:	8b 45 08             	mov    0x8(%ebp),%eax
  101daf:	8b 40 14             	mov    0x14(%eax),%eax
  101db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101db6:	c7 04 24 47 69 10 00 	movl   $0x106947,(%esp)
  101dbd:	e8 08 e5 ff ff       	call   1002ca <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc5:	8b 40 18             	mov    0x18(%eax),%eax
  101dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dcc:	c7 04 24 56 69 10 00 	movl   $0x106956,(%esp)
  101dd3:	e8 f2 e4 ff ff       	call   1002ca <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  101ddb:	8b 40 1c             	mov    0x1c(%eax),%eax
  101dde:	89 44 24 04          	mov    %eax,0x4(%esp)
  101de2:	c7 04 24 65 69 10 00 	movl   $0x106965,(%esp)
  101de9:	e8 dc e4 ff ff       	call   1002ca <cprintf>
}
  101dee:	90                   	nop
  101def:	c9                   	leave  
  101df0:	c3                   	ret    

00101df1 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101df1:	f3 0f 1e fb          	endbr32 
  101df5:	55                   	push   %ebp
  101df6:	89 e5                	mov    %esp,%ebp
  101df8:	57                   	push   %edi
  101df9:	56                   	push   %esi
  101dfa:	53                   	push   %ebx
  101dfb:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  101e01:	8b 40 30             	mov    0x30(%eax),%eax
  101e04:	83 f8 79             	cmp    $0x79,%eax
  101e07:	0f 84 c6 01 00 00    	je     101fd3 <trap_dispatch+0x1e2>
  101e0d:	83 f8 79             	cmp    $0x79,%eax
  101e10:	0f 87 3a 02 00 00    	ja     102050 <trap_dispatch+0x25f>
  101e16:	83 f8 78             	cmp    $0x78,%eax
  101e19:	0f 84 d0 00 00 00    	je     101eef <trap_dispatch+0xfe>
  101e1f:	83 f8 78             	cmp    $0x78,%eax
  101e22:	0f 87 28 02 00 00    	ja     102050 <trap_dispatch+0x25f>
  101e28:	83 f8 2f             	cmp    $0x2f,%eax
  101e2b:	0f 87 1f 02 00 00    	ja     102050 <trap_dispatch+0x25f>
  101e31:	83 f8 2e             	cmp    $0x2e,%eax
  101e34:	0f 83 4b 02 00 00    	jae    102085 <trap_dispatch+0x294>
  101e3a:	83 f8 24             	cmp    $0x24,%eax
  101e3d:	74 5e                	je     101e9d <trap_dispatch+0xac>
  101e3f:	83 f8 24             	cmp    $0x24,%eax
  101e42:	0f 87 08 02 00 00    	ja     102050 <trap_dispatch+0x25f>
  101e48:	83 f8 20             	cmp    $0x20,%eax
  101e4b:	74 0a                	je     101e57 <trap_dispatch+0x66>
  101e4d:	83 f8 21             	cmp    $0x21,%eax
  101e50:	74 74                	je     101ec6 <trap_dispatch+0xd5>
  101e52:	e9 f9 01 00 00       	jmp    102050 <trap_dispatch+0x25f>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101e57:	a1 0c df 11 00       	mov    0x11df0c,%eax
  101e5c:	40                   	inc    %eax
  101e5d:	a3 0c df 11 00       	mov    %eax,0x11df0c
        if (ticks % TICK_NUM == 0) {
  101e62:	8b 0d 0c df 11 00    	mov    0x11df0c,%ecx
  101e68:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e6d:	89 c8                	mov    %ecx,%eax
  101e6f:	f7 e2                	mul    %edx
  101e71:	c1 ea 05             	shr    $0x5,%edx
  101e74:	89 d0                	mov    %edx,%eax
  101e76:	c1 e0 02             	shl    $0x2,%eax
  101e79:	01 d0                	add    %edx,%eax
  101e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e82:	01 d0                	add    %edx,%eax
  101e84:	c1 e0 02             	shl    $0x2,%eax
  101e87:	29 c1                	sub    %eax,%ecx
  101e89:	89 ca                	mov    %ecx,%edx
  101e8b:	85 d2                	test   %edx,%edx
  101e8d:	0f 85 f5 01 00 00    	jne    102088 <trap_dispatch+0x297>
            print_ticks();
  101e93:	e8 02 fb ff ff       	call   10199a <print_ticks>
        }
        break;
  101e98:	e9 eb 01 00 00       	jmp    102088 <trap_dispatch+0x297>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e9d:	e8 8b f8 ff ff       	call   10172d <cons_getc>
  101ea2:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ea5:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101ea9:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101ead:	89 54 24 08          	mov    %edx,0x8(%esp)
  101eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101eb5:	c7 04 24 74 69 10 00 	movl   $0x106974,(%esp)
  101ebc:	e8 09 e4 ff ff       	call   1002ca <cprintf>
        break;
  101ec1:	e9 c9 01 00 00       	jmp    10208f <trap_dispatch+0x29e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101ec6:	e8 62 f8 ff ff       	call   10172d <cons_getc>
  101ecb:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101ece:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101ed2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101ed6:	89 54 24 08          	mov    %edx,0x8(%esp)
  101eda:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ede:	c7 04 24 86 69 10 00 	movl   $0x106986,(%esp)
  101ee5:	e8 e0 e3 ff ff       	call   1002ca <cprintf>
        break;
  101eea:	e9 a0 01 00 00       	jmp    10208f <trap_dispatch+0x29e>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    	if (tf->tf_cs != USER_CS) {
  101eef:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ef6:	83 f8 1b             	cmp    $0x1b,%eax
  101ef9:	0f 84 8c 01 00 00    	je     10208b <trap_dispatch+0x29a>
            switchk2u = *tf;
  101eff:	8b 55 08             	mov    0x8(%ebp),%edx
  101f02:	b8 20 df 11 00       	mov    $0x11df20,%eax
  101f07:	bb 4c 00 00 00       	mov    $0x4c,%ebx
  101f0c:	89 c1                	mov    %eax,%ecx
  101f0e:	83 e1 01             	and    $0x1,%ecx
  101f11:	85 c9                	test   %ecx,%ecx
  101f13:	74 0c                	je     101f21 <trap_dispatch+0x130>
  101f15:	0f b6 0a             	movzbl (%edx),%ecx
  101f18:	88 08                	mov    %cl,(%eax)
  101f1a:	8d 40 01             	lea    0x1(%eax),%eax
  101f1d:	8d 52 01             	lea    0x1(%edx),%edx
  101f20:	4b                   	dec    %ebx
  101f21:	89 c1                	mov    %eax,%ecx
  101f23:	83 e1 02             	and    $0x2,%ecx
  101f26:	85 c9                	test   %ecx,%ecx
  101f28:	74 0f                	je     101f39 <trap_dispatch+0x148>
  101f2a:	0f b7 0a             	movzwl (%edx),%ecx
  101f2d:	66 89 08             	mov    %cx,(%eax)
  101f30:	8d 40 02             	lea    0x2(%eax),%eax
  101f33:	8d 52 02             	lea    0x2(%edx),%edx
  101f36:	83 eb 02             	sub    $0x2,%ebx
  101f39:	89 df                	mov    %ebx,%edi
  101f3b:	83 e7 fc             	and    $0xfffffffc,%edi
  101f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  101f43:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
  101f46:	89 34 08             	mov    %esi,(%eax,%ecx,1)
  101f49:	83 c1 04             	add    $0x4,%ecx
  101f4c:	39 f9                	cmp    %edi,%ecx
  101f4e:	72 f3                	jb     101f43 <trap_dispatch+0x152>
  101f50:	01 c8                	add    %ecx,%eax
  101f52:	01 ca                	add    %ecx,%edx
  101f54:	b9 00 00 00 00       	mov    $0x0,%ecx
  101f59:	89 de                	mov    %ebx,%esi
  101f5b:	83 e6 02             	and    $0x2,%esi
  101f5e:	85 f6                	test   %esi,%esi
  101f60:	74 0b                	je     101f6d <trap_dispatch+0x17c>
  101f62:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
  101f66:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
  101f6a:	83 c1 02             	add    $0x2,%ecx
  101f6d:	83 e3 01             	and    $0x1,%ebx
  101f70:	85 db                	test   %ebx,%ebx
  101f72:	74 07                	je     101f7b <trap_dispatch+0x18a>
  101f74:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
  101f78:	88 14 08             	mov    %dl,(%eax,%ecx,1)
            switchk2u.tf_cs = USER_CS;
  101f7b:	66 c7 05 5c df 11 00 	movw   $0x1b,0x11df5c
  101f82:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101f84:	66 c7 05 68 df 11 00 	movw   $0x23,0x11df68
  101f8b:	23 00 
  101f8d:	0f b7 05 68 df 11 00 	movzwl 0x11df68,%eax
  101f94:	66 a3 48 df 11 00    	mov    %ax,0x11df48
  101f9a:	0f b7 05 48 df 11 00 	movzwl 0x11df48,%eax
  101fa1:	66 a3 4c df 11 00    	mov    %ax,0x11df4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  101faa:	83 c0 44             	add    $0x44,%eax
  101fad:	a3 64 df 11 00       	mov    %eax,0x11df64
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101fb2:	a1 60 df 11 00       	mov    0x11df60,%eax
  101fb7:	0d 00 30 00 00       	or     $0x3000,%eax
  101fbc:	a3 60 df 11 00       	mov    %eax,0x11df60
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101fc4:	83 e8 04             	sub    $0x4,%eax
  101fc7:	ba 20 df 11 00       	mov    $0x11df20,%edx
  101fcc:	89 10                	mov    %edx,(%eax)
        }
        break;
  101fce:	e9 b8 00 00 00       	jmp    10208b <trap_dispatch+0x29a>
    case T_SWITCH_TOK:
    	if (tf->tf_cs != KERNEL_CS) {
  101fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101fd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101fda:	83 f8 08             	cmp    $0x8,%eax
  101fdd:	0f 84 ab 00 00 00    	je     10208e <trap_dispatch+0x29d>
            tf->tf_cs = KERNEL_CS;
  101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  101fe6:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101fec:	8b 45 08             	mov    0x8(%ebp),%eax
  101fef:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ff8:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  101fff:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  102003:	8b 45 08             	mov    0x8(%ebp),%eax
  102006:	8b 40 40             	mov    0x40(%eax),%eax
  102009:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  10200e:	89 c2                	mov    %eax,%edx
  102010:	8b 45 08             	mov    0x8(%ebp),%eax
  102013:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  102016:	8b 45 08             	mov    0x8(%ebp),%eax
  102019:	8b 40 44             	mov    0x44(%eax),%eax
  10201c:	83 e8 44             	sub    $0x44,%eax
  10201f:	a3 6c df 11 00       	mov    %eax,0x11df6c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  102024:	a1 6c df 11 00       	mov    0x11df6c,%eax
  102029:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  102030:	00 
  102031:	8b 55 08             	mov    0x8(%ebp),%edx
  102034:	89 54 24 04          	mov    %edx,0x4(%esp)
  102038:	89 04 24             	mov    %eax,(%esp)
  10203b:	e8 39 3c 00 00       	call   105c79 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  102040:	8b 15 6c df 11 00    	mov    0x11df6c,%edx
  102046:	8b 45 08             	mov    0x8(%ebp),%eax
  102049:	83 e8 04             	sub    $0x4,%eax
  10204c:	89 10                	mov    %edx,(%eax)
        }
        break;
  10204e:	eb 3e                	jmp    10208e <trap_dispatch+0x29d>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102050:	8b 45 08             	mov    0x8(%ebp),%eax
  102053:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102057:	83 e0 03             	and    $0x3,%eax
  10205a:	85 c0                	test   %eax,%eax
  10205c:	75 31                	jne    10208f <trap_dispatch+0x29e>
            print_trapframe(tf);
  10205e:	8b 45 08             	mov    0x8(%ebp),%eax
  102061:	89 04 24             	mov    %eax,(%esp)
  102064:	e8 17 fb ff ff       	call   101b80 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  102069:	c7 44 24 08 95 69 10 	movl   $0x106995,0x8(%esp)
  102070:	00 
  102071:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  102078:	00 
  102079:	c7 04 24 b1 69 10 00 	movl   $0x1069b1,(%esp)
  102080:	e8 b1 e3 ff ff       	call   100436 <__panic>
        break;
  102085:	90                   	nop
  102086:	eb 07                	jmp    10208f <trap_dispatch+0x29e>
        break;
  102088:	90                   	nop
  102089:	eb 04                	jmp    10208f <trap_dispatch+0x29e>
        break;
  10208b:	90                   	nop
  10208c:	eb 01                	jmp    10208f <trap_dispatch+0x29e>
        break;
  10208e:	90                   	nop
        }
    }
}
  10208f:	90                   	nop
  102090:	83 c4 2c             	add    $0x2c,%esp
  102093:	5b                   	pop    %ebx
  102094:	5e                   	pop    %esi
  102095:	5f                   	pop    %edi
  102096:	5d                   	pop    %ebp
  102097:	c3                   	ret    

00102098 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  102098:	f3 0f 1e fb          	endbr32 
  10209c:	55                   	push   %ebp
  10209d:	89 e5                	mov    %esp,%ebp
  10209f:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  1020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1020a5:	89 04 24             	mov    %eax,(%esp)
  1020a8:	e8 44 fd ff ff       	call   101df1 <trap_dispatch>
}
  1020ad:	90                   	nop
  1020ae:	c9                   	leave  
  1020af:	c3                   	ret    

001020b0 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $0
  1020b2:	6a 00                	push   $0x0
  jmp __alltraps
  1020b4:	e9 69 0a 00 00       	jmp    102b22 <__alltraps>

001020b9 <vector1>:
.globl vector1
vector1:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $1
  1020bb:	6a 01                	push   $0x1
  jmp __alltraps
  1020bd:	e9 60 0a 00 00       	jmp    102b22 <__alltraps>

001020c2 <vector2>:
.globl vector2
vector2:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $2
  1020c4:	6a 02                	push   $0x2
  jmp __alltraps
  1020c6:	e9 57 0a 00 00       	jmp    102b22 <__alltraps>

001020cb <vector3>:
.globl vector3
vector3:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $3
  1020cd:	6a 03                	push   $0x3
  jmp __alltraps
  1020cf:	e9 4e 0a 00 00       	jmp    102b22 <__alltraps>

001020d4 <vector4>:
.globl vector4
vector4:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $4
  1020d6:	6a 04                	push   $0x4
  jmp __alltraps
  1020d8:	e9 45 0a 00 00       	jmp    102b22 <__alltraps>

001020dd <vector5>:
.globl vector5
vector5:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $5
  1020df:	6a 05                	push   $0x5
  jmp __alltraps
  1020e1:	e9 3c 0a 00 00       	jmp    102b22 <__alltraps>

001020e6 <vector6>:
.globl vector6
vector6:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $6
  1020e8:	6a 06                	push   $0x6
  jmp __alltraps
  1020ea:	e9 33 0a 00 00       	jmp    102b22 <__alltraps>

001020ef <vector7>:
.globl vector7
vector7:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $7
  1020f1:	6a 07                	push   $0x7
  jmp __alltraps
  1020f3:	e9 2a 0a 00 00       	jmp    102b22 <__alltraps>

001020f8 <vector8>:
.globl vector8
vector8:
  pushl $8
  1020f8:	6a 08                	push   $0x8
  jmp __alltraps
  1020fa:	e9 23 0a 00 00       	jmp    102b22 <__alltraps>

001020ff <vector9>:
.globl vector9
vector9:
  pushl $0
  1020ff:	6a 00                	push   $0x0
  pushl $9
  102101:	6a 09                	push   $0x9
  jmp __alltraps
  102103:	e9 1a 0a 00 00       	jmp    102b22 <__alltraps>

00102108 <vector10>:
.globl vector10
vector10:
  pushl $10
  102108:	6a 0a                	push   $0xa
  jmp __alltraps
  10210a:	e9 13 0a 00 00       	jmp    102b22 <__alltraps>

0010210f <vector11>:
.globl vector11
vector11:
  pushl $11
  10210f:	6a 0b                	push   $0xb
  jmp __alltraps
  102111:	e9 0c 0a 00 00       	jmp    102b22 <__alltraps>

00102116 <vector12>:
.globl vector12
vector12:
  pushl $12
  102116:	6a 0c                	push   $0xc
  jmp __alltraps
  102118:	e9 05 0a 00 00       	jmp    102b22 <__alltraps>

0010211d <vector13>:
.globl vector13
vector13:
  pushl $13
  10211d:	6a 0d                	push   $0xd
  jmp __alltraps
  10211f:	e9 fe 09 00 00       	jmp    102b22 <__alltraps>

00102124 <vector14>:
.globl vector14
vector14:
  pushl $14
  102124:	6a 0e                	push   $0xe
  jmp __alltraps
  102126:	e9 f7 09 00 00       	jmp    102b22 <__alltraps>

0010212b <vector15>:
.globl vector15
vector15:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $15
  10212d:	6a 0f                	push   $0xf
  jmp __alltraps
  10212f:	e9 ee 09 00 00       	jmp    102b22 <__alltraps>

00102134 <vector16>:
.globl vector16
vector16:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $16
  102136:	6a 10                	push   $0x10
  jmp __alltraps
  102138:	e9 e5 09 00 00       	jmp    102b22 <__alltraps>

0010213d <vector17>:
.globl vector17
vector17:
  pushl $17
  10213d:	6a 11                	push   $0x11
  jmp __alltraps
  10213f:	e9 de 09 00 00       	jmp    102b22 <__alltraps>

00102144 <vector18>:
.globl vector18
vector18:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $18
  102146:	6a 12                	push   $0x12
  jmp __alltraps
  102148:	e9 d5 09 00 00       	jmp    102b22 <__alltraps>

0010214d <vector19>:
.globl vector19
vector19:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $19
  10214f:	6a 13                	push   $0x13
  jmp __alltraps
  102151:	e9 cc 09 00 00       	jmp    102b22 <__alltraps>

00102156 <vector20>:
.globl vector20
vector20:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $20
  102158:	6a 14                	push   $0x14
  jmp __alltraps
  10215a:	e9 c3 09 00 00       	jmp    102b22 <__alltraps>

0010215f <vector21>:
.globl vector21
vector21:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $21
  102161:	6a 15                	push   $0x15
  jmp __alltraps
  102163:	e9 ba 09 00 00       	jmp    102b22 <__alltraps>

00102168 <vector22>:
.globl vector22
vector22:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $22
  10216a:	6a 16                	push   $0x16
  jmp __alltraps
  10216c:	e9 b1 09 00 00       	jmp    102b22 <__alltraps>

00102171 <vector23>:
.globl vector23
vector23:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $23
  102173:	6a 17                	push   $0x17
  jmp __alltraps
  102175:	e9 a8 09 00 00       	jmp    102b22 <__alltraps>

0010217a <vector24>:
.globl vector24
vector24:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $24
  10217c:	6a 18                	push   $0x18
  jmp __alltraps
  10217e:	e9 9f 09 00 00       	jmp    102b22 <__alltraps>

00102183 <vector25>:
.globl vector25
vector25:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $25
  102185:	6a 19                	push   $0x19
  jmp __alltraps
  102187:	e9 96 09 00 00       	jmp    102b22 <__alltraps>

0010218c <vector26>:
.globl vector26
vector26:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $26
  10218e:	6a 1a                	push   $0x1a
  jmp __alltraps
  102190:	e9 8d 09 00 00       	jmp    102b22 <__alltraps>

00102195 <vector27>:
.globl vector27
vector27:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $27
  102197:	6a 1b                	push   $0x1b
  jmp __alltraps
  102199:	e9 84 09 00 00       	jmp    102b22 <__alltraps>

0010219e <vector28>:
.globl vector28
vector28:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $28
  1021a0:	6a 1c                	push   $0x1c
  jmp __alltraps
  1021a2:	e9 7b 09 00 00       	jmp    102b22 <__alltraps>

001021a7 <vector29>:
.globl vector29
vector29:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $29
  1021a9:	6a 1d                	push   $0x1d
  jmp __alltraps
  1021ab:	e9 72 09 00 00       	jmp    102b22 <__alltraps>

001021b0 <vector30>:
.globl vector30
vector30:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $30
  1021b2:	6a 1e                	push   $0x1e
  jmp __alltraps
  1021b4:	e9 69 09 00 00       	jmp    102b22 <__alltraps>

001021b9 <vector31>:
.globl vector31
vector31:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $31
  1021bb:	6a 1f                	push   $0x1f
  jmp __alltraps
  1021bd:	e9 60 09 00 00       	jmp    102b22 <__alltraps>

001021c2 <vector32>:
.globl vector32
vector32:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $32
  1021c4:	6a 20                	push   $0x20
  jmp __alltraps
  1021c6:	e9 57 09 00 00       	jmp    102b22 <__alltraps>

001021cb <vector33>:
.globl vector33
vector33:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $33
  1021cd:	6a 21                	push   $0x21
  jmp __alltraps
  1021cf:	e9 4e 09 00 00       	jmp    102b22 <__alltraps>

001021d4 <vector34>:
.globl vector34
vector34:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $34
  1021d6:	6a 22                	push   $0x22
  jmp __alltraps
  1021d8:	e9 45 09 00 00       	jmp    102b22 <__alltraps>

001021dd <vector35>:
.globl vector35
vector35:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $35
  1021df:	6a 23                	push   $0x23
  jmp __alltraps
  1021e1:	e9 3c 09 00 00       	jmp    102b22 <__alltraps>

001021e6 <vector36>:
.globl vector36
vector36:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $36
  1021e8:	6a 24                	push   $0x24
  jmp __alltraps
  1021ea:	e9 33 09 00 00       	jmp    102b22 <__alltraps>

001021ef <vector37>:
.globl vector37
vector37:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $37
  1021f1:	6a 25                	push   $0x25
  jmp __alltraps
  1021f3:	e9 2a 09 00 00       	jmp    102b22 <__alltraps>

001021f8 <vector38>:
.globl vector38
vector38:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $38
  1021fa:	6a 26                	push   $0x26
  jmp __alltraps
  1021fc:	e9 21 09 00 00       	jmp    102b22 <__alltraps>

00102201 <vector39>:
.globl vector39
vector39:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $39
  102203:	6a 27                	push   $0x27
  jmp __alltraps
  102205:	e9 18 09 00 00       	jmp    102b22 <__alltraps>

0010220a <vector40>:
.globl vector40
vector40:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $40
  10220c:	6a 28                	push   $0x28
  jmp __alltraps
  10220e:	e9 0f 09 00 00       	jmp    102b22 <__alltraps>

00102213 <vector41>:
.globl vector41
vector41:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $41
  102215:	6a 29                	push   $0x29
  jmp __alltraps
  102217:	e9 06 09 00 00       	jmp    102b22 <__alltraps>

0010221c <vector42>:
.globl vector42
vector42:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $42
  10221e:	6a 2a                	push   $0x2a
  jmp __alltraps
  102220:	e9 fd 08 00 00       	jmp    102b22 <__alltraps>

00102225 <vector43>:
.globl vector43
vector43:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $43
  102227:	6a 2b                	push   $0x2b
  jmp __alltraps
  102229:	e9 f4 08 00 00       	jmp    102b22 <__alltraps>

0010222e <vector44>:
.globl vector44
vector44:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $44
  102230:	6a 2c                	push   $0x2c
  jmp __alltraps
  102232:	e9 eb 08 00 00       	jmp    102b22 <__alltraps>

00102237 <vector45>:
.globl vector45
vector45:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $45
  102239:	6a 2d                	push   $0x2d
  jmp __alltraps
  10223b:	e9 e2 08 00 00       	jmp    102b22 <__alltraps>

00102240 <vector46>:
.globl vector46
vector46:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $46
  102242:	6a 2e                	push   $0x2e
  jmp __alltraps
  102244:	e9 d9 08 00 00       	jmp    102b22 <__alltraps>

00102249 <vector47>:
.globl vector47
vector47:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $47
  10224b:	6a 2f                	push   $0x2f
  jmp __alltraps
  10224d:	e9 d0 08 00 00       	jmp    102b22 <__alltraps>

00102252 <vector48>:
.globl vector48
vector48:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $48
  102254:	6a 30                	push   $0x30
  jmp __alltraps
  102256:	e9 c7 08 00 00       	jmp    102b22 <__alltraps>

0010225b <vector49>:
.globl vector49
vector49:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $49
  10225d:	6a 31                	push   $0x31
  jmp __alltraps
  10225f:	e9 be 08 00 00       	jmp    102b22 <__alltraps>

00102264 <vector50>:
.globl vector50
vector50:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $50
  102266:	6a 32                	push   $0x32
  jmp __alltraps
  102268:	e9 b5 08 00 00       	jmp    102b22 <__alltraps>

0010226d <vector51>:
.globl vector51
vector51:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $51
  10226f:	6a 33                	push   $0x33
  jmp __alltraps
  102271:	e9 ac 08 00 00       	jmp    102b22 <__alltraps>

00102276 <vector52>:
.globl vector52
vector52:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $52
  102278:	6a 34                	push   $0x34
  jmp __alltraps
  10227a:	e9 a3 08 00 00       	jmp    102b22 <__alltraps>

0010227f <vector53>:
.globl vector53
vector53:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $53
  102281:	6a 35                	push   $0x35
  jmp __alltraps
  102283:	e9 9a 08 00 00       	jmp    102b22 <__alltraps>

00102288 <vector54>:
.globl vector54
vector54:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $54
  10228a:	6a 36                	push   $0x36
  jmp __alltraps
  10228c:	e9 91 08 00 00       	jmp    102b22 <__alltraps>

00102291 <vector55>:
.globl vector55
vector55:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $55
  102293:	6a 37                	push   $0x37
  jmp __alltraps
  102295:	e9 88 08 00 00       	jmp    102b22 <__alltraps>

0010229a <vector56>:
.globl vector56
vector56:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $56
  10229c:	6a 38                	push   $0x38
  jmp __alltraps
  10229e:	e9 7f 08 00 00       	jmp    102b22 <__alltraps>

001022a3 <vector57>:
.globl vector57
vector57:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $57
  1022a5:	6a 39                	push   $0x39
  jmp __alltraps
  1022a7:	e9 76 08 00 00       	jmp    102b22 <__alltraps>

001022ac <vector58>:
.globl vector58
vector58:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $58
  1022ae:	6a 3a                	push   $0x3a
  jmp __alltraps
  1022b0:	e9 6d 08 00 00       	jmp    102b22 <__alltraps>

001022b5 <vector59>:
.globl vector59
vector59:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $59
  1022b7:	6a 3b                	push   $0x3b
  jmp __alltraps
  1022b9:	e9 64 08 00 00       	jmp    102b22 <__alltraps>

001022be <vector60>:
.globl vector60
vector60:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $60
  1022c0:	6a 3c                	push   $0x3c
  jmp __alltraps
  1022c2:	e9 5b 08 00 00       	jmp    102b22 <__alltraps>

001022c7 <vector61>:
.globl vector61
vector61:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $61
  1022c9:	6a 3d                	push   $0x3d
  jmp __alltraps
  1022cb:	e9 52 08 00 00       	jmp    102b22 <__alltraps>

001022d0 <vector62>:
.globl vector62
vector62:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $62
  1022d2:	6a 3e                	push   $0x3e
  jmp __alltraps
  1022d4:	e9 49 08 00 00       	jmp    102b22 <__alltraps>

001022d9 <vector63>:
.globl vector63
vector63:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $63
  1022db:	6a 3f                	push   $0x3f
  jmp __alltraps
  1022dd:	e9 40 08 00 00       	jmp    102b22 <__alltraps>

001022e2 <vector64>:
.globl vector64
vector64:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $64
  1022e4:	6a 40                	push   $0x40
  jmp __alltraps
  1022e6:	e9 37 08 00 00       	jmp    102b22 <__alltraps>

001022eb <vector65>:
.globl vector65
vector65:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $65
  1022ed:	6a 41                	push   $0x41
  jmp __alltraps
  1022ef:	e9 2e 08 00 00       	jmp    102b22 <__alltraps>

001022f4 <vector66>:
.globl vector66
vector66:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $66
  1022f6:	6a 42                	push   $0x42
  jmp __alltraps
  1022f8:	e9 25 08 00 00       	jmp    102b22 <__alltraps>

001022fd <vector67>:
.globl vector67
vector67:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $67
  1022ff:	6a 43                	push   $0x43
  jmp __alltraps
  102301:	e9 1c 08 00 00       	jmp    102b22 <__alltraps>

00102306 <vector68>:
.globl vector68
vector68:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $68
  102308:	6a 44                	push   $0x44
  jmp __alltraps
  10230a:	e9 13 08 00 00       	jmp    102b22 <__alltraps>

0010230f <vector69>:
.globl vector69
vector69:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $69
  102311:	6a 45                	push   $0x45
  jmp __alltraps
  102313:	e9 0a 08 00 00       	jmp    102b22 <__alltraps>

00102318 <vector70>:
.globl vector70
vector70:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $70
  10231a:	6a 46                	push   $0x46
  jmp __alltraps
  10231c:	e9 01 08 00 00       	jmp    102b22 <__alltraps>

00102321 <vector71>:
.globl vector71
vector71:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $71
  102323:	6a 47                	push   $0x47
  jmp __alltraps
  102325:	e9 f8 07 00 00       	jmp    102b22 <__alltraps>

0010232a <vector72>:
.globl vector72
vector72:
  pushl $0
  10232a:	6a 00                	push   $0x0
  pushl $72
  10232c:	6a 48                	push   $0x48
  jmp __alltraps
  10232e:	e9 ef 07 00 00       	jmp    102b22 <__alltraps>

00102333 <vector73>:
.globl vector73
vector73:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $73
  102335:	6a 49                	push   $0x49
  jmp __alltraps
  102337:	e9 e6 07 00 00       	jmp    102b22 <__alltraps>

0010233c <vector74>:
.globl vector74
vector74:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $74
  10233e:	6a 4a                	push   $0x4a
  jmp __alltraps
  102340:	e9 dd 07 00 00       	jmp    102b22 <__alltraps>

00102345 <vector75>:
.globl vector75
vector75:
  pushl $0
  102345:	6a 00                	push   $0x0
  pushl $75
  102347:	6a 4b                	push   $0x4b
  jmp __alltraps
  102349:	e9 d4 07 00 00       	jmp    102b22 <__alltraps>

0010234e <vector76>:
.globl vector76
vector76:
  pushl $0
  10234e:	6a 00                	push   $0x0
  pushl $76
  102350:	6a 4c                	push   $0x4c
  jmp __alltraps
  102352:	e9 cb 07 00 00       	jmp    102b22 <__alltraps>

00102357 <vector77>:
.globl vector77
vector77:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $77
  102359:	6a 4d                	push   $0x4d
  jmp __alltraps
  10235b:	e9 c2 07 00 00       	jmp    102b22 <__alltraps>

00102360 <vector78>:
.globl vector78
vector78:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $78
  102362:	6a 4e                	push   $0x4e
  jmp __alltraps
  102364:	e9 b9 07 00 00       	jmp    102b22 <__alltraps>

00102369 <vector79>:
.globl vector79
vector79:
  pushl $0
  102369:	6a 00                	push   $0x0
  pushl $79
  10236b:	6a 4f                	push   $0x4f
  jmp __alltraps
  10236d:	e9 b0 07 00 00       	jmp    102b22 <__alltraps>

00102372 <vector80>:
.globl vector80
vector80:
  pushl $0
  102372:	6a 00                	push   $0x0
  pushl $80
  102374:	6a 50                	push   $0x50
  jmp __alltraps
  102376:	e9 a7 07 00 00       	jmp    102b22 <__alltraps>

0010237b <vector81>:
.globl vector81
vector81:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $81
  10237d:	6a 51                	push   $0x51
  jmp __alltraps
  10237f:	e9 9e 07 00 00       	jmp    102b22 <__alltraps>

00102384 <vector82>:
.globl vector82
vector82:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $82
  102386:	6a 52                	push   $0x52
  jmp __alltraps
  102388:	e9 95 07 00 00       	jmp    102b22 <__alltraps>

0010238d <vector83>:
.globl vector83
vector83:
  pushl $0
  10238d:	6a 00                	push   $0x0
  pushl $83
  10238f:	6a 53                	push   $0x53
  jmp __alltraps
  102391:	e9 8c 07 00 00       	jmp    102b22 <__alltraps>

00102396 <vector84>:
.globl vector84
vector84:
  pushl $0
  102396:	6a 00                	push   $0x0
  pushl $84
  102398:	6a 54                	push   $0x54
  jmp __alltraps
  10239a:	e9 83 07 00 00       	jmp    102b22 <__alltraps>

0010239f <vector85>:
.globl vector85
vector85:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $85
  1023a1:	6a 55                	push   $0x55
  jmp __alltraps
  1023a3:	e9 7a 07 00 00       	jmp    102b22 <__alltraps>

001023a8 <vector86>:
.globl vector86
vector86:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $86
  1023aa:	6a 56                	push   $0x56
  jmp __alltraps
  1023ac:	e9 71 07 00 00       	jmp    102b22 <__alltraps>

001023b1 <vector87>:
.globl vector87
vector87:
  pushl $0
  1023b1:	6a 00                	push   $0x0
  pushl $87
  1023b3:	6a 57                	push   $0x57
  jmp __alltraps
  1023b5:	e9 68 07 00 00       	jmp    102b22 <__alltraps>

001023ba <vector88>:
.globl vector88
vector88:
  pushl $0
  1023ba:	6a 00                	push   $0x0
  pushl $88
  1023bc:	6a 58                	push   $0x58
  jmp __alltraps
  1023be:	e9 5f 07 00 00       	jmp    102b22 <__alltraps>

001023c3 <vector89>:
.globl vector89
vector89:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $89
  1023c5:	6a 59                	push   $0x59
  jmp __alltraps
  1023c7:	e9 56 07 00 00       	jmp    102b22 <__alltraps>

001023cc <vector90>:
.globl vector90
vector90:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $90
  1023ce:	6a 5a                	push   $0x5a
  jmp __alltraps
  1023d0:	e9 4d 07 00 00       	jmp    102b22 <__alltraps>

001023d5 <vector91>:
.globl vector91
vector91:
  pushl $0
  1023d5:	6a 00                	push   $0x0
  pushl $91
  1023d7:	6a 5b                	push   $0x5b
  jmp __alltraps
  1023d9:	e9 44 07 00 00       	jmp    102b22 <__alltraps>

001023de <vector92>:
.globl vector92
vector92:
  pushl $0
  1023de:	6a 00                	push   $0x0
  pushl $92
  1023e0:	6a 5c                	push   $0x5c
  jmp __alltraps
  1023e2:	e9 3b 07 00 00       	jmp    102b22 <__alltraps>

001023e7 <vector93>:
.globl vector93
vector93:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $93
  1023e9:	6a 5d                	push   $0x5d
  jmp __alltraps
  1023eb:	e9 32 07 00 00       	jmp    102b22 <__alltraps>

001023f0 <vector94>:
.globl vector94
vector94:
  pushl $0
  1023f0:	6a 00                	push   $0x0
  pushl $94
  1023f2:	6a 5e                	push   $0x5e
  jmp __alltraps
  1023f4:	e9 29 07 00 00       	jmp    102b22 <__alltraps>

001023f9 <vector95>:
.globl vector95
vector95:
  pushl $0
  1023f9:	6a 00                	push   $0x0
  pushl $95
  1023fb:	6a 5f                	push   $0x5f
  jmp __alltraps
  1023fd:	e9 20 07 00 00       	jmp    102b22 <__alltraps>

00102402 <vector96>:
.globl vector96
vector96:
  pushl $0
  102402:	6a 00                	push   $0x0
  pushl $96
  102404:	6a 60                	push   $0x60
  jmp __alltraps
  102406:	e9 17 07 00 00       	jmp    102b22 <__alltraps>

0010240b <vector97>:
.globl vector97
vector97:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $97
  10240d:	6a 61                	push   $0x61
  jmp __alltraps
  10240f:	e9 0e 07 00 00       	jmp    102b22 <__alltraps>

00102414 <vector98>:
.globl vector98
vector98:
  pushl $0
  102414:	6a 00                	push   $0x0
  pushl $98
  102416:	6a 62                	push   $0x62
  jmp __alltraps
  102418:	e9 05 07 00 00       	jmp    102b22 <__alltraps>

0010241d <vector99>:
.globl vector99
vector99:
  pushl $0
  10241d:	6a 00                	push   $0x0
  pushl $99
  10241f:	6a 63                	push   $0x63
  jmp __alltraps
  102421:	e9 fc 06 00 00       	jmp    102b22 <__alltraps>

00102426 <vector100>:
.globl vector100
vector100:
  pushl $0
  102426:	6a 00                	push   $0x0
  pushl $100
  102428:	6a 64                	push   $0x64
  jmp __alltraps
  10242a:	e9 f3 06 00 00       	jmp    102b22 <__alltraps>

0010242f <vector101>:
.globl vector101
vector101:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $101
  102431:	6a 65                	push   $0x65
  jmp __alltraps
  102433:	e9 ea 06 00 00       	jmp    102b22 <__alltraps>

00102438 <vector102>:
.globl vector102
vector102:
  pushl $0
  102438:	6a 00                	push   $0x0
  pushl $102
  10243a:	6a 66                	push   $0x66
  jmp __alltraps
  10243c:	e9 e1 06 00 00       	jmp    102b22 <__alltraps>

00102441 <vector103>:
.globl vector103
vector103:
  pushl $0
  102441:	6a 00                	push   $0x0
  pushl $103
  102443:	6a 67                	push   $0x67
  jmp __alltraps
  102445:	e9 d8 06 00 00       	jmp    102b22 <__alltraps>

0010244a <vector104>:
.globl vector104
vector104:
  pushl $0
  10244a:	6a 00                	push   $0x0
  pushl $104
  10244c:	6a 68                	push   $0x68
  jmp __alltraps
  10244e:	e9 cf 06 00 00       	jmp    102b22 <__alltraps>

00102453 <vector105>:
.globl vector105
vector105:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $105
  102455:	6a 69                	push   $0x69
  jmp __alltraps
  102457:	e9 c6 06 00 00       	jmp    102b22 <__alltraps>

0010245c <vector106>:
.globl vector106
vector106:
  pushl $0
  10245c:	6a 00                	push   $0x0
  pushl $106
  10245e:	6a 6a                	push   $0x6a
  jmp __alltraps
  102460:	e9 bd 06 00 00       	jmp    102b22 <__alltraps>

00102465 <vector107>:
.globl vector107
vector107:
  pushl $0
  102465:	6a 00                	push   $0x0
  pushl $107
  102467:	6a 6b                	push   $0x6b
  jmp __alltraps
  102469:	e9 b4 06 00 00       	jmp    102b22 <__alltraps>

0010246e <vector108>:
.globl vector108
vector108:
  pushl $0
  10246e:	6a 00                	push   $0x0
  pushl $108
  102470:	6a 6c                	push   $0x6c
  jmp __alltraps
  102472:	e9 ab 06 00 00       	jmp    102b22 <__alltraps>

00102477 <vector109>:
.globl vector109
vector109:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $109
  102479:	6a 6d                	push   $0x6d
  jmp __alltraps
  10247b:	e9 a2 06 00 00       	jmp    102b22 <__alltraps>

00102480 <vector110>:
.globl vector110
vector110:
  pushl $0
  102480:	6a 00                	push   $0x0
  pushl $110
  102482:	6a 6e                	push   $0x6e
  jmp __alltraps
  102484:	e9 99 06 00 00       	jmp    102b22 <__alltraps>

00102489 <vector111>:
.globl vector111
vector111:
  pushl $0
  102489:	6a 00                	push   $0x0
  pushl $111
  10248b:	6a 6f                	push   $0x6f
  jmp __alltraps
  10248d:	e9 90 06 00 00       	jmp    102b22 <__alltraps>

00102492 <vector112>:
.globl vector112
vector112:
  pushl $0
  102492:	6a 00                	push   $0x0
  pushl $112
  102494:	6a 70                	push   $0x70
  jmp __alltraps
  102496:	e9 87 06 00 00       	jmp    102b22 <__alltraps>

0010249b <vector113>:
.globl vector113
vector113:
  pushl $0
  10249b:	6a 00                	push   $0x0
  pushl $113
  10249d:	6a 71                	push   $0x71
  jmp __alltraps
  10249f:	e9 7e 06 00 00       	jmp    102b22 <__alltraps>

001024a4 <vector114>:
.globl vector114
vector114:
  pushl $0
  1024a4:	6a 00                	push   $0x0
  pushl $114
  1024a6:	6a 72                	push   $0x72
  jmp __alltraps
  1024a8:	e9 75 06 00 00       	jmp    102b22 <__alltraps>

001024ad <vector115>:
.globl vector115
vector115:
  pushl $0
  1024ad:	6a 00                	push   $0x0
  pushl $115
  1024af:	6a 73                	push   $0x73
  jmp __alltraps
  1024b1:	e9 6c 06 00 00       	jmp    102b22 <__alltraps>

001024b6 <vector116>:
.globl vector116
vector116:
  pushl $0
  1024b6:	6a 00                	push   $0x0
  pushl $116
  1024b8:	6a 74                	push   $0x74
  jmp __alltraps
  1024ba:	e9 63 06 00 00       	jmp    102b22 <__alltraps>

001024bf <vector117>:
.globl vector117
vector117:
  pushl $0
  1024bf:	6a 00                	push   $0x0
  pushl $117
  1024c1:	6a 75                	push   $0x75
  jmp __alltraps
  1024c3:	e9 5a 06 00 00       	jmp    102b22 <__alltraps>

001024c8 <vector118>:
.globl vector118
vector118:
  pushl $0
  1024c8:	6a 00                	push   $0x0
  pushl $118
  1024ca:	6a 76                	push   $0x76
  jmp __alltraps
  1024cc:	e9 51 06 00 00       	jmp    102b22 <__alltraps>

001024d1 <vector119>:
.globl vector119
vector119:
  pushl $0
  1024d1:	6a 00                	push   $0x0
  pushl $119
  1024d3:	6a 77                	push   $0x77
  jmp __alltraps
  1024d5:	e9 48 06 00 00       	jmp    102b22 <__alltraps>

001024da <vector120>:
.globl vector120
vector120:
  pushl $0
  1024da:	6a 00                	push   $0x0
  pushl $120
  1024dc:	6a 78                	push   $0x78
  jmp __alltraps
  1024de:	e9 3f 06 00 00       	jmp    102b22 <__alltraps>

001024e3 <vector121>:
.globl vector121
vector121:
  pushl $0
  1024e3:	6a 00                	push   $0x0
  pushl $121
  1024e5:	6a 79                	push   $0x79
  jmp __alltraps
  1024e7:	e9 36 06 00 00       	jmp    102b22 <__alltraps>

001024ec <vector122>:
.globl vector122
vector122:
  pushl $0
  1024ec:	6a 00                	push   $0x0
  pushl $122
  1024ee:	6a 7a                	push   $0x7a
  jmp __alltraps
  1024f0:	e9 2d 06 00 00       	jmp    102b22 <__alltraps>

001024f5 <vector123>:
.globl vector123
vector123:
  pushl $0
  1024f5:	6a 00                	push   $0x0
  pushl $123
  1024f7:	6a 7b                	push   $0x7b
  jmp __alltraps
  1024f9:	e9 24 06 00 00       	jmp    102b22 <__alltraps>

001024fe <vector124>:
.globl vector124
vector124:
  pushl $0
  1024fe:	6a 00                	push   $0x0
  pushl $124
  102500:	6a 7c                	push   $0x7c
  jmp __alltraps
  102502:	e9 1b 06 00 00       	jmp    102b22 <__alltraps>

00102507 <vector125>:
.globl vector125
vector125:
  pushl $0
  102507:	6a 00                	push   $0x0
  pushl $125
  102509:	6a 7d                	push   $0x7d
  jmp __alltraps
  10250b:	e9 12 06 00 00       	jmp    102b22 <__alltraps>

00102510 <vector126>:
.globl vector126
vector126:
  pushl $0
  102510:	6a 00                	push   $0x0
  pushl $126
  102512:	6a 7e                	push   $0x7e
  jmp __alltraps
  102514:	e9 09 06 00 00       	jmp    102b22 <__alltraps>

00102519 <vector127>:
.globl vector127
vector127:
  pushl $0
  102519:	6a 00                	push   $0x0
  pushl $127
  10251b:	6a 7f                	push   $0x7f
  jmp __alltraps
  10251d:	e9 00 06 00 00       	jmp    102b22 <__alltraps>

00102522 <vector128>:
.globl vector128
vector128:
  pushl $0
  102522:	6a 00                	push   $0x0
  pushl $128
  102524:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102529:	e9 f4 05 00 00       	jmp    102b22 <__alltraps>

0010252e <vector129>:
.globl vector129
vector129:
  pushl $0
  10252e:	6a 00                	push   $0x0
  pushl $129
  102530:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102535:	e9 e8 05 00 00       	jmp    102b22 <__alltraps>

0010253a <vector130>:
.globl vector130
vector130:
  pushl $0
  10253a:	6a 00                	push   $0x0
  pushl $130
  10253c:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102541:	e9 dc 05 00 00       	jmp    102b22 <__alltraps>

00102546 <vector131>:
.globl vector131
vector131:
  pushl $0
  102546:	6a 00                	push   $0x0
  pushl $131
  102548:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10254d:	e9 d0 05 00 00       	jmp    102b22 <__alltraps>

00102552 <vector132>:
.globl vector132
vector132:
  pushl $0
  102552:	6a 00                	push   $0x0
  pushl $132
  102554:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102559:	e9 c4 05 00 00       	jmp    102b22 <__alltraps>

0010255e <vector133>:
.globl vector133
vector133:
  pushl $0
  10255e:	6a 00                	push   $0x0
  pushl $133
  102560:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102565:	e9 b8 05 00 00       	jmp    102b22 <__alltraps>

0010256a <vector134>:
.globl vector134
vector134:
  pushl $0
  10256a:	6a 00                	push   $0x0
  pushl $134
  10256c:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102571:	e9 ac 05 00 00       	jmp    102b22 <__alltraps>

00102576 <vector135>:
.globl vector135
vector135:
  pushl $0
  102576:	6a 00                	push   $0x0
  pushl $135
  102578:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10257d:	e9 a0 05 00 00       	jmp    102b22 <__alltraps>

00102582 <vector136>:
.globl vector136
vector136:
  pushl $0
  102582:	6a 00                	push   $0x0
  pushl $136
  102584:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102589:	e9 94 05 00 00       	jmp    102b22 <__alltraps>

0010258e <vector137>:
.globl vector137
vector137:
  pushl $0
  10258e:	6a 00                	push   $0x0
  pushl $137
  102590:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102595:	e9 88 05 00 00       	jmp    102b22 <__alltraps>

0010259a <vector138>:
.globl vector138
vector138:
  pushl $0
  10259a:	6a 00                	push   $0x0
  pushl $138
  10259c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1025a1:	e9 7c 05 00 00       	jmp    102b22 <__alltraps>

001025a6 <vector139>:
.globl vector139
vector139:
  pushl $0
  1025a6:	6a 00                	push   $0x0
  pushl $139
  1025a8:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1025ad:	e9 70 05 00 00       	jmp    102b22 <__alltraps>

001025b2 <vector140>:
.globl vector140
vector140:
  pushl $0
  1025b2:	6a 00                	push   $0x0
  pushl $140
  1025b4:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1025b9:	e9 64 05 00 00       	jmp    102b22 <__alltraps>

001025be <vector141>:
.globl vector141
vector141:
  pushl $0
  1025be:	6a 00                	push   $0x0
  pushl $141
  1025c0:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1025c5:	e9 58 05 00 00       	jmp    102b22 <__alltraps>

001025ca <vector142>:
.globl vector142
vector142:
  pushl $0
  1025ca:	6a 00                	push   $0x0
  pushl $142
  1025cc:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1025d1:	e9 4c 05 00 00       	jmp    102b22 <__alltraps>

001025d6 <vector143>:
.globl vector143
vector143:
  pushl $0
  1025d6:	6a 00                	push   $0x0
  pushl $143
  1025d8:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1025dd:	e9 40 05 00 00       	jmp    102b22 <__alltraps>

001025e2 <vector144>:
.globl vector144
vector144:
  pushl $0
  1025e2:	6a 00                	push   $0x0
  pushl $144
  1025e4:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1025e9:	e9 34 05 00 00       	jmp    102b22 <__alltraps>

001025ee <vector145>:
.globl vector145
vector145:
  pushl $0
  1025ee:	6a 00                	push   $0x0
  pushl $145
  1025f0:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1025f5:	e9 28 05 00 00       	jmp    102b22 <__alltraps>

001025fa <vector146>:
.globl vector146
vector146:
  pushl $0
  1025fa:	6a 00                	push   $0x0
  pushl $146
  1025fc:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102601:	e9 1c 05 00 00       	jmp    102b22 <__alltraps>

00102606 <vector147>:
.globl vector147
vector147:
  pushl $0
  102606:	6a 00                	push   $0x0
  pushl $147
  102608:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10260d:	e9 10 05 00 00       	jmp    102b22 <__alltraps>

00102612 <vector148>:
.globl vector148
vector148:
  pushl $0
  102612:	6a 00                	push   $0x0
  pushl $148
  102614:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102619:	e9 04 05 00 00       	jmp    102b22 <__alltraps>

0010261e <vector149>:
.globl vector149
vector149:
  pushl $0
  10261e:	6a 00                	push   $0x0
  pushl $149
  102620:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102625:	e9 f8 04 00 00       	jmp    102b22 <__alltraps>

0010262a <vector150>:
.globl vector150
vector150:
  pushl $0
  10262a:	6a 00                	push   $0x0
  pushl $150
  10262c:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102631:	e9 ec 04 00 00       	jmp    102b22 <__alltraps>

00102636 <vector151>:
.globl vector151
vector151:
  pushl $0
  102636:	6a 00                	push   $0x0
  pushl $151
  102638:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10263d:	e9 e0 04 00 00       	jmp    102b22 <__alltraps>

00102642 <vector152>:
.globl vector152
vector152:
  pushl $0
  102642:	6a 00                	push   $0x0
  pushl $152
  102644:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102649:	e9 d4 04 00 00       	jmp    102b22 <__alltraps>

0010264e <vector153>:
.globl vector153
vector153:
  pushl $0
  10264e:	6a 00                	push   $0x0
  pushl $153
  102650:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102655:	e9 c8 04 00 00       	jmp    102b22 <__alltraps>

0010265a <vector154>:
.globl vector154
vector154:
  pushl $0
  10265a:	6a 00                	push   $0x0
  pushl $154
  10265c:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102661:	e9 bc 04 00 00       	jmp    102b22 <__alltraps>

00102666 <vector155>:
.globl vector155
vector155:
  pushl $0
  102666:	6a 00                	push   $0x0
  pushl $155
  102668:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10266d:	e9 b0 04 00 00       	jmp    102b22 <__alltraps>

00102672 <vector156>:
.globl vector156
vector156:
  pushl $0
  102672:	6a 00                	push   $0x0
  pushl $156
  102674:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102679:	e9 a4 04 00 00       	jmp    102b22 <__alltraps>

0010267e <vector157>:
.globl vector157
vector157:
  pushl $0
  10267e:	6a 00                	push   $0x0
  pushl $157
  102680:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102685:	e9 98 04 00 00       	jmp    102b22 <__alltraps>

0010268a <vector158>:
.globl vector158
vector158:
  pushl $0
  10268a:	6a 00                	push   $0x0
  pushl $158
  10268c:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102691:	e9 8c 04 00 00       	jmp    102b22 <__alltraps>

00102696 <vector159>:
.globl vector159
vector159:
  pushl $0
  102696:	6a 00                	push   $0x0
  pushl $159
  102698:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10269d:	e9 80 04 00 00       	jmp    102b22 <__alltraps>

001026a2 <vector160>:
.globl vector160
vector160:
  pushl $0
  1026a2:	6a 00                	push   $0x0
  pushl $160
  1026a4:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1026a9:	e9 74 04 00 00       	jmp    102b22 <__alltraps>

001026ae <vector161>:
.globl vector161
vector161:
  pushl $0
  1026ae:	6a 00                	push   $0x0
  pushl $161
  1026b0:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1026b5:	e9 68 04 00 00       	jmp    102b22 <__alltraps>

001026ba <vector162>:
.globl vector162
vector162:
  pushl $0
  1026ba:	6a 00                	push   $0x0
  pushl $162
  1026bc:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1026c1:	e9 5c 04 00 00       	jmp    102b22 <__alltraps>

001026c6 <vector163>:
.globl vector163
vector163:
  pushl $0
  1026c6:	6a 00                	push   $0x0
  pushl $163
  1026c8:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1026cd:	e9 50 04 00 00       	jmp    102b22 <__alltraps>

001026d2 <vector164>:
.globl vector164
vector164:
  pushl $0
  1026d2:	6a 00                	push   $0x0
  pushl $164
  1026d4:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1026d9:	e9 44 04 00 00       	jmp    102b22 <__alltraps>

001026de <vector165>:
.globl vector165
vector165:
  pushl $0
  1026de:	6a 00                	push   $0x0
  pushl $165
  1026e0:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1026e5:	e9 38 04 00 00       	jmp    102b22 <__alltraps>

001026ea <vector166>:
.globl vector166
vector166:
  pushl $0
  1026ea:	6a 00                	push   $0x0
  pushl $166
  1026ec:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1026f1:	e9 2c 04 00 00       	jmp    102b22 <__alltraps>

001026f6 <vector167>:
.globl vector167
vector167:
  pushl $0
  1026f6:	6a 00                	push   $0x0
  pushl $167
  1026f8:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1026fd:	e9 20 04 00 00       	jmp    102b22 <__alltraps>

00102702 <vector168>:
.globl vector168
vector168:
  pushl $0
  102702:	6a 00                	push   $0x0
  pushl $168
  102704:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102709:	e9 14 04 00 00       	jmp    102b22 <__alltraps>

0010270e <vector169>:
.globl vector169
vector169:
  pushl $0
  10270e:	6a 00                	push   $0x0
  pushl $169
  102710:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102715:	e9 08 04 00 00       	jmp    102b22 <__alltraps>

0010271a <vector170>:
.globl vector170
vector170:
  pushl $0
  10271a:	6a 00                	push   $0x0
  pushl $170
  10271c:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102721:	e9 fc 03 00 00       	jmp    102b22 <__alltraps>

00102726 <vector171>:
.globl vector171
vector171:
  pushl $0
  102726:	6a 00                	push   $0x0
  pushl $171
  102728:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10272d:	e9 f0 03 00 00       	jmp    102b22 <__alltraps>

00102732 <vector172>:
.globl vector172
vector172:
  pushl $0
  102732:	6a 00                	push   $0x0
  pushl $172
  102734:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102739:	e9 e4 03 00 00       	jmp    102b22 <__alltraps>

0010273e <vector173>:
.globl vector173
vector173:
  pushl $0
  10273e:	6a 00                	push   $0x0
  pushl $173
  102740:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102745:	e9 d8 03 00 00       	jmp    102b22 <__alltraps>

0010274a <vector174>:
.globl vector174
vector174:
  pushl $0
  10274a:	6a 00                	push   $0x0
  pushl $174
  10274c:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102751:	e9 cc 03 00 00       	jmp    102b22 <__alltraps>

00102756 <vector175>:
.globl vector175
vector175:
  pushl $0
  102756:	6a 00                	push   $0x0
  pushl $175
  102758:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10275d:	e9 c0 03 00 00       	jmp    102b22 <__alltraps>

00102762 <vector176>:
.globl vector176
vector176:
  pushl $0
  102762:	6a 00                	push   $0x0
  pushl $176
  102764:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102769:	e9 b4 03 00 00       	jmp    102b22 <__alltraps>

0010276e <vector177>:
.globl vector177
vector177:
  pushl $0
  10276e:	6a 00                	push   $0x0
  pushl $177
  102770:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102775:	e9 a8 03 00 00       	jmp    102b22 <__alltraps>

0010277a <vector178>:
.globl vector178
vector178:
  pushl $0
  10277a:	6a 00                	push   $0x0
  pushl $178
  10277c:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102781:	e9 9c 03 00 00       	jmp    102b22 <__alltraps>

00102786 <vector179>:
.globl vector179
vector179:
  pushl $0
  102786:	6a 00                	push   $0x0
  pushl $179
  102788:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10278d:	e9 90 03 00 00       	jmp    102b22 <__alltraps>

00102792 <vector180>:
.globl vector180
vector180:
  pushl $0
  102792:	6a 00                	push   $0x0
  pushl $180
  102794:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102799:	e9 84 03 00 00       	jmp    102b22 <__alltraps>

0010279e <vector181>:
.globl vector181
vector181:
  pushl $0
  10279e:	6a 00                	push   $0x0
  pushl $181
  1027a0:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1027a5:	e9 78 03 00 00       	jmp    102b22 <__alltraps>

001027aa <vector182>:
.globl vector182
vector182:
  pushl $0
  1027aa:	6a 00                	push   $0x0
  pushl $182
  1027ac:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1027b1:	e9 6c 03 00 00       	jmp    102b22 <__alltraps>

001027b6 <vector183>:
.globl vector183
vector183:
  pushl $0
  1027b6:	6a 00                	push   $0x0
  pushl $183
  1027b8:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1027bd:	e9 60 03 00 00       	jmp    102b22 <__alltraps>

001027c2 <vector184>:
.globl vector184
vector184:
  pushl $0
  1027c2:	6a 00                	push   $0x0
  pushl $184
  1027c4:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1027c9:	e9 54 03 00 00       	jmp    102b22 <__alltraps>

001027ce <vector185>:
.globl vector185
vector185:
  pushl $0
  1027ce:	6a 00                	push   $0x0
  pushl $185
  1027d0:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1027d5:	e9 48 03 00 00       	jmp    102b22 <__alltraps>

001027da <vector186>:
.globl vector186
vector186:
  pushl $0
  1027da:	6a 00                	push   $0x0
  pushl $186
  1027dc:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1027e1:	e9 3c 03 00 00       	jmp    102b22 <__alltraps>

001027e6 <vector187>:
.globl vector187
vector187:
  pushl $0
  1027e6:	6a 00                	push   $0x0
  pushl $187
  1027e8:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1027ed:	e9 30 03 00 00       	jmp    102b22 <__alltraps>

001027f2 <vector188>:
.globl vector188
vector188:
  pushl $0
  1027f2:	6a 00                	push   $0x0
  pushl $188
  1027f4:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1027f9:	e9 24 03 00 00       	jmp    102b22 <__alltraps>

001027fe <vector189>:
.globl vector189
vector189:
  pushl $0
  1027fe:	6a 00                	push   $0x0
  pushl $189
  102800:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102805:	e9 18 03 00 00       	jmp    102b22 <__alltraps>

0010280a <vector190>:
.globl vector190
vector190:
  pushl $0
  10280a:	6a 00                	push   $0x0
  pushl $190
  10280c:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102811:	e9 0c 03 00 00       	jmp    102b22 <__alltraps>

00102816 <vector191>:
.globl vector191
vector191:
  pushl $0
  102816:	6a 00                	push   $0x0
  pushl $191
  102818:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10281d:	e9 00 03 00 00       	jmp    102b22 <__alltraps>

00102822 <vector192>:
.globl vector192
vector192:
  pushl $0
  102822:	6a 00                	push   $0x0
  pushl $192
  102824:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102829:	e9 f4 02 00 00       	jmp    102b22 <__alltraps>

0010282e <vector193>:
.globl vector193
vector193:
  pushl $0
  10282e:	6a 00                	push   $0x0
  pushl $193
  102830:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102835:	e9 e8 02 00 00       	jmp    102b22 <__alltraps>

0010283a <vector194>:
.globl vector194
vector194:
  pushl $0
  10283a:	6a 00                	push   $0x0
  pushl $194
  10283c:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102841:	e9 dc 02 00 00       	jmp    102b22 <__alltraps>

00102846 <vector195>:
.globl vector195
vector195:
  pushl $0
  102846:	6a 00                	push   $0x0
  pushl $195
  102848:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10284d:	e9 d0 02 00 00       	jmp    102b22 <__alltraps>

00102852 <vector196>:
.globl vector196
vector196:
  pushl $0
  102852:	6a 00                	push   $0x0
  pushl $196
  102854:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102859:	e9 c4 02 00 00       	jmp    102b22 <__alltraps>

0010285e <vector197>:
.globl vector197
vector197:
  pushl $0
  10285e:	6a 00                	push   $0x0
  pushl $197
  102860:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102865:	e9 b8 02 00 00       	jmp    102b22 <__alltraps>

0010286a <vector198>:
.globl vector198
vector198:
  pushl $0
  10286a:	6a 00                	push   $0x0
  pushl $198
  10286c:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102871:	e9 ac 02 00 00       	jmp    102b22 <__alltraps>

00102876 <vector199>:
.globl vector199
vector199:
  pushl $0
  102876:	6a 00                	push   $0x0
  pushl $199
  102878:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10287d:	e9 a0 02 00 00       	jmp    102b22 <__alltraps>

00102882 <vector200>:
.globl vector200
vector200:
  pushl $0
  102882:	6a 00                	push   $0x0
  pushl $200
  102884:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102889:	e9 94 02 00 00       	jmp    102b22 <__alltraps>

0010288e <vector201>:
.globl vector201
vector201:
  pushl $0
  10288e:	6a 00                	push   $0x0
  pushl $201
  102890:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102895:	e9 88 02 00 00       	jmp    102b22 <__alltraps>

0010289a <vector202>:
.globl vector202
vector202:
  pushl $0
  10289a:	6a 00                	push   $0x0
  pushl $202
  10289c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1028a1:	e9 7c 02 00 00       	jmp    102b22 <__alltraps>

001028a6 <vector203>:
.globl vector203
vector203:
  pushl $0
  1028a6:	6a 00                	push   $0x0
  pushl $203
  1028a8:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1028ad:	e9 70 02 00 00       	jmp    102b22 <__alltraps>

001028b2 <vector204>:
.globl vector204
vector204:
  pushl $0
  1028b2:	6a 00                	push   $0x0
  pushl $204
  1028b4:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1028b9:	e9 64 02 00 00       	jmp    102b22 <__alltraps>

001028be <vector205>:
.globl vector205
vector205:
  pushl $0
  1028be:	6a 00                	push   $0x0
  pushl $205
  1028c0:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1028c5:	e9 58 02 00 00       	jmp    102b22 <__alltraps>

001028ca <vector206>:
.globl vector206
vector206:
  pushl $0
  1028ca:	6a 00                	push   $0x0
  pushl $206
  1028cc:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1028d1:	e9 4c 02 00 00       	jmp    102b22 <__alltraps>

001028d6 <vector207>:
.globl vector207
vector207:
  pushl $0
  1028d6:	6a 00                	push   $0x0
  pushl $207
  1028d8:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1028dd:	e9 40 02 00 00       	jmp    102b22 <__alltraps>

001028e2 <vector208>:
.globl vector208
vector208:
  pushl $0
  1028e2:	6a 00                	push   $0x0
  pushl $208
  1028e4:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1028e9:	e9 34 02 00 00       	jmp    102b22 <__alltraps>

001028ee <vector209>:
.globl vector209
vector209:
  pushl $0
  1028ee:	6a 00                	push   $0x0
  pushl $209
  1028f0:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1028f5:	e9 28 02 00 00       	jmp    102b22 <__alltraps>

001028fa <vector210>:
.globl vector210
vector210:
  pushl $0
  1028fa:	6a 00                	push   $0x0
  pushl $210
  1028fc:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102901:	e9 1c 02 00 00       	jmp    102b22 <__alltraps>

00102906 <vector211>:
.globl vector211
vector211:
  pushl $0
  102906:	6a 00                	push   $0x0
  pushl $211
  102908:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10290d:	e9 10 02 00 00       	jmp    102b22 <__alltraps>

00102912 <vector212>:
.globl vector212
vector212:
  pushl $0
  102912:	6a 00                	push   $0x0
  pushl $212
  102914:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102919:	e9 04 02 00 00       	jmp    102b22 <__alltraps>

0010291e <vector213>:
.globl vector213
vector213:
  pushl $0
  10291e:	6a 00                	push   $0x0
  pushl $213
  102920:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102925:	e9 f8 01 00 00       	jmp    102b22 <__alltraps>

0010292a <vector214>:
.globl vector214
vector214:
  pushl $0
  10292a:	6a 00                	push   $0x0
  pushl $214
  10292c:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102931:	e9 ec 01 00 00       	jmp    102b22 <__alltraps>

00102936 <vector215>:
.globl vector215
vector215:
  pushl $0
  102936:	6a 00                	push   $0x0
  pushl $215
  102938:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10293d:	e9 e0 01 00 00       	jmp    102b22 <__alltraps>

00102942 <vector216>:
.globl vector216
vector216:
  pushl $0
  102942:	6a 00                	push   $0x0
  pushl $216
  102944:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102949:	e9 d4 01 00 00       	jmp    102b22 <__alltraps>

0010294e <vector217>:
.globl vector217
vector217:
  pushl $0
  10294e:	6a 00                	push   $0x0
  pushl $217
  102950:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102955:	e9 c8 01 00 00       	jmp    102b22 <__alltraps>

0010295a <vector218>:
.globl vector218
vector218:
  pushl $0
  10295a:	6a 00                	push   $0x0
  pushl $218
  10295c:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102961:	e9 bc 01 00 00       	jmp    102b22 <__alltraps>

00102966 <vector219>:
.globl vector219
vector219:
  pushl $0
  102966:	6a 00                	push   $0x0
  pushl $219
  102968:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10296d:	e9 b0 01 00 00       	jmp    102b22 <__alltraps>

00102972 <vector220>:
.globl vector220
vector220:
  pushl $0
  102972:	6a 00                	push   $0x0
  pushl $220
  102974:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102979:	e9 a4 01 00 00       	jmp    102b22 <__alltraps>

0010297e <vector221>:
.globl vector221
vector221:
  pushl $0
  10297e:	6a 00                	push   $0x0
  pushl $221
  102980:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102985:	e9 98 01 00 00       	jmp    102b22 <__alltraps>

0010298a <vector222>:
.globl vector222
vector222:
  pushl $0
  10298a:	6a 00                	push   $0x0
  pushl $222
  10298c:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102991:	e9 8c 01 00 00       	jmp    102b22 <__alltraps>

00102996 <vector223>:
.globl vector223
vector223:
  pushl $0
  102996:	6a 00                	push   $0x0
  pushl $223
  102998:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10299d:	e9 80 01 00 00       	jmp    102b22 <__alltraps>

001029a2 <vector224>:
.globl vector224
vector224:
  pushl $0
  1029a2:	6a 00                	push   $0x0
  pushl $224
  1029a4:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1029a9:	e9 74 01 00 00       	jmp    102b22 <__alltraps>

001029ae <vector225>:
.globl vector225
vector225:
  pushl $0
  1029ae:	6a 00                	push   $0x0
  pushl $225
  1029b0:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1029b5:	e9 68 01 00 00       	jmp    102b22 <__alltraps>

001029ba <vector226>:
.globl vector226
vector226:
  pushl $0
  1029ba:	6a 00                	push   $0x0
  pushl $226
  1029bc:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1029c1:	e9 5c 01 00 00       	jmp    102b22 <__alltraps>

001029c6 <vector227>:
.globl vector227
vector227:
  pushl $0
  1029c6:	6a 00                	push   $0x0
  pushl $227
  1029c8:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1029cd:	e9 50 01 00 00       	jmp    102b22 <__alltraps>

001029d2 <vector228>:
.globl vector228
vector228:
  pushl $0
  1029d2:	6a 00                	push   $0x0
  pushl $228
  1029d4:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1029d9:	e9 44 01 00 00       	jmp    102b22 <__alltraps>

001029de <vector229>:
.globl vector229
vector229:
  pushl $0
  1029de:	6a 00                	push   $0x0
  pushl $229
  1029e0:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1029e5:	e9 38 01 00 00       	jmp    102b22 <__alltraps>

001029ea <vector230>:
.globl vector230
vector230:
  pushl $0
  1029ea:	6a 00                	push   $0x0
  pushl $230
  1029ec:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1029f1:	e9 2c 01 00 00       	jmp    102b22 <__alltraps>

001029f6 <vector231>:
.globl vector231
vector231:
  pushl $0
  1029f6:	6a 00                	push   $0x0
  pushl $231
  1029f8:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1029fd:	e9 20 01 00 00       	jmp    102b22 <__alltraps>

00102a02 <vector232>:
.globl vector232
vector232:
  pushl $0
  102a02:	6a 00                	push   $0x0
  pushl $232
  102a04:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102a09:	e9 14 01 00 00       	jmp    102b22 <__alltraps>

00102a0e <vector233>:
.globl vector233
vector233:
  pushl $0
  102a0e:	6a 00                	push   $0x0
  pushl $233
  102a10:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102a15:	e9 08 01 00 00       	jmp    102b22 <__alltraps>

00102a1a <vector234>:
.globl vector234
vector234:
  pushl $0
  102a1a:	6a 00                	push   $0x0
  pushl $234
  102a1c:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102a21:	e9 fc 00 00 00       	jmp    102b22 <__alltraps>

00102a26 <vector235>:
.globl vector235
vector235:
  pushl $0
  102a26:	6a 00                	push   $0x0
  pushl $235
  102a28:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102a2d:	e9 f0 00 00 00       	jmp    102b22 <__alltraps>

00102a32 <vector236>:
.globl vector236
vector236:
  pushl $0
  102a32:	6a 00                	push   $0x0
  pushl $236
  102a34:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102a39:	e9 e4 00 00 00       	jmp    102b22 <__alltraps>

00102a3e <vector237>:
.globl vector237
vector237:
  pushl $0
  102a3e:	6a 00                	push   $0x0
  pushl $237
  102a40:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102a45:	e9 d8 00 00 00       	jmp    102b22 <__alltraps>

00102a4a <vector238>:
.globl vector238
vector238:
  pushl $0
  102a4a:	6a 00                	push   $0x0
  pushl $238
  102a4c:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102a51:	e9 cc 00 00 00       	jmp    102b22 <__alltraps>

00102a56 <vector239>:
.globl vector239
vector239:
  pushl $0
  102a56:	6a 00                	push   $0x0
  pushl $239
  102a58:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102a5d:	e9 c0 00 00 00       	jmp    102b22 <__alltraps>

00102a62 <vector240>:
.globl vector240
vector240:
  pushl $0
  102a62:	6a 00                	push   $0x0
  pushl $240
  102a64:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102a69:	e9 b4 00 00 00       	jmp    102b22 <__alltraps>

00102a6e <vector241>:
.globl vector241
vector241:
  pushl $0
  102a6e:	6a 00                	push   $0x0
  pushl $241
  102a70:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102a75:	e9 a8 00 00 00       	jmp    102b22 <__alltraps>

00102a7a <vector242>:
.globl vector242
vector242:
  pushl $0
  102a7a:	6a 00                	push   $0x0
  pushl $242
  102a7c:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102a81:	e9 9c 00 00 00       	jmp    102b22 <__alltraps>

00102a86 <vector243>:
.globl vector243
vector243:
  pushl $0
  102a86:	6a 00                	push   $0x0
  pushl $243
  102a88:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102a8d:	e9 90 00 00 00       	jmp    102b22 <__alltraps>

00102a92 <vector244>:
.globl vector244
vector244:
  pushl $0
  102a92:	6a 00                	push   $0x0
  pushl $244
  102a94:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102a99:	e9 84 00 00 00       	jmp    102b22 <__alltraps>

00102a9e <vector245>:
.globl vector245
vector245:
  pushl $0
  102a9e:	6a 00                	push   $0x0
  pushl $245
  102aa0:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102aa5:	e9 78 00 00 00       	jmp    102b22 <__alltraps>

00102aaa <vector246>:
.globl vector246
vector246:
  pushl $0
  102aaa:	6a 00                	push   $0x0
  pushl $246
  102aac:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102ab1:	e9 6c 00 00 00       	jmp    102b22 <__alltraps>

00102ab6 <vector247>:
.globl vector247
vector247:
  pushl $0
  102ab6:	6a 00                	push   $0x0
  pushl $247
  102ab8:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102abd:	e9 60 00 00 00       	jmp    102b22 <__alltraps>

00102ac2 <vector248>:
.globl vector248
vector248:
  pushl $0
  102ac2:	6a 00                	push   $0x0
  pushl $248
  102ac4:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102ac9:	e9 54 00 00 00       	jmp    102b22 <__alltraps>

00102ace <vector249>:
.globl vector249
vector249:
  pushl $0
  102ace:	6a 00                	push   $0x0
  pushl $249
  102ad0:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102ad5:	e9 48 00 00 00       	jmp    102b22 <__alltraps>

00102ada <vector250>:
.globl vector250
vector250:
  pushl $0
  102ada:	6a 00                	push   $0x0
  pushl $250
  102adc:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102ae1:	e9 3c 00 00 00       	jmp    102b22 <__alltraps>

00102ae6 <vector251>:
.globl vector251
vector251:
  pushl $0
  102ae6:	6a 00                	push   $0x0
  pushl $251
  102ae8:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102aed:	e9 30 00 00 00       	jmp    102b22 <__alltraps>

00102af2 <vector252>:
.globl vector252
vector252:
  pushl $0
  102af2:	6a 00                	push   $0x0
  pushl $252
  102af4:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102af9:	e9 24 00 00 00       	jmp    102b22 <__alltraps>

00102afe <vector253>:
.globl vector253
vector253:
  pushl $0
  102afe:	6a 00                	push   $0x0
  pushl $253
  102b00:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102b05:	e9 18 00 00 00       	jmp    102b22 <__alltraps>

00102b0a <vector254>:
.globl vector254
vector254:
  pushl $0
  102b0a:	6a 00                	push   $0x0
  pushl $254
  102b0c:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102b11:	e9 0c 00 00 00       	jmp    102b22 <__alltraps>

00102b16 <vector255>:
.globl vector255
vector255:
  pushl $0
  102b16:	6a 00                	push   $0x0
  pushl $255
  102b18:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102b1d:	e9 00 00 00 00       	jmp    102b22 <__alltraps>

00102b22 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102b22:	1e                   	push   %ds
    pushl %es
  102b23:	06                   	push   %es
    pushl %fs
  102b24:	0f a0                	push   %fs
    pushl %gs
  102b26:	0f a8                	push   %gs
    pushal
  102b28:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102b29:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102b2e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102b30:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102b32:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102b33:	e8 60 f5 ff ff       	call   102098 <trap>

    # pop the pushed stack pointer
    popl %esp
  102b38:	5c                   	pop    %esp

00102b39 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102b39:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102b3a:	0f a9                	pop    %gs
    popl %fs
  102b3c:	0f a1                	pop    %fs
    popl %es
  102b3e:	07                   	pop    %es
    popl %ds
  102b3f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102b40:	83 c4 08             	add    $0x8,%esp
    iret
  102b43:	cf                   	iret   

00102b44 <page2ppn>:
extern struct Page *pages;
extern size_t npage;

// PPN Physical Page Number 物理地址页号 
static inline ppn_t 
page2ppn(struct Page *page) { 
  102b44:	55                   	push   %ebp
  102b45:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102b47:	a1 78 df 11 00       	mov    0x11df78,%eax
  102b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  102b4f:	29 c2                	sub    %eax,%edx
  102b51:	89 d0                	mov    %edx,%eax
  102b53:	c1 f8 02             	sar    $0x2,%eax
  102b56:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102b5c:	5d                   	pop    %ebp
  102b5d:	c3                   	ret    

00102b5e <page2pa>:

// PA Physial Address 物理地址
static inline uintptr_t
page2pa(struct Page *page) {
  102b5e:	55                   	push   %ebp
  102b5f:	89 e5                	mov    %esp,%ebp
  102b61:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102b64:	8b 45 08             	mov    0x8(%ebp),%eax
  102b67:	89 04 24             	mov    %eax,(%esp)
  102b6a:	e8 d5 ff ff ff       	call   102b44 <page2ppn>
  102b6f:	c1 e0 0c             	shl    $0xc,%eax
}
  102b72:	c9                   	leave  
  102b73:	c3                   	ret    

00102b74 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102b74:	55                   	push   %ebp
  102b75:	89 e5                	mov    %esp,%ebp
  102b77:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7d:	c1 e8 0c             	shr    $0xc,%eax
  102b80:	89 c2                	mov    %eax,%edx
  102b82:	a1 80 de 11 00       	mov    0x11de80,%eax
  102b87:	39 c2                	cmp    %eax,%edx
  102b89:	72 1c                	jb     102ba7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102b8b:	c7 44 24 08 70 6b 10 	movl   $0x106b70,0x8(%esp)
  102b92:	00 
  102b93:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
  102b9a:	00 
  102b9b:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  102ba2:	e8 8f d8 ff ff       	call   100436 <__panic>
    }
    return &pages[PPN(pa)];
  102ba7:	8b 0d 78 df 11 00    	mov    0x11df78,%ecx
  102bad:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb0:	c1 e8 0c             	shr    $0xc,%eax
  102bb3:	89 c2                	mov    %eax,%edx
  102bb5:	89 d0                	mov    %edx,%eax
  102bb7:	c1 e0 02             	shl    $0x2,%eax
  102bba:	01 d0                	add    %edx,%eax
  102bbc:	c1 e0 02             	shl    $0x2,%eax
  102bbf:	01 c8                	add    %ecx,%eax
}
  102bc1:	c9                   	leave  
  102bc2:	c3                   	ret    

00102bc3 <page2kva>:

// KVA Kernel Virtual Address 内核虚拟地址
static inline void *
page2kva(struct Page *page) { 
  102bc3:	55                   	push   %ebp
  102bc4:	89 e5                	mov    %esp,%ebp
  102bc6:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bcc:	89 04 24             	mov    %eax,(%esp)
  102bcf:	e8 8a ff ff ff       	call   102b5e <page2pa>
  102bd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bda:	c1 e8 0c             	shr    $0xc,%eax
  102bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102be0:	a1 80 de 11 00       	mov    0x11de80,%eax
  102be5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102be8:	72 23                	jb     102c0d <page2kva+0x4a>
  102bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102bf1:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  102bf8:	00 
  102bf9:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  102c00:	00 
  102c01:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  102c08:	e8 29 d8 ff ff       	call   100436 <__panic>
  102c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c10:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102c15:	c9                   	leave  
  102c16:	c3                   	ret    

00102c17 <pte2page>:
    return pa2page(PADDR(kva));
}

// PTE Page Table Entry 页表
static inline struct Page *
pte2page(pte_t pte) {
  102c17:	55                   	push   %ebp
  102c18:	89 e5                	mov    %esp,%ebp
  102c1a:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  102c20:	83 e0 01             	and    $0x1,%eax
  102c23:	85 c0                	test   %eax,%eax
  102c25:	75 1c                	jne    102c43 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102c27:	c7 44 24 08 c4 6b 10 	movl   $0x106bc4,0x8(%esp)
  102c2e:	00 
  102c2f:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
  102c36:	00 
  102c37:	c7 04 24 8f 6b 10 00 	movl   $0x106b8f,(%esp)
  102c3e:	e8 f3 d7 ff ff       	call   100436 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102c43:	8b 45 08             	mov    0x8(%ebp),%eax
  102c46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102c4b:	89 04 24             	mov    %eax,(%esp)
  102c4e:	e8 21 ff ff ff       	call   102b74 <pa2page>
}
  102c53:	c9                   	leave  
  102c54:	c3                   	ret    

00102c55 <pde2page>:

// PDE Page Directory Entry 页目录表
static inline struct Page *
pde2page(pde_t pde) {
  102c55:	55                   	push   %ebp
  102c56:	89 e5                	mov    %esp,%ebp
  102c58:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  102c5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102c63:	89 04 24             	mov    %eax,(%esp)
  102c66:	e8 09 ff ff ff       	call   102b74 <pa2page>
}
  102c6b:	c9                   	leave  
  102c6c:	c3                   	ret    

00102c6d <page_ref>:

static inline int
page_ref(struct Page *page) {
  102c6d:	55                   	push   %ebp
  102c6e:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102c70:	8b 45 08             	mov    0x8(%ebp),%eax
  102c73:	8b 00                	mov    (%eax),%eax
}
  102c75:	5d                   	pop    %ebp
  102c76:	c3                   	ret    

00102c77 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102c77:	55                   	push   %ebp
  102c78:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  102c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102c80:	89 10                	mov    %edx,(%eax)
}
  102c82:	90                   	nop
  102c83:	5d                   	pop    %ebp
  102c84:	c3                   	ret    

00102c85 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102c85:	55                   	push   %ebp
  102c86:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102c88:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8b:	8b 00                	mov    (%eax),%eax
  102c8d:	8d 50 01             	lea    0x1(%eax),%edx
  102c90:	8b 45 08             	mov    0x8(%ebp),%eax
  102c93:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102c95:	8b 45 08             	mov    0x8(%ebp),%eax
  102c98:	8b 00                	mov    (%eax),%eax
}
  102c9a:	5d                   	pop    %ebp
  102c9b:	c3                   	ret    

00102c9c <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102c9c:	55                   	push   %ebp
  102c9d:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  102ca2:	8b 00                	mov    (%eax),%eax
  102ca4:	8d 50 ff             	lea    -0x1(%eax),%edx
  102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  102caa:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102cac:	8b 45 08             	mov    0x8(%ebp),%eax
  102caf:	8b 00                	mov    (%eax),%eax
}
  102cb1:	5d                   	pop    %ebp
  102cb2:	c3                   	ret    

00102cb3 <__intr_save>:
__intr_save(void) {
  102cb3:	55                   	push   %ebp
  102cb4:	89 e5                	mov    %esp,%ebp
  102cb6:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102cb9:	9c                   	pushf  
  102cba:	58                   	pop    %eax
  102cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102cc1:	25 00 02 00 00       	and    $0x200,%eax
  102cc6:	85 c0                	test   %eax,%eax
  102cc8:	74 0c                	je     102cd6 <__intr_save+0x23>
        intr_disable();
  102cca:	e8 bf ec ff ff       	call   10198e <intr_disable>
        return 1;
  102ccf:	b8 01 00 00 00       	mov    $0x1,%eax
  102cd4:	eb 05                	jmp    102cdb <__intr_save+0x28>
    return 0;
  102cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102cdb:	c9                   	leave  
  102cdc:	c3                   	ret    

00102cdd <__intr_restore>:
__intr_restore(bool flag) {
  102cdd:	55                   	push   %ebp
  102cde:	89 e5                	mov    %esp,%ebp
  102ce0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102ce3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102ce7:	74 05                	je     102cee <__intr_restore+0x11>
        intr_enable();
  102ce9:	e8 94 ec ff ff       	call   101982 <intr_enable>
}
  102cee:	90                   	nop
  102cef:	c9                   	leave  
  102cf0:	c3                   	ret    

00102cf1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102cf1:	55                   	push   %ebp
  102cf2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  102cf7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102cfa:	b8 23 00 00 00       	mov    $0x23,%eax
  102cff:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102d01:	b8 23 00 00 00       	mov    $0x23,%eax
  102d06:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102d08:	b8 10 00 00 00       	mov    $0x10,%eax
  102d0d:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102d0f:	b8 10 00 00 00       	mov    $0x10,%eax
  102d14:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102d16:	b8 10 00 00 00       	mov    $0x10,%eax
  102d1b:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102d1d:	ea 24 2d 10 00 08 00 	ljmp   $0x8,$0x102d24
}
  102d24:	90                   	nop
  102d25:	5d                   	pop    %ebp
  102d26:	c3                   	ret    

00102d27 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102d27:	f3 0f 1e fb          	endbr32 
  102d2b:	55                   	push   %ebp
  102d2c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d31:	a3 a4 de 11 00       	mov    %eax,0x11dea4
}
  102d36:	90                   	nop
  102d37:	5d                   	pop    %ebp
  102d38:	c3                   	ret    

00102d39 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102d39:	f3 0f 1e fb          	endbr32 
  102d3d:	55                   	push   %ebp
  102d3e:	89 e5                	mov    %esp,%ebp
  102d40:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102d43:	b8 00 a0 11 00       	mov    $0x11a000,%eax
  102d48:	89 04 24             	mov    %eax,(%esp)
  102d4b:	e8 d7 ff ff ff       	call   102d27 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102d50:	66 c7 05 a8 de 11 00 	movw   $0x10,0x11dea8
  102d57:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102d59:	66 c7 05 28 aa 11 00 	movw   $0x68,0x11aa28
  102d60:	68 00 
  102d62:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102d67:	0f b7 c0             	movzwl %ax,%eax
  102d6a:	66 a3 2a aa 11 00    	mov    %ax,0x11aa2a
  102d70:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102d75:	c1 e8 10             	shr    $0x10,%eax
  102d78:	a2 2c aa 11 00       	mov    %al,0x11aa2c
  102d7d:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102d84:	24 f0                	and    $0xf0,%al
  102d86:	0c 09                	or     $0x9,%al
  102d88:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102d8d:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102d94:	24 ef                	and    $0xef,%al
  102d96:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102d9b:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102da2:	24 9f                	and    $0x9f,%al
  102da4:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102da9:	0f b6 05 2d aa 11 00 	movzbl 0x11aa2d,%eax
  102db0:	0c 80                	or     $0x80,%al
  102db2:	a2 2d aa 11 00       	mov    %al,0x11aa2d
  102db7:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102dbe:	24 f0                	and    $0xf0,%al
  102dc0:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102dc5:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102dcc:	24 ef                	and    $0xef,%al
  102dce:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102dd3:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102dda:	24 df                	and    $0xdf,%al
  102ddc:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102de1:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102de8:	0c 40                	or     $0x40,%al
  102dea:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102def:	0f b6 05 2e aa 11 00 	movzbl 0x11aa2e,%eax
  102df6:	24 7f                	and    $0x7f,%al
  102df8:	a2 2e aa 11 00       	mov    %al,0x11aa2e
  102dfd:	b8 a0 de 11 00       	mov    $0x11dea0,%eax
  102e02:	c1 e8 18             	shr    $0x18,%eax
  102e05:	a2 2f aa 11 00       	mov    %al,0x11aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102e0a:	c7 04 24 30 aa 11 00 	movl   $0x11aa30,(%esp)
  102e11:	e8 db fe ff ff       	call   102cf1 <lgdt>
  102e16:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102e1c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102e20:	0f 00 d8             	ltr    %ax
}
  102e23:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102e24:	90                   	nop
  102e25:	c9                   	leave  
  102e26:	c3                   	ret    

00102e27 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102e27:	f3 0f 1e fb          	endbr32 
  102e2b:	55                   	push   %ebp
  102e2c:	89 e5                	mov    %esp,%ebp
  102e2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102e31:	c7 05 70 df 11 00 5c 	movl   $0x10755c,0x11df70
  102e38:	75 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102e3b:	a1 70 df 11 00       	mov    0x11df70,%eax
  102e40:	8b 00                	mov    (%eax),%eax
  102e42:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e46:	c7 04 24 f0 6b 10 00 	movl   $0x106bf0,(%esp)
  102e4d:	e8 78 d4 ff ff       	call   1002ca <cprintf>
    pmm_manager->init();
  102e52:	a1 70 df 11 00       	mov    0x11df70,%eax
  102e57:	8b 40 04             	mov    0x4(%eax),%eax
  102e5a:	ff d0                	call   *%eax
}
  102e5c:	90                   	nop
  102e5d:	c9                   	leave  
  102e5e:	c3                   	ret    

00102e5f <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102e5f:	f3 0f 1e fb          	endbr32 
  102e63:	55                   	push   %ebp
  102e64:	89 e5                	mov    %esp,%ebp
  102e66:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102e69:	a1 70 df 11 00       	mov    0x11df70,%eax
  102e6e:	8b 40 08             	mov    0x8(%eax),%eax
  102e71:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e74:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e78:	8b 55 08             	mov    0x8(%ebp),%edx
  102e7b:	89 14 24             	mov    %edx,(%esp)
  102e7e:	ff d0                	call   *%eax
}
  102e80:	90                   	nop
  102e81:	c9                   	leave  
  102e82:	c3                   	ret    

00102e83 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102e83:	f3 0f 1e fb          	endbr32 
  102e87:	55                   	push   %ebp
  102e88:	89 e5                	mov    %esp,%ebp
  102e8a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102e8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102e94:	e8 1a fe ff ff       	call   102cb3 <__intr_save>
  102e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102e9c:	a1 70 df 11 00       	mov    0x11df70,%eax
  102ea1:	8b 40 0c             	mov    0xc(%eax),%eax
  102ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  102ea7:	89 14 24             	mov    %edx,(%esp)
  102eaa:	ff d0                	call   *%eax
  102eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eb2:	89 04 24             	mov    %eax,(%esp)
  102eb5:	e8 23 fe ff ff       	call   102cdd <__intr_restore>
    return page;
  102eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102ebd:	c9                   	leave  
  102ebe:	c3                   	ret    

00102ebf <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102ebf:	f3 0f 1e fb          	endbr32 
  102ec3:	55                   	push   %ebp
  102ec4:	89 e5                	mov    %esp,%ebp
  102ec6:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102ec9:	e8 e5 fd ff ff       	call   102cb3 <__intr_save>
  102ece:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102ed1:	a1 70 df 11 00       	mov    0x11df70,%eax
  102ed6:	8b 40 10             	mov    0x10(%eax),%eax
  102ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
  102edc:	89 54 24 04          	mov    %edx,0x4(%esp)
  102ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  102ee3:	89 14 24             	mov    %edx,(%esp)
  102ee6:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eeb:	89 04 24             	mov    %eax,(%esp)
  102eee:	e8 ea fd ff ff       	call   102cdd <__intr_restore>
}
  102ef3:	90                   	nop
  102ef4:	c9                   	leave  
  102ef5:	c3                   	ret    

00102ef6 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102ef6:	f3 0f 1e fb          	endbr32 
  102efa:	55                   	push   %ebp
  102efb:	89 e5                	mov    %esp,%ebp
  102efd:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102f00:	e8 ae fd ff ff       	call   102cb3 <__intr_save>
  102f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102f08:	a1 70 df 11 00       	mov    0x11df70,%eax
  102f0d:	8b 40 14             	mov    0x14(%eax),%eax
  102f10:	ff d0                	call   *%eax
  102f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f18:	89 04 24             	mov    %eax,(%esp)
  102f1b:	e8 bd fd ff ff       	call   102cdd <__intr_restore>
    return ret;
  102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102f23:	c9                   	leave  
  102f24:	c3                   	ret    

00102f25 <page_init>:


/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102f25:	f3 0f 1e fb          	endbr32 
  102f29:	55                   	push   %ebp
  102f2a:	89 e5                	mov    %esp,%ebp
  102f2c:	57                   	push   %edi
  102f2d:	56                   	push   %esi
  102f2e:	53                   	push   %ebx
  102f2f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102f35:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102f3c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102f43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102f4a:	c7 04 24 07 6c 10 00 	movl   $0x106c07,(%esp)
  102f51:	e8 74 d3 ff ff       	call   1002ca <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102f56:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102f5d:	e9 1a 01 00 00       	jmp    10307c <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102f62:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f65:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f68:	89 d0                	mov    %edx,%eax
  102f6a:	c1 e0 02             	shl    $0x2,%eax
  102f6d:	01 d0                	add    %edx,%eax
  102f6f:	c1 e0 02             	shl    $0x2,%eax
  102f72:	01 c8                	add    %ecx,%eax
  102f74:	8b 50 08             	mov    0x8(%eax),%edx
  102f77:	8b 40 04             	mov    0x4(%eax),%eax
  102f7a:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102f7d:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102f80:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f83:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f86:	89 d0                	mov    %edx,%eax
  102f88:	c1 e0 02             	shl    $0x2,%eax
  102f8b:	01 d0                	add    %edx,%eax
  102f8d:	c1 e0 02             	shl    $0x2,%eax
  102f90:	01 c8                	add    %ecx,%eax
  102f92:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f95:	8b 58 10             	mov    0x10(%eax),%ebx
  102f98:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f9b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102f9e:	01 c8                	add    %ecx,%eax
  102fa0:	11 da                	adc    %ebx,%edx
  102fa2:	89 45 98             	mov    %eax,-0x68(%ebp)
  102fa5:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102fa8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102fab:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fae:	89 d0                	mov    %edx,%eax
  102fb0:	c1 e0 02             	shl    $0x2,%eax
  102fb3:	01 d0                	add    %edx,%eax
  102fb5:	c1 e0 02             	shl    $0x2,%eax
  102fb8:	01 c8                	add    %ecx,%eax
  102fba:	83 c0 14             	add    $0x14,%eax
  102fbd:	8b 00                	mov    (%eax),%eax
  102fbf:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102fc2:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fc5:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102fc8:	83 c0 ff             	add    $0xffffffff,%eax
  102fcb:	83 d2 ff             	adc    $0xffffffff,%edx
  102fce:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102fd4:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102fda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102fdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102fe0:	89 d0                	mov    %edx,%eax
  102fe2:	c1 e0 02             	shl    $0x2,%eax
  102fe5:	01 d0                	add    %edx,%eax
  102fe7:	c1 e0 02             	shl    $0x2,%eax
  102fea:	01 c8                	add    %ecx,%eax
  102fec:	8b 48 0c             	mov    0xc(%eax),%ecx
  102fef:	8b 58 10             	mov    0x10(%eax),%ebx
  102ff2:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102ff5:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102ff9:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102fff:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  103005:	89 44 24 14          	mov    %eax,0x14(%esp)
  103009:	89 54 24 18          	mov    %edx,0x18(%esp)
  10300d:	8b 45 a0             	mov    -0x60(%ebp),%eax
  103010:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  103013:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103017:	89 54 24 10          	mov    %edx,0x10(%esp)
  10301b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  10301f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  103023:	c7 04 24 14 6c 10 00 	movl   $0x106c14,(%esp)
  10302a:	e8 9b d2 ff ff       	call   1002ca <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  10302f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103032:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103035:	89 d0                	mov    %edx,%eax
  103037:	c1 e0 02             	shl    $0x2,%eax
  10303a:	01 d0                	add    %edx,%eax
  10303c:	c1 e0 02             	shl    $0x2,%eax
  10303f:	01 c8                	add    %ecx,%eax
  103041:	83 c0 14             	add    $0x14,%eax
  103044:	8b 00                	mov    (%eax),%eax
  103046:	83 f8 01             	cmp    $0x1,%eax
  103049:	75 2e                	jne    103079 <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
  10304b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10304e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103051:	3b 45 98             	cmp    -0x68(%ebp),%eax
  103054:	89 d0                	mov    %edx,%eax
  103056:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  103059:	73 1e                	jae    103079 <page_init+0x154>
  10305b:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  103060:	b8 00 00 00 00       	mov    $0x0,%eax
  103065:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  103068:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  10306b:	72 0c                	jb     103079 <page_init+0x154>
                maxpa = end;
  10306d:	8b 45 98             	mov    -0x68(%ebp),%eax
  103070:	8b 55 9c             	mov    -0x64(%ebp),%edx
  103073:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103076:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  103079:	ff 45 dc             	incl   -0x24(%ebp)
  10307c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10307f:	8b 00                	mov    (%eax),%eax
  103081:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103084:	0f 8c d8 fe ff ff    	jl     102f62 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  10308a:	ba 00 00 00 38       	mov    $0x38000000,%edx
  10308f:	b8 00 00 00 00       	mov    $0x0,%eax
  103094:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  103097:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  10309a:	73 0e                	jae    1030aa <page_init+0x185>
        maxpa = KMEMSIZE;
  10309c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  1030a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  1030aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1030b0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1030b4:	c1 ea 0c             	shr    $0xc,%edx
  1030b7:	a3 80 de 11 00       	mov    %eax,0x11de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  1030bc:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  1030c3:	b8 88 df 11 00       	mov    $0x11df88,%eax
  1030c8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030cb:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1030ce:	01 d0                	add    %edx,%eax
  1030d0:	89 45 bc             	mov    %eax,-0x44(%ebp)
  1030d3:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1030d6:	ba 00 00 00 00       	mov    $0x0,%edx
  1030db:	f7 75 c0             	divl   -0x40(%ebp)
  1030de:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1030e1:	29 d0                	sub    %edx,%eax
  1030e3:	a3 78 df 11 00       	mov    %eax,0x11df78

    for (i = 0; i < npage; i ++) {
  1030e8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1030ef:	eb 2f                	jmp    103120 <page_init+0x1fb>
        SetPageReserved(pages + i);
  1030f1:	8b 0d 78 df 11 00    	mov    0x11df78,%ecx
  1030f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030fa:	89 d0                	mov    %edx,%eax
  1030fc:	c1 e0 02             	shl    $0x2,%eax
  1030ff:	01 d0                	add    %edx,%eax
  103101:	c1 e0 02             	shl    $0x2,%eax
  103104:	01 c8                	add    %ecx,%eax
  103106:	83 c0 04             	add    $0x4,%eax
  103109:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  103110:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103113:	8b 45 90             	mov    -0x70(%ebp),%eax
  103116:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103119:	0f ab 10             	bts    %edx,(%eax)
}
  10311c:	90                   	nop
    for (i = 0; i < npage; i ++) {
  10311d:	ff 45 dc             	incl   -0x24(%ebp)
  103120:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103123:	a1 80 de 11 00       	mov    0x11de80,%eax
  103128:	39 c2                	cmp    %eax,%edx
  10312a:	72 c5                	jb     1030f1 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  10312c:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  103132:	89 d0                	mov    %edx,%eax
  103134:	c1 e0 02             	shl    $0x2,%eax
  103137:	01 d0                	add    %edx,%eax
  103139:	c1 e0 02             	shl    $0x2,%eax
  10313c:	89 c2                	mov    %eax,%edx
  10313e:	a1 78 df 11 00       	mov    0x11df78,%eax
  103143:	01 d0                	add    %edx,%eax
  103145:	89 45 b8             	mov    %eax,-0x48(%ebp)
  103148:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  10314f:	77 23                	ja     103174 <page_init+0x24f>
  103151:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103158:	c7 44 24 08 44 6c 10 	movl   $0x106c44,0x8(%esp)
  10315f:	00 
  103160:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  103167:	00 
  103168:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  10316f:	e8 c2 d2 ff ff       	call   100436 <__panic>
  103174:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103177:	05 00 00 00 40       	add    $0x40000000,%eax
  10317c:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  10317f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103186:	e9 4b 01 00 00       	jmp    1032d6 <page_init+0x3b1>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10318b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10318e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103191:	89 d0                	mov    %edx,%eax
  103193:	c1 e0 02             	shl    $0x2,%eax
  103196:	01 d0                	add    %edx,%eax
  103198:	c1 e0 02             	shl    $0x2,%eax
  10319b:	01 c8                	add    %ecx,%eax
  10319d:	8b 50 08             	mov    0x8(%eax),%edx
  1031a0:	8b 40 04             	mov    0x4(%eax),%eax
  1031a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1031a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1031a9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1031ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031af:	89 d0                	mov    %edx,%eax
  1031b1:	c1 e0 02             	shl    $0x2,%eax
  1031b4:	01 d0                	add    %edx,%eax
  1031b6:	c1 e0 02             	shl    $0x2,%eax
  1031b9:	01 c8                	add    %ecx,%eax
  1031bb:	8b 48 0c             	mov    0xc(%eax),%ecx
  1031be:	8b 58 10             	mov    0x10(%eax),%ebx
  1031c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1031c7:	01 c8                	add    %ecx,%eax
  1031c9:	11 da                	adc    %ebx,%edx
  1031cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1031ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1031d1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1031d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031d7:	89 d0                	mov    %edx,%eax
  1031d9:	c1 e0 02             	shl    $0x2,%eax
  1031dc:	01 d0                	add    %edx,%eax
  1031de:	c1 e0 02             	shl    $0x2,%eax
  1031e1:	01 c8                	add    %ecx,%eax
  1031e3:	83 c0 14             	add    $0x14,%eax
  1031e6:	8b 00                	mov    (%eax),%eax
  1031e8:	83 f8 01             	cmp    $0x1,%eax
  1031eb:	0f 85 e2 00 00 00    	jne    1032d3 <page_init+0x3ae>
            if (begin < freemem) {
  1031f1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1031f4:	ba 00 00 00 00       	mov    $0x0,%edx
  1031f9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1031fc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1031ff:	19 d1                	sbb    %edx,%ecx
  103201:	73 0d                	jae    103210 <page_init+0x2eb>
                begin = freemem;
  103203:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103206:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103209:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  103210:	ba 00 00 00 38       	mov    $0x38000000,%edx
  103215:	b8 00 00 00 00       	mov    $0x0,%eax
  10321a:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  10321d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  103220:	73 0e                	jae    103230 <page_init+0x30b>
                end = KMEMSIZE;
  103222:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  103229:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  103230:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103233:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103236:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103239:	89 d0                	mov    %edx,%eax
  10323b:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  10323e:	0f 83 8f 00 00 00    	jae    1032d3 <page_init+0x3ae>
                begin = ROUNDUP(begin, PGSIZE);
  103244:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  10324b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10324e:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103251:	01 d0                	add    %edx,%eax
  103253:	48                   	dec    %eax
  103254:	89 45 ac             	mov    %eax,-0x54(%ebp)
  103257:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10325a:	ba 00 00 00 00       	mov    $0x0,%edx
  10325f:	f7 75 b0             	divl   -0x50(%ebp)
  103262:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103265:	29 d0                	sub    %edx,%eax
  103267:	ba 00 00 00 00       	mov    $0x0,%edx
  10326c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10326f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103272:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103275:	89 45 a8             	mov    %eax,-0x58(%ebp)
  103278:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10327b:	ba 00 00 00 00       	mov    $0x0,%edx
  103280:	89 c3                	mov    %eax,%ebx
  103282:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  103288:	89 de                	mov    %ebx,%esi
  10328a:	89 d0                	mov    %edx,%eax
  10328c:	83 e0 00             	and    $0x0,%eax
  10328f:	89 c7                	mov    %eax,%edi
  103291:	89 75 c8             	mov    %esi,-0x38(%ebp)
  103294:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  103297:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10329a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10329d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1032a0:	89 d0                	mov    %edx,%eax
  1032a2:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1032a5:	73 2c                	jae    1032d3 <page_init+0x3ae>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1032a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1032aa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1032ad:	2b 45 d0             	sub    -0x30(%ebp),%eax
  1032b0:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  1032b3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1032b7:	c1 ea 0c             	shr    $0xc,%edx
  1032ba:	89 c3                	mov    %eax,%ebx
  1032bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1032bf:	89 04 24             	mov    %eax,(%esp)
  1032c2:	e8 ad f8 ff ff       	call   102b74 <pa2page>
  1032c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1032cb:	89 04 24             	mov    %eax,(%esp)
  1032ce:	e8 8c fb ff ff       	call   102e5f <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  1032d3:	ff 45 dc             	incl   -0x24(%ebp)
  1032d6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1032d9:	8b 00                	mov    (%eax),%eax
  1032db:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1032de:	0f 8c a7 fe ff ff    	jl     10318b <page_init+0x266>
                }
            }
        }
    }
}
  1032e4:	90                   	nop
  1032e5:	90                   	nop
  1032e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1032ec:	5b                   	pop    %ebx
  1032ed:	5e                   	pop    %esi
  1032ee:	5f                   	pop    %edi
  1032ef:	5d                   	pop    %ebp
  1032f0:	c3                   	ret    

001032f1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1032f1:	f3 0f 1e fb          	endbr32 
  1032f5:	55                   	push   %ebp
  1032f6:	89 e5                	mov    %esp,%ebp
  1032f8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1032fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032fe:	33 45 14             	xor    0x14(%ebp),%eax
  103301:	25 ff 0f 00 00       	and    $0xfff,%eax
  103306:	85 c0                	test   %eax,%eax
  103308:	74 24                	je     10332e <boot_map_segment+0x3d>
  10330a:	c7 44 24 0c 76 6c 10 	movl   $0x106c76,0xc(%esp)
  103311:	00 
  103312:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103319:	00 
  10331a:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  103321:	00 
  103322:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103329:	e8 08 d1 ff ff       	call   100436 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  10332e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103335:	8b 45 0c             	mov    0xc(%ebp),%eax
  103338:	25 ff 0f 00 00       	and    $0xfff,%eax
  10333d:	89 c2                	mov    %eax,%edx
  10333f:	8b 45 10             	mov    0x10(%ebp),%eax
  103342:	01 c2                	add    %eax,%edx
  103344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103347:	01 d0                	add    %edx,%eax
  103349:	48                   	dec    %eax
  10334a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10334d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103350:	ba 00 00 00 00       	mov    $0x0,%edx
  103355:	f7 75 f0             	divl   -0x10(%ebp)
  103358:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10335b:	29 d0                	sub    %edx,%eax
  10335d:	c1 e8 0c             	shr    $0xc,%eax
  103360:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103363:	8b 45 0c             	mov    0xc(%ebp),%eax
  103366:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103369:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10336c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103371:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103374:	8b 45 14             	mov    0x14(%ebp),%eax
  103377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10337a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10337d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103382:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103385:	eb 68                	jmp    1033ef <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
  103387:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10338e:	00 
  10338f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103392:	89 44 24 04          	mov    %eax,0x4(%esp)
  103396:	8b 45 08             	mov    0x8(%ebp),%eax
  103399:	89 04 24             	mov    %eax,(%esp)
  10339c:	e8 8a 01 00 00       	call   10352b <get_pte>
  1033a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1033a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1033a8:	75 24                	jne    1033ce <boot_map_segment+0xdd>
  1033aa:	c7 44 24 0c a2 6c 10 	movl   $0x106ca2,0xc(%esp)
  1033b1:	00 
  1033b2:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  1033b9:	00 
  1033ba:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  1033c1:	00 
  1033c2:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1033c9:	e8 68 d0 ff ff       	call   100436 <__panic>
        *ptep = pa | PTE_P | perm;
  1033ce:	8b 45 14             	mov    0x14(%ebp),%eax
  1033d1:	0b 45 18             	or     0x18(%ebp),%eax
  1033d4:	83 c8 01             	or     $0x1,%eax
  1033d7:	89 c2                	mov    %eax,%edx
  1033d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1033dc:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1033de:	ff 4d f4             	decl   -0xc(%ebp)
  1033e1:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1033e8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1033ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1033f3:	75 92                	jne    103387 <boot_map_segment+0x96>
    }
}
  1033f5:	90                   	nop
  1033f6:	90                   	nop
  1033f7:	c9                   	leave  
  1033f8:	c3                   	ret    

001033f9 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1033f9:	f3 0f 1e fb          	endbr32 
  1033fd:	55                   	push   %ebp
  1033fe:	89 e5                	mov    %esp,%ebp
  103400:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10340a:	e8 74 fa ff ff       	call   102e83 <alloc_pages>
  10340f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103412:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103416:	75 1c                	jne    103434 <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
  103418:	c7 44 24 08 af 6c 10 	movl   $0x106caf,0x8(%esp)
  10341f:	00 
  103420:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  103427:	00 
  103428:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  10342f:	e8 02 d0 ff ff       	call   100436 <__panic>
    }
    return page2kva(p);
  103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103437:	89 04 24             	mov    %eax,(%esp)
  10343a:	e8 84 f7 ff ff       	call   102bc3 <page2kva>
}
  10343f:	c9                   	leave  
  103440:	c3                   	ret    

00103441 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103441:	f3 0f 1e fb          	endbr32 
  103445:	55                   	push   %ebp
  103446:	89 e5                	mov    %esp,%ebp
  103448:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10344b:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103453:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10345a:	77 23                	ja     10347f <pmm_init+0x3e>
  10345c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10345f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103463:	c7 44 24 08 44 6c 10 	movl   $0x106c44,0x8(%esp)
  10346a:	00 
  10346b:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  103472:	00 
  103473:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  10347a:	e8 b7 cf ff ff       	call   100436 <__panic>
  10347f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103482:	05 00 00 00 40       	add    $0x40000000,%eax
  103487:	a3 74 df 11 00       	mov    %eax,0x11df74
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10348c:	e8 96 f9 ff ff       	call   102e27 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103491:	e8 8f fa ff ff       	call   102f25 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103496:	e8 77 04 00 00       	call   103912 <check_alloc_page>

    check_pgdir();
  10349b:	e8 95 04 00 00       	call   103935 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1034a0:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1034a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034a8:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1034af:	77 23                	ja     1034d4 <pmm_init+0x93>
  1034b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1034b8:	c7 44 24 08 44 6c 10 	movl   $0x106c44,0x8(%esp)
  1034bf:	00 
  1034c0:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  1034c7:	00 
  1034c8:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1034cf:	e8 62 cf ff ff       	call   100436 <__panic>
  1034d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d7:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  1034dd:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1034e2:	05 ac 0f 00 00       	add    $0xfac,%eax
  1034e7:	83 ca 03             	or     $0x3,%edx
  1034ea:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1034ec:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1034f1:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1034f8:	00 
  1034f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103500:	00 
  103501:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  103508:	38 
  103509:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  103510:	c0 
  103511:	89 04 24             	mov    %eax,(%esp)
  103514:	e8 d8 fd ff ff       	call   1032f1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103519:	e8 1b f8 ff ff       	call   102d39 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10351e:	e8 b2 0a 00 00       	call   103fd5 <check_boot_pgdir>

    print_pgdir();
  103523:	e8 37 0f 00 00       	call   10445f <print_pgdir>

}
  103528:	90                   	nop
  103529:	c9                   	leave  
  10352a:	c3                   	ret    

0010352b <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10352b:	f3 0f 1e fb          	endbr32 
  10352f:	55                   	push   %ebp
  103530:	89 e5                	mov    %esp,%ebp
  103532:	83 ec 48             	sub    $0x48,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif

	pde_t pde_index = PDX(la); // find page directory entry
  103535:	8b 45 0c             	mov    0xc(%ebp),%eax
  103538:	c1 e8 16             	shr    $0x16,%eax
  10353b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pte_t* pte_addr = NULL;
  10353e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
	
	pde_t* pde_ptr = &pgdir[pde_index];
  103545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103548:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10354f:	8b 45 08             	mov    0x8(%ebp),%eax
  103552:	01 d0                	add    %edx,%eax
  103554:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(*pde_ptr & PTE_P){ // check if entry is present
  103557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10355a:	8b 00                	mov    (%eax),%eax
  10355c:	83 e0 01             	and    $0x1,%eax
  10355f:	85 c0                	test   %eax,%eax
  103561:	74 67                	je     1035ca <get_pte+0x9f>
		pte_addr = (pte_t *)KADDR(PDE_ADDR(*pde_ptr));
  103563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103566:	8b 00                	mov    (%eax),%eax
  103568:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10356d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  103570:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103573:	c1 e8 0c             	shr    $0xc,%eax
  103576:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103579:	a1 80 de 11 00       	mov    0x11de80,%eax
  10357e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  103581:	72 23                	jb     1035a6 <get_pte+0x7b>
  103583:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10358a:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  103591:	00 
  103592:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
  103599:	00 
  10359a:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1035a1:	e8 90 ce ff ff       	call   100436 <__panic>
  1035a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1035a9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1035ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
		return &(pte_addr)[PTX(la)]; // return page table entry
  1035b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1035b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1035b7:	c1 ea 0c             	shr    $0xc,%edx
  1035ba:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  1035c0:	c1 e2 02             	shl    $0x2,%edx
  1035c3:	01 d0                	add    %edx,%eax
  1035c5:	e9 20 01 00 00       	jmp    1036ea <get_pte+0x1bf>
	}
	else{
		if(create == 0){ // check if creating is needed
  1035ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1035ce:	75 0a                	jne    1035da <get_pte+0xaf>
			return NULL;
  1035d0:	b8 00 00 00 00       	mov    $0x0,%eax
  1035d5:	e9 10 01 00 00       	jmp    1036ea <get_pte+0x1bf>
		}
		struct Page* new_page = alloc_page(); // alloc page for page table
  1035da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035e1:	e8 9d f8 ff ff       	call   102e83 <alloc_pages>
  1035e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(new_page == NULL){
  1035e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1035ed:	75 0a                	jne    1035f9 <get_pte+0xce>
			return NULL;
  1035ef:	b8 00 00 00 00       	mov    $0x0,%eax
  1035f4:	e9 f1 00 00 00       	jmp    1036ea <get_pte+0x1bf>
		}
		set_page_ref(new_page, 1); // set page reference
  1035f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103600:	00 
  103601:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103604:	89 04 24             	mov    %eax,(%esp)
  103607:	e8 6b f6 ff ff       	call   102c77 <set_page_ref>
		uintptr_t phy_addr = page2pa(new_page); // get linear address of page
  10360c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10360f:	89 04 24             	mov    %eax,(%esp)
  103612:	e8 47 f5 ff ff       	call   102b5e <page2pa>
  103617:	89 45 e8             	mov    %eax,-0x18(%ebp)
		memset(KADDR(phy_addr), 0, PGSIZE); // clear page content using memset
  10361a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10361d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103623:	c1 e8 0c             	shr    $0xc,%eax
  103626:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103629:	a1 80 de 11 00       	mov    0x11de80,%eax
  10362e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103631:	72 23                	jb     103656 <get_pte+0x12b>
  103633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103636:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10363a:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  103641:	00 
  103642:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
  103649:	00 
  10364a:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103651:	e8 e0 cd ff ff       	call   100436 <__panic>
  103656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103659:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10365e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103665:	00 
  103666:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10366d:	00 
  10366e:	89 04 24             	mov    %eax,(%esp)
  103671:	e8 c0 25 00 00       	call   105c36 <memset>
		*pde_ptr = phy_addr | PTE_P | PTE_W | PTE_U; // set page directory entry's permission
  103676:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103679:	83 c8 07             	or     $0x7,%eax
  10367c:	89 c2                	mov    %eax,%edx
  10367e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103681:	89 10                	mov    %edx,(%eax)
		pte_addr = (pte_t *)KADDR(PDE_ADDR(*pde_ptr)); 
  103683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103686:	8b 00                	mov    (%eax),%eax
  103688:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10368d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103690:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103693:	c1 e8 0c             	shr    $0xc,%eax
  103696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  103699:	a1 80 de 11 00       	mov    0x11de80,%eax
  10369e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1036a1:	72 23                	jb     1036c6 <get_pte+0x19b>
  1036a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1036a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1036aa:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  1036b1:	00 
  1036b2:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
  1036b9:	00 
  1036ba:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1036c1:	e8 70 cd ff ff       	call   100436 <__panic>
  1036c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1036c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1036ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
		return (&pte_addr)[PTX(la)]; // return page table entry
  1036d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036d4:	c1 e8 0c             	shr    $0xc,%eax
  1036d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  1036dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1036e3:	8d 45 cc             	lea    -0x34(%ebp),%eax
  1036e6:	01 d0                	add    %edx,%eax
  1036e8:	8b 00                	mov    (%eax),%eax
	}
	return NULL;
}
  1036ea:	c9                   	leave  
  1036eb:	c3                   	ret    

001036ec <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1036ec:	f3 0f 1e fb          	endbr32 
  1036f0:	55                   	push   %ebp
  1036f1:	89 e5                	mov    %esp,%ebp
  1036f3:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1036f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036fd:	00 
  1036fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  103701:	89 44 24 04          	mov    %eax,0x4(%esp)
  103705:	8b 45 08             	mov    0x8(%ebp),%eax
  103708:	89 04 24             	mov    %eax,(%esp)
  10370b:	e8 1b fe ff ff       	call   10352b <get_pte>
  103710:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103713:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103717:	74 08                	je     103721 <get_page+0x35>
        *ptep_store = ptep;
  103719:	8b 45 10             	mov    0x10(%ebp),%eax
  10371c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10371f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103721:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103725:	74 1b                	je     103742 <get_page+0x56>
  103727:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10372a:	8b 00                	mov    (%eax),%eax
  10372c:	83 e0 01             	and    $0x1,%eax
  10372f:	85 c0                	test   %eax,%eax
  103731:	74 0f                	je     103742 <get_page+0x56>
        return pte2page(*ptep);
  103733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103736:	8b 00                	mov    (%eax),%eax
  103738:	89 04 24             	mov    %eax,(%esp)
  10373b:	e8 d7 f4 ff ff       	call   102c17 <pte2page>
  103740:	eb 05                	jmp    103747 <get_page+0x5b>
    }
    return NULL;
  103742:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103747:	c9                   	leave  
  103748:	c3                   	ret    

00103749 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103749:	55                   	push   %ebp
  10374a:	89 e5                	mov    %esp,%ebp
  10374c:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
	if(*ptep & PTE_P){ 							// check if this page table entry is present
  10374f:	8b 45 10             	mov    0x10(%ebp),%eax
  103752:	8b 00                	mov    (%eax),%eax
  103754:	83 e0 01             	and    $0x1,%eax
  103757:	85 c0                	test   %eax,%eax
  103759:	74 4d                	je     1037a8 <page_remove_pte+0x5f>
		struct Page *page = pte2page(*ptep); 	// find corresponding page to pte
  10375b:	8b 45 10             	mov    0x10(%ebp),%eax
  10375e:	8b 00                	mov    (%eax),%eax
  103760:	89 04 24             	mov    %eax,(%esp)
  103763:	e8 af f4 ff ff       	call   102c17 <pte2page>
  103768:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(page_ref_dec(page) == 0){ 			// decrease page reference
  10376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10376e:	89 04 24             	mov    %eax,(%esp)
  103771:	e8 26 f5 ff ff       	call   102c9c <page_ref_dec>
  103776:	85 c0                	test   %eax,%eax
  103778:	75 13                	jne    10378d <page_remove_pte+0x44>
			free_page(page); 					// and free this page when page reference reachs 0
  10377a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103781:	00 
  103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103785:	89 04 24             	mov    %eax,(%esp)
  103788:	e8 32 f7 ff ff       	call   102ebf <free_pages>
		}
		*ptep = 0; 								// clear second page table entry
  10378d:	8b 45 10             	mov    0x10(%ebp),%eax
  103790:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, la); 				// flush tlb
  103796:	8b 45 0c             	mov    0xc(%ebp),%eax
  103799:	89 44 24 04          	mov    %eax,0x4(%esp)
  10379d:	8b 45 08             	mov    0x8(%ebp),%eax
  1037a0:	89 04 24             	mov    %eax,(%esp)
  1037a3:	e8 09 01 00 00       	call   1038b1 <tlb_invalidate>
	}
}
  1037a8:	90                   	nop
  1037a9:	c9                   	leave  
  1037aa:	c3                   	ret    

001037ab <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1037ab:	f3 0f 1e fb          	endbr32 
  1037af:	55                   	push   %ebp
  1037b0:	89 e5                	mov    %esp,%ebp
  1037b2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1037b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037bc:	00 
  1037bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1037c7:	89 04 24             	mov    %eax,(%esp)
  1037ca:	e8 5c fd ff ff       	call   10352b <get_pte>
  1037cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1037d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1037d6:	74 19                	je     1037f1 <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
  1037d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1037df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1037e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1037e9:	89 04 24             	mov    %eax,(%esp)
  1037ec:	e8 58 ff ff ff       	call   103749 <page_remove_pte>
    }
}
  1037f1:	90                   	nop
  1037f2:	c9                   	leave  
  1037f3:	c3                   	ret    

001037f4 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1037f4:	f3 0f 1e fb          	endbr32 
  1037f8:	55                   	push   %ebp
  1037f9:	89 e5                	mov    %esp,%ebp
  1037fb:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1037fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103805:	00 
  103806:	8b 45 10             	mov    0x10(%ebp),%eax
  103809:	89 44 24 04          	mov    %eax,0x4(%esp)
  10380d:	8b 45 08             	mov    0x8(%ebp),%eax
  103810:	89 04 24             	mov    %eax,(%esp)
  103813:	e8 13 fd ff ff       	call   10352b <get_pte>
  103818:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10381b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10381f:	75 0a                	jne    10382b <page_insert+0x37>
        return -E_NO_MEM;
  103821:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103826:	e9 84 00 00 00       	jmp    1038af <page_insert+0xbb>
    }
    page_ref_inc(page);
  10382b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10382e:	89 04 24             	mov    %eax,(%esp)
  103831:	e8 4f f4 ff ff       	call   102c85 <page_ref_inc>
    if (*ptep & PTE_P) {
  103836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103839:	8b 00                	mov    (%eax),%eax
  10383b:	83 e0 01             	and    $0x1,%eax
  10383e:	85 c0                	test   %eax,%eax
  103840:	74 3e                	je     103880 <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
  103842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103845:	8b 00                	mov    (%eax),%eax
  103847:	89 04 24             	mov    %eax,(%esp)
  10384a:	e8 c8 f3 ff ff       	call   102c17 <pte2page>
  10384f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  103852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103855:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103858:	75 0d                	jne    103867 <page_insert+0x73>
            page_ref_dec(page);
  10385a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10385d:	89 04 24             	mov    %eax,(%esp)
  103860:	e8 37 f4 ff ff       	call   102c9c <page_ref_dec>
  103865:	eb 19                	jmp    103880 <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10386a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10386e:	8b 45 10             	mov    0x10(%ebp),%eax
  103871:	89 44 24 04          	mov    %eax,0x4(%esp)
  103875:	8b 45 08             	mov    0x8(%ebp),%eax
  103878:	89 04 24             	mov    %eax,(%esp)
  10387b:	e8 c9 fe ff ff       	call   103749 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  103880:	8b 45 0c             	mov    0xc(%ebp),%eax
  103883:	89 04 24             	mov    %eax,(%esp)
  103886:	e8 d3 f2 ff ff       	call   102b5e <page2pa>
  10388b:	0b 45 14             	or     0x14(%ebp),%eax
  10388e:	83 c8 01             	or     $0x1,%eax
  103891:	89 c2                	mov    %eax,%edx
  103893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103896:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103898:	8b 45 10             	mov    0x10(%ebp),%eax
  10389b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10389f:	8b 45 08             	mov    0x8(%ebp),%eax
  1038a2:	89 04 24             	mov    %eax,(%esp)
  1038a5:	e8 07 00 00 00       	call   1038b1 <tlb_invalidate>
    return 0;
  1038aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1038af:	c9                   	leave  
  1038b0:	c3                   	ret    

001038b1 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1038b1:	f3 0f 1e fb          	endbr32 
  1038b5:	55                   	push   %ebp
  1038b6:	89 e5                	mov    %esp,%ebp
  1038b8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1038bb:	0f 20 d8             	mov    %cr3,%eax
  1038be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1038c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1038c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1038c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1038ca:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1038d1:	77 23                	ja     1038f6 <tlb_invalidate+0x45>
  1038d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1038da:	c7 44 24 08 44 6c 10 	movl   $0x106c44,0x8(%esp)
  1038e1:	00 
  1038e2:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  1038e9:	00 
  1038ea:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1038f1:	e8 40 cb ff ff       	call   100436 <__panic>
  1038f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038f9:	05 00 00 00 40       	add    $0x40000000,%eax
  1038fe:	39 d0                	cmp    %edx,%eax
  103900:	75 0d                	jne    10390f <tlb_invalidate+0x5e>
        invlpg((void *)la);
  103902:	8b 45 0c             	mov    0xc(%ebp),%eax
  103905:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103908:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10390b:	0f 01 38             	invlpg (%eax)
}
  10390e:	90                   	nop
    }
}
  10390f:	90                   	nop
  103910:	c9                   	leave  
  103911:	c3                   	ret    

00103912 <check_alloc_page>:

static void
check_alloc_page(void) {
  103912:	f3 0f 1e fb          	endbr32 
  103916:	55                   	push   %ebp
  103917:	89 e5                	mov    %esp,%ebp
  103919:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10391c:	a1 70 df 11 00       	mov    0x11df70,%eax
  103921:	8b 40 18             	mov    0x18(%eax),%eax
  103924:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103926:	c7 04 24 c8 6c 10 00 	movl   $0x106cc8,(%esp)
  10392d:	e8 98 c9 ff ff       	call   1002ca <cprintf>
}
  103932:	90                   	nop
  103933:	c9                   	leave  
  103934:	c3                   	ret    

00103935 <check_pgdir>:

static void
check_pgdir(void) {
  103935:	f3 0f 1e fb          	endbr32 
  103939:	55                   	push   %ebp
  10393a:	89 e5                	mov    %esp,%ebp
  10393c:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10393f:	a1 80 de 11 00       	mov    0x11de80,%eax
  103944:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103949:	76 24                	jbe    10396f <check_pgdir+0x3a>
  10394b:	c7 44 24 0c e7 6c 10 	movl   $0x106ce7,0xc(%esp)
  103952:	00 
  103953:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  10395a:	00 
  10395b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  103962:	00 
  103963:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  10396a:	e8 c7 ca ff ff       	call   100436 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  10396f:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103974:	85 c0                	test   %eax,%eax
  103976:	74 0e                	je     103986 <check_pgdir+0x51>
  103978:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10397d:	25 ff 0f 00 00       	and    $0xfff,%eax
  103982:	85 c0                	test   %eax,%eax
  103984:	74 24                	je     1039aa <check_pgdir+0x75>
  103986:	c7 44 24 0c 04 6d 10 	movl   $0x106d04,0xc(%esp)
  10398d:	00 
  10398e:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103995:	00 
  103996:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  10399d:	00 
  10399e:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1039a5:	e8 8c ca ff ff       	call   100436 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1039aa:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1039af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1039b6:	00 
  1039b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1039be:	00 
  1039bf:	89 04 24             	mov    %eax,(%esp)
  1039c2:	e8 25 fd ff ff       	call   1036ec <get_page>
  1039c7:	85 c0                	test   %eax,%eax
  1039c9:	74 24                	je     1039ef <check_pgdir+0xba>
  1039cb:	c7 44 24 0c 3c 6d 10 	movl   $0x106d3c,0xc(%esp)
  1039d2:	00 
  1039d3:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  1039da:	00 
  1039db:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  1039e2:	00 
  1039e3:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1039ea:	e8 47 ca ff ff       	call   100436 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1039ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1039f6:	e8 88 f4 ff ff       	call   102e83 <alloc_pages>
  1039fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1039fe:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103a0a:	00 
  103a0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a12:	00 
  103a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103a16:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a1a:	89 04 24             	mov    %eax,(%esp)
  103a1d:	e8 d2 fd ff ff       	call   1037f4 <page_insert>
  103a22:	85 c0                	test   %eax,%eax
  103a24:	74 24                	je     103a4a <check_pgdir+0x115>
  103a26:	c7 44 24 0c 64 6d 10 	movl   $0x106d64,0xc(%esp)
  103a2d:	00 
  103a2e:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103a35:	00 
  103a36:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103a3d:	00 
  103a3e:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103a45:	e8 ec c9 ff ff       	call   100436 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103a4a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103a4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a56:	00 
  103a57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103a5e:	00 
  103a5f:	89 04 24             	mov    %eax,(%esp)
  103a62:	e8 c4 fa ff ff       	call   10352b <get_pte>
  103a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a6e:	75 24                	jne    103a94 <check_pgdir+0x15f>
  103a70:	c7 44 24 0c 90 6d 10 	movl   $0x106d90,0xc(%esp)
  103a77:	00 
  103a78:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103a7f:	00 
  103a80:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  103a87:	00 
  103a88:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103a8f:	e8 a2 c9 ff ff       	call   100436 <__panic>
    assert(pte2page(*ptep) == p1);
  103a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a97:	8b 00                	mov    (%eax),%eax
  103a99:	89 04 24             	mov    %eax,(%esp)
  103a9c:	e8 76 f1 ff ff       	call   102c17 <pte2page>
  103aa1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103aa4:	74 24                	je     103aca <check_pgdir+0x195>
  103aa6:	c7 44 24 0c bd 6d 10 	movl   $0x106dbd,0xc(%esp)
  103aad:	00 
  103aae:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103ab5:	00 
  103ab6:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103abd:	00 
  103abe:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103ac5:	e8 6c c9 ff ff       	call   100436 <__panic>
    assert(page_ref(p1) == 1);
  103aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103acd:	89 04 24             	mov    %eax,(%esp)
  103ad0:	e8 98 f1 ff ff       	call   102c6d <page_ref>
  103ad5:	83 f8 01             	cmp    $0x1,%eax
  103ad8:	74 24                	je     103afe <check_pgdir+0x1c9>
  103ada:	c7 44 24 0c d3 6d 10 	movl   $0x106dd3,0xc(%esp)
  103ae1:	00 
  103ae2:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103ae9:	00 
  103aea:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103af1:	00 
  103af2:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103af9:	e8 38 c9 ff ff       	call   100436 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103afe:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b03:	8b 00                	mov    (%eax),%eax
  103b05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b10:	c1 e8 0c             	shr    $0xc,%eax
  103b13:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103b16:	a1 80 de 11 00       	mov    0x11de80,%eax
  103b1b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103b1e:	72 23                	jb     103b43 <check_pgdir+0x20e>
  103b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103b27:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  103b2e:	00 
  103b2f:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103b36:	00 
  103b37:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103b3e:	e8 f3 c8 ff ff       	call   100436 <__panic>
  103b43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103b46:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103b4b:	83 c0 04             	add    $0x4,%eax
  103b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103b51:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103b56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103b5d:	00 
  103b5e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b65:	00 
  103b66:	89 04 24             	mov    %eax,(%esp)
  103b69:	e8 bd f9 ff ff       	call   10352b <get_pte>
  103b6e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103b71:	74 24                	je     103b97 <check_pgdir+0x262>
  103b73:	c7 44 24 0c e8 6d 10 	movl   $0x106de8,0xc(%esp)
  103b7a:	00 
  103b7b:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103b82:	00 
  103b83:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  103b8a:	00 
  103b8b:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103b92:	e8 9f c8 ff ff       	call   100436 <__panic>

    p2 = alloc_page();
  103b97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b9e:	e8 e0 f2 ff ff       	call   102e83 <alloc_pages>
  103ba3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103ba6:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103bab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103bb2:	00 
  103bb3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103bba:	00 
  103bbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  103bc2:	89 04 24             	mov    %eax,(%esp)
  103bc5:	e8 2a fc ff ff       	call   1037f4 <page_insert>
  103bca:	85 c0                	test   %eax,%eax
  103bcc:	74 24                	je     103bf2 <check_pgdir+0x2bd>
  103bce:	c7 44 24 0c 10 6e 10 	movl   $0x106e10,0xc(%esp)
  103bd5:	00 
  103bd6:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103bdd:	00 
  103bde:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103be5:	00 
  103be6:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103bed:	e8 44 c8 ff ff       	call   100436 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103bf2:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103bfe:	00 
  103bff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103c06:	00 
  103c07:	89 04 24             	mov    %eax,(%esp)
  103c0a:	e8 1c f9 ff ff       	call   10352b <get_pte>
  103c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103c16:	75 24                	jne    103c3c <check_pgdir+0x307>
  103c18:	c7 44 24 0c 48 6e 10 	movl   $0x106e48,0xc(%esp)
  103c1f:	00 
  103c20:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103c27:	00 
  103c28:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  103c2f:	00 
  103c30:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103c37:	e8 fa c7 ff ff       	call   100436 <__panic>
    assert(*ptep & PTE_U);
  103c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c3f:	8b 00                	mov    (%eax),%eax
  103c41:	83 e0 04             	and    $0x4,%eax
  103c44:	85 c0                	test   %eax,%eax
  103c46:	75 24                	jne    103c6c <check_pgdir+0x337>
  103c48:	c7 44 24 0c 78 6e 10 	movl   $0x106e78,0xc(%esp)
  103c4f:	00 
  103c50:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103c57:	00 
  103c58:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  103c5f:	00 
  103c60:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103c67:	e8 ca c7 ff ff       	call   100436 <__panic>
    assert(*ptep & PTE_W);
  103c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c6f:	8b 00                	mov    (%eax),%eax
  103c71:	83 e0 02             	and    $0x2,%eax
  103c74:	85 c0                	test   %eax,%eax
  103c76:	75 24                	jne    103c9c <check_pgdir+0x367>
  103c78:	c7 44 24 0c 86 6e 10 	movl   $0x106e86,0xc(%esp)
  103c7f:	00 
  103c80:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103c87:	00 
  103c88:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  103c8f:	00 
  103c90:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103c97:	e8 9a c7 ff ff       	call   100436 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103c9c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ca1:	8b 00                	mov    (%eax),%eax
  103ca3:	83 e0 04             	and    $0x4,%eax
  103ca6:	85 c0                	test   %eax,%eax
  103ca8:	75 24                	jne    103cce <check_pgdir+0x399>
  103caa:	c7 44 24 0c 94 6e 10 	movl   $0x106e94,0xc(%esp)
  103cb1:	00 
  103cb2:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103cb9:	00 
  103cba:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  103cc1:	00 
  103cc2:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103cc9:	e8 68 c7 ff ff       	call   100436 <__panic>
    assert(page_ref(p2) == 1);
  103cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103cd1:	89 04 24             	mov    %eax,(%esp)
  103cd4:	e8 94 ef ff ff       	call   102c6d <page_ref>
  103cd9:	83 f8 01             	cmp    $0x1,%eax
  103cdc:	74 24                	je     103d02 <check_pgdir+0x3cd>
  103cde:	c7 44 24 0c aa 6e 10 	movl   $0x106eaa,0xc(%esp)
  103ce5:	00 
  103ce6:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103ced:	00 
  103cee:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  103cf5:	00 
  103cf6:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103cfd:	e8 34 c7 ff ff       	call   100436 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103d02:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103d07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103d0e:	00 
  103d0f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103d16:	00 
  103d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d1e:	89 04 24             	mov    %eax,(%esp)
  103d21:	e8 ce fa ff ff       	call   1037f4 <page_insert>
  103d26:	85 c0                	test   %eax,%eax
  103d28:	74 24                	je     103d4e <check_pgdir+0x419>
  103d2a:	c7 44 24 0c bc 6e 10 	movl   $0x106ebc,0xc(%esp)
  103d31:	00 
  103d32:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103d39:	00 
  103d3a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
  103d41:	00 
  103d42:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103d49:	e8 e8 c6 ff ff       	call   100436 <__panic>
    assert(page_ref(p1) == 2);
  103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d51:	89 04 24             	mov    %eax,(%esp)
  103d54:	e8 14 ef ff ff       	call   102c6d <page_ref>
  103d59:	83 f8 02             	cmp    $0x2,%eax
  103d5c:	74 24                	je     103d82 <check_pgdir+0x44d>
  103d5e:	c7 44 24 0c e8 6e 10 	movl   $0x106ee8,0xc(%esp)
  103d65:	00 
  103d66:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103d6d:	00 
  103d6e:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  103d75:	00 
  103d76:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103d7d:	e8 b4 c6 ff ff       	call   100436 <__panic>
    assert(page_ref(p2) == 0);
  103d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d85:	89 04 24             	mov    %eax,(%esp)
  103d88:	e8 e0 ee ff ff       	call   102c6d <page_ref>
  103d8d:	85 c0                	test   %eax,%eax
  103d8f:	74 24                	je     103db5 <check_pgdir+0x480>
  103d91:	c7 44 24 0c fa 6e 10 	movl   $0x106efa,0xc(%esp)
  103d98:	00 
  103d99:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103da0:	00 
  103da1:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  103da8:	00 
  103da9:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103db0:	e8 81 c6 ff ff       	call   100436 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103db5:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103dba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103dc1:	00 
  103dc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103dc9:	00 
  103dca:	89 04 24             	mov    %eax,(%esp)
  103dcd:	e8 59 f7 ff ff       	call   10352b <get_pte>
  103dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103dd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103dd9:	75 24                	jne    103dff <check_pgdir+0x4ca>
  103ddb:	c7 44 24 0c 48 6e 10 	movl   $0x106e48,0xc(%esp)
  103de2:	00 
  103de3:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103dea:	00 
  103deb:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103df2:	00 
  103df3:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103dfa:	e8 37 c6 ff ff       	call   100436 <__panic>
    assert(pte2page(*ptep) == p1);
  103dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e02:	8b 00                	mov    (%eax),%eax
  103e04:	89 04 24             	mov    %eax,(%esp)
  103e07:	e8 0b ee ff ff       	call   102c17 <pte2page>
  103e0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103e0f:	74 24                	je     103e35 <check_pgdir+0x500>
  103e11:	c7 44 24 0c bd 6d 10 	movl   $0x106dbd,0xc(%esp)
  103e18:	00 
  103e19:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103e20:	00 
  103e21:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
  103e28:	00 
  103e29:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103e30:	e8 01 c6 ff ff       	call   100436 <__panic>
    assert((*ptep & PTE_U) == 0);
  103e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103e38:	8b 00                	mov    (%eax),%eax
  103e3a:	83 e0 04             	and    $0x4,%eax
  103e3d:	85 c0                	test   %eax,%eax
  103e3f:	74 24                	je     103e65 <check_pgdir+0x530>
  103e41:	c7 44 24 0c 0c 6f 10 	movl   $0x106f0c,0xc(%esp)
  103e48:	00 
  103e49:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103e50:	00 
  103e51:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103e58:	00 
  103e59:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103e60:	e8 d1 c5 ff ff       	call   100436 <__panic>

    page_remove(boot_pgdir, 0x0);
  103e65:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103e6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103e71:	00 
  103e72:	89 04 24             	mov    %eax,(%esp)
  103e75:	e8 31 f9 ff ff       	call   1037ab <page_remove>
    assert(page_ref(p1) == 1);
  103e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e7d:	89 04 24             	mov    %eax,(%esp)
  103e80:	e8 e8 ed ff ff       	call   102c6d <page_ref>
  103e85:	83 f8 01             	cmp    $0x1,%eax
  103e88:	74 24                	je     103eae <check_pgdir+0x579>
  103e8a:	c7 44 24 0c d3 6d 10 	movl   $0x106dd3,0xc(%esp)
  103e91:	00 
  103e92:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103e99:	00 
  103e9a:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  103ea1:	00 
  103ea2:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103ea9:	e8 88 c5 ff ff       	call   100436 <__panic>
    assert(page_ref(p2) == 0);
  103eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103eb1:	89 04 24             	mov    %eax,(%esp)
  103eb4:	e8 b4 ed ff ff       	call   102c6d <page_ref>
  103eb9:	85 c0                	test   %eax,%eax
  103ebb:	74 24                	je     103ee1 <check_pgdir+0x5ac>
  103ebd:	c7 44 24 0c fa 6e 10 	movl   $0x106efa,0xc(%esp)
  103ec4:	00 
  103ec5:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103ecc:	00 
  103ecd:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
  103ed4:	00 
  103ed5:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103edc:	e8 55 c5 ff ff       	call   100436 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103ee1:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103ee6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103eed:	00 
  103eee:	89 04 24             	mov    %eax,(%esp)
  103ef1:	e8 b5 f8 ff ff       	call   1037ab <page_remove>
    assert(page_ref(p1) == 0);
  103ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ef9:	89 04 24             	mov    %eax,(%esp)
  103efc:	e8 6c ed ff ff       	call   102c6d <page_ref>
  103f01:	85 c0                	test   %eax,%eax
  103f03:	74 24                	je     103f29 <check_pgdir+0x5f4>
  103f05:	c7 44 24 0c 21 6f 10 	movl   $0x106f21,0xc(%esp)
  103f0c:	00 
  103f0d:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103f14:	00 
  103f15:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  103f1c:	00 
  103f1d:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103f24:	e8 0d c5 ff ff       	call   100436 <__panic>
    assert(page_ref(p2) == 0);
  103f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103f2c:	89 04 24             	mov    %eax,(%esp)
  103f2f:	e8 39 ed ff ff       	call   102c6d <page_ref>
  103f34:	85 c0                	test   %eax,%eax
  103f36:	74 24                	je     103f5c <check_pgdir+0x627>
  103f38:	c7 44 24 0c fa 6e 10 	movl   $0x106efa,0xc(%esp)
  103f3f:	00 
  103f40:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103f47:	00 
  103f48:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  103f4f:	00 
  103f50:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103f57:	e8 da c4 ff ff       	call   100436 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103f5c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103f61:	8b 00                	mov    (%eax),%eax
  103f63:	89 04 24             	mov    %eax,(%esp)
  103f66:	e8 ea ec ff ff       	call   102c55 <pde2page>
  103f6b:	89 04 24             	mov    %eax,(%esp)
  103f6e:	e8 fa ec ff ff       	call   102c6d <page_ref>
  103f73:	83 f8 01             	cmp    $0x1,%eax
  103f76:	74 24                	je     103f9c <check_pgdir+0x667>
  103f78:	c7 44 24 0c 34 6f 10 	movl   $0x106f34,0xc(%esp)
  103f7f:	00 
  103f80:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  103f87:	00 
  103f88:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
  103f8f:	00 
  103f90:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  103f97:	e8 9a c4 ff ff       	call   100436 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103f9c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103fa1:	8b 00                	mov    (%eax),%eax
  103fa3:	89 04 24             	mov    %eax,(%esp)
  103fa6:	e8 aa ec ff ff       	call   102c55 <pde2page>
  103fab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103fb2:	00 
  103fb3:	89 04 24             	mov    %eax,(%esp)
  103fb6:	e8 04 ef ff ff       	call   102ebf <free_pages>
    boot_pgdir[0] = 0;
  103fbb:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  103fc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103fc6:	c7 04 24 5b 6f 10 00 	movl   $0x106f5b,(%esp)
  103fcd:	e8 f8 c2 ff ff       	call   1002ca <cprintf>
}
  103fd2:	90                   	nop
  103fd3:	c9                   	leave  
  103fd4:	c3                   	ret    

00103fd5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103fd5:	f3 0f 1e fb          	endbr32 
  103fd9:	55                   	push   %ebp
  103fda:	89 e5                	mov    %esp,%ebp
  103fdc:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103fdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103fe6:	e9 ca 00 00 00       	jmp    1040b5 <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ff4:	c1 e8 0c             	shr    $0xc,%eax
  103ff7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103ffa:	a1 80 de 11 00       	mov    0x11de80,%eax
  103fff:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104002:	72 23                	jb     104027 <check_boot_pgdir+0x52>
  104004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104007:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10400b:	c7 44 24 08 a0 6b 10 	movl   $0x106ba0,0x8(%esp)
  104012:	00 
  104013:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
  10401a:	00 
  10401b:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104022:	e8 0f c4 ff ff       	call   100436 <__panic>
  104027:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10402a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10402f:	89 c2                	mov    %eax,%edx
  104031:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  104036:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10403d:	00 
  10403e:	89 54 24 04          	mov    %edx,0x4(%esp)
  104042:	89 04 24             	mov    %eax,(%esp)
  104045:	e8 e1 f4 ff ff       	call   10352b <get_pte>
  10404a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10404d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104051:	75 24                	jne    104077 <check_boot_pgdir+0xa2>
  104053:	c7 44 24 0c 78 6f 10 	movl   $0x106f78,0xc(%esp)
  10405a:	00 
  10405b:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104062:	00 
  104063:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
  10406a:	00 
  10406b:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104072:	e8 bf c3 ff ff       	call   100436 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  104077:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10407a:	8b 00                	mov    (%eax),%eax
  10407c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104081:	89 c2                	mov    %eax,%edx
  104083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104086:	39 c2                	cmp    %eax,%edx
  104088:	74 24                	je     1040ae <check_boot_pgdir+0xd9>
  10408a:	c7 44 24 0c b5 6f 10 	movl   $0x106fb5,0xc(%esp)
  104091:	00 
  104092:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104099:	00 
  10409a:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  1040a1:	00 
  1040a2:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1040a9:	e8 88 c3 ff ff       	call   100436 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  1040ae:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1040b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1040b8:	a1 80 de 11 00       	mov    0x11de80,%eax
  1040bd:	39 c2                	cmp    %eax,%edx
  1040bf:	0f 82 26 ff ff ff    	jb     103feb <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  1040c5:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1040ca:	05 ac 0f 00 00       	add    $0xfac,%eax
  1040cf:	8b 00                	mov    (%eax),%eax
  1040d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1040d6:	89 c2                	mov    %eax,%edx
  1040d8:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1040dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1040e0:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1040e7:	77 23                	ja     10410c <check_boot_pgdir+0x137>
  1040e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1040ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1040f0:	c7 44 24 08 44 6c 10 	movl   $0x106c44,0x8(%esp)
  1040f7:	00 
  1040f8:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  1040ff:	00 
  104100:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104107:	e8 2a c3 ff ff       	call   100436 <__panic>
  10410c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10410f:	05 00 00 00 40       	add    $0x40000000,%eax
  104114:	39 d0                	cmp    %edx,%eax
  104116:	74 24                	je     10413c <check_boot_pgdir+0x167>
  104118:	c7 44 24 0c cc 6f 10 	movl   $0x106fcc,0xc(%esp)
  10411f:	00 
  104120:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104127:	00 
  104128:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  10412f:	00 
  104130:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104137:	e8 fa c2 ff ff       	call   100436 <__panic>

    assert(boot_pgdir[0] == 0);
  10413c:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  104141:	8b 00                	mov    (%eax),%eax
  104143:	85 c0                	test   %eax,%eax
  104145:	74 24                	je     10416b <check_boot_pgdir+0x196>
  104147:	c7 44 24 0c 00 70 10 	movl   $0x107000,0xc(%esp)
  10414e:	00 
  10414f:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104156:	00 
  104157:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
  10415e:	00 
  10415f:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104166:	e8 cb c2 ff ff       	call   100436 <__panic>

    struct Page *p;
    p = alloc_page();
  10416b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104172:	e8 0c ed ff ff       	call   102e83 <alloc_pages>
  104177:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10417a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10417f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104186:	00 
  104187:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  10418e:	00 
  10418f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104192:	89 54 24 04          	mov    %edx,0x4(%esp)
  104196:	89 04 24             	mov    %eax,(%esp)
  104199:	e8 56 f6 ff ff       	call   1037f4 <page_insert>
  10419e:	85 c0                	test   %eax,%eax
  1041a0:	74 24                	je     1041c6 <check_boot_pgdir+0x1f1>
  1041a2:	c7 44 24 0c 14 70 10 	movl   $0x107014,0xc(%esp)
  1041a9:	00 
  1041aa:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  1041b1:	00 
  1041b2:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
  1041b9:	00 
  1041ba:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1041c1:	e8 70 c2 ff ff       	call   100436 <__panic>
    assert(page_ref(p) == 1);
  1041c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041c9:	89 04 24             	mov    %eax,(%esp)
  1041cc:	e8 9c ea ff ff       	call   102c6d <page_ref>
  1041d1:	83 f8 01             	cmp    $0x1,%eax
  1041d4:	74 24                	je     1041fa <check_boot_pgdir+0x225>
  1041d6:	c7 44 24 0c 42 70 10 	movl   $0x107042,0xc(%esp)
  1041dd:	00 
  1041de:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  1041e5:	00 
  1041e6:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
  1041ed:	00 
  1041ee:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1041f5:	e8 3c c2 ff ff       	call   100436 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1041fa:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  1041ff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104206:	00 
  104207:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10420e:	00 
  10420f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104212:	89 54 24 04          	mov    %edx,0x4(%esp)
  104216:	89 04 24             	mov    %eax,(%esp)
  104219:	e8 d6 f5 ff ff       	call   1037f4 <page_insert>
  10421e:	85 c0                	test   %eax,%eax
  104220:	74 24                	je     104246 <check_boot_pgdir+0x271>
  104222:	c7 44 24 0c 54 70 10 	movl   $0x107054,0xc(%esp)
  104229:	00 
  10422a:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104231:	00 
  104232:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
  104239:	00 
  10423a:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104241:	e8 f0 c1 ff ff       	call   100436 <__panic>
    assert(page_ref(p) == 2);
  104246:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104249:	89 04 24             	mov    %eax,(%esp)
  10424c:	e8 1c ea ff ff       	call   102c6d <page_ref>
  104251:	83 f8 02             	cmp    $0x2,%eax
  104254:	74 24                	je     10427a <check_boot_pgdir+0x2a5>
  104256:	c7 44 24 0c 8b 70 10 	movl   $0x10708b,0xc(%esp)
  10425d:	00 
  10425e:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104265:	00 
  104266:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
  10426d:	00 
  10426e:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104275:	e8 bc c1 ff ff       	call   100436 <__panic>

    const char *str = "ucore: Hello world!!";
  10427a:	c7 45 e8 9c 70 10 00 	movl   $0x10709c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  104281:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104284:	89 44 24 04          	mov    %eax,0x4(%esp)
  104288:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10428f:	e8 be 16 00 00       	call   105952 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  104294:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  10429b:	00 
  10429c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1042a3:	e8 28 17 00 00       	call   1059d0 <strcmp>
  1042a8:	85 c0                	test   %eax,%eax
  1042aa:	74 24                	je     1042d0 <check_boot_pgdir+0x2fb>
  1042ac:	c7 44 24 0c b4 70 10 	movl   $0x1070b4,0xc(%esp)
  1042b3:	00 
  1042b4:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  1042bb:	00 
  1042bc:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
  1042c3:	00 
  1042c4:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  1042cb:	e8 66 c1 ff ff       	call   100436 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1042d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1042d3:	89 04 24             	mov    %eax,(%esp)
  1042d6:	e8 e8 e8 ff ff       	call   102bc3 <page2kva>
  1042db:	05 00 01 00 00       	add    $0x100,%eax
  1042e0:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1042e3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1042ea:	e8 05 16 00 00       	call   1058f4 <strlen>
  1042ef:	85 c0                	test   %eax,%eax
  1042f1:	74 24                	je     104317 <check_boot_pgdir+0x342>
  1042f3:	c7 44 24 0c ec 70 10 	movl   $0x1070ec,0xc(%esp)
  1042fa:	00 
  1042fb:	c7 44 24 08 8d 6c 10 	movl   $0x106c8d,0x8(%esp)
  104302:	00 
  104303:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
  10430a:	00 
  10430b:	c7 04 24 68 6c 10 00 	movl   $0x106c68,(%esp)
  104312:	e8 1f c1 ff ff       	call   100436 <__panic>

    free_page(p);
  104317:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10431e:	00 
  10431f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104322:	89 04 24             	mov    %eax,(%esp)
  104325:	e8 95 eb ff ff       	call   102ebf <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10432a:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10432f:	8b 00                	mov    (%eax),%eax
  104331:	89 04 24             	mov    %eax,(%esp)
  104334:	e8 1c e9 ff ff       	call   102c55 <pde2page>
  104339:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104340:	00 
  104341:	89 04 24             	mov    %eax,(%esp)
  104344:	e8 76 eb ff ff       	call   102ebf <free_pages>
    boot_pgdir[0] = 0;
  104349:	a1 e0 a9 11 00       	mov    0x11a9e0,%eax
  10434e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104354:	c7 04 24 10 71 10 00 	movl   $0x107110,(%esp)
  10435b:	e8 6a bf ff ff       	call   1002ca <cprintf>
}
  104360:	90                   	nop
  104361:	c9                   	leave  
  104362:	c3                   	ret    

00104363 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  104363:	f3 0f 1e fb          	endbr32 
  104367:	55                   	push   %ebp
  104368:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  10436a:	8b 45 08             	mov    0x8(%ebp),%eax
  10436d:	83 e0 04             	and    $0x4,%eax
  104370:	85 c0                	test   %eax,%eax
  104372:	74 04                	je     104378 <perm2str+0x15>
  104374:	b0 75                	mov    $0x75,%al
  104376:	eb 02                	jmp    10437a <perm2str+0x17>
  104378:	b0 2d                	mov    $0x2d,%al
  10437a:	a2 08 df 11 00       	mov    %al,0x11df08
    str[1] = 'r';
  10437f:	c6 05 09 df 11 00 72 	movb   $0x72,0x11df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  104386:	8b 45 08             	mov    0x8(%ebp),%eax
  104389:	83 e0 02             	and    $0x2,%eax
  10438c:	85 c0                	test   %eax,%eax
  10438e:	74 04                	je     104394 <perm2str+0x31>
  104390:	b0 77                	mov    $0x77,%al
  104392:	eb 02                	jmp    104396 <perm2str+0x33>
  104394:	b0 2d                	mov    $0x2d,%al
  104396:	a2 0a df 11 00       	mov    %al,0x11df0a
    str[3] = '\0';
  10439b:	c6 05 0b df 11 00 00 	movb   $0x0,0x11df0b
    return str;
  1043a2:	b8 08 df 11 00       	mov    $0x11df08,%eax
}
  1043a7:	5d                   	pop    %ebp
  1043a8:	c3                   	ret    

001043a9 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1043a9:	f3 0f 1e fb          	endbr32 
  1043ad:	55                   	push   %ebp
  1043ae:	89 e5                	mov    %esp,%ebp
  1043b0:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1043b3:	8b 45 10             	mov    0x10(%ebp),%eax
  1043b6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1043b9:	72 0d                	jb     1043c8 <get_pgtable_items+0x1f>
        return 0;
  1043bb:	b8 00 00 00 00       	mov    $0x0,%eax
  1043c0:	e9 98 00 00 00       	jmp    10445d <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1043c5:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1043c8:	8b 45 10             	mov    0x10(%ebp),%eax
  1043cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1043ce:	73 18                	jae    1043e8 <get_pgtable_items+0x3f>
  1043d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1043d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1043da:	8b 45 14             	mov    0x14(%ebp),%eax
  1043dd:	01 d0                	add    %edx,%eax
  1043df:	8b 00                	mov    (%eax),%eax
  1043e1:	83 e0 01             	and    $0x1,%eax
  1043e4:	85 c0                	test   %eax,%eax
  1043e6:	74 dd                	je     1043c5 <get_pgtable_items+0x1c>
    }
    if (start < right) {
  1043e8:	8b 45 10             	mov    0x10(%ebp),%eax
  1043eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1043ee:	73 68                	jae    104458 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1043f0:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1043f4:	74 08                	je     1043fe <get_pgtable_items+0x55>
            *left_store = start;
  1043f6:	8b 45 18             	mov    0x18(%ebp),%eax
  1043f9:	8b 55 10             	mov    0x10(%ebp),%edx
  1043fc:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1043fe:	8b 45 10             	mov    0x10(%ebp),%eax
  104401:	8d 50 01             	lea    0x1(%eax),%edx
  104404:	89 55 10             	mov    %edx,0x10(%ebp)
  104407:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10440e:	8b 45 14             	mov    0x14(%ebp),%eax
  104411:	01 d0                	add    %edx,%eax
  104413:	8b 00                	mov    (%eax),%eax
  104415:	83 e0 07             	and    $0x7,%eax
  104418:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10441b:	eb 03                	jmp    104420 <get_pgtable_items+0x77>
            start ++;
  10441d:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104420:	8b 45 10             	mov    0x10(%ebp),%eax
  104423:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104426:	73 1d                	jae    104445 <get_pgtable_items+0x9c>
  104428:	8b 45 10             	mov    0x10(%ebp),%eax
  10442b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104432:	8b 45 14             	mov    0x14(%ebp),%eax
  104435:	01 d0                	add    %edx,%eax
  104437:	8b 00                	mov    (%eax),%eax
  104439:	83 e0 07             	and    $0x7,%eax
  10443c:	89 c2                	mov    %eax,%edx
  10443e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104441:	39 c2                	cmp    %eax,%edx
  104443:	74 d8                	je     10441d <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
  104445:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104449:	74 08                	je     104453 <get_pgtable_items+0xaa>
            *right_store = start;
  10444b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10444e:	8b 55 10             	mov    0x10(%ebp),%edx
  104451:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104453:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104456:	eb 05                	jmp    10445d <get_pgtable_items+0xb4>
    }
    return 0;
  104458:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10445d:	c9                   	leave  
  10445e:	c3                   	ret    

0010445f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10445f:	f3 0f 1e fb          	endbr32 
  104463:	55                   	push   %ebp
  104464:	89 e5                	mov    %esp,%ebp
  104466:	57                   	push   %edi
  104467:	56                   	push   %esi
  104468:	53                   	push   %ebx
  104469:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10446c:	c7 04 24 30 71 10 00 	movl   $0x107130,(%esp)
  104473:	e8 52 be ff ff       	call   1002ca <cprintf>
    size_t left, right = 0, perm;
  104478:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10447f:	e9 fa 00 00 00       	jmp    10457e <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104487:	89 04 24             	mov    %eax,(%esp)
  10448a:	e8 d4 fe ff ff       	call   104363 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  10448f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  104492:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104495:	29 d1                	sub    %edx,%ecx
  104497:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104499:	89 d6                	mov    %edx,%esi
  10449b:	c1 e6 16             	shl    $0x16,%esi
  10449e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1044a1:	89 d3                	mov    %edx,%ebx
  1044a3:	c1 e3 16             	shl    $0x16,%ebx
  1044a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1044a9:	89 d1                	mov    %edx,%ecx
  1044ab:	c1 e1 16             	shl    $0x16,%ecx
  1044ae:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1044b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1044b4:	29 d7                	sub    %edx,%edi
  1044b6:	89 fa                	mov    %edi,%edx
  1044b8:	89 44 24 14          	mov    %eax,0x14(%esp)
  1044bc:	89 74 24 10          	mov    %esi,0x10(%esp)
  1044c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1044c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1044c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1044cc:	c7 04 24 61 71 10 00 	movl   $0x107161,(%esp)
  1044d3:	e8 f2 bd ff ff       	call   1002ca <cprintf>
        size_t l, r = left * NPTEENTRY;
  1044d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1044db:	c1 e0 0a             	shl    $0xa,%eax
  1044de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1044e1:	eb 54                	jmp    104537 <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1044e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1044e6:	89 04 24             	mov    %eax,(%esp)
  1044e9:	e8 75 fe ff ff       	call   104363 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1044ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1044f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1044f4:	29 d1                	sub    %edx,%ecx
  1044f6:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1044f8:	89 d6                	mov    %edx,%esi
  1044fa:	c1 e6 0c             	shl    $0xc,%esi
  1044fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104500:	89 d3                	mov    %edx,%ebx
  104502:	c1 e3 0c             	shl    $0xc,%ebx
  104505:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104508:	89 d1                	mov    %edx,%ecx
  10450a:	c1 e1 0c             	shl    $0xc,%ecx
  10450d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104510:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104513:	29 d7                	sub    %edx,%edi
  104515:	89 fa                	mov    %edi,%edx
  104517:	89 44 24 14          	mov    %eax,0x14(%esp)
  10451b:	89 74 24 10          	mov    %esi,0x10(%esp)
  10451f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104527:	89 54 24 04          	mov    %edx,0x4(%esp)
  10452b:	c7 04 24 80 71 10 00 	movl   $0x107180,(%esp)
  104532:	e8 93 bd ff ff       	call   1002ca <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104537:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10453c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10453f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104542:	89 d3                	mov    %edx,%ebx
  104544:	c1 e3 0a             	shl    $0xa,%ebx
  104547:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10454a:	89 d1                	mov    %edx,%ecx
  10454c:	c1 e1 0a             	shl    $0xa,%ecx
  10454f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104552:	89 54 24 14          	mov    %edx,0x14(%esp)
  104556:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104559:	89 54 24 10          	mov    %edx,0x10(%esp)
  10455d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104561:	89 44 24 08          	mov    %eax,0x8(%esp)
  104565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104569:	89 0c 24             	mov    %ecx,(%esp)
  10456c:	e8 38 fe ff ff       	call   1043a9 <get_pgtable_items>
  104571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104578:	0f 85 65 ff ff ff    	jne    1044e3 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10457e:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  104583:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104586:	8d 55 dc             	lea    -0x24(%ebp),%edx
  104589:	89 54 24 14          	mov    %edx,0x14(%esp)
  10458d:	8d 55 e0             	lea    -0x20(%ebp),%edx
  104590:	89 54 24 10          	mov    %edx,0x10(%esp)
  104594:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  104598:	89 44 24 08          	mov    %eax,0x8(%esp)
  10459c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1045a3:	00 
  1045a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1045ab:	e8 f9 fd ff ff       	call   1043a9 <get_pgtable_items>
  1045b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1045b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1045b7:	0f 85 c7 fe ff ff    	jne    104484 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1045bd:	c7 04 24 a4 71 10 00 	movl   $0x1071a4,(%esp)
  1045c4:	e8 01 bd ff ff       	call   1002ca <cprintf>
}
  1045c9:	90                   	nop
  1045ca:	83 c4 4c             	add    $0x4c,%esp
  1045cd:	5b                   	pop    %ebx
  1045ce:	5e                   	pop    %esi
  1045cf:	5f                   	pop    %edi
  1045d0:	5d                   	pop    %ebp
  1045d1:	c3                   	ret    

001045d2 <page2ppn>:
page2ppn(struct Page *page) { 
  1045d2:	55                   	push   %ebp
  1045d3:	89 e5                	mov    %esp,%ebp
    return page - pages;
  1045d5:	a1 78 df 11 00       	mov    0x11df78,%eax
  1045da:	8b 55 08             	mov    0x8(%ebp),%edx
  1045dd:	29 c2                	sub    %eax,%edx
  1045df:	89 d0                	mov    %edx,%eax
  1045e1:	c1 f8 02             	sar    $0x2,%eax
  1045e4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1045ea:	5d                   	pop    %ebp
  1045eb:	c3                   	ret    

001045ec <page2pa>:
page2pa(struct Page *page) {
  1045ec:	55                   	push   %ebp
  1045ed:	89 e5                	mov    %esp,%ebp
  1045ef:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1045f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1045f5:	89 04 24             	mov    %eax,(%esp)
  1045f8:	e8 d5 ff ff ff       	call   1045d2 <page2ppn>
  1045fd:	c1 e0 0c             	shl    $0xc,%eax
}
  104600:	c9                   	leave  
  104601:	c3                   	ret    

00104602 <page_ref>:
page_ref(struct Page *page) {
  104602:	55                   	push   %ebp
  104603:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104605:	8b 45 08             	mov    0x8(%ebp),%eax
  104608:	8b 00                	mov    (%eax),%eax
}
  10460a:	5d                   	pop    %ebp
  10460b:	c3                   	ret    

0010460c <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  10460c:	55                   	push   %ebp
  10460d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10460f:	8b 45 08             	mov    0x8(%ebp),%eax
  104612:	8b 55 0c             	mov    0xc(%ebp),%edx
  104615:	89 10                	mov    %edx,(%eax)
}
  104617:	90                   	nop
  104618:	5d                   	pop    %ebp
  104619:	c3                   	ret    

0010461a <default_init>:
#define nr_free (free_area.nr_free)

// LAB2 EXERCISE 1: 19335286

// REWRITE default_init
static void default_init(void){
  10461a:	f3 0f 1e fb          	endbr32 
  10461e:	55                   	push   %ebp
  10461f:	89 e5                	mov    %esp,%ebp
  104621:	83 ec 10             	sub    $0x10,%esp
  104624:	c7 45 fc 7c df 11 00 	movl   $0x11df7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10462b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10462e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104631:	89 50 04             	mov    %edx,0x4(%eax)
  104634:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104637:	8b 50 04             	mov    0x4(%eax),%edx
  10463a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10463d:	89 10                	mov    %edx,(%eax)
}
  10463f:	90                   	nop
	list_init(&free_list);
	nr_free = 0;
  104640:	c7 05 84 df 11 00 00 	movl   $0x0,0x11df84
  104647:	00 00 00 
}
  10464a:	90                   	nop
  10464b:	c9                   	leave  
  10464c:	c3                   	ret    

0010464d <default_init_memmap>:

// REWRITE default_init_memmap
static void default_init_memmap(struct Page *base, size_t n){
  10464d:	f3 0f 1e fb          	endbr32 
  104651:	55                   	push   %ebp
  104652:	89 e5                	mov    %esp,%ebp
  104654:	83 ec 58             	sub    $0x58,%esp
	assert(n > 0);
  104657:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10465b:	75 24                	jne    104681 <default_init_memmap+0x34>
  10465d:	c7 44 24 0c d8 71 10 	movl   $0x1071d8,0xc(%esp)
  104664:	00 
  104665:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10466c:	00 
  10466d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  104674:	00 
  104675:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10467c:	e8 b5 bd ff ff       	call   100436 <__panic>
	
	// 初始化空闲块首部的页base
	assert(PageReserved(base)); // 检查base标志位
  104681:	8b 45 08             	mov    0x8(%ebp),%eax
  104684:	83 c0 04             	add    $0x4,%eax
  104687:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  10468e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104691:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104694:	8b 55 f0             	mov    -0x10(%ebp),%edx
  104697:	0f a3 10             	bt     %edx,(%eax)
  10469a:	19 c0                	sbb    %eax,%eax
  10469c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  10469f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1046a3:	0f 95 c0             	setne  %al
  1046a6:	0f b6 c0             	movzbl %al,%eax
  1046a9:	85 c0                	test   %eax,%eax
  1046ab:	75 24                	jne    1046d1 <default_init_memmap+0x84>
  1046ad:	c7 44 24 0c 09 72 10 	movl   $0x107209,0xc(%esp)
  1046b4:	00 
  1046b5:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1046bc:	00 
  1046bd:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  1046c4:	00 
  1046c5:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1046cc:	e8 65 bd ff ff       	call   100436 <__panic>
	base->flags = 0;
  1046d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1046d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	base->property = n; // 设置base指向的页为空闲块首部
  1046db:	8b 45 08             	mov    0x8(%ebp),%eax
  1046de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1046e1:	89 50 08             	mov    %edx,0x8(%eax)
	set_page_ref(base, 0); // 置为ref为0
  1046e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1046eb:	00 
  1046ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1046ef:	89 04 24             	mov    %eax,(%esp)
  1046f2:	e8 15 ff ff ff       	call   10460c <set_page_ref>
    SetPageProperty(base); // 设置base指向的页为空闲块首部
  1046f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1046fa:	83 c0 04             	add    $0x4,%eax
  1046fd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  104704:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104707:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10470a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10470d:	0f ab 10             	bts    %edx,(%eax)
}
  104710:	90                   	nop
    
    // 便历、初始化非空闲块首部的页
    struct Page *t = NULL; 
  104711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (t = base + 1; t < base + n; t ++) {
  104718:	8b 45 08             	mov    0x8(%ebp),%eax
  10471b:	83 c0 14             	add    $0x14,%eax
  10471e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104721:	eb 7d                	jmp    1047a0 <default_init_memmap+0x153>
        assert(PageReserved(t)); // 由于函数pmm_init已赋值保留位为0,这里仅需测试保留位是否被正确置0。
  104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104726:	83 c0 04             	add    $0x4,%eax
  104729:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104730:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104733:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104736:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104739:	0f a3 10             	bt     %edx,(%eax)
  10473c:	19 c0                	sbb    %eax,%eax
  10473e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
  104741:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  104745:	0f 95 c0             	setne  %al
  104748:	0f b6 c0             	movzbl %al,%eax
  10474b:	85 c0                	test   %eax,%eax
  10474d:	75 24                	jne    104773 <default_init_memmap+0x126>
  10474f:	c7 44 24 0c 1c 72 10 	movl   $0x10721c,0xc(%esp)
  104756:	00 
  104757:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10475e:	00 
  10475f:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  104766:	00 
  104767:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10476e:	e8 c3 bc ff ff       	call   100436 <__panic>
        t->flags = t->property = 0; // 设置该页不是空闲块首部
  104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104776:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104780:	8b 50 08             	mov    0x8(%eax),%edx
  104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104786:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(t, 0); // 置为ref为0
  104789:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104790:	00 
  104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104794:	89 04 24             	mov    %eax,(%esp)
  104797:	e8 70 fe ff ff       	call   10460c <set_page_ref>
    for (t = base + 1; t < base + n; t ++) {
  10479c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1047a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1047a3:	89 d0                	mov    %edx,%eax
  1047a5:	c1 e0 02             	shl    $0x2,%eax
  1047a8:	01 d0                	add    %edx,%eax
  1047aa:	c1 e0 02             	shl    $0x2,%eax
  1047ad:	89 c2                	mov    %eax,%edx
  1047af:	8b 45 08             	mov    0x8(%ebp),%eax
  1047b2:	01 d0                	add    %edx,%eax
  1047b4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1047b7:	0f 82 66 ff ff ff    	jb     104723 <default_init_memmap+0xd6>
    }
    
    // 更新链表
    nr_free += n; // 更新空闲页的总数
  1047bd:	8b 15 84 df 11 00    	mov    0x11df84,%edx
  1047c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047c6:	01 d0                	add    %edx,%eax
  1047c8:	a3 84 df 11 00       	mov    %eax,0x11df84
    list_add(&free_list, &(base->page_link)); // 将该空闲块插入页表（空闲块）链表中。
  1047cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1047d0:	83 c0 0c             	add    $0xc,%eax
  1047d3:	c7 45 d0 7c df 11 00 	movl   $0x11df7c,-0x30(%ebp)
  1047da:	89 45 cc             	mov    %eax,-0x34(%ebp)
  1047dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1047e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1047e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1047e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1047e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1047ec:	8b 40 04             	mov    0x4(%eax),%eax
  1047ef:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1047f2:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1047f5:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1047f8:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1047fb:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1047fe:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104801:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104804:	89 10                	mov    %edx,(%eax)
  104806:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104809:	8b 10                	mov    (%eax),%edx
  10480b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10480e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104811:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104814:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104817:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10481a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10481d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104820:	89 10                	mov    %edx,(%eax)
}
  104822:	90                   	nop
}
  104823:	90                   	nop
}
  104824:	90                   	nop
}
  104825:	90                   	nop
  104826:	c9                   	leave  
  104827:	c3                   	ret    

00104828 <default_alloc_pages>:

// REWRITE default_alloc_pages
static struct Page* default_alloc_pages(size_t n){
  104828:	f3 0f 1e fb          	endbr32 
  10482c:	55                   	push   %ebp
  10482d:	89 e5                	mov    %esp,%ebp
  10482f:	83 ec 78             	sub    $0x78,%esp
	assert(n > 0);
  104832:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104836:	75 24                	jne    10485c <default_alloc_pages+0x34>
  104838:	c7 44 24 0c d8 71 10 	movl   $0x1071d8,0xc(%esp)
  10483f:	00 
  104840:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104847:	00 
  104848:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
  10484f:	00 
  104850:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104857:	e8 da bb ff ff       	call   100436 <__panic>
	if(n > nr_free){ 
  10485c:	a1 84 df 11 00       	mov    0x11df84,%eax
  104861:	39 45 08             	cmp    %eax,0x8(%ebp)
  104864:	76 0a                	jbe    104870 <default_alloc_pages+0x48>
		return NULL; // 如果请求页数比当前空闲总页数还大，拒绝请求	，但没必要结束程序
  104866:	b8 00 00 00 00       	mov    $0x0,%eax
  10486b:	e9 b6 01 00 00       	jmp    104a26 <default_alloc_pages+0x1fe>
	}
	
	struct Page *p = NULL, *p2 = NULL;
  104870:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  104877:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10487e:	c7 45 e8 7c df 11 00 	movl   $0x11df7c,-0x18(%ebp)
    return listelm->next;
  104885:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104888:	8b 40 04             	mov    0x4(%eax),%eax
	
	list_entry_t *l = list_next(&free_list);
  10488b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ // 从头遍历链表
  10488e:	eb 2b                	jmp    1048bb <default_alloc_pages+0x93>
		 p = le2page(l, page_link);
  104890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104893:	83 e8 0c             	sub    $0xc,%eax
  104896:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104899:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10489c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10489f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1048a2:	8b 40 04             	mov    0x4(%eax),%eax
		 l = list_next(l); 
  1048a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		 if(p->property >= n){ // 找到第一个页数>=n的空闲块
  1048a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048ab:	8b 40 08             	mov    0x8(%eax),%eax
  1048ae:	39 45 08             	cmp    %eax,0x8(%ebp)
  1048b1:	77 08                	ja     1048bb <default_alloc_pages+0x93>
		 	p2 = p; // p2即满足条件的空闲块首部页
  1048b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1048b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		 	break;
  1048b9:	eb 09                	jmp    1048c4 <default_alloc_pages+0x9c>
    while (l != &free_list){ // 从头遍历链表
  1048bb:	81 7d f0 7c df 11 00 	cmpl   $0x11df7c,-0x10(%ebp)
  1048c2:	75 cc                	jne    104890 <default_alloc_pages+0x68>
		 }
	}
	
	if(p2 != NULL){
  1048c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048c8:	0f 84 55 01 00 00    	je     104a23 <default_alloc_pages+0x1fb>
		if(p2->property == n){ // p2空闲块大小刚好等于所需页数
  1048ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048d1:	8b 40 08             	mov    0x8(%eax),%eax
  1048d4:	39 45 08             	cmp    %eax,0x8(%ebp)
  1048d7:	75 58                	jne    104931 <default_alloc_pages+0x109>
			nr_free -= n;
  1048d9:	a1 84 df 11 00       	mov    0x11df84,%eax
  1048de:	2b 45 08             	sub    0x8(%ebp),%eax
  1048e1:	a3 84 df 11 00       	mov    %eax,0x11df84
			ClearPageProperty(p2);
  1048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048e9:	83 c0 04             	add    $0x4,%eax
  1048ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1048f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1048f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1048f9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1048fc:	0f b3 10             	btr    %edx,(%eax)
}
  1048ff:	90                   	nop
			list_del(&(p2->page_link)); // 将p2从链表中删除
  104900:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104903:	83 c0 0c             	add    $0xc,%eax
  104906:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
  104909:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10490c:	8b 40 04             	mov    0x4(%eax),%eax
  10490f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104912:	8b 12                	mov    (%edx),%edx
  104914:	89 55 dc             	mov    %edx,-0x24(%ebp)
  104917:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10491a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10491d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104920:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104923:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104926:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104929:	89 10                	mov    %edx,(%eax)
}
  10492b:	90                   	nop
}
  10492c:	e9 f2 00 00 00       	jmp    104a23 <default_alloc_pages+0x1fb>
		}
		else if(p2->property > n){ // p2空闲块大小大于所需页数
  104931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104934:	8b 40 08             	mov    0x8(%eax),%eax
  104937:	39 45 08             	cmp    %eax,0x8(%ebp)
  10493a:	0f 83 e3 00 00 00    	jae    104a23 <default_alloc_pages+0x1fb>
			p = p2 + n; // 剩下的页组合在一起变成p，修改p的属性，重新加入链表
  104940:	8b 55 08             	mov    0x8(%ebp),%edx
  104943:	89 d0                	mov    %edx,%eax
  104945:	c1 e0 02             	shl    $0x2,%eax
  104948:	01 d0                	add    %edx,%eax
  10494a:	c1 e0 02             	shl    $0x2,%eax
  10494d:	89 c2                	mov    %eax,%edx
  10494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104952:	01 d0                	add    %edx,%eax
  104954:	89 45 ec             	mov    %eax,-0x14(%ebp)
			p->property = p2->property - n;
  104957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10495a:	8b 40 08             	mov    0x8(%eax),%eax
  10495d:	2b 45 08             	sub    0x8(%ebp),%eax
  104960:	89 c2                	mov    %eax,%edx
  104962:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104965:	89 50 08             	mov    %edx,0x8(%eax)
			SetPageProperty(p);
  104968:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10496b:	83 c0 04             	add    $0x4,%eax
  10496e:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  104975:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104978:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10497b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10497e:	0f ab 10             	bts    %edx,(%eax)
}
  104981:	90                   	nop
			nr_free -= n;
  104982:	a1 84 df 11 00       	mov    0x11df84,%eax
  104987:	2b 45 08             	sub    0x8(%ebp),%eax
  10498a:	a3 84 df 11 00       	mov    %eax,0x11df84
			ClearPageProperty(p2);
  10498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104992:	83 c0 04             	add    $0x4,%eax
  104995:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  10499c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  10499f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1049a2:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1049a5:	0f b3 10             	btr    %edx,(%eax)
}
  1049a8:	90                   	nop
			list_add_after(&(p2->page_link), &(p->page_link));
  1049a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049ac:	83 c0 0c             	add    $0xc,%eax
  1049af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1049b2:	83 c2 0c             	add    $0xc,%edx
  1049b5:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1049b8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_add(elm, listelm, listelm->next);
  1049bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1049be:	8b 40 04             	mov    0x4(%eax),%eax
  1049c1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1049c4:	89 55 b8             	mov    %edx,-0x48(%ebp)
  1049c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1049ca:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  1049cd:	89 45 b0             	mov    %eax,-0x50(%ebp)
    prev->next = next->prev = elm;
  1049d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1049d3:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1049d6:	89 10                	mov    %edx,(%eax)
  1049d8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1049db:	8b 10                	mov    (%eax),%edx
  1049dd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1049e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1049e3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1049e6:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1049e9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1049ec:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1049ef:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  1049f2:	89 10                	mov    %edx,(%eax)
}
  1049f4:	90                   	nop
}
  1049f5:	90                   	nop
			list_del(&(p2->page_link)); // 将p2从链表中删除
  1049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049f9:	83 c0 0c             	add    $0xc,%eax
  1049fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
  1049ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104a02:	8b 40 04             	mov    0x4(%eax),%eax
  104a05:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104a08:	8b 12                	mov    (%edx),%edx
  104a0a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  104a0d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
  104a10:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104a13:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104a16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104a19:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104a1c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104a1f:	89 10                	mov    %edx,(%eax)
}
  104a21:	90                   	nop
}
  104a22:	90                   	nop
			//list_add(&free_list, &(p->page_link)); // 将p加入链表
		}
	}
	return p2;
  104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104a26:	c9                   	leave  
  104a27:	c3                   	ret    

00104a28 <default_free_pages>:

// REWRITE default_free_pages
static void default_free_pages(struct Page *base, size_t n){ // base~base+n 是归还给空闲链表的页
  104a28:	f3 0f 1e fb          	endbr32 
  104a2c:	55                   	push   %ebp
  104a2d:	89 e5                	mov    %esp,%ebp
  104a2f:	81 ec 98 00 00 00    	sub    $0x98,%esp
	assert(n > 0);
  104a35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104a39:	75 24                	jne    104a5f <default_free_pages+0x37>
  104a3b:	c7 44 24 0c d8 71 10 	movl   $0x1071d8,0xc(%esp)
  104a42:	00 
  104a43:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104a4a:	00 
  104a4b:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
  104a52:	00 
  104a53:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104a5a:	e8 d7 b9 ff ff       	call   100436 <__panic>
	// 清空内容
	for(struct Page *i = base; i < base + n; i++){
  104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  104a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104a65:	e9 c1 00 00 00       	jmp    104b2b <default_free_pages+0x103>
		assert(!PageReserved(i)); 
  104a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a6d:	83 c0 04             	add    $0x4,%eax
  104a70:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104a7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104a80:	0f a3 10             	bt     %edx,(%eax)
  104a83:	19 c0                	sbb    %eax,%eax
  104a85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  104a88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  104a8c:	0f 95 c0             	setne  %al
  104a8f:	0f b6 c0             	movzbl %al,%eax
  104a92:	85 c0                	test   %eax,%eax
  104a94:	74 24                	je     104aba <default_free_pages+0x92>
  104a96:	c7 44 24 0c 2c 72 10 	movl   $0x10722c,0xc(%esp)
  104a9d:	00 
  104a9e:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104aa5:	00 
  104aa6:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
  104aad:	00 
  104aae:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104ab5:	e8 7c b9 ff ff       	call   100436 <__panic>
		assert(!PageProperty(i));
  104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104abd:	83 c0 04             	add    $0x4,%eax
  104ac0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  104ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104acd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104ad0:	0f a3 10             	bt     %edx,(%eax)
  104ad3:	19 c0                	sbb    %eax,%eax
  104ad5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
  104ad8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  104adc:	0f 95 c0             	setne  %al
  104adf:	0f b6 c0             	movzbl %al,%eax
  104ae2:	85 c0                	test   %eax,%eax
  104ae4:	74 24                	je     104b0a <default_free_pages+0xe2>
  104ae6:	c7 44 24 0c 3d 72 10 	movl   $0x10723d,0xc(%esp)
  104aed:	00 
  104aee:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104af5:	00 
  104af6:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  104afd:	00 
  104afe:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104b05:	e8 2c b9 ff ff       	call   100436 <__panic>
		i->flags = 0;
  104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b0d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		set_page_ref(i, 0);
  104b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b1b:	00 
  104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b1f:	89 04 24             	mov    %eax,(%esp)
  104b22:	e8 e5 fa ff ff       	call   10460c <set_page_ref>
	for(struct Page *i = base; i < base + n; i++){
  104b27:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  104b2e:	89 d0                	mov    %edx,%eax
  104b30:	c1 e0 02             	shl    $0x2,%eax
  104b33:	01 d0                	add    %edx,%eax
  104b35:	c1 e0 02             	shl    $0x2,%eax
  104b38:	89 c2                	mov    %eax,%edx
  104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  104b3d:	01 d0                	add    %edx,%eax
  104b3f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104b42:	0f 82 22 ff ff ff    	jb     104a6a <default_free_pages+0x42>
	}
	
	// 四种情况：两个块合并（前后和后前）、三个块合并、单独成块
	struct Page *p = NULL;
  104b48:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	nr_free += n;
  104b4f:	8b 15 84 df 11 00    	mov    0x11df84,%edx
  104b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  104b58:	01 d0                	add    %edx,%eax
  104b5a:	a3 84 df 11 00       	mov    %eax,0x11df84
	SetPageProperty(base);
  104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  104b62:	83 c0 04             	add    $0x4,%eax
  104b65:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  104b6c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104b6f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104b72:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104b75:	0f ab 10             	bts    %edx,(%eax)
}
  104b78:	90                   	nop
	base->property = n;
  104b79:	8b 45 08             	mov    0x8(%ebp),%eax
  104b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  104b7f:	89 50 08             	mov    %edx,0x8(%eax)
  104b82:	c7 45 d0 7c df 11 00 	movl   $0x11df7c,-0x30(%ebp)
    return listelm->next;
  104b89:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104b8c:	8b 40 04             	mov    0x4(%eax),%eax

    list_entry_t *l = list_next(&free_list);
  104b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list) { // 遍历，合并
  104b92:	e9 0e 01 00 00       	jmp    104ca5 <default_free_pages+0x27d>
        p = le2page(l, page_link); 
  104b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b9a:	83 e8 0c             	sub    $0xc,%eax
  104b9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ba3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  104ba6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104ba9:	8b 40 04             	mov    0x4(%eax),%eax
        l = list_next(l);       
  104bac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) { // base 合并 p
  104baf:	8b 45 08             	mov    0x8(%ebp),%eax
  104bb2:	8b 50 08             	mov    0x8(%eax),%edx
  104bb5:	89 d0                	mov    %edx,%eax
  104bb7:	c1 e0 02             	shl    $0x2,%eax
  104bba:	01 d0                	add    %edx,%eax
  104bbc:	c1 e0 02             	shl    $0x2,%eax
  104bbf:	89 c2                	mov    %eax,%edx
  104bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  104bc4:	01 d0                	add    %edx,%eax
  104bc6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104bc9:	75 5d                	jne    104c28 <default_free_pages+0x200>
        	ClearPageProperty(p);
  104bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bce:	83 c0 04             	add    $0x4,%eax
  104bd1:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
  104bd8:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104bdb:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104bde:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104be1:	0f b3 10             	btr    %edx,(%eax)
}
  104be4:	90                   	nop
            base->property += p->property;
  104be5:	8b 45 08             	mov    0x8(%ebp),%eax
  104be8:	8b 50 08             	mov    0x8(%eax),%edx
  104beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bee:	8b 40 08             	mov    0x8(%eax),%eax
  104bf1:	01 c2                	add    %eax,%edx
  104bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  104bf6:	89 50 08             	mov    %edx,0x8(%eax)
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
  104bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bfc:	83 c0 0c             	add    $0xc,%eax
  104bff:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
  104c02:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104c05:	8b 40 04             	mov    0x4(%eax),%eax
  104c08:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104c0b:	8b 12                	mov    (%edx),%edx
  104c0d:	89 55 bc             	mov    %edx,-0x44(%ebp)
  104c10:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
  104c13:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104c16:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104c19:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104c1c:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104c1f:	8b 55 bc             	mov    -0x44(%ebp),%edx
  104c22:	89 10                	mov    %edx,(%eax)
}
  104c24:	90                   	nop
}
  104c25:	90                   	nop
  104c26:	eb 7d                	jmp    104ca5 <default_free_pages+0x27d>
        }
        else if (p + p->property == base) { // p 合并 base
  104c28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c2b:	8b 50 08             	mov    0x8(%eax),%edx
  104c2e:	89 d0                	mov    %edx,%eax
  104c30:	c1 e0 02             	shl    $0x2,%eax
  104c33:	01 d0                	add    %edx,%eax
  104c35:	c1 e0 02             	shl    $0x2,%eax
  104c38:	89 c2                	mov    %eax,%edx
  104c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c3d:	01 d0                	add    %edx,%eax
  104c3f:	39 45 08             	cmp    %eax,0x8(%ebp)
  104c42:	75 61                	jne    104ca5 <default_free_pages+0x27d>
        	ClearPageProperty(base);
  104c44:	8b 45 08             	mov    0x8(%ebp),%eax
  104c47:	83 c0 04             	add    $0x4,%eax
  104c4a:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  104c51:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104c54:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104c57:	8b 55 a0             	mov    -0x60(%ebp),%edx
  104c5a:	0f b3 10             	btr    %edx,(%eax)
}
  104c5d:	90                   	nop
            p->property += base->property;
  104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c61:	8b 50 08             	mov    0x8(%eax),%edx
  104c64:	8b 45 08             	mov    0x8(%ebp),%eax
  104c67:	8b 40 08             	mov    0x8(%eax),%eax
  104c6a:	01 c2                	add    %eax,%edx
  104c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c6f:	89 50 08             	mov    %edx,0x8(%eax)
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
  104c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c75:	83 c0 0c             	add    $0xc,%eax
  104c78:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
  104c7b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104c7e:	8b 40 04             	mov    0x4(%eax),%eax
  104c81:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104c84:	8b 12                	mov    (%edx),%edx
  104c86:	89 55 a8             	mov    %edx,-0x58(%ebp)
  104c89:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
  104c8c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104c8f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104c92:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104c95:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104c98:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104c9b:	89 10                	mov    %edx,(%eax)
}
  104c9d:	90                   	nop
}
  104c9e:	90                   	nop
            base = p; // 更新 base 为 p
  104c9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ca2:	89 45 08             	mov    %eax,0x8(%ebp)
    while (l != &free_list) { // 遍历，合并
  104ca5:	81 7d f0 7c df 11 00 	cmpl   $0x11df7c,-0x10(%ebp)
  104cac:	0f 85 e5 fe ff ff    	jne    104b97 <default_free_pages+0x16f>
  104cb2:	c7 45 98 7c df 11 00 	movl   $0x11df7c,-0x68(%ebp)
    return listelm->next;
  104cb9:	8b 45 98             	mov    -0x68(%ebp),%eax
  104cbc:	8b 40 04             	mov    0x4(%eax),%eax
        }
    }
    
    l = list_next(&free_list);
  104cbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ //遍历，找位置按序插入
  104cc2:	eb 34                	jmp    104cf8 <default_free_pages+0x2d0>
        p = le2page(l, page_link);
  104cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cc7:	83 e8 0c             	sub    $0xc,%eax
  104cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (base + base->property < p){
  104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  104cd0:	8b 50 08             	mov    0x8(%eax),%edx
  104cd3:	89 d0                	mov    %edx,%eax
  104cd5:	c1 e0 02             	shl    $0x2,%eax
  104cd8:	01 d0                	add    %edx,%eax
  104cda:	c1 e0 02             	shl    $0x2,%eax
  104cdd:	89 c2                	mov    %eax,%edx
  104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  104ce2:	01 d0                	add    %edx,%eax
  104ce4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104ce7:	77 1a                	ja     104d03 <default_free_pages+0x2db>
  104ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cec:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104cef:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104cf2:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        l = list_next(l);   
  104cf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ //遍历，找位置按序插入
  104cf8:	81 7d f0 7c df 11 00 	cmpl   $0x11df7c,-0x10(%ebp)
  104cff:	75 c3                	jne    104cc4 <default_free_pages+0x29c>
  104d01:	eb 01                	jmp    104d04 <default_free_pages+0x2dc>
            break;
  104d03:	90                   	nop
    }
    list_add_before(l, &(base->page_link)); // 若free_list为空可直接插入base
  104d04:	8b 45 08             	mov    0x8(%ebp),%eax
  104d07:	8d 50 0c             	lea    0xc(%eax),%edx
  104d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d0d:	89 45 90             	mov    %eax,-0x70(%ebp)
  104d10:	89 55 8c             	mov    %edx,-0x74(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104d13:	8b 45 90             	mov    -0x70(%ebp),%eax
  104d16:	8b 00                	mov    (%eax),%eax
  104d18:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104d1b:	89 55 88             	mov    %edx,-0x78(%ebp)
  104d1e:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104d21:	8b 45 90             	mov    -0x70(%ebp),%eax
  104d24:	89 45 80             	mov    %eax,-0x80(%ebp)
    prev->next = next->prev = elm;
  104d27:	8b 45 80             	mov    -0x80(%ebp),%eax
  104d2a:	8b 55 88             	mov    -0x78(%ebp),%edx
  104d2d:	89 10                	mov    %edx,(%eax)
  104d2f:	8b 45 80             	mov    -0x80(%ebp),%eax
  104d32:	8b 10                	mov    (%eax),%edx
  104d34:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104d37:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104d3a:	8b 45 88             	mov    -0x78(%ebp),%eax
  104d3d:	8b 55 80             	mov    -0x80(%ebp),%edx
  104d40:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104d43:	8b 45 88             	mov    -0x78(%ebp),%eax
  104d46:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104d49:	89 10                	mov    %edx,(%eax)
}
  104d4b:	90                   	nop
}
  104d4c:	90                   	nop
}
  104d4d:	90                   	nop
  104d4e:	c9                   	leave  
  104d4f:	c3                   	ret    

00104d50 <default_nr_free_pages>:
    list_add(&free_list, &(base->page_link)); //不对，插入过程要保证有序，不能直接插入链表头
}
*/

static size_t
default_nr_free_pages(void) {
  104d50:	f3 0f 1e fb          	endbr32 
  104d54:	55                   	push   %ebp
  104d55:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104d57:	a1 84 df 11 00       	mov    0x11df84,%eax
}
  104d5c:	5d                   	pop    %ebp
  104d5d:	c3                   	ret    

00104d5e <basic_check>:

static void
basic_check(void) {
  104d5e:	f3 0f 1e fb          	endbr32 
  104d62:	55                   	push   %ebp
  104d63:	89 e5                	mov    %esp,%ebp
  104d65:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d78:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104d7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d82:	e8 fc e0 ff ff       	call   102e83 <alloc_pages>
  104d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104d8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104d8e:	75 24                	jne    104db4 <basic_check+0x56>
  104d90:	c7 44 24 0c 4e 72 10 	movl   $0x10724e,0xc(%esp)
  104d97:	00 
  104d98:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104d9f:	00 
  104da0:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
  104da7:	00 
  104da8:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104daf:	e8 82 b6 ff ff       	call   100436 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104db4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104dbb:	e8 c3 e0 ff ff       	call   102e83 <alloc_pages>
  104dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104dc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104dc7:	75 24                	jne    104ded <basic_check+0x8f>
  104dc9:	c7 44 24 0c 6a 72 10 	movl   $0x10726a,0xc(%esp)
  104dd0:	00 
  104dd1:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104dd8:	00 
  104dd9:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  104de0:	00 
  104de1:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104de8:	e8 49 b6 ff ff       	call   100436 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104ded:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104df4:	e8 8a e0 ff ff       	call   102e83 <alloc_pages>
  104df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104dfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104e00:	75 24                	jne    104e26 <basic_check+0xc8>
  104e02:	c7 44 24 0c 86 72 10 	movl   $0x107286,0xc(%esp)
  104e09:	00 
  104e0a:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104e11:	00 
  104e12:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  104e19:	00 
  104e1a:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104e21:	e8 10 b6 ff ff       	call   100436 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e29:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104e2c:	74 10                	je     104e3e <basic_check+0xe0>
  104e2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104e34:	74 08                	je     104e3e <basic_check+0xe0>
  104e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104e3c:	75 24                	jne    104e62 <basic_check+0x104>
  104e3e:	c7 44 24 0c a4 72 10 	movl   $0x1072a4,0xc(%esp)
  104e45:	00 
  104e46:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104e4d:	00 
  104e4e:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  104e55:	00 
  104e56:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104e5d:	e8 d4 b5 ff ff       	call   100436 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e65:	89 04 24             	mov    %eax,(%esp)
  104e68:	e8 95 f7 ff ff       	call   104602 <page_ref>
  104e6d:	85 c0                	test   %eax,%eax
  104e6f:	75 1e                	jne    104e8f <basic_check+0x131>
  104e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e74:	89 04 24             	mov    %eax,(%esp)
  104e77:	e8 86 f7 ff ff       	call   104602 <page_ref>
  104e7c:	85 c0                	test   %eax,%eax
  104e7e:	75 0f                	jne    104e8f <basic_check+0x131>
  104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e83:	89 04 24             	mov    %eax,(%esp)
  104e86:	e8 77 f7 ff ff       	call   104602 <page_ref>
  104e8b:	85 c0                	test   %eax,%eax
  104e8d:	74 24                	je     104eb3 <basic_check+0x155>
  104e8f:	c7 44 24 0c c8 72 10 	movl   $0x1072c8,0xc(%esp)
  104e96:	00 
  104e97:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104e9e:	00 
  104e9f:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
  104ea6:	00 
  104ea7:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104eae:	e8 83 b5 ff ff       	call   100436 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104eb6:	89 04 24             	mov    %eax,(%esp)
  104eb9:	e8 2e f7 ff ff       	call   1045ec <page2pa>
  104ebe:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104ec4:	c1 e2 0c             	shl    $0xc,%edx
  104ec7:	39 d0                	cmp    %edx,%eax
  104ec9:	72 24                	jb     104eef <basic_check+0x191>
  104ecb:	c7 44 24 0c 04 73 10 	movl   $0x107304,0xc(%esp)
  104ed2:	00 
  104ed3:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104eda:	00 
  104edb:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  104ee2:	00 
  104ee3:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104eea:	e8 47 b5 ff ff       	call   100436 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ef2:	89 04 24             	mov    %eax,(%esp)
  104ef5:	e8 f2 f6 ff ff       	call   1045ec <page2pa>
  104efa:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104f00:	c1 e2 0c             	shl    $0xc,%edx
  104f03:	39 d0                	cmp    %edx,%eax
  104f05:	72 24                	jb     104f2b <basic_check+0x1cd>
  104f07:	c7 44 24 0c 21 73 10 	movl   $0x107321,0xc(%esp)
  104f0e:	00 
  104f0f:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104f16:	00 
  104f17:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  104f1e:	00 
  104f1f:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104f26:	e8 0b b5 ff ff       	call   100436 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f2e:	89 04 24             	mov    %eax,(%esp)
  104f31:	e8 b6 f6 ff ff       	call   1045ec <page2pa>
  104f36:	8b 15 80 de 11 00    	mov    0x11de80,%edx
  104f3c:	c1 e2 0c             	shl    $0xc,%edx
  104f3f:	39 d0                	cmp    %edx,%eax
  104f41:	72 24                	jb     104f67 <basic_check+0x209>
  104f43:	c7 44 24 0c 3e 73 10 	movl   $0x10733e,0xc(%esp)
  104f4a:	00 
  104f4b:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104f52:	00 
  104f53:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  104f5a:	00 
  104f5b:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104f62:	e8 cf b4 ff ff       	call   100436 <__panic>

    list_entry_t free_list_store = free_list;
  104f67:	a1 7c df 11 00       	mov    0x11df7c,%eax
  104f6c:	8b 15 80 df 11 00    	mov    0x11df80,%edx
  104f72:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104f75:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104f78:	c7 45 dc 7c df 11 00 	movl   $0x11df7c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104f7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f82:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104f85:	89 50 04             	mov    %edx,0x4(%eax)
  104f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f8b:	8b 50 04             	mov    0x4(%eax),%edx
  104f8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104f91:	89 10                	mov    %edx,(%eax)
}
  104f93:	90                   	nop
  104f94:	c7 45 e0 7c df 11 00 	movl   $0x11df7c,-0x20(%ebp)
    return list->next == list;
  104f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104f9e:	8b 40 04             	mov    0x4(%eax),%eax
  104fa1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104fa4:	0f 94 c0             	sete   %al
  104fa7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104faa:	85 c0                	test   %eax,%eax
  104fac:	75 24                	jne    104fd2 <basic_check+0x274>
  104fae:	c7 44 24 0c 5b 73 10 	movl   $0x10735b,0xc(%esp)
  104fb5:	00 
  104fb6:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  104fbd:	00 
  104fbe:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  104fc5:	00 
  104fc6:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  104fcd:	e8 64 b4 ff ff       	call   100436 <__panic>

    unsigned int nr_free_store = nr_free;
  104fd2:	a1 84 df 11 00       	mov    0x11df84,%eax
  104fd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104fda:	c7 05 84 df 11 00 00 	movl   $0x0,0x11df84
  104fe1:	00 00 00 

    assert(alloc_page() == NULL);
  104fe4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104feb:	e8 93 de ff ff       	call   102e83 <alloc_pages>
  104ff0:	85 c0                	test   %eax,%eax
  104ff2:	74 24                	je     105018 <basic_check+0x2ba>
  104ff4:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  104ffb:	00 
  104ffc:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105003:	00 
  105004:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  10500b:	00 
  10500c:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105013:	e8 1e b4 ff ff       	call   100436 <__panic>

    free_page(p0);
  105018:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10501f:	00 
  105020:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105023:	89 04 24             	mov    %eax,(%esp)
  105026:	e8 94 de ff ff       	call   102ebf <free_pages>
    free_page(p1);
  10502b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105032:	00 
  105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105036:	89 04 24             	mov    %eax,(%esp)
  105039:	e8 81 de ff ff       	call   102ebf <free_pages>
    free_page(p2);
  10503e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105045:	00 
  105046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105049:	89 04 24             	mov    %eax,(%esp)
  10504c:	e8 6e de ff ff       	call   102ebf <free_pages>
    assert(nr_free == 3);
  105051:	a1 84 df 11 00       	mov    0x11df84,%eax
  105056:	83 f8 03             	cmp    $0x3,%eax
  105059:	74 24                	je     10507f <basic_check+0x321>
  10505b:	c7 44 24 0c 87 73 10 	movl   $0x107387,0xc(%esp)
  105062:	00 
  105063:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10506a:	00 
  10506b:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
  105072:	00 
  105073:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10507a:	e8 b7 b3 ff ff       	call   100436 <__panic>

    assert((p0 = alloc_page()) != NULL);
  10507f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105086:	e8 f8 dd ff ff       	call   102e83 <alloc_pages>
  10508b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10508e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  105092:	75 24                	jne    1050b8 <basic_check+0x35a>
  105094:	c7 44 24 0c 4e 72 10 	movl   $0x10724e,0xc(%esp)
  10509b:	00 
  10509c:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1050a3:	00 
  1050a4:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
  1050ab:	00 
  1050ac:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1050b3:	e8 7e b3 ff ff       	call   100436 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1050b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050bf:	e8 bf dd ff ff       	call   102e83 <alloc_pages>
  1050c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1050c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1050cb:	75 24                	jne    1050f1 <basic_check+0x393>
  1050cd:	c7 44 24 0c 6a 72 10 	movl   $0x10726a,0xc(%esp)
  1050d4:	00 
  1050d5:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1050dc:	00 
  1050dd:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
  1050e4:	00 
  1050e5:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1050ec:	e8 45 b3 ff ff       	call   100436 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1050f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050f8:	e8 86 dd ff ff       	call   102e83 <alloc_pages>
  1050fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105100:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105104:	75 24                	jne    10512a <basic_check+0x3cc>
  105106:	c7 44 24 0c 86 72 10 	movl   $0x107286,0xc(%esp)
  10510d:	00 
  10510e:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105115:	00 
  105116:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  10511d:	00 
  10511e:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105125:	e8 0c b3 ff ff       	call   100436 <__panic>

    assert(alloc_page() == NULL);
  10512a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105131:	e8 4d dd ff ff       	call   102e83 <alloc_pages>
  105136:	85 c0                	test   %eax,%eax
  105138:	74 24                	je     10515e <basic_check+0x400>
  10513a:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  105141:	00 
  105142:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105149:	00 
  10514a:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  105151:	00 
  105152:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105159:	e8 d8 b2 ff ff       	call   100436 <__panic>

    free_page(p0);
  10515e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105165:	00 
  105166:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105169:	89 04 24             	mov    %eax,(%esp)
  10516c:	e8 4e dd ff ff       	call   102ebf <free_pages>
  105171:	c7 45 d8 7c df 11 00 	movl   $0x11df7c,-0x28(%ebp)
  105178:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10517b:	8b 40 04             	mov    0x4(%eax),%eax
  10517e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  105181:	0f 94 c0             	sete   %al
  105184:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  105187:	85 c0                	test   %eax,%eax
  105189:	74 24                	je     1051af <basic_check+0x451>
  10518b:	c7 44 24 0c 94 73 10 	movl   $0x107394,0xc(%esp)
  105192:	00 
  105193:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10519a:	00 
  10519b:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
  1051a2:	00 
  1051a3:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1051aa:	e8 87 b2 ff ff       	call   100436 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1051af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051b6:	e8 c8 dc ff ff       	call   102e83 <alloc_pages>
  1051bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1051be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1051c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1051c4:	74 24                	je     1051ea <basic_check+0x48c>
  1051c6:	c7 44 24 0c ac 73 10 	movl   $0x1073ac,0xc(%esp)
  1051cd:	00 
  1051ce:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1051d5:	00 
  1051d6:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
  1051dd:	00 
  1051de:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1051e5:	e8 4c b2 ff ff       	call   100436 <__panic>
    assert(alloc_page() == NULL);
  1051ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051f1:	e8 8d dc ff ff       	call   102e83 <alloc_pages>
  1051f6:	85 c0                	test   %eax,%eax
  1051f8:	74 24                	je     10521e <basic_check+0x4c0>
  1051fa:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  105201:	00 
  105202:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105209:	00 
  10520a:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
  105211:	00 
  105212:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105219:	e8 18 b2 ff ff       	call   100436 <__panic>

    assert(nr_free == 0);
  10521e:	a1 84 df 11 00       	mov    0x11df84,%eax
  105223:	85 c0                	test   %eax,%eax
  105225:	74 24                	je     10524b <basic_check+0x4ed>
  105227:	c7 44 24 0c c5 73 10 	movl   $0x1073c5,0xc(%esp)
  10522e:	00 
  10522f:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105236:	00 
  105237:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
  10523e:	00 
  10523f:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105246:	e8 eb b1 ff ff       	call   100436 <__panic>
    free_list = free_list_store;
  10524b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10524e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105251:	a3 7c df 11 00       	mov    %eax,0x11df7c
  105256:	89 15 80 df 11 00    	mov    %edx,0x11df80
    nr_free = nr_free_store;
  10525c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10525f:	a3 84 df 11 00       	mov    %eax,0x11df84

    free_page(p);
  105264:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10526b:	00 
  10526c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10526f:	89 04 24             	mov    %eax,(%esp)
  105272:	e8 48 dc ff ff       	call   102ebf <free_pages>
    free_page(p1);
  105277:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10527e:	00 
  10527f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105282:	89 04 24             	mov    %eax,(%esp)
  105285:	e8 35 dc ff ff       	call   102ebf <free_pages>
    free_page(p2);
  10528a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105291:	00 
  105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105295:	89 04 24             	mov    %eax,(%esp)
  105298:	e8 22 dc ff ff       	call   102ebf <free_pages>
}
  10529d:	90                   	nop
  10529e:	c9                   	leave  
  10529f:	c3                   	ret    

001052a0 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1052a0:	f3 0f 1e fb          	endbr32 
  1052a4:	55                   	push   %ebp
  1052a5:	89 e5                	mov    %esp,%ebp
  1052a7:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  1052ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1052b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1052bb:	c7 45 ec 7c df 11 00 	movl   $0x11df7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1052c2:	eb 6a                	jmp    10532e <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
  1052c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052c7:	83 e8 0c             	sub    $0xc,%eax
  1052ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  1052cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1052d0:	83 c0 04             	add    $0x4,%eax
  1052d3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1052da:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1052dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1052e0:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1052e3:	0f a3 10             	bt     %edx,(%eax)
  1052e6:	19 c0                	sbb    %eax,%eax
  1052e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1052eb:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1052ef:	0f 95 c0             	setne  %al
  1052f2:	0f b6 c0             	movzbl %al,%eax
  1052f5:	85 c0                	test   %eax,%eax
  1052f7:	75 24                	jne    10531d <default_check+0x7d>
  1052f9:	c7 44 24 0c d2 73 10 	movl   $0x1073d2,0xc(%esp)
  105300:	00 
  105301:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105308:	00 
  105309:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
  105310:	00 
  105311:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105318:	e8 19 b1 ff ff       	call   100436 <__panic>
        count ++, total += p->property;
  10531d:	ff 45 f4             	incl   -0xc(%ebp)
  105320:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105323:	8b 50 08             	mov    0x8(%eax),%edx
  105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105329:	01 d0                	add    %edx,%eax
  10532b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10532e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105331:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  105334:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105337:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10533a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10533d:	81 7d ec 7c df 11 00 	cmpl   $0x11df7c,-0x14(%ebp)
  105344:	0f 85 7a ff ff ff    	jne    1052c4 <default_check+0x24>
    }
    assert(total == nr_free_pages());
  10534a:	e8 a7 db ff ff       	call   102ef6 <nr_free_pages>
  10534f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105352:	39 d0                	cmp    %edx,%eax
  105354:	74 24                	je     10537a <default_check+0xda>
  105356:	c7 44 24 0c e2 73 10 	movl   $0x1073e2,0xc(%esp)
  10535d:	00 
  10535e:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105365:	00 
  105366:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  10536d:	00 
  10536e:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105375:	e8 bc b0 ff ff       	call   100436 <__panic>

    basic_check();
  10537a:	e8 df f9 ff ff       	call   104d5e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  10537f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105386:	e8 f8 da ff ff       	call   102e83 <alloc_pages>
  10538b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  10538e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105392:	75 24                	jne    1053b8 <default_check+0x118>
  105394:	c7 44 24 0c fb 73 10 	movl   $0x1073fb,0xc(%esp)
  10539b:	00 
  10539c:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1053a3:	00 
  1053a4:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
  1053ab:	00 
  1053ac:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1053b3:	e8 7e b0 ff ff       	call   100436 <__panic>
    assert(!PageProperty(p0));
  1053b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053bb:	83 c0 04             	add    $0x4,%eax
  1053be:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  1053c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1053c8:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1053cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1053ce:	0f a3 10             	bt     %edx,(%eax)
  1053d1:	19 c0                	sbb    %eax,%eax
  1053d3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  1053d6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1053da:	0f 95 c0             	setne  %al
  1053dd:	0f b6 c0             	movzbl %al,%eax
  1053e0:	85 c0                	test   %eax,%eax
  1053e2:	74 24                	je     105408 <default_check+0x168>
  1053e4:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  1053eb:	00 
  1053ec:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1053f3:	00 
  1053f4:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
  1053fb:	00 
  1053fc:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105403:	e8 2e b0 ff ff       	call   100436 <__panic>

    list_entry_t free_list_store = free_list;
  105408:	a1 7c df 11 00       	mov    0x11df7c,%eax
  10540d:	8b 15 80 df 11 00    	mov    0x11df80,%edx
  105413:	89 45 80             	mov    %eax,-0x80(%ebp)
  105416:	89 55 84             	mov    %edx,-0x7c(%ebp)
  105419:	c7 45 b0 7c df 11 00 	movl   $0x11df7c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  105420:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105423:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105426:	89 50 04             	mov    %edx,0x4(%eax)
  105429:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10542c:	8b 50 04             	mov    0x4(%eax),%edx
  10542f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  105432:	89 10                	mov    %edx,(%eax)
}
  105434:	90                   	nop
  105435:	c7 45 b4 7c df 11 00 	movl   $0x11df7c,-0x4c(%ebp)
    return list->next == list;
  10543c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10543f:	8b 40 04             	mov    0x4(%eax),%eax
  105442:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  105445:	0f 94 c0             	sete   %al
  105448:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  10544b:	85 c0                	test   %eax,%eax
  10544d:	75 24                	jne    105473 <default_check+0x1d3>
  10544f:	c7 44 24 0c 5b 73 10 	movl   $0x10735b,0xc(%esp)
  105456:	00 
  105457:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10545e:	00 
  10545f:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
  105466:	00 
  105467:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10546e:	e8 c3 af ff ff       	call   100436 <__panic>
    assert(alloc_page() == NULL);
  105473:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10547a:	e8 04 da ff ff       	call   102e83 <alloc_pages>
  10547f:	85 c0                	test   %eax,%eax
  105481:	74 24                	je     1054a7 <default_check+0x207>
  105483:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  10548a:	00 
  10548b:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105492:	00 
  105493:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
  10549a:	00 
  10549b:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1054a2:	e8 8f af ff ff       	call   100436 <__panic>

    unsigned int nr_free_store = nr_free;
  1054a7:	a1 84 df 11 00       	mov    0x11df84,%eax
  1054ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  1054af:	c7 05 84 df 11 00 00 	movl   $0x0,0x11df84
  1054b6:	00 00 00 

    free_pages(p0 + 2, 3);
  1054b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054bc:	83 c0 28             	add    $0x28,%eax
  1054bf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1054c6:	00 
  1054c7:	89 04 24             	mov    %eax,(%esp)
  1054ca:	e8 f0 d9 ff ff       	call   102ebf <free_pages>
    assert(alloc_pages(4) == NULL);
  1054cf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1054d6:	e8 a8 d9 ff ff       	call   102e83 <alloc_pages>
  1054db:	85 c0                	test   %eax,%eax
  1054dd:	74 24                	je     105503 <default_check+0x263>
  1054df:	c7 44 24 0c 18 74 10 	movl   $0x107418,0xc(%esp)
  1054e6:	00 
  1054e7:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1054ee:	00 
  1054ef:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
  1054f6:	00 
  1054f7:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1054fe:	e8 33 af ff ff       	call   100436 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  105503:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105506:	83 c0 28             	add    $0x28,%eax
  105509:	83 c0 04             	add    $0x4,%eax
  10550c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  105513:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105516:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105519:	8b 55 ac             	mov    -0x54(%ebp),%edx
  10551c:	0f a3 10             	bt     %edx,(%eax)
  10551f:	19 c0                	sbb    %eax,%eax
  105521:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  105524:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  105528:	0f 95 c0             	setne  %al
  10552b:	0f b6 c0             	movzbl %al,%eax
  10552e:	85 c0                	test   %eax,%eax
  105530:	74 0e                	je     105540 <default_check+0x2a0>
  105532:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105535:	83 c0 28             	add    $0x28,%eax
  105538:	8b 40 08             	mov    0x8(%eax),%eax
  10553b:	83 f8 03             	cmp    $0x3,%eax
  10553e:	74 24                	je     105564 <default_check+0x2c4>
  105540:	c7 44 24 0c 30 74 10 	movl   $0x107430,0xc(%esp)
  105547:	00 
  105548:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10554f:	00 
  105550:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
  105557:	00 
  105558:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10555f:	e8 d2 ae ff ff       	call   100436 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105564:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  10556b:	e8 13 d9 ff ff       	call   102e83 <alloc_pages>
  105570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105577:	75 24                	jne    10559d <default_check+0x2fd>
  105579:	c7 44 24 0c 5c 74 10 	movl   $0x10745c,0xc(%esp)
  105580:	00 
  105581:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105588:	00 
  105589:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
  105590:	00 
  105591:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105598:	e8 99 ae ff ff       	call   100436 <__panic>
    assert(alloc_page() == NULL);
  10559d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1055a4:	e8 da d8 ff ff       	call   102e83 <alloc_pages>
  1055a9:	85 c0                	test   %eax,%eax
  1055ab:	74 24                	je     1055d1 <default_check+0x331>
  1055ad:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  1055b4:	00 
  1055b5:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1055bc:	00 
  1055bd:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
  1055c4:	00 
  1055c5:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1055cc:	e8 65 ae ff ff       	call   100436 <__panic>
    assert(p0 + 2 == p1);
  1055d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1055d4:	83 c0 28             	add    $0x28,%eax
  1055d7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1055da:	74 24                	je     105600 <default_check+0x360>
  1055dc:	c7 44 24 0c 7a 74 10 	movl   $0x10747a,0xc(%esp)
  1055e3:	00 
  1055e4:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1055eb:	00 
  1055ec:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  1055f3:	00 
  1055f4:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1055fb:	e8 36 ae ff ff       	call   100436 <__panic>

    p2 = p0 + 1;
  105600:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105603:	83 c0 14             	add    $0x14,%eax
  105606:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  105609:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105610:	00 
  105611:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105614:	89 04 24             	mov    %eax,(%esp)
  105617:	e8 a3 d8 ff ff       	call   102ebf <free_pages>
    free_pages(p1, 3);
  10561c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105623:	00 
  105624:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105627:	89 04 24             	mov    %eax,(%esp)
  10562a:	e8 90 d8 ff ff       	call   102ebf <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  10562f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105632:	83 c0 04             	add    $0x4,%eax
  105635:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  10563c:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10563f:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105642:	8b 55 a0             	mov    -0x60(%ebp),%edx
  105645:	0f a3 10             	bt     %edx,(%eax)
  105648:	19 c0                	sbb    %eax,%eax
  10564a:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10564d:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105651:	0f 95 c0             	setne  %al
  105654:	0f b6 c0             	movzbl %al,%eax
  105657:	85 c0                	test   %eax,%eax
  105659:	74 0b                	je     105666 <default_check+0x3c6>
  10565b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10565e:	8b 40 08             	mov    0x8(%eax),%eax
  105661:	83 f8 01             	cmp    $0x1,%eax
  105664:	74 24                	je     10568a <default_check+0x3ea>
  105666:	c7 44 24 0c 88 74 10 	movl   $0x107488,0xc(%esp)
  10566d:	00 
  10566e:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  105675:	00 
  105676:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
  10567d:	00 
  10567e:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105685:	e8 ac ad ff ff       	call   100436 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  10568a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10568d:	83 c0 04             	add    $0x4,%eax
  105690:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105697:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10569a:	8b 45 90             	mov    -0x70(%ebp),%eax
  10569d:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1056a0:	0f a3 10             	bt     %edx,(%eax)
  1056a3:	19 c0                	sbb    %eax,%eax
  1056a5:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  1056a8:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  1056ac:	0f 95 c0             	setne  %al
  1056af:	0f b6 c0             	movzbl %al,%eax
  1056b2:	85 c0                	test   %eax,%eax
  1056b4:	74 0b                	je     1056c1 <default_check+0x421>
  1056b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1056b9:	8b 40 08             	mov    0x8(%eax),%eax
  1056bc:	83 f8 03             	cmp    $0x3,%eax
  1056bf:	74 24                	je     1056e5 <default_check+0x445>
  1056c1:	c7 44 24 0c b0 74 10 	movl   $0x1074b0,0xc(%esp)
  1056c8:	00 
  1056c9:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1056d0:	00 
  1056d1:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
  1056d8:	00 
  1056d9:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1056e0:	e8 51 ad ff ff       	call   100436 <__panic>
	
    assert((p0 = alloc_page()) == p2 - 1);
  1056e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1056ec:	e8 92 d7 ff ff       	call   102e83 <alloc_pages>
  1056f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1056f7:	83 e8 14             	sub    $0x14,%eax
  1056fa:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1056fd:	74 24                	je     105723 <default_check+0x483>
  1056ff:	c7 44 24 0c d6 74 10 	movl   $0x1074d6,0xc(%esp)
  105706:	00 
  105707:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10570e:	00 
  10570f:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
  105716:	00 
  105717:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10571e:	e8 13 ad ff ff       	call   100436 <__panic>
    free_page(p0);
  105723:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10572a:	00 
  10572b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10572e:	89 04 24             	mov    %eax,(%esp)
  105731:	e8 89 d7 ff ff       	call   102ebf <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  105736:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  10573d:	e8 41 d7 ff ff       	call   102e83 <alloc_pages>
  105742:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105745:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105748:	83 c0 14             	add    $0x14,%eax
  10574b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10574e:	74 24                	je     105774 <default_check+0x4d4>
  105750:	c7 44 24 0c f4 74 10 	movl   $0x1074f4,0xc(%esp)
  105757:	00 
  105758:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10575f:	00 
  105760:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
  105767:	00 
  105768:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10576f:	e8 c2 ac ff ff       	call   100436 <__panic>

    free_pages(p0, 2);
  105774:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  10577b:	00 
  10577c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10577f:	89 04 24             	mov    %eax,(%esp)
  105782:	e8 38 d7 ff ff       	call   102ebf <free_pages>
    free_page(p2);
  105787:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10578e:	00 
  10578f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105792:	89 04 24             	mov    %eax,(%esp)
  105795:	e8 25 d7 ff ff       	call   102ebf <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  10579a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1057a1:	e8 dd d6 ff ff       	call   102e83 <alloc_pages>
  1057a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1057a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1057ad:	75 24                	jne    1057d3 <default_check+0x533>
  1057af:	c7 44 24 0c 14 75 10 	movl   $0x107514,0xc(%esp)
  1057b6:	00 
  1057b7:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1057be:	00 
  1057bf:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
  1057c6:	00 
  1057c7:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1057ce:	e8 63 ac ff ff       	call   100436 <__panic>
    assert(alloc_page() == NULL);
  1057d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1057da:	e8 a4 d6 ff ff       	call   102e83 <alloc_pages>
  1057df:	85 c0                	test   %eax,%eax
  1057e1:	74 24                	je     105807 <default_check+0x567>
  1057e3:	c7 44 24 0c 72 73 10 	movl   $0x107372,0xc(%esp)
  1057ea:	00 
  1057eb:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1057f2:	00 
  1057f3:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
  1057fa:	00 
  1057fb:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  105802:	e8 2f ac ff ff       	call   100436 <__panic>

    assert(nr_free == 0);
  105807:	a1 84 df 11 00       	mov    0x11df84,%eax
  10580c:	85 c0                	test   %eax,%eax
  10580e:	74 24                	je     105834 <default_check+0x594>
  105810:	c7 44 24 0c c5 73 10 	movl   $0x1073c5,0xc(%esp)
  105817:	00 
  105818:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  10581f:	00 
  105820:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
  105827:	00 
  105828:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  10582f:	e8 02 ac ff ff       	call   100436 <__panic>
    nr_free = nr_free_store;
  105834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105837:	a3 84 df 11 00       	mov    %eax,0x11df84

    free_list = free_list_store;
  10583c:	8b 45 80             	mov    -0x80(%ebp),%eax
  10583f:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105842:	a3 7c df 11 00       	mov    %eax,0x11df7c
  105847:	89 15 80 df 11 00    	mov    %edx,0x11df80
    free_pages(p0, 5);
  10584d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  105854:	00 
  105855:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105858:	89 04 24             	mov    %eax,(%esp)
  10585b:	e8 5f d6 ff ff       	call   102ebf <free_pages>

    le = &free_list;
  105860:	c7 45 ec 7c df 11 00 	movl   $0x11df7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105867:	eb 1c                	jmp    105885 <default_check+0x5e5>
        struct Page *p = le2page(le, page_link);
  105869:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10586c:	83 e8 0c             	sub    $0xc,%eax
  10586f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  105872:	ff 4d f4             	decl   -0xc(%ebp)
  105875:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105878:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10587b:	8b 40 08             	mov    0x8(%eax),%eax
  10587e:	29 c2                	sub    %eax,%edx
  105880:	89 d0                	mov    %edx,%eax
  105882:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105885:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105888:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  10588b:	8b 45 88             	mov    -0x78(%ebp),%eax
  10588e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  105891:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105894:	81 7d ec 7c df 11 00 	cmpl   $0x11df7c,-0x14(%ebp)
  10589b:	75 cc                	jne    105869 <default_check+0x5c9>
    }
    assert(count == 0);
  10589d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1058a1:	74 24                	je     1058c7 <default_check+0x627>
  1058a3:	c7 44 24 0c 32 75 10 	movl   $0x107532,0xc(%esp)
  1058aa:	00 
  1058ab:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1058b2:	00 
  1058b3:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
  1058ba:	00 
  1058bb:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1058c2:	e8 6f ab ff ff       	call   100436 <__panic>
    assert(total == 0);
  1058c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1058cb:	74 24                	je     1058f1 <default_check+0x651>
  1058cd:	c7 44 24 0c 3d 75 10 	movl   $0x10753d,0xc(%esp)
  1058d4:	00 
  1058d5:	c7 44 24 08 de 71 10 	movl   $0x1071de,0x8(%esp)
  1058dc:	00 
  1058dd:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
  1058e4:	00 
  1058e5:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  1058ec:	e8 45 ab ff ff       	call   100436 <__panic>
}
  1058f1:	90                   	nop
  1058f2:	c9                   	leave  
  1058f3:	c3                   	ret    

001058f4 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1058f4:	f3 0f 1e fb          	endbr32 
  1058f8:	55                   	push   %ebp
  1058f9:	89 e5                	mov    %esp,%ebp
  1058fb:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1058fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105905:	eb 03                	jmp    10590a <strlen+0x16>
        cnt ++;
  105907:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  10590a:	8b 45 08             	mov    0x8(%ebp),%eax
  10590d:	8d 50 01             	lea    0x1(%eax),%edx
  105910:	89 55 08             	mov    %edx,0x8(%ebp)
  105913:	0f b6 00             	movzbl (%eax),%eax
  105916:	84 c0                	test   %al,%al
  105918:	75 ed                	jne    105907 <strlen+0x13>
    }
    return cnt;
  10591a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10591d:	c9                   	leave  
  10591e:	c3                   	ret    

0010591f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  10591f:	f3 0f 1e fb          	endbr32 
  105923:	55                   	push   %ebp
  105924:	89 e5                	mov    %esp,%ebp
  105926:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105929:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105930:	eb 03                	jmp    105935 <strnlen+0x16>
        cnt ++;
  105932:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105935:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105938:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10593b:	73 10                	jae    10594d <strnlen+0x2e>
  10593d:	8b 45 08             	mov    0x8(%ebp),%eax
  105940:	8d 50 01             	lea    0x1(%eax),%edx
  105943:	89 55 08             	mov    %edx,0x8(%ebp)
  105946:	0f b6 00             	movzbl (%eax),%eax
  105949:	84 c0                	test   %al,%al
  10594b:	75 e5                	jne    105932 <strnlen+0x13>
    }
    return cnt;
  10594d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105950:	c9                   	leave  
  105951:	c3                   	ret    

00105952 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105952:	f3 0f 1e fb          	endbr32 
  105956:	55                   	push   %ebp
  105957:	89 e5                	mov    %esp,%ebp
  105959:	57                   	push   %edi
  10595a:	56                   	push   %esi
  10595b:	83 ec 20             	sub    $0x20,%esp
  10595e:	8b 45 08             	mov    0x8(%ebp),%eax
  105961:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105964:	8b 45 0c             	mov    0xc(%ebp),%eax
  105967:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  10596a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10596d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105970:	89 d1                	mov    %edx,%ecx
  105972:	89 c2                	mov    %eax,%edx
  105974:	89 ce                	mov    %ecx,%esi
  105976:	89 d7                	mov    %edx,%edi
  105978:	ac                   	lods   %ds:(%esi),%al
  105979:	aa                   	stos   %al,%es:(%edi)
  10597a:	84 c0                	test   %al,%al
  10597c:	75 fa                	jne    105978 <strcpy+0x26>
  10597e:	89 fa                	mov    %edi,%edx
  105980:	89 f1                	mov    %esi,%ecx
  105982:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105985:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105988:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  10598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10598e:	83 c4 20             	add    $0x20,%esp
  105991:	5e                   	pop    %esi
  105992:	5f                   	pop    %edi
  105993:	5d                   	pop    %ebp
  105994:	c3                   	ret    

00105995 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105995:	f3 0f 1e fb          	endbr32 
  105999:	55                   	push   %ebp
  10599a:	89 e5                	mov    %esp,%ebp
  10599c:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  10599f:	8b 45 08             	mov    0x8(%ebp),%eax
  1059a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1059a5:	eb 1e                	jmp    1059c5 <strncpy+0x30>
        if ((*p = *src) != '\0') {
  1059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059aa:	0f b6 10             	movzbl (%eax),%edx
  1059ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1059b0:	88 10                	mov    %dl,(%eax)
  1059b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1059b5:	0f b6 00             	movzbl (%eax),%eax
  1059b8:	84 c0                	test   %al,%al
  1059ba:	74 03                	je     1059bf <strncpy+0x2a>
            src ++;
  1059bc:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  1059bf:	ff 45 fc             	incl   -0x4(%ebp)
  1059c2:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  1059c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1059c9:	75 dc                	jne    1059a7 <strncpy+0x12>
    }
    return dst;
  1059cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1059ce:	c9                   	leave  
  1059cf:	c3                   	ret    

001059d0 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1059d0:	f3 0f 1e fb          	endbr32 
  1059d4:	55                   	push   %ebp
  1059d5:	89 e5                	mov    %esp,%ebp
  1059d7:	57                   	push   %edi
  1059d8:	56                   	push   %esi
  1059d9:	83 ec 20             	sub    $0x20,%esp
  1059dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1059df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  1059e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1059ee:	89 d1                	mov    %edx,%ecx
  1059f0:	89 c2                	mov    %eax,%edx
  1059f2:	89 ce                	mov    %ecx,%esi
  1059f4:	89 d7                	mov    %edx,%edi
  1059f6:	ac                   	lods   %ds:(%esi),%al
  1059f7:	ae                   	scas   %es:(%edi),%al
  1059f8:	75 08                	jne    105a02 <strcmp+0x32>
  1059fa:	84 c0                	test   %al,%al
  1059fc:	75 f8                	jne    1059f6 <strcmp+0x26>
  1059fe:	31 c0                	xor    %eax,%eax
  105a00:	eb 04                	jmp    105a06 <strcmp+0x36>
  105a02:	19 c0                	sbb    %eax,%eax
  105a04:	0c 01                	or     $0x1,%al
  105a06:	89 fa                	mov    %edi,%edx
  105a08:	89 f1                	mov    %esi,%ecx
  105a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a0d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105a10:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105a16:	83 c4 20             	add    $0x20,%esp
  105a19:	5e                   	pop    %esi
  105a1a:	5f                   	pop    %edi
  105a1b:	5d                   	pop    %ebp
  105a1c:	c3                   	ret    

00105a1d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105a1d:	f3 0f 1e fb          	endbr32 
  105a21:	55                   	push   %ebp
  105a22:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a24:	eb 09                	jmp    105a2f <strncmp+0x12>
        n --, s1 ++, s2 ++;
  105a26:	ff 4d 10             	decl   0x10(%ebp)
  105a29:	ff 45 08             	incl   0x8(%ebp)
  105a2c:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a33:	74 1a                	je     105a4f <strncmp+0x32>
  105a35:	8b 45 08             	mov    0x8(%ebp),%eax
  105a38:	0f b6 00             	movzbl (%eax),%eax
  105a3b:	84 c0                	test   %al,%al
  105a3d:	74 10                	je     105a4f <strncmp+0x32>
  105a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  105a42:	0f b6 10             	movzbl (%eax),%edx
  105a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a48:	0f b6 00             	movzbl (%eax),%eax
  105a4b:	38 c2                	cmp    %al,%dl
  105a4d:	74 d7                	je     105a26 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105a4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a53:	74 18                	je     105a6d <strncmp+0x50>
  105a55:	8b 45 08             	mov    0x8(%ebp),%eax
  105a58:	0f b6 00             	movzbl (%eax),%eax
  105a5b:	0f b6 d0             	movzbl %al,%edx
  105a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a61:	0f b6 00             	movzbl (%eax),%eax
  105a64:	0f b6 c0             	movzbl %al,%eax
  105a67:	29 c2                	sub    %eax,%edx
  105a69:	89 d0                	mov    %edx,%eax
  105a6b:	eb 05                	jmp    105a72 <strncmp+0x55>
  105a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105a72:	5d                   	pop    %ebp
  105a73:	c3                   	ret    

00105a74 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105a74:	f3 0f 1e fb          	endbr32 
  105a78:	55                   	push   %ebp
  105a79:	89 e5                	mov    %esp,%ebp
  105a7b:	83 ec 04             	sub    $0x4,%esp
  105a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a81:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105a84:	eb 13                	jmp    105a99 <strchr+0x25>
        if (*s == c) {
  105a86:	8b 45 08             	mov    0x8(%ebp),%eax
  105a89:	0f b6 00             	movzbl (%eax),%eax
  105a8c:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105a8f:	75 05                	jne    105a96 <strchr+0x22>
            return (char *)s;
  105a91:	8b 45 08             	mov    0x8(%ebp),%eax
  105a94:	eb 12                	jmp    105aa8 <strchr+0x34>
        }
        s ++;
  105a96:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105a99:	8b 45 08             	mov    0x8(%ebp),%eax
  105a9c:	0f b6 00             	movzbl (%eax),%eax
  105a9f:	84 c0                	test   %al,%al
  105aa1:	75 e3                	jne    105a86 <strchr+0x12>
    }
    return NULL;
  105aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105aa8:	c9                   	leave  
  105aa9:	c3                   	ret    

00105aaa <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105aaa:	f3 0f 1e fb          	endbr32 
  105aae:	55                   	push   %ebp
  105aaf:	89 e5                	mov    %esp,%ebp
  105ab1:	83 ec 04             	sub    $0x4,%esp
  105ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ab7:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105aba:	eb 0e                	jmp    105aca <strfind+0x20>
        if (*s == c) {
  105abc:	8b 45 08             	mov    0x8(%ebp),%eax
  105abf:	0f b6 00             	movzbl (%eax),%eax
  105ac2:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105ac5:	74 0f                	je     105ad6 <strfind+0x2c>
            break;
        }
        s ++;
  105ac7:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105aca:	8b 45 08             	mov    0x8(%ebp),%eax
  105acd:	0f b6 00             	movzbl (%eax),%eax
  105ad0:	84 c0                	test   %al,%al
  105ad2:	75 e8                	jne    105abc <strfind+0x12>
  105ad4:	eb 01                	jmp    105ad7 <strfind+0x2d>
            break;
  105ad6:	90                   	nop
    }
    return (char *)s;
  105ad7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105ada:	c9                   	leave  
  105adb:	c3                   	ret    

00105adc <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105adc:	f3 0f 1e fb          	endbr32 
  105ae0:	55                   	push   %ebp
  105ae1:	89 e5                	mov    %esp,%ebp
  105ae3:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105ae6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105aed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105af4:	eb 03                	jmp    105af9 <strtol+0x1d>
        s ++;
  105af6:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105af9:	8b 45 08             	mov    0x8(%ebp),%eax
  105afc:	0f b6 00             	movzbl (%eax),%eax
  105aff:	3c 20                	cmp    $0x20,%al
  105b01:	74 f3                	je     105af6 <strtol+0x1a>
  105b03:	8b 45 08             	mov    0x8(%ebp),%eax
  105b06:	0f b6 00             	movzbl (%eax),%eax
  105b09:	3c 09                	cmp    $0x9,%al
  105b0b:	74 e9                	je     105af6 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  105b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  105b10:	0f b6 00             	movzbl (%eax),%eax
  105b13:	3c 2b                	cmp    $0x2b,%al
  105b15:	75 05                	jne    105b1c <strtol+0x40>
        s ++;
  105b17:	ff 45 08             	incl   0x8(%ebp)
  105b1a:	eb 14                	jmp    105b30 <strtol+0x54>
    }
    else if (*s == '-') {
  105b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1f:	0f b6 00             	movzbl (%eax),%eax
  105b22:	3c 2d                	cmp    $0x2d,%al
  105b24:	75 0a                	jne    105b30 <strtol+0x54>
        s ++, neg = 1;
  105b26:	ff 45 08             	incl   0x8(%ebp)
  105b29:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105b30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b34:	74 06                	je     105b3c <strtol+0x60>
  105b36:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105b3a:	75 22                	jne    105b5e <strtol+0x82>
  105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b3f:	0f b6 00             	movzbl (%eax),%eax
  105b42:	3c 30                	cmp    $0x30,%al
  105b44:	75 18                	jne    105b5e <strtol+0x82>
  105b46:	8b 45 08             	mov    0x8(%ebp),%eax
  105b49:	40                   	inc    %eax
  105b4a:	0f b6 00             	movzbl (%eax),%eax
  105b4d:	3c 78                	cmp    $0x78,%al
  105b4f:	75 0d                	jne    105b5e <strtol+0x82>
        s += 2, base = 16;
  105b51:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105b55:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105b5c:	eb 29                	jmp    105b87 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
  105b5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b62:	75 16                	jne    105b7a <strtol+0x9e>
  105b64:	8b 45 08             	mov    0x8(%ebp),%eax
  105b67:	0f b6 00             	movzbl (%eax),%eax
  105b6a:	3c 30                	cmp    $0x30,%al
  105b6c:	75 0c                	jne    105b7a <strtol+0x9e>
        s ++, base = 8;
  105b6e:	ff 45 08             	incl   0x8(%ebp)
  105b71:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105b78:	eb 0d                	jmp    105b87 <strtol+0xab>
    }
    else if (base == 0) {
  105b7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b7e:	75 07                	jne    105b87 <strtol+0xab>
        base = 10;
  105b80:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105b87:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8a:	0f b6 00             	movzbl (%eax),%eax
  105b8d:	3c 2f                	cmp    $0x2f,%al
  105b8f:	7e 1b                	jle    105bac <strtol+0xd0>
  105b91:	8b 45 08             	mov    0x8(%ebp),%eax
  105b94:	0f b6 00             	movzbl (%eax),%eax
  105b97:	3c 39                	cmp    $0x39,%al
  105b99:	7f 11                	jg     105bac <strtol+0xd0>
            dig = *s - '0';
  105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  105b9e:	0f b6 00             	movzbl (%eax),%eax
  105ba1:	0f be c0             	movsbl %al,%eax
  105ba4:	83 e8 30             	sub    $0x30,%eax
  105ba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105baa:	eb 48                	jmp    105bf4 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105bac:	8b 45 08             	mov    0x8(%ebp),%eax
  105baf:	0f b6 00             	movzbl (%eax),%eax
  105bb2:	3c 60                	cmp    $0x60,%al
  105bb4:	7e 1b                	jle    105bd1 <strtol+0xf5>
  105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  105bb9:	0f b6 00             	movzbl (%eax),%eax
  105bbc:	3c 7a                	cmp    $0x7a,%al
  105bbe:	7f 11                	jg     105bd1 <strtol+0xf5>
            dig = *s - 'a' + 10;
  105bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  105bc3:	0f b6 00             	movzbl (%eax),%eax
  105bc6:	0f be c0             	movsbl %al,%eax
  105bc9:	83 e8 57             	sub    $0x57,%eax
  105bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bcf:	eb 23                	jmp    105bf4 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd4:	0f b6 00             	movzbl (%eax),%eax
  105bd7:	3c 40                	cmp    $0x40,%al
  105bd9:	7e 3b                	jle    105c16 <strtol+0x13a>
  105bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  105bde:	0f b6 00             	movzbl (%eax),%eax
  105be1:	3c 5a                	cmp    $0x5a,%al
  105be3:	7f 31                	jg     105c16 <strtol+0x13a>
            dig = *s - 'A' + 10;
  105be5:	8b 45 08             	mov    0x8(%ebp),%eax
  105be8:	0f b6 00             	movzbl (%eax),%eax
  105beb:	0f be c0             	movsbl %al,%eax
  105bee:	83 e8 37             	sub    $0x37,%eax
  105bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105bf7:	3b 45 10             	cmp    0x10(%ebp),%eax
  105bfa:	7d 19                	jge    105c15 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
  105bfc:	ff 45 08             	incl   0x8(%ebp)
  105bff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105c02:	0f af 45 10          	imul   0x10(%ebp),%eax
  105c06:	89 c2                	mov    %eax,%edx
  105c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c0b:	01 d0                	add    %edx,%eax
  105c0d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  105c10:	e9 72 ff ff ff       	jmp    105b87 <strtol+0xab>
            break;
  105c15:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  105c16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105c1a:	74 08                	je     105c24 <strtol+0x148>
        *endptr = (char *) s;
  105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1f:	8b 55 08             	mov    0x8(%ebp),%edx
  105c22:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105c24:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105c28:	74 07                	je     105c31 <strtol+0x155>
  105c2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105c2d:	f7 d8                	neg    %eax
  105c2f:	eb 03                	jmp    105c34 <strtol+0x158>
  105c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105c34:	c9                   	leave  
  105c35:	c3                   	ret    

00105c36 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105c36:	f3 0f 1e fb          	endbr32 
  105c3a:	55                   	push   %ebp
  105c3b:	89 e5                	mov    %esp,%ebp
  105c3d:	57                   	push   %edi
  105c3e:	83 ec 24             	sub    $0x24,%esp
  105c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c44:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105c47:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  105c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105c4e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  105c51:	88 55 f7             	mov    %dl,-0x9(%ebp)
  105c54:	8b 45 10             	mov    0x10(%ebp),%eax
  105c57:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105c5a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105c5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105c61:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105c64:	89 d7                	mov    %edx,%edi
  105c66:	f3 aa                	rep stos %al,%es:(%edi)
  105c68:	89 fa                	mov    %edi,%edx
  105c6a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105c6d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105c70:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105c73:	83 c4 24             	add    $0x24,%esp
  105c76:	5f                   	pop    %edi
  105c77:	5d                   	pop    %ebp
  105c78:	c3                   	ret    

00105c79 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105c79:	f3 0f 1e fb          	endbr32 
  105c7d:	55                   	push   %ebp
  105c7e:	89 e5                	mov    %esp,%ebp
  105c80:	57                   	push   %edi
  105c81:	56                   	push   %esi
  105c82:	53                   	push   %ebx
  105c83:	83 ec 30             	sub    $0x30,%esp
  105c86:	8b 45 08             	mov    0x8(%ebp),%eax
  105c89:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c92:	8b 45 10             	mov    0x10(%ebp),%eax
  105c95:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105c9e:	73 42                	jae    105ce2 <memmove+0x69>
  105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ca3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ca9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105caf:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105cb5:	c1 e8 02             	shr    $0x2,%eax
  105cb8:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105cba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105cbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105cc0:	89 d7                	mov    %edx,%edi
  105cc2:	89 c6                	mov    %eax,%esi
  105cc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105cc6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105cc9:	83 e1 03             	and    $0x3,%ecx
  105ccc:	74 02                	je     105cd0 <memmove+0x57>
  105cce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105cd0:	89 f0                	mov    %esi,%eax
  105cd2:	89 fa                	mov    %edi,%edx
  105cd4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105cd7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105cda:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  105ce0:	eb 36                	jmp    105d18 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ce5:	8d 50 ff             	lea    -0x1(%eax),%edx
  105ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ceb:	01 c2                	add    %eax,%edx
  105ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105cf0:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cf6:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105cfc:	89 c1                	mov    %eax,%ecx
  105cfe:	89 d8                	mov    %ebx,%eax
  105d00:	89 d6                	mov    %edx,%esi
  105d02:	89 c7                	mov    %eax,%edi
  105d04:	fd                   	std    
  105d05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d07:	fc                   	cld    
  105d08:	89 f8                	mov    %edi,%eax
  105d0a:	89 f2                	mov    %esi,%edx
  105d0c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105d0f:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105d12:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105d18:	83 c4 30             	add    $0x30,%esp
  105d1b:	5b                   	pop    %ebx
  105d1c:	5e                   	pop    %esi
  105d1d:	5f                   	pop    %edi
  105d1e:	5d                   	pop    %ebp
  105d1f:	c3                   	ret    

00105d20 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105d20:	f3 0f 1e fb          	endbr32 
  105d24:	55                   	push   %ebp
  105d25:	89 e5                	mov    %esp,%ebp
  105d27:	57                   	push   %edi
  105d28:	56                   	push   %esi
  105d29:	83 ec 20             	sub    $0x20,%esp
  105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d32:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d38:	8b 45 10             	mov    0x10(%ebp),%eax
  105d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d41:	c1 e8 02             	shr    $0x2,%eax
  105d44:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d4c:	89 d7                	mov    %edx,%edi
  105d4e:	89 c6                	mov    %eax,%esi
  105d50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105d52:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105d55:	83 e1 03             	and    $0x3,%ecx
  105d58:	74 02                	je     105d5c <memcpy+0x3c>
  105d5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d5c:	89 f0                	mov    %esi,%eax
  105d5e:	89 fa                	mov    %edi,%edx
  105d60:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105d63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105d66:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105d6c:	83 c4 20             	add    $0x20,%esp
  105d6f:	5e                   	pop    %esi
  105d70:	5f                   	pop    %edi
  105d71:	5d                   	pop    %ebp
  105d72:	c3                   	ret    

00105d73 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105d73:	f3 0f 1e fb          	endbr32 
  105d77:	55                   	push   %ebp
  105d78:	89 e5                	mov    %esp,%ebp
  105d7a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  105d80:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105d83:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d86:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105d89:	eb 2e                	jmp    105db9 <memcmp+0x46>
        if (*s1 != *s2) {
  105d8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d8e:	0f b6 10             	movzbl (%eax),%edx
  105d91:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105d94:	0f b6 00             	movzbl (%eax),%eax
  105d97:	38 c2                	cmp    %al,%dl
  105d99:	74 18                	je     105db3 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105d9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d9e:	0f b6 00             	movzbl (%eax),%eax
  105da1:	0f b6 d0             	movzbl %al,%edx
  105da4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105da7:	0f b6 00             	movzbl (%eax),%eax
  105daa:	0f b6 c0             	movzbl %al,%eax
  105dad:	29 c2                	sub    %eax,%edx
  105daf:	89 d0                	mov    %edx,%eax
  105db1:	eb 18                	jmp    105dcb <memcmp+0x58>
        }
        s1 ++, s2 ++;
  105db3:	ff 45 fc             	incl   -0x4(%ebp)
  105db6:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105db9:	8b 45 10             	mov    0x10(%ebp),%eax
  105dbc:	8d 50 ff             	lea    -0x1(%eax),%edx
  105dbf:	89 55 10             	mov    %edx,0x10(%ebp)
  105dc2:	85 c0                	test   %eax,%eax
  105dc4:	75 c5                	jne    105d8b <memcmp+0x18>
    }
    return 0;
  105dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105dcb:	c9                   	leave  
  105dcc:	c3                   	ret    

00105dcd <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105dcd:	f3 0f 1e fb          	endbr32 
  105dd1:	55                   	push   %ebp
  105dd2:	89 e5                	mov    %esp,%ebp
  105dd4:	83 ec 58             	sub    $0x58,%esp
  105dd7:	8b 45 10             	mov    0x10(%ebp),%eax
  105dda:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105ddd:	8b 45 14             	mov    0x14(%ebp),%eax
  105de0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105de3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105de6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105de9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105dec:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105def:	8b 45 18             	mov    0x18(%ebp),%eax
  105df2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105df5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105df8:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105dfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105dfe:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105e0b:	74 1c                	je     105e29 <printnum+0x5c>
  105e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e10:	ba 00 00 00 00       	mov    $0x0,%edx
  105e15:	f7 75 e4             	divl   -0x1c(%ebp)
  105e18:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e1e:	ba 00 00 00 00       	mov    $0x0,%edx
  105e23:	f7 75 e4             	divl   -0x1c(%ebp)
  105e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e2f:	f7 75 e4             	divl   -0x1c(%ebp)
  105e32:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e35:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105e44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e47:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105e4a:	8b 45 18             	mov    0x18(%ebp),%eax
  105e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  105e52:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105e55:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105e58:	19 d1                	sbb    %edx,%ecx
  105e5a:	72 4c                	jb     105ea8 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
  105e5c:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105e5f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e62:	8b 45 20             	mov    0x20(%ebp),%eax
  105e65:	89 44 24 18          	mov    %eax,0x18(%esp)
  105e69:	89 54 24 14          	mov    %edx,0x14(%esp)
  105e6d:	8b 45 18             	mov    0x18(%ebp),%eax
  105e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  105e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e77:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  105e7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e85:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e89:	8b 45 08             	mov    0x8(%ebp),%eax
  105e8c:	89 04 24             	mov    %eax,(%esp)
  105e8f:	e8 39 ff ff ff       	call   105dcd <printnum>
  105e94:	eb 1b                	jmp    105eb1 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e9d:	8b 45 20             	mov    0x20(%ebp),%eax
  105ea0:	89 04 24             	mov    %eax,(%esp)
  105ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ea6:	ff d0                	call   *%eax
        while (-- width > 0)
  105ea8:	ff 4d 1c             	decl   0x1c(%ebp)
  105eab:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105eaf:	7f e5                	jg     105e96 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105eb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105eb4:	05 f8 75 10 00       	add    $0x1075f8,%eax
  105eb9:	0f b6 00             	movzbl (%eax),%eax
  105ebc:	0f be c0             	movsbl %al,%eax
  105ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
  105ec6:	89 04 24             	mov    %eax,(%esp)
  105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ecc:	ff d0                	call   *%eax
}
  105ece:	90                   	nop
  105ecf:	c9                   	leave  
  105ed0:	c3                   	ret    

00105ed1 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105ed1:	f3 0f 1e fb          	endbr32 
  105ed5:	55                   	push   %ebp
  105ed6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105ed8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105edc:	7e 14                	jle    105ef2 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  105ede:	8b 45 08             	mov    0x8(%ebp),%eax
  105ee1:	8b 00                	mov    (%eax),%eax
  105ee3:	8d 48 08             	lea    0x8(%eax),%ecx
  105ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  105ee9:	89 0a                	mov    %ecx,(%edx)
  105eeb:	8b 50 04             	mov    0x4(%eax),%edx
  105eee:	8b 00                	mov    (%eax),%eax
  105ef0:	eb 30                	jmp    105f22 <getuint+0x51>
    }
    else if (lflag) {
  105ef2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105ef6:	74 16                	je     105f0e <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  105efb:	8b 00                	mov    (%eax),%eax
  105efd:	8d 48 04             	lea    0x4(%eax),%ecx
  105f00:	8b 55 08             	mov    0x8(%ebp),%edx
  105f03:	89 0a                	mov    %ecx,(%edx)
  105f05:	8b 00                	mov    (%eax),%eax
  105f07:	ba 00 00 00 00       	mov    $0x0,%edx
  105f0c:	eb 14                	jmp    105f22 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  105f11:	8b 00                	mov    (%eax),%eax
  105f13:	8d 48 04             	lea    0x4(%eax),%ecx
  105f16:	8b 55 08             	mov    0x8(%ebp),%edx
  105f19:	89 0a                	mov    %ecx,(%edx)
  105f1b:	8b 00                	mov    (%eax),%eax
  105f1d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105f22:	5d                   	pop    %ebp
  105f23:	c3                   	ret    

00105f24 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105f24:	f3 0f 1e fb          	endbr32 
  105f28:	55                   	push   %ebp
  105f29:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105f2b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105f2f:	7e 14                	jle    105f45 <getint+0x21>
        return va_arg(*ap, long long);
  105f31:	8b 45 08             	mov    0x8(%ebp),%eax
  105f34:	8b 00                	mov    (%eax),%eax
  105f36:	8d 48 08             	lea    0x8(%eax),%ecx
  105f39:	8b 55 08             	mov    0x8(%ebp),%edx
  105f3c:	89 0a                	mov    %ecx,(%edx)
  105f3e:	8b 50 04             	mov    0x4(%eax),%edx
  105f41:	8b 00                	mov    (%eax),%eax
  105f43:	eb 28                	jmp    105f6d <getint+0x49>
    }
    else if (lflag) {
  105f45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105f49:	74 12                	je     105f5d <getint+0x39>
        return va_arg(*ap, long);
  105f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4e:	8b 00                	mov    (%eax),%eax
  105f50:	8d 48 04             	lea    0x4(%eax),%ecx
  105f53:	8b 55 08             	mov    0x8(%ebp),%edx
  105f56:	89 0a                	mov    %ecx,(%edx)
  105f58:	8b 00                	mov    (%eax),%eax
  105f5a:	99                   	cltd   
  105f5b:	eb 10                	jmp    105f6d <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  105f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  105f60:	8b 00                	mov    (%eax),%eax
  105f62:	8d 48 04             	lea    0x4(%eax),%ecx
  105f65:	8b 55 08             	mov    0x8(%ebp),%edx
  105f68:	89 0a                	mov    %ecx,(%edx)
  105f6a:	8b 00                	mov    (%eax),%eax
  105f6c:	99                   	cltd   
    }
}
  105f6d:	5d                   	pop    %ebp
  105f6e:	c3                   	ret    

00105f6f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105f6f:	f3 0f 1e fb          	endbr32 
  105f73:	55                   	push   %ebp
  105f74:	89 e5                	mov    %esp,%ebp
  105f76:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105f79:	8d 45 14             	lea    0x14(%ebp),%eax
  105f7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105f82:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105f86:	8b 45 10             	mov    0x10(%ebp),%eax
  105f89:	89 44 24 08          	mov    %eax,0x8(%esp)
  105f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f90:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f94:	8b 45 08             	mov    0x8(%ebp),%eax
  105f97:	89 04 24             	mov    %eax,(%esp)
  105f9a:	e8 03 00 00 00       	call   105fa2 <vprintfmt>
    va_end(ap);
}
  105f9f:	90                   	nop
  105fa0:	c9                   	leave  
  105fa1:	c3                   	ret    

00105fa2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105fa2:	f3 0f 1e fb          	endbr32 
  105fa6:	55                   	push   %ebp
  105fa7:	89 e5                	mov    %esp,%ebp
  105fa9:	56                   	push   %esi
  105faa:	53                   	push   %ebx
  105fab:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105fae:	eb 17                	jmp    105fc7 <vprintfmt+0x25>
            if (ch == '\0') {
  105fb0:	85 db                	test   %ebx,%ebx
  105fb2:	0f 84 c0 03 00 00    	je     106378 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
  105fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fbf:	89 1c 24             	mov    %ebx,(%esp)
  105fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc5:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105fc7:	8b 45 10             	mov    0x10(%ebp),%eax
  105fca:	8d 50 01             	lea    0x1(%eax),%edx
  105fcd:	89 55 10             	mov    %edx,0x10(%ebp)
  105fd0:	0f b6 00             	movzbl (%eax),%eax
  105fd3:	0f b6 d8             	movzbl %al,%ebx
  105fd6:	83 fb 25             	cmp    $0x25,%ebx
  105fd9:	75 d5                	jne    105fb0 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105fdb:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105fdf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105fe9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105fec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105ff3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ff6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105ff9:	8b 45 10             	mov    0x10(%ebp),%eax
  105ffc:	8d 50 01             	lea    0x1(%eax),%edx
  105fff:	89 55 10             	mov    %edx,0x10(%ebp)
  106002:	0f b6 00             	movzbl (%eax),%eax
  106005:	0f b6 d8             	movzbl %al,%ebx
  106008:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10600b:	83 f8 55             	cmp    $0x55,%eax
  10600e:	0f 87 38 03 00 00    	ja     10634c <vprintfmt+0x3aa>
  106014:	8b 04 85 1c 76 10 00 	mov    0x10761c(,%eax,4),%eax
  10601b:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10601e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  106022:	eb d5                	jmp    105ff9 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  106024:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106028:	eb cf                	jmp    105ff9 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10602a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106031:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  106034:	89 d0                	mov    %edx,%eax
  106036:	c1 e0 02             	shl    $0x2,%eax
  106039:	01 d0                	add    %edx,%eax
  10603b:	01 c0                	add    %eax,%eax
  10603d:	01 d8                	add    %ebx,%eax
  10603f:	83 e8 30             	sub    $0x30,%eax
  106042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  106045:	8b 45 10             	mov    0x10(%ebp),%eax
  106048:	0f b6 00             	movzbl (%eax),%eax
  10604b:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10604e:	83 fb 2f             	cmp    $0x2f,%ebx
  106051:	7e 38                	jle    10608b <vprintfmt+0xe9>
  106053:	83 fb 39             	cmp    $0x39,%ebx
  106056:	7f 33                	jg     10608b <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
  106058:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  10605b:	eb d4                	jmp    106031 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  10605d:	8b 45 14             	mov    0x14(%ebp),%eax
  106060:	8d 50 04             	lea    0x4(%eax),%edx
  106063:	89 55 14             	mov    %edx,0x14(%ebp)
  106066:	8b 00                	mov    (%eax),%eax
  106068:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10606b:	eb 1f                	jmp    10608c <vprintfmt+0xea>

        case '.':
            if (width < 0)
  10606d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106071:	79 86                	jns    105ff9 <vprintfmt+0x57>
                width = 0;
  106073:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10607a:	e9 7a ff ff ff       	jmp    105ff9 <vprintfmt+0x57>

        case '#':
            altflag = 1;
  10607f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  106086:	e9 6e ff ff ff       	jmp    105ff9 <vprintfmt+0x57>
            goto process_precision;
  10608b:	90                   	nop

        process_precision:
            if (width < 0)
  10608c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106090:	0f 89 63 ff ff ff    	jns    105ff9 <vprintfmt+0x57>
                width = precision, precision = -1;
  106096:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106099:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10609c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1060a3:	e9 51 ff ff ff       	jmp    105ff9 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1060a8:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1060ab:	e9 49 ff ff ff       	jmp    105ff9 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1060b0:	8b 45 14             	mov    0x14(%ebp),%eax
  1060b3:	8d 50 04             	lea    0x4(%eax),%edx
  1060b6:	89 55 14             	mov    %edx,0x14(%ebp)
  1060b9:	8b 00                	mov    (%eax),%eax
  1060bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  1060be:	89 54 24 04          	mov    %edx,0x4(%esp)
  1060c2:	89 04 24             	mov    %eax,(%esp)
  1060c5:	8b 45 08             	mov    0x8(%ebp),%eax
  1060c8:	ff d0                	call   *%eax
            break;
  1060ca:	e9 a4 02 00 00       	jmp    106373 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1060cf:	8b 45 14             	mov    0x14(%ebp),%eax
  1060d2:	8d 50 04             	lea    0x4(%eax),%edx
  1060d5:	89 55 14             	mov    %edx,0x14(%ebp)
  1060d8:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1060da:	85 db                	test   %ebx,%ebx
  1060dc:	79 02                	jns    1060e0 <vprintfmt+0x13e>
                err = -err;
  1060de:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1060e0:	83 fb 06             	cmp    $0x6,%ebx
  1060e3:	7f 0b                	jg     1060f0 <vprintfmt+0x14e>
  1060e5:	8b 34 9d dc 75 10 00 	mov    0x1075dc(,%ebx,4),%esi
  1060ec:	85 f6                	test   %esi,%esi
  1060ee:	75 23                	jne    106113 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
  1060f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1060f4:	c7 44 24 08 09 76 10 	movl   $0x107609,0x8(%esp)
  1060fb:	00 
  1060fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  106103:	8b 45 08             	mov    0x8(%ebp),%eax
  106106:	89 04 24             	mov    %eax,(%esp)
  106109:	e8 61 fe ff ff       	call   105f6f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10610e:	e9 60 02 00 00       	jmp    106373 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
  106113:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106117:	c7 44 24 08 12 76 10 	movl   $0x107612,0x8(%esp)
  10611e:	00 
  10611f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106122:	89 44 24 04          	mov    %eax,0x4(%esp)
  106126:	8b 45 08             	mov    0x8(%ebp),%eax
  106129:	89 04 24             	mov    %eax,(%esp)
  10612c:	e8 3e fe ff ff       	call   105f6f <printfmt>
            break;
  106131:	e9 3d 02 00 00       	jmp    106373 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  106136:	8b 45 14             	mov    0x14(%ebp),%eax
  106139:	8d 50 04             	lea    0x4(%eax),%edx
  10613c:	89 55 14             	mov    %edx,0x14(%ebp)
  10613f:	8b 30                	mov    (%eax),%esi
  106141:	85 f6                	test   %esi,%esi
  106143:	75 05                	jne    10614a <vprintfmt+0x1a8>
                p = "(null)";
  106145:	be 15 76 10 00       	mov    $0x107615,%esi
            }
            if (width > 0 && padc != '-') {
  10614a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10614e:	7e 76                	jle    1061c6 <vprintfmt+0x224>
  106150:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106154:	74 70                	je     1061c6 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106159:	89 44 24 04          	mov    %eax,0x4(%esp)
  10615d:	89 34 24             	mov    %esi,(%esp)
  106160:	e8 ba f7 ff ff       	call   10591f <strnlen>
  106165:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106168:	29 c2                	sub    %eax,%edx
  10616a:	89 d0                	mov    %edx,%eax
  10616c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10616f:	eb 16                	jmp    106187 <vprintfmt+0x1e5>
                    putch(padc, putdat);
  106171:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106175:	8b 55 0c             	mov    0xc(%ebp),%edx
  106178:	89 54 24 04          	mov    %edx,0x4(%esp)
  10617c:	89 04 24             	mov    %eax,(%esp)
  10617f:	8b 45 08             	mov    0x8(%ebp),%eax
  106182:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  106184:	ff 4d e8             	decl   -0x18(%ebp)
  106187:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10618b:	7f e4                	jg     106171 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10618d:	eb 37                	jmp    1061c6 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
  10618f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106193:	74 1f                	je     1061b4 <vprintfmt+0x212>
  106195:	83 fb 1f             	cmp    $0x1f,%ebx
  106198:	7e 05                	jle    10619f <vprintfmt+0x1fd>
  10619a:	83 fb 7e             	cmp    $0x7e,%ebx
  10619d:	7e 15                	jle    1061b4 <vprintfmt+0x212>
                    putch('?', putdat);
  10619f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061a6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1061ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1061b0:	ff d0                	call   *%eax
  1061b2:	eb 0f                	jmp    1061c3 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
  1061b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061bb:	89 1c 24             	mov    %ebx,(%esp)
  1061be:	8b 45 08             	mov    0x8(%ebp),%eax
  1061c1:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1061c3:	ff 4d e8             	decl   -0x18(%ebp)
  1061c6:	89 f0                	mov    %esi,%eax
  1061c8:	8d 70 01             	lea    0x1(%eax),%esi
  1061cb:	0f b6 00             	movzbl (%eax),%eax
  1061ce:	0f be d8             	movsbl %al,%ebx
  1061d1:	85 db                	test   %ebx,%ebx
  1061d3:	74 27                	je     1061fc <vprintfmt+0x25a>
  1061d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1061d9:	78 b4                	js     10618f <vprintfmt+0x1ed>
  1061db:	ff 4d e4             	decl   -0x1c(%ebp)
  1061de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1061e2:	79 ab                	jns    10618f <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
  1061e4:	eb 16                	jmp    1061fc <vprintfmt+0x25a>
                putch(' ', putdat);
  1061e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1061f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1061f7:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  1061f9:	ff 4d e8             	decl   -0x18(%ebp)
  1061fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106200:	7f e4                	jg     1061e6 <vprintfmt+0x244>
            }
            break;
  106202:	e9 6c 01 00 00       	jmp    106373 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106207:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10620a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10620e:	8d 45 14             	lea    0x14(%ebp),%eax
  106211:	89 04 24             	mov    %eax,(%esp)
  106214:	e8 0b fd ff ff       	call   105f24 <getint>
  106219:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10621c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10621f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106225:	85 d2                	test   %edx,%edx
  106227:	79 26                	jns    10624f <vprintfmt+0x2ad>
                putch('-', putdat);
  106229:	8b 45 0c             	mov    0xc(%ebp),%eax
  10622c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106230:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  106237:	8b 45 08             	mov    0x8(%ebp),%eax
  10623a:	ff d0                	call   *%eax
                num = -(long long)num;
  10623c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10623f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106242:	f7 d8                	neg    %eax
  106244:	83 d2 00             	adc    $0x0,%edx
  106247:	f7 da                	neg    %edx
  106249:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10624c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10624f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106256:	e9 a8 00 00 00       	jmp    106303 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  10625b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10625e:	89 44 24 04          	mov    %eax,0x4(%esp)
  106262:	8d 45 14             	lea    0x14(%ebp),%eax
  106265:	89 04 24             	mov    %eax,(%esp)
  106268:	e8 64 fc ff ff       	call   105ed1 <getuint>
  10626d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106270:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106273:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10627a:	e9 84 00 00 00       	jmp    106303 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  10627f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106282:	89 44 24 04          	mov    %eax,0x4(%esp)
  106286:	8d 45 14             	lea    0x14(%ebp),%eax
  106289:	89 04 24             	mov    %eax,(%esp)
  10628c:	e8 40 fc ff ff       	call   105ed1 <getuint>
  106291:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106294:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106297:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  10629e:	eb 63                	jmp    106303 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
  1062a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1062ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1062b1:	ff d0                	call   *%eax
            putch('x', putdat);
  1062b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062ba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1062c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1062c4:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1062c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1062c9:	8d 50 04             	lea    0x4(%eax),%edx
  1062cc:	89 55 14             	mov    %edx,0x14(%ebp)
  1062cf:	8b 00                	mov    (%eax),%eax
  1062d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1062d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1062db:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1062e2:	eb 1f                	jmp    106303 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1062e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1062e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062eb:	8d 45 14             	lea    0x14(%ebp),%eax
  1062ee:	89 04 24             	mov    %eax,(%esp)
  1062f1:	e8 db fb ff ff       	call   105ed1 <getuint>
  1062f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1062f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1062fc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106303:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106307:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10630a:	89 54 24 18          	mov    %edx,0x18(%esp)
  10630e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106311:	89 54 24 14          	mov    %edx,0x14(%esp)
  106315:	89 44 24 10          	mov    %eax,0x10(%esp)
  106319:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10631c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10631f:	89 44 24 08          	mov    %eax,0x8(%esp)
  106323:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106327:	8b 45 0c             	mov    0xc(%ebp),%eax
  10632a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10632e:	8b 45 08             	mov    0x8(%ebp),%eax
  106331:	89 04 24             	mov    %eax,(%esp)
  106334:	e8 94 fa ff ff       	call   105dcd <printnum>
            break;
  106339:	eb 38                	jmp    106373 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10633b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10633e:	89 44 24 04          	mov    %eax,0x4(%esp)
  106342:	89 1c 24             	mov    %ebx,(%esp)
  106345:	8b 45 08             	mov    0x8(%ebp),%eax
  106348:	ff d0                	call   *%eax
            break;
  10634a:	eb 27                	jmp    106373 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10634c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10634f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106353:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  10635a:	8b 45 08             	mov    0x8(%ebp),%eax
  10635d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10635f:	ff 4d 10             	decl   0x10(%ebp)
  106362:	eb 03                	jmp    106367 <vprintfmt+0x3c5>
  106364:	ff 4d 10             	decl   0x10(%ebp)
  106367:	8b 45 10             	mov    0x10(%ebp),%eax
  10636a:	48                   	dec    %eax
  10636b:	0f b6 00             	movzbl (%eax),%eax
  10636e:	3c 25                	cmp    $0x25,%al
  106370:	75 f2                	jne    106364 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
  106372:	90                   	nop
    while (1) {
  106373:	e9 36 fc ff ff       	jmp    105fae <vprintfmt+0xc>
                return;
  106378:	90                   	nop
        }
    }
}
  106379:	83 c4 40             	add    $0x40,%esp
  10637c:	5b                   	pop    %ebx
  10637d:	5e                   	pop    %esi
  10637e:	5d                   	pop    %ebp
  10637f:	c3                   	ret    

00106380 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106380:	f3 0f 1e fb          	endbr32 
  106384:	55                   	push   %ebp
  106385:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106387:	8b 45 0c             	mov    0xc(%ebp),%eax
  10638a:	8b 40 08             	mov    0x8(%eax),%eax
  10638d:	8d 50 01             	lea    0x1(%eax),%edx
  106390:	8b 45 0c             	mov    0xc(%ebp),%eax
  106393:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106396:	8b 45 0c             	mov    0xc(%ebp),%eax
  106399:	8b 10                	mov    (%eax),%edx
  10639b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10639e:	8b 40 04             	mov    0x4(%eax),%eax
  1063a1:	39 c2                	cmp    %eax,%edx
  1063a3:	73 12                	jae    1063b7 <sprintputch+0x37>
        *b->buf ++ = ch;
  1063a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063a8:	8b 00                	mov    (%eax),%eax
  1063aa:	8d 48 01             	lea    0x1(%eax),%ecx
  1063ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  1063b0:	89 0a                	mov    %ecx,(%edx)
  1063b2:	8b 55 08             	mov    0x8(%ebp),%edx
  1063b5:	88 10                	mov    %dl,(%eax)
    }
}
  1063b7:	90                   	nop
  1063b8:	5d                   	pop    %ebp
  1063b9:	c3                   	ret    

001063ba <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1063ba:	f3 0f 1e fb          	endbr32 
  1063be:	55                   	push   %ebp
  1063bf:	89 e5                	mov    %esp,%ebp
  1063c1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1063c4:	8d 45 14             	lea    0x14(%ebp),%eax
  1063c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1063ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1063cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1063d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1063d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1063d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1063df:	8b 45 08             	mov    0x8(%ebp),%eax
  1063e2:	89 04 24             	mov    %eax,(%esp)
  1063e5:	e8 08 00 00 00       	call   1063f2 <vsnprintf>
  1063ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1063ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1063f0:	c9                   	leave  
  1063f1:	c3                   	ret    

001063f2 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1063f2:	f3 0f 1e fb          	endbr32 
  1063f6:	55                   	push   %ebp
  1063f7:	89 e5                	mov    %esp,%ebp
  1063f9:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1063fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1063ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106402:	8b 45 0c             	mov    0xc(%ebp),%eax
  106405:	8d 50 ff             	lea    -0x1(%eax),%edx
  106408:	8b 45 08             	mov    0x8(%ebp),%eax
  10640b:	01 d0                	add    %edx,%eax
  10640d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106410:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106417:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10641b:	74 0a                	je     106427 <vsnprintf+0x35>
  10641d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106420:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106423:	39 c2                	cmp    %eax,%edx
  106425:	76 07                	jbe    10642e <vsnprintf+0x3c>
        return -E_INVAL;
  106427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10642c:	eb 2a                	jmp    106458 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  10642e:	8b 45 14             	mov    0x14(%ebp),%eax
  106431:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106435:	8b 45 10             	mov    0x10(%ebp),%eax
  106438:	89 44 24 08          	mov    %eax,0x8(%esp)
  10643c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  10643f:	89 44 24 04          	mov    %eax,0x4(%esp)
  106443:	c7 04 24 80 63 10 00 	movl   $0x106380,(%esp)
  10644a:	e8 53 fb ff ff       	call   105fa2 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  10644f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106452:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106455:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106458:	c9                   	leave  
  106459:	c3                   	ret    
