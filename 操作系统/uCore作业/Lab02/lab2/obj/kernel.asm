
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 b0 11 00       	mov    $0x11b000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 b0 11 c0       	mov    %eax,0xc011b000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 a0 11 c0       	mov    $0xc011a000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	f3 0f 1e fb          	endbr32 
c010003a:	55                   	push   %ebp
c010003b:	89 e5                	mov    %esp,%ebp
c010003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100040:	b8 88 df 11 c0       	mov    $0xc011df88,%eax
c0100045:	2d 00 d0 11 c0       	sub    $0xc011d000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 d0 11 c0 	movl   $0xc011d000,(%esp)
c010005d:	e8 d4 5b 00 00       	call   c0105c36 <memset>

    cons_init();                // init the console
c0100062:	e8 54 16 00 00       	call   c01016bb <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 64 10 c0 	movl   $0xc0106460,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c 64 10 c0 	movl   $0xc010647c,(%esp)
c010007c:	e8 49 02 00 00       	call   c01002ca <cprintf>

    print_kerninfo();
c0100081:	e8 07 09 00 00       	call   c010098d <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9a 00 00 00       	call   c0100125 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 b1 33 00 00       	call   c0103441 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 a1 17 00 00       	call   c0101836 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 21 19 00 00       	call   c01019bb <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 63 0d 00 00       	call   c0100e02 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 de 18 00 00       	call   c0101982 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
	lab1_switch_test();
c01000a4:	e8 87 01 00 00       	call   c0100230 <lab1_switch_test>
	
    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	f3 0f 1e fb          	endbr32 
c01000af:	55                   	push   %ebp
c01000b0:	89 e5                	mov    %esp,%ebp
c01000b2:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000bc:	00 
c01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c4:	00 
c01000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000cc:	e8 1b 0d 00 00       	call   c0100dec <mon_backtrace>
}
c01000d1:	90                   	nop
c01000d2:	c9                   	leave  
c01000d3:	c3                   	ret    

c01000d4 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d4:	f3 0f 1e fb          	endbr32 
c01000d8:	55                   	push   %ebp
c01000d9:	89 e5                	mov    %esp,%ebp
c01000db:	53                   	push   %ebx
c01000dc:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000df:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e5:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01000eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000ef:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f7:	89 04 24             	mov    %eax,(%esp)
c01000fa:	e8 ac ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000ff:	90                   	nop
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	f3 0f 1e fb          	endbr32 
c010010a:	55                   	push   %ebp
c010010b:	89 e5                	mov    %esp,%ebp
c010010d:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100110:	8b 45 10             	mov    0x10(%ebp),%eax
c0100113:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100117:	8b 45 08             	mov    0x8(%ebp),%eax
c010011a:	89 04 24             	mov    %eax,(%esp)
c010011d:	e8 b2 ff ff ff       	call   c01000d4 <grade_backtrace1>
}
c0100122:	90                   	nop
c0100123:	c9                   	leave  
c0100124:	c3                   	ret    

c0100125 <grade_backtrace>:

void
grade_backtrace(void) {
c0100125:	f3 0f 1e fb          	endbr32 
c0100129:	55                   	push   %ebp
c010012a:	89 e5                	mov    %esp,%ebp
c010012c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100134:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013b:	ff 
c010013c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100147:	e8 ba ff ff ff       	call   c0100106 <grade_backtrace0>
}
c010014c:	90                   	nop
c010014d:	c9                   	leave  
c010014e:	c3                   	ret    

c010014f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014f:	f3 0f 1e fb          	endbr32 
c0100153:	55                   	push   %ebp
c0100154:	89 e5                	mov    %esp,%ebp
c0100156:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100159:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015f:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100162:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100165:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100169:	83 e0 03             	and    $0x3,%eax
c010016c:	89 c2                	mov    %eax,%edx
c010016e:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100173:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100177:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017b:	c7 04 24 81 64 10 c0 	movl   $0xc0106481,(%esp)
c0100182:	e8 43 01 00 00       	call   c01002ca <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100187:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018b:	89 c2                	mov    %eax,%edx
c010018d:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100192:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100196:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019a:	c7 04 24 8f 64 10 c0 	movl   $0xc010648f,(%esp)
c01001a1:	e8 24 01 00 00       	call   c01002ca <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a6:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001aa:	89 c2                	mov    %eax,%edx
c01001ac:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001b1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b9:	c7 04 24 9d 64 10 c0 	movl   $0xc010649d,(%esp)
c01001c0:	e8 05 01 00 00       	call   c01002ca <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c9:	89 c2                	mov    %eax,%edx
c01001cb:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 ab 64 10 c0 	movl   $0xc01064ab,(%esp)
c01001df:	e8 e6 00 00 00       	call   c01002ca <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	89 c2                	mov    %eax,%edx
c01001ea:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c01001ef:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f7:	c7 04 24 b9 64 10 c0 	movl   $0xc01064b9,(%esp)
c01001fe:	e8 c7 00 00 00       	call   c01002ca <cprintf>
    round ++;
c0100203:	a1 00 d0 11 c0       	mov    0xc011d000,%eax
c0100208:	40                   	inc    %eax
c0100209:	a3 00 d0 11 c0       	mov    %eax,0xc011d000
}
c010020e:	90                   	nop
c010020f:	c9                   	leave  
c0100210:	c3                   	ret    

c0100211 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100211:	f3 0f 1e fb          	endbr32 
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
c0100218:	83 ec 08             	sub    $0x8,%esp
c010021b:	cd 78                	int    $0x78
c010021d:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
c010021f:	90                   	nop
c0100220:	5d                   	pop    %ebp
c0100221:	c3                   	ret    

c0100222 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100222:	f3 0f 1e fb          	endbr32 
c0100226:	55                   	push   %ebp
c0100227:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
c0100229:	cd 79                	int    $0x79
c010022b:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
c010022d:	90                   	nop
c010022e:	5d                   	pop    %ebp
c010022f:	c3                   	ret    

c0100230 <lab1_switch_test>:


static void
lab1_switch_test(void) {
c0100230:	f3 0f 1e fb          	endbr32 
c0100234:	55                   	push   %ebp
c0100235:	89 e5                	mov    %esp,%ebp
c0100237:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010023a:	e8 10 ff ff ff       	call   c010014f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010023f:	c7 04 24 c8 64 10 c0 	movl   $0xc01064c8,(%esp)
c0100246:	e8 7f 00 00 00       	call   c01002ca <cprintf>
    lab1_switch_to_user();
c010024b:	e8 c1 ff ff ff       	call   c0100211 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100250:	e8 fa fe ff ff       	call   c010014f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100255:	c7 04 24 e8 64 10 c0 	movl   $0xc01064e8,(%esp)
c010025c:	e8 69 00 00 00       	call   c01002ca <cprintf>
    lab1_switch_to_kernel();
c0100261:	e8 bc ff ff ff       	call   c0100222 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100266:	e8 e4 fe ff ff       	call   c010014f <lab1_print_cur_status>
}
c010026b:	90                   	nop
c010026c:	c9                   	leave  
c010026d:	c3                   	ret    

c010026e <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010026e:	f3 0f 1e fb          	endbr32 
c0100272:	55                   	push   %ebp
c0100273:	89 e5                	mov    %esp,%ebp
c0100275:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100278:	8b 45 08             	mov    0x8(%ebp),%eax
c010027b:	89 04 24             	mov    %eax,(%esp)
c010027e:	e8 69 14 00 00       	call   c01016ec <cons_putc>
    (*cnt) ++;
c0100283:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100286:	8b 00                	mov    (%eax),%eax
c0100288:	8d 50 01             	lea    0x1(%eax),%edx
c010028b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028e:	89 10                	mov    %edx,(%eax)
}
c0100290:	90                   	nop
c0100291:	c9                   	leave  
c0100292:	c3                   	ret    

c0100293 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100293:	f3 0f 1e fb          	endbr32 
c0100297:	55                   	push   %ebp
c0100298:	89 e5                	mov    %esp,%ebp
c010029a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010029d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01002ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
c01002b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01002b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b9:	c7 04 24 6e 02 10 c0 	movl   $0xc010026e,(%esp)
c01002c0:	e8 dd 5c 00 00       	call   c0105fa2 <vprintfmt>
    return cnt;
c01002c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c8:	c9                   	leave  
c01002c9:	c3                   	ret    

c01002ca <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002ca:	f3 0f 1e fb          	endbr32 
c01002ce:	55                   	push   %ebp
c01002cf:	89 e5                	mov    %esp,%ebp
c01002d1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002d4:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e4:	89 04 24             	mov    %eax,(%esp)
c01002e7:	e8 a7 ff ff ff       	call   c0100293 <vcprintf>
c01002ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002f2:	c9                   	leave  
c01002f3:	c3                   	ret    

c01002f4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002f4:	f3 0f 1e fb          	endbr32 
c01002f8:	55                   	push   %ebp
c01002f9:	89 e5                	mov    %esp,%ebp
c01002fb:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100301:	89 04 24             	mov    %eax,(%esp)
c0100304:	e8 e3 13 00 00       	call   c01016ec <cons_putc>
}
c0100309:	90                   	nop
c010030a:	c9                   	leave  
c010030b:	c3                   	ret    

c010030c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010030c:	f3 0f 1e fb          	endbr32 
c0100310:	55                   	push   %ebp
c0100311:	89 e5                	mov    %esp,%ebp
c0100313:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100316:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010031d:	eb 13                	jmp    c0100332 <cputs+0x26>
        cputch(c, &cnt);
c010031f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100323:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100326:	89 54 24 04          	mov    %edx,0x4(%esp)
c010032a:	89 04 24             	mov    %eax,(%esp)
c010032d:	e8 3c ff ff ff       	call   c010026e <cputch>
    while ((c = *str ++) != '\0') {
c0100332:	8b 45 08             	mov    0x8(%ebp),%eax
c0100335:	8d 50 01             	lea    0x1(%eax),%edx
c0100338:	89 55 08             	mov    %edx,0x8(%ebp)
c010033b:	0f b6 00             	movzbl (%eax),%eax
c010033e:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100341:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100345:	75 d8                	jne    c010031f <cputs+0x13>
    }
    cputch('\n', &cnt);
c0100347:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010034a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100355:	e8 14 ff ff ff       	call   c010026e <cputch>
    return cnt;
c010035a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010035d:	c9                   	leave  
c010035e:	c3                   	ret    

c010035f <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010035f:	f3 0f 1e fb          	endbr32 
c0100363:	55                   	push   %ebp
c0100364:	89 e5                	mov    %esp,%ebp
c0100366:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100369:	90                   	nop
c010036a:	e8 be 13 00 00       	call   c010172d <cons_getc>
c010036f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100372:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100376:	74 f2                	je     c010036a <getchar+0xb>
        /* do nothing */;
    return c;
c0100378:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037b:	c9                   	leave  
c010037c:	c3                   	ret    

c010037d <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010037d:	f3 0f 1e fb          	endbr32 
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100387:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010038b:	74 13                	je     c01003a0 <readline+0x23>
        cprintf("%s", prompt);
c010038d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100390:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100394:	c7 04 24 07 65 10 c0 	movl   $0xc0106507,(%esp)
c010039b:	e8 2a ff ff ff       	call   c01002ca <cprintf>
    }
    int i = 0, c;
c01003a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01003a7:	e8 b3 ff ff ff       	call   c010035f <getchar>
c01003ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01003af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003b3:	79 07                	jns    c01003bc <readline+0x3f>
            return NULL;
c01003b5:	b8 00 00 00 00       	mov    $0x0,%eax
c01003ba:	eb 78                	jmp    c0100434 <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01003bc:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01003c0:	7e 28                	jle    c01003ea <readline+0x6d>
c01003c2:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01003c9:	7f 1f                	jg     c01003ea <readline+0x6d>
            cputchar(c);
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ce:	89 04 24             	mov    %eax,(%esp)
c01003d1:	e8 1e ff ff ff       	call   c01002f4 <cputchar>
            buf[i ++] = c;
c01003d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d9:	8d 50 01             	lea    0x1(%eax),%edx
c01003dc:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003e2:	88 90 20 d0 11 c0    	mov    %dl,-0x3fee2fe0(%eax)
c01003e8:	eb 45                	jmp    c010042f <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
c01003ea:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003ee:	75 16                	jne    c0100406 <readline+0x89>
c01003f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f4:	7e 10                	jle    c0100406 <readline+0x89>
            cputchar(c);
c01003f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f9:	89 04 24             	mov    %eax,(%esp)
c01003fc:	e8 f3 fe ff ff       	call   c01002f4 <cputchar>
            i --;
c0100401:	ff 4d f4             	decl   -0xc(%ebp)
c0100404:	eb 29                	jmp    c010042f <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
c0100406:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c010040a:	74 06                	je     c0100412 <readline+0x95>
c010040c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0100410:	75 95                	jne    c01003a7 <readline+0x2a>
            cputchar(c);
c0100412:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100415:	89 04 24             	mov    %eax,(%esp)
c0100418:	e8 d7 fe ff ff       	call   c01002f4 <cputchar>
            buf[i] = '\0';
c010041d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100420:	05 20 d0 11 c0       	add    $0xc011d020,%eax
c0100425:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100428:	b8 20 d0 11 c0       	mov    $0xc011d020,%eax
c010042d:	eb 05                	jmp    c0100434 <readline+0xb7>
        c = getchar();
c010042f:	e9 73 ff ff ff       	jmp    c01003a7 <readline+0x2a>
        }
    }
}
c0100434:	c9                   	leave  
c0100435:	c3                   	ret    

c0100436 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100436:	f3 0f 1e fb          	endbr32 
c010043a:	55                   	push   %ebp
c010043b:	89 e5                	mov    %esp,%ebp
c010043d:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100440:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
c0100445:	85 c0                	test   %eax,%eax
c0100447:	75 5b                	jne    c01004a4 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100449:	c7 05 20 d4 11 c0 01 	movl   $0x1,0xc011d420
c0100450:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100453:	8d 45 14             	lea    0x14(%ebp),%eax
c0100456:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100459:	8b 45 0c             	mov    0xc(%ebp),%eax
c010045c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100460:	8b 45 08             	mov    0x8(%ebp),%eax
c0100463:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100467:	c7 04 24 0a 65 10 c0 	movl   $0xc010650a,(%esp)
c010046e:	e8 57 fe ff ff       	call   c01002ca <cprintf>
    vcprintf(fmt, ap);
c0100473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100476:	89 44 24 04          	mov    %eax,0x4(%esp)
c010047a:	8b 45 10             	mov    0x10(%ebp),%eax
c010047d:	89 04 24             	mov    %eax,(%esp)
c0100480:	e8 0e fe ff ff       	call   c0100293 <vcprintf>
    cprintf("\n");
c0100485:	c7 04 24 26 65 10 c0 	movl   $0xc0106526,(%esp)
c010048c:	e8 39 fe ff ff       	call   c01002ca <cprintf>
    
    cprintf("stack trackback:\n");
c0100491:	c7 04 24 28 65 10 c0 	movl   $0xc0106528,(%esp)
c0100498:	e8 2d fe ff ff       	call   c01002ca <cprintf>
    print_stackframe();
c010049d:	e8 3d 06 00 00       	call   c0100adf <print_stackframe>
c01004a2:	eb 01                	jmp    c01004a5 <__panic+0x6f>
        goto panic_dead;
c01004a4:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004a5:	e8 e4 14 00 00       	call   c010198e <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004b1:	e8 5d 08 00 00       	call   c0100d13 <kmonitor>
c01004b6:	eb f2                	jmp    c01004aa <__panic+0x74>

c01004b8 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01004b8:	f3 0f 1e fb          	endbr32 
c01004bc:	55                   	push   %ebp
c01004bd:	89 e5                	mov    %esp,%ebp
c01004bf:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01004c2:	8d 45 14             	lea    0x14(%ebp),%eax
c01004c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004cb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004d6:	c7 04 24 3a 65 10 c0 	movl   $0xc010653a,(%esp)
c01004dd:	e8 e8 fd ff ff       	call   c01002ca <cprintf>
    vcprintf(fmt, ap);
c01004e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ec:	89 04 24             	mov    %eax,(%esp)
c01004ef:	e8 9f fd ff ff       	call   c0100293 <vcprintf>
    cprintf("\n");
c01004f4:	c7 04 24 26 65 10 c0 	movl   $0xc0106526,(%esp)
c01004fb:	e8 ca fd ff ff       	call   c01002ca <cprintf>
    va_end(ap);
}
c0100500:	90                   	nop
c0100501:	c9                   	leave  
c0100502:	c3                   	ret    

c0100503 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100503:	f3 0f 1e fb          	endbr32 
c0100507:	55                   	push   %ebp
c0100508:	89 e5                	mov    %esp,%ebp
    return is_panic;
c010050a:	a1 20 d4 11 c0       	mov    0xc011d420,%eax
}
c010050f:	5d                   	pop    %ebp
c0100510:	c3                   	ret    

c0100511 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100511:	f3 0f 1e fb          	endbr32 
c0100515:	55                   	push   %ebp
c0100516:	89 e5                	mov    %esp,%ebp
c0100518:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100523:	8b 45 10             	mov    0x10(%ebp),%eax
c0100526:	8b 00                	mov    (%eax),%eax
c0100528:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010052b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100532:	e9 ca 00 00 00       	jmp    c0100601 <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
c0100537:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010053d:	01 d0                	add    %edx,%eax
c010053f:	89 c2                	mov    %eax,%edx
c0100541:	c1 ea 1f             	shr    $0x1f,%edx
c0100544:	01 d0                	add    %edx,%eax
c0100546:	d1 f8                	sar    %eax
c0100548:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010054b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010054e:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100551:	eb 03                	jmp    c0100556 <stab_binsearch+0x45>
            m --;
c0100553:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100556:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100559:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010055c:	7c 1f                	jl     c010057d <stab_binsearch+0x6c>
c010055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100561:	89 d0                	mov    %edx,%eax
c0100563:	01 c0                	add    %eax,%eax
c0100565:	01 d0                	add    %edx,%eax
c0100567:	c1 e0 02             	shl    $0x2,%eax
c010056a:	89 c2                	mov    %eax,%edx
c010056c:	8b 45 08             	mov    0x8(%ebp),%eax
c010056f:	01 d0                	add    %edx,%eax
c0100571:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100575:	0f b6 c0             	movzbl %al,%eax
c0100578:	39 45 14             	cmp    %eax,0x14(%ebp)
c010057b:	75 d6                	jne    c0100553 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
c010057d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100580:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100583:	7d 09                	jge    c010058e <stab_binsearch+0x7d>
            l = true_m + 1;
c0100585:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100588:	40                   	inc    %eax
c0100589:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010058c:	eb 73                	jmp    c0100601 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
c010058e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100595:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100598:	89 d0                	mov    %edx,%eax
c010059a:	01 c0                	add    %eax,%eax
c010059c:	01 d0                	add    %edx,%eax
c010059e:	c1 e0 02             	shl    $0x2,%eax
c01005a1:	89 c2                	mov    %eax,%edx
c01005a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01005a6:	01 d0                	add    %edx,%eax
c01005a8:	8b 40 08             	mov    0x8(%eax),%eax
c01005ab:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005ae:	76 11                	jbe    c01005c1 <stab_binsearch+0xb0>
            *region_left = m;
c01005b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b6:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01005b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005bb:	40                   	inc    %eax
c01005bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01005bf:	eb 40                	jmp    c0100601 <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	89 d0                	mov    %edx,%eax
c01005c6:	01 c0                	add    %eax,%eax
c01005c8:	01 d0                	add    %edx,%eax
c01005ca:	c1 e0 02             	shl    $0x2,%eax
c01005cd:	89 c2                	mov    %eax,%edx
c01005cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d2:	01 d0                	add    %edx,%eax
c01005d4:	8b 40 08             	mov    0x8(%eax),%eax
c01005d7:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005da:	73 14                	jae    c01005f0 <stab_binsearch+0xdf>
            *region_right = m - 1;
c01005dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005df:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e5:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ea:	48                   	dec    %eax
c01005eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ee:	eb 11                	jmp    c0100601 <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005f6:	89 10                	mov    %edx,(%eax)
            l = m;
c01005f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005fb:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005fe:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100601:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100604:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100607:	0f 8e 2a ff ff ff    	jle    c0100537 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
c010060d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100611:	75 0f                	jne    c0100622 <stab_binsearch+0x111>
        *region_right = *region_left - 1;
c0100613:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100616:	8b 00                	mov    (%eax),%eax
c0100618:	8d 50 ff             	lea    -0x1(%eax),%edx
c010061b:	8b 45 10             	mov    0x10(%ebp),%eax
c010061e:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100620:	eb 3e                	jmp    c0100660 <stab_binsearch+0x14f>
        l = *region_right;
c0100622:	8b 45 10             	mov    0x10(%ebp),%eax
c0100625:	8b 00                	mov    (%eax),%eax
c0100627:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010062a:	eb 03                	jmp    c010062f <stab_binsearch+0x11e>
c010062c:	ff 4d fc             	decl   -0x4(%ebp)
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	8b 00                	mov    (%eax),%eax
c0100634:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100637:	7e 1f                	jle    c0100658 <stab_binsearch+0x147>
c0100639:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010063c:	89 d0                	mov    %edx,%eax
c010063e:	01 c0                	add    %eax,%eax
c0100640:	01 d0                	add    %edx,%eax
c0100642:	c1 e0 02             	shl    $0x2,%eax
c0100645:	89 c2                	mov    %eax,%edx
c0100647:	8b 45 08             	mov    0x8(%ebp),%eax
c010064a:	01 d0                	add    %edx,%eax
c010064c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100650:	0f b6 c0             	movzbl %al,%eax
c0100653:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100656:	75 d4                	jne    c010062c <stab_binsearch+0x11b>
        *region_left = l;
c0100658:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010065e:	89 10                	mov    %edx,(%eax)
}
c0100660:	90                   	nop
c0100661:	c9                   	leave  
c0100662:	c3                   	ret    

c0100663 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100663:	f3 0f 1e fb          	endbr32 
c0100667:	55                   	push   %ebp
c0100668:	89 e5                	mov    %esp,%ebp
c010066a:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010066d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100670:	c7 00 58 65 10 c0    	movl   $0xc0106558,(%eax)
    info->eip_line = 0;
c0100676:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100679:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100680:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100683:	c7 40 08 58 65 10 c0 	movl   $0xc0106558,0x8(%eax)
    info->eip_fn_namelen = 9;
c010068a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010068d:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100694:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100697:	8b 55 08             	mov    0x8(%ebp),%edx
c010069a:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010069d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01006a7:	c7 45 f4 74 77 10 c0 	movl   $0xc0107774,-0xc(%ebp)
    stab_end = __STAB_END__;
c01006ae:	c7 45 f0 94 44 11 c0 	movl   $0xc0114494,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01006b5:	c7 45 ec 95 44 11 c0 	movl   $0xc0114495,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01006bc:	c7 45 e8 16 70 11 c0 	movl   $0xc0117016,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c9:	76 0b                	jbe    c01006d6 <debuginfo_eip+0x73>
c01006cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006ce:	48                   	dec    %eax
c01006cf:	0f b6 00             	movzbl (%eax),%eax
c01006d2:	84 c0                	test   %al,%al
c01006d4:	74 0a                	je     c01006e0 <debuginfo_eip+0x7d>
        return -1;
c01006d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006db:	e9 ab 02 00 00       	jmp    c010098b <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006ea:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006ed:	c1 f8 02             	sar    $0x2,%eax
c01006f0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006f6:	48                   	dec    %eax
c01006f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fd:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100701:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100708:	00 
c0100709:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010070c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100710:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100713:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071a:	89 04 24             	mov    %eax,(%esp)
c010071d:	e8 ef fd ff ff       	call   c0100511 <stab_binsearch>
    if (lfile == 0)
c0100722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100725:	85 c0                	test   %eax,%eax
c0100727:	75 0a                	jne    c0100733 <debuginfo_eip+0xd0>
        return -1;
c0100729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010072e:	e9 58 02 00 00       	jmp    c010098b <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100736:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100739:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010073f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100742:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100746:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010074d:	00 
c010074e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100751:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100755:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100758:	89 44 24 04          	mov    %eax,0x4(%esp)
c010075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075f:	89 04 24             	mov    %eax,(%esp)
c0100762:	e8 aa fd ff ff       	call   c0100511 <stab_binsearch>

    if (lfun <= rfun) {
c0100767:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010076a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010076d:	39 c2                	cmp    %eax,%edx
c010076f:	7f 78                	jg     c01007e9 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100771:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100774:	89 c2                	mov    %eax,%edx
c0100776:	89 d0                	mov    %edx,%eax
c0100778:	01 c0                	add    %eax,%eax
c010077a:	01 d0                	add    %edx,%eax
c010077c:	c1 e0 02             	shl    $0x2,%eax
c010077f:	89 c2                	mov    %eax,%edx
c0100781:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	8b 10                	mov    (%eax),%edx
c0100788:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010078b:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010078e:	39 c2                	cmp    %eax,%edx
c0100790:	73 22                	jae    c01007b4 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100792:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100795:	89 c2                	mov    %eax,%edx
c0100797:	89 d0                	mov    %edx,%eax
c0100799:	01 c0                	add    %eax,%eax
c010079b:	01 d0                	add    %edx,%eax
c010079d:	c1 e0 02             	shl    $0x2,%eax
c01007a0:	89 c2                	mov    %eax,%edx
c01007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a5:	01 d0                	add    %edx,%eax
c01007a7:	8b 10                	mov    (%eax),%edx
c01007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007ac:	01 c2                	add    %eax,%edx
c01007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b1:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007b7:	89 c2                	mov    %eax,%edx
c01007b9:	89 d0                	mov    %edx,%eax
c01007bb:	01 c0                	add    %eax,%eax
c01007bd:	01 d0                	add    %edx,%eax
c01007bf:	c1 e0 02             	shl    $0x2,%eax
c01007c2:	89 c2                	mov    %eax,%edx
c01007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c7:	01 d0                	add    %edx,%eax
c01007c9:	8b 50 08             	mov    0x8(%eax),%edx
c01007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cf:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d5:	8b 40 10             	mov    0x10(%eax),%eax
c01007d8:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007e7:	eb 15                	jmp    c01007fe <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ec:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ef:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100801:	8b 40 08             	mov    0x8(%eax),%eax
c0100804:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010080b:	00 
c010080c:	89 04 24             	mov    %eax,(%esp)
c010080f:	e8 96 52 00 00       	call   c0105aaa <strfind>
c0100814:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100817:	8b 52 08             	mov    0x8(%edx),%edx
c010081a:	29 d0                	sub    %edx,%eax
c010081c:	89 c2                	mov    %eax,%edx
c010081e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100821:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100824:	8b 45 08             	mov    0x8(%ebp),%eax
c0100827:	89 44 24 10          	mov    %eax,0x10(%esp)
c010082b:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100832:	00 
c0100833:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100836:	89 44 24 08          	mov    %eax,0x8(%esp)
c010083a:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010083d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100841:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100844:	89 04 24             	mov    %eax,(%esp)
c0100847:	e8 c5 fc ff ff       	call   c0100511 <stab_binsearch>
    if (lline <= rline) {
c010084c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100852:	39 c2                	cmp    %eax,%edx
c0100854:	7f 23                	jg     c0100879 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
c0100856:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100859:	89 c2                	mov    %eax,%edx
c010085b:	89 d0                	mov    %edx,%eax
c010085d:	01 c0                	add    %eax,%eax
c010085f:	01 d0                	add    %edx,%eax
c0100861:	c1 e0 02             	shl    $0x2,%eax
c0100864:	89 c2                	mov    %eax,%edx
c0100866:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100869:	01 d0                	add    %edx,%eax
c010086b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010086f:	89 c2                	mov    %eax,%edx
c0100871:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100874:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100877:	eb 11                	jmp    c010088a <debuginfo_eip+0x227>
        return -1;
c0100879:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010087e:	e9 08 01 00 00       	jmp    c010098b <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100883:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100886:	48                   	dec    %eax
c0100887:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c010088a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010088d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100890:	39 c2                	cmp    %eax,%edx
c0100892:	7c 56                	jl     c01008ea <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
c0100894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100897:	89 c2                	mov    %eax,%edx
c0100899:	89 d0                	mov    %edx,%eax
c010089b:	01 c0                	add    %eax,%eax
c010089d:	01 d0                	add    %edx,%eax
c010089f:	c1 e0 02             	shl    $0x2,%eax
c01008a2:	89 c2                	mov    %eax,%edx
c01008a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a7:	01 d0                	add    %edx,%eax
c01008a9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008ad:	3c 84                	cmp    $0x84,%al
c01008af:	74 39                	je     c01008ea <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b4:	89 c2                	mov    %eax,%edx
c01008b6:	89 d0                	mov    %edx,%eax
c01008b8:	01 c0                	add    %eax,%eax
c01008ba:	01 d0                	add    %edx,%eax
c01008bc:	c1 e0 02             	shl    $0x2,%eax
c01008bf:	89 c2                	mov    %eax,%edx
c01008c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c4:	01 d0                	add    %edx,%eax
c01008c6:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008ca:	3c 64                	cmp    $0x64,%al
c01008cc:	75 b5                	jne    c0100883 <debuginfo_eip+0x220>
c01008ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d1:	89 c2                	mov    %eax,%edx
c01008d3:	89 d0                	mov    %edx,%eax
c01008d5:	01 c0                	add    %eax,%eax
c01008d7:	01 d0                	add    %edx,%eax
c01008d9:	c1 e0 02             	shl    $0x2,%eax
c01008dc:	89 c2                	mov    %eax,%edx
c01008de:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e1:	01 d0                	add    %edx,%eax
c01008e3:	8b 40 08             	mov    0x8(%eax),%eax
c01008e6:	85 c0                	test   %eax,%eax
c01008e8:	74 99                	je     c0100883 <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008f0:	39 c2                	cmp    %eax,%edx
c01008f2:	7c 42                	jl     c0100936 <debuginfo_eip+0x2d3>
c01008f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f7:	89 c2                	mov    %eax,%edx
c01008f9:	89 d0                	mov    %edx,%eax
c01008fb:	01 c0                	add    %eax,%eax
c01008fd:	01 d0                	add    %edx,%eax
c01008ff:	c1 e0 02             	shl    $0x2,%eax
c0100902:	89 c2                	mov    %eax,%edx
c0100904:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100907:	01 d0                	add    %edx,%eax
c0100909:	8b 10                	mov    (%eax),%edx
c010090b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010090e:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100911:	39 c2                	cmp    %eax,%edx
c0100913:	73 21                	jae    c0100936 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100915:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100918:	89 c2                	mov    %eax,%edx
c010091a:	89 d0                	mov    %edx,%eax
c010091c:	01 c0                	add    %eax,%eax
c010091e:	01 d0                	add    %edx,%eax
c0100920:	c1 e0 02             	shl    $0x2,%eax
c0100923:	89 c2                	mov    %eax,%edx
c0100925:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100928:	01 d0                	add    %edx,%eax
c010092a:	8b 10                	mov    (%eax),%edx
c010092c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092f:	01 c2                	add    %eax,%edx
c0100931:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100934:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100936:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100939:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010093c:	39 c2                	cmp    %eax,%edx
c010093e:	7d 46                	jge    c0100986 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
c0100940:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100943:	40                   	inc    %eax
c0100944:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100947:	eb 16                	jmp    c010095f <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100949:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094c:	8b 40 14             	mov    0x14(%eax),%eax
c010094f:	8d 50 01             	lea    0x1(%eax),%edx
c0100952:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100955:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100958:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010095b:	40                   	inc    %eax
c010095c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100962:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100965:	39 c2                	cmp    %eax,%edx
c0100967:	7d 1d                	jge    c0100986 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100969:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010096c:	89 c2                	mov    %eax,%edx
c010096e:	89 d0                	mov    %edx,%eax
c0100970:	01 c0                	add    %eax,%eax
c0100972:	01 d0                	add    %edx,%eax
c0100974:	c1 e0 02             	shl    $0x2,%eax
c0100977:	89 c2                	mov    %eax,%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100982:	3c a0                	cmp    $0xa0,%al
c0100984:	74 c3                	je     c0100949 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
c0100986:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010098b:	c9                   	leave  
c010098c:	c3                   	ret    

c010098d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010098d:	f3 0f 1e fb          	endbr32 
c0100991:	55                   	push   %ebp
c0100992:	89 e5                	mov    %esp,%ebp
c0100994:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100997:	c7 04 24 62 65 10 c0 	movl   $0xc0106562,(%esp)
c010099e:	e8 27 f9 ff ff       	call   c01002ca <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01009a3:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009aa:	c0 
c01009ab:	c7 04 24 7b 65 10 c0 	movl   $0xc010657b,(%esp)
c01009b2:	e8 13 f9 ff ff       	call   c01002ca <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b7:	c7 44 24 04 5a 64 10 	movl   $0xc010645a,0x4(%esp)
c01009be:	c0 
c01009bf:	c7 04 24 93 65 10 c0 	movl   $0xc0106593,(%esp)
c01009c6:	e8 ff f8 ff ff       	call   c01002ca <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009cb:	c7 44 24 04 00 d0 11 	movl   $0xc011d000,0x4(%esp)
c01009d2:	c0 
c01009d3:	c7 04 24 ab 65 10 c0 	movl   $0xc01065ab,(%esp)
c01009da:	e8 eb f8 ff ff       	call   c01002ca <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009df:	c7 44 24 04 88 df 11 	movl   $0xc011df88,0x4(%esp)
c01009e6:	c0 
c01009e7:	c7 04 24 c3 65 10 c0 	movl   $0xc01065c3,(%esp)
c01009ee:	e8 d7 f8 ff ff       	call   c01002ca <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009f3:	b8 88 df 11 c0       	mov    $0xc011df88,%eax
c01009f8:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009fd:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100a02:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a08:	85 c0                	test   %eax,%eax
c0100a0a:	0f 48 c2             	cmovs  %edx,%eax
c0100a0d:	c1 f8 0a             	sar    $0xa,%eax
c0100a10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a14:	c7 04 24 dc 65 10 c0 	movl   $0xc01065dc,(%esp)
c0100a1b:	e8 aa f8 ff ff       	call   c01002ca <cprintf>
}
c0100a20:	90                   	nop
c0100a21:	c9                   	leave  
c0100a22:	c3                   	ret    

c0100a23 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a23:	f3 0f 1e fb          	endbr32 
c0100a27:	55                   	push   %ebp
c0100a28:	89 e5                	mov    %esp,%ebp
c0100a2a:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a30:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a3a:	89 04 24             	mov    %eax,(%esp)
c0100a3d:	e8 21 fc ff ff       	call   c0100663 <debuginfo_eip>
c0100a42:	85 c0                	test   %eax,%eax
c0100a44:	74 15                	je     c0100a5b <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a46:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4d:	c7 04 24 06 66 10 c0 	movl   $0xc0106606,(%esp)
c0100a54:	e8 71 f8 ff ff       	call   c01002ca <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a59:	eb 6c                	jmp    c0100ac7 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a62:	eb 1b                	jmp    c0100a7f <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100a64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6a:	01 d0                	add    %edx,%eax
c0100a6c:	0f b6 10             	movzbl (%eax),%edx
c0100a6f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a78:	01 c8                	add    %ecx,%eax
c0100a7a:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a7c:	ff 45 f4             	incl   -0xc(%ebp)
c0100a7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a85:	7c dd                	jl     c0100a64 <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100a87:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a90:	01 d0                	add    %edx,%eax
c0100a92:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a95:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a98:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a9b:	89 d1                	mov    %edx,%ecx
c0100a9d:	29 c1                	sub    %eax,%ecx
c0100a9f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100aa2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa9:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aaf:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100ab3:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100abb:	c7 04 24 22 66 10 c0 	movl   $0xc0106622,(%esp)
c0100ac2:	e8 03 f8 ff ff       	call   c01002ca <cprintf>
}
c0100ac7:	90                   	nop
c0100ac8:	c9                   	leave  
c0100ac9:	c3                   	ret    

c0100aca <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100aca:	f3 0f 1e fb          	endbr32 
c0100ace:	55                   	push   %ebp
c0100acf:	89 e5                	mov    %esp,%ebp
c0100ad1:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100ad4:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ad7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ada:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100add:	c9                   	leave  
c0100ade:	c3                   	ret    

c0100adf <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100adf:	f3 0f 1e fb          	endbr32 
c0100ae3:	55                   	push   %ebp
c0100ae4:	89 e5                	mov    %esp,%ebp
c0100ae6:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae9:	89 e8                	mov    %ebp,%eax
c0100aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100aee:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp = read_ebp(), eip = read_eip();
c0100af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100af4:	e8 d1 ff ff ff       	call   c0100aca <read_eip>
c0100af9:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100afc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100b03:	e9 84 00 00 00       	jmp    c0100b8c <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b16:	c7 04 24 34 66 10 c0 	movl   $0xc0106634,(%esp)
c0100b1d:	e8 a8 f7 ff ff       	call   c01002ca <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b25:	83 c0 08             	add    $0x8,%eax
c0100b28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100b2b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100b32:	eb 24                	jmp    c0100b58 <print_stackframe+0x79>
            cprintf("0x%08x ", args[j]);
c0100b34:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b37:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b41:	01 d0                	add    %edx,%eax
c0100b43:	8b 00                	mov    (%eax),%eax
c0100b45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b49:	c7 04 24 50 66 10 c0 	movl   $0xc0106650,(%esp)
c0100b50:	e8 75 f7 ff ff       	call   c01002ca <cprintf>
        for (j = 0; j < 4; j ++) {
c0100b55:	ff 45 e8             	incl   -0x18(%ebp)
c0100b58:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b5c:	7e d6                	jle    c0100b34 <print_stackframe+0x55>
        }
        cprintf("\n");
c0100b5e:	c7 04 24 58 66 10 c0 	movl   $0xc0106658,(%esp)
c0100b65:	e8 60 f7 ff ff       	call   c01002ca <cprintf>
        print_debuginfo(eip - 1);
c0100b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b6d:	48                   	dec    %eax
c0100b6e:	89 04 24             	mov    %eax,(%esp)
c0100b71:	e8 ad fe ff ff       	call   c0100a23 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b79:	83 c0 04             	add    $0x4,%eax
c0100b7c:	8b 00                	mov    (%eax),%eax
c0100b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b84:	8b 00                	mov    (%eax),%eax
c0100b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b89:	ff 45 ec             	incl   -0x14(%ebp)
c0100b8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b90:	74 0a                	je     c0100b9c <print_stackframe+0xbd>
c0100b92:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b96:	0f 8e 6c ff ff ff    	jle    c0100b08 <print_stackframe+0x29>
    }
}
c0100b9c:	90                   	nop
c0100b9d:	c9                   	leave  
c0100b9e:	c3                   	ret    

c0100b9f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b9f:	f3 0f 1e fb          	endbr32 
c0100ba3:	55                   	push   %ebp
c0100ba4:	89 e5                	mov    %esp,%ebp
c0100ba6:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100ba9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bb0:	eb 0c                	jmp    c0100bbe <parse+0x1f>
            *buf ++ = '\0';
c0100bb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bb5:	8d 50 01             	lea    0x1(%eax),%edx
c0100bb8:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bbb:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc1:	0f b6 00             	movzbl (%eax),%eax
c0100bc4:	84 c0                	test   %al,%al
c0100bc6:	74 1d                	je     c0100be5 <parse+0x46>
c0100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcb:	0f b6 00             	movzbl (%eax),%eax
c0100bce:	0f be c0             	movsbl %al,%eax
c0100bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bd5:	c7 04 24 dc 66 10 c0 	movl   $0xc01066dc,(%esp)
c0100bdc:	e8 93 4e 00 00       	call   c0105a74 <strchr>
c0100be1:	85 c0                	test   %eax,%eax
c0100be3:	75 cd                	jne    c0100bb2 <parse+0x13>
        }
        if (*buf == '\0') {
c0100be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be8:	0f b6 00             	movzbl (%eax),%eax
c0100beb:	84 c0                	test   %al,%al
c0100bed:	74 65                	je     c0100c54 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bef:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bf3:	75 14                	jne    c0100c09 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bf5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bfc:	00 
c0100bfd:	c7 04 24 e1 66 10 c0 	movl   $0xc01066e1,(%esp)
c0100c04:	e8 c1 f6 ff ff       	call   c01002ca <cprintf>
        }
        argv[argc ++] = buf;
c0100c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0c:	8d 50 01             	lea    0x1(%eax),%edx
c0100c0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c1c:	01 c2                	add    %eax,%edx
c0100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c21:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c23:	eb 03                	jmp    c0100c28 <parse+0x89>
            buf ++;
c0100c25:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2b:	0f b6 00             	movzbl (%eax),%eax
c0100c2e:	84 c0                	test   %al,%al
c0100c30:	74 8c                	je     c0100bbe <parse+0x1f>
c0100c32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c35:	0f b6 00             	movzbl (%eax),%eax
c0100c38:	0f be c0             	movsbl %al,%eax
c0100c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3f:	c7 04 24 dc 66 10 c0 	movl   $0xc01066dc,(%esp)
c0100c46:	e8 29 4e 00 00       	call   c0105a74 <strchr>
c0100c4b:	85 c0                	test   %eax,%eax
c0100c4d:	74 d6                	je     c0100c25 <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c4f:	e9 6a ff ff ff       	jmp    c0100bbe <parse+0x1f>
            break;
c0100c54:	90                   	nop
        }
    }
    return argc;
c0100c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c58:	c9                   	leave  
c0100c59:	c3                   	ret    

c0100c5a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c5a:	f3 0f 1e fb          	endbr32 
c0100c5e:	55                   	push   %ebp
c0100c5f:	89 e5                	mov    %esp,%ebp
c0100c61:	53                   	push   %ebx
c0100c62:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c65:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c6f:	89 04 24             	mov    %eax,(%esp)
c0100c72:	e8 28 ff ff ff       	call   c0100b9f <parse>
c0100c77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c7e:	75 0a                	jne    c0100c8a <runcmd+0x30>
        return 0;
c0100c80:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c85:	e9 83 00 00 00       	jmp    c0100d0d <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c91:	eb 5a                	jmp    c0100ced <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c93:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c99:	89 d0                	mov    %edx,%eax
c0100c9b:	01 c0                	add    %eax,%eax
c0100c9d:	01 d0                	add    %edx,%eax
c0100c9f:	c1 e0 02             	shl    $0x2,%eax
c0100ca2:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100ca7:	8b 00                	mov    (%eax),%eax
c0100ca9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100cad:	89 04 24             	mov    %eax,(%esp)
c0100cb0:	e8 1b 4d 00 00       	call   c01059d0 <strcmp>
c0100cb5:	85 c0                	test   %eax,%eax
c0100cb7:	75 31                	jne    c0100cea <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cbc:	89 d0                	mov    %edx,%eax
c0100cbe:	01 c0                	add    %eax,%eax
c0100cc0:	01 d0                	add    %edx,%eax
c0100cc2:	c1 e0 02             	shl    $0x2,%eax
c0100cc5:	05 08 a0 11 c0       	add    $0xc011a008,%eax
c0100cca:	8b 10                	mov    (%eax),%edx
c0100ccc:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100ccf:	83 c0 04             	add    $0x4,%eax
c0100cd2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100cd5:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100cdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ce3:	89 1c 24             	mov    %ebx,(%esp)
c0100ce6:	ff d2                	call   *%edx
c0100ce8:	eb 23                	jmp    c0100d0d <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cea:	ff 45 f4             	incl   -0xc(%ebp)
c0100ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cf0:	83 f8 02             	cmp    $0x2,%eax
c0100cf3:	76 9e                	jbe    c0100c93 <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cf5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cf8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cfc:	c7 04 24 ff 66 10 c0 	movl   $0xc01066ff,(%esp)
c0100d03:	e8 c2 f5 ff ff       	call   c01002ca <cprintf>
    return 0;
c0100d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d0d:	83 c4 64             	add    $0x64,%esp
c0100d10:	5b                   	pop    %ebx
c0100d11:	5d                   	pop    %ebp
c0100d12:	c3                   	ret    

c0100d13 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d13:	f3 0f 1e fb          	endbr32 
c0100d17:	55                   	push   %ebp
c0100d18:	89 e5                	mov    %esp,%ebp
c0100d1a:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d1d:	c7 04 24 18 67 10 c0 	movl   $0xc0106718,(%esp)
c0100d24:	e8 a1 f5 ff ff       	call   c01002ca <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d29:	c7 04 24 40 67 10 c0 	movl   $0xc0106740,(%esp)
c0100d30:	e8 95 f5 ff ff       	call   c01002ca <cprintf>

    if (tf != NULL) {
c0100d35:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d39:	74 0b                	je     c0100d46 <kmonitor+0x33>
        print_trapframe(tf);
c0100d3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3e:	89 04 24             	mov    %eax,(%esp)
c0100d41:	e8 3a 0e 00 00       	call   c0101b80 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d46:	c7 04 24 65 67 10 c0 	movl   $0xc0106765,(%esp)
c0100d4d:	e8 2b f6 ff ff       	call   c010037d <readline>
c0100d52:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d59:	74 eb                	je     c0100d46 <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100d5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d65:	89 04 24             	mov    %eax,(%esp)
c0100d68:	e8 ed fe ff ff       	call   c0100c5a <runcmd>
c0100d6d:	85 c0                	test   %eax,%eax
c0100d6f:	78 02                	js     c0100d73 <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100d71:	eb d3                	jmp    c0100d46 <kmonitor+0x33>
                break;
c0100d73:	90                   	nop
            }
        }
    }
}
c0100d74:	90                   	nop
c0100d75:	c9                   	leave  
c0100d76:	c3                   	ret    

c0100d77 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d77:	f3 0f 1e fb          	endbr32 
c0100d7b:	55                   	push   %ebp
c0100d7c:	89 e5                	mov    %esp,%ebp
c0100d7e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d88:	eb 3d                	jmp    c0100dc7 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d8d:	89 d0                	mov    %edx,%eax
c0100d8f:	01 c0                	add    %eax,%eax
c0100d91:	01 d0                	add    %edx,%eax
c0100d93:	c1 e0 02             	shl    $0x2,%eax
c0100d96:	05 04 a0 11 c0       	add    $0xc011a004,%eax
c0100d9b:	8b 08                	mov    (%eax),%ecx
c0100d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100da0:	89 d0                	mov    %edx,%eax
c0100da2:	01 c0                	add    %eax,%eax
c0100da4:	01 d0                	add    %edx,%eax
c0100da6:	c1 e0 02             	shl    $0x2,%eax
c0100da9:	05 00 a0 11 c0       	add    $0xc011a000,%eax
c0100dae:	8b 00                	mov    (%eax),%eax
c0100db0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100db4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100db8:	c7 04 24 69 67 10 c0 	movl   $0xc0106769,(%esp)
c0100dbf:	e8 06 f5 ff ff       	call   c01002ca <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100dc4:	ff 45 f4             	incl   -0xc(%ebp)
c0100dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dca:	83 f8 02             	cmp    $0x2,%eax
c0100dcd:	76 bb                	jbe    c0100d8a <mon_help+0x13>
    }
    return 0;
c0100dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd4:	c9                   	leave  
c0100dd5:	c3                   	ret    

c0100dd6 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100dd6:	f3 0f 1e fb          	endbr32 
c0100dda:	55                   	push   %ebp
c0100ddb:	89 e5                	mov    %esp,%ebp
c0100ddd:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100de0:	e8 a8 fb ff ff       	call   c010098d <print_kerninfo>
    return 0;
c0100de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dea:	c9                   	leave  
c0100deb:	c3                   	ret    

c0100dec <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dec:	f3 0f 1e fb          	endbr32 
c0100df0:	55                   	push   %ebp
c0100df1:	89 e5                	mov    %esp,%ebp
c0100df3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100df6:	e8 e4 fc ff ff       	call   c0100adf <print_stackframe>
    return 0;
c0100dfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e00:	c9                   	leave  
c0100e01:	c3                   	ret    

c0100e02 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100e02:	f3 0f 1e fb          	endbr32 
c0100e06:	55                   	push   %ebp
c0100e07:	89 e5                	mov    %esp,%ebp
c0100e09:	83 ec 28             	sub    $0x28,%esp
c0100e0c:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e12:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e16:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e1a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e1e:	ee                   	out    %al,(%dx)
}
c0100e1f:	90                   	nop
c0100e20:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e26:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e2a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e2e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e32:	ee                   	out    %al,(%dx)
}
c0100e33:	90                   	nop
c0100e34:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e3a:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e3e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e42:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e46:	ee                   	out    %al,(%dx)
}
c0100e47:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e48:	c7 05 0c df 11 c0 00 	movl   $0x0,0xc011df0c
c0100e4f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e52:	c7 04 24 72 67 10 c0 	movl   $0xc0106772,(%esp)
c0100e59:	e8 6c f4 ff ff       	call   c01002ca <cprintf>
    pic_enable(IRQ_TIMER);
c0100e5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e65:	e8 95 09 00 00       	call   c01017ff <pic_enable>
}
c0100e6a:	90                   	nop
c0100e6b:	c9                   	leave  
c0100e6c:	c3                   	ret    

c0100e6d <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e6d:	55                   	push   %ebp
c0100e6e:	89 e5                	mov    %esp,%ebp
c0100e70:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e73:	9c                   	pushf  
c0100e74:	58                   	pop    %eax
c0100e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e7b:	25 00 02 00 00       	and    $0x200,%eax
c0100e80:	85 c0                	test   %eax,%eax
c0100e82:	74 0c                	je     c0100e90 <__intr_save+0x23>
        intr_disable();
c0100e84:	e8 05 0b 00 00       	call   c010198e <intr_disable>
        return 1;
c0100e89:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e8e:	eb 05                	jmp    c0100e95 <__intr_save+0x28>
    }
    return 0;
c0100e90:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e95:	c9                   	leave  
c0100e96:	c3                   	ret    

c0100e97 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e97:	55                   	push   %ebp
c0100e98:	89 e5                	mov    %esp,%ebp
c0100e9a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e9d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ea1:	74 05                	je     c0100ea8 <__intr_restore+0x11>
        intr_enable();
c0100ea3:	e8 da 0a 00 00       	call   c0101982 <intr_enable>
    }
}
c0100ea8:	90                   	nop
c0100ea9:	c9                   	leave  
c0100eaa:	c3                   	ret    

c0100eab <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100eab:	f3 0f 1e fb          	endbr32 
c0100eaf:	55                   	push   %ebp
c0100eb0:	89 e5                	mov    %esp,%ebp
c0100eb2:	83 ec 10             	sub    $0x10,%esp
c0100eb5:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ebb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ebf:	89 c2                	mov    %eax,%edx
c0100ec1:	ec                   	in     (%dx),%al
c0100ec2:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100ec5:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ecb:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ecf:	89 c2                	mov    %eax,%edx
c0100ed1:	ec                   	in     (%dx),%al
c0100ed2:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100ed5:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100edb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100edf:	89 c2                	mov    %eax,%edx
c0100ee1:	ec                   	in     (%dx),%al
c0100ee2:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100ee5:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100eeb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100eef:	89 c2                	mov    %eax,%edx
c0100ef1:	ec                   	in     (%dx),%al
c0100ef2:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ef5:	90                   	nop
c0100ef6:	c9                   	leave  
c0100ef7:	c3                   	ret    

c0100ef8 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100ef8:	f3 0f 1e fb          	endbr32 
c0100efc:	55                   	push   %ebp
c0100efd:	89 e5                	mov    %esp,%ebp
c0100eff:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100f02:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f09:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f0c:	0f b7 00             	movzwl (%eax),%eax
c0100f0f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f13:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f16:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f1e:	0f b7 00             	movzwl (%eax),%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f29:	74 12                	je     c0100f3d <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f2b:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f32:	66 c7 05 46 d4 11 c0 	movw   $0x3b4,0xc011d446
c0100f39:	b4 03 
c0100f3b:	eb 13                	jmp    c0100f50 <cga_init+0x58>
    } else {
        *cp = was;
c0100f3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f40:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f44:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f47:	66 c7 05 46 d4 11 c0 	movw   $0x3d4,0xc011d446
c0100f4e:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f50:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f57:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f5b:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f5f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f63:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f67:	ee                   	out    %al,(%dx)
}
c0100f68:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f69:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f70:	40                   	inc    %eax
c0100f71:	0f b7 c0             	movzwl %ax,%eax
c0100f74:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f78:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f7c:	89 c2                	mov    %eax,%edx
c0100f7e:	ec                   	in     (%dx),%al
c0100f7f:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f82:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f86:	0f b6 c0             	movzbl %al,%eax
c0100f89:	c1 e0 08             	shl    $0x8,%eax
c0100f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f8f:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100f96:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f9a:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f9e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fa6:	ee                   	out    %al,(%dx)
}
c0100fa7:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100fa8:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0100faf:	40                   	inc    %eax
c0100fb0:	0f b7 c0             	movzwl %ax,%eax
c0100fb3:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fb7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fbb:	89 c2                	mov    %eax,%edx
c0100fbd:	ec                   	in     (%dx),%al
c0100fbe:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fc1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fc5:	0f b6 c0             	movzbl %al,%eax
c0100fc8:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fce:	a3 40 d4 11 c0       	mov    %eax,0xc011d440
    crt_pos = pos;
c0100fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fd6:	0f b7 c0             	movzwl %ax,%eax
c0100fd9:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
}
c0100fdf:	90                   	nop
c0100fe0:	c9                   	leave  
c0100fe1:	c3                   	ret    

c0100fe2 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fe2:	f3 0f 1e fb          	endbr32 
c0100fe6:	55                   	push   %ebp
c0100fe7:	89 e5                	mov    %esp,%ebp
c0100fe9:	83 ec 48             	sub    $0x48,%esp
c0100fec:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100ff2:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100ffa:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100ffe:	ee                   	out    %al,(%dx)
}
c0100fff:	90                   	nop
c0101000:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0101006:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010100a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010100e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101012:	ee                   	out    %al,(%dx)
}
c0101013:	90                   	nop
c0101014:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c010101a:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101022:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101026:	ee                   	out    %al,(%dx)
}
c0101027:	90                   	nop
c0101028:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c010102e:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101032:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101036:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010103a:	ee                   	out    %al,(%dx)
}
c010103b:	90                   	nop
c010103c:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0101042:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101046:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010104a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010104e:	ee                   	out    %al,(%dx)
}
c010104f:	90                   	nop
c0101050:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101056:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010105a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010105e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101062:	ee                   	out    %al,(%dx)
}
c0101063:	90                   	nop
c0101064:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010106a:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010106e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101072:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101076:	ee                   	out    %al,(%dx)
}
c0101077:	90                   	nop
c0101078:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010107e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101082:	89 c2                	mov    %eax,%edx
c0101084:	ec                   	in     (%dx),%al
c0101085:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101088:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010108c:	3c ff                	cmp    $0xff,%al
c010108e:	0f 95 c0             	setne  %al
c0101091:	0f b6 c0             	movzbl %al,%eax
c0101094:	a3 48 d4 11 c0       	mov    %eax,0xc011d448
c0101099:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010109f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01010a3:	89 c2                	mov    %eax,%edx
c01010a5:	ec                   	in     (%dx),%al
c01010a6:	88 45 f1             	mov    %al,-0xf(%ebp)
c01010a9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01010af:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010b3:	89 c2                	mov    %eax,%edx
c01010b5:	ec                   	in     (%dx),%al
c01010b6:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01010b9:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c01010be:	85 c0                	test   %eax,%eax
c01010c0:	74 0c                	je     c01010ce <serial_init+0xec>
        pic_enable(IRQ_COM1);
c01010c2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010c9:	e8 31 07 00 00       	call   c01017ff <pic_enable>
    }
}
c01010ce:	90                   	nop
c01010cf:	c9                   	leave  
c01010d0:	c3                   	ret    

c01010d1 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010d1:	f3 0f 1e fb          	endbr32 
c01010d5:	55                   	push   %ebp
c01010d6:	89 e5                	mov    %esp,%ebp
c01010d8:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010db:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010e2:	eb 08                	jmp    c01010ec <lpt_putc_sub+0x1b>
        delay();
c01010e4:	e8 c2 fd ff ff       	call   c0100eab <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010e9:	ff 45 fc             	incl   -0x4(%ebp)
c01010ec:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010f2:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010f6:	89 c2                	mov    %eax,%edx
c01010f8:	ec                   	in     (%dx),%al
c01010f9:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010fc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101100:	84 c0                	test   %al,%al
c0101102:	78 09                	js     c010110d <lpt_putc_sub+0x3c>
c0101104:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010110b:	7e d7                	jle    c01010e4 <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	0f b6 c0             	movzbl %al,%eax
c0101113:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101119:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010111c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101120:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101124:	ee                   	out    %al,(%dx)
}
c0101125:	90                   	nop
c0101126:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c010112c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101130:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101134:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101138:	ee                   	out    %al,(%dx)
}
c0101139:	90                   	nop
c010113a:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101140:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101144:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101148:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010114c:	ee                   	out    %al,(%dx)
}
c010114d:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c010114e:	90                   	nop
c010114f:	c9                   	leave  
c0101150:	c3                   	ret    

c0101151 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101151:	f3 0f 1e fb          	endbr32 
c0101155:	55                   	push   %ebp
c0101156:	89 e5                	mov    %esp,%ebp
c0101158:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010115b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010115f:	74 0d                	je     c010116e <lpt_putc+0x1d>
        lpt_putc_sub(c);
c0101161:	8b 45 08             	mov    0x8(%ebp),%eax
c0101164:	89 04 24             	mov    %eax,(%esp)
c0101167:	e8 65 ff ff ff       	call   c01010d1 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010116c:	eb 24                	jmp    c0101192 <lpt_putc+0x41>
        lpt_putc_sub('\b');
c010116e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101175:	e8 57 ff ff ff       	call   c01010d1 <lpt_putc_sub>
        lpt_putc_sub(' ');
c010117a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101181:	e8 4b ff ff ff       	call   c01010d1 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101186:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010118d:	e8 3f ff ff ff       	call   c01010d1 <lpt_putc_sub>
}
c0101192:	90                   	nop
c0101193:	c9                   	leave  
c0101194:	c3                   	ret    

c0101195 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101195:	f3 0f 1e fb          	endbr32 
c0101199:	55                   	push   %ebp
c010119a:	89 e5                	mov    %esp,%ebp
c010119c:	53                   	push   %ebx
c010119d:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01011a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a3:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011a8:	85 c0                	test   %eax,%eax
c01011aa:	75 07                	jne    c01011b3 <cga_putc+0x1e>
        c |= 0x0700;
c01011ac:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01011b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01011b6:	0f b6 c0             	movzbl %al,%eax
c01011b9:	83 f8 0d             	cmp    $0xd,%eax
c01011bc:	74 72                	je     c0101230 <cga_putc+0x9b>
c01011be:	83 f8 0d             	cmp    $0xd,%eax
c01011c1:	0f 8f a3 00 00 00    	jg     c010126a <cga_putc+0xd5>
c01011c7:	83 f8 08             	cmp    $0x8,%eax
c01011ca:	74 0a                	je     c01011d6 <cga_putc+0x41>
c01011cc:	83 f8 0a             	cmp    $0xa,%eax
c01011cf:	74 4c                	je     c010121d <cga_putc+0x88>
c01011d1:	e9 94 00 00 00       	jmp    c010126a <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c01011d6:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011dd:	85 c0                	test   %eax,%eax
c01011df:	0f 84 af 00 00 00    	je     c0101294 <cga_putc+0xff>
            crt_pos --;
c01011e5:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01011ec:	48                   	dec    %eax
c01011ed:	0f b7 c0             	movzwl %ax,%eax
c01011f0:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f9:	98                   	cwtl   
c01011fa:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011ff:	98                   	cwtl   
c0101200:	83 c8 20             	or     $0x20,%eax
c0101203:	98                   	cwtl   
c0101204:	8b 15 40 d4 11 c0    	mov    0xc011d440,%edx
c010120a:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c0101211:	01 c9                	add    %ecx,%ecx
c0101213:	01 ca                	add    %ecx,%edx
c0101215:	0f b7 c0             	movzwl %ax,%eax
c0101218:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010121b:	eb 77                	jmp    c0101294 <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c010121d:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101224:	83 c0 50             	add    $0x50,%eax
c0101227:	0f b7 c0             	movzwl %ax,%eax
c010122a:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101230:	0f b7 1d 44 d4 11 c0 	movzwl 0xc011d444,%ebx
c0101237:	0f b7 0d 44 d4 11 c0 	movzwl 0xc011d444,%ecx
c010123e:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101243:	89 c8                	mov    %ecx,%eax
c0101245:	f7 e2                	mul    %edx
c0101247:	c1 ea 06             	shr    $0x6,%edx
c010124a:	89 d0                	mov    %edx,%eax
c010124c:	c1 e0 02             	shl    $0x2,%eax
c010124f:	01 d0                	add    %edx,%eax
c0101251:	c1 e0 04             	shl    $0x4,%eax
c0101254:	29 c1                	sub    %eax,%ecx
c0101256:	89 c8                	mov    %ecx,%eax
c0101258:	0f b7 c0             	movzwl %ax,%eax
c010125b:	29 c3                	sub    %eax,%ebx
c010125d:	89 d8                	mov    %ebx,%eax
c010125f:	0f b7 c0             	movzwl %ax,%eax
c0101262:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
        break;
c0101268:	eb 2b                	jmp    c0101295 <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010126a:	8b 0d 40 d4 11 c0    	mov    0xc011d440,%ecx
c0101270:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101277:	8d 50 01             	lea    0x1(%eax),%edx
c010127a:	0f b7 d2             	movzwl %dx,%edx
c010127d:	66 89 15 44 d4 11 c0 	mov    %dx,0xc011d444
c0101284:	01 c0                	add    %eax,%eax
c0101286:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101289:	8b 45 08             	mov    0x8(%ebp),%eax
c010128c:	0f b7 c0             	movzwl %ax,%eax
c010128f:	66 89 02             	mov    %ax,(%edx)
        break;
c0101292:	eb 01                	jmp    c0101295 <cga_putc+0x100>
        break;
c0101294:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101295:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c010129c:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01012a1:	76 5d                	jbe    c0101300 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01012a3:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c01012a8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012ae:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c01012b3:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012ba:	00 
c01012bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012bf:	89 04 24             	mov    %eax,(%esp)
c01012c2:	e8 b2 49 00 00       	call   c0105c79 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012c7:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012ce:	eb 14                	jmp    c01012e4 <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c01012d0:	a1 40 d4 11 c0       	mov    0xc011d440,%eax
c01012d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012d8:	01 d2                	add    %edx,%edx
c01012da:	01 d0                	add    %edx,%eax
c01012dc:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012e1:	ff 45 f4             	incl   -0xc(%ebp)
c01012e4:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012eb:	7e e3                	jle    c01012d0 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c01012ed:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c01012f4:	83 e8 50             	sub    $0x50,%eax
c01012f7:	0f b7 c0             	movzwl %ax,%eax
c01012fa:	66 a3 44 d4 11 c0    	mov    %ax,0xc011d444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101300:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c0101307:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c010130b:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010130f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101313:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101317:	ee                   	out    %al,(%dx)
}
c0101318:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101319:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101320:	c1 e8 08             	shr    $0x8,%eax
c0101323:	0f b7 c0             	movzwl %ax,%eax
c0101326:	0f b6 c0             	movzbl %al,%eax
c0101329:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c0101330:	42                   	inc    %edx
c0101331:	0f b7 d2             	movzwl %dx,%edx
c0101334:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101338:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010133b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010133f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101343:	ee                   	out    %al,(%dx)
}
c0101344:	90                   	nop
    outb(addr_6845, 15);
c0101345:	0f b7 05 46 d4 11 c0 	movzwl 0xc011d446,%eax
c010134c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101350:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101354:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101358:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010135c:	ee                   	out    %al,(%dx)
}
c010135d:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010135e:	0f b7 05 44 d4 11 c0 	movzwl 0xc011d444,%eax
c0101365:	0f b6 c0             	movzbl %al,%eax
c0101368:	0f b7 15 46 d4 11 c0 	movzwl 0xc011d446,%edx
c010136f:	42                   	inc    %edx
c0101370:	0f b7 d2             	movzwl %dx,%edx
c0101373:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101377:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010137a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010137e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101382:	ee                   	out    %al,(%dx)
}
c0101383:	90                   	nop
}
c0101384:	90                   	nop
c0101385:	83 c4 34             	add    $0x34,%esp
c0101388:	5b                   	pop    %ebx
c0101389:	5d                   	pop    %ebp
c010138a:	c3                   	ret    

c010138b <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c010138b:	f3 0f 1e fb          	endbr32 
c010138f:	55                   	push   %ebp
c0101390:	89 e5                	mov    %esp,%ebp
c0101392:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101395:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010139c:	eb 08                	jmp    c01013a6 <serial_putc_sub+0x1b>
        delay();
c010139e:	e8 08 fb ff ff       	call   c0100eab <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013a3:	ff 45 fc             	incl   -0x4(%ebp)
c01013a6:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ac:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013b0:	89 c2                	mov    %eax,%edx
c01013b2:	ec                   	in     (%dx),%al
c01013b3:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013b6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013ba:	0f b6 c0             	movzbl %al,%eax
c01013bd:	83 e0 20             	and    $0x20,%eax
c01013c0:	85 c0                	test   %eax,%eax
c01013c2:	75 09                	jne    c01013cd <serial_putc_sub+0x42>
c01013c4:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013cb:	7e d1                	jle    c010139e <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c01013cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d0:	0f b6 c0             	movzbl %al,%eax
c01013d3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013d9:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013dc:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013e0:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013e4:	ee                   	out    %al,(%dx)
}
c01013e5:	90                   	nop
}
c01013e6:	90                   	nop
c01013e7:	c9                   	leave  
c01013e8:	c3                   	ret    

c01013e9 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013e9:	f3 0f 1e fb          	endbr32 
c01013ed:	55                   	push   %ebp
c01013ee:	89 e5                	mov    %esp,%ebp
c01013f0:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013f3:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01013f7:	74 0d                	je     c0101406 <serial_putc+0x1d>
        serial_putc_sub(c);
c01013f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01013fc:	89 04 24             	mov    %eax,(%esp)
c01013ff:	e8 87 ff ff ff       	call   c010138b <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101404:	eb 24                	jmp    c010142a <serial_putc+0x41>
        serial_putc_sub('\b');
c0101406:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010140d:	e8 79 ff ff ff       	call   c010138b <serial_putc_sub>
        serial_putc_sub(' ');
c0101412:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101419:	e8 6d ff ff ff       	call   c010138b <serial_putc_sub>
        serial_putc_sub('\b');
c010141e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101425:	e8 61 ff ff ff       	call   c010138b <serial_putc_sub>
}
c010142a:	90                   	nop
c010142b:	c9                   	leave  
c010142c:	c3                   	ret    

c010142d <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010142d:	f3 0f 1e fb          	endbr32 
c0101431:	55                   	push   %ebp
c0101432:	89 e5                	mov    %esp,%ebp
c0101434:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101437:	eb 33                	jmp    c010146c <cons_intr+0x3f>
        if (c != 0) {
c0101439:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010143d:	74 2d                	je     c010146c <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c010143f:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c0101444:	8d 50 01             	lea    0x1(%eax),%edx
c0101447:	89 15 64 d6 11 c0    	mov    %edx,0xc011d664
c010144d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101450:	88 90 60 d4 11 c0    	mov    %dl,-0x3fee2ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101456:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c010145b:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101460:	75 0a                	jne    c010146c <cons_intr+0x3f>
                cons.wpos = 0;
c0101462:	c7 05 64 d6 11 c0 00 	movl   $0x0,0xc011d664
c0101469:	00 00 00 
    while ((c = (*proc)()) != -1) {
c010146c:	8b 45 08             	mov    0x8(%ebp),%eax
c010146f:	ff d0                	call   *%eax
c0101471:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101474:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101478:	75 bf                	jne    c0101439 <cons_intr+0xc>
            }
        }
    }
}
c010147a:	90                   	nop
c010147b:	90                   	nop
c010147c:	c9                   	leave  
c010147d:	c3                   	ret    

c010147e <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c010147e:	f3 0f 1e fb          	endbr32 
c0101482:	55                   	push   %ebp
c0101483:	89 e5                	mov    %esp,%ebp
c0101485:	83 ec 10             	sub    $0x10,%esp
c0101488:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010148e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101492:	89 c2                	mov    %eax,%edx
c0101494:	ec                   	in     (%dx),%al
c0101495:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101498:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c010149c:	0f b6 c0             	movzbl %al,%eax
c010149f:	83 e0 01             	and    $0x1,%eax
c01014a2:	85 c0                	test   %eax,%eax
c01014a4:	75 07                	jne    c01014ad <serial_proc_data+0x2f>
        return -1;
c01014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014ab:	eb 2a                	jmp    c01014d7 <serial_proc_data+0x59>
c01014ad:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014b3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014b7:	89 c2                	mov    %eax,%edx
c01014b9:	ec                   	in     (%dx),%al
c01014ba:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014bd:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014c1:	0f b6 c0             	movzbl %al,%eax
c01014c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014c7:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014cb:	75 07                	jne    c01014d4 <serial_proc_data+0x56>
        c = '\b';
c01014cd:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014d7:	c9                   	leave  
c01014d8:	c3                   	ret    

c01014d9 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014d9:	f3 0f 1e fb          	endbr32 
c01014dd:	55                   	push   %ebp
c01014de:	89 e5                	mov    %esp,%ebp
c01014e0:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014e3:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c01014e8:	85 c0                	test   %eax,%eax
c01014ea:	74 0c                	je     c01014f8 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c01014ec:	c7 04 24 7e 14 10 c0 	movl   $0xc010147e,(%esp)
c01014f3:	e8 35 ff ff ff       	call   c010142d <cons_intr>
    }
}
c01014f8:	90                   	nop
c01014f9:	c9                   	leave  
c01014fa:	c3                   	ret    

c01014fb <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01014fb:	f3 0f 1e fb          	endbr32 
c01014ff:	55                   	push   %ebp
c0101500:	89 e5                	mov    %esp,%ebp
c0101502:	83 ec 38             	sub    $0x38,%esp
c0101505:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010150b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010150e:	89 c2                	mov    %eax,%edx
c0101510:	ec                   	in     (%dx),%al
c0101511:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101514:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101518:	0f b6 c0             	movzbl %al,%eax
c010151b:	83 e0 01             	and    $0x1,%eax
c010151e:	85 c0                	test   %eax,%eax
c0101520:	75 0a                	jne    c010152c <kbd_proc_data+0x31>
        return -1;
c0101522:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101527:	e9 56 01 00 00       	jmp    c0101682 <kbd_proc_data+0x187>
c010152c:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101532:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101535:	89 c2                	mov    %eax,%edx
c0101537:	ec                   	in     (%dx),%al
c0101538:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010153b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010153f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101542:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101546:	75 17                	jne    c010155f <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c0101548:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010154d:	83 c8 40             	or     $0x40,%eax
c0101550:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c0101555:	b8 00 00 00 00       	mov    $0x0,%eax
c010155a:	e9 23 01 00 00       	jmp    c0101682 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c010155f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101563:	84 c0                	test   %al,%al
c0101565:	79 45                	jns    c01015ac <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101567:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010156c:	83 e0 40             	and    $0x40,%eax
c010156f:	85 c0                	test   %eax,%eax
c0101571:	75 08                	jne    c010157b <kbd_proc_data+0x80>
c0101573:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101577:	24 7f                	and    $0x7f,%al
c0101579:	eb 04                	jmp    c010157f <kbd_proc_data+0x84>
c010157b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010157f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101582:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101586:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c010158d:	0c 40                	or     $0x40,%al
c010158f:	0f b6 c0             	movzbl %al,%eax
c0101592:	f7 d0                	not    %eax
c0101594:	89 c2                	mov    %eax,%edx
c0101596:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010159b:	21 d0                	and    %edx,%eax
c010159d:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
        return 0;
c01015a2:	b8 00 00 00 00       	mov    $0x0,%eax
c01015a7:	e9 d6 00 00 00       	jmp    c0101682 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015ac:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01015b1:	83 e0 40             	and    $0x40,%eax
c01015b4:	85 c0                	test   %eax,%eax
c01015b6:	74 11                	je     c01015c9 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015b8:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015bc:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01015c1:	83 e0 bf             	and    $0xffffffbf,%eax
c01015c4:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    }

    shift |= shiftcode[data];
c01015c9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015cd:	0f b6 80 40 a0 11 c0 	movzbl -0x3fee5fc0(%eax),%eax
c01015d4:	0f b6 d0             	movzbl %al,%edx
c01015d7:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01015dc:	09 d0                	or     %edx,%eax
c01015de:	a3 68 d6 11 c0       	mov    %eax,0xc011d668
    shift ^= togglecode[data];
c01015e3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015e7:	0f b6 80 40 a1 11 c0 	movzbl -0x3fee5ec0(%eax),%eax
c01015ee:	0f b6 d0             	movzbl %al,%edx
c01015f1:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c01015f6:	31 d0                	xor    %edx,%eax
c01015f8:	a3 68 d6 11 c0       	mov    %eax,0xc011d668

    c = charcode[shift & (CTL | SHIFT)][data];
c01015fd:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101602:	83 e0 03             	and    $0x3,%eax
c0101605:	8b 14 85 40 a5 11 c0 	mov    -0x3fee5ac0(,%eax,4),%edx
c010160c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101610:	01 d0                	add    %edx,%eax
c0101612:	0f b6 00             	movzbl (%eax),%eax
c0101615:	0f b6 c0             	movzbl %al,%eax
c0101618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010161b:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c0101620:	83 e0 08             	and    $0x8,%eax
c0101623:	85 c0                	test   %eax,%eax
c0101625:	74 22                	je     c0101649 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101627:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010162b:	7e 0c                	jle    c0101639 <kbd_proc_data+0x13e>
c010162d:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101631:	7f 06                	jg     c0101639 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101633:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101637:	eb 10                	jmp    c0101649 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101639:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010163d:	7e 0a                	jle    c0101649 <kbd_proc_data+0x14e>
c010163f:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101643:	7f 04                	jg     c0101649 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101645:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101649:	a1 68 d6 11 c0       	mov    0xc011d668,%eax
c010164e:	f7 d0                	not    %eax
c0101650:	83 e0 06             	and    $0x6,%eax
c0101653:	85 c0                	test   %eax,%eax
c0101655:	75 28                	jne    c010167f <kbd_proc_data+0x184>
c0101657:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c010165e:	75 1f                	jne    c010167f <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101660:	c7 04 24 8d 67 10 c0 	movl   $0xc010678d,(%esp)
c0101667:	e8 5e ec ff ff       	call   c01002ca <cprintf>
c010166c:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101672:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101676:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010167a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010167d:	ee                   	out    %al,(%dx)
}
c010167e:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010167f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101682:	c9                   	leave  
c0101683:	c3                   	ret    

c0101684 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101684:	f3 0f 1e fb          	endbr32 
c0101688:	55                   	push   %ebp
c0101689:	89 e5                	mov    %esp,%ebp
c010168b:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010168e:	c7 04 24 fb 14 10 c0 	movl   $0xc01014fb,(%esp)
c0101695:	e8 93 fd ff ff       	call   c010142d <cons_intr>
}
c010169a:	90                   	nop
c010169b:	c9                   	leave  
c010169c:	c3                   	ret    

c010169d <kbd_init>:

static void
kbd_init(void) {
c010169d:	f3 0f 1e fb          	endbr32 
c01016a1:	55                   	push   %ebp
c01016a2:	89 e5                	mov    %esp,%ebp
c01016a4:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016a7:	e8 d8 ff ff ff       	call   c0101684 <kbd_intr>
    pic_enable(IRQ_KBD);
c01016ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016b3:	e8 47 01 00 00       	call   c01017ff <pic_enable>
}
c01016b8:	90                   	nop
c01016b9:	c9                   	leave  
c01016ba:	c3                   	ret    

c01016bb <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016bb:	f3 0f 1e fb          	endbr32 
c01016bf:	55                   	push   %ebp
c01016c0:	89 e5                	mov    %esp,%ebp
c01016c2:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016c5:	e8 2e f8 ff ff       	call   c0100ef8 <cga_init>
    serial_init();
c01016ca:	e8 13 f9 ff ff       	call   c0100fe2 <serial_init>
    kbd_init();
c01016cf:	e8 c9 ff ff ff       	call   c010169d <kbd_init>
    if (!serial_exists) {
c01016d4:	a1 48 d4 11 c0       	mov    0xc011d448,%eax
c01016d9:	85 c0                	test   %eax,%eax
c01016db:	75 0c                	jne    c01016e9 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01016dd:	c7 04 24 99 67 10 c0 	movl   $0xc0106799,(%esp)
c01016e4:	e8 e1 eb ff ff       	call   c01002ca <cprintf>
    }
}
c01016e9:	90                   	nop
c01016ea:	c9                   	leave  
c01016eb:	c3                   	ret    

c01016ec <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016ec:	f3 0f 1e fb          	endbr32 
c01016f0:	55                   	push   %ebp
c01016f1:	89 e5                	mov    %esp,%ebp
c01016f3:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01016f6:	e8 72 f7 ff ff       	call   c0100e6d <__intr_save>
c01016fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01016fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101701:	89 04 24             	mov    %eax,(%esp)
c0101704:	e8 48 fa ff ff       	call   c0101151 <lpt_putc>
        cga_putc(c);
c0101709:	8b 45 08             	mov    0x8(%ebp),%eax
c010170c:	89 04 24             	mov    %eax,(%esp)
c010170f:	e8 81 fa ff ff       	call   c0101195 <cga_putc>
        serial_putc(c);
c0101714:	8b 45 08             	mov    0x8(%ebp),%eax
c0101717:	89 04 24             	mov    %eax,(%esp)
c010171a:	e8 ca fc ff ff       	call   c01013e9 <serial_putc>
    }
    local_intr_restore(intr_flag);
c010171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101722:	89 04 24             	mov    %eax,(%esp)
c0101725:	e8 6d f7 ff ff       	call   c0100e97 <__intr_restore>
}
c010172a:	90                   	nop
c010172b:	c9                   	leave  
c010172c:	c3                   	ret    

c010172d <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010172d:	f3 0f 1e fb          	endbr32 
c0101731:	55                   	push   %ebp
c0101732:	89 e5                	mov    %esp,%ebp
c0101734:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010173e:	e8 2a f7 ff ff       	call   c0100e6d <__intr_save>
c0101743:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101746:	e8 8e fd ff ff       	call   c01014d9 <serial_intr>
        kbd_intr();
c010174b:	e8 34 ff ff ff       	call   c0101684 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101750:	8b 15 60 d6 11 c0    	mov    0xc011d660,%edx
c0101756:	a1 64 d6 11 c0       	mov    0xc011d664,%eax
c010175b:	39 c2                	cmp    %eax,%edx
c010175d:	74 31                	je     c0101790 <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c010175f:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c0101764:	8d 50 01             	lea    0x1(%eax),%edx
c0101767:	89 15 60 d6 11 c0    	mov    %edx,0xc011d660
c010176d:	0f b6 80 60 d4 11 c0 	movzbl -0x3fee2ba0(%eax),%eax
c0101774:	0f b6 c0             	movzbl %al,%eax
c0101777:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010177a:	a1 60 d6 11 c0       	mov    0xc011d660,%eax
c010177f:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101784:	75 0a                	jne    c0101790 <cons_getc+0x63>
                cons.rpos = 0;
c0101786:	c7 05 60 d6 11 c0 00 	movl   $0x0,0xc011d660
c010178d:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101790:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101793:	89 04 24             	mov    %eax,(%esp)
c0101796:	e8 fc f6 ff ff       	call   c0100e97 <__intr_restore>
    return c;
c010179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010179e:	c9                   	leave  
c010179f:	c3                   	ret    

c01017a0 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01017a0:	f3 0f 1e fb          	endbr32 
c01017a4:	55                   	push   %ebp
c01017a5:	89 e5                	mov    %esp,%ebp
c01017a7:	83 ec 14             	sub    $0x14,%esp
c01017aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01017ad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01017b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017b4:	66 a3 50 a5 11 c0    	mov    %ax,0xc011a550
    if (did_init) {
c01017ba:	a1 6c d6 11 c0       	mov    0xc011d66c,%eax
c01017bf:	85 c0                	test   %eax,%eax
c01017c1:	74 39                	je     c01017fc <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c01017c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017c6:	0f b6 c0             	movzbl %al,%eax
c01017c9:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01017cf:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017d2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017d6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017da:	ee                   	out    %al,(%dx)
}
c01017db:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01017dc:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017e0:	c1 e8 08             	shr    $0x8,%eax
c01017e3:	0f b7 c0             	movzwl %ax,%eax
c01017e6:	0f b6 c0             	movzbl %al,%eax
c01017e9:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01017ef:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017f2:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01017f6:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01017fa:	ee                   	out    %al,(%dx)
}
c01017fb:	90                   	nop
    }
}
c01017fc:	90                   	nop
c01017fd:	c9                   	leave  
c01017fe:	c3                   	ret    

c01017ff <pic_enable>:

void
pic_enable(unsigned int irq) {
c01017ff:	f3 0f 1e fb          	endbr32 
c0101803:	55                   	push   %ebp
c0101804:	89 e5                	mov    %esp,%ebp
c0101806:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101809:	8b 45 08             	mov    0x8(%ebp),%eax
c010180c:	ba 01 00 00 00       	mov    $0x1,%edx
c0101811:	88 c1                	mov    %al,%cl
c0101813:	d3 e2                	shl    %cl,%edx
c0101815:	89 d0                	mov    %edx,%eax
c0101817:	98                   	cwtl   
c0101818:	f7 d0                	not    %eax
c010181a:	0f bf d0             	movswl %ax,%edx
c010181d:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c0101824:	98                   	cwtl   
c0101825:	21 d0                	and    %edx,%eax
c0101827:	98                   	cwtl   
c0101828:	0f b7 c0             	movzwl %ax,%eax
c010182b:	89 04 24             	mov    %eax,(%esp)
c010182e:	e8 6d ff ff ff       	call   c01017a0 <pic_setmask>
}
c0101833:	90                   	nop
c0101834:	c9                   	leave  
c0101835:	c3                   	ret    

c0101836 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101836:	f3 0f 1e fb          	endbr32 
c010183a:	55                   	push   %ebp
c010183b:	89 e5                	mov    %esp,%ebp
c010183d:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101840:	c7 05 6c d6 11 c0 01 	movl   $0x1,0xc011d66c
c0101847:	00 00 00 
c010184a:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c0101850:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101854:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101858:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010185c:	ee                   	out    %al,(%dx)
}
c010185d:	90                   	nop
c010185e:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101864:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101868:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010186c:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101870:	ee                   	out    %al,(%dx)
}
c0101871:	90                   	nop
c0101872:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101878:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010187c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101880:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101884:	ee                   	out    %al,(%dx)
}
c0101885:	90                   	nop
c0101886:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010188c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101890:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101894:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101898:	ee                   	out    %al,(%dx)
}
c0101899:	90                   	nop
c010189a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01018a0:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018a4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01018a8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01018ac:	ee                   	out    %al,(%dx)
}
c01018ad:	90                   	nop
c01018ae:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01018b4:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018b8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01018bc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01018c0:	ee                   	out    %al,(%dx)
}
c01018c1:	90                   	nop
c01018c2:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01018c8:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018cc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01018d0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01018d4:	ee                   	out    %al,(%dx)
}
c01018d5:	90                   	nop
c01018d6:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01018dc:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018e4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018e8:	ee                   	out    %al,(%dx)
}
c01018e9:	90                   	nop
c01018ea:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01018f0:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018f4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01018f8:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01018fc:	ee                   	out    %al,(%dx)
}
c01018fd:	90                   	nop
c01018fe:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0101904:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101908:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010190c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101910:	ee                   	out    %al,(%dx)
}
c0101911:	90                   	nop
c0101912:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101918:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010191c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101920:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101924:	ee                   	out    %al,(%dx)
}
c0101925:	90                   	nop
c0101926:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010192c:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101930:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101934:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101938:	ee                   	out    %al,(%dx)
}
c0101939:	90                   	nop
c010193a:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c0101940:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101944:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101948:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010194c:	ee                   	out    %al,(%dx)
}
c010194d:	90                   	nop
c010194e:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c0101954:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101958:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010195c:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101960:	ee                   	out    %al,(%dx)
}
c0101961:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101962:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c0101969:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010196e:	74 0f                	je     c010197f <pic_init+0x149>
        pic_setmask(irq_mask);
c0101970:	0f b7 05 50 a5 11 c0 	movzwl 0xc011a550,%eax
c0101977:	89 04 24             	mov    %eax,(%esp)
c010197a:	e8 21 fe ff ff       	call   c01017a0 <pic_setmask>
    }
}
c010197f:	90                   	nop
c0101980:	c9                   	leave  
c0101981:	c3                   	ret    

c0101982 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101982:	f3 0f 1e fb          	endbr32 
c0101986:	55                   	push   %ebp
c0101987:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101989:	fb                   	sti    
}
c010198a:	90                   	nop
    sti();
}
c010198b:	90                   	nop
c010198c:	5d                   	pop    %ebp
c010198d:	c3                   	ret    

c010198e <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010198e:	f3 0f 1e fb          	endbr32 
c0101992:	55                   	push   %ebp
c0101993:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101995:	fa                   	cli    
}
c0101996:	90                   	nop
    cli();
}
c0101997:	90                   	nop
c0101998:	5d                   	pop    %ebp
c0101999:	c3                   	ret    

c010199a <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c010199a:	f3 0f 1e fb          	endbr32 
c010199e:	55                   	push   %ebp
c010199f:	89 e5                	mov    %esp,%ebp
c01019a1:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01019a4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01019ab:	00 
c01019ac:	c7 04 24 c0 67 10 c0 	movl   $0xc01067c0,(%esp)
c01019b3:	e8 12 e9 ff ff       	call   c01002ca <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01019b8:	90                   	nop
c01019b9:	c9                   	leave  
c01019ba:	c3                   	ret    

c01019bb <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01019bb:	f3 0f 1e fb          	endbr32 
c01019bf:	55                   	push   %ebp
c01019c0:	89 e5                	mov    %esp,%ebp
c01019c2:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01019c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019cc:	e9 c4 00 00 00       	jmp    c0101a95 <idt_init+0xda>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01019d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d4:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c01019db:	0f b7 d0             	movzwl %ax,%edx
c01019de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019e1:	66 89 14 c5 80 d6 11 	mov    %dx,-0x3fee2980(,%eax,8)
c01019e8:	c0 
c01019e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ec:	66 c7 04 c5 82 d6 11 	movw   $0x8,-0x3fee297e(,%eax,8)
c01019f3:	c0 08 00 
c01019f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019f9:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101a00:	c0 
c0101a01:	80 e2 e0             	and    $0xe0,%dl
c0101a04:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101a0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a0e:	0f b6 14 c5 84 d6 11 	movzbl -0x3fee297c(,%eax,8),%edx
c0101a15:	c0 
c0101a16:	80 e2 1f             	and    $0x1f,%dl
c0101a19:	88 14 c5 84 d6 11 c0 	mov    %dl,-0x3fee297c(,%eax,8)
c0101a20:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a23:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101a2a:	c0 
c0101a2b:	80 e2 f0             	and    $0xf0,%dl
c0101a2e:	80 ca 0e             	or     $0xe,%dl
c0101a31:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101a38:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a3b:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101a42:	c0 
c0101a43:	80 e2 ef             	and    $0xef,%dl
c0101a46:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101a4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a50:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101a57:	c0 
c0101a58:	80 e2 9f             	and    $0x9f,%dl
c0101a5b:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101a62:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a65:	0f b6 14 c5 85 d6 11 	movzbl -0x3fee297b(,%eax,8),%edx
c0101a6c:	c0 
c0101a6d:	80 ca 80             	or     $0x80,%dl
c0101a70:	88 14 c5 85 d6 11 c0 	mov    %dl,-0x3fee297b(,%eax,8)
c0101a77:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a7a:	8b 04 85 e0 a5 11 c0 	mov    -0x3fee5a20(,%eax,4),%eax
c0101a81:	c1 e8 10             	shr    $0x10,%eax
c0101a84:	0f b7 d0             	movzwl %ax,%edx
c0101a87:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a8a:	66 89 14 c5 86 d6 11 	mov    %dx,-0x3fee297a(,%eax,8)
c0101a91:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101a92:	ff 45 fc             	incl   -0x4(%ebp)
c0101a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a98:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a9d:	0f 86 2e ff ff ff    	jbe    c01019d1 <idt_init+0x16>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101aa3:	a1 c4 a7 11 c0       	mov    0xc011a7c4,%eax
c0101aa8:	0f b7 c0             	movzwl %ax,%eax
c0101aab:	66 a3 48 da 11 c0    	mov    %ax,0xc011da48
c0101ab1:	66 c7 05 4a da 11 c0 	movw   $0x8,0xc011da4a
c0101ab8:	08 00 
c0101aba:	0f b6 05 4c da 11 c0 	movzbl 0xc011da4c,%eax
c0101ac1:	24 e0                	and    $0xe0,%al
c0101ac3:	a2 4c da 11 c0       	mov    %al,0xc011da4c
c0101ac8:	0f b6 05 4c da 11 c0 	movzbl 0xc011da4c,%eax
c0101acf:	24 1f                	and    $0x1f,%al
c0101ad1:	a2 4c da 11 c0       	mov    %al,0xc011da4c
c0101ad6:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c0101add:	24 f0                	and    $0xf0,%al
c0101adf:	0c 0e                	or     $0xe,%al
c0101ae1:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101ae6:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c0101aed:	24 ef                	and    $0xef,%al
c0101aef:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101af4:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c0101afb:	0c 60                	or     $0x60,%al
c0101afd:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101b02:	0f b6 05 4d da 11 c0 	movzbl 0xc011da4d,%eax
c0101b09:	0c 80                	or     $0x80,%al
c0101b0b:	a2 4d da 11 c0       	mov    %al,0xc011da4d
c0101b10:	a1 c4 a7 11 c0       	mov    0xc011a7c4,%eax
c0101b15:	c1 e8 10             	shr    $0x10,%eax
c0101b18:	0f b7 c0             	movzwl %ax,%eax
c0101b1b:	66 a3 4e da 11 c0    	mov    %ax,0xc011da4e
c0101b21:	c7 45 f8 60 a5 11 c0 	movl   $0xc011a560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101b28:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b2b:	0f 01 18             	lidtl  (%eax)
}
c0101b2e:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
c0101b2f:	90                   	nop
c0101b30:	c9                   	leave  
c0101b31:	c3                   	ret    

c0101b32 <trapname>:

static const char *
trapname(int trapno) {
c0101b32:	f3 0f 1e fb          	endbr32 
c0101b36:	55                   	push   %ebp
c0101b37:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101b39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3c:	83 f8 13             	cmp    $0x13,%eax
c0101b3f:	77 0c                	ja     c0101b4d <trapname+0x1b>
        return excnames[trapno];
c0101b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b44:	8b 04 85 20 6b 10 c0 	mov    -0x3fef94e0(,%eax,4),%eax
c0101b4b:	eb 18                	jmp    c0101b65 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101b4d:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101b51:	7e 0d                	jle    c0101b60 <trapname+0x2e>
c0101b53:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101b57:	7f 07                	jg     c0101b60 <trapname+0x2e>
        return "Hardware Interrupt";
c0101b59:	b8 ca 67 10 c0       	mov    $0xc01067ca,%eax
c0101b5e:	eb 05                	jmp    c0101b65 <trapname+0x33>
    }
    return "(unknown trap)";
c0101b60:	b8 dd 67 10 c0       	mov    $0xc01067dd,%eax
}
c0101b65:	5d                   	pop    %ebp
c0101b66:	c3                   	ret    

c0101b67 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b67:	f3 0f 1e fb          	endbr32 
c0101b6b:	55                   	push   %ebp
c0101b6c:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b71:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b75:	83 f8 08             	cmp    $0x8,%eax
c0101b78:	0f 94 c0             	sete   %al
c0101b7b:	0f b6 c0             	movzbl %al,%eax
}
c0101b7e:	5d                   	pop    %ebp
c0101b7f:	c3                   	ret    

c0101b80 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b80:	f3 0f 1e fb          	endbr32 
c0101b84:	55                   	push   %ebp
c0101b85:	89 e5                	mov    %esp,%ebp
c0101b87:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b91:	c7 04 24 1e 68 10 c0 	movl   $0xc010681e,(%esp)
c0101b98:	e8 2d e7 ff ff       	call   c01002ca <cprintf>
    print_regs(&tf->tf_regs);
c0101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba0:	89 04 24             	mov    %eax,(%esp)
c0101ba3:	e8 8d 01 00 00       	call   c0101d35 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101ba8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bab:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101baf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bb3:	c7 04 24 2f 68 10 c0 	movl   $0xc010682f,(%esp)
c0101bba:	e8 0b e7 ff ff       	call   c01002ca <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc2:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bca:	c7 04 24 42 68 10 c0 	movl   $0xc0106842,(%esp)
c0101bd1:	e8 f4 e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd9:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be1:	c7 04 24 55 68 10 c0 	movl   $0xc0106855,(%esp)
c0101be8:	e8 dd e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf0:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf8:	c7 04 24 68 68 10 c0 	movl   $0xc0106868,(%esp)
c0101bff:	e8 c6 e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c07:	8b 40 30             	mov    0x30(%eax),%eax
c0101c0a:	89 04 24             	mov    %eax,(%esp)
c0101c0d:	e8 20 ff ff ff       	call   c0101b32 <trapname>
c0101c12:	8b 55 08             	mov    0x8(%ebp),%edx
c0101c15:	8b 52 30             	mov    0x30(%edx),%edx
c0101c18:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101c1c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101c20:	c7 04 24 7b 68 10 c0 	movl   $0xc010687b,(%esp)
c0101c27:	e8 9e e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2f:	8b 40 34             	mov    0x34(%eax),%eax
c0101c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c36:	c7 04 24 8d 68 10 c0 	movl   $0xc010688d,(%esp)
c0101c3d:	e8 88 e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101c42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c45:	8b 40 38             	mov    0x38(%eax),%eax
c0101c48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4c:	c7 04 24 9c 68 10 c0 	movl   $0xc010689c,(%esp)
c0101c53:	e8 72 e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101c58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c63:	c7 04 24 ab 68 10 c0 	movl   $0xc01068ab,(%esp)
c0101c6a:	e8 5b e6 ff ff       	call   c01002ca <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c72:	8b 40 40             	mov    0x40(%eax),%eax
c0101c75:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c79:	c7 04 24 be 68 10 c0 	movl   $0xc01068be,(%esp)
c0101c80:	e8 45 e6 ff ff       	call   c01002ca <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c8c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c93:	eb 3d                	jmp    c0101cd2 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c98:	8b 50 40             	mov    0x40(%eax),%edx
c0101c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c9e:	21 d0                	and    %edx,%eax
c0101ca0:	85 c0                	test   %eax,%eax
c0101ca2:	74 28                	je     c0101ccc <print_trapframe+0x14c>
c0101ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ca7:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101cae:	85 c0                	test   %eax,%eax
c0101cb0:	74 1a                	je     c0101ccc <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
c0101cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cb5:	8b 04 85 80 a5 11 c0 	mov    -0x3fee5a80(,%eax,4),%eax
c0101cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc0:	c7 04 24 cd 68 10 c0 	movl   $0xc01068cd,(%esp)
c0101cc7:	e8 fe e5 ff ff       	call   c01002ca <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ccc:	ff 45 f4             	incl   -0xc(%ebp)
c0101ccf:	d1 65 f0             	shll   -0x10(%ebp)
c0101cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cd5:	83 f8 17             	cmp    $0x17,%eax
c0101cd8:	76 bb                	jbe    c0101c95 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdd:	8b 40 40             	mov    0x40(%eax),%eax
c0101ce0:	c1 e8 0c             	shr    $0xc,%eax
c0101ce3:	83 e0 03             	and    $0x3,%eax
c0101ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cea:	c7 04 24 d1 68 10 c0 	movl   $0xc01068d1,(%esp)
c0101cf1:	e8 d4 e5 ff ff       	call   c01002ca <cprintf>

    if (!trap_in_kernel(tf)) {
c0101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf9:	89 04 24             	mov    %eax,(%esp)
c0101cfc:	e8 66 fe ff ff       	call   c0101b67 <trap_in_kernel>
c0101d01:	85 c0                	test   %eax,%eax
c0101d03:	75 2d                	jne    c0101d32 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d08:	8b 40 44             	mov    0x44(%eax),%eax
c0101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0f:	c7 04 24 da 68 10 c0 	movl   $0xc01068da,(%esp)
c0101d16:	e8 af e5 ff ff       	call   c01002ca <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1e:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101d22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d26:	c7 04 24 e9 68 10 c0 	movl   $0xc01068e9,(%esp)
c0101d2d:	e8 98 e5 ff ff       	call   c01002ca <cprintf>
    }
}
c0101d32:	90                   	nop
c0101d33:	c9                   	leave  
c0101d34:	c3                   	ret    

c0101d35 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101d35:	f3 0f 1e fb          	endbr32 
c0101d39:	55                   	push   %ebp
c0101d3a:	89 e5                	mov    %esp,%ebp
c0101d3c:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101d3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d42:	8b 00                	mov    (%eax),%eax
c0101d44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d48:	c7 04 24 fc 68 10 c0 	movl   $0xc01068fc,(%esp)
c0101d4f:	e8 76 e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101d54:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d57:	8b 40 04             	mov    0x4(%eax),%eax
c0101d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d5e:	c7 04 24 0b 69 10 c0 	movl   $0xc010690b,(%esp)
c0101d65:	e8 60 e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6d:	8b 40 08             	mov    0x8(%eax),%eax
c0101d70:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d74:	c7 04 24 1a 69 10 c0 	movl   $0xc010691a,(%esp)
c0101d7b:	e8 4a e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d80:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d83:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d86:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d8a:	c7 04 24 29 69 10 c0 	movl   $0xc0106929,(%esp)
c0101d91:	e8 34 e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d96:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d99:	8b 40 10             	mov    0x10(%eax),%eax
c0101d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da0:	c7 04 24 38 69 10 c0 	movl   $0xc0106938,(%esp)
c0101da7:	e8 1e e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101dac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101daf:	8b 40 14             	mov    0x14(%eax),%eax
c0101db2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101db6:	c7 04 24 47 69 10 c0 	movl   $0xc0106947,(%esp)
c0101dbd:	e8 08 e5 ff ff       	call   c01002ca <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc5:	8b 40 18             	mov    0x18(%eax),%eax
c0101dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dcc:	c7 04 24 56 69 10 c0 	movl   $0xc0106956,(%esp)
c0101dd3:	e8 f2 e4 ff ff       	call   c01002ca <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101dd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ddb:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101dde:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101de2:	c7 04 24 65 69 10 c0 	movl   $0xc0106965,(%esp)
c0101de9:	e8 dc e4 ff ff       	call   c01002ca <cprintf>
}
c0101dee:	90                   	nop
c0101def:	c9                   	leave  
c0101df0:	c3                   	ret    

c0101df1 <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101df1:	f3 0f 1e fb          	endbr32 
c0101df5:	55                   	push   %ebp
c0101df6:	89 e5                	mov    %esp,%ebp
c0101df8:	57                   	push   %edi
c0101df9:	56                   	push   %esi
c0101dfa:	53                   	push   %ebx
c0101dfb:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
c0101dfe:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e01:	8b 40 30             	mov    0x30(%eax),%eax
c0101e04:	83 f8 79             	cmp    $0x79,%eax
c0101e07:	0f 84 c6 01 00 00    	je     c0101fd3 <trap_dispatch+0x1e2>
c0101e0d:	83 f8 79             	cmp    $0x79,%eax
c0101e10:	0f 87 3a 02 00 00    	ja     c0102050 <trap_dispatch+0x25f>
c0101e16:	83 f8 78             	cmp    $0x78,%eax
c0101e19:	0f 84 d0 00 00 00    	je     c0101eef <trap_dispatch+0xfe>
c0101e1f:	83 f8 78             	cmp    $0x78,%eax
c0101e22:	0f 87 28 02 00 00    	ja     c0102050 <trap_dispatch+0x25f>
c0101e28:	83 f8 2f             	cmp    $0x2f,%eax
c0101e2b:	0f 87 1f 02 00 00    	ja     c0102050 <trap_dispatch+0x25f>
c0101e31:	83 f8 2e             	cmp    $0x2e,%eax
c0101e34:	0f 83 4b 02 00 00    	jae    c0102085 <trap_dispatch+0x294>
c0101e3a:	83 f8 24             	cmp    $0x24,%eax
c0101e3d:	74 5e                	je     c0101e9d <trap_dispatch+0xac>
c0101e3f:	83 f8 24             	cmp    $0x24,%eax
c0101e42:	0f 87 08 02 00 00    	ja     c0102050 <trap_dispatch+0x25f>
c0101e48:	83 f8 20             	cmp    $0x20,%eax
c0101e4b:	74 0a                	je     c0101e57 <trap_dispatch+0x66>
c0101e4d:	83 f8 21             	cmp    $0x21,%eax
c0101e50:	74 74                	je     c0101ec6 <trap_dispatch+0xd5>
c0101e52:	e9 f9 01 00 00       	jmp    c0102050 <trap_dispatch+0x25f>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101e57:	a1 0c df 11 c0       	mov    0xc011df0c,%eax
c0101e5c:	40                   	inc    %eax
c0101e5d:	a3 0c df 11 c0       	mov    %eax,0xc011df0c
        if (ticks % TICK_NUM == 0) {
c0101e62:	8b 0d 0c df 11 c0    	mov    0xc011df0c,%ecx
c0101e68:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101e6d:	89 c8                	mov    %ecx,%eax
c0101e6f:	f7 e2                	mul    %edx
c0101e71:	c1 ea 05             	shr    $0x5,%edx
c0101e74:	89 d0                	mov    %edx,%eax
c0101e76:	c1 e0 02             	shl    $0x2,%eax
c0101e79:	01 d0                	add    %edx,%eax
c0101e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e82:	01 d0                	add    %edx,%eax
c0101e84:	c1 e0 02             	shl    $0x2,%eax
c0101e87:	29 c1                	sub    %eax,%ecx
c0101e89:	89 ca                	mov    %ecx,%edx
c0101e8b:	85 d2                	test   %edx,%edx
c0101e8d:	0f 85 f5 01 00 00    	jne    c0102088 <trap_dispatch+0x297>
            print_ticks();
c0101e93:	e8 02 fb ff ff       	call   c010199a <print_ticks>
        }
        break;
c0101e98:	e9 eb 01 00 00       	jmp    c0102088 <trap_dispatch+0x297>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e9d:	e8 8b f8 ff ff       	call   c010172d <cons_getc>
c0101ea2:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ea5:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101ea9:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101ead:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eb5:	c7 04 24 74 69 10 c0 	movl   $0xc0106974,(%esp)
c0101ebc:	e8 09 e4 ff ff       	call   c01002ca <cprintf>
        break;
c0101ec1:	e9 c9 01 00 00       	jmp    c010208f <trap_dispatch+0x29e>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101ec6:	e8 62 f8 ff ff       	call   c010172d <cons_getc>
c0101ecb:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101ece:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
c0101ed2:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
c0101ed6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101eda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ede:	c7 04 24 86 69 10 c0 	movl   $0xc0106986,(%esp)
c0101ee5:	e8 e0 e3 ff ff       	call   c01002ca <cprintf>
        break;
c0101eea:	e9 a0 01 00 00       	jmp    c010208f <trap_dispatch+0x29e>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    	if (tf->tf_cs != USER_CS) {
c0101eef:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ef6:	83 f8 1b             	cmp    $0x1b,%eax
c0101ef9:	0f 84 8c 01 00 00    	je     c010208b <trap_dispatch+0x29a>
            switchk2u = *tf;
c0101eff:	8b 55 08             	mov    0x8(%ebp),%edx
c0101f02:	b8 20 df 11 c0       	mov    $0xc011df20,%eax
c0101f07:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0101f0c:	89 c1                	mov    %eax,%ecx
c0101f0e:	83 e1 01             	and    $0x1,%ecx
c0101f11:	85 c9                	test   %ecx,%ecx
c0101f13:	74 0c                	je     c0101f21 <trap_dispatch+0x130>
c0101f15:	0f b6 0a             	movzbl (%edx),%ecx
c0101f18:	88 08                	mov    %cl,(%eax)
c0101f1a:	8d 40 01             	lea    0x1(%eax),%eax
c0101f1d:	8d 52 01             	lea    0x1(%edx),%edx
c0101f20:	4b                   	dec    %ebx
c0101f21:	89 c1                	mov    %eax,%ecx
c0101f23:	83 e1 02             	and    $0x2,%ecx
c0101f26:	85 c9                	test   %ecx,%ecx
c0101f28:	74 0f                	je     c0101f39 <trap_dispatch+0x148>
c0101f2a:	0f b7 0a             	movzwl (%edx),%ecx
c0101f2d:	66 89 08             	mov    %cx,(%eax)
c0101f30:	8d 40 02             	lea    0x2(%eax),%eax
c0101f33:	8d 52 02             	lea    0x2(%edx),%edx
c0101f36:	83 eb 02             	sub    $0x2,%ebx
c0101f39:	89 df                	mov    %ebx,%edi
c0101f3b:	83 e7 fc             	and    $0xfffffffc,%edi
c0101f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101f43:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0101f46:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0101f49:	83 c1 04             	add    $0x4,%ecx
c0101f4c:	39 f9                	cmp    %edi,%ecx
c0101f4e:	72 f3                	jb     c0101f43 <trap_dispatch+0x152>
c0101f50:	01 c8                	add    %ecx,%eax
c0101f52:	01 ca                	add    %ecx,%edx
c0101f54:	b9 00 00 00 00       	mov    $0x0,%ecx
c0101f59:	89 de                	mov    %ebx,%esi
c0101f5b:	83 e6 02             	and    $0x2,%esi
c0101f5e:	85 f6                	test   %esi,%esi
c0101f60:	74 0b                	je     c0101f6d <trap_dispatch+0x17c>
c0101f62:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0101f66:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0101f6a:	83 c1 02             	add    $0x2,%ecx
c0101f6d:	83 e3 01             	and    $0x1,%ebx
c0101f70:	85 db                	test   %ebx,%ebx
c0101f72:	74 07                	je     c0101f7b <trap_dispatch+0x18a>
c0101f74:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0101f78:	88 14 08             	mov    %dl,(%eax,%ecx,1)
            switchk2u.tf_cs = USER_CS;
c0101f7b:	66 c7 05 5c df 11 c0 	movw   $0x1b,0xc011df5c
c0101f82:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101f84:	66 c7 05 68 df 11 c0 	movw   $0x23,0xc011df68
c0101f8b:	23 00 
c0101f8d:	0f b7 05 68 df 11 c0 	movzwl 0xc011df68,%eax
c0101f94:	66 a3 48 df 11 c0    	mov    %ax,0xc011df48
c0101f9a:	0f b7 05 48 df 11 c0 	movzwl 0xc011df48,%eax
c0101fa1:	66 a3 4c df 11 c0    	mov    %ax,0xc011df4c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101faa:	83 c0 44             	add    $0x44,%eax
c0101fad:	a3 64 df 11 c0       	mov    %eax,0xc011df64
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0101fb2:	a1 60 df 11 c0       	mov    0xc011df60,%eax
c0101fb7:	0d 00 30 00 00       	or     $0x3000,%eax
c0101fbc:	a3 60 df 11 c0       	mov    %eax,0xc011df60
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101fc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fc4:	83 e8 04             	sub    $0x4,%eax
c0101fc7:	ba 20 df 11 c0       	mov    $0xc011df20,%edx
c0101fcc:	89 10                	mov    %edx,(%eax)
        }
        break;
c0101fce:	e9 b8 00 00 00       	jmp    c010208b <trap_dispatch+0x29a>
    case T_SWITCH_TOK:
    	if (tf->tf_cs != KERNEL_CS) {
c0101fd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fd6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101fda:	83 f8 08             	cmp    $0x8,%eax
c0101fdd:	0f 84 ab 00 00 00    	je     c010208e <trap_dispatch+0x29d>
            tf->tf_cs = KERNEL_CS;
c0101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fe6:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101fec:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fef:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ff8:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101ffc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fff:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0102003:	8b 45 08             	mov    0x8(%ebp),%eax
c0102006:	8b 40 40             	mov    0x40(%eax),%eax
c0102009:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c010200e:	89 c2                	mov    %eax,%edx
c0102010:	8b 45 08             	mov    0x8(%ebp),%eax
c0102013:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0102016:	8b 45 08             	mov    0x8(%ebp),%eax
c0102019:	8b 40 44             	mov    0x44(%eax),%eax
c010201c:	83 e8 44             	sub    $0x44,%eax
c010201f:	a3 6c df 11 c0       	mov    %eax,0xc011df6c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0102024:	a1 6c df 11 c0       	mov    0xc011df6c,%eax
c0102029:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0102030:	00 
c0102031:	8b 55 08             	mov    0x8(%ebp),%edx
c0102034:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102038:	89 04 24             	mov    %eax,(%esp)
c010203b:	e8 39 3c 00 00       	call   c0105c79 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0102040:	8b 15 6c df 11 c0    	mov    0xc011df6c,%edx
c0102046:	8b 45 08             	mov    0x8(%ebp),%eax
c0102049:	83 e8 04             	sub    $0x4,%eax
c010204c:	89 10                	mov    %edx,(%eax)
        }
        break;
c010204e:	eb 3e                	jmp    c010208e <trap_dispatch+0x29d>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102050:	8b 45 08             	mov    0x8(%ebp),%eax
c0102053:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102057:	83 e0 03             	and    $0x3,%eax
c010205a:	85 c0                	test   %eax,%eax
c010205c:	75 31                	jne    c010208f <trap_dispatch+0x29e>
            print_trapframe(tf);
c010205e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102061:	89 04 24             	mov    %eax,(%esp)
c0102064:	e8 17 fb ff ff       	call   c0101b80 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102069:	c7 44 24 08 95 69 10 	movl   $0xc0106995,0x8(%esp)
c0102070:	c0 
c0102071:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0102078:	00 
c0102079:	c7 04 24 b1 69 10 c0 	movl   $0xc01069b1,(%esp)
c0102080:	e8 b1 e3 ff ff       	call   c0100436 <__panic>
        break;
c0102085:	90                   	nop
c0102086:	eb 07                	jmp    c010208f <trap_dispatch+0x29e>
        break;
c0102088:	90                   	nop
c0102089:	eb 04                	jmp    c010208f <trap_dispatch+0x29e>
        break;
c010208b:	90                   	nop
c010208c:	eb 01                	jmp    c010208f <trap_dispatch+0x29e>
        break;
c010208e:	90                   	nop
        }
    }
}
c010208f:	90                   	nop
c0102090:	83 c4 2c             	add    $0x2c,%esp
c0102093:	5b                   	pop    %ebx
c0102094:	5e                   	pop    %esi
c0102095:	5f                   	pop    %edi
c0102096:	5d                   	pop    %ebp
c0102097:	c3                   	ret    

c0102098 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102098:	f3 0f 1e fb          	endbr32 
c010209c:	55                   	push   %ebp
c010209d:	89 e5                	mov    %esp,%ebp
c010209f:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c01020a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01020a5:	89 04 24             	mov    %eax,(%esp)
c01020a8:	e8 44 fd ff ff       	call   c0101df1 <trap_dispatch>
}
c01020ad:	90                   	nop
c01020ae:	c9                   	leave  
c01020af:	c3                   	ret    

c01020b0 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $0
c01020b2:	6a 00                	push   $0x0
  jmp __alltraps
c01020b4:	e9 69 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020b9 <vector1>:
.globl vector1
vector1:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $1
c01020bb:	6a 01                	push   $0x1
  jmp __alltraps
c01020bd:	e9 60 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020c2 <vector2>:
.globl vector2
vector2:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $2
c01020c4:	6a 02                	push   $0x2
  jmp __alltraps
c01020c6:	e9 57 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020cb <vector3>:
.globl vector3
vector3:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $3
c01020cd:	6a 03                	push   $0x3
  jmp __alltraps
c01020cf:	e9 4e 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020d4 <vector4>:
.globl vector4
vector4:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $4
c01020d6:	6a 04                	push   $0x4
  jmp __alltraps
c01020d8:	e9 45 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020dd <vector5>:
.globl vector5
vector5:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $5
c01020df:	6a 05                	push   $0x5
  jmp __alltraps
c01020e1:	e9 3c 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020e6 <vector6>:
.globl vector6
vector6:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $6
c01020e8:	6a 06                	push   $0x6
  jmp __alltraps
c01020ea:	e9 33 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020ef <vector7>:
.globl vector7
vector7:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $7
c01020f1:	6a 07                	push   $0x7
  jmp __alltraps
c01020f3:	e9 2a 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020f8 <vector8>:
.globl vector8
vector8:
  pushl $8
c01020f8:	6a 08                	push   $0x8
  jmp __alltraps
c01020fa:	e9 23 0a 00 00       	jmp    c0102b22 <__alltraps>

c01020ff <vector9>:
.globl vector9
vector9:
  pushl $0
c01020ff:	6a 00                	push   $0x0
  pushl $9
c0102101:	6a 09                	push   $0x9
  jmp __alltraps
c0102103:	e9 1a 0a 00 00       	jmp    c0102b22 <__alltraps>

c0102108 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102108:	6a 0a                	push   $0xa
  jmp __alltraps
c010210a:	e9 13 0a 00 00       	jmp    c0102b22 <__alltraps>

c010210f <vector11>:
.globl vector11
vector11:
  pushl $11
c010210f:	6a 0b                	push   $0xb
  jmp __alltraps
c0102111:	e9 0c 0a 00 00       	jmp    c0102b22 <__alltraps>

c0102116 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102116:	6a 0c                	push   $0xc
  jmp __alltraps
c0102118:	e9 05 0a 00 00       	jmp    c0102b22 <__alltraps>

c010211d <vector13>:
.globl vector13
vector13:
  pushl $13
c010211d:	6a 0d                	push   $0xd
  jmp __alltraps
c010211f:	e9 fe 09 00 00       	jmp    c0102b22 <__alltraps>

c0102124 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102124:	6a 0e                	push   $0xe
  jmp __alltraps
c0102126:	e9 f7 09 00 00       	jmp    c0102b22 <__alltraps>

c010212b <vector15>:
.globl vector15
vector15:
  pushl $0
c010212b:	6a 00                	push   $0x0
  pushl $15
c010212d:	6a 0f                	push   $0xf
  jmp __alltraps
c010212f:	e9 ee 09 00 00       	jmp    c0102b22 <__alltraps>

c0102134 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102134:	6a 00                	push   $0x0
  pushl $16
c0102136:	6a 10                	push   $0x10
  jmp __alltraps
c0102138:	e9 e5 09 00 00       	jmp    c0102b22 <__alltraps>

c010213d <vector17>:
.globl vector17
vector17:
  pushl $17
c010213d:	6a 11                	push   $0x11
  jmp __alltraps
c010213f:	e9 de 09 00 00       	jmp    c0102b22 <__alltraps>

c0102144 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102144:	6a 00                	push   $0x0
  pushl $18
c0102146:	6a 12                	push   $0x12
  jmp __alltraps
c0102148:	e9 d5 09 00 00       	jmp    c0102b22 <__alltraps>

c010214d <vector19>:
.globl vector19
vector19:
  pushl $0
c010214d:	6a 00                	push   $0x0
  pushl $19
c010214f:	6a 13                	push   $0x13
  jmp __alltraps
c0102151:	e9 cc 09 00 00       	jmp    c0102b22 <__alltraps>

c0102156 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102156:	6a 00                	push   $0x0
  pushl $20
c0102158:	6a 14                	push   $0x14
  jmp __alltraps
c010215a:	e9 c3 09 00 00       	jmp    c0102b22 <__alltraps>

c010215f <vector21>:
.globl vector21
vector21:
  pushl $0
c010215f:	6a 00                	push   $0x0
  pushl $21
c0102161:	6a 15                	push   $0x15
  jmp __alltraps
c0102163:	e9 ba 09 00 00       	jmp    c0102b22 <__alltraps>

c0102168 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102168:	6a 00                	push   $0x0
  pushl $22
c010216a:	6a 16                	push   $0x16
  jmp __alltraps
c010216c:	e9 b1 09 00 00       	jmp    c0102b22 <__alltraps>

c0102171 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102171:	6a 00                	push   $0x0
  pushl $23
c0102173:	6a 17                	push   $0x17
  jmp __alltraps
c0102175:	e9 a8 09 00 00       	jmp    c0102b22 <__alltraps>

c010217a <vector24>:
.globl vector24
vector24:
  pushl $0
c010217a:	6a 00                	push   $0x0
  pushl $24
c010217c:	6a 18                	push   $0x18
  jmp __alltraps
c010217e:	e9 9f 09 00 00       	jmp    c0102b22 <__alltraps>

c0102183 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102183:	6a 00                	push   $0x0
  pushl $25
c0102185:	6a 19                	push   $0x19
  jmp __alltraps
c0102187:	e9 96 09 00 00       	jmp    c0102b22 <__alltraps>

c010218c <vector26>:
.globl vector26
vector26:
  pushl $0
c010218c:	6a 00                	push   $0x0
  pushl $26
c010218e:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102190:	e9 8d 09 00 00       	jmp    c0102b22 <__alltraps>

c0102195 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102195:	6a 00                	push   $0x0
  pushl $27
c0102197:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102199:	e9 84 09 00 00       	jmp    c0102b22 <__alltraps>

c010219e <vector28>:
.globl vector28
vector28:
  pushl $0
c010219e:	6a 00                	push   $0x0
  pushl $28
c01021a0:	6a 1c                	push   $0x1c
  jmp __alltraps
c01021a2:	e9 7b 09 00 00       	jmp    c0102b22 <__alltraps>

c01021a7 <vector29>:
.globl vector29
vector29:
  pushl $0
c01021a7:	6a 00                	push   $0x0
  pushl $29
c01021a9:	6a 1d                	push   $0x1d
  jmp __alltraps
c01021ab:	e9 72 09 00 00       	jmp    c0102b22 <__alltraps>

c01021b0 <vector30>:
.globl vector30
vector30:
  pushl $0
c01021b0:	6a 00                	push   $0x0
  pushl $30
c01021b2:	6a 1e                	push   $0x1e
  jmp __alltraps
c01021b4:	e9 69 09 00 00       	jmp    c0102b22 <__alltraps>

c01021b9 <vector31>:
.globl vector31
vector31:
  pushl $0
c01021b9:	6a 00                	push   $0x0
  pushl $31
c01021bb:	6a 1f                	push   $0x1f
  jmp __alltraps
c01021bd:	e9 60 09 00 00       	jmp    c0102b22 <__alltraps>

c01021c2 <vector32>:
.globl vector32
vector32:
  pushl $0
c01021c2:	6a 00                	push   $0x0
  pushl $32
c01021c4:	6a 20                	push   $0x20
  jmp __alltraps
c01021c6:	e9 57 09 00 00       	jmp    c0102b22 <__alltraps>

c01021cb <vector33>:
.globl vector33
vector33:
  pushl $0
c01021cb:	6a 00                	push   $0x0
  pushl $33
c01021cd:	6a 21                	push   $0x21
  jmp __alltraps
c01021cf:	e9 4e 09 00 00       	jmp    c0102b22 <__alltraps>

c01021d4 <vector34>:
.globl vector34
vector34:
  pushl $0
c01021d4:	6a 00                	push   $0x0
  pushl $34
c01021d6:	6a 22                	push   $0x22
  jmp __alltraps
c01021d8:	e9 45 09 00 00       	jmp    c0102b22 <__alltraps>

c01021dd <vector35>:
.globl vector35
vector35:
  pushl $0
c01021dd:	6a 00                	push   $0x0
  pushl $35
c01021df:	6a 23                	push   $0x23
  jmp __alltraps
c01021e1:	e9 3c 09 00 00       	jmp    c0102b22 <__alltraps>

c01021e6 <vector36>:
.globl vector36
vector36:
  pushl $0
c01021e6:	6a 00                	push   $0x0
  pushl $36
c01021e8:	6a 24                	push   $0x24
  jmp __alltraps
c01021ea:	e9 33 09 00 00       	jmp    c0102b22 <__alltraps>

c01021ef <vector37>:
.globl vector37
vector37:
  pushl $0
c01021ef:	6a 00                	push   $0x0
  pushl $37
c01021f1:	6a 25                	push   $0x25
  jmp __alltraps
c01021f3:	e9 2a 09 00 00       	jmp    c0102b22 <__alltraps>

c01021f8 <vector38>:
.globl vector38
vector38:
  pushl $0
c01021f8:	6a 00                	push   $0x0
  pushl $38
c01021fa:	6a 26                	push   $0x26
  jmp __alltraps
c01021fc:	e9 21 09 00 00       	jmp    c0102b22 <__alltraps>

c0102201 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102201:	6a 00                	push   $0x0
  pushl $39
c0102203:	6a 27                	push   $0x27
  jmp __alltraps
c0102205:	e9 18 09 00 00       	jmp    c0102b22 <__alltraps>

c010220a <vector40>:
.globl vector40
vector40:
  pushl $0
c010220a:	6a 00                	push   $0x0
  pushl $40
c010220c:	6a 28                	push   $0x28
  jmp __alltraps
c010220e:	e9 0f 09 00 00       	jmp    c0102b22 <__alltraps>

c0102213 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $41
c0102215:	6a 29                	push   $0x29
  jmp __alltraps
c0102217:	e9 06 09 00 00       	jmp    c0102b22 <__alltraps>

c010221c <vector42>:
.globl vector42
vector42:
  pushl $0
c010221c:	6a 00                	push   $0x0
  pushl $42
c010221e:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102220:	e9 fd 08 00 00       	jmp    c0102b22 <__alltraps>

c0102225 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102225:	6a 00                	push   $0x0
  pushl $43
c0102227:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102229:	e9 f4 08 00 00       	jmp    c0102b22 <__alltraps>

c010222e <vector44>:
.globl vector44
vector44:
  pushl $0
c010222e:	6a 00                	push   $0x0
  pushl $44
c0102230:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102232:	e9 eb 08 00 00       	jmp    c0102b22 <__alltraps>

c0102237 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $45
c0102239:	6a 2d                	push   $0x2d
  jmp __alltraps
c010223b:	e9 e2 08 00 00       	jmp    c0102b22 <__alltraps>

c0102240 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102240:	6a 00                	push   $0x0
  pushl $46
c0102242:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102244:	e9 d9 08 00 00       	jmp    c0102b22 <__alltraps>

c0102249 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102249:	6a 00                	push   $0x0
  pushl $47
c010224b:	6a 2f                	push   $0x2f
  jmp __alltraps
c010224d:	e9 d0 08 00 00       	jmp    c0102b22 <__alltraps>

c0102252 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102252:	6a 00                	push   $0x0
  pushl $48
c0102254:	6a 30                	push   $0x30
  jmp __alltraps
c0102256:	e9 c7 08 00 00       	jmp    c0102b22 <__alltraps>

c010225b <vector49>:
.globl vector49
vector49:
  pushl $0
c010225b:	6a 00                	push   $0x0
  pushl $49
c010225d:	6a 31                	push   $0x31
  jmp __alltraps
c010225f:	e9 be 08 00 00       	jmp    c0102b22 <__alltraps>

c0102264 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102264:	6a 00                	push   $0x0
  pushl $50
c0102266:	6a 32                	push   $0x32
  jmp __alltraps
c0102268:	e9 b5 08 00 00       	jmp    c0102b22 <__alltraps>

c010226d <vector51>:
.globl vector51
vector51:
  pushl $0
c010226d:	6a 00                	push   $0x0
  pushl $51
c010226f:	6a 33                	push   $0x33
  jmp __alltraps
c0102271:	e9 ac 08 00 00       	jmp    c0102b22 <__alltraps>

c0102276 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102276:	6a 00                	push   $0x0
  pushl $52
c0102278:	6a 34                	push   $0x34
  jmp __alltraps
c010227a:	e9 a3 08 00 00       	jmp    c0102b22 <__alltraps>

c010227f <vector53>:
.globl vector53
vector53:
  pushl $0
c010227f:	6a 00                	push   $0x0
  pushl $53
c0102281:	6a 35                	push   $0x35
  jmp __alltraps
c0102283:	e9 9a 08 00 00       	jmp    c0102b22 <__alltraps>

c0102288 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102288:	6a 00                	push   $0x0
  pushl $54
c010228a:	6a 36                	push   $0x36
  jmp __alltraps
c010228c:	e9 91 08 00 00       	jmp    c0102b22 <__alltraps>

c0102291 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102291:	6a 00                	push   $0x0
  pushl $55
c0102293:	6a 37                	push   $0x37
  jmp __alltraps
c0102295:	e9 88 08 00 00       	jmp    c0102b22 <__alltraps>

c010229a <vector56>:
.globl vector56
vector56:
  pushl $0
c010229a:	6a 00                	push   $0x0
  pushl $56
c010229c:	6a 38                	push   $0x38
  jmp __alltraps
c010229e:	e9 7f 08 00 00       	jmp    c0102b22 <__alltraps>

c01022a3 <vector57>:
.globl vector57
vector57:
  pushl $0
c01022a3:	6a 00                	push   $0x0
  pushl $57
c01022a5:	6a 39                	push   $0x39
  jmp __alltraps
c01022a7:	e9 76 08 00 00       	jmp    c0102b22 <__alltraps>

c01022ac <vector58>:
.globl vector58
vector58:
  pushl $0
c01022ac:	6a 00                	push   $0x0
  pushl $58
c01022ae:	6a 3a                	push   $0x3a
  jmp __alltraps
c01022b0:	e9 6d 08 00 00       	jmp    c0102b22 <__alltraps>

c01022b5 <vector59>:
.globl vector59
vector59:
  pushl $0
c01022b5:	6a 00                	push   $0x0
  pushl $59
c01022b7:	6a 3b                	push   $0x3b
  jmp __alltraps
c01022b9:	e9 64 08 00 00       	jmp    c0102b22 <__alltraps>

c01022be <vector60>:
.globl vector60
vector60:
  pushl $0
c01022be:	6a 00                	push   $0x0
  pushl $60
c01022c0:	6a 3c                	push   $0x3c
  jmp __alltraps
c01022c2:	e9 5b 08 00 00       	jmp    c0102b22 <__alltraps>

c01022c7 <vector61>:
.globl vector61
vector61:
  pushl $0
c01022c7:	6a 00                	push   $0x0
  pushl $61
c01022c9:	6a 3d                	push   $0x3d
  jmp __alltraps
c01022cb:	e9 52 08 00 00       	jmp    c0102b22 <__alltraps>

c01022d0 <vector62>:
.globl vector62
vector62:
  pushl $0
c01022d0:	6a 00                	push   $0x0
  pushl $62
c01022d2:	6a 3e                	push   $0x3e
  jmp __alltraps
c01022d4:	e9 49 08 00 00       	jmp    c0102b22 <__alltraps>

c01022d9 <vector63>:
.globl vector63
vector63:
  pushl $0
c01022d9:	6a 00                	push   $0x0
  pushl $63
c01022db:	6a 3f                	push   $0x3f
  jmp __alltraps
c01022dd:	e9 40 08 00 00       	jmp    c0102b22 <__alltraps>

c01022e2 <vector64>:
.globl vector64
vector64:
  pushl $0
c01022e2:	6a 00                	push   $0x0
  pushl $64
c01022e4:	6a 40                	push   $0x40
  jmp __alltraps
c01022e6:	e9 37 08 00 00       	jmp    c0102b22 <__alltraps>

c01022eb <vector65>:
.globl vector65
vector65:
  pushl $0
c01022eb:	6a 00                	push   $0x0
  pushl $65
c01022ed:	6a 41                	push   $0x41
  jmp __alltraps
c01022ef:	e9 2e 08 00 00       	jmp    c0102b22 <__alltraps>

c01022f4 <vector66>:
.globl vector66
vector66:
  pushl $0
c01022f4:	6a 00                	push   $0x0
  pushl $66
c01022f6:	6a 42                	push   $0x42
  jmp __alltraps
c01022f8:	e9 25 08 00 00       	jmp    c0102b22 <__alltraps>

c01022fd <vector67>:
.globl vector67
vector67:
  pushl $0
c01022fd:	6a 00                	push   $0x0
  pushl $67
c01022ff:	6a 43                	push   $0x43
  jmp __alltraps
c0102301:	e9 1c 08 00 00       	jmp    c0102b22 <__alltraps>

c0102306 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102306:	6a 00                	push   $0x0
  pushl $68
c0102308:	6a 44                	push   $0x44
  jmp __alltraps
c010230a:	e9 13 08 00 00       	jmp    c0102b22 <__alltraps>

c010230f <vector69>:
.globl vector69
vector69:
  pushl $0
c010230f:	6a 00                	push   $0x0
  pushl $69
c0102311:	6a 45                	push   $0x45
  jmp __alltraps
c0102313:	e9 0a 08 00 00       	jmp    c0102b22 <__alltraps>

c0102318 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102318:	6a 00                	push   $0x0
  pushl $70
c010231a:	6a 46                	push   $0x46
  jmp __alltraps
c010231c:	e9 01 08 00 00       	jmp    c0102b22 <__alltraps>

c0102321 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102321:	6a 00                	push   $0x0
  pushl $71
c0102323:	6a 47                	push   $0x47
  jmp __alltraps
c0102325:	e9 f8 07 00 00       	jmp    c0102b22 <__alltraps>

c010232a <vector72>:
.globl vector72
vector72:
  pushl $0
c010232a:	6a 00                	push   $0x0
  pushl $72
c010232c:	6a 48                	push   $0x48
  jmp __alltraps
c010232e:	e9 ef 07 00 00       	jmp    c0102b22 <__alltraps>

c0102333 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102333:	6a 00                	push   $0x0
  pushl $73
c0102335:	6a 49                	push   $0x49
  jmp __alltraps
c0102337:	e9 e6 07 00 00       	jmp    c0102b22 <__alltraps>

c010233c <vector74>:
.globl vector74
vector74:
  pushl $0
c010233c:	6a 00                	push   $0x0
  pushl $74
c010233e:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102340:	e9 dd 07 00 00       	jmp    c0102b22 <__alltraps>

c0102345 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102345:	6a 00                	push   $0x0
  pushl $75
c0102347:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102349:	e9 d4 07 00 00       	jmp    c0102b22 <__alltraps>

c010234e <vector76>:
.globl vector76
vector76:
  pushl $0
c010234e:	6a 00                	push   $0x0
  pushl $76
c0102350:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102352:	e9 cb 07 00 00       	jmp    c0102b22 <__alltraps>

c0102357 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $77
c0102359:	6a 4d                	push   $0x4d
  jmp __alltraps
c010235b:	e9 c2 07 00 00       	jmp    c0102b22 <__alltraps>

c0102360 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102360:	6a 00                	push   $0x0
  pushl $78
c0102362:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102364:	e9 b9 07 00 00       	jmp    c0102b22 <__alltraps>

c0102369 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102369:	6a 00                	push   $0x0
  pushl $79
c010236b:	6a 4f                	push   $0x4f
  jmp __alltraps
c010236d:	e9 b0 07 00 00       	jmp    c0102b22 <__alltraps>

c0102372 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102372:	6a 00                	push   $0x0
  pushl $80
c0102374:	6a 50                	push   $0x50
  jmp __alltraps
c0102376:	e9 a7 07 00 00       	jmp    c0102b22 <__alltraps>

c010237b <vector81>:
.globl vector81
vector81:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $81
c010237d:	6a 51                	push   $0x51
  jmp __alltraps
c010237f:	e9 9e 07 00 00       	jmp    c0102b22 <__alltraps>

c0102384 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102384:	6a 00                	push   $0x0
  pushl $82
c0102386:	6a 52                	push   $0x52
  jmp __alltraps
c0102388:	e9 95 07 00 00       	jmp    c0102b22 <__alltraps>

c010238d <vector83>:
.globl vector83
vector83:
  pushl $0
c010238d:	6a 00                	push   $0x0
  pushl $83
c010238f:	6a 53                	push   $0x53
  jmp __alltraps
c0102391:	e9 8c 07 00 00       	jmp    c0102b22 <__alltraps>

c0102396 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102396:	6a 00                	push   $0x0
  pushl $84
c0102398:	6a 54                	push   $0x54
  jmp __alltraps
c010239a:	e9 83 07 00 00       	jmp    c0102b22 <__alltraps>

c010239f <vector85>:
.globl vector85
vector85:
  pushl $0
c010239f:	6a 00                	push   $0x0
  pushl $85
c01023a1:	6a 55                	push   $0x55
  jmp __alltraps
c01023a3:	e9 7a 07 00 00       	jmp    c0102b22 <__alltraps>

c01023a8 <vector86>:
.globl vector86
vector86:
  pushl $0
c01023a8:	6a 00                	push   $0x0
  pushl $86
c01023aa:	6a 56                	push   $0x56
  jmp __alltraps
c01023ac:	e9 71 07 00 00       	jmp    c0102b22 <__alltraps>

c01023b1 <vector87>:
.globl vector87
vector87:
  pushl $0
c01023b1:	6a 00                	push   $0x0
  pushl $87
c01023b3:	6a 57                	push   $0x57
  jmp __alltraps
c01023b5:	e9 68 07 00 00       	jmp    c0102b22 <__alltraps>

c01023ba <vector88>:
.globl vector88
vector88:
  pushl $0
c01023ba:	6a 00                	push   $0x0
  pushl $88
c01023bc:	6a 58                	push   $0x58
  jmp __alltraps
c01023be:	e9 5f 07 00 00       	jmp    c0102b22 <__alltraps>

c01023c3 <vector89>:
.globl vector89
vector89:
  pushl $0
c01023c3:	6a 00                	push   $0x0
  pushl $89
c01023c5:	6a 59                	push   $0x59
  jmp __alltraps
c01023c7:	e9 56 07 00 00       	jmp    c0102b22 <__alltraps>

c01023cc <vector90>:
.globl vector90
vector90:
  pushl $0
c01023cc:	6a 00                	push   $0x0
  pushl $90
c01023ce:	6a 5a                	push   $0x5a
  jmp __alltraps
c01023d0:	e9 4d 07 00 00       	jmp    c0102b22 <__alltraps>

c01023d5 <vector91>:
.globl vector91
vector91:
  pushl $0
c01023d5:	6a 00                	push   $0x0
  pushl $91
c01023d7:	6a 5b                	push   $0x5b
  jmp __alltraps
c01023d9:	e9 44 07 00 00       	jmp    c0102b22 <__alltraps>

c01023de <vector92>:
.globl vector92
vector92:
  pushl $0
c01023de:	6a 00                	push   $0x0
  pushl $92
c01023e0:	6a 5c                	push   $0x5c
  jmp __alltraps
c01023e2:	e9 3b 07 00 00       	jmp    c0102b22 <__alltraps>

c01023e7 <vector93>:
.globl vector93
vector93:
  pushl $0
c01023e7:	6a 00                	push   $0x0
  pushl $93
c01023e9:	6a 5d                	push   $0x5d
  jmp __alltraps
c01023eb:	e9 32 07 00 00       	jmp    c0102b22 <__alltraps>

c01023f0 <vector94>:
.globl vector94
vector94:
  pushl $0
c01023f0:	6a 00                	push   $0x0
  pushl $94
c01023f2:	6a 5e                	push   $0x5e
  jmp __alltraps
c01023f4:	e9 29 07 00 00       	jmp    c0102b22 <__alltraps>

c01023f9 <vector95>:
.globl vector95
vector95:
  pushl $0
c01023f9:	6a 00                	push   $0x0
  pushl $95
c01023fb:	6a 5f                	push   $0x5f
  jmp __alltraps
c01023fd:	e9 20 07 00 00       	jmp    c0102b22 <__alltraps>

c0102402 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102402:	6a 00                	push   $0x0
  pushl $96
c0102404:	6a 60                	push   $0x60
  jmp __alltraps
c0102406:	e9 17 07 00 00       	jmp    c0102b22 <__alltraps>

c010240b <vector97>:
.globl vector97
vector97:
  pushl $0
c010240b:	6a 00                	push   $0x0
  pushl $97
c010240d:	6a 61                	push   $0x61
  jmp __alltraps
c010240f:	e9 0e 07 00 00       	jmp    c0102b22 <__alltraps>

c0102414 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102414:	6a 00                	push   $0x0
  pushl $98
c0102416:	6a 62                	push   $0x62
  jmp __alltraps
c0102418:	e9 05 07 00 00       	jmp    c0102b22 <__alltraps>

c010241d <vector99>:
.globl vector99
vector99:
  pushl $0
c010241d:	6a 00                	push   $0x0
  pushl $99
c010241f:	6a 63                	push   $0x63
  jmp __alltraps
c0102421:	e9 fc 06 00 00       	jmp    c0102b22 <__alltraps>

c0102426 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102426:	6a 00                	push   $0x0
  pushl $100
c0102428:	6a 64                	push   $0x64
  jmp __alltraps
c010242a:	e9 f3 06 00 00       	jmp    c0102b22 <__alltraps>

c010242f <vector101>:
.globl vector101
vector101:
  pushl $0
c010242f:	6a 00                	push   $0x0
  pushl $101
c0102431:	6a 65                	push   $0x65
  jmp __alltraps
c0102433:	e9 ea 06 00 00       	jmp    c0102b22 <__alltraps>

c0102438 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102438:	6a 00                	push   $0x0
  pushl $102
c010243a:	6a 66                	push   $0x66
  jmp __alltraps
c010243c:	e9 e1 06 00 00       	jmp    c0102b22 <__alltraps>

c0102441 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102441:	6a 00                	push   $0x0
  pushl $103
c0102443:	6a 67                	push   $0x67
  jmp __alltraps
c0102445:	e9 d8 06 00 00       	jmp    c0102b22 <__alltraps>

c010244a <vector104>:
.globl vector104
vector104:
  pushl $0
c010244a:	6a 00                	push   $0x0
  pushl $104
c010244c:	6a 68                	push   $0x68
  jmp __alltraps
c010244e:	e9 cf 06 00 00       	jmp    c0102b22 <__alltraps>

c0102453 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102453:	6a 00                	push   $0x0
  pushl $105
c0102455:	6a 69                	push   $0x69
  jmp __alltraps
c0102457:	e9 c6 06 00 00       	jmp    c0102b22 <__alltraps>

c010245c <vector106>:
.globl vector106
vector106:
  pushl $0
c010245c:	6a 00                	push   $0x0
  pushl $106
c010245e:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102460:	e9 bd 06 00 00       	jmp    c0102b22 <__alltraps>

c0102465 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102465:	6a 00                	push   $0x0
  pushl $107
c0102467:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102469:	e9 b4 06 00 00       	jmp    c0102b22 <__alltraps>

c010246e <vector108>:
.globl vector108
vector108:
  pushl $0
c010246e:	6a 00                	push   $0x0
  pushl $108
c0102470:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102472:	e9 ab 06 00 00       	jmp    c0102b22 <__alltraps>

c0102477 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102477:	6a 00                	push   $0x0
  pushl $109
c0102479:	6a 6d                	push   $0x6d
  jmp __alltraps
c010247b:	e9 a2 06 00 00       	jmp    c0102b22 <__alltraps>

c0102480 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102480:	6a 00                	push   $0x0
  pushl $110
c0102482:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102484:	e9 99 06 00 00       	jmp    c0102b22 <__alltraps>

c0102489 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102489:	6a 00                	push   $0x0
  pushl $111
c010248b:	6a 6f                	push   $0x6f
  jmp __alltraps
c010248d:	e9 90 06 00 00       	jmp    c0102b22 <__alltraps>

c0102492 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102492:	6a 00                	push   $0x0
  pushl $112
c0102494:	6a 70                	push   $0x70
  jmp __alltraps
c0102496:	e9 87 06 00 00       	jmp    c0102b22 <__alltraps>

c010249b <vector113>:
.globl vector113
vector113:
  pushl $0
c010249b:	6a 00                	push   $0x0
  pushl $113
c010249d:	6a 71                	push   $0x71
  jmp __alltraps
c010249f:	e9 7e 06 00 00       	jmp    c0102b22 <__alltraps>

c01024a4 <vector114>:
.globl vector114
vector114:
  pushl $0
c01024a4:	6a 00                	push   $0x0
  pushl $114
c01024a6:	6a 72                	push   $0x72
  jmp __alltraps
c01024a8:	e9 75 06 00 00       	jmp    c0102b22 <__alltraps>

c01024ad <vector115>:
.globl vector115
vector115:
  pushl $0
c01024ad:	6a 00                	push   $0x0
  pushl $115
c01024af:	6a 73                	push   $0x73
  jmp __alltraps
c01024b1:	e9 6c 06 00 00       	jmp    c0102b22 <__alltraps>

c01024b6 <vector116>:
.globl vector116
vector116:
  pushl $0
c01024b6:	6a 00                	push   $0x0
  pushl $116
c01024b8:	6a 74                	push   $0x74
  jmp __alltraps
c01024ba:	e9 63 06 00 00       	jmp    c0102b22 <__alltraps>

c01024bf <vector117>:
.globl vector117
vector117:
  pushl $0
c01024bf:	6a 00                	push   $0x0
  pushl $117
c01024c1:	6a 75                	push   $0x75
  jmp __alltraps
c01024c3:	e9 5a 06 00 00       	jmp    c0102b22 <__alltraps>

c01024c8 <vector118>:
.globl vector118
vector118:
  pushl $0
c01024c8:	6a 00                	push   $0x0
  pushl $118
c01024ca:	6a 76                	push   $0x76
  jmp __alltraps
c01024cc:	e9 51 06 00 00       	jmp    c0102b22 <__alltraps>

c01024d1 <vector119>:
.globl vector119
vector119:
  pushl $0
c01024d1:	6a 00                	push   $0x0
  pushl $119
c01024d3:	6a 77                	push   $0x77
  jmp __alltraps
c01024d5:	e9 48 06 00 00       	jmp    c0102b22 <__alltraps>

c01024da <vector120>:
.globl vector120
vector120:
  pushl $0
c01024da:	6a 00                	push   $0x0
  pushl $120
c01024dc:	6a 78                	push   $0x78
  jmp __alltraps
c01024de:	e9 3f 06 00 00       	jmp    c0102b22 <__alltraps>

c01024e3 <vector121>:
.globl vector121
vector121:
  pushl $0
c01024e3:	6a 00                	push   $0x0
  pushl $121
c01024e5:	6a 79                	push   $0x79
  jmp __alltraps
c01024e7:	e9 36 06 00 00       	jmp    c0102b22 <__alltraps>

c01024ec <vector122>:
.globl vector122
vector122:
  pushl $0
c01024ec:	6a 00                	push   $0x0
  pushl $122
c01024ee:	6a 7a                	push   $0x7a
  jmp __alltraps
c01024f0:	e9 2d 06 00 00       	jmp    c0102b22 <__alltraps>

c01024f5 <vector123>:
.globl vector123
vector123:
  pushl $0
c01024f5:	6a 00                	push   $0x0
  pushl $123
c01024f7:	6a 7b                	push   $0x7b
  jmp __alltraps
c01024f9:	e9 24 06 00 00       	jmp    c0102b22 <__alltraps>

c01024fe <vector124>:
.globl vector124
vector124:
  pushl $0
c01024fe:	6a 00                	push   $0x0
  pushl $124
c0102500:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102502:	e9 1b 06 00 00       	jmp    c0102b22 <__alltraps>

c0102507 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102507:	6a 00                	push   $0x0
  pushl $125
c0102509:	6a 7d                	push   $0x7d
  jmp __alltraps
c010250b:	e9 12 06 00 00       	jmp    c0102b22 <__alltraps>

c0102510 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102510:	6a 00                	push   $0x0
  pushl $126
c0102512:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102514:	e9 09 06 00 00       	jmp    c0102b22 <__alltraps>

c0102519 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102519:	6a 00                	push   $0x0
  pushl $127
c010251b:	6a 7f                	push   $0x7f
  jmp __alltraps
c010251d:	e9 00 06 00 00       	jmp    c0102b22 <__alltraps>

c0102522 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102522:	6a 00                	push   $0x0
  pushl $128
c0102524:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102529:	e9 f4 05 00 00       	jmp    c0102b22 <__alltraps>

c010252e <vector129>:
.globl vector129
vector129:
  pushl $0
c010252e:	6a 00                	push   $0x0
  pushl $129
c0102530:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102535:	e9 e8 05 00 00       	jmp    c0102b22 <__alltraps>

c010253a <vector130>:
.globl vector130
vector130:
  pushl $0
c010253a:	6a 00                	push   $0x0
  pushl $130
c010253c:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102541:	e9 dc 05 00 00       	jmp    c0102b22 <__alltraps>

c0102546 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102546:	6a 00                	push   $0x0
  pushl $131
c0102548:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010254d:	e9 d0 05 00 00       	jmp    c0102b22 <__alltraps>

c0102552 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102552:	6a 00                	push   $0x0
  pushl $132
c0102554:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102559:	e9 c4 05 00 00       	jmp    c0102b22 <__alltraps>

c010255e <vector133>:
.globl vector133
vector133:
  pushl $0
c010255e:	6a 00                	push   $0x0
  pushl $133
c0102560:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102565:	e9 b8 05 00 00       	jmp    c0102b22 <__alltraps>

c010256a <vector134>:
.globl vector134
vector134:
  pushl $0
c010256a:	6a 00                	push   $0x0
  pushl $134
c010256c:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102571:	e9 ac 05 00 00       	jmp    c0102b22 <__alltraps>

c0102576 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102576:	6a 00                	push   $0x0
  pushl $135
c0102578:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010257d:	e9 a0 05 00 00       	jmp    c0102b22 <__alltraps>

c0102582 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102582:	6a 00                	push   $0x0
  pushl $136
c0102584:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102589:	e9 94 05 00 00       	jmp    c0102b22 <__alltraps>

c010258e <vector137>:
.globl vector137
vector137:
  pushl $0
c010258e:	6a 00                	push   $0x0
  pushl $137
c0102590:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102595:	e9 88 05 00 00       	jmp    c0102b22 <__alltraps>

c010259a <vector138>:
.globl vector138
vector138:
  pushl $0
c010259a:	6a 00                	push   $0x0
  pushl $138
c010259c:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01025a1:	e9 7c 05 00 00       	jmp    c0102b22 <__alltraps>

c01025a6 <vector139>:
.globl vector139
vector139:
  pushl $0
c01025a6:	6a 00                	push   $0x0
  pushl $139
c01025a8:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01025ad:	e9 70 05 00 00       	jmp    c0102b22 <__alltraps>

c01025b2 <vector140>:
.globl vector140
vector140:
  pushl $0
c01025b2:	6a 00                	push   $0x0
  pushl $140
c01025b4:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01025b9:	e9 64 05 00 00       	jmp    c0102b22 <__alltraps>

c01025be <vector141>:
.globl vector141
vector141:
  pushl $0
c01025be:	6a 00                	push   $0x0
  pushl $141
c01025c0:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01025c5:	e9 58 05 00 00       	jmp    c0102b22 <__alltraps>

c01025ca <vector142>:
.globl vector142
vector142:
  pushl $0
c01025ca:	6a 00                	push   $0x0
  pushl $142
c01025cc:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01025d1:	e9 4c 05 00 00       	jmp    c0102b22 <__alltraps>

c01025d6 <vector143>:
.globl vector143
vector143:
  pushl $0
c01025d6:	6a 00                	push   $0x0
  pushl $143
c01025d8:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01025dd:	e9 40 05 00 00       	jmp    c0102b22 <__alltraps>

c01025e2 <vector144>:
.globl vector144
vector144:
  pushl $0
c01025e2:	6a 00                	push   $0x0
  pushl $144
c01025e4:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01025e9:	e9 34 05 00 00       	jmp    c0102b22 <__alltraps>

c01025ee <vector145>:
.globl vector145
vector145:
  pushl $0
c01025ee:	6a 00                	push   $0x0
  pushl $145
c01025f0:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01025f5:	e9 28 05 00 00       	jmp    c0102b22 <__alltraps>

c01025fa <vector146>:
.globl vector146
vector146:
  pushl $0
c01025fa:	6a 00                	push   $0x0
  pushl $146
c01025fc:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102601:	e9 1c 05 00 00       	jmp    c0102b22 <__alltraps>

c0102606 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102606:	6a 00                	push   $0x0
  pushl $147
c0102608:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010260d:	e9 10 05 00 00       	jmp    c0102b22 <__alltraps>

c0102612 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102612:	6a 00                	push   $0x0
  pushl $148
c0102614:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102619:	e9 04 05 00 00       	jmp    c0102b22 <__alltraps>

c010261e <vector149>:
.globl vector149
vector149:
  pushl $0
c010261e:	6a 00                	push   $0x0
  pushl $149
c0102620:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102625:	e9 f8 04 00 00       	jmp    c0102b22 <__alltraps>

c010262a <vector150>:
.globl vector150
vector150:
  pushl $0
c010262a:	6a 00                	push   $0x0
  pushl $150
c010262c:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102631:	e9 ec 04 00 00       	jmp    c0102b22 <__alltraps>

c0102636 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102636:	6a 00                	push   $0x0
  pushl $151
c0102638:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010263d:	e9 e0 04 00 00       	jmp    c0102b22 <__alltraps>

c0102642 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102642:	6a 00                	push   $0x0
  pushl $152
c0102644:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102649:	e9 d4 04 00 00       	jmp    c0102b22 <__alltraps>

c010264e <vector153>:
.globl vector153
vector153:
  pushl $0
c010264e:	6a 00                	push   $0x0
  pushl $153
c0102650:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102655:	e9 c8 04 00 00       	jmp    c0102b22 <__alltraps>

c010265a <vector154>:
.globl vector154
vector154:
  pushl $0
c010265a:	6a 00                	push   $0x0
  pushl $154
c010265c:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102661:	e9 bc 04 00 00       	jmp    c0102b22 <__alltraps>

c0102666 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102666:	6a 00                	push   $0x0
  pushl $155
c0102668:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010266d:	e9 b0 04 00 00       	jmp    c0102b22 <__alltraps>

c0102672 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102672:	6a 00                	push   $0x0
  pushl $156
c0102674:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102679:	e9 a4 04 00 00       	jmp    c0102b22 <__alltraps>

c010267e <vector157>:
.globl vector157
vector157:
  pushl $0
c010267e:	6a 00                	push   $0x0
  pushl $157
c0102680:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102685:	e9 98 04 00 00       	jmp    c0102b22 <__alltraps>

c010268a <vector158>:
.globl vector158
vector158:
  pushl $0
c010268a:	6a 00                	push   $0x0
  pushl $158
c010268c:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102691:	e9 8c 04 00 00       	jmp    c0102b22 <__alltraps>

c0102696 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102696:	6a 00                	push   $0x0
  pushl $159
c0102698:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010269d:	e9 80 04 00 00       	jmp    c0102b22 <__alltraps>

c01026a2 <vector160>:
.globl vector160
vector160:
  pushl $0
c01026a2:	6a 00                	push   $0x0
  pushl $160
c01026a4:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01026a9:	e9 74 04 00 00       	jmp    c0102b22 <__alltraps>

c01026ae <vector161>:
.globl vector161
vector161:
  pushl $0
c01026ae:	6a 00                	push   $0x0
  pushl $161
c01026b0:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01026b5:	e9 68 04 00 00       	jmp    c0102b22 <__alltraps>

c01026ba <vector162>:
.globl vector162
vector162:
  pushl $0
c01026ba:	6a 00                	push   $0x0
  pushl $162
c01026bc:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01026c1:	e9 5c 04 00 00       	jmp    c0102b22 <__alltraps>

c01026c6 <vector163>:
.globl vector163
vector163:
  pushl $0
c01026c6:	6a 00                	push   $0x0
  pushl $163
c01026c8:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01026cd:	e9 50 04 00 00       	jmp    c0102b22 <__alltraps>

c01026d2 <vector164>:
.globl vector164
vector164:
  pushl $0
c01026d2:	6a 00                	push   $0x0
  pushl $164
c01026d4:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01026d9:	e9 44 04 00 00       	jmp    c0102b22 <__alltraps>

c01026de <vector165>:
.globl vector165
vector165:
  pushl $0
c01026de:	6a 00                	push   $0x0
  pushl $165
c01026e0:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01026e5:	e9 38 04 00 00       	jmp    c0102b22 <__alltraps>

c01026ea <vector166>:
.globl vector166
vector166:
  pushl $0
c01026ea:	6a 00                	push   $0x0
  pushl $166
c01026ec:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01026f1:	e9 2c 04 00 00       	jmp    c0102b22 <__alltraps>

c01026f6 <vector167>:
.globl vector167
vector167:
  pushl $0
c01026f6:	6a 00                	push   $0x0
  pushl $167
c01026f8:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01026fd:	e9 20 04 00 00       	jmp    c0102b22 <__alltraps>

c0102702 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102702:	6a 00                	push   $0x0
  pushl $168
c0102704:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102709:	e9 14 04 00 00       	jmp    c0102b22 <__alltraps>

c010270e <vector169>:
.globl vector169
vector169:
  pushl $0
c010270e:	6a 00                	push   $0x0
  pushl $169
c0102710:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102715:	e9 08 04 00 00       	jmp    c0102b22 <__alltraps>

c010271a <vector170>:
.globl vector170
vector170:
  pushl $0
c010271a:	6a 00                	push   $0x0
  pushl $170
c010271c:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102721:	e9 fc 03 00 00       	jmp    c0102b22 <__alltraps>

c0102726 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102726:	6a 00                	push   $0x0
  pushl $171
c0102728:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010272d:	e9 f0 03 00 00       	jmp    c0102b22 <__alltraps>

c0102732 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102732:	6a 00                	push   $0x0
  pushl $172
c0102734:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102739:	e9 e4 03 00 00       	jmp    c0102b22 <__alltraps>

c010273e <vector173>:
.globl vector173
vector173:
  pushl $0
c010273e:	6a 00                	push   $0x0
  pushl $173
c0102740:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102745:	e9 d8 03 00 00       	jmp    c0102b22 <__alltraps>

c010274a <vector174>:
.globl vector174
vector174:
  pushl $0
c010274a:	6a 00                	push   $0x0
  pushl $174
c010274c:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102751:	e9 cc 03 00 00       	jmp    c0102b22 <__alltraps>

c0102756 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102756:	6a 00                	push   $0x0
  pushl $175
c0102758:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010275d:	e9 c0 03 00 00       	jmp    c0102b22 <__alltraps>

c0102762 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102762:	6a 00                	push   $0x0
  pushl $176
c0102764:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102769:	e9 b4 03 00 00       	jmp    c0102b22 <__alltraps>

c010276e <vector177>:
.globl vector177
vector177:
  pushl $0
c010276e:	6a 00                	push   $0x0
  pushl $177
c0102770:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102775:	e9 a8 03 00 00       	jmp    c0102b22 <__alltraps>

c010277a <vector178>:
.globl vector178
vector178:
  pushl $0
c010277a:	6a 00                	push   $0x0
  pushl $178
c010277c:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102781:	e9 9c 03 00 00       	jmp    c0102b22 <__alltraps>

c0102786 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102786:	6a 00                	push   $0x0
  pushl $179
c0102788:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010278d:	e9 90 03 00 00       	jmp    c0102b22 <__alltraps>

c0102792 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102792:	6a 00                	push   $0x0
  pushl $180
c0102794:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102799:	e9 84 03 00 00       	jmp    c0102b22 <__alltraps>

c010279e <vector181>:
.globl vector181
vector181:
  pushl $0
c010279e:	6a 00                	push   $0x0
  pushl $181
c01027a0:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01027a5:	e9 78 03 00 00       	jmp    c0102b22 <__alltraps>

c01027aa <vector182>:
.globl vector182
vector182:
  pushl $0
c01027aa:	6a 00                	push   $0x0
  pushl $182
c01027ac:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01027b1:	e9 6c 03 00 00       	jmp    c0102b22 <__alltraps>

c01027b6 <vector183>:
.globl vector183
vector183:
  pushl $0
c01027b6:	6a 00                	push   $0x0
  pushl $183
c01027b8:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01027bd:	e9 60 03 00 00       	jmp    c0102b22 <__alltraps>

c01027c2 <vector184>:
.globl vector184
vector184:
  pushl $0
c01027c2:	6a 00                	push   $0x0
  pushl $184
c01027c4:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01027c9:	e9 54 03 00 00       	jmp    c0102b22 <__alltraps>

c01027ce <vector185>:
.globl vector185
vector185:
  pushl $0
c01027ce:	6a 00                	push   $0x0
  pushl $185
c01027d0:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01027d5:	e9 48 03 00 00       	jmp    c0102b22 <__alltraps>

c01027da <vector186>:
.globl vector186
vector186:
  pushl $0
c01027da:	6a 00                	push   $0x0
  pushl $186
c01027dc:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01027e1:	e9 3c 03 00 00       	jmp    c0102b22 <__alltraps>

c01027e6 <vector187>:
.globl vector187
vector187:
  pushl $0
c01027e6:	6a 00                	push   $0x0
  pushl $187
c01027e8:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01027ed:	e9 30 03 00 00       	jmp    c0102b22 <__alltraps>

c01027f2 <vector188>:
.globl vector188
vector188:
  pushl $0
c01027f2:	6a 00                	push   $0x0
  pushl $188
c01027f4:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01027f9:	e9 24 03 00 00       	jmp    c0102b22 <__alltraps>

c01027fe <vector189>:
.globl vector189
vector189:
  pushl $0
c01027fe:	6a 00                	push   $0x0
  pushl $189
c0102800:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102805:	e9 18 03 00 00       	jmp    c0102b22 <__alltraps>

c010280a <vector190>:
.globl vector190
vector190:
  pushl $0
c010280a:	6a 00                	push   $0x0
  pushl $190
c010280c:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102811:	e9 0c 03 00 00       	jmp    c0102b22 <__alltraps>

c0102816 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102816:	6a 00                	push   $0x0
  pushl $191
c0102818:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010281d:	e9 00 03 00 00       	jmp    c0102b22 <__alltraps>

c0102822 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102822:	6a 00                	push   $0x0
  pushl $192
c0102824:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102829:	e9 f4 02 00 00       	jmp    c0102b22 <__alltraps>

c010282e <vector193>:
.globl vector193
vector193:
  pushl $0
c010282e:	6a 00                	push   $0x0
  pushl $193
c0102830:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102835:	e9 e8 02 00 00       	jmp    c0102b22 <__alltraps>

c010283a <vector194>:
.globl vector194
vector194:
  pushl $0
c010283a:	6a 00                	push   $0x0
  pushl $194
c010283c:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102841:	e9 dc 02 00 00       	jmp    c0102b22 <__alltraps>

c0102846 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102846:	6a 00                	push   $0x0
  pushl $195
c0102848:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010284d:	e9 d0 02 00 00       	jmp    c0102b22 <__alltraps>

c0102852 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102852:	6a 00                	push   $0x0
  pushl $196
c0102854:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102859:	e9 c4 02 00 00       	jmp    c0102b22 <__alltraps>

c010285e <vector197>:
.globl vector197
vector197:
  pushl $0
c010285e:	6a 00                	push   $0x0
  pushl $197
c0102860:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102865:	e9 b8 02 00 00       	jmp    c0102b22 <__alltraps>

c010286a <vector198>:
.globl vector198
vector198:
  pushl $0
c010286a:	6a 00                	push   $0x0
  pushl $198
c010286c:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102871:	e9 ac 02 00 00       	jmp    c0102b22 <__alltraps>

c0102876 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102876:	6a 00                	push   $0x0
  pushl $199
c0102878:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010287d:	e9 a0 02 00 00       	jmp    c0102b22 <__alltraps>

c0102882 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102882:	6a 00                	push   $0x0
  pushl $200
c0102884:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102889:	e9 94 02 00 00       	jmp    c0102b22 <__alltraps>

c010288e <vector201>:
.globl vector201
vector201:
  pushl $0
c010288e:	6a 00                	push   $0x0
  pushl $201
c0102890:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102895:	e9 88 02 00 00       	jmp    c0102b22 <__alltraps>

c010289a <vector202>:
.globl vector202
vector202:
  pushl $0
c010289a:	6a 00                	push   $0x0
  pushl $202
c010289c:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01028a1:	e9 7c 02 00 00       	jmp    c0102b22 <__alltraps>

c01028a6 <vector203>:
.globl vector203
vector203:
  pushl $0
c01028a6:	6a 00                	push   $0x0
  pushl $203
c01028a8:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01028ad:	e9 70 02 00 00       	jmp    c0102b22 <__alltraps>

c01028b2 <vector204>:
.globl vector204
vector204:
  pushl $0
c01028b2:	6a 00                	push   $0x0
  pushl $204
c01028b4:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01028b9:	e9 64 02 00 00       	jmp    c0102b22 <__alltraps>

c01028be <vector205>:
.globl vector205
vector205:
  pushl $0
c01028be:	6a 00                	push   $0x0
  pushl $205
c01028c0:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01028c5:	e9 58 02 00 00       	jmp    c0102b22 <__alltraps>

c01028ca <vector206>:
.globl vector206
vector206:
  pushl $0
c01028ca:	6a 00                	push   $0x0
  pushl $206
c01028cc:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01028d1:	e9 4c 02 00 00       	jmp    c0102b22 <__alltraps>

c01028d6 <vector207>:
.globl vector207
vector207:
  pushl $0
c01028d6:	6a 00                	push   $0x0
  pushl $207
c01028d8:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01028dd:	e9 40 02 00 00       	jmp    c0102b22 <__alltraps>

c01028e2 <vector208>:
.globl vector208
vector208:
  pushl $0
c01028e2:	6a 00                	push   $0x0
  pushl $208
c01028e4:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01028e9:	e9 34 02 00 00       	jmp    c0102b22 <__alltraps>

c01028ee <vector209>:
.globl vector209
vector209:
  pushl $0
c01028ee:	6a 00                	push   $0x0
  pushl $209
c01028f0:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01028f5:	e9 28 02 00 00       	jmp    c0102b22 <__alltraps>

c01028fa <vector210>:
.globl vector210
vector210:
  pushl $0
c01028fa:	6a 00                	push   $0x0
  pushl $210
c01028fc:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102901:	e9 1c 02 00 00       	jmp    c0102b22 <__alltraps>

c0102906 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102906:	6a 00                	push   $0x0
  pushl $211
c0102908:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010290d:	e9 10 02 00 00       	jmp    c0102b22 <__alltraps>

c0102912 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102912:	6a 00                	push   $0x0
  pushl $212
c0102914:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102919:	e9 04 02 00 00       	jmp    c0102b22 <__alltraps>

c010291e <vector213>:
.globl vector213
vector213:
  pushl $0
c010291e:	6a 00                	push   $0x0
  pushl $213
c0102920:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102925:	e9 f8 01 00 00       	jmp    c0102b22 <__alltraps>

c010292a <vector214>:
.globl vector214
vector214:
  pushl $0
c010292a:	6a 00                	push   $0x0
  pushl $214
c010292c:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102931:	e9 ec 01 00 00       	jmp    c0102b22 <__alltraps>

c0102936 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102936:	6a 00                	push   $0x0
  pushl $215
c0102938:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010293d:	e9 e0 01 00 00       	jmp    c0102b22 <__alltraps>

c0102942 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102942:	6a 00                	push   $0x0
  pushl $216
c0102944:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102949:	e9 d4 01 00 00       	jmp    c0102b22 <__alltraps>

c010294e <vector217>:
.globl vector217
vector217:
  pushl $0
c010294e:	6a 00                	push   $0x0
  pushl $217
c0102950:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102955:	e9 c8 01 00 00       	jmp    c0102b22 <__alltraps>

c010295a <vector218>:
.globl vector218
vector218:
  pushl $0
c010295a:	6a 00                	push   $0x0
  pushl $218
c010295c:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102961:	e9 bc 01 00 00       	jmp    c0102b22 <__alltraps>

c0102966 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102966:	6a 00                	push   $0x0
  pushl $219
c0102968:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010296d:	e9 b0 01 00 00       	jmp    c0102b22 <__alltraps>

c0102972 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102972:	6a 00                	push   $0x0
  pushl $220
c0102974:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102979:	e9 a4 01 00 00       	jmp    c0102b22 <__alltraps>

c010297e <vector221>:
.globl vector221
vector221:
  pushl $0
c010297e:	6a 00                	push   $0x0
  pushl $221
c0102980:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102985:	e9 98 01 00 00       	jmp    c0102b22 <__alltraps>

c010298a <vector222>:
.globl vector222
vector222:
  pushl $0
c010298a:	6a 00                	push   $0x0
  pushl $222
c010298c:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102991:	e9 8c 01 00 00       	jmp    c0102b22 <__alltraps>

c0102996 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102996:	6a 00                	push   $0x0
  pushl $223
c0102998:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010299d:	e9 80 01 00 00       	jmp    c0102b22 <__alltraps>

c01029a2 <vector224>:
.globl vector224
vector224:
  pushl $0
c01029a2:	6a 00                	push   $0x0
  pushl $224
c01029a4:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01029a9:	e9 74 01 00 00       	jmp    c0102b22 <__alltraps>

c01029ae <vector225>:
.globl vector225
vector225:
  pushl $0
c01029ae:	6a 00                	push   $0x0
  pushl $225
c01029b0:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01029b5:	e9 68 01 00 00       	jmp    c0102b22 <__alltraps>

c01029ba <vector226>:
.globl vector226
vector226:
  pushl $0
c01029ba:	6a 00                	push   $0x0
  pushl $226
c01029bc:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01029c1:	e9 5c 01 00 00       	jmp    c0102b22 <__alltraps>

c01029c6 <vector227>:
.globl vector227
vector227:
  pushl $0
c01029c6:	6a 00                	push   $0x0
  pushl $227
c01029c8:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01029cd:	e9 50 01 00 00       	jmp    c0102b22 <__alltraps>

c01029d2 <vector228>:
.globl vector228
vector228:
  pushl $0
c01029d2:	6a 00                	push   $0x0
  pushl $228
c01029d4:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01029d9:	e9 44 01 00 00       	jmp    c0102b22 <__alltraps>

c01029de <vector229>:
.globl vector229
vector229:
  pushl $0
c01029de:	6a 00                	push   $0x0
  pushl $229
c01029e0:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01029e5:	e9 38 01 00 00       	jmp    c0102b22 <__alltraps>

c01029ea <vector230>:
.globl vector230
vector230:
  pushl $0
c01029ea:	6a 00                	push   $0x0
  pushl $230
c01029ec:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01029f1:	e9 2c 01 00 00       	jmp    c0102b22 <__alltraps>

c01029f6 <vector231>:
.globl vector231
vector231:
  pushl $0
c01029f6:	6a 00                	push   $0x0
  pushl $231
c01029f8:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01029fd:	e9 20 01 00 00       	jmp    c0102b22 <__alltraps>

c0102a02 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102a02:	6a 00                	push   $0x0
  pushl $232
c0102a04:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102a09:	e9 14 01 00 00       	jmp    c0102b22 <__alltraps>

c0102a0e <vector233>:
.globl vector233
vector233:
  pushl $0
c0102a0e:	6a 00                	push   $0x0
  pushl $233
c0102a10:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102a15:	e9 08 01 00 00       	jmp    c0102b22 <__alltraps>

c0102a1a <vector234>:
.globl vector234
vector234:
  pushl $0
c0102a1a:	6a 00                	push   $0x0
  pushl $234
c0102a1c:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102a21:	e9 fc 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a26 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102a26:	6a 00                	push   $0x0
  pushl $235
c0102a28:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102a2d:	e9 f0 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a32 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102a32:	6a 00                	push   $0x0
  pushl $236
c0102a34:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102a39:	e9 e4 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a3e <vector237>:
.globl vector237
vector237:
  pushl $0
c0102a3e:	6a 00                	push   $0x0
  pushl $237
c0102a40:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102a45:	e9 d8 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a4a <vector238>:
.globl vector238
vector238:
  pushl $0
c0102a4a:	6a 00                	push   $0x0
  pushl $238
c0102a4c:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102a51:	e9 cc 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a56 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102a56:	6a 00                	push   $0x0
  pushl $239
c0102a58:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102a5d:	e9 c0 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a62 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102a62:	6a 00                	push   $0x0
  pushl $240
c0102a64:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102a69:	e9 b4 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a6e <vector241>:
.globl vector241
vector241:
  pushl $0
c0102a6e:	6a 00                	push   $0x0
  pushl $241
c0102a70:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102a75:	e9 a8 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a7a <vector242>:
.globl vector242
vector242:
  pushl $0
c0102a7a:	6a 00                	push   $0x0
  pushl $242
c0102a7c:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102a81:	e9 9c 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a86 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102a86:	6a 00                	push   $0x0
  pushl $243
c0102a88:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102a8d:	e9 90 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a92 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102a92:	6a 00                	push   $0x0
  pushl $244
c0102a94:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102a99:	e9 84 00 00 00       	jmp    c0102b22 <__alltraps>

c0102a9e <vector245>:
.globl vector245
vector245:
  pushl $0
c0102a9e:	6a 00                	push   $0x0
  pushl $245
c0102aa0:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102aa5:	e9 78 00 00 00       	jmp    c0102b22 <__alltraps>

c0102aaa <vector246>:
.globl vector246
vector246:
  pushl $0
c0102aaa:	6a 00                	push   $0x0
  pushl $246
c0102aac:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102ab1:	e9 6c 00 00 00       	jmp    c0102b22 <__alltraps>

c0102ab6 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102ab6:	6a 00                	push   $0x0
  pushl $247
c0102ab8:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102abd:	e9 60 00 00 00       	jmp    c0102b22 <__alltraps>

c0102ac2 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102ac2:	6a 00                	push   $0x0
  pushl $248
c0102ac4:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102ac9:	e9 54 00 00 00       	jmp    c0102b22 <__alltraps>

c0102ace <vector249>:
.globl vector249
vector249:
  pushl $0
c0102ace:	6a 00                	push   $0x0
  pushl $249
c0102ad0:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102ad5:	e9 48 00 00 00       	jmp    c0102b22 <__alltraps>

c0102ada <vector250>:
.globl vector250
vector250:
  pushl $0
c0102ada:	6a 00                	push   $0x0
  pushl $250
c0102adc:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102ae1:	e9 3c 00 00 00       	jmp    c0102b22 <__alltraps>

c0102ae6 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102ae6:	6a 00                	push   $0x0
  pushl $251
c0102ae8:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102aed:	e9 30 00 00 00       	jmp    c0102b22 <__alltraps>

c0102af2 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102af2:	6a 00                	push   $0x0
  pushl $252
c0102af4:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102af9:	e9 24 00 00 00       	jmp    c0102b22 <__alltraps>

c0102afe <vector253>:
.globl vector253
vector253:
  pushl $0
c0102afe:	6a 00                	push   $0x0
  pushl $253
c0102b00:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102b05:	e9 18 00 00 00       	jmp    c0102b22 <__alltraps>

c0102b0a <vector254>:
.globl vector254
vector254:
  pushl $0
c0102b0a:	6a 00                	push   $0x0
  pushl $254
c0102b0c:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102b11:	e9 0c 00 00 00       	jmp    c0102b22 <__alltraps>

c0102b16 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102b16:	6a 00                	push   $0x0
  pushl $255
c0102b18:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102b1d:	e9 00 00 00 00       	jmp    c0102b22 <__alltraps>

c0102b22 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102b22:	1e                   	push   %ds
    pushl %es
c0102b23:	06                   	push   %es
    pushl %fs
c0102b24:	0f a0                	push   %fs
    pushl %gs
c0102b26:	0f a8                	push   %gs
    pushal
c0102b28:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102b29:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102b2e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102b30:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102b32:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102b33:	e8 60 f5 ff ff       	call   c0102098 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102b38:	5c                   	pop    %esp

c0102b39 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102b39:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102b3a:	0f a9                	pop    %gs
    popl %fs
c0102b3c:	0f a1                	pop    %fs
    popl %es
c0102b3e:	07                   	pop    %es
    popl %ds
c0102b3f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102b40:	83 c4 08             	add    $0x8,%esp
    iret
c0102b43:	cf                   	iret   

c0102b44 <page2ppn>:
extern struct Page *pages;
extern size_t npage;

// PPN Physical Page Number 物理地址页号 
static inline ppn_t 
page2ppn(struct Page *page) { 
c0102b44:	55                   	push   %ebp
c0102b45:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102b47:	a1 78 df 11 c0       	mov    0xc011df78,%eax
c0102b4c:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b4f:	29 c2                	sub    %eax,%edx
c0102b51:	89 d0                	mov    %edx,%eax
c0102b53:	c1 f8 02             	sar    $0x2,%eax
c0102b56:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102b5c:	5d                   	pop    %ebp
c0102b5d:	c3                   	ret    

c0102b5e <page2pa>:

// PA Physial Address 物理地址
static inline uintptr_t
page2pa(struct Page *page) {
c0102b5e:	55                   	push   %ebp
c0102b5f:	89 e5                	mov    %esp,%ebp
c0102b61:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b67:	89 04 24             	mov    %eax,(%esp)
c0102b6a:	e8 d5 ff ff ff       	call   c0102b44 <page2ppn>
c0102b6f:	c1 e0 0c             	shl    $0xc,%eax
}
c0102b72:	c9                   	leave  
c0102b73:	c3                   	ret    

c0102b74 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102b74:	55                   	push   %ebp
c0102b75:	89 e5                	mov    %esp,%ebp
c0102b77:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102b7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7d:	c1 e8 0c             	shr    $0xc,%eax
c0102b80:	89 c2                	mov    %eax,%edx
c0102b82:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102b87:	39 c2                	cmp    %eax,%edx
c0102b89:	72 1c                	jb     c0102ba7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102b8b:	c7 44 24 08 70 6b 10 	movl   $0xc0106b70,0x8(%esp)
c0102b92:	c0 
c0102b93:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0102b9a:	00 
c0102b9b:	c7 04 24 8f 6b 10 c0 	movl   $0xc0106b8f,(%esp)
c0102ba2:	e8 8f d8 ff ff       	call   c0100436 <__panic>
    }
    return &pages[PPN(pa)];
c0102ba7:	8b 0d 78 df 11 c0    	mov    0xc011df78,%ecx
c0102bad:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bb0:	c1 e8 0c             	shr    $0xc,%eax
c0102bb3:	89 c2                	mov    %eax,%edx
c0102bb5:	89 d0                	mov    %edx,%eax
c0102bb7:	c1 e0 02             	shl    $0x2,%eax
c0102bba:	01 d0                	add    %edx,%eax
c0102bbc:	c1 e0 02             	shl    $0x2,%eax
c0102bbf:	01 c8                	add    %ecx,%eax
}
c0102bc1:	c9                   	leave  
c0102bc2:	c3                   	ret    

c0102bc3 <page2kva>:

// KVA Kernel Virtual Address 内核虚拟地址
static inline void *
page2kva(struct Page *page) { 
c0102bc3:	55                   	push   %ebp
c0102bc4:	89 e5                	mov    %esp,%ebp
c0102bc6:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bcc:	89 04 24             	mov    %eax,(%esp)
c0102bcf:	e8 8a ff ff ff       	call   c0102b5e <page2pa>
c0102bd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bda:	c1 e8 0c             	shr    $0xc,%eax
c0102bdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102be0:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0102be5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102be8:	72 23                	jb     c0102c0d <page2kva+0x4a>
c0102bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102bf1:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c0102bf8:	c0 
c0102bf9:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0102c00:	00 
c0102c01:	c7 04 24 8f 6b 10 c0 	movl   $0xc0106b8f,(%esp)
c0102c08:	e8 29 d8 ff ff       	call   c0100436 <__panic>
c0102c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c10:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102c15:	c9                   	leave  
c0102c16:	c3                   	ret    

c0102c17 <pte2page>:
    return pa2page(PADDR(kva));
}

// PTE Page Table Entry 页表
static inline struct Page *
pte2page(pte_t pte) {
c0102c17:	55                   	push   %ebp
c0102c18:	89 e5                	mov    %esp,%ebp
c0102c1a:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c20:	83 e0 01             	and    $0x1,%eax
c0102c23:	85 c0                	test   %eax,%eax
c0102c25:	75 1c                	jne    c0102c43 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102c27:	c7 44 24 08 c4 6b 10 	movl   $0xc0106bc4,0x8(%esp)
c0102c2e:	c0 
c0102c2f:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0102c36:	00 
c0102c37:	c7 04 24 8f 6b 10 c0 	movl   $0xc0106b8f,(%esp)
c0102c3e:	e8 f3 d7 ff ff       	call   c0100436 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102c43:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102c4b:	89 04 24             	mov    %eax,(%esp)
c0102c4e:	e8 21 ff ff ff       	call   c0102b74 <pa2page>
}
c0102c53:	c9                   	leave  
c0102c54:	c3                   	ret    

c0102c55 <pde2page>:

// PDE Page Directory Entry 页目录表
static inline struct Page *
pde2page(pde_t pde) {
c0102c55:	55                   	push   %ebp
c0102c56:	89 e5                	mov    %esp,%ebp
c0102c58:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102c63:	89 04 24             	mov    %eax,(%esp)
c0102c66:	e8 09 ff ff ff       	call   c0102b74 <pa2page>
}
c0102c6b:	c9                   	leave  
c0102c6c:	c3                   	ret    

c0102c6d <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102c6d:	55                   	push   %ebp
c0102c6e:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c73:	8b 00                	mov    (%eax),%eax
}
c0102c75:	5d                   	pop    %ebp
c0102c76:	c3                   	ret    

c0102c77 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102c77:	55                   	push   %ebp
c0102c78:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c80:	89 10                	mov    %edx,(%eax)
}
c0102c82:	90                   	nop
c0102c83:	5d                   	pop    %ebp
c0102c84:	c3                   	ret    

c0102c85 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102c85:	55                   	push   %ebp
c0102c86:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c8b:	8b 00                	mov    (%eax),%eax
c0102c8d:	8d 50 01             	lea    0x1(%eax),%edx
c0102c90:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c93:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c98:	8b 00                	mov    (%eax),%eax
}
c0102c9a:	5d                   	pop    %ebp
c0102c9b:	c3                   	ret    

c0102c9c <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102c9c:	55                   	push   %ebp
c0102c9d:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102c9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca2:	8b 00                	mov    (%eax),%eax
c0102ca4:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102caa:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102cac:	8b 45 08             	mov    0x8(%ebp),%eax
c0102caf:	8b 00                	mov    (%eax),%eax
}
c0102cb1:	5d                   	pop    %ebp
c0102cb2:	c3                   	ret    

c0102cb3 <__intr_save>:
__intr_save(void) {
c0102cb3:	55                   	push   %ebp
c0102cb4:	89 e5                	mov    %esp,%ebp
c0102cb6:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102cb9:	9c                   	pushf  
c0102cba:	58                   	pop    %eax
c0102cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102cc1:	25 00 02 00 00       	and    $0x200,%eax
c0102cc6:	85 c0                	test   %eax,%eax
c0102cc8:	74 0c                	je     c0102cd6 <__intr_save+0x23>
        intr_disable();
c0102cca:	e8 bf ec ff ff       	call   c010198e <intr_disable>
        return 1;
c0102ccf:	b8 01 00 00 00       	mov    $0x1,%eax
c0102cd4:	eb 05                	jmp    c0102cdb <__intr_save+0x28>
    return 0;
c0102cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102cdb:	c9                   	leave  
c0102cdc:	c3                   	ret    

c0102cdd <__intr_restore>:
__intr_restore(bool flag) {
c0102cdd:	55                   	push   %ebp
c0102cde:	89 e5                	mov    %esp,%ebp
c0102ce0:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102ce3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102ce7:	74 05                	je     c0102cee <__intr_restore+0x11>
        intr_enable();
c0102ce9:	e8 94 ec ff ff       	call   c0101982 <intr_enable>
}
c0102cee:	90                   	nop
c0102cef:	c9                   	leave  
c0102cf0:	c3                   	ret    

c0102cf1 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102cf1:	55                   	push   %ebp
c0102cf2:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102cf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cf7:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102cfa:	b8 23 00 00 00       	mov    $0x23,%eax
c0102cff:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102d01:	b8 23 00 00 00       	mov    $0x23,%eax
c0102d06:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102d08:	b8 10 00 00 00       	mov    $0x10,%eax
c0102d0d:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102d0f:	b8 10 00 00 00       	mov    $0x10,%eax
c0102d14:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102d16:	b8 10 00 00 00       	mov    $0x10,%eax
c0102d1b:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102d1d:	ea 24 2d 10 c0 08 00 	ljmp   $0x8,$0xc0102d24
}
c0102d24:	90                   	nop
c0102d25:	5d                   	pop    %ebp
c0102d26:	c3                   	ret    

c0102d27 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102d27:	f3 0f 1e fb          	endbr32 
c0102d2b:	55                   	push   %ebp
c0102d2c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d31:	a3 a4 de 11 c0       	mov    %eax,0xc011dea4
}
c0102d36:	90                   	nop
c0102d37:	5d                   	pop    %ebp
c0102d38:	c3                   	ret    

c0102d39 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102d39:	f3 0f 1e fb          	endbr32 
c0102d3d:	55                   	push   %ebp
c0102d3e:	89 e5                	mov    %esp,%ebp
c0102d40:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102d43:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0102d48:	89 04 24             	mov    %eax,(%esp)
c0102d4b:	e8 d7 ff ff ff       	call   c0102d27 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102d50:	66 c7 05 a8 de 11 c0 	movw   $0x10,0xc011dea8
c0102d57:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102d59:	66 c7 05 28 aa 11 c0 	movw   $0x68,0xc011aa28
c0102d60:	68 00 
c0102d62:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102d67:	0f b7 c0             	movzwl %ax,%eax
c0102d6a:	66 a3 2a aa 11 c0    	mov    %ax,0xc011aa2a
c0102d70:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102d75:	c1 e8 10             	shr    $0x10,%eax
c0102d78:	a2 2c aa 11 c0       	mov    %al,0xc011aa2c
c0102d7d:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102d84:	24 f0                	and    $0xf0,%al
c0102d86:	0c 09                	or     $0x9,%al
c0102d88:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102d8d:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102d94:	24 ef                	and    $0xef,%al
c0102d96:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102d9b:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102da2:	24 9f                	and    $0x9f,%al
c0102da4:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102da9:	0f b6 05 2d aa 11 c0 	movzbl 0xc011aa2d,%eax
c0102db0:	0c 80                	or     $0x80,%al
c0102db2:	a2 2d aa 11 c0       	mov    %al,0xc011aa2d
c0102db7:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102dbe:	24 f0                	and    $0xf0,%al
c0102dc0:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102dc5:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102dcc:	24 ef                	and    $0xef,%al
c0102dce:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102dd3:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102dda:	24 df                	and    $0xdf,%al
c0102ddc:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102de1:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102de8:	0c 40                	or     $0x40,%al
c0102dea:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102def:	0f b6 05 2e aa 11 c0 	movzbl 0xc011aa2e,%eax
c0102df6:	24 7f                	and    $0x7f,%al
c0102df8:	a2 2e aa 11 c0       	mov    %al,0xc011aa2e
c0102dfd:	b8 a0 de 11 c0       	mov    $0xc011dea0,%eax
c0102e02:	c1 e8 18             	shr    $0x18,%eax
c0102e05:	a2 2f aa 11 c0       	mov    %al,0xc011aa2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102e0a:	c7 04 24 30 aa 11 c0 	movl   $0xc011aa30,(%esp)
c0102e11:	e8 db fe ff ff       	call   c0102cf1 <lgdt>
c0102e16:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102e1c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102e20:	0f 00 d8             	ltr    %ax
}
c0102e23:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0102e24:	90                   	nop
c0102e25:	c9                   	leave  
c0102e26:	c3                   	ret    

c0102e27 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102e27:	f3 0f 1e fb          	endbr32 
c0102e2b:	55                   	push   %ebp
c0102e2c:	89 e5                	mov    %esp,%ebp
c0102e2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102e31:	c7 05 70 df 11 c0 5c 	movl   $0xc010755c,0xc011df70
c0102e38:	75 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102e3b:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102e40:	8b 00                	mov    (%eax),%eax
c0102e42:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102e46:	c7 04 24 f0 6b 10 c0 	movl   $0xc0106bf0,(%esp)
c0102e4d:	e8 78 d4 ff ff       	call   c01002ca <cprintf>
    pmm_manager->init();
c0102e52:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102e57:	8b 40 04             	mov    0x4(%eax),%eax
c0102e5a:	ff d0                	call   *%eax
}
c0102e5c:	90                   	nop
c0102e5d:	c9                   	leave  
c0102e5e:	c3                   	ret    

c0102e5f <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102e5f:	f3 0f 1e fb          	endbr32 
c0102e63:	55                   	push   %ebp
c0102e64:	89 e5                	mov    %esp,%ebp
c0102e66:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102e69:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102e6e:	8b 40 08             	mov    0x8(%eax),%eax
c0102e71:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e74:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102e78:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e7b:	89 14 24             	mov    %edx,(%esp)
c0102e7e:	ff d0                	call   *%eax
}
c0102e80:	90                   	nop
c0102e81:	c9                   	leave  
c0102e82:	c3                   	ret    

c0102e83 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102e83:	f3 0f 1e fb          	endbr32 
c0102e87:	55                   	push   %ebp
c0102e88:	89 e5                	mov    %esp,%ebp
c0102e8a:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102e8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102e94:	e8 1a fe ff ff       	call   c0102cb3 <__intr_save>
c0102e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102e9c:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102ea1:	8b 40 0c             	mov    0xc(%eax),%eax
c0102ea4:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ea7:	89 14 24             	mov    %edx,(%esp)
c0102eaa:	ff d0                	call   *%eax
c0102eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102eaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eb2:	89 04 24             	mov    %eax,(%esp)
c0102eb5:	e8 23 fe ff ff       	call   c0102cdd <__intr_restore>
    return page;
c0102eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102ebd:	c9                   	leave  
c0102ebe:	c3                   	ret    

c0102ebf <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102ebf:	f3 0f 1e fb          	endbr32 
c0102ec3:	55                   	push   %ebp
c0102ec4:	89 e5                	mov    %esp,%ebp
c0102ec6:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102ec9:	e8 e5 fd ff ff       	call   c0102cb3 <__intr_save>
c0102ece:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102ed1:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102ed6:	8b 40 10             	mov    0x10(%eax),%eax
c0102ed9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102edc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102ee0:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ee3:	89 14 24             	mov    %edx,(%esp)
c0102ee6:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eeb:	89 04 24             	mov    %eax,(%esp)
c0102eee:	e8 ea fd ff ff       	call   c0102cdd <__intr_restore>
}
c0102ef3:	90                   	nop
c0102ef4:	c9                   	leave  
c0102ef5:	c3                   	ret    

c0102ef6 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102ef6:	f3 0f 1e fb          	endbr32 
c0102efa:	55                   	push   %ebp
c0102efb:	89 e5                	mov    %esp,%ebp
c0102efd:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102f00:	e8 ae fd ff ff       	call   c0102cb3 <__intr_save>
c0102f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102f08:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0102f0d:	8b 40 14             	mov    0x14(%eax),%eax
c0102f10:	ff d0                	call   *%eax
c0102f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f18:	89 04 24             	mov    %eax,(%esp)
c0102f1b:	e8 bd fd ff ff       	call   c0102cdd <__intr_restore>
    return ret;
c0102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102f23:	c9                   	leave  
c0102f24:	c3                   	ret    

c0102f25 <page_init>:


/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102f25:	f3 0f 1e fb          	endbr32 
c0102f29:	55                   	push   %ebp
c0102f2a:	89 e5                	mov    %esp,%ebp
c0102f2c:	57                   	push   %edi
c0102f2d:	56                   	push   %esi
c0102f2e:	53                   	push   %ebx
c0102f2f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102f35:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102f3c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102f43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102f4a:	c7 04 24 07 6c 10 c0 	movl   $0xc0106c07,(%esp)
c0102f51:	e8 74 d3 ff ff       	call   c01002ca <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102f56:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102f5d:	e9 1a 01 00 00       	jmp    c010307c <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102f62:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f65:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f68:	89 d0                	mov    %edx,%eax
c0102f6a:	c1 e0 02             	shl    $0x2,%eax
c0102f6d:	01 d0                	add    %edx,%eax
c0102f6f:	c1 e0 02             	shl    $0x2,%eax
c0102f72:	01 c8                	add    %ecx,%eax
c0102f74:	8b 50 08             	mov    0x8(%eax),%edx
c0102f77:	8b 40 04             	mov    0x4(%eax),%eax
c0102f7a:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102f7d:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102f80:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f83:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f86:	89 d0                	mov    %edx,%eax
c0102f88:	c1 e0 02             	shl    $0x2,%eax
c0102f8b:	01 d0                	add    %edx,%eax
c0102f8d:	c1 e0 02             	shl    $0x2,%eax
c0102f90:	01 c8                	add    %ecx,%eax
c0102f92:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f95:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f98:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f9b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102f9e:	01 c8                	add    %ecx,%eax
c0102fa0:	11 da                	adc    %ebx,%edx
c0102fa2:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102fa5:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102fa8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102fab:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fae:	89 d0                	mov    %edx,%eax
c0102fb0:	c1 e0 02             	shl    $0x2,%eax
c0102fb3:	01 d0                	add    %edx,%eax
c0102fb5:	c1 e0 02             	shl    $0x2,%eax
c0102fb8:	01 c8                	add    %ecx,%eax
c0102fba:	83 c0 14             	add    $0x14,%eax
c0102fbd:	8b 00                	mov    (%eax),%eax
c0102fbf:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102fc2:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fc5:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102fc8:	83 c0 ff             	add    $0xffffffff,%eax
c0102fcb:	83 d2 ff             	adc    $0xffffffff,%edx
c0102fce:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102fd4:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102fda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102fdd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102fe0:	89 d0                	mov    %edx,%eax
c0102fe2:	c1 e0 02             	shl    $0x2,%eax
c0102fe5:	01 d0                	add    %edx,%eax
c0102fe7:	c1 e0 02             	shl    $0x2,%eax
c0102fea:	01 c8                	add    %ecx,%eax
c0102fec:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102fef:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ff2:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102ff5:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102ff9:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102fff:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0103005:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103009:	89 54 24 18          	mov    %edx,0x18(%esp)
c010300d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103010:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103013:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103017:	89 54 24 10          	mov    %edx,0x10(%esp)
c010301b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010301f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103023:	c7 04 24 14 6c 10 c0 	movl   $0xc0106c14,(%esp)
c010302a:	e8 9b d2 ff ff       	call   c01002ca <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010302f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103032:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103035:	89 d0                	mov    %edx,%eax
c0103037:	c1 e0 02             	shl    $0x2,%eax
c010303a:	01 d0                	add    %edx,%eax
c010303c:	c1 e0 02             	shl    $0x2,%eax
c010303f:	01 c8                	add    %ecx,%eax
c0103041:	83 c0 14             	add    $0x14,%eax
c0103044:	8b 00                	mov    (%eax),%eax
c0103046:	83 f8 01             	cmp    $0x1,%eax
c0103049:	75 2e                	jne    c0103079 <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
c010304b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010304e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103051:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0103054:	89 d0                	mov    %edx,%eax
c0103056:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0103059:	73 1e                	jae    c0103079 <page_init+0x154>
c010305b:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0103060:	b8 00 00 00 00       	mov    $0x0,%eax
c0103065:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0103068:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010306b:	72 0c                	jb     c0103079 <page_init+0x154>
                maxpa = end;
c010306d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103070:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0103073:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103076:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0103079:	ff 45 dc             	incl   -0x24(%ebp)
c010307c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010307f:	8b 00                	mov    (%eax),%eax
c0103081:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103084:	0f 8c d8 fe ff ff    	jl     c0102f62 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010308a:	ba 00 00 00 38       	mov    $0x38000000,%edx
c010308f:	b8 00 00 00 00       	mov    $0x0,%eax
c0103094:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0103097:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c010309a:	73 0e                	jae    c01030aa <page_init+0x185>
        maxpa = KMEMSIZE;
c010309c:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01030a3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01030aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01030b0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01030b4:	c1 ea 0c             	shr    $0xc,%edx
c01030b7:	a3 80 de 11 c0       	mov    %eax,0xc011de80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01030bc:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c01030c3:	b8 88 df 11 c0       	mov    $0xc011df88,%eax
c01030c8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01030cb:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01030ce:	01 d0                	add    %edx,%eax
c01030d0:	89 45 bc             	mov    %eax,-0x44(%ebp)
c01030d3:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01030d6:	ba 00 00 00 00       	mov    $0x0,%edx
c01030db:	f7 75 c0             	divl   -0x40(%ebp)
c01030de:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01030e1:	29 d0                	sub    %edx,%eax
c01030e3:	a3 78 df 11 c0       	mov    %eax,0xc011df78

    for (i = 0; i < npage; i ++) {
c01030e8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01030ef:	eb 2f                	jmp    c0103120 <page_init+0x1fb>
        SetPageReserved(pages + i);
c01030f1:	8b 0d 78 df 11 c0    	mov    0xc011df78,%ecx
c01030f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030fa:	89 d0                	mov    %edx,%eax
c01030fc:	c1 e0 02             	shl    $0x2,%eax
c01030ff:	01 d0                	add    %edx,%eax
c0103101:	c1 e0 02             	shl    $0x2,%eax
c0103104:	01 c8                	add    %ecx,%eax
c0103106:	83 c0 04             	add    $0x4,%eax
c0103109:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0103110:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103113:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103116:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103119:	0f ab 10             	bts    %edx,(%eax)
}
c010311c:	90                   	nop
    for (i = 0; i < npage; i ++) {
c010311d:	ff 45 dc             	incl   -0x24(%ebp)
c0103120:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103123:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103128:	39 c2                	cmp    %eax,%edx
c010312a:	72 c5                	jb     c01030f1 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010312c:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0103132:	89 d0                	mov    %edx,%eax
c0103134:	c1 e0 02             	shl    $0x2,%eax
c0103137:	01 d0                	add    %edx,%eax
c0103139:	c1 e0 02             	shl    $0x2,%eax
c010313c:	89 c2                	mov    %eax,%edx
c010313e:	a1 78 df 11 c0       	mov    0xc011df78,%eax
c0103143:	01 d0                	add    %edx,%eax
c0103145:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103148:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010314f:	77 23                	ja     c0103174 <page_init+0x24f>
c0103151:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103154:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103158:	c7 44 24 08 44 6c 10 	movl   $0xc0106c44,0x8(%esp)
c010315f:	c0 
c0103160:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0103167:	00 
c0103168:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c010316f:	e8 c2 d2 ff ff       	call   c0100436 <__panic>
c0103174:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103177:	05 00 00 00 40       	add    $0x40000000,%eax
c010317c:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010317f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103186:	e9 4b 01 00 00       	jmp    c01032d6 <page_init+0x3b1>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010318b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010318e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103191:	89 d0                	mov    %edx,%eax
c0103193:	c1 e0 02             	shl    $0x2,%eax
c0103196:	01 d0                	add    %edx,%eax
c0103198:	c1 e0 02             	shl    $0x2,%eax
c010319b:	01 c8                	add    %ecx,%eax
c010319d:	8b 50 08             	mov    0x8(%eax),%edx
c01031a0:	8b 40 04             	mov    0x4(%eax),%eax
c01031a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01031a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01031a9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031af:	89 d0                	mov    %edx,%eax
c01031b1:	c1 e0 02             	shl    $0x2,%eax
c01031b4:	01 d0                	add    %edx,%eax
c01031b6:	c1 e0 02             	shl    $0x2,%eax
c01031b9:	01 c8                	add    %ecx,%eax
c01031bb:	8b 48 0c             	mov    0xc(%eax),%ecx
c01031be:	8b 58 10             	mov    0x10(%eax),%ebx
c01031c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01031c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01031c7:	01 c8                	add    %ecx,%eax
c01031c9:	11 da                	adc    %ebx,%edx
c01031cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01031ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01031d1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031d7:	89 d0                	mov    %edx,%eax
c01031d9:	c1 e0 02             	shl    $0x2,%eax
c01031dc:	01 d0                	add    %edx,%eax
c01031de:	c1 e0 02             	shl    $0x2,%eax
c01031e1:	01 c8                	add    %ecx,%eax
c01031e3:	83 c0 14             	add    $0x14,%eax
c01031e6:	8b 00                	mov    (%eax),%eax
c01031e8:	83 f8 01             	cmp    $0x1,%eax
c01031eb:	0f 85 e2 00 00 00    	jne    c01032d3 <page_init+0x3ae>
            if (begin < freemem) {
c01031f1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01031f4:	ba 00 00 00 00       	mov    $0x0,%edx
c01031f9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01031fc:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01031ff:	19 d1                	sbb    %edx,%ecx
c0103201:	73 0d                	jae    c0103210 <page_init+0x2eb>
                begin = freemem;
c0103203:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103206:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103209:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103210:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0103215:	b8 00 00 00 00       	mov    $0x0,%eax
c010321a:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c010321d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103220:	73 0e                	jae    c0103230 <page_init+0x30b>
                end = KMEMSIZE;
c0103222:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103229:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103230:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103233:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103236:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103239:	89 d0                	mov    %edx,%eax
c010323b:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c010323e:	0f 83 8f 00 00 00    	jae    c01032d3 <page_init+0x3ae>
                begin = ROUNDUP(begin, PGSIZE);
c0103244:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010324b:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010324e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103251:	01 d0                	add    %edx,%eax
c0103253:	48                   	dec    %eax
c0103254:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0103257:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010325a:	ba 00 00 00 00       	mov    $0x0,%edx
c010325f:	f7 75 b0             	divl   -0x50(%ebp)
c0103262:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103265:	29 d0                	sub    %edx,%eax
c0103267:	ba 00 00 00 00       	mov    $0x0,%edx
c010326c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010326f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103272:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103275:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103278:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010327b:	ba 00 00 00 00       	mov    $0x0,%edx
c0103280:	89 c3                	mov    %eax,%ebx
c0103282:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103288:	89 de                	mov    %ebx,%esi
c010328a:	89 d0                	mov    %edx,%eax
c010328c:	83 e0 00             	and    $0x0,%eax
c010328f:	89 c7                	mov    %eax,%edi
c0103291:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103294:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103297:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010329a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010329d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01032a0:	89 d0                	mov    %edx,%eax
c01032a2:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01032a5:	73 2c                	jae    c01032d3 <page_init+0x3ae>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01032a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01032aa:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01032ad:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01032b0:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01032b3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01032b7:	c1 ea 0c             	shr    $0xc,%edx
c01032ba:	89 c3                	mov    %eax,%ebx
c01032bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01032bf:	89 04 24             	mov    %eax,(%esp)
c01032c2:	e8 ad f8 ff ff       	call   c0102b74 <pa2page>
c01032c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01032cb:	89 04 24             	mov    %eax,(%esp)
c01032ce:	e8 8c fb ff ff       	call   c0102e5f <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c01032d3:	ff 45 dc             	incl   -0x24(%ebp)
c01032d6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01032d9:	8b 00                	mov    (%eax),%eax
c01032db:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01032de:	0f 8c a7 fe ff ff    	jl     c010318b <page_init+0x266>
                }
            }
        }
    }
}
c01032e4:	90                   	nop
c01032e5:	90                   	nop
c01032e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01032ec:	5b                   	pop    %ebx
c01032ed:	5e                   	pop    %esi
c01032ee:	5f                   	pop    %edi
c01032ef:	5d                   	pop    %ebp
c01032f0:	c3                   	ret    

c01032f1 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01032f1:	f3 0f 1e fb          	endbr32 
c01032f5:	55                   	push   %ebp
c01032f6:	89 e5                	mov    %esp,%ebp
c01032f8:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01032fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032fe:	33 45 14             	xor    0x14(%ebp),%eax
c0103301:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103306:	85 c0                	test   %eax,%eax
c0103308:	74 24                	je     c010332e <boot_map_segment+0x3d>
c010330a:	c7 44 24 0c 76 6c 10 	movl   $0xc0106c76,0xc(%esp)
c0103311:	c0 
c0103312:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103319:	c0 
c010331a:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103321:	00 
c0103322:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103329:	e8 08 d1 ff ff       	call   c0100436 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010332e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103335:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103338:	25 ff 0f 00 00       	and    $0xfff,%eax
c010333d:	89 c2                	mov    %eax,%edx
c010333f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103342:	01 c2                	add    %eax,%edx
c0103344:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103347:	01 d0                	add    %edx,%eax
c0103349:	48                   	dec    %eax
c010334a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010334d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103350:	ba 00 00 00 00       	mov    $0x0,%edx
c0103355:	f7 75 f0             	divl   -0x10(%ebp)
c0103358:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010335b:	29 d0                	sub    %edx,%eax
c010335d:	c1 e8 0c             	shr    $0xc,%eax
c0103360:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103363:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103366:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103369:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010336c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103371:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103374:	8b 45 14             	mov    0x14(%ebp),%eax
c0103377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010337a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010337d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103382:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103385:	eb 68                	jmp    c01033ef <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103387:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010338e:	00 
c010338f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103392:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103396:	8b 45 08             	mov    0x8(%ebp),%eax
c0103399:	89 04 24             	mov    %eax,(%esp)
c010339c:	e8 8a 01 00 00       	call   c010352b <get_pte>
c01033a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01033a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01033a8:	75 24                	jne    c01033ce <boot_map_segment+0xdd>
c01033aa:	c7 44 24 0c a2 6c 10 	movl   $0xc0106ca2,0xc(%esp)
c01033b1:	c0 
c01033b2:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c01033b9:	c0 
c01033ba:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01033c1:	00 
c01033c2:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01033c9:	e8 68 d0 ff ff       	call   c0100436 <__panic>
        *ptep = pa | PTE_P | perm;
c01033ce:	8b 45 14             	mov    0x14(%ebp),%eax
c01033d1:	0b 45 18             	or     0x18(%ebp),%eax
c01033d4:	83 c8 01             	or     $0x1,%eax
c01033d7:	89 c2                	mov    %eax,%edx
c01033d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01033dc:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01033de:	ff 4d f4             	decl   -0xc(%ebp)
c01033e1:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01033e8:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01033ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01033f3:	75 92                	jne    c0103387 <boot_map_segment+0x96>
    }
}
c01033f5:	90                   	nop
c01033f6:	90                   	nop
c01033f7:	c9                   	leave  
c01033f8:	c3                   	ret    

c01033f9 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01033f9:	f3 0f 1e fb          	endbr32 
c01033fd:	55                   	push   %ebp
c01033fe:	89 e5                	mov    %esp,%ebp
c0103400:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103403:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010340a:	e8 74 fa ff ff       	call   c0102e83 <alloc_pages>
c010340f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103412:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103416:	75 1c                	jne    c0103434 <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
c0103418:	c7 44 24 08 af 6c 10 	movl   $0xc0106caf,0x8(%esp)
c010341f:	c0 
c0103420:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0103427:	00 
c0103428:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c010342f:	e8 02 d0 ff ff       	call   c0100436 <__panic>
    }
    return page2kva(p);
c0103434:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103437:	89 04 24             	mov    %eax,(%esp)
c010343a:	e8 84 f7 ff ff       	call   c0102bc3 <page2kva>
}
c010343f:	c9                   	leave  
c0103440:	c3                   	ret    

c0103441 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103441:	f3 0f 1e fb          	endbr32 
c0103445:	55                   	push   %ebp
c0103446:	89 e5                	mov    %esp,%ebp
c0103448:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010344b:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103450:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103453:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010345a:	77 23                	ja     c010347f <pmm_init+0x3e>
c010345c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010345f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103463:	c7 44 24 08 44 6c 10 	movl   $0xc0106c44,0x8(%esp)
c010346a:	c0 
c010346b:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0103472:	00 
c0103473:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c010347a:	e8 b7 cf ff ff       	call   c0100436 <__panic>
c010347f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103482:	05 00 00 00 40       	add    $0x40000000,%eax
c0103487:	a3 74 df 11 c0       	mov    %eax,0xc011df74
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010348c:	e8 96 f9 ff ff       	call   c0102e27 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103491:	e8 8f fa ff ff       	call   c0102f25 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103496:	e8 77 04 00 00       	call   c0103912 <check_alloc_page>

    check_pgdir();
c010349b:	e8 95 04 00 00       	call   c0103935 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01034a0:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01034a8:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01034af:	77 23                	ja     c01034d4 <pmm_init+0x93>
c01034b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034b8:	c7 44 24 08 44 6c 10 	movl   $0xc0106c44,0x8(%esp)
c01034bf:	c0 
c01034c0:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c01034c7:	00 
c01034c8:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01034cf:	e8 62 cf ff ff       	call   c0100436 <__panic>
c01034d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034d7:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01034dd:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034e2:	05 ac 0f 00 00       	add    $0xfac,%eax
c01034e7:	83 ca 03             	or     $0x3,%edx
c01034ea:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01034ec:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01034f1:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01034f8:	00 
c01034f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103500:	00 
c0103501:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103508:	38 
c0103509:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103510:	c0 
c0103511:	89 04 24             	mov    %eax,(%esp)
c0103514:	e8 d8 fd ff ff       	call   c01032f1 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103519:	e8 1b f8 ff ff       	call   c0102d39 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010351e:	e8 b2 0a 00 00       	call   c0103fd5 <check_boot_pgdir>

    print_pgdir();
c0103523:	e8 37 0f 00 00       	call   c010445f <print_pgdir>

}
c0103528:	90                   	nop
c0103529:	c9                   	leave  
c010352a:	c3                   	ret    

c010352b <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010352b:	f3 0f 1e fb          	endbr32 
c010352f:	55                   	push   %ebp
c0103530:	89 e5                	mov    %esp,%ebp
c0103532:	83 ec 48             	sub    $0x48,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif

	pde_t pde_index = PDX(la); // find page directory entry
c0103535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103538:	c1 e8 16             	shr    $0x16,%eax
c010353b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pte_t* pte_addr = NULL;
c010353e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
	
	pde_t* pde_ptr = &pgdir[pde_index];
c0103545:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103548:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010354f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103552:	01 d0                	add    %edx,%eax
c0103554:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(*pde_ptr & PTE_P){ // check if entry is present
c0103557:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010355a:	8b 00                	mov    (%eax),%eax
c010355c:	83 e0 01             	and    $0x1,%eax
c010355f:	85 c0                	test   %eax,%eax
c0103561:	74 67                	je     c01035ca <get_pte+0x9f>
		pte_addr = (pte_t *)KADDR(PDE_ADDR(*pde_ptr));
c0103563:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103566:	8b 00                	mov    (%eax),%eax
c0103568:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010356d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103570:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103573:	c1 e8 0c             	shr    $0xc,%eax
c0103576:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103579:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010357e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103581:	72 23                	jb     c01035a6 <get_pte+0x7b>
c0103583:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103586:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010358a:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c0103591:	c0 
c0103592:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c0103599:	00 
c010359a:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01035a1:	e8 90 ce ff ff       	call   c0100436 <__panic>
c01035a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01035a9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01035ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
		return &(pte_addr)[PTX(la)]; // return page table entry
c01035b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01035b4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035b7:	c1 ea 0c             	shr    $0xc,%edx
c01035ba:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c01035c0:	c1 e2 02             	shl    $0x2,%edx
c01035c3:	01 d0                	add    %edx,%eax
c01035c5:	e9 20 01 00 00       	jmp    c01036ea <get_pte+0x1bf>
	}
	else{
		if(create == 0){ // check if creating is needed
c01035ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01035ce:	75 0a                	jne    c01035da <get_pte+0xaf>
			return NULL;
c01035d0:	b8 00 00 00 00       	mov    $0x0,%eax
c01035d5:	e9 10 01 00 00       	jmp    c01036ea <get_pte+0x1bf>
		}
		struct Page* new_page = alloc_page(); // alloc page for page table
c01035da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035e1:	e8 9d f8 ff ff       	call   c0102e83 <alloc_pages>
c01035e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if(new_page == NULL){
c01035e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01035ed:	75 0a                	jne    c01035f9 <get_pte+0xce>
			return NULL;
c01035ef:	b8 00 00 00 00       	mov    $0x0,%eax
c01035f4:	e9 f1 00 00 00       	jmp    c01036ea <get_pte+0x1bf>
		}
		set_page_ref(new_page, 1); // set page reference
c01035f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103600:	00 
c0103601:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103604:	89 04 24             	mov    %eax,(%esp)
c0103607:	e8 6b f6 ff ff       	call   c0102c77 <set_page_ref>
		uintptr_t phy_addr = page2pa(new_page); // get linear address of page
c010360c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010360f:	89 04 24             	mov    %eax,(%esp)
c0103612:	e8 47 f5 ff ff       	call   c0102b5e <page2pa>
c0103617:	89 45 e8             	mov    %eax,-0x18(%ebp)
		memset(KADDR(phy_addr), 0, PGSIZE); // clear page content using memset
c010361a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010361d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103620:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103623:	c1 e8 0c             	shr    $0xc,%eax
c0103626:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103629:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010362e:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103631:	72 23                	jb     c0103656 <get_pte+0x12b>
c0103633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103636:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010363a:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c0103641:	c0 
c0103642:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
c0103649:	00 
c010364a:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103651:	e8 e0 cd ff ff       	call   c0100436 <__panic>
c0103656:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103659:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010365e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103665:	00 
c0103666:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010366d:	00 
c010366e:	89 04 24             	mov    %eax,(%esp)
c0103671:	e8 c0 25 00 00       	call   c0105c36 <memset>
		*pde_ptr = phy_addr | PTE_P | PTE_W | PTE_U; // set page directory entry's permission
c0103676:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103679:	83 c8 07             	or     $0x7,%eax
c010367c:	89 c2                	mov    %eax,%edx
c010367e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103681:	89 10                	mov    %edx,(%eax)
		pte_addr = (pte_t *)KADDR(PDE_ADDR(*pde_ptr)); 
c0103683:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103686:	8b 00                	mov    (%eax),%eax
c0103688:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010368d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103690:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103693:	c1 e8 0c             	shr    $0xc,%eax
c0103696:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103699:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c010369e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01036a1:	72 23                	jb     c01036c6 <get_pte+0x19b>
c01036a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036aa:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c01036b1:	c0 
c01036b2:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c01036b9:	00 
c01036ba:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01036c1:	e8 70 cd ff ff       	call   c0100436 <__panic>
c01036c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036c9:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01036ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
		return (&pte_addr)[PTX(la)]; // return page table entry
c01036d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036d4:	c1 e8 0c             	shr    $0xc,%eax
c01036d7:	25 ff 03 00 00       	and    $0x3ff,%eax
c01036dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01036e3:	8d 45 cc             	lea    -0x34(%ebp),%eax
c01036e6:	01 d0                	add    %edx,%eax
c01036e8:	8b 00                	mov    (%eax),%eax
	}
	return NULL;
}
c01036ea:	c9                   	leave  
c01036eb:	c3                   	ret    

c01036ec <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01036ec:	f3 0f 1e fb          	endbr32 
c01036f0:	55                   	push   %ebp
c01036f1:	89 e5                	mov    %esp,%ebp
c01036f3:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01036f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036fd:	00 
c01036fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103701:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103705:	8b 45 08             	mov    0x8(%ebp),%eax
c0103708:	89 04 24             	mov    %eax,(%esp)
c010370b:	e8 1b fe ff ff       	call   c010352b <get_pte>
c0103710:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103713:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103717:	74 08                	je     c0103721 <get_page+0x35>
        *ptep_store = ptep;
c0103719:	8b 45 10             	mov    0x10(%ebp),%eax
c010371c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010371f:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103721:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103725:	74 1b                	je     c0103742 <get_page+0x56>
c0103727:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010372a:	8b 00                	mov    (%eax),%eax
c010372c:	83 e0 01             	and    $0x1,%eax
c010372f:	85 c0                	test   %eax,%eax
c0103731:	74 0f                	je     c0103742 <get_page+0x56>
        return pte2page(*ptep);
c0103733:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103736:	8b 00                	mov    (%eax),%eax
c0103738:	89 04 24             	mov    %eax,(%esp)
c010373b:	e8 d7 f4 ff ff       	call   c0102c17 <pte2page>
c0103740:	eb 05                	jmp    c0103747 <get_page+0x5b>
    }
    return NULL;
c0103742:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103747:	c9                   	leave  
c0103748:	c3                   	ret    

c0103749 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103749:	55                   	push   %ebp
c010374a:	89 e5                	mov    %esp,%ebp
c010374c:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
	if(*ptep & PTE_P){ 							// check if this page table entry is present
c010374f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103752:	8b 00                	mov    (%eax),%eax
c0103754:	83 e0 01             	and    $0x1,%eax
c0103757:	85 c0                	test   %eax,%eax
c0103759:	74 4d                	je     c01037a8 <page_remove_pte+0x5f>
		struct Page *page = pte2page(*ptep); 	// find corresponding page to pte
c010375b:	8b 45 10             	mov    0x10(%ebp),%eax
c010375e:	8b 00                	mov    (%eax),%eax
c0103760:	89 04 24             	mov    %eax,(%esp)
c0103763:	e8 af f4 ff ff       	call   c0102c17 <pte2page>
c0103768:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(page_ref_dec(page) == 0){ 			// decrease page reference
c010376b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010376e:	89 04 24             	mov    %eax,(%esp)
c0103771:	e8 26 f5 ff ff       	call   c0102c9c <page_ref_dec>
c0103776:	85 c0                	test   %eax,%eax
c0103778:	75 13                	jne    c010378d <page_remove_pte+0x44>
			free_page(page); 					// and free this page when page reference reachs 0
c010377a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103781:	00 
c0103782:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103785:	89 04 24             	mov    %eax,(%esp)
c0103788:	e8 32 f7 ff ff       	call   c0102ebf <free_pages>
		}
		*ptep = 0; 								// clear second page table entry
c010378d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103790:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, la); 				// flush tlb
c0103796:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103799:	89 44 24 04          	mov    %eax,0x4(%esp)
c010379d:	8b 45 08             	mov    0x8(%ebp),%eax
c01037a0:	89 04 24             	mov    %eax,(%esp)
c01037a3:	e8 09 01 00 00       	call   c01038b1 <tlb_invalidate>
	}
}
c01037a8:	90                   	nop
c01037a9:	c9                   	leave  
c01037aa:	c3                   	ret    

c01037ab <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01037ab:	f3 0f 1e fb          	endbr32 
c01037af:	55                   	push   %ebp
c01037b0:	89 e5                	mov    %esp,%ebp
c01037b2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01037b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037bc:	00 
c01037bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037c7:	89 04 24             	mov    %eax,(%esp)
c01037ca:	e8 5c fd ff ff       	call   c010352b <get_pte>
c01037cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01037d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01037d6:	74 19                	je     c01037f1 <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
c01037d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037db:	89 44 24 08          	mov    %eax,0x8(%esp)
c01037df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e9:	89 04 24             	mov    %eax,(%esp)
c01037ec:	e8 58 ff ff ff       	call   c0103749 <page_remove_pte>
    }
}
c01037f1:	90                   	nop
c01037f2:	c9                   	leave  
c01037f3:	c3                   	ret    

c01037f4 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01037f4:	f3 0f 1e fb          	endbr32 
c01037f8:	55                   	push   %ebp
c01037f9:	89 e5                	mov    %esp,%ebp
c01037fb:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01037fe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103805:	00 
c0103806:	8b 45 10             	mov    0x10(%ebp),%eax
c0103809:	89 44 24 04          	mov    %eax,0x4(%esp)
c010380d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103810:	89 04 24             	mov    %eax,(%esp)
c0103813:	e8 13 fd ff ff       	call   c010352b <get_pte>
c0103818:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010381b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010381f:	75 0a                	jne    c010382b <page_insert+0x37>
        return -E_NO_MEM;
c0103821:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103826:	e9 84 00 00 00       	jmp    c01038af <page_insert+0xbb>
    }
    page_ref_inc(page);
c010382b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010382e:	89 04 24             	mov    %eax,(%esp)
c0103831:	e8 4f f4 ff ff       	call   c0102c85 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103836:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103839:	8b 00                	mov    (%eax),%eax
c010383b:	83 e0 01             	and    $0x1,%eax
c010383e:	85 c0                	test   %eax,%eax
c0103840:	74 3e                	je     c0103880 <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
c0103842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103845:	8b 00                	mov    (%eax),%eax
c0103847:	89 04 24             	mov    %eax,(%esp)
c010384a:	e8 c8 f3 ff ff       	call   c0102c17 <pte2page>
c010384f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103852:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103855:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103858:	75 0d                	jne    c0103867 <page_insert+0x73>
            page_ref_dec(page);
c010385a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010385d:	89 04 24             	mov    %eax,(%esp)
c0103860:	e8 37 f4 ff ff       	call   c0102c9c <page_ref_dec>
c0103865:	eb 19                	jmp    c0103880 <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010386a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010386e:	8b 45 10             	mov    0x10(%ebp),%eax
c0103871:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103875:	8b 45 08             	mov    0x8(%ebp),%eax
c0103878:	89 04 24             	mov    %eax,(%esp)
c010387b:	e8 c9 fe ff ff       	call   c0103749 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103880:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103883:	89 04 24             	mov    %eax,(%esp)
c0103886:	e8 d3 f2 ff ff       	call   c0102b5e <page2pa>
c010388b:	0b 45 14             	or     0x14(%ebp),%eax
c010388e:	83 c8 01             	or     $0x1,%eax
c0103891:	89 c2                	mov    %eax,%edx
c0103893:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103896:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103898:	8b 45 10             	mov    0x10(%ebp),%eax
c010389b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010389f:	8b 45 08             	mov    0x8(%ebp),%eax
c01038a2:	89 04 24             	mov    %eax,(%esp)
c01038a5:	e8 07 00 00 00       	call   c01038b1 <tlb_invalidate>
    return 0;
c01038aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01038af:	c9                   	leave  
c01038b0:	c3                   	ret    

c01038b1 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01038b1:	f3 0f 1e fb          	endbr32 
c01038b5:	55                   	push   %ebp
c01038b6:	89 e5                	mov    %esp,%ebp
c01038b8:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01038bb:	0f 20 d8             	mov    %cr3,%eax
c01038be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01038c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01038c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038ca:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01038d1:	77 23                	ja     c01038f6 <tlb_invalidate+0x45>
c01038d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01038da:	c7 44 24 08 44 6c 10 	movl   $0xc0106c44,0x8(%esp)
c01038e1:	c0 
c01038e2:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c01038e9:	00 
c01038ea:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01038f1:	e8 40 cb ff ff       	call   c0100436 <__panic>
c01038f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038f9:	05 00 00 00 40       	add    $0x40000000,%eax
c01038fe:	39 d0                	cmp    %edx,%eax
c0103900:	75 0d                	jne    c010390f <tlb_invalidate+0x5e>
        invlpg((void *)la);
c0103902:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103905:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010390b:	0f 01 38             	invlpg (%eax)
}
c010390e:	90                   	nop
    }
}
c010390f:	90                   	nop
c0103910:	c9                   	leave  
c0103911:	c3                   	ret    

c0103912 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103912:	f3 0f 1e fb          	endbr32 
c0103916:	55                   	push   %ebp
c0103917:	89 e5                	mov    %esp,%ebp
c0103919:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010391c:	a1 70 df 11 c0       	mov    0xc011df70,%eax
c0103921:	8b 40 18             	mov    0x18(%eax),%eax
c0103924:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103926:	c7 04 24 c8 6c 10 c0 	movl   $0xc0106cc8,(%esp)
c010392d:	e8 98 c9 ff ff       	call   c01002ca <cprintf>
}
c0103932:	90                   	nop
c0103933:	c9                   	leave  
c0103934:	c3                   	ret    

c0103935 <check_pgdir>:

static void
check_pgdir(void) {
c0103935:	f3 0f 1e fb          	endbr32 
c0103939:	55                   	push   %ebp
c010393a:	89 e5                	mov    %esp,%ebp
c010393c:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010393f:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103944:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103949:	76 24                	jbe    c010396f <check_pgdir+0x3a>
c010394b:	c7 44 24 0c e7 6c 10 	movl   $0xc0106ce7,0xc(%esp)
c0103952:	c0 
c0103953:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c010395a:	c0 
c010395b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0103962:	00 
c0103963:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c010396a:	e8 c7 ca ff ff       	call   c0100436 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c010396f:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103974:	85 c0                	test   %eax,%eax
c0103976:	74 0e                	je     c0103986 <check_pgdir+0x51>
c0103978:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010397d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103982:	85 c0                	test   %eax,%eax
c0103984:	74 24                	je     c01039aa <check_pgdir+0x75>
c0103986:	c7 44 24 0c 04 6d 10 	movl   $0xc0106d04,0xc(%esp)
c010398d:	c0 
c010398e:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103995:	c0 
c0103996:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010399d:	00 
c010399e:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01039a5:	e8 8c ca ff ff       	call   c0100436 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01039aa:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01039af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01039b6:	00 
c01039b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01039be:	00 
c01039bf:	89 04 24             	mov    %eax,(%esp)
c01039c2:	e8 25 fd ff ff       	call   c01036ec <get_page>
c01039c7:	85 c0                	test   %eax,%eax
c01039c9:	74 24                	je     c01039ef <check_pgdir+0xba>
c01039cb:	c7 44 24 0c 3c 6d 10 	movl   $0xc0106d3c,0xc(%esp)
c01039d2:	c0 
c01039d3:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c01039da:	c0 
c01039db:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c01039e2:	00 
c01039e3:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01039ea:	e8 47 ca ff ff       	call   c0100436 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01039ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01039f6:	e8 88 f4 ff ff       	call   c0102e83 <alloc_pages>
c01039fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01039fe:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103a0a:	00 
c0103a0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a12:	00 
c0103a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a16:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a1a:	89 04 24             	mov    %eax,(%esp)
c0103a1d:	e8 d2 fd ff ff       	call   c01037f4 <page_insert>
c0103a22:	85 c0                	test   %eax,%eax
c0103a24:	74 24                	je     c0103a4a <check_pgdir+0x115>
c0103a26:	c7 44 24 0c 64 6d 10 	movl   $0xc0106d64,0xc(%esp)
c0103a2d:	c0 
c0103a2e:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103a35:	c0 
c0103a36:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103a3d:	00 
c0103a3e:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103a45:	e8 ec c9 ff ff       	call   c0100436 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103a4a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103a4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a56:	00 
c0103a57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103a5e:	00 
c0103a5f:	89 04 24             	mov    %eax,(%esp)
c0103a62:	e8 c4 fa ff ff       	call   c010352b <get_pte>
c0103a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a6e:	75 24                	jne    c0103a94 <check_pgdir+0x15f>
c0103a70:	c7 44 24 0c 90 6d 10 	movl   $0xc0106d90,0xc(%esp)
c0103a77:	c0 
c0103a78:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103a7f:	c0 
c0103a80:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0103a87:	00 
c0103a88:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103a8f:	e8 a2 c9 ff ff       	call   c0100436 <__panic>
    assert(pte2page(*ptep) == p1);
c0103a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a97:	8b 00                	mov    (%eax),%eax
c0103a99:	89 04 24             	mov    %eax,(%esp)
c0103a9c:	e8 76 f1 ff ff       	call   c0102c17 <pte2page>
c0103aa1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103aa4:	74 24                	je     c0103aca <check_pgdir+0x195>
c0103aa6:	c7 44 24 0c bd 6d 10 	movl   $0xc0106dbd,0xc(%esp)
c0103aad:	c0 
c0103aae:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103ab5:	c0 
c0103ab6:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103abd:	00 
c0103abe:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103ac5:	e8 6c c9 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p1) == 1);
c0103aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103acd:	89 04 24             	mov    %eax,(%esp)
c0103ad0:	e8 98 f1 ff ff       	call   c0102c6d <page_ref>
c0103ad5:	83 f8 01             	cmp    $0x1,%eax
c0103ad8:	74 24                	je     c0103afe <check_pgdir+0x1c9>
c0103ada:	c7 44 24 0c d3 6d 10 	movl   $0xc0106dd3,0xc(%esp)
c0103ae1:	c0 
c0103ae2:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103ae9:	c0 
c0103aea:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103af1:	00 
c0103af2:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103af9:	e8 38 c9 ff ff       	call   c0100436 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103afe:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b03:	8b 00                	mov    (%eax),%eax
c0103b05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103b0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b10:	c1 e8 0c             	shr    $0xc,%eax
c0103b13:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b16:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103b1b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103b1e:	72 23                	jb     c0103b43 <check_pgdir+0x20e>
c0103b20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b27:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c0103b2e:	c0 
c0103b2f:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103b36:	00 
c0103b37:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103b3e:	e8 f3 c8 ff ff       	call   c0100436 <__panic>
c0103b43:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b46:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103b4b:	83 c0 04             	add    $0x4,%eax
c0103b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103b51:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103b56:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b5d:	00 
c0103b5e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b65:	00 
c0103b66:	89 04 24             	mov    %eax,(%esp)
c0103b69:	e8 bd f9 ff ff       	call   c010352b <get_pte>
c0103b6e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103b71:	74 24                	je     c0103b97 <check_pgdir+0x262>
c0103b73:	c7 44 24 0c e8 6d 10 	movl   $0xc0106de8,0xc(%esp)
c0103b7a:	c0 
c0103b7b:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103b82:	c0 
c0103b83:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0103b8a:	00 
c0103b8b:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103b92:	e8 9f c8 ff ff       	call   c0100436 <__panic>

    p2 = alloc_page();
c0103b97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b9e:	e8 e0 f2 ff ff       	call   c0102e83 <alloc_pages>
c0103ba3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103ba6:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103bb2:	00 
c0103bb3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103bba:	00 
c0103bbb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103bc2:	89 04 24             	mov    %eax,(%esp)
c0103bc5:	e8 2a fc ff ff       	call   c01037f4 <page_insert>
c0103bca:	85 c0                	test   %eax,%eax
c0103bcc:	74 24                	je     c0103bf2 <check_pgdir+0x2bd>
c0103bce:	c7 44 24 0c 10 6e 10 	movl   $0xc0106e10,0xc(%esp)
c0103bd5:	c0 
c0103bd6:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103bdd:	c0 
c0103bde:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103be5:	00 
c0103be6:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103bed:	e8 44 c8 ff ff       	call   c0100436 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103bf2:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103bf7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103bfe:	00 
c0103bff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103c06:	00 
c0103c07:	89 04 24             	mov    %eax,(%esp)
c0103c0a:	e8 1c f9 ff ff       	call   c010352b <get_pte>
c0103c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c16:	75 24                	jne    c0103c3c <check_pgdir+0x307>
c0103c18:	c7 44 24 0c 48 6e 10 	movl   $0xc0106e48,0xc(%esp)
c0103c1f:	c0 
c0103c20:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103c27:	c0 
c0103c28:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0103c2f:	00 
c0103c30:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103c37:	e8 fa c7 ff ff       	call   c0100436 <__panic>
    assert(*ptep & PTE_U);
c0103c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c3f:	8b 00                	mov    (%eax),%eax
c0103c41:	83 e0 04             	and    $0x4,%eax
c0103c44:	85 c0                	test   %eax,%eax
c0103c46:	75 24                	jne    c0103c6c <check_pgdir+0x337>
c0103c48:	c7 44 24 0c 78 6e 10 	movl   $0xc0106e78,0xc(%esp)
c0103c4f:	c0 
c0103c50:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103c57:	c0 
c0103c58:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103c5f:	00 
c0103c60:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103c67:	e8 ca c7 ff ff       	call   c0100436 <__panic>
    assert(*ptep & PTE_W);
c0103c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c6f:	8b 00                	mov    (%eax),%eax
c0103c71:	83 e0 02             	and    $0x2,%eax
c0103c74:	85 c0                	test   %eax,%eax
c0103c76:	75 24                	jne    c0103c9c <check_pgdir+0x367>
c0103c78:	c7 44 24 0c 86 6e 10 	movl   $0xc0106e86,0xc(%esp)
c0103c7f:	c0 
c0103c80:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103c87:	c0 
c0103c88:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0103c8f:	00 
c0103c90:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103c97:	e8 9a c7 ff ff       	call   c0100436 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103c9c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ca1:	8b 00                	mov    (%eax),%eax
c0103ca3:	83 e0 04             	and    $0x4,%eax
c0103ca6:	85 c0                	test   %eax,%eax
c0103ca8:	75 24                	jne    c0103cce <check_pgdir+0x399>
c0103caa:	c7 44 24 0c 94 6e 10 	movl   $0xc0106e94,0xc(%esp)
c0103cb1:	c0 
c0103cb2:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103cb9:	c0 
c0103cba:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0103cc1:	00 
c0103cc2:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103cc9:	e8 68 c7 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p2) == 1);
c0103cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103cd1:	89 04 24             	mov    %eax,(%esp)
c0103cd4:	e8 94 ef ff ff       	call   c0102c6d <page_ref>
c0103cd9:	83 f8 01             	cmp    $0x1,%eax
c0103cdc:	74 24                	je     c0103d02 <check_pgdir+0x3cd>
c0103cde:	c7 44 24 0c aa 6e 10 	movl   $0xc0106eaa,0xc(%esp)
c0103ce5:	c0 
c0103ce6:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103ced:	c0 
c0103cee:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0103cf5:	00 
c0103cf6:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103cfd:	e8 34 c7 ff ff       	call   c0100436 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103d02:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103d07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103d0e:	00 
c0103d0f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103d16:	00 
c0103d17:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d1a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d1e:	89 04 24             	mov    %eax,(%esp)
c0103d21:	e8 ce fa ff ff       	call   c01037f4 <page_insert>
c0103d26:	85 c0                	test   %eax,%eax
c0103d28:	74 24                	je     c0103d4e <check_pgdir+0x419>
c0103d2a:	c7 44 24 0c bc 6e 10 	movl   $0xc0106ebc,0xc(%esp)
c0103d31:	c0 
c0103d32:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103d39:	c0 
c0103d3a:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0103d41:	00 
c0103d42:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103d49:	e8 e8 c6 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p1) == 2);
c0103d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d51:	89 04 24             	mov    %eax,(%esp)
c0103d54:	e8 14 ef ff ff       	call   c0102c6d <page_ref>
c0103d59:	83 f8 02             	cmp    $0x2,%eax
c0103d5c:	74 24                	je     c0103d82 <check_pgdir+0x44d>
c0103d5e:	c7 44 24 0c e8 6e 10 	movl   $0xc0106ee8,0xc(%esp)
c0103d65:	c0 
c0103d66:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103d6d:	c0 
c0103d6e:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0103d75:	00 
c0103d76:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103d7d:	e8 b4 c6 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p2) == 0);
c0103d82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d85:	89 04 24             	mov    %eax,(%esp)
c0103d88:	e8 e0 ee ff ff       	call   c0102c6d <page_ref>
c0103d8d:	85 c0                	test   %eax,%eax
c0103d8f:	74 24                	je     c0103db5 <check_pgdir+0x480>
c0103d91:	c7 44 24 0c fa 6e 10 	movl   $0xc0106efa,0xc(%esp)
c0103d98:	c0 
c0103d99:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103da0:	c0 
c0103da1:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0103da8:	00 
c0103da9:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103db0:	e8 81 c6 ff ff       	call   c0100436 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103db5:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103dba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103dc1:	00 
c0103dc2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103dc9:	00 
c0103dca:	89 04 24             	mov    %eax,(%esp)
c0103dcd:	e8 59 f7 ff ff       	call   c010352b <get_pte>
c0103dd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103dd5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103dd9:	75 24                	jne    c0103dff <check_pgdir+0x4ca>
c0103ddb:	c7 44 24 0c 48 6e 10 	movl   $0xc0106e48,0xc(%esp)
c0103de2:	c0 
c0103de3:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103dea:	c0 
c0103deb:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103df2:	00 
c0103df3:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103dfa:	e8 37 c6 ff ff       	call   c0100436 <__panic>
    assert(pte2page(*ptep) == p1);
c0103dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e02:	8b 00                	mov    (%eax),%eax
c0103e04:	89 04 24             	mov    %eax,(%esp)
c0103e07:	e8 0b ee ff ff       	call   c0102c17 <pte2page>
c0103e0c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103e0f:	74 24                	je     c0103e35 <check_pgdir+0x500>
c0103e11:	c7 44 24 0c bd 6d 10 	movl   $0xc0106dbd,0xc(%esp)
c0103e18:	c0 
c0103e19:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103e20:	c0 
c0103e21:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0103e28:	00 
c0103e29:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103e30:	e8 01 c6 ff ff       	call   c0100436 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e38:	8b 00                	mov    (%eax),%eax
c0103e3a:	83 e0 04             	and    $0x4,%eax
c0103e3d:	85 c0                	test   %eax,%eax
c0103e3f:	74 24                	je     c0103e65 <check_pgdir+0x530>
c0103e41:	c7 44 24 0c 0c 6f 10 	movl   $0xc0106f0c,0xc(%esp)
c0103e48:	c0 
c0103e49:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103e50:	c0 
c0103e51:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0103e58:	00 
c0103e59:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103e60:	e8 d1 c5 ff ff       	call   c0100436 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103e65:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103e6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103e71:	00 
c0103e72:	89 04 24             	mov    %eax,(%esp)
c0103e75:	e8 31 f9 ff ff       	call   c01037ab <page_remove>
    assert(page_ref(p1) == 1);
c0103e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e7d:	89 04 24             	mov    %eax,(%esp)
c0103e80:	e8 e8 ed ff ff       	call   c0102c6d <page_ref>
c0103e85:	83 f8 01             	cmp    $0x1,%eax
c0103e88:	74 24                	je     c0103eae <check_pgdir+0x579>
c0103e8a:	c7 44 24 0c d3 6d 10 	movl   $0xc0106dd3,0xc(%esp)
c0103e91:	c0 
c0103e92:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103e99:	c0 
c0103e9a:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0103ea1:	00 
c0103ea2:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103ea9:	e8 88 c5 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p2) == 0);
c0103eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eb1:	89 04 24             	mov    %eax,(%esp)
c0103eb4:	e8 b4 ed ff ff       	call   c0102c6d <page_ref>
c0103eb9:	85 c0                	test   %eax,%eax
c0103ebb:	74 24                	je     c0103ee1 <check_pgdir+0x5ac>
c0103ebd:	c7 44 24 0c fa 6e 10 	movl   $0xc0106efa,0xc(%esp)
c0103ec4:	c0 
c0103ec5:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103ecc:	c0 
c0103ecd:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c0103ed4:	00 
c0103ed5:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103edc:	e8 55 c5 ff ff       	call   c0100436 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103ee1:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103ee6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103eed:	00 
c0103eee:	89 04 24             	mov    %eax,(%esp)
c0103ef1:	e8 b5 f8 ff ff       	call   c01037ab <page_remove>
    assert(page_ref(p1) == 0);
c0103ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ef9:	89 04 24             	mov    %eax,(%esp)
c0103efc:	e8 6c ed ff ff       	call   c0102c6d <page_ref>
c0103f01:	85 c0                	test   %eax,%eax
c0103f03:	74 24                	je     c0103f29 <check_pgdir+0x5f4>
c0103f05:	c7 44 24 0c 21 6f 10 	movl   $0xc0106f21,0xc(%esp)
c0103f0c:	c0 
c0103f0d:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103f14:	c0 
c0103f15:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0103f1c:	00 
c0103f1d:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103f24:	e8 0d c5 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p2) == 0);
c0103f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f2c:	89 04 24             	mov    %eax,(%esp)
c0103f2f:	e8 39 ed ff ff       	call   c0102c6d <page_ref>
c0103f34:	85 c0                	test   %eax,%eax
c0103f36:	74 24                	je     c0103f5c <check_pgdir+0x627>
c0103f38:	c7 44 24 0c fa 6e 10 	movl   $0xc0106efa,0xc(%esp)
c0103f3f:	c0 
c0103f40:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103f47:	c0 
c0103f48:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0103f4f:	00 
c0103f50:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103f57:	e8 da c4 ff ff       	call   c0100436 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103f5c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103f61:	8b 00                	mov    (%eax),%eax
c0103f63:	89 04 24             	mov    %eax,(%esp)
c0103f66:	e8 ea ec ff ff       	call   c0102c55 <pde2page>
c0103f6b:	89 04 24             	mov    %eax,(%esp)
c0103f6e:	e8 fa ec ff ff       	call   c0102c6d <page_ref>
c0103f73:	83 f8 01             	cmp    $0x1,%eax
c0103f76:	74 24                	je     c0103f9c <check_pgdir+0x667>
c0103f78:	c7 44 24 0c 34 6f 10 	movl   $0xc0106f34,0xc(%esp)
c0103f7f:	c0 
c0103f80:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0103f87:	c0 
c0103f88:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0103f8f:	00 
c0103f90:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0103f97:	e8 9a c4 ff ff       	call   c0100436 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103f9c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103fa1:	8b 00                	mov    (%eax),%eax
c0103fa3:	89 04 24             	mov    %eax,(%esp)
c0103fa6:	e8 aa ec ff ff       	call   c0102c55 <pde2page>
c0103fab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103fb2:	00 
c0103fb3:	89 04 24             	mov    %eax,(%esp)
c0103fb6:	e8 04 ef ff ff       	call   c0102ebf <free_pages>
    boot_pgdir[0] = 0;
c0103fbb:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0103fc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103fc6:	c7 04 24 5b 6f 10 c0 	movl   $0xc0106f5b,(%esp)
c0103fcd:	e8 f8 c2 ff ff       	call   c01002ca <cprintf>
}
c0103fd2:	90                   	nop
c0103fd3:	c9                   	leave  
c0103fd4:	c3                   	ret    

c0103fd5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103fd5:	f3 0f 1e fb          	endbr32 
c0103fd9:	55                   	push   %ebp
c0103fda:	89 e5                	mov    %esp,%ebp
c0103fdc:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103fdf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103fe6:	e9 ca 00 00 00       	jmp    c01040b5 <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ff4:	c1 e8 0c             	shr    $0xc,%eax
c0103ff7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103ffa:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c0103fff:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104002:	72 23                	jb     c0104027 <check_boot_pgdir+0x52>
c0104004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104007:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010400b:	c7 44 24 08 a0 6b 10 	movl   $0xc0106ba0,0x8(%esp)
c0104012:	c0 
c0104013:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c010401a:	00 
c010401b:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104022:	e8 0f c4 ff ff       	call   c0100436 <__panic>
c0104027:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010402a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010402f:	89 c2                	mov    %eax,%edx
c0104031:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0104036:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010403d:	00 
c010403e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104042:	89 04 24             	mov    %eax,(%esp)
c0104045:	e8 e1 f4 ff ff       	call   c010352b <get_pte>
c010404a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010404d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104051:	75 24                	jne    c0104077 <check_boot_pgdir+0xa2>
c0104053:	c7 44 24 0c 78 6f 10 	movl   $0xc0106f78,0xc(%esp)
c010405a:	c0 
c010405b:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104062:	c0 
c0104063:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c010406a:	00 
c010406b:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104072:	e8 bf c3 ff ff       	call   c0100436 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104077:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010407a:	8b 00                	mov    (%eax),%eax
c010407c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104081:	89 c2                	mov    %eax,%edx
c0104083:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104086:	39 c2                	cmp    %eax,%edx
c0104088:	74 24                	je     c01040ae <check_boot_pgdir+0xd9>
c010408a:	c7 44 24 0c b5 6f 10 	movl   $0xc0106fb5,0xc(%esp)
c0104091:	c0 
c0104092:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104099:	c0 
c010409a:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c01040a1:	00 
c01040a2:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01040a9:	e8 88 c3 ff ff       	call   c0100436 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01040ae:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01040b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01040b8:	a1 80 de 11 c0       	mov    0xc011de80,%eax
c01040bd:	39 c2                	cmp    %eax,%edx
c01040bf:	0f 82 26 ff ff ff    	jb     c0103feb <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01040c5:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01040ca:	05 ac 0f 00 00       	add    $0xfac,%eax
c01040cf:	8b 00                	mov    (%eax),%eax
c01040d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01040d6:	89 c2                	mov    %eax,%edx
c01040d8:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01040dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01040e0:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01040e7:	77 23                	ja     c010410c <check_boot_pgdir+0x137>
c01040e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01040f0:	c7 44 24 08 44 6c 10 	movl   $0xc0106c44,0x8(%esp)
c01040f7:	c0 
c01040f8:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c01040ff:	00 
c0104100:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104107:	e8 2a c3 ff ff       	call   c0100436 <__panic>
c010410c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010410f:	05 00 00 00 40       	add    $0x40000000,%eax
c0104114:	39 d0                	cmp    %edx,%eax
c0104116:	74 24                	je     c010413c <check_boot_pgdir+0x167>
c0104118:	c7 44 24 0c cc 6f 10 	movl   $0xc0106fcc,0xc(%esp)
c010411f:	c0 
c0104120:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104127:	c0 
c0104128:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c010412f:	00 
c0104130:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104137:	e8 fa c2 ff ff       	call   c0100436 <__panic>

    assert(boot_pgdir[0] == 0);
c010413c:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c0104141:	8b 00                	mov    (%eax),%eax
c0104143:	85 c0                	test   %eax,%eax
c0104145:	74 24                	je     c010416b <check_boot_pgdir+0x196>
c0104147:	c7 44 24 0c 00 70 10 	movl   $0xc0107000,0xc(%esp)
c010414e:	c0 
c010414f:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104156:	c0 
c0104157:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
c010415e:	00 
c010415f:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104166:	e8 cb c2 ff ff       	call   c0100436 <__panic>

    struct Page *p;
    p = alloc_page();
c010416b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104172:	e8 0c ed ff ff       	call   c0102e83 <alloc_pages>
c0104177:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010417a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010417f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104186:	00 
c0104187:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010418e:	00 
c010418f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104192:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104196:	89 04 24             	mov    %eax,(%esp)
c0104199:	e8 56 f6 ff ff       	call   c01037f4 <page_insert>
c010419e:	85 c0                	test   %eax,%eax
c01041a0:	74 24                	je     c01041c6 <check_boot_pgdir+0x1f1>
c01041a2:	c7 44 24 0c 14 70 10 	movl   $0xc0107014,0xc(%esp)
c01041a9:	c0 
c01041aa:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c01041b1:	c0 
c01041b2:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c01041b9:	00 
c01041ba:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01041c1:	e8 70 c2 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p) == 1);
c01041c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041c9:	89 04 24             	mov    %eax,(%esp)
c01041cc:	e8 9c ea ff ff       	call   c0102c6d <page_ref>
c01041d1:	83 f8 01             	cmp    $0x1,%eax
c01041d4:	74 24                	je     c01041fa <check_boot_pgdir+0x225>
c01041d6:	c7 44 24 0c 42 70 10 	movl   $0xc0107042,0xc(%esp)
c01041dd:	c0 
c01041de:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c01041e5:	c0 
c01041e6:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01041ed:	00 
c01041ee:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01041f5:	e8 3c c2 ff ff       	call   c0100436 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01041fa:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c01041ff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104206:	00 
c0104207:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010420e:	00 
c010420f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104212:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104216:	89 04 24             	mov    %eax,(%esp)
c0104219:	e8 d6 f5 ff ff       	call   c01037f4 <page_insert>
c010421e:	85 c0                	test   %eax,%eax
c0104220:	74 24                	je     c0104246 <check_boot_pgdir+0x271>
c0104222:	c7 44 24 0c 54 70 10 	movl   $0xc0107054,0xc(%esp)
c0104229:	c0 
c010422a:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104231:	c0 
c0104232:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0104239:	00 
c010423a:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104241:	e8 f0 c1 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p) == 2);
c0104246:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104249:	89 04 24             	mov    %eax,(%esp)
c010424c:	e8 1c ea ff ff       	call   c0102c6d <page_ref>
c0104251:	83 f8 02             	cmp    $0x2,%eax
c0104254:	74 24                	je     c010427a <check_boot_pgdir+0x2a5>
c0104256:	c7 44 24 0c 8b 70 10 	movl   $0xc010708b,0xc(%esp)
c010425d:	c0 
c010425e:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104265:	c0 
c0104266:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c010426d:	00 
c010426e:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104275:	e8 bc c1 ff ff       	call   c0100436 <__panic>

    const char *str = "ucore: Hello world!!";
c010427a:	c7 45 e8 9c 70 10 c0 	movl   $0xc010709c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0104281:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104284:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104288:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010428f:	e8 be 16 00 00       	call   c0105952 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0104294:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c010429b:	00 
c010429c:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01042a3:	e8 28 17 00 00       	call   c01059d0 <strcmp>
c01042a8:	85 c0                	test   %eax,%eax
c01042aa:	74 24                	je     c01042d0 <check_boot_pgdir+0x2fb>
c01042ac:	c7 44 24 0c b4 70 10 	movl   $0xc01070b4,0xc(%esp)
c01042b3:	c0 
c01042b4:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c01042bb:	c0 
c01042bc:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c01042c3:	00 
c01042c4:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c01042cb:	e8 66 c1 ff ff       	call   c0100436 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01042d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01042d3:	89 04 24             	mov    %eax,(%esp)
c01042d6:	e8 e8 e8 ff ff       	call   c0102bc3 <page2kva>
c01042db:	05 00 01 00 00       	add    $0x100,%eax
c01042e0:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01042e3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01042ea:	e8 05 16 00 00       	call   c01058f4 <strlen>
c01042ef:	85 c0                	test   %eax,%eax
c01042f1:	74 24                	je     c0104317 <check_boot_pgdir+0x342>
c01042f3:	c7 44 24 0c ec 70 10 	movl   $0xc01070ec,0xc(%esp)
c01042fa:	c0 
c01042fb:	c7 44 24 08 8d 6c 10 	movl   $0xc0106c8d,0x8(%esp)
c0104302:	c0 
c0104303:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010430a:	00 
c010430b:	c7 04 24 68 6c 10 c0 	movl   $0xc0106c68,(%esp)
c0104312:	e8 1f c1 ff ff       	call   c0100436 <__panic>

    free_page(p);
c0104317:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010431e:	00 
c010431f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104322:	89 04 24             	mov    %eax,(%esp)
c0104325:	e8 95 eb ff ff       	call   c0102ebf <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010432a:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010432f:	8b 00                	mov    (%eax),%eax
c0104331:	89 04 24             	mov    %eax,(%esp)
c0104334:	e8 1c e9 ff ff       	call   c0102c55 <pde2page>
c0104339:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104340:	00 
c0104341:	89 04 24             	mov    %eax,(%esp)
c0104344:	e8 76 eb ff ff       	call   c0102ebf <free_pages>
    boot_pgdir[0] = 0;
c0104349:	a1 e0 a9 11 c0       	mov    0xc011a9e0,%eax
c010434e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104354:	c7 04 24 10 71 10 c0 	movl   $0xc0107110,(%esp)
c010435b:	e8 6a bf ff ff       	call   c01002ca <cprintf>
}
c0104360:	90                   	nop
c0104361:	c9                   	leave  
c0104362:	c3                   	ret    

c0104363 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104363:	f3 0f 1e fb          	endbr32 
c0104367:	55                   	push   %ebp
c0104368:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010436a:	8b 45 08             	mov    0x8(%ebp),%eax
c010436d:	83 e0 04             	and    $0x4,%eax
c0104370:	85 c0                	test   %eax,%eax
c0104372:	74 04                	je     c0104378 <perm2str+0x15>
c0104374:	b0 75                	mov    $0x75,%al
c0104376:	eb 02                	jmp    c010437a <perm2str+0x17>
c0104378:	b0 2d                	mov    $0x2d,%al
c010437a:	a2 08 df 11 c0       	mov    %al,0xc011df08
    str[1] = 'r';
c010437f:	c6 05 09 df 11 c0 72 	movb   $0x72,0xc011df09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104386:	8b 45 08             	mov    0x8(%ebp),%eax
c0104389:	83 e0 02             	and    $0x2,%eax
c010438c:	85 c0                	test   %eax,%eax
c010438e:	74 04                	je     c0104394 <perm2str+0x31>
c0104390:	b0 77                	mov    $0x77,%al
c0104392:	eb 02                	jmp    c0104396 <perm2str+0x33>
c0104394:	b0 2d                	mov    $0x2d,%al
c0104396:	a2 0a df 11 c0       	mov    %al,0xc011df0a
    str[3] = '\0';
c010439b:	c6 05 0b df 11 c0 00 	movb   $0x0,0xc011df0b
    return str;
c01043a2:	b8 08 df 11 c0       	mov    $0xc011df08,%eax
}
c01043a7:	5d                   	pop    %ebp
c01043a8:	c3                   	ret    

c01043a9 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01043a9:	f3 0f 1e fb          	endbr32 
c01043ad:	55                   	push   %ebp
c01043ae:	89 e5                	mov    %esp,%ebp
c01043b0:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01043b3:	8b 45 10             	mov    0x10(%ebp),%eax
c01043b6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01043b9:	72 0d                	jb     c01043c8 <get_pgtable_items+0x1f>
        return 0;
c01043bb:	b8 00 00 00 00       	mov    $0x0,%eax
c01043c0:	e9 98 00 00 00       	jmp    c010445d <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01043c5:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01043c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01043cb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01043ce:	73 18                	jae    c01043e8 <get_pgtable_items+0x3f>
c01043d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01043d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01043da:	8b 45 14             	mov    0x14(%ebp),%eax
c01043dd:	01 d0                	add    %edx,%eax
c01043df:	8b 00                	mov    (%eax),%eax
c01043e1:	83 e0 01             	and    $0x1,%eax
c01043e4:	85 c0                	test   %eax,%eax
c01043e6:	74 dd                	je     c01043c5 <get_pgtable_items+0x1c>
    }
    if (start < right) {
c01043e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01043eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01043ee:	73 68                	jae    c0104458 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01043f0:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01043f4:	74 08                	je     c01043fe <get_pgtable_items+0x55>
            *left_store = start;
c01043f6:	8b 45 18             	mov    0x18(%ebp),%eax
c01043f9:	8b 55 10             	mov    0x10(%ebp),%edx
c01043fc:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01043fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0104401:	8d 50 01             	lea    0x1(%eax),%edx
c0104404:	89 55 10             	mov    %edx,0x10(%ebp)
c0104407:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010440e:	8b 45 14             	mov    0x14(%ebp),%eax
c0104411:	01 d0                	add    %edx,%eax
c0104413:	8b 00                	mov    (%eax),%eax
c0104415:	83 e0 07             	and    $0x7,%eax
c0104418:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010441b:	eb 03                	jmp    c0104420 <get_pgtable_items+0x77>
            start ++;
c010441d:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104420:	8b 45 10             	mov    0x10(%ebp),%eax
c0104423:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104426:	73 1d                	jae    c0104445 <get_pgtable_items+0x9c>
c0104428:	8b 45 10             	mov    0x10(%ebp),%eax
c010442b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104432:	8b 45 14             	mov    0x14(%ebp),%eax
c0104435:	01 d0                	add    %edx,%eax
c0104437:	8b 00                	mov    (%eax),%eax
c0104439:	83 e0 07             	and    $0x7,%eax
c010443c:	89 c2                	mov    %eax,%edx
c010443e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104441:	39 c2                	cmp    %eax,%edx
c0104443:	74 d8                	je     c010441d <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
c0104445:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104449:	74 08                	je     c0104453 <get_pgtable_items+0xaa>
            *right_store = start;
c010444b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010444e:	8b 55 10             	mov    0x10(%ebp),%edx
c0104451:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104453:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104456:	eb 05                	jmp    c010445d <get_pgtable_items+0xb4>
    }
    return 0;
c0104458:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010445d:	c9                   	leave  
c010445e:	c3                   	ret    

c010445f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010445f:	f3 0f 1e fb          	endbr32 
c0104463:	55                   	push   %ebp
c0104464:	89 e5                	mov    %esp,%ebp
c0104466:	57                   	push   %edi
c0104467:	56                   	push   %esi
c0104468:	53                   	push   %ebx
c0104469:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010446c:	c7 04 24 30 71 10 c0 	movl   $0xc0107130,(%esp)
c0104473:	e8 52 be ff ff       	call   c01002ca <cprintf>
    size_t left, right = 0, perm;
c0104478:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010447f:	e9 fa 00 00 00       	jmp    c010457e <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104487:	89 04 24             	mov    %eax,(%esp)
c010448a:	e8 d4 fe ff ff       	call   c0104363 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010448f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104492:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104495:	29 d1                	sub    %edx,%ecx
c0104497:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104499:	89 d6                	mov    %edx,%esi
c010449b:	c1 e6 16             	shl    $0x16,%esi
c010449e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01044a1:	89 d3                	mov    %edx,%ebx
c01044a3:	c1 e3 16             	shl    $0x16,%ebx
c01044a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01044a9:	89 d1                	mov    %edx,%ecx
c01044ab:	c1 e1 16             	shl    $0x16,%ecx
c01044ae:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01044b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01044b4:	29 d7                	sub    %edx,%edi
c01044b6:	89 fa                	mov    %edi,%edx
c01044b8:	89 44 24 14          	mov    %eax,0x14(%esp)
c01044bc:	89 74 24 10          	mov    %esi,0x10(%esp)
c01044c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01044c4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01044c8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01044cc:	c7 04 24 61 71 10 c0 	movl   $0xc0107161,(%esp)
c01044d3:	e8 f2 bd ff ff       	call   c01002ca <cprintf>
        size_t l, r = left * NPTEENTRY;
c01044d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01044db:	c1 e0 0a             	shl    $0xa,%eax
c01044de:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01044e1:	eb 54                	jmp    c0104537 <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01044e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01044e6:	89 04 24             	mov    %eax,(%esp)
c01044e9:	e8 75 fe ff ff       	call   c0104363 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01044ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01044f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01044f4:	29 d1                	sub    %edx,%ecx
c01044f6:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01044f8:	89 d6                	mov    %edx,%esi
c01044fa:	c1 e6 0c             	shl    $0xc,%esi
c01044fd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104500:	89 d3                	mov    %edx,%ebx
c0104502:	c1 e3 0c             	shl    $0xc,%ebx
c0104505:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104508:	89 d1                	mov    %edx,%ecx
c010450a:	c1 e1 0c             	shl    $0xc,%ecx
c010450d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104510:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104513:	29 d7                	sub    %edx,%edi
c0104515:	89 fa                	mov    %edi,%edx
c0104517:	89 44 24 14          	mov    %eax,0x14(%esp)
c010451b:	89 74 24 10          	mov    %esi,0x10(%esp)
c010451f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104523:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104527:	89 54 24 04          	mov    %edx,0x4(%esp)
c010452b:	c7 04 24 80 71 10 c0 	movl   $0xc0107180,(%esp)
c0104532:	e8 93 bd ff ff       	call   c01002ca <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104537:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010453c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010453f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104542:	89 d3                	mov    %edx,%ebx
c0104544:	c1 e3 0a             	shl    $0xa,%ebx
c0104547:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010454a:	89 d1                	mov    %edx,%ecx
c010454c:	c1 e1 0a             	shl    $0xa,%ecx
c010454f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104552:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104556:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104559:	89 54 24 10          	mov    %edx,0x10(%esp)
c010455d:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104561:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104565:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104569:	89 0c 24             	mov    %ecx,(%esp)
c010456c:	e8 38 fe ff ff       	call   c01043a9 <get_pgtable_items>
c0104571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104578:	0f 85 65 ff ff ff    	jne    c01044e3 <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010457e:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104583:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104586:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104589:	89 54 24 14          	mov    %edx,0x14(%esp)
c010458d:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104590:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104594:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104598:	89 44 24 08          	mov    %eax,0x8(%esp)
c010459c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01045a3:	00 
c01045a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01045ab:	e8 f9 fd ff ff       	call   c01043a9 <get_pgtable_items>
c01045b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01045b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01045b7:	0f 85 c7 fe ff ff    	jne    c0104484 <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01045bd:	c7 04 24 a4 71 10 c0 	movl   $0xc01071a4,(%esp)
c01045c4:	e8 01 bd ff ff       	call   c01002ca <cprintf>
}
c01045c9:	90                   	nop
c01045ca:	83 c4 4c             	add    $0x4c,%esp
c01045cd:	5b                   	pop    %ebx
c01045ce:	5e                   	pop    %esi
c01045cf:	5f                   	pop    %edi
c01045d0:	5d                   	pop    %ebp
c01045d1:	c3                   	ret    

c01045d2 <page2ppn>:
page2ppn(struct Page *page) { 
c01045d2:	55                   	push   %ebp
c01045d3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01045d5:	a1 78 df 11 c0       	mov    0xc011df78,%eax
c01045da:	8b 55 08             	mov    0x8(%ebp),%edx
c01045dd:	29 c2                	sub    %eax,%edx
c01045df:	89 d0                	mov    %edx,%eax
c01045e1:	c1 f8 02             	sar    $0x2,%eax
c01045e4:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01045ea:	5d                   	pop    %ebp
c01045eb:	c3                   	ret    

c01045ec <page2pa>:
page2pa(struct Page *page) {
c01045ec:	55                   	push   %ebp
c01045ed:	89 e5                	mov    %esp,%ebp
c01045ef:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01045f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01045f5:	89 04 24             	mov    %eax,(%esp)
c01045f8:	e8 d5 ff ff ff       	call   c01045d2 <page2ppn>
c01045fd:	c1 e0 0c             	shl    $0xc,%eax
}
c0104600:	c9                   	leave  
c0104601:	c3                   	ret    

c0104602 <page_ref>:
page_ref(struct Page *page) {
c0104602:	55                   	push   %ebp
c0104603:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104605:	8b 45 08             	mov    0x8(%ebp),%eax
c0104608:	8b 00                	mov    (%eax),%eax
}
c010460a:	5d                   	pop    %ebp
c010460b:	c3                   	ret    

c010460c <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c010460c:	55                   	push   %ebp
c010460d:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010460f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104612:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104615:	89 10                	mov    %edx,(%eax)
}
c0104617:	90                   	nop
c0104618:	5d                   	pop    %ebp
c0104619:	c3                   	ret    

c010461a <default_init>:
#define nr_free (free_area.nr_free)

// LAB2 EXERCISE 1: 19335286

// REWRITE default_init
static void default_init(void){
c010461a:	f3 0f 1e fb          	endbr32 
c010461e:	55                   	push   %ebp
c010461f:	89 e5                	mov    %esp,%ebp
c0104621:	83 ec 10             	sub    $0x10,%esp
c0104624:	c7 45 fc 7c df 11 c0 	movl   $0xc011df7c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010462b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010462e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104631:	89 50 04             	mov    %edx,0x4(%eax)
c0104634:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104637:	8b 50 04             	mov    0x4(%eax),%edx
c010463a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010463d:	89 10                	mov    %edx,(%eax)
}
c010463f:	90                   	nop
	list_init(&free_list);
	nr_free = 0;
c0104640:	c7 05 84 df 11 c0 00 	movl   $0x0,0xc011df84
c0104647:	00 00 00 
}
c010464a:	90                   	nop
c010464b:	c9                   	leave  
c010464c:	c3                   	ret    

c010464d <default_init_memmap>:

// REWRITE default_init_memmap
static void default_init_memmap(struct Page *base, size_t n){
c010464d:	f3 0f 1e fb          	endbr32 
c0104651:	55                   	push   %ebp
c0104652:	89 e5                	mov    %esp,%ebp
c0104654:	83 ec 58             	sub    $0x58,%esp
	assert(n > 0);
c0104657:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010465b:	75 24                	jne    c0104681 <default_init_memmap+0x34>
c010465d:	c7 44 24 0c d8 71 10 	movl   $0xc01071d8,0xc(%esp)
c0104664:	c0 
c0104665:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010466c:	c0 
c010466d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0104674:	00 
c0104675:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010467c:	e8 b5 bd ff ff       	call   c0100436 <__panic>
	
	// 初始化空闲块首部的页base
	assert(PageReserved(base)); // 检查base标志位
c0104681:	8b 45 08             	mov    0x8(%ebp),%eax
c0104684:	83 c0 04             	add    $0x4,%eax
c0104687:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c010468e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104691:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104694:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104697:	0f a3 10             	bt     %edx,(%eax)
c010469a:	19 c0                	sbb    %eax,%eax
c010469c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c010469f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01046a3:	0f 95 c0             	setne  %al
c01046a6:	0f b6 c0             	movzbl %al,%eax
c01046a9:	85 c0                	test   %eax,%eax
c01046ab:	75 24                	jne    c01046d1 <default_init_memmap+0x84>
c01046ad:	c7 44 24 0c 09 72 10 	movl   $0xc0107209,0xc(%esp)
c01046b4:	c0 
c01046b5:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01046bc:	c0 
c01046bd:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c01046c4:	00 
c01046c5:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01046cc:	e8 65 bd ff ff       	call   c0100436 <__panic>
	base->flags = 0;
c01046d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	base->property = n; // 设置base指向的页为空闲块首部
c01046db:	8b 45 08             	mov    0x8(%ebp),%eax
c01046de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046e1:	89 50 08             	mov    %edx,0x8(%eax)
	set_page_ref(base, 0); // 置为ref为0
c01046e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01046eb:	00 
c01046ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ef:	89 04 24             	mov    %eax,(%esp)
c01046f2:	e8 15 ff ff ff       	call   c010460c <set_page_ref>
    SetPageProperty(base); // 设置base指向的页为空闲块首部
c01046f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01046fa:	83 c0 04             	add    $0x4,%eax
c01046fd:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0104704:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104707:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010470a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010470d:	0f ab 10             	bts    %edx,(%eax)
}
c0104710:	90                   	nop
    
    // 便历、初始化非空闲块首部的页
    struct Page *t = NULL; 
c0104711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (t = base + 1; t < base + n; t ++) {
c0104718:	8b 45 08             	mov    0x8(%ebp),%eax
c010471b:	83 c0 14             	add    $0x14,%eax
c010471e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104721:	eb 7d                	jmp    c01047a0 <default_init_memmap+0x153>
        assert(PageReserved(t)); // 由于函数pmm_init已赋值保留位为0,这里仅需测试保留位是否被正确置0。
c0104723:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104726:	83 c0 04             	add    $0x4,%eax
c0104729:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104730:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104733:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104736:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104739:	0f a3 10             	bt     %edx,(%eax)
c010473c:	19 c0                	sbb    %eax,%eax
c010473e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0104741:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0104745:	0f 95 c0             	setne  %al
c0104748:	0f b6 c0             	movzbl %al,%eax
c010474b:	85 c0                	test   %eax,%eax
c010474d:	75 24                	jne    c0104773 <default_init_memmap+0x126>
c010474f:	c7 44 24 0c 1c 72 10 	movl   $0xc010721c,0xc(%esp)
c0104756:	c0 
c0104757:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010475e:	c0 
c010475f:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c0104766:	00 
c0104767:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010476e:	e8 c3 bc ff ff       	call   c0100436 <__panic>
        t->flags = t->property = 0; // 设置该页不是空闲块首部
c0104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104776:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104780:	8b 50 08             	mov    0x8(%eax),%edx
c0104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104786:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(t, 0); // 置为ref为0
c0104789:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104790:	00 
c0104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104794:	89 04 24             	mov    %eax,(%esp)
c0104797:	e8 70 fe ff ff       	call   c010460c <set_page_ref>
    for (t = base + 1; t < base + n; t ++) {
c010479c:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01047a0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047a3:	89 d0                	mov    %edx,%eax
c01047a5:	c1 e0 02             	shl    $0x2,%eax
c01047a8:	01 d0                	add    %edx,%eax
c01047aa:	c1 e0 02             	shl    $0x2,%eax
c01047ad:	89 c2                	mov    %eax,%edx
c01047af:	8b 45 08             	mov    0x8(%ebp),%eax
c01047b2:	01 d0                	add    %edx,%eax
c01047b4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01047b7:	0f 82 66 ff ff ff    	jb     c0104723 <default_init_memmap+0xd6>
    }
    
    // 更新链表
    nr_free += n; // 更新空闲页的总数
c01047bd:	8b 15 84 df 11 c0    	mov    0xc011df84,%edx
c01047c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047c6:	01 d0                	add    %edx,%eax
c01047c8:	a3 84 df 11 c0       	mov    %eax,0xc011df84
    list_add(&free_list, &(base->page_link)); // 将该空闲块插入页表（空闲块）链表中。
c01047cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d0:	83 c0 0c             	add    $0xc,%eax
c01047d3:	c7 45 d0 7c df 11 c0 	movl   $0xc011df7c,-0x30(%ebp)
c01047da:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01047dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01047e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01047e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01047e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01047e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01047ec:	8b 40 04             	mov    0x4(%eax),%eax
c01047ef:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01047f2:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01047f5:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01047f8:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01047fb:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01047fe:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104801:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104804:	89 10                	mov    %edx,(%eax)
c0104806:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104809:	8b 10                	mov    (%eax),%edx
c010480b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010480e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104811:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104814:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104817:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010481a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010481d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104820:	89 10                	mov    %edx,(%eax)
}
c0104822:	90                   	nop
}
c0104823:	90                   	nop
}
c0104824:	90                   	nop
}
c0104825:	90                   	nop
c0104826:	c9                   	leave  
c0104827:	c3                   	ret    

c0104828 <default_alloc_pages>:

// REWRITE default_alloc_pages
static struct Page* default_alloc_pages(size_t n){
c0104828:	f3 0f 1e fb          	endbr32 
c010482c:	55                   	push   %ebp
c010482d:	89 e5                	mov    %esp,%ebp
c010482f:	83 ec 78             	sub    $0x78,%esp
	assert(n > 0);
c0104832:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104836:	75 24                	jne    c010485c <default_alloc_pages+0x34>
c0104838:	c7 44 24 0c d8 71 10 	movl   $0xc01071d8,0xc(%esp)
c010483f:	c0 
c0104840:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104847:	c0 
c0104848:	c7 44 24 04 8b 00 00 	movl   $0x8b,0x4(%esp)
c010484f:	00 
c0104850:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104857:	e8 da bb ff ff       	call   c0100436 <__panic>
	if(n > nr_free){ 
c010485c:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c0104861:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104864:	76 0a                	jbe    c0104870 <default_alloc_pages+0x48>
		return NULL; // 如果请求页数比当前空闲总页数还大，拒绝请求	，但没必要结束程序
c0104866:	b8 00 00 00 00       	mov    $0x0,%eax
c010486b:	e9 b6 01 00 00       	jmp    c0104a26 <default_alloc_pages+0x1fe>
	}
	
	struct Page *p = NULL, *p2 = NULL;
c0104870:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104877:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010487e:	c7 45 e8 7c df 11 c0 	movl   $0xc011df7c,-0x18(%ebp)
    return listelm->next;
c0104885:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104888:	8b 40 04             	mov    0x4(%eax),%eax
	
	list_entry_t *l = list_next(&free_list);
c010488b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ // 从头遍历链表
c010488e:	eb 2b                	jmp    c01048bb <default_alloc_pages+0x93>
		 p = le2page(l, page_link);
c0104890:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104893:	83 e8 0c             	sub    $0xc,%eax
c0104896:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104899:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010489c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010489f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048a2:	8b 40 04             	mov    0x4(%eax),%eax
		 l = list_next(l); 
c01048a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		 if(p->property >= n){ // 找到第一个页数>=n的空闲块
c01048a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048ab:	8b 40 08             	mov    0x8(%eax),%eax
c01048ae:	39 45 08             	cmp    %eax,0x8(%ebp)
c01048b1:	77 08                	ja     c01048bb <default_alloc_pages+0x93>
		 	p2 = p; // p2即满足条件的空闲块首部页
c01048b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
		 	break;
c01048b9:	eb 09                	jmp    c01048c4 <default_alloc_pages+0x9c>
    while (l != &free_list){ // 从头遍历链表
c01048bb:	81 7d f0 7c df 11 c0 	cmpl   $0xc011df7c,-0x10(%ebp)
c01048c2:	75 cc                	jne    c0104890 <default_alloc_pages+0x68>
		 }
	}
	
	if(p2 != NULL){
c01048c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048c8:	0f 84 55 01 00 00    	je     c0104a23 <default_alloc_pages+0x1fb>
		if(p2->property == n){ // p2空闲块大小刚好等于所需页数
c01048ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d1:	8b 40 08             	mov    0x8(%eax),%eax
c01048d4:	39 45 08             	cmp    %eax,0x8(%ebp)
c01048d7:	75 58                	jne    c0104931 <default_alloc_pages+0x109>
			nr_free -= n;
c01048d9:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c01048de:	2b 45 08             	sub    0x8(%ebp),%eax
c01048e1:	a3 84 df 11 c0       	mov    %eax,0xc011df84
			ClearPageProperty(p2);
c01048e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048e9:	83 c0 04             	add    $0x4,%eax
c01048ec:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01048f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01048f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01048f9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01048fc:	0f b3 10             	btr    %edx,(%eax)
}
c01048ff:	90                   	nop
			list_del(&(p2->page_link)); // 将p2从链表中删除
c0104900:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104903:	83 c0 0c             	add    $0xc,%eax
c0104906:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104909:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010490c:	8b 40 04             	mov    0x4(%eax),%eax
c010490f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104912:	8b 12                	mov    (%edx),%edx
c0104914:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104917:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010491a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010491d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104920:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104923:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104926:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104929:	89 10                	mov    %edx,(%eax)
}
c010492b:	90                   	nop
}
c010492c:	e9 f2 00 00 00       	jmp    c0104a23 <default_alloc_pages+0x1fb>
		}
		else if(p2->property > n){ // p2空闲块大小大于所需页数
c0104931:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104934:	8b 40 08             	mov    0x8(%eax),%eax
c0104937:	39 45 08             	cmp    %eax,0x8(%ebp)
c010493a:	0f 83 e3 00 00 00    	jae    c0104a23 <default_alloc_pages+0x1fb>
			p = p2 + n; // 剩下的页组合在一起变成p，修改p的属性，重新加入链表
c0104940:	8b 55 08             	mov    0x8(%ebp),%edx
c0104943:	89 d0                	mov    %edx,%eax
c0104945:	c1 e0 02             	shl    $0x2,%eax
c0104948:	01 d0                	add    %edx,%eax
c010494a:	c1 e0 02             	shl    $0x2,%eax
c010494d:	89 c2                	mov    %eax,%edx
c010494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104952:	01 d0                	add    %edx,%eax
c0104954:	89 45 ec             	mov    %eax,-0x14(%ebp)
			p->property = p2->property - n;
c0104957:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495a:	8b 40 08             	mov    0x8(%eax),%eax
c010495d:	2b 45 08             	sub    0x8(%ebp),%eax
c0104960:	89 c2                	mov    %eax,%edx
c0104962:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104965:	89 50 08             	mov    %edx,0x8(%eax)
			SetPageProperty(p);
c0104968:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010496b:	83 c0 04             	add    $0x4,%eax
c010496e:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0104975:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104978:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010497b:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010497e:	0f ab 10             	bts    %edx,(%eax)
}
c0104981:	90                   	nop
			nr_free -= n;
c0104982:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c0104987:	2b 45 08             	sub    0x8(%ebp),%eax
c010498a:	a3 84 df 11 c0       	mov    %eax,0xc011df84
			ClearPageProperty(p2);
c010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104992:	83 c0 04             	add    $0x4,%eax
c0104995:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c010499c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010499f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01049a2:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01049a5:	0f b3 10             	btr    %edx,(%eax)
}
c01049a8:	90                   	nop
			list_add_after(&(p2->page_link), &(p->page_link));
c01049a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049ac:	83 c0 0c             	add    $0xc,%eax
c01049af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049b2:	83 c2 0c             	add    $0xc,%edx
c01049b5:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01049b8:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_add(elm, listelm, listelm->next);
c01049bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01049be:	8b 40 04             	mov    0x4(%eax),%eax
c01049c1:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01049c4:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01049c7:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01049ca:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c01049cd:	89 45 b0             	mov    %eax,-0x50(%ebp)
    prev->next = next->prev = elm;
c01049d0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01049d3:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01049d6:	89 10                	mov    %edx,(%eax)
c01049d8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01049db:	8b 10                	mov    (%eax),%edx
c01049dd:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01049e0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01049e3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01049e6:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01049e9:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01049ec:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01049ef:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01049f2:	89 10                	mov    %edx,(%eax)
}
c01049f4:	90                   	nop
}
c01049f5:	90                   	nop
			list_del(&(p2->page_link)); // 将p2从链表中删除
c01049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f9:	83 c0 0c             	add    $0xc,%eax
c01049fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c01049ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104a02:	8b 40 04             	mov    0x4(%eax),%eax
c0104a05:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104a08:	8b 12                	mov    (%edx),%edx
c0104a0a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0104a0d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c0104a10:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104a13:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104a16:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104a19:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104a1c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104a1f:	89 10                	mov    %edx,(%eax)
}
c0104a21:	90                   	nop
}
c0104a22:	90                   	nop
			//list_add(&free_list, &(p->page_link)); // 将p加入链表
		}
	}
	return p2;
c0104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104a26:	c9                   	leave  
c0104a27:	c3                   	ret    

c0104a28 <default_free_pages>:

// REWRITE default_free_pages
static void default_free_pages(struct Page *base, size_t n){ // base~base+n 是归还给空闲链表的页
c0104a28:	f3 0f 1e fb          	endbr32 
c0104a2c:	55                   	push   %ebp
c0104a2d:	89 e5                	mov    %esp,%ebp
c0104a2f:	81 ec 98 00 00 00    	sub    $0x98,%esp
	assert(n > 0);
c0104a35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104a39:	75 24                	jne    c0104a5f <default_free_pages+0x37>
c0104a3b:	c7 44 24 0c d8 71 10 	movl   $0xc01071d8,0xc(%esp)
c0104a42:	c0 
c0104a43:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104a4a:	c0 
c0104a4b:	c7 44 24 04 b2 00 00 	movl   $0xb2,0x4(%esp)
c0104a52:	00 
c0104a53:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104a5a:	e8 d7 b9 ff ff       	call   c0100436 <__panic>
	// 清空内容
	for(struct Page *i = base; i < base + n; i++){
c0104a5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a62:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104a65:	e9 c1 00 00 00       	jmp    c0104b2b <default_free_pages+0x103>
		assert(!PageReserved(i)); 
c0104a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a6d:	83 c0 04             	add    $0x4,%eax
c0104a70:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104a7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a7d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104a80:	0f a3 10             	bt     %edx,(%eax)
c0104a83:	19 c0                	sbb    %eax,%eax
c0104a85:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0104a88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104a8c:	0f 95 c0             	setne  %al
c0104a8f:	0f b6 c0             	movzbl %al,%eax
c0104a92:	85 c0                	test   %eax,%eax
c0104a94:	74 24                	je     c0104aba <default_free_pages+0x92>
c0104a96:	c7 44 24 0c 2c 72 10 	movl   $0xc010722c,0xc(%esp)
c0104a9d:	c0 
c0104a9e:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104aa5:	c0 
c0104aa6:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0104aad:	00 
c0104aae:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104ab5:	e8 7c b9 ff ff       	call   c0100436 <__panic>
		assert(!PageProperty(i));
c0104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104abd:	83 c0 04             	add    $0x4,%eax
c0104ac0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0104ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104acd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104ad0:	0f a3 10             	bt     %edx,(%eax)
c0104ad3:	19 c0                	sbb    %eax,%eax
c0104ad5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    return oldbit != 0;
c0104ad8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0104adc:	0f 95 c0             	setne  %al
c0104adf:	0f b6 c0             	movzbl %al,%eax
c0104ae2:	85 c0                	test   %eax,%eax
c0104ae4:	74 24                	je     c0104b0a <default_free_pages+0xe2>
c0104ae6:	c7 44 24 0c 3d 72 10 	movl   $0xc010723d,0xc(%esp)
c0104aed:	c0 
c0104aee:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104af5:	c0 
c0104af6:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0104afd:	00 
c0104afe:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104b05:	e8 2c b9 ff ff       	call   c0100436 <__panic>
		i->flags = 0;
c0104b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b0d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		set_page_ref(i, 0);
c0104b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b1b:	00 
c0104b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b1f:	89 04 24             	mov    %eax,(%esp)
c0104b22:	e8 e5 fa ff ff       	call   c010460c <set_page_ref>
	for(struct Page *i = base; i < base + n; i++){
c0104b27:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b2e:	89 d0                	mov    %edx,%eax
c0104b30:	c1 e0 02             	shl    $0x2,%eax
c0104b33:	01 d0                	add    %edx,%eax
c0104b35:	c1 e0 02             	shl    $0x2,%eax
c0104b38:	89 c2                	mov    %eax,%edx
c0104b3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b3d:	01 d0                	add    %edx,%eax
c0104b3f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104b42:	0f 82 22 ff ff ff    	jb     c0104a6a <default_free_pages+0x42>
	}
	
	// 四种情况：两个块合并（前后和后前）、三个块合并、单独成块
	struct Page *p = NULL;
c0104b48:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	
	nr_free += n;
c0104b4f:	8b 15 84 df 11 c0    	mov    0xc011df84,%edx
c0104b55:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b58:	01 d0                	add    %edx,%eax
c0104b5a:	a3 84 df 11 c0       	mov    %eax,0xc011df84
	SetPageProperty(base);
c0104b5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b62:	83 c0 04             	add    $0x4,%eax
c0104b65:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0104b6c:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b6f:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104b72:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104b75:	0f ab 10             	bts    %edx,(%eax)
}
c0104b78:	90                   	nop
	base->property = n;
c0104b79:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b7f:	89 50 08             	mov    %edx,0x8(%eax)
c0104b82:	c7 45 d0 7c df 11 c0 	movl   $0xc011df7c,-0x30(%ebp)
    return listelm->next;
c0104b89:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b8c:	8b 40 04             	mov    0x4(%eax),%eax

    list_entry_t *l = list_next(&free_list);
c0104b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list) { // 遍历，合并
c0104b92:	e9 0e 01 00 00       	jmp    c0104ca5 <default_free_pages+0x27d>
        p = le2page(l, page_link); 
c0104b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b9a:	83 e8 0c             	sub    $0xc,%eax
c0104b9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104ba0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ba3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104ba6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104ba9:	8b 40 04             	mov    0x4(%eax),%eax
        l = list_next(l);       
c0104bac:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) { // base 合并 p
c0104baf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bb2:	8b 50 08             	mov    0x8(%eax),%edx
c0104bb5:	89 d0                	mov    %edx,%eax
c0104bb7:	c1 e0 02             	shl    $0x2,%eax
c0104bba:	01 d0                	add    %edx,%eax
c0104bbc:	c1 e0 02             	shl    $0x2,%eax
c0104bbf:	89 c2                	mov    %eax,%edx
c0104bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bc4:	01 d0                	add    %edx,%eax
c0104bc6:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104bc9:	75 5d                	jne    c0104c28 <default_free_pages+0x200>
        	ClearPageProperty(p);
c0104bcb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bce:	83 c0 04             	add    $0x4,%eax
c0104bd1:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0104bd8:	89 45 b0             	mov    %eax,-0x50(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104bdb:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104bde:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104be1:	0f b3 10             	btr    %edx,(%eax)
}
c0104be4:	90                   	nop
            base->property += p->property;
c0104be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104be8:	8b 50 08             	mov    0x8(%eax),%edx
c0104beb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bee:	8b 40 08             	mov    0x8(%eax),%eax
c0104bf1:	01 c2                	add    %eax,%edx
c0104bf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bf6:	89 50 08             	mov    %edx,0x8(%eax)
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
c0104bf9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bfc:	83 c0 0c             	add    $0xc,%eax
c0104bff:	89 45 c0             	mov    %eax,-0x40(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104c02:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104c05:	8b 40 04             	mov    0x4(%eax),%eax
c0104c08:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104c0b:	8b 12                	mov    (%edx),%edx
c0104c0d:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0104c10:	89 45 b8             	mov    %eax,-0x48(%ebp)
    prev->next = next;
c0104c13:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104c16:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104c19:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104c1c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104c1f:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104c22:	89 10                	mov    %edx,(%eax)
}
c0104c24:	90                   	nop
}
c0104c25:	90                   	nop
c0104c26:	eb 7d                	jmp    c0104ca5 <default_free_pages+0x27d>
        }
        else if (p + p->property == base) { // p 合并 base
c0104c28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c2b:	8b 50 08             	mov    0x8(%eax),%edx
c0104c2e:	89 d0                	mov    %edx,%eax
c0104c30:	c1 e0 02             	shl    $0x2,%eax
c0104c33:	01 d0                	add    %edx,%eax
c0104c35:	c1 e0 02             	shl    $0x2,%eax
c0104c38:	89 c2                	mov    %eax,%edx
c0104c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c3d:	01 d0                	add    %edx,%eax
c0104c3f:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104c42:	75 61                	jne    c0104ca5 <default_free_pages+0x27d>
        	ClearPageProperty(base);
c0104c44:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c47:	83 c0 04             	add    $0x4,%eax
c0104c4a:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0104c51:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104c54:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c57:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104c5a:	0f b3 10             	btr    %edx,(%eax)
}
c0104c5d:	90                   	nop
            p->property += base->property;
c0104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c61:	8b 50 08             	mov    0x8(%eax),%edx
c0104c64:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c67:	8b 40 08             	mov    0x8(%eax),%eax
c0104c6a:	01 c2                	add    %eax,%edx
c0104c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c6f:	89 50 08             	mov    %edx,0x8(%eax)
            list_del(&(p->page_link)); // 断开被合并的块在free_list的链接
c0104c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c75:	83 c0 0c             	add    $0xc,%eax
c0104c78:	89 45 ac             	mov    %eax,-0x54(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104c7b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104c7e:	8b 40 04             	mov    0x4(%eax),%eax
c0104c81:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104c84:	8b 12                	mov    (%edx),%edx
c0104c86:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0104c89:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    prev->next = next;
c0104c8c:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104c8f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104c92:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104c95:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104c98:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104c9b:	89 10                	mov    %edx,(%eax)
}
c0104c9d:	90                   	nop
}
c0104c9e:	90                   	nop
            base = p; // 更新 base 为 p
c0104c9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ca2:	89 45 08             	mov    %eax,0x8(%ebp)
    while (l != &free_list) { // 遍历，合并
c0104ca5:	81 7d f0 7c df 11 c0 	cmpl   $0xc011df7c,-0x10(%ebp)
c0104cac:	0f 85 e5 fe ff ff    	jne    c0104b97 <default_free_pages+0x16f>
c0104cb2:	c7 45 98 7c df 11 c0 	movl   $0xc011df7c,-0x68(%ebp)
    return listelm->next;
c0104cb9:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104cbc:	8b 40 04             	mov    0x4(%eax),%eax
        }
    }
    
    l = list_next(&free_list);
c0104cbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ //遍历，找位置按序插入
c0104cc2:	eb 34                	jmp    c0104cf8 <default_free_pages+0x2d0>
        p = le2page(l, page_link);
c0104cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cc7:	83 e8 0c             	sub    $0xc,%eax
c0104cca:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (base + base->property < p){
c0104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd0:	8b 50 08             	mov    0x8(%eax),%edx
c0104cd3:	89 d0                	mov    %edx,%eax
c0104cd5:	c1 e0 02             	shl    $0x2,%eax
c0104cd8:	01 d0                	add    %edx,%eax
c0104cda:	c1 e0 02             	shl    $0x2,%eax
c0104cdd:	89 c2                	mov    %eax,%edx
c0104cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ce2:	01 d0                	add    %edx,%eax
c0104ce4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104ce7:	77 1a                	ja     c0104d03 <default_free_pages+0x2db>
c0104ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cec:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104cef:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104cf2:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        l = list_next(l);   
c0104cf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (l != &free_list){ //遍历，找位置按序插入
c0104cf8:	81 7d f0 7c df 11 c0 	cmpl   $0xc011df7c,-0x10(%ebp)
c0104cff:	75 c3                	jne    c0104cc4 <default_free_pages+0x29c>
c0104d01:	eb 01                	jmp    c0104d04 <default_free_pages+0x2dc>
            break;
c0104d03:	90                   	nop
    }
    list_add_before(l, &(base->page_link)); // 若free_list为空可直接插入base
c0104d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d07:	8d 50 0c             	lea    0xc(%eax),%edx
c0104d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d0d:	89 45 90             	mov    %eax,-0x70(%ebp)
c0104d10:	89 55 8c             	mov    %edx,-0x74(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104d13:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104d16:	8b 00                	mov    (%eax),%eax
c0104d18:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104d1b:	89 55 88             	mov    %edx,-0x78(%ebp)
c0104d1e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104d21:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104d24:	89 45 80             	mov    %eax,-0x80(%ebp)
    prev->next = next->prev = elm;
c0104d27:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104d2a:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104d2d:	89 10                	mov    %edx,(%eax)
c0104d2f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104d32:	8b 10                	mov    (%eax),%edx
c0104d34:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104d37:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104d3a:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104d3d:	8b 55 80             	mov    -0x80(%ebp),%edx
c0104d40:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104d43:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104d46:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104d49:	89 10                	mov    %edx,(%eax)
}
c0104d4b:	90                   	nop
}
c0104d4c:	90                   	nop
}
c0104d4d:	90                   	nop
c0104d4e:	c9                   	leave  
c0104d4f:	c3                   	ret    

c0104d50 <default_nr_free_pages>:
    list_add(&free_list, &(base->page_link)); //不对，插入过程要保证有序，不能直接插入链表头
}
*/

static size_t
default_nr_free_pages(void) {
c0104d50:	f3 0f 1e fb          	endbr32 
c0104d54:	55                   	push   %ebp
c0104d55:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104d57:	a1 84 df 11 c0       	mov    0xc011df84,%eax
}
c0104d5c:	5d                   	pop    %ebp
c0104d5d:	c3                   	ret    

c0104d5e <basic_check>:

static void
basic_check(void) {
c0104d5e:	f3 0f 1e fb          	endbr32 
c0104d62:	55                   	push   %ebp
c0104d63:	89 e5                	mov    %esp,%ebp
c0104d65:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104d68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d72:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d78:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104d7b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d82:	e8 fc e0 ff ff       	call   c0102e83 <alloc_pages>
c0104d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d8e:	75 24                	jne    c0104db4 <basic_check+0x56>
c0104d90:	c7 44 24 0c 4e 72 10 	movl   $0xc010724e,0xc(%esp)
c0104d97:	c0 
c0104d98:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104d9f:	c0 
c0104da0:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c0104da7:	00 
c0104da8:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104daf:	e8 82 b6 ff ff       	call   c0100436 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104db4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104dbb:	e8 c3 e0 ff ff       	call   c0102e83 <alloc_pages>
c0104dc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104dc3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104dc7:	75 24                	jne    c0104ded <basic_check+0x8f>
c0104dc9:	c7 44 24 0c 6a 72 10 	movl   $0xc010726a,0xc(%esp)
c0104dd0:	c0 
c0104dd1:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104dd8:	c0 
c0104dd9:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
c0104de0:	00 
c0104de1:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104de8:	e8 49 b6 ff ff       	call   c0100436 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104ded:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104df4:	e8 8a e0 ff ff       	call   c0102e83 <alloc_pages>
c0104df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104dfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e00:	75 24                	jne    c0104e26 <basic_check+0xc8>
c0104e02:	c7 44 24 0c 86 72 10 	movl   $0xc0107286,0xc(%esp)
c0104e09:	c0 
c0104e0a:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104e11:	c0 
c0104e12:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0104e19:	00 
c0104e1a:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104e21:	e8 10 b6 ff ff       	call   c0100436 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e29:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104e2c:	74 10                	je     c0104e3e <basic_check+0xe0>
c0104e2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e34:	74 08                	je     c0104e3e <basic_check+0xe0>
c0104e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e3c:	75 24                	jne    c0104e62 <basic_check+0x104>
c0104e3e:	c7 44 24 0c a4 72 10 	movl   $0xc01072a4,0xc(%esp)
c0104e45:	c0 
c0104e46:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104e4d:	c0 
c0104e4e:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0104e55:	00 
c0104e56:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104e5d:	e8 d4 b5 ff ff       	call   c0100436 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104e62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e65:	89 04 24             	mov    %eax,(%esp)
c0104e68:	e8 95 f7 ff ff       	call   c0104602 <page_ref>
c0104e6d:	85 c0                	test   %eax,%eax
c0104e6f:	75 1e                	jne    c0104e8f <basic_check+0x131>
c0104e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e74:	89 04 24             	mov    %eax,(%esp)
c0104e77:	e8 86 f7 ff ff       	call   c0104602 <page_ref>
c0104e7c:	85 c0                	test   %eax,%eax
c0104e7e:	75 0f                	jne    c0104e8f <basic_check+0x131>
c0104e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e83:	89 04 24             	mov    %eax,(%esp)
c0104e86:	e8 77 f7 ff ff       	call   c0104602 <page_ref>
c0104e8b:	85 c0                	test   %eax,%eax
c0104e8d:	74 24                	je     c0104eb3 <basic_check+0x155>
c0104e8f:	c7 44 24 0c c8 72 10 	movl   $0xc01072c8,0xc(%esp)
c0104e96:	c0 
c0104e97:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104e9e:	c0 
c0104e9f:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0104ea6:	00 
c0104ea7:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104eae:	e8 83 b5 ff ff       	call   c0100436 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104eb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104eb6:	89 04 24             	mov    %eax,(%esp)
c0104eb9:	e8 2e f7 ff ff       	call   c01045ec <page2pa>
c0104ebe:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104ec4:	c1 e2 0c             	shl    $0xc,%edx
c0104ec7:	39 d0                	cmp    %edx,%eax
c0104ec9:	72 24                	jb     c0104eef <basic_check+0x191>
c0104ecb:	c7 44 24 0c 04 73 10 	movl   $0xc0107304,0xc(%esp)
c0104ed2:	c0 
c0104ed3:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104eda:	c0 
c0104edb:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0104ee2:	00 
c0104ee3:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104eea:	e8 47 b5 ff ff       	call   c0100436 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ef2:	89 04 24             	mov    %eax,(%esp)
c0104ef5:	e8 f2 f6 ff ff       	call   c01045ec <page2pa>
c0104efa:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104f00:	c1 e2 0c             	shl    $0xc,%edx
c0104f03:	39 d0                	cmp    %edx,%eax
c0104f05:	72 24                	jb     c0104f2b <basic_check+0x1cd>
c0104f07:	c7 44 24 0c 21 73 10 	movl   $0xc0107321,0xc(%esp)
c0104f0e:	c0 
c0104f0f:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104f16:	c0 
c0104f17:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0104f1e:	00 
c0104f1f:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104f26:	e8 0b b5 ff ff       	call   c0100436 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f2e:	89 04 24             	mov    %eax,(%esp)
c0104f31:	e8 b6 f6 ff ff       	call   c01045ec <page2pa>
c0104f36:	8b 15 80 de 11 c0    	mov    0xc011de80,%edx
c0104f3c:	c1 e2 0c             	shl    $0xc,%edx
c0104f3f:	39 d0                	cmp    %edx,%eax
c0104f41:	72 24                	jb     c0104f67 <basic_check+0x209>
c0104f43:	c7 44 24 0c 3e 73 10 	movl   $0xc010733e,0xc(%esp)
c0104f4a:	c0 
c0104f4b:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104f52:	c0 
c0104f53:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c0104f5a:	00 
c0104f5b:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104f62:	e8 cf b4 ff ff       	call   c0100436 <__panic>

    list_entry_t free_list_store = free_list;
c0104f67:	a1 7c df 11 c0       	mov    0xc011df7c,%eax
c0104f6c:	8b 15 80 df 11 c0    	mov    0xc011df80,%edx
c0104f72:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104f75:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104f78:	c7 45 dc 7c df 11 c0 	movl   $0xc011df7c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104f7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f82:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104f85:	89 50 04             	mov    %edx,0x4(%eax)
c0104f88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f8b:	8b 50 04             	mov    0x4(%eax),%edx
c0104f8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f91:	89 10                	mov    %edx,(%eax)
}
c0104f93:	90                   	nop
c0104f94:	c7 45 e0 7c df 11 c0 	movl   $0xc011df7c,-0x20(%ebp)
    return list->next == list;
c0104f9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f9e:	8b 40 04             	mov    0x4(%eax),%eax
c0104fa1:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104fa4:	0f 94 c0             	sete   %al
c0104fa7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104faa:	85 c0                	test   %eax,%eax
c0104fac:	75 24                	jne    c0104fd2 <basic_check+0x274>
c0104fae:	c7 44 24 0c 5b 73 10 	movl   $0xc010735b,0xc(%esp)
c0104fb5:	c0 
c0104fb6:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0104fbd:	c0 
c0104fbe:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c0104fc5:	00 
c0104fc6:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0104fcd:	e8 64 b4 ff ff       	call   c0100436 <__panic>

    unsigned int nr_free_store = nr_free;
c0104fd2:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c0104fd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104fda:	c7 05 84 df 11 c0 00 	movl   $0x0,0xc011df84
c0104fe1:	00 00 00 

    assert(alloc_page() == NULL);
c0104fe4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104feb:	e8 93 de ff ff       	call   c0102e83 <alloc_pages>
c0104ff0:	85 c0                	test   %eax,%eax
c0104ff2:	74 24                	je     c0105018 <basic_check+0x2ba>
c0104ff4:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c0104ffb:	c0 
c0104ffc:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105003:	c0 
c0105004:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c010500b:	00 
c010500c:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105013:	e8 1e b4 ff ff       	call   c0100436 <__panic>

    free_page(p0);
c0105018:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010501f:	00 
c0105020:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105023:	89 04 24             	mov    %eax,(%esp)
c0105026:	e8 94 de ff ff       	call   c0102ebf <free_pages>
    free_page(p1);
c010502b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105032:	00 
c0105033:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105036:	89 04 24             	mov    %eax,(%esp)
c0105039:	e8 81 de ff ff       	call   c0102ebf <free_pages>
    free_page(p2);
c010503e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105045:	00 
c0105046:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105049:	89 04 24             	mov    %eax,(%esp)
c010504c:	e8 6e de ff ff       	call   c0102ebf <free_pages>
    assert(nr_free == 3);
c0105051:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c0105056:	83 f8 03             	cmp    $0x3,%eax
c0105059:	74 24                	je     c010507f <basic_check+0x321>
c010505b:	c7 44 24 0c 87 73 10 	movl   $0xc0107387,0xc(%esp)
c0105062:	c0 
c0105063:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010506a:	c0 
c010506b:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0105072:	00 
c0105073:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010507a:	e8 b7 b3 ff ff       	call   c0100436 <__panic>

    assert((p0 = alloc_page()) != NULL);
c010507f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105086:	e8 f8 dd ff ff       	call   c0102e83 <alloc_pages>
c010508b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010508e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105092:	75 24                	jne    c01050b8 <basic_check+0x35a>
c0105094:	c7 44 24 0c 4e 72 10 	movl   $0xc010724e,0xc(%esp)
c010509b:	c0 
c010509c:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01050a3:	c0 
c01050a4:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
c01050ab:	00 
c01050ac:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01050b3:	e8 7e b3 ff ff       	call   c0100436 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01050b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050bf:	e8 bf dd ff ff       	call   c0102e83 <alloc_pages>
c01050c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01050cb:	75 24                	jne    c01050f1 <basic_check+0x393>
c01050cd:	c7 44 24 0c 6a 72 10 	movl   $0xc010726a,0xc(%esp)
c01050d4:	c0 
c01050d5:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01050dc:	c0 
c01050dd:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c01050e4:	00 
c01050e5:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01050ec:	e8 45 b3 ff ff       	call   c0100436 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01050f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050f8:	e8 86 dd ff ff       	call   c0102e83 <alloc_pages>
c01050fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105100:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105104:	75 24                	jne    c010512a <basic_check+0x3cc>
c0105106:	c7 44 24 0c 86 72 10 	movl   $0xc0107286,0xc(%esp)
c010510d:	c0 
c010510e:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105115:	c0 
c0105116:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c010511d:	00 
c010511e:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105125:	e8 0c b3 ff ff       	call   c0100436 <__panic>

    assert(alloc_page() == NULL);
c010512a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105131:	e8 4d dd ff ff       	call   c0102e83 <alloc_pages>
c0105136:	85 c0                	test   %eax,%eax
c0105138:	74 24                	je     c010515e <basic_check+0x400>
c010513a:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c0105141:	c0 
c0105142:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105149:	c0 
c010514a:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0105151:	00 
c0105152:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105159:	e8 d8 b2 ff ff       	call   c0100436 <__panic>

    free_page(p0);
c010515e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105165:	00 
c0105166:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105169:	89 04 24             	mov    %eax,(%esp)
c010516c:	e8 4e dd ff ff       	call   c0102ebf <free_pages>
c0105171:	c7 45 d8 7c df 11 c0 	movl   $0xc011df7c,-0x28(%ebp)
c0105178:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010517b:	8b 40 04             	mov    0x4(%eax),%eax
c010517e:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105181:	0f 94 c0             	sete   %al
c0105184:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105187:	85 c0                	test   %eax,%eax
c0105189:	74 24                	je     c01051af <basic_check+0x451>
c010518b:	c7 44 24 0c 94 73 10 	movl   $0xc0107394,0xc(%esp)
c0105192:	c0 
c0105193:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010519a:	c0 
c010519b:	c7 44 24 04 5b 01 00 	movl   $0x15b,0x4(%esp)
c01051a2:	00 
c01051a3:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01051aa:	e8 87 b2 ff ff       	call   c0100436 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01051af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051b6:	e8 c8 dc ff ff       	call   c0102e83 <alloc_pages>
c01051bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01051be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051c1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01051c4:	74 24                	je     c01051ea <basic_check+0x48c>
c01051c6:	c7 44 24 0c ac 73 10 	movl   $0xc01073ac,0xc(%esp)
c01051cd:	c0 
c01051ce:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01051d5:	c0 
c01051d6:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
c01051dd:	00 
c01051de:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01051e5:	e8 4c b2 ff ff       	call   c0100436 <__panic>
    assert(alloc_page() == NULL);
c01051ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051f1:	e8 8d dc ff ff       	call   c0102e83 <alloc_pages>
c01051f6:	85 c0                	test   %eax,%eax
c01051f8:	74 24                	je     c010521e <basic_check+0x4c0>
c01051fa:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c0105201:	c0 
c0105202:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105209:	c0 
c010520a:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
c0105211:	00 
c0105212:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105219:	e8 18 b2 ff ff       	call   c0100436 <__panic>

    assert(nr_free == 0);
c010521e:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c0105223:	85 c0                	test   %eax,%eax
c0105225:	74 24                	je     c010524b <basic_check+0x4ed>
c0105227:	c7 44 24 0c c5 73 10 	movl   $0xc01073c5,0xc(%esp)
c010522e:	c0 
c010522f:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105236:	c0 
c0105237:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c010523e:	00 
c010523f:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105246:	e8 eb b1 ff ff       	call   c0100436 <__panic>
    free_list = free_list_store;
c010524b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010524e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105251:	a3 7c df 11 c0       	mov    %eax,0xc011df7c
c0105256:	89 15 80 df 11 c0    	mov    %edx,0xc011df80
    nr_free = nr_free_store;
c010525c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010525f:	a3 84 df 11 c0       	mov    %eax,0xc011df84

    free_page(p);
c0105264:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010526b:	00 
c010526c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010526f:	89 04 24             	mov    %eax,(%esp)
c0105272:	e8 48 dc ff ff       	call   c0102ebf <free_pages>
    free_page(p1);
c0105277:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010527e:	00 
c010527f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105282:	89 04 24             	mov    %eax,(%esp)
c0105285:	e8 35 dc ff ff       	call   c0102ebf <free_pages>
    free_page(p2);
c010528a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105291:	00 
c0105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105295:	89 04 24             	mov    %eax,(%esp)
c0105298:	e8 22 dc ff ff       	call   c0102ebf <free_pages>
}
c010529d:	90                   	nop
c010529e:	c9                   	leave  
c010529f:	c3                   	ret    

c01052a0 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01052a0:	f3 0f 1e fb          	endbr32 
c01052a4:	55                   	push   %ebp
c01052a5:	89 e5                	mov    %esp,%ebp
c01052a7:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01052ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01052b4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01052bb:	c7 45 ec 7c df 11 c0 	movl   $0xc011df7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01052c2:	eb 6a                	jmp    c010532e <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
c01052c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052c7:	83 e8 0c             	sub    $0xc,%eax
c01052ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c01052cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052d0:	83 c0 04             	add    $0x4,%eax
c01052d3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01052da:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01052dd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01052e0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01052e3:	0f a3 10             	bt     %edx,(%eax)
c01052e6:	19 c0                	sbb    %eax,%eax
c01052e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01052eb:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01052ef:	0f 95 c0             	setne  %al
c01052f2:	0f b6 c0             	movzbl %al,%eax
c01052f5:	85 c0                	test   %eax,%eax
c01052f7:	75 24                	jne    c010531d <default_check+0x7d>
c01052f9:	c7 44 24 0c d2 73 10 	movl   $0xc01073d2,0xc(%esp)
c0105300:	c0 
c0105301:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105308:	c0 
c0105309:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
c0105310:	00 
c0105311:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105318:	e8 19 b1 ff ff       	call   c0100436 <__panic>
        count ++, total += p->property;
c010531d:	ff 45 f4             	incl   -0xc(%ebp)
c0105320:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105323:	8b 50 08             	mov    0x8(%eax),%edx
c0105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105329:	01 d0                	add    %edx,%eax
c010532b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010532e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105331:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c0105334:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105337:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010533a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010533d:	81 7d ec 7c df 11 c0 	cmpl   $0xc011df7c,-0x14(%ebp)
c0105344:	0f 85 7a ff ff ff    	jne    c01052c4 <default_check+0x24>
    }
    assert(total == nr_free_pages());
c010534a:	e8 a7 db ff ff       	call   c0102ef6 <nr_free_pages>
c010534f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105352:	39 d0                	cmp    %edx,%eax
c0105354:	74 24                	je     c010537a <default_check+0xda>
c0105356:	c7 44 24 0c e2 73 10 	movl   $0xc01073e2,0xc(%esp)
c010535d:	c0 
c010535e:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105365:	c0 
c0105366:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c010536d:	00 
c010536e:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105375:	e8 bc b0 ff ff       	call   c0100436 <__panic>

    basic_check();
c010537a:	e8 df f9 ff ff       	call   c0104d5e <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010537f:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105386:	e8 f8 da ff ff       	call   c0102e83 <alloc_pages>
c010538b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c010538e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105392:	75 24                	jne    c01053b8 <default_check+0x118>
c0105394:	c7 44 24 0c fb 73 10 	movl   $0xc01073fb,0xc(%esp)
c010539b:	c0 
c010539c:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01053a3:	c0 
c01053a4:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c01053ab:	00 
c01053ac:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01053b3:	e8 7e b0 ff ff       	call   c0100436 <__panic>
    assert(!PageProperty(p0));
c01053b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053bb:	83 c0 04             	add    $0x4,%eax
c01053be:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c01053c5:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053c8:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01053cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01053ce:	0f a3 10             	bt     %edx,(%eax)
c01053d1:	19 c0                	sbb    %eax,%eax
c01053d3:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c01053d6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01053da:	0f 95 c0             	setne  %al
c01053dd:	0f b6 c0             	movzbl %al,%eax
c01053e0:	85 c0                	test   %eax,%eax
c01053e2:	74 24                	je     c0105408 <default_check+0x168>
c01053e4:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c01053eb:	c0 
c01053ec:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01053f3:	c0 
c01053f4:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
c01053fb:	00 
c01053fc:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105403:	e8 2e b0 ff ff       	call   c0100436 <__panic>

    list_entry_t free_list_store = free_list;
c0105408:	a1 7c df 11 c0       	mov    0xc011df7c,%eax
c010540d:	8b 15 80 df 11 c0    	mov    0xc011df80,%edx
c0105413:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105416:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105419:	c7 45 b0 7c df 11 c0 	movl   $0xc011df7c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c0105420:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105423:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105426:	89 50 04             	mov    %edx,0x4(%eax)
c0105429:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010542c:	8b 50 04             	mov    0x4(%eax),%edx
c010542f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0105432:	89 10                	mov    %edx,(%eax)
}
c0105434:	90                   	nop
c0105435:	c7 45 b4 7c df 11 c0 	movl   $0xc011df7c,-0x4c(%ebp)
    return list->next == list;
c010543c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010543f:	8b 40 04             	mov    0x4(%eax),%eax
c0105442:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c0105445:	0f 94 c0             	sete   %al
c0105448:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010544b:	85 c0                	test   %eax,%eax
c010544d:	75 24                	jne    c0105473 <default_check+0x1d3>
c010544f:	c7 44 24 0c 5b 73 10 	movl   $0xc010735b,0xc(%esp)
c0105456:	c0 
c0105457:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010545e:	c0 
c010545f:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0105466:	00 
c0105467:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010546e:	e8 c3 af ff ff       	call   c0100436 <__panic>
    assert(alloc_page() == NULL);
c0105473:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010547a:	e8 04 da ff ff       	call   c0102e83 <alloc_pages>
c010547f:	85 c0                	test   %eax,%eax
c0105481:	74 24                	je     c01054a7 <default_check+0x207>
c0105483:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c010548a:	c0 
c010548b:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105492:	c0 
c0105493:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
c010549a:	00 
c010549b:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01054a2:	e8 8f af ff ff       	call   c0100436 <__panic>

    unsigned int nr_free_store = nr_free;
c01054a7:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c01054ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c01054af:	c7 05 84 df 11 c0 00 	movl   $0x0,0xc011df84
c01054b6:	00 00 00 

    free_pages(p0 + 2, 3);
c01054b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054bc:	83 c0 28             	add    $0x28,%eax
c01054bf:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01054c6:	00 
c01054c7:	89 04 24             	mov    %eax,(%esp)
c01054ca:	e8 f0 d9 ff ff       	call   c0102ebf <free_pages>
    assert(alloc_pages(4) == NULL);
c01054cf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01054d6:	e8 a8 d9 ff ff       	call   c0102e83 <alloc_pages>
c01054db:	85 c0                	test   %eax,%eax
c01054dd:	74 24                	je     c0105503 <default_check+0x263>
c01054df:	c7 44 24 0c 18 74 10 	movl   $0xc0107418,0xc(%esp)
c01054e6:	c0 
c01054e7:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01054ee:	c0 
c01054ef:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c01054f6:	00 
c01054f7:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01054fe:	e8 33 af ff ff       	call   c0100436 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105503:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105506:	83 c0 28             	add    $0x28,%eax
c0105509:	83 c0 04             	add    $0x4,%eax
c010550c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0105513:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105516:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105519:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010551c:	0f a3 10             	bt     %edx,(%eax)
c010551f:	19 c0                	sbb    %eax,%eax
c0105521:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0105524:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0105528:	0f 95 c0             	setne  %al
c010552b:	0f b6 c0             	movzbl %al,%eax
c010552e:	85 c0                	test   %eax,%eax
c0105530:	74 0e                	je     c0105540 <default_check+0x2a0>
c0105532:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105535:	83 c0 28             	add    $0x28,%eax
c0105538:	8b 40 08             	mov    0x8(%eax),%eax
c010553b:	83 f8 03             	cmp    $0x3,%eax
c010553e:	74 24                	je     c0105564 <default_check+0x2c4>
c0105540:	c7 44 24 0c 30 74 10 	movl   $0xc0107430,0xc(%esp)
c0105547:	c0 
c0105548:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010554f:	c0 
c0105550:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0105557:	00 
c0105558:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010555f:	e8 d2 ae ff ff       	call   c0100436 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105564:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010556b:	e8 13 d9 ff ff       	call   c0102e83 <alloc_pages>
c0105570:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105577:	75 24                	jne    c010559d <default_check+0x2fd>
c0105579:	c7 44 24 0c 5c 74 10 	movl   $0xc010745c,0xc(%esp)
c0105580:	c0 
c0105581:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105588:	c0 
c0105589:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0105590:	00 
c0105591:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105598:	e8 99 ae ff ff       	call   c0100436 <__panic>
    assert(alloc_page() == NULL);
c010559d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01055a4:	e8 da d8 ff ff       	call   c0102e83 <alloc_pages>
c01055a9:	85 c0                	test   %eax,%eax
c01055ab:	74 24                	je     c01055d1 <default_check+0x331>
c01055ad:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c01055b4:	c0 
c01055b5:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01055bc:	c0 
c01055bd:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c01055c4:	00 
c01055c5:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01055cc:	e8 65 ae ff ff       	call   c0100436 <__panic>
    assert(p0 + 2 == p1);
c01055d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055d4:	83 c0 28             	add    $0x28,%eax
c01055d7:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01055da:	74 24                	je     c0105600 <default_check+0x360>
c01055dc:	c7 44 24 0c 7a 74 10 	movl   $0xc010747a,0xc(%esp)
c01055e3:	c0 
c01055e4:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01055eb:	c0 
c01055ec:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c01055f3:	00 
c01055f4:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01055fb:	e8 36 ae ff ff       	call   c0100436 <__panic>

    p2 = p0 + 1;
c0105600:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105603:	83 c0 14             	add    $0x14,%eax
c0105606:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c0105609:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105610:	00 
c0105611:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105614:	89 04 24             	mov    %eax,(%esp)
c0105617:	e8 a3 d8 ff ff       	call   c0102ebf <free_pages>
    free_pages(p1, 3);
c010561c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105623:	00 
c0105624:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105627:	89 04 24             	mov    %eax,(%esp)
c010562a:	e8 90 d8 ff ff       	call   c0102ebf <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010562f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105632:	83 c0 04             	add    $0x4,%eax
c0105635:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010563c:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010563f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105642:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0105645:	0f a3 10             	bt     %edx,(%eax)
c0105648:	19 c0                	sbb    %eax,%eax
c010564a:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010564d:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105651:	0f 95 c0             	setne  %al
c0105654:	0f b6 c0             	movzbl %al,%eax
c0105657:	85 c0                	test   %eax,%eax
c0105659:	74 0b                	je     c0105666 <default_check+0x3c6>
c010565b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010565e:	8b 40 08             	mov    0x8(%eax),%eax
c0105661:	83 f8 01             	cmp    $0x1,%eax
c0105664:	74 24                	je     c010568a <default_check+0x3ea>
c0105666:	c7 44 24 0c 88 74 10 	movl   $0xc0107488,0xc(%esp)
c010566d:	c0 
c010566e:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c0105675:	c0 
c0105676:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c010567d:	00 
c010567e:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105685:	e8 ac ad ff ff       	call   c0100436 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010568a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010568d:	83 c0 04             	add    $0x4,%eax
c0105690:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105697:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010569a:	8b 45 90             	mov    -0x70(%ebp),%eax
c010569d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01056a0:	0f a3 10             	bt     %edx,(%eax)
c01056a3:	19 c0                	sbb    %eax,%eax
c01056a5:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c01056a8:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c01056ac:	0f 95 c0             	setne  %al
c01056af:	0f b6 c0             	movzbl %al,%eax
c01056b2:	85 c0                	test   %eax,%eax
c01056b4:	74 0b                	je     c01056c1 <default_check+0x421>
c01056b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01056b9:	8b 40 08             	mov    0x8(%eax),%eax
c01056bc:	83 f8 03             	cmp    $0x3,%eax
c01056bf:	74 24                	je     c01056e5 <default_check+0x445>
c01056c1:	c7 44 24 0c b0 74 10 	movl   $0xc01074b0,0xc(%esp)
c01056c8:	c0 
c01056c9:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01056d0:	c0 
c01056d1:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
c01056d8:	00 
c01056d9:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01056e0:	e8 51 ad ff ff       	call   c0100436 <__panic>
	
    assert((p0 = alloc_page()) == p2 - 1);
c01056e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01056ec:	e8 92 d7 ff ff       	call   c0102e83 <alloc_pages>
c01056f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056f7:	83 e8 14             	sub    $0x14,%eax
c01056fa:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01056fd:	74 24                	je     c0105723 <default_check+0x483>
c01056ff:	c7 44 24 0c d6 74 10 	movl   $0xc01074d6,0xc(%esp)
c0105706:	c0 
c0105707:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010570e:	c0 
c010570f:	c7 44 24 04 92 01 00 	movl   $0x192,0x4(%esp)
c0105716:	00 
c0105717:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010571e:	e8 13 ad ff ff       	call   c0100436 <__panic>
    free_page(p0);
c0105723:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010572a:	00 
c010572b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010572e:	89 04 24             	mov    %eax,(%esp)
c0105731:	e8 89 d7 ff ff       	call   c0102ebf <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0105736:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010573d:	e8 41 d7 ff ff       	call   c0102e83 <alloc_pages>
c0105742:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105745:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105748:	83 c0 14             	add    $0x14,%eax
c010574b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010574e:	74 24                	je     c0105774 <default_check+0x4d4>
c0105750:	c7 44 24 0c f4 74 10 	movl   $0xc01074f4,0xc(%esp)
c0105757:	c0 
c0105758:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010575f:	c0 
c0105760:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c0105767:	00 
c0105768:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010576f:	e8 c2 ac ff ff       	call   c0100436 <__panic>

    free_pages(p0, 2);
c0105774:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010577b:	00 
c010577c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010577f:	89 04 24             	mov    %eax,(%esp)
c0105782:	e8 38 d7 ff ff       	call   c0102ebf <free_pages>
    free_page(p2);
c0105787:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010578e:	00 
c010578f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105792:	89 04 24             	mov    %eax,(%esp)
c0105795:	e8 25 d7 ff ff       	call   c0102ebf <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010579a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01057a1:	e8 dd d6 ff ff       	call   c0102e83 <alloc_pages>
c01057a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01057a9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01057ad:	75 24                	jne    c01057d3 <default_check+0x533>
c01057af:	c7 44 24 0c 14 75 10 	movl   $0xc0107514,0xc(%esp)
c01057b6:	c0 
c01057b7:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01057be:	c0 
c01057bf:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
c01057c6:	00 
c01057c7:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01057ce:	e8 63 ac ff ff       	call   c0100436 <__panic>
    assert(alloc_page() == NULL);
c01057d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01057da:	e8 a4 d6 ff ff       	call   c0102e83 <alloc_pages>
c01057df:	85 c0                	test   %eax,%eax
c01057e1:	74 24                	je     c0105807 <default_check+0x567>
c01057e3:	c7 44 24 0c 72 73 10 	movl   $0xc0107372,0xc(%esp)
c01057ea:	c0 
c01057eb:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01057f2:	c0 
c01057f3:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c01057fa:	00 
c01057fb:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0105802:	e8 2f ac ff ff       	call   c0100436 <__panic>

    assert(nr_free == 0);
c0105807:	a1 84 df 11 c0       	mov    0xc011df84,%eax
c010580c:	85 c0                	test   %eax,%eax
c010580e:	74 24                	je     c0105834 <default_check+0x594>
c0105810:	c7 44 24 0c c5 73 10 	movl   $0xc01073c5,0xc(%esp)
c0105817:	c0 
c0105818:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c010581f:	c0 
c0105820:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
c0105827:	00 
c0105828:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c010582f:	e8 02 ac ff ff       	call   c0100436 <__panic>
    nr_free = nr_free_store;
c0105834:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105837:	a3 84 df 11 c0       	mov    %eax,0xc011df84

    free_list = free_list_store;
c010583c:	8b 45 80             	mov    -0x80(%ebp),%eax
c010583f:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105842:	a3 7c df 11 c0       	mov    %eax,0xc011df7c
c0105847:	89 15 80 df 11 c0    	mov    %edx,0xc011df80
    free_pages(p0, 5);
c010584d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105854:	00 
c0105855:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105858:	89 04 24             	mov    %eax,(%esp)
c010585b:	e8 5f d6 ff ff       	call   c0102ebf <free_pages>

    le = &free_list;
c0105860:	c7 45 ec 7c df 11 c0 	movl   $0xc011df7c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105867:	eb 1c                	jmp    c0105885 <default_check+0x5e5>
        struct Page *p = le2page(le, page_link);
c0105869:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010586c:	83 e8 0c             	sub    $0xc,%eax
c010586f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0105872:	ff 4d f4             	decl   -0xc(%ebp)
c0105875:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105878:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010587b:	8b 40 08             	mov    0x8(%eax),%eax
c010587e:	29 c2                	sub    %eax,%edx
c0105880:	89 d0                	mov    %edx,%eax
c0105882:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105885:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105888:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c010588b:	8b 45 88             	mov    -0x78(%ebp),%eax
c010588e:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0105891:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105894:	81 7d ec 7c df 11 c0 	cmpl   $0xc011df7c,-0x14(%ebp)
c010589b:	75 cc                	jne    c0105869 <default_check+0x5c9>
    }
    assert(count == 0);
c010589d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058a1:	74 24                	je     c01058c7 <default_check+0x627>
c01058a3:	c7 44 24 0c 32 75 10 	movl   $0xc0107532,0xc(%esp)
c01058aa:	c0 
c01058ab:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01058b2:	c0 
c01058b3:	c7 44 24 04 a7 01 00 	movl   $0x1a7,0x4(%esp)
c01058ba:	00 
c01058bb:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01058c2:	e8 6f ab ff ff       	call   c0100436 <__panic>
    assert(total == 0);
c01058c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058cb:	74 24                	je     c01058f1 <default_check+0x651>
c01058cd:	c7 44 24 0c 3d 75 10 	movl   $0xc010753d,0xc(%esp)
c01058d4:	c0 
c01058d5:	c7 44 24 08 de 71 10 	movl   $0xc01071de,0x8(%esp)
c01058dc:	c0 
c01058dd:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c01058e4:	00 
c01058e5:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c01058ec:	e8 45 ab ff ff       	call   c0100436 <__panic>
}
c01058f1:	90                   	nop
c01058f2:	c9                   	leave  
c01058f3:	c3                   	ret    

c01058f4 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01058f4:	f3 0f 1e fb          	endbr32 
c01058f8:	55                   	push   %ebp
c01058f9:	89 e5                	mov    %esp,%ebp
c01058fb:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01058fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105905:	eb 03                	jmp    c010590a <strlen+0x16>
        cnt ++;
c0105907:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c010590a:	8b 45 08             	mov    0x8(%ebp),%eax
c010590d:	8d 50 01             	lea    0x1(%eax),%edx
c0105910:	89 55 08             	mov    %edx,0x8(%ebp)
c0105913:	0f b6 00             	movzbl (%eax),%eax
c0105916:	84 c0                	test   %al,%al
c0105918:	75 ed                	jne    c0105907 <strlen+0x13>
    }
    return cnt;
c010591a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010591d:	c9                   	leave  
c010591e:	c3                   	ret    

c010591f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010591f:	f3 0f 1e fb          	endbr32 
c0105923:	55                   	push   %ebp
c0105924:	89 e5                	mov    %esp,%ebp
c0105926:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105929:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105930:	eb 03                	jmp    c0105935 <strnlen+0x16>
        cnt ++;
c0105932:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105935:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105938:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010593b:	73 10                	jae    c010594d <strnlen+0x2e>
c010593d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105940:	8d 50 01             	lea    0x1(%eax),%edx
c0105943:	89 55 08             	mov    %edx,0x8(%ebp)
c0105946:	0f b6 00             	movzbl (%eax),%eax
c0105949:	84 c0                	test   %al,%al
c010594b:	75 e5                	jne    c0105932 <strnlen+0x13>
    }
    return cnt;
c010594d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105950:	c9                   	leave  
c0105951:	c3                   	ret    

c0105952 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105952:	f3 0f 1e fb          	endbr32 
c0105956:	55                   	push   %ebp
c0105957:	89 e5                	mov    %esp,%ebp
c0105959:	57                   	push   %edi
c010595a:	56                   	push   %esi
c010595b:	83 ec 20             	sub    $0x20,%esp
c010595e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105961:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105964:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105967:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010596a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010596d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105970:	89 d1                	mov    %edx,%ecx
c0105972:	89 c2                	mov    %eax,%edx
c0105974:	89 ce                	mov    %ecx,%esi
c0105976:	89 d7                	mov    %edx,%edi
c0105978:	ac                   	lods   %ds:(%esi),%al
c0105979:	aa                   	stos   %al,%es:(%edi)
c010597a:	84 c0                	test   %al,%al
c010597c:	75 fa                	jne    c0105978 <strcpy+0x26>
c010597e:	89 fa                	mov    %edi,%edx
c0105980:	89 f1                	mov    %esi,%ecx
c0105982:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105985:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105988:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010598e:	83 c4 20             	add    $0x20,%esp
c0105991:	5e                   	pop    %esi
c0105992:	5f                   	pop    %edi
c0105993:	5d                   	pop    %ebp
c0105994:	c3                   	ret    

c0105995 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105995:	f3 0f 1e fb          	endbr32 
c0105999:	55                   	push   %ebp
c010599a:	89 e5                	mov    %esp,%ebp
c010599c:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010599f:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01059a5:	eb 1e                	jmp    c01059c5 <strncpy+0x30>
        if ((*p = *src) != '\0') {
c01059a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059aa:	0f b6 10             	movzbl (%eax),%edx
c01059ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01059b0:	88 10                	mov    %dl,(%eax)
c01059b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01059b5:	0f b6 00             	movzbl (%eax),%eax
c01059b8:	84 c0                	test   %al,%al
c01059ba:	74 03                	je     c01059bf <strncpy+0x2a>
            src ++;
c01059bc:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01059bf:	ff 45 fc             	incl   -0x4(%ebp)
c01059c2:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c01059c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01059c9:	75 dc                	jne    c01059a7 <strncpy+0x12>
    }
    return dst;
c01059cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01059ce:	c9                   	leave  
c01059cf:	c3                   	ret    

c01059d0 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01059d0:	f3 0f 1e fb          	endbr32 
c01059d4:	55                   	push   %ebp
c01059d5:	89 e5                	mov    %esp,%ebp
c01059d7:	57                   	push   %edi
c01059d8:	56                   	push   %esi
c01059d9:	83 ec 20             	sub    $0x20,%esp
c01059dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01059df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c01059e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059ee:	89 d1                	mov    %edx,%ecx
c01059f0:	89 c2                	mov    %eax,%edx
c01059f2:	89 ce                	mov    %ecx,%esi
c01059f4:	89 d7                	mov    %edx,%edi
c01059f6:	ac                   	lods   %ds:(%esi),%al
c01059f7:	ae                   	scas   %es:(%edi),%al
c01059f8:	75 08                	jne    c0105a02 <strcmp+0x32>
c01059fa:	84 c0                	test   %al,%al
c01059fc:	75 f8                	jne    c01059f6 <strcmp+0x26>
c01059fe:	31 c0                	xor    %eax,%eax
c0105a00:	eb 04                	jmp    c0105a06 <strcmp+0x36>
c0105a02:	19 c0                	sbb    %eax,%eax
c0105a04:	0c 01                	or     $0x1,%al
c0105a06:	89 fa                	mov    %edi,%edx
c0105a08:	89 f1                	mov    %esi,%ecx
c0105a0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a0d:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105a10:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105a13:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105a16:	83 c4 20             	add    $0x20,%esp
c0105a19:	5e                   	pop    %esi
c0105a1a:	5f                   	pop    %edi
c0105a1b:	5d                   	pop    %ebp
c0105a1c:	c3                   	ret    

c0105a1d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105a1d:	f3 0f 1e fb          	endbr32 
c0105a21:	55                   	push   %ebp
c0105a22:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a24:	eb 09                	jmp    c0105a2f <strncmp+0x12>
        n --, s1 ++, s2 ++;
c0105a26:	ff 4d 10             	decl   0x10(%ebp)
c0105a29:	ff 45 08             	incl   0x8(%ebp)
c0105a2c:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a33:	74 1a                	je     c0105a4f <strncmp+0x32>
c0105a35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a38:	0f b6 00             	movzbl (%eax),%eax
c0105a3b:	84 c0                	test   %al,%al
c0105a3d:	74 10                	je     c0105a4f <strncmp+0x32>
c0105a3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a42:	0f b6 10             	movzbl (%eax),%edx
c0105a45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a48:	0f b6 00             	movzbl (%eax),%eax
c0105a4b:	38 c2                	cmp    %al,%dl
c0105a4d:	74 d7                	je     c0105a26 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105a4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a53:	74 18                	je     c0105a6d <strncmp+0x50>
c0105a55:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a58:	0f b6 00             	movzbl (%eax),%eax
c0105a5b:	0f b6 d0             	movzbl %al,%edx
c0105a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a61:	0f b6 00             	movzbl (%eax),%eax
c0105a64:	0f b6 c0             	movzbl %al,%eax
c0105a67:	29 c2                	sub    %eax,%edx
c0105a69:	89 d0                	mov    %edx,%eax
c0105a6b:	eb 05                	jmp    c0105a72 <strncmp+0x55>
c0105a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105a72:	5d                   	pop    %ebp
c0105a73:	c3                   	ret    

c0105a74 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105a74:	f3 0f 1e fb          	endbr32 
c0105a78:	55                   	push   %ebp
c0105a79:	89 e5                	mov    %esp,%ebp
c0105a7b:	83 ec 04             	sub    $0x4,%esp
c0105a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a81:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105a84:	eb 13                	jmp    c0105a99 <strchr+0x25>
        if (*s == c) {
c0105a86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a89:	0f b6 00             	movzbl (%eax),%eax
c0105a8c:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105a8f:	75 05                	jne    c0105a96 <strchr+0x22>
            return (char *)s;
c0105a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a94:	eb 12                	jmp    c0105aa8 <strchr+0x34>
        }
        s ++;
c0105a96:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105a99:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a9c:	0f b6 00             	movzbl (%eax),%eax
c0105a9f:	84 c0                	test   %al,%al
c0105aa1:	75 e3                	jne    c0105a86 <strchr+0x12>
    }
    return NULL;
c0105aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105aa8:	c9                   	leave  
c0105aa9:	c3                   	ret    

c0105aaa <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105aaa:	f3 0f 1e fb          	endbr32 
c0105aae:	55                   	push   %ebp
c0105aaf:	89 e5                	mov    %esp,%ebp
c0105ab1:	83 ec 04             	sub    $0x4,%esp
c0105ab4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ab7:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105aba:	eb 0e                	jmp    c0105aca <strfind+0x20>
        if (*s == c) {
c0105abc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105abf:	0f b6 00             	movzbl (%eax),%eax
c0105ac2:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105ac5:	74 0f                	je     c0105ad6 <strfind+0x2c>
            break;
        }
        s ++;
c0105ac7:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105aca:	8b 45 08             	mov    0x8(%ebp),%eax
c0105acd:	0f b6 00             	movzbl (%eax),%eax
c0105ad0:	84 c0                	test   %al,%al
c0105ad2:	75 e8                	jne    c0105abc <strfind+0x12>
c0105ad4:	eb 01                	jmp    c0105ad7 <strfind+0x2d>
            break;
c0105ad6:	90                   	nop
    }
    return (char *)s;
c0105ad7:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105ada:	c9                   	leave  
c0105adb:	c3                   	ret    

c0105adc <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105adc:	f3 0f 1e fb          	endbr32 
c0105ae0:	55                   	push   %ebp
c0105ae1:	89 e5                	mov    %esp,%ebp
c0105ae3:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105ae6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105aed:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105af4:	eb 03                	jmp    c0105af9 <strtol+0x1d>
        s ++;
c0105af6:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105af9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105afc:	0f b6 00             	movzbl (%eax),%eax
c0105aff:	3c 20                	cmp    $0x20,%al
c0105b01:	74 f3                	je     c0105af6 <strtol+0x1a>
c0105b03:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b06:	0f b6 00             	movzbl (%eax),%eax
c0105b09:	3c 09                	cmp    $0x9,%al
c0105b0b:	74 e9                	je     c0105af6 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c0105b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b10:	0f b6 00             	movzbl (%eax),%eax
c0105b13:	3c 2b                	cmp    $0x2b,%al
c0105b15:	75 05                	jne    c0105b1c <strtol+0x40>
        s ++;
c0105b17:	ff 45 08             	incl   0x8(%ebp)
c0105b1a:	eb 14                	jmp    c0105b30 <strtol+0x54>
    }
    else if (*s == '-') {
c0105b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b1f:	0f b6 00             	movzbl (%eax),%eax
c0105b22:	3c 2d                	cmp    $0x2d,%al
c0105b24:	75 0a                	jne    c0105b30 <strtol+0x54>
        s ++, neg = 1;
c0105b26:	ff 45 08             	incl   0x8(%ebp)
c0105b29:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105b30:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b34:	74 06                	je     c0105b3c <strtol+0x60>
c0105b36:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105b3a:	75 22                	jne    c0105b5e <strtol+0x82>
c0105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b3f:	0f b6 00             	movzbl (%eax),%eax
c0105b42:	3c 30                	cmp    $0x30,%al
c0105b44:	75 18                	jne    c0105b5e <strtol+0x82>
c0105b46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b49:	40                   	inc    %eax
c0105b4a:	0f b6 00             	movzbl (%eax),%eax
c0105b4d:	3c 78                	cmp    $0x78,%al
c0105b4f:	75 0d                	jne    c0105b5e <strtol+0x82>
        s += 2, base = 16;
c0105b51:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105b55:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105b5c:	eb 29                	jmp    c0105b87 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c0105b5e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b62:	75 16                	jne    c0105b7a <strtol+0x9e>
c0105b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b67:	0f b6 00             	movzbl (%eax),%eax
c0105b6a:	3c 30                	cmp    $0x30,%al
c0105b6c:	75 0c                	jne    c0105b7a <strtol+0x9e>
        s ++, base = 8;
c0105b6e:	ff 45 08             	incl   0x8(%ebp)
c0105b71:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105b78:	eb 0d                	jmp    c0105b87 <strtol+0xab>
    }
    else if (base == 0) {
c0105b7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b7e:	75 07                	jne    c0105b87 <strtol+0xab>
        base = 10;
c0105b80:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105b87:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8a:	0f b6 00             	movzbl (%eax),%eax
c0105b8d:	3c 2f                	cmp    $0x2f,%al
c0105b8f:	7e 1b                	jle    c0105bac <strtol+0xd0>
c0105b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b94:	0f b6 00             	movzbl (%eax),%eax
c0105b97:	3c 39                	cmp    $0x39,%al
c0105b99:	7f 11                	jg     c0105bac <strtol+0xd0>
            dig = *s - '0';
c0105b9b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b9e:	0f b6 00             	movzbl (%eax),%eax
c0105ba1:	0f be c0             	movsbl %al,%eax
c0105ba4:	83 e8 30             	sub    $0x30,%eax
c0105ba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105baa:	eb 48                	jmp    c0105bf4 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0105baf:	0f b6 00             	movzbl (%eax),%eax
c0105bb2:	3c 60                	cmp    $0x60,%al
c0105bb4:	7e 1b                	jle    c0105bd1 <strtol+0xf5>
c0105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb9:	0f b6 00             	movzbl (%eax),%eax
c0105bbc:	3c 7a                	cmp    $0x7a,%al
c0105bbe:	7f 11                	jg     c0105bd1 <strtol+0xf5>
            dig = *s - 'a' + 10;
c0105bc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc3:	0f b6 00             	movzbl (%eax),%eax
c0105bc6:	0f be c0             	movsbl %al,%eax
c0105bc9:	83 e8 57             	sub    $0x57,%eax
c0105bcc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bcf:	eb 23                	jmp    c0105bf4 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd4:	0f b6 00             	movzbl (%eax),%eax
c0105bd7:	3c 40                	cmp    $0x40,%al
c0105bd9:	7e 3b                	jle    c0105c16 <strtol+0x13a>
c0105bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bde:	0f b6 00             	movzbl (%eax),%eax
c0105be1:	3c 5a                	cmp    $0x5a,%al
c0105be3:	7f 31                	jg     c0105c16 <strtol+0x13a>
            dig = *s - 'A' + 10;
c0105be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be8:	0f b6 00             	movzbl (%eax),%eax
c0105beb:	0f be c0             	movsbl %al,%eax
c0105bee:	83 e8 37             	sub    $0x37,%eax
c0105bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105bf7:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105bfa:	7d 19                	jge    c0105c15 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c0105bfc:	ff 45 08             	incl   0x8(%ebp)
c0105bff:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c02:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105c06:	89 c2                	mov    %eax,%edx
c0105c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c0b:	01 d0                	add    %edx,%eax
c0105c0d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0105c10:	e9 72 ff ff ff       	jmp    c0105b87 <strtol+0xab>
            break;
c0105c15:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105c16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c1a:	74 08                	je     c0105c24 <strtol+0x148>
        *endptr = (char *) s;
c0105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c22:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105c24:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105c28:	74 07                	je     c0105c31 <strtol+0x155>
c0105c2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c2d:	f7 d8                	neg    %eax
c0105c2f:	eb 03                	jmp    c0105c34 <strtol+0x158>
c0105c31:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105c34:	c9                   	leave  
c0105c35:	c3                   	ret    

c0105c36 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105c36:	f3 0f 1e fb          	endbr32 
c0105c3a:	55                   	push   %ebp
c0105c3b:	89 e5                	mov    %esp,%ebp
c0105c3d:	57                   	push   %edi
c0105c3e:	83 ec 24             	sub    $0x24,%esp
c0105c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c44:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105c47:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0105c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c4e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0105c51:	88 55 f7             	mov    %dl,-0x9(%ebp)
c0105c54:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c57:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105c5a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105c5d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105c61:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105c64:	89 d7                	mov    %edx,%edi
c0105c66:	f3 aa                	rep stos %al,%es:(%edi)
c0105c68:	89 fa                	mov    %edi,%edx
c0105c6a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105c6d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105c70:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105c73:	83 c4 24             	add    $0x24,%esp
c0105c76:	5f                   	pop    %edi
c0105c77:	5d                   	pop    %ebp
c0105c78:	c3                   	ret    

c0105c79 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105c79:	f3 0f 1e fb          	endbr32 
c0105c7d:	55                   	push   %ebp
c0105c7e:	89 e5                	mov    %esp,%ebp
c0105c80:	57                   	push   %edi
c0105c81:	56                   	push   %esi
c0105c82:	53                   	push   %ebx
c0105c83:	83 ec 30             	sub    $0x30,%esp
c0105c86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c89:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c92:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c95:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c9b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105c9e:	73 42                	jae    c0105ce2 <memmove+0x69>
c0105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ca3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ca6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ca9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105caf:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105cb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cb5:	c1 e8 02             	shr    $0x2,%eax
c0105cb8:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105cba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cc0:	89 d7                	mov    %edx,%edi
c0105cc2:	89 c6                	mov    %eax,%esi
c0105cc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105cc6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105cc9:	83 e1 03             	and    $0x3,%ecx
c0105ccc:	74 02                	je     c0105cd0 <memmove+0x57>
c0105cce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105cd0:	89 f0                	mov    %esi,%eax
c0105cd2:	89 fa                	mov    %edi,%edx
c0105cd4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105cd7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105cda:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0105ce0:	eb 36                	jmp    c0105d18 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105ce2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ce5:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105ce8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ceb:	01 c2                	add    %eax,%edx
c0105ced:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cf0:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cf6:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105cf9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105cfc:	89 c1                	mov    %eax,%ecx
c0105cfe:	89 d8                	mov    %ebx,%eax
c0105d00:	89 d6                	mov    %edx,%esi
c0105d02:	89 c7                	mov    %eax,%edi
c0105d04:	fd                   	std    
c0105d05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d07:	fc                   	cld    
c0105d08:	89 f8                	mov    %edi,%eax
c0105d0a:	89 f2                	mov    %esi,%edx
c0105d0c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105d0f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105d12:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0105d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105d18:	83 c4 30             	add    $0x30,%esp
c0105d1b:	5b                   	pop    %ebx
c0105d1c:	5e                   	pop    %esi
c0105d1d:	5f                   	pop    %edi
c0105d1e:	5d                   	pop    %ebp
c0105d1f:	c3                   	ret    

c0105d20 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105d20:	f3 0f 1e fb          	endbr32 
c0105d24:	55                   	push   %ebp
c0105d25:	89 e5                	mov    %esp,%ebp
c0105d27:	57                   	push   %edi
c0105d28:	56                   	push   %esi
c0105d29:	83 ec 20             	sub    $0x20,%esp
c0105d2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d32:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d35:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d38:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d3b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d41:	c1 e8 02             	shr    $0x2,%eax
c0105d44:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d4c:	89 d7                	mov    %edx,%edi
c0105d4e:	89 c6                	mov    %eax,%esi
c0105d50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d52:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105d55:	83 e1 03             	and    $0x3,%ecx
c0105d58:	74 02                	je     c0105d5c <memcpy+0x3c>
c0105d5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d5c:	89 f0                	mov    %esi,%eax
c0105d5e:	89 fa                	mov    %edi,%edx
c0105d60:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105d63:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105d66:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105d6c:	83 c4 20             	add    $0x20,%esp
c0105d6f:	5e                   	pop    %esi
c0105d70:	5f                   	pop    %edi
c0105d71:	5d                   	pop    %ebp
c0105d72:	c3                   	ret    

c0105d73 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105d73:	f3 0f 1e fb          	endbr32 
c0105d77:	55                   	push   %ebp
c0105d78:	89 e5                	mov    %esp,%ebp
c0105d7a:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105d7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d80:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105d83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d86:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105d89:	eb 2e                	jmp    c0105db9 <memcmp+0x46>
        if (*s1 != *s2) {
c0105d8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d8e:	0f b6 10             	movzbl (%eax),%edx
c0105d91:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105d94:	0f b6 00             	movzbl (%eax),%eax
c0105d97:	38 c2                	cmp    %al,%dl
c0105d99:	74 18                	je     c0105db3 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105d9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d9e:	0f b6 00             	movzbl (%eax),%eax
c0105da1:	0f b6 d0             	movzbl %al,%edx
c0105da4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105da7:	0f b6 00             	movzbl (%eax),%eax
c0105daa:	0f b6 c0             	movzbl %al,%eax
c0105dad:	29 c2                	sub    %eax,%edx
c0105daf:	89 d0                	mov    %edx,%eax
c0105db1:	eb 18                	jmp    c0105dcb <memcmp+0x58>
        }
        s1 ++, s2 ++;
c0105db3:	ff 45 fc             	incl   -0x4(%ebp)
c0105db6:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105db9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dbc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105dbf:	89 55 10             	mov    %edx,0x10(%ebp)
c0105dc2:	85 c0                	test   %eax,%eax
c0105dc4:	75 c5                	jne    c0105d8b <memcmp+0x18>
    }
    return 0;
c0105dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dcb:	c9                   	leave  
c0105dcc:	c3                   	ret    

c0105dcd <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105dcd:	f3 0f 1e fb          	endbr32 
c0105dd1:	55                   	push   %ebp
c0105dd2:	89 e5                	mov    %esp,%ebp
c0105dd4:	83 ec 58             	sub    $0x58,%esp
c0105dd7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dda:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105ddd:	8b 45 14             	mov    0x14(%ebp),%eax
c0105de0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105de3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105de6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105de9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105dec:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105def:	8b 45 18             	mov    0x18(%ebp),%eax
c0105df2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105df5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105df8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105dfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105dfe:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105e01:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e0b:	74 1c                	je     c0105e29 <printnum+0x5c>
c0105e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e10:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e15:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e18:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e1e:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e23:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e29:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e2f:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e32:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e35:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105e38:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e3e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e41:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105e44:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e47:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105e4a:	8b 45 18             	mov    0x18(%ebp),%eax
c0105e4d:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e52:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105e55:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105e58:	19 d1                	sbb    %edx,%ecx
c0105e5a:	72 4c                	jb     c0105ea8 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105e5c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105e5f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e62:	8b 45 20             	mov    0x20(%ebp),%eax
c0105e65:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105e69:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105e6d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105e70:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e77:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e7e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105e82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e89:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e8c:	89 04 24             	mov    %eax,(%esp)
c0105e8f:	e8 39 ff ff ff       	call   c0105dcd <printnum>
c0105e94:	eb 1b                	jmp    c0105eb1 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105e96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e9d:	8b 45 20             	mov    0x20(%ebp),%eax
c0105ea0:	89 04 24             	mov    %eax,(%esp)
c0105ea3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ea6:	ff d0                	call   *%eax
        while (-- width > 0)
c0105ea8:	ff 4d 1c             	decl   0x1c(%ebp)
c0105eab:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105eaf:	7f e5                	jg     c0105e96 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105eb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105eb4:	05 f8 75 10 c0       	add    $0xc01075f8,%eax
c0105eb9:	0f b6 00             	movzbl (%eax),%eax
c0105ebc:	0f be c0             	movsbl %al,%eax
c0105ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ec6:	89 04 24             	mov    %eax,(%esp)
c0105ec9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ecc:	ff d0                	call   *%eax
}
c0105ece:	90                   	nop
c0105ecf:	c9                   	leave  
c0105ed0:	c3                   	ret    

c0105ed1 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105ed1:	f3 0f 1e fb          	endbr32 
c0105ed5:	55                   	push   %ebp
c0105ed6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105ed8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105edc:	7e 14                	jle    c0105ef2 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c0105ede:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ee1:	8b 00                	mov    (%eax),%eax
c0105ee3:	8d 48 08             	lea    0x8(%eax),%ecx
c0105ee6:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ee9:	89 0a                	mov    %ecx,(%edx)
c0105eeb:	8b 50 04             	mov    0x4(%eax),%edx
c0105eee:	8b 00                	mov    (%eax),%eax
c0105ef0:	eb 30                	jmp    c0105f22 <getuint+0x51>
    }
    else if (lflag) {
c0105ef2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ef6:	74 16                	je     c0105f0e <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c0105ef8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105efb:	8b 00                	mov    (%eax),%eax
c0105efd:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f00:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f03:	89 0a                	mov    %ecx,(%edx)
c0105f05:	8b 00                	mov    (%eax),%eax
c0105f07:	ba 00 00 00 00       	mov    $0x0,%edx
c0105f0c:	eb 14                	jmp    c0105f22 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f11:	8b 00                	mov    (%eax),%eax
c0105f13:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f16:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f19:	89 0a                	mov    %ecx,(%edx)
c0105f1b:	8b 00                	mov    (%eax),%eax
c0105f1d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105f22:	5d                   	pop    %ebp
c0105f23:	c3                   	ret    

c0105f24 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105f24:	f3 0f 1e fb          	endbr32 
c0105f28:	55                   	push   %ebp
c0105f29:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105f2b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105f2f:	7e 14                	jle    c0105f45 <getint+0x21>
        return va_arg(*ap, long long);
c0105f31:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f34:	8b 00                	mov    (%eax),%eax
c0105f36:	8d 48 08             	lea    0x8(%eax),%ecx
c0105f39:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f3c:	89 0a                	mov    %ecx,(%edx)
c0105f3e:	8b 50 04             	mov    0x4(%eax),%edx
c0105f41:	8b 00                	mov    (%eax),%eax
c0105f43:	eb 28                	jmp    c0105f6d <getint+0x49>
    }
    else if (lflag) {
c0105f45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f49:	74 12                	je     c0105f5d <getint+0x39>
        return va_arg(*ap, long);
c0105f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4e:	8b 00                	mov    (%eax),%eax
c0105f50:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f53:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f56:	89 0a                	mov    %ecx,(%edx)
c0105f58:	8b 00                	mov    (%eax),%eax
c0105f5a:	99                   	cltd   
c0105f5b:	eb 10                	jmp    c0105f6d <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c0105f5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f60:	8b 00                	mov    (%eax),%eax
c0105f62:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f65:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f68:	89 0a                	mov    %ecx,(%edx)
c0105f6a:	8b 00                	mov    (%eax),%eax
c0105f6c:	99                   	cltd   
    }
}
c0105f6d:	5d                   	pop    %ebp
c0105f6e:	c3                   	ret    

c0105f6f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105f6f:	f3 0f 1e fb          	endbr32 
c0105f73:	55                   	push   %ebp
c0105f74:	89 e5                	mov    %esp,%ebp
c0105f76:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105f79:	8d 45 14             	lea    0x14(%ebp),%eax
c0105f7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f82:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105f86:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f89:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f90:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f94:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f97:	89 04 24             	mov    %eax,(%esp)
c0105f9a:	e8 03 00 00 00       	call   c0105fa2 <vprintfmt>
    va_end(ap);
}
c0105f9f:	90                   	nop
c0105fa0:	c9                   	leave  
c0105fa1:	c3                   	ret    

c0105fa2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105fa2:	f3 0f 1e fb          	endbr32 
c0105fa6:	55                   	push   %ebp
c0105fa7:	89 e5                	mov    %esp,%ebp
c0105fa9:	56                   	push   %esi
c0105faa:	53                   	push   %ebx
c0105fab:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105fae:	eb 17                	jmp    c0105fc7 <vprintfmt+0x25>
            if (ch == '\0') {
c0105fb0:	85 db                	test   %ebx,%ebx
c0105fb2:	0f 84 c0 03 00 00    	je     c0106378 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c0105fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fbf:	89 1c 24             	mov    %ebx,(%esp)
c0105fc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc5:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105fc7:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fca:	8d 50 01             	lea    0x1(%eax),%edx
c0105fcd:	89 55 10             	mov    %edx,0x10(%ebp)
c0105fd0:	0f b6 00             	movzbl (%eax),%eax
c0105fd3:	0f b6 d8             	movzbl %al,%ebx
c0105fd6:	83 fb 25             	cmp    $0x25,%ebx
c0105fd9:	75 d5                	jne    c0105fb0 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105fdb:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105fdf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105fe9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105fec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105ff3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ff6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105ff9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ffc:	8d 50 01             	lea    0x1(%eax),%edx
c0105fff:	89 55 10             	mov    %edx,0x10(%ebp)
c0106002:	0f b6 00             	movzbl (%eax),%eax
c0106005:	0f b6 d8             	movzbl %al,%ebx
c0106008:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010600b:	83 f8 55             	cmp    $0x55,%eax
c010600e:	0f 87 38 03 00 00    	ja     c010634c <vprintfmt+0x3aa>
c0106014:	8b 04 85 1c 76 10 c0 	mov    -0x3fef89e4(,%eax,4),%eax
c010601b:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010601e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106022:	eb d5                	jmp    c0105ff9 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0106024:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106028:	eb cf                	jmp    c0105ff9 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010602a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106031:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106034:	89 d0                	mov    %edx,%eax
c0106036:	c1 e0 02             	shl    $0x2,%eax
c0106039:	01 d0                	add    %edx,%eax
c010603b:	01 c0                	add    %eax,%eax
c010603d:	01 d8                	add    %ebx,%eax
c010603f:	83 e8 30             	sub    $0x30,%eax
c0106042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0106045:	8b 45 10             	mov    0x10(%ebp),%eax
c0106048:	0f b6 00             	movzbl (%eax),%eax
c010604b:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010604e:	83 fb 2f             	cmp    $0x2f,%ebx
c0106051:	7e 38                	jle    c010608b <vprintfmt+0xe9>
c0106053:	83 fb 39             	cmp    $0x39,%ebx
c0106056:	7f 33                	jg     c010608b <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c0106058:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c010605b:	eb d4                	jmp    c0106031 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010605d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106060:	8d 50 04             	lea    0x4(%eax),%edx
c0106063:	89 55 14             	mov    %edx,0x14(%ebp)
c0106066:	8b 00                	mov    (%eax),%eax
c0106068:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010606b:	eb 1f                	jmp    c010608c <vprintfmt+0xea>

        case '.':
            if (width < 0)
c010606d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106071:	79 86                	jns    c0105ff9 <vprintfmt+0x57>
                width = 0;
c0106073:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010607a:	e9 7a ff ff ff       	jmp    c0105ff9 <vprintfmt+0x57>

        case '#':
            altflag = 1;
c010607f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0106086:	e9 6e ff ff ff       	jmp    c0105ff9 <vprintfmt+0x57>
            goto process_precision;
c010608b:	90                   	nop

        process_precision:
            if (width < 0)
c010608c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106090:	0f 89 63 ff ff ff    	jns    c0105ff9 <vprintfmt+0x57>
                width = precision, precision = -1;
c0106096:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106099:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010609c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01060a3:	e9 51 ff ff ff       	jmp    c0105ff9 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01060a8:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01060ab:	e9 49 ff ff ff       	jmp    c0105ff9 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01060b0:	8b 45 14             	mov    0x14(%ebp),%eax
c01060b3:	8d 50 04             	lea    0x4(%eax),%edx
c01060b6:	89 55 14             	mov    %edx,0x14(%ebp)
c01060b9:	8b 00                	mov    (%eax),%eax
c01060bb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060be:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060c2:	89 04 24             	mov    %eax,(%esp)
c01060c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01060c8:	ff d0                	call   *%eax
            break;
c01060ca:	e9 a4 02 00 00       	jmp    c0106373 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01060cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01060d2:	8d 50 04             	lea    0x4(%eax),%edx
c01060d5:	89 55 14             	mov    %edx,0x14(%ebp)
c01060d8:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01060da:	85 db                	test   %ebx,%ebx
c01060dc:	79 02                	jns    c01060e0 <vprintfmt+0x13e>
                err = -err;
c01060de:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01060e0:	83 fb 06             	cmp    $0x6,%ebx
c01060e3:	7f 0b                	jg     c01060f0 <vprintfmt+0x14e>
c01060e5:	8b 34 9d dc 75 10 c0 	mov    -0x3fef8a24(,%ebx,4),%esi
c01060ec:	85 f6                	test   %esi,%esi
c01060ee:	75 23                	jne    c0106113 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c01060f0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01060f4:	c7 44 24 08 09 76 10 	movl   $0xc0107609,0x8(%esp)
c01060fb:	c0 
c01060fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106103:	8b 45 08             	mov    0x8(%ebp),%eax
c0106106:	89 04 24             	mov    %eax,(%esp)
c0106109:	e8 61 fe ff ff       	call   c0105f6f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010610e:	e9 60 02 00 00       	jmp    c0106373 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c0106113:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106117:	c7 44 24 08 12 76 10 	movl   $0xc0107612,0x8(%esp)
c010611e:	c0 
c010611f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106122:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106126:	8b 45 08             	mov    0x8(%ebp),%eax
c0106129:	89 04 24             	mov    %eax,(%esp)
c010612c:	e8 3e fe ff ff       	call   c0105f6f <printfmt>
            break;
c0106131:	e9 3d 02 00 00       	jmp    c0106373 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106136:	8b 45 14             	mov    0x14(%ebp),%eax
c0106139:	8d 50 04             	lea    0x4(%eax),%edx
c010613c:	89 55 14             	mov    %edx,0x14(%ebp)
c010613f:	8b 30                	mov    (%eax),%esi
c0106141:	85 f6                	test   %esi,%esi
c0106143:	75 05                	jne    c010614a <vprintfmt+0x1a8>
                p = "(null)";
c0106145:	be 15 76 10 c0       	mov    $0xc0107615,%esi
            }
            if (width > 0 && padc != '-') {
c010614a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010614e:	7e 76                	jle    c01061c6 <vprintfmt+0x224>
c0106150:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106154:	74 70                	je     c01061c6 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106156:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106159:	89 44 24 04          	mov    %eax,0x4(%esp)
c010615d:	89 34 24             	mov    %esi,(%esp)
c0106160:	e8 ba f7 ff ff       	call   c010591f <strnlen>
c0106165:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106168:	29 c2                	sub    %eax,%edx
c010616a:	89 d0                	mov    %edx,%eax
c010616c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010616f:	eb 16                	jmp    c0106187 <vprintfmt+0x1e5>
                    putch(padc, putdat);
c0106171:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106175:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106178:	89 54 24 04          	mov    %edx,0x4(%esp)
c010617c:	89 04 24             	mov    %eax,(%esp)
c010617f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106182:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106184:	ff 4d e8             	decl   -0x18(%ebp)
c0106187:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010618b:	7f e4                	jg     c0106171 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010618d:	eb 37                	jmp    c01061c6 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c010618f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106193:	74 1f                	je     c01061b4 <vprintfmt+0x212>
c0106195:	83 fb 1f             	cmp    $0x1f,%ebx
c0106198:	7e 05                	jle    c010619f <vprintfmt+0x1fd>
c010619a:	83 fb 7e             	cmp    $0x7e,%ebx
c010619d:	7e 15                	jle    c01061b4 <vprintfmt+0x212>
                    putch('?', putdat);
c010619f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061a2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061a6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01061ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01061b0:	ff d0                	call   *%eax
c01061b2:	eb 0f                	jmp    c01061c3 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c01061b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061bb:	89 1c 24             	mov    %ebx,(%esp)
c01061be:	8b 45 08             	mov    0x8(%ebp),%eax
c01061c1:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01061c3:	ff 4d e8             	decl   -0x18(%ebp)
c01061c6:	89 f0                	mov    %esi,%eax
c01061c8:	8d 70 01             	lea    0x1(%eax),%esi
c01061cb:	0f b6 00             	movzbl (%eax),%eax
c01061ce:	0f be d8             	movsbl %al,%ebx
c01061d1:	85 db                	test   %ebx,%ebx
c01061d3:	74 27                	je     c01061fc <vprintfmt+0x25a>
c01061d5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01061d9:	78 b4                	js     c010618f <vprintfmt+0x1ed>
c01061db:	ff 4d e4             	decl   -0x1c(%ebp)
c01061de:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01061e2:	79 ab                	jns    c010618f <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c01061e4:	eb 16                	jmp    c01061fc <vprintfmt+0x25a>
                putch(' ', putdat);
c01061e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061ed:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01061f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01061f7:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c01061f9:	ff 4d e8             	decl   -0x18(%ebp)
c01061fc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106200:	7f e4                	jg     c01061e6 <vprintfmt+0x244>
            }
            break;
c0106202:	e9 6c 01 00 00       	jmp    c0106373 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106207:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010620a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010620e:	8d 45 14             	lea    0x14(%ebp),%eax
c0106211:	89 04 24             	mov    %eax,(%esp)
c0106214:	e8 0b fd ff ff       	call   c0105f24 <getint>
c0106219:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010621c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010621f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106222:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106225:	85 d2                	test   %edx,%edx
c0106227:	79 26                	jns    c010624f <vprintfmt+0x2ad>
                putch('-', putdat);
c0106229:	8b 45 0c             	mov    0xc(%ebp),%eax
c010622c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106230:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106237:	8b 45 08             	mov    0x8(%ebp),%eax
c010623a:	ff d0                	call   *%eax
                num = -(long long)num;
c010623c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010623f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106242:	f7 d8                	neg    %eax
c0106244:	83 d2 00             	adc    $0x0,%edx
c0106247:	f7 da                	neg    %edx
c0106249:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010624c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010624f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106256:	e9 a8 00 00 00       	jmp    c0106303 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010625b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010625e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106262:	8d 45 14             	lea    0x14(%ebp),%eax
c0106265:	89 04 24             	mov    %eax,(%esp)
c0106268:	e8 64 fc ff ff       	call   c0105ed1 <getuint>
c010626d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106270:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106273:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010627a:	e9 84 00 00 00       	jmp    c0106303 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010627f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106282:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106286:	8d 45 14             	lea    0x14(%ebp),%eax
c0106289:	89 04 24             	mov    %eax,(%esp)
c010628c:	e8 40 fc ff ff       	call   c0105ed1 <getuint>
c0106291:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106294:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106297:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010629e:	eb 63                	jmp    c0106303 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c01062a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062a7:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01062ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01062b1:	ff d0                	call   *%eax
            putch('x', putdat);
c01062b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062ba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01062c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01062c4:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01062c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01062c9:	8d 50 04             	lea    0x4(%eax),%edx
c01062cc:	89 55 14             	mov    %edx,0x14(%ebp)
c01062cf:	8b 00                	mov    (%eax),%eax
c01062d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01062db:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01062e2:	eb 1f                	jmp    c0106303 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01062e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062eb:	8d 45 14             	lea    0x14(%ebp),%eax
c01062ee:	89 04 24             	mov    %eax,(%esp)
c01062f1:	e8 db fb ff ff       	call   c0105ed1 <getuint>
c01062f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01062fc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106303:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106307:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010630a:	89 54 24 18          	mov    %edx,0x18(%esp)
c010630e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106311:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106315:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106319:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010631c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010631f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106323:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106327:	8b 45 0c             	mov    0xc(%ebp),%eax
c010632a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010632e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106331:	89 04 24             	mov    %eax,(%esp)
c0106334:	e8 94 fa ff ff       	call   c0105dcd <printnum>
            break;
c0106339:	eb 38                	jmp    c0106373 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010633b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010633e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106342:	89 1c 24             	mov    %ebx,(%esp)
c0106345:	8b 45 08             	mov    0x8(%ebp),%eax
c0106348:	ff d0                	call   *%eax
            break;
c010634a:	eb 27                	jmp    c0106373 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010634c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010634f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106353:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010635a:	8b 45 08             	mov    0x8(%ebp),%eax
c010635d:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010635f:	ff 4d 10             	decl   0x10(%ebp)
c0106362:	eb 03                	jmp    c0106367 <vprintfmt+0x3c5>
c0106364:	ff 4d 10             	decl   0x10(%ebp)
c0106367:	8b 45 10             	mov    0x10(%ebp),%eax
c010636a:	48                   	dec    %eax
c010636b:	0f b6 00             	movzbl (%eax),%eax
c010636e:	3c 25                	cmp    $0x25,%al
c0106370:	75 f2                	jne    c0106364 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c0106372:	90                   	nop
    while (1) {
c0106373:	e9 36 fc ff ff       	jmp    c0105fae <vprintfmt+0xc>
                return;
c0106378:	90                   	nop
        }
    }
}
c0106379:	83 c4 40             	add    $0x40,%esp
c010637c:	5b                   	pop    %ebx
c010637d:	5e                   	pop    %esi
c010637e:	5d                   	pop    %ebp
c010637f:	c3                   	ret    

c0106380 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106380:	f3 0f 1e fb          	endbr32 
c0106384:	55                   	push   %ebp
c0106385:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106387:	8b 45 0c             	mov    0xc(%ebp),%eax
c010638a:	8b 40 08             	mov    0x8(%eax),%eax
c010638d:	8d 50 01             	lea    0x1(%eax),%edx
c0106390:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106393:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106396:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106399:	8b 10                	mov    (%eax),%edx
c010639b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010639e:	8b 40 04             	mov    0x4(%eax),%eax
c01063a1:	39 c2                	cmp    %eax,%edx
c01063a3:	73 12                	jae    c01063b7 <sprintputch+0x37>
        *b->buf ++ = ch;
c01063a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063a8:	8b 00                	mov    (%eax),%eax
c01063aa:	8d 48 01             	lea    0x1(%eax),%ecx
c01063ad:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063b0:	89 0a                	mov    %ecx,(%edx)
c01063b2:	8b 55 08             	mov    0x8(%ebp),%edx
c01063b5:	88 10                	mov    %dl,(%eax)
    }
}
c01063b7:	90                   	nop
c01063b8:	5d                   	pop    %ebp
c01063b9:	c3                   	ret    

c01063ba <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01063ba:	f3 0f 1e fb          	endbr32 
c01063be:	55                   	push   %ebp
c01063bf:	89 e5                	mov    %esp,%ebp
c01063c1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01063c4:	8d 45 14             	lea    0x14(%ebp),%eax
c01063c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01063ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01063d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01063d4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01063d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063df:	8b 45 08             	mov    0x8(%ebp),%eax
c01063e2:	89 04 24             	mov    %eax,(%esp)
c01063e5:	e8 08 00 00 00       	call   c01063f2 <vsnprintf>
c01063ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01063ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01063f0:	c9                   	leave  
c01063f1:	c3                   	ret    

c01063f2 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01063f2:	f3 0f 1e fb          	endbr32 
c01063f6:	55                   	push   %ebp
c01063f7:	89 e5                	mov    %esp,%ebp
c01063f9:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01063fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106402:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106405:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106408:	8b 45 08             	mov    0x8(%ebp),%eax
c010640b:	01 d0                	add    %edx,%eax
c010640d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106410:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106417:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010641b:	74 0a                	je     c0106427 <vsnprintf+0x35>
c010641d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106420:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106423:	39 c2                	cmp    %eax,%edx
c0106425:	76 07                	jbe    c010642e <vsnprintf+0x3c>
        return -E_INVAL;
c0106427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010642c:	eb 2a                	jmp    c0106458 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010642e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106431:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106435:	8b 45 10             	mov    0x10(%ebp),%eax
c0106438:	89 44 24 08          	mov    %eax,0x8(%esp)
c010643c:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010643f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106443:	c7 04 24 80 63 10 c0 	movl   $0xc0106380,(%esp)
c010644a:	e8 53 fb ff ff       	call   c0105fa2 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010644f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106452:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106455:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106458:	c9                   	leave  
c0106459:	c3                   	ret    
