
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
void grade_backtrace(void);
static void lab1_switch_test(void);
static void lab1_print_cur_status(void);

void
kern_init(void){
  100000:	f3 0f 1e fb          	endbr32 
  100004:	55                   	push   %ebp
  100005:	89 e5                	mov    %esp,%ebp
  100007:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10000a:	b8 80 1d 11 00       	mov    $0x111d80,%eax
  10000f:	2d 16 0a 11 00       	sub    $0x110a16,%eax
  100014:	83 ec 04             	sub    $0x4,%esp
  100017:	50                   	push   %eax
  100018:	6a 00                	push   $0x0
  10001a:	68 16 0a 11 00       	push   $0x110a16
  10001f:	e8 1d 30 00 00       	call   103041 <memset>
  100024:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
  100027:	e8 29 16 00 00       	call   101655 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  10002c:	c7 45 f0 20 38 10 00 	movl   $0x103820,-0x10(%ebp)
    cprintf("%s\n\n", message);
  100033:	83 ec 08             	sub    $0x8,%esp
  100036:	ff 75 f0             	pushl  -0x10(%ebp)
  100039:	68 3c 38 10 00       	push   $0x10383c
  10003e:	e8 52 02 00 00       	call   100295 <cprintf>
  100043:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
  100046:	e8 06 09 00 00       	call   100951 <print_kerninfo>

    grade_backtrace();
  10004b:	e8 a5 00 00 00       	call   1000f5 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100050:	e8 8a 2c 00 00       	call   102cdf <pmm_init>

    pic_init();                 // init interrupt controller
  100055:	e8 54 17 00 00       	call   1017ae <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005a:	e8 d5 18 00 00       	call   101934 <idt_init>

    clock_init();               // init clock interrupt
  10005f:	e8 76 0d 00 00       	call   100dda <clock_init>
    intr_enable();              // enable irq interrupt
  100064:	e8 94 18 00 00       	call   1018fd <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  100069:	e8 8c 01 00 00       	call   1001fa <lab1_switch_test>
	
    /* do nothing */
    int i = 0;
  10006e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1){
        i++;
  100075:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        if(i == 10000000){
  100079:	81 7d f4 80 96 98 00 	cmpl   $0x989680,-0xc(%ebp)
  100080:	75 f3                	jne    100075 <kern_init+0x75>
    	    i = 0;
  100082:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    lab1_print_cur_status();
  100089:	e8 8c 00 00 00       	call   10011a <lab1_print_cur_status>
        i++;
  10008e:	eb e5                	jmp    100075 <kern_init+0x75>

00100090 <grade_backtrace2>:
        }
    };
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100090:	f3 0f 1e fb          	endbr32 
  100094:	55                   	push   %ebp
  100095:	89 e5                	mov    %esp,%ebp
  100097:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
  10009a:	83 ec 04             	sub    $0x4,%esp
  10009d:	6a 00                	push   $0x0
  10009f:	6a 00                	push   $0x0
  1000a1:	6a 00                	push   $0x0
  1000a3:	e8 1c 0d 00 00       	call   100dc4 <mon_backtrace>
  1000a8:	83 c4 10             	add    $0x10,%esp
}
  1000ab:	90                   	nop
  1000ac:	c9                   	leave  
  1000ad:	c3                   	ret    

001000ae <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000ae:	f3 0f 1e fb          	endbr32 
  1000b2:	55                   	push   %ebp
  1000b3:	89 e5                	mov    %esp,%ebp
  1000b5:	53                   	push   %ebx
  1000b6:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000b9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000bf:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000c2:	8b 45 08             	mov    0x8(%ebp),%eax
  1000c5:	51                   	push   %ecx
  1000c6:	52                   	push   %edx
  1000c7:	53                   	push   %ebx
  1000c8:	50                   	push   %eax
  1000c9:	e8 c2 ff ff ff       	call   100090 <grade_backtrace2>
  1000ce:	83 c4 10             	add    $0x10,%esp
}
  1000d1:	90                   	nop
  1000d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000d5:	c9                   	leave  
  1000d6:	c3                   	ret    

001000d7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000d7:	f3 0f 1e fb          	endbr32 
  1000db:	55                   	push   %ebp
  1000dc:	89 e5                	mov    %esp,%ebp
  1000de:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
  1000e1:	83 ec 08             	sub    $0x8,%esp
  1000e4:	ff 75 10             	pushl  0x10(%ebp)
  1000e7:	ff 75 08             	pushl  0x8(%ebp)
  1000ea:	e8 bf ff ff ff       	call   1000ae <grade_backtrace1>
  1000ef:	83 c4 10             	add    $0x10,%esp
}
  1000f2:	90                   	nop
  1000f3:	c9                   	leave  
  1000f4:	c3                   	ret    

001000f5 <grade_backtrace>:

void
grade_backtrace(void) {
  1000f5:	f3 0f 1e fb          	endbr32 
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000ff:	b8 00 00 10 00       	mov    $0x100000,%eax
  100104:	83 ec 04             	sub    $0x4,%esp
  100107:	68 00 00 ff ff       	push   $0xffff0000
  10010c:	50                   	push   %eax
  10010d:	6a 00                	push   $0x0
  10010f:	e8 c3 ff ff ff       	call   1000d7 <grade_backtrace0>
  100114:	83 c4 10             	add    $0x10,%esp
}
  100117:	90                   	nop
  100118:	c9                   	leave  
  100119:	c3                   	ret    

0010011a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10011a:	f3 0f 1e fb          	endbr32 
  10011e:	55                   	push   %ebp
  10011f:	89 e5                	mov    %esp,%ebp
  100121:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100124:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100127:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10012a:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10012d:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100130:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100134:	0f b7 c0             	movzwl %ax,%eax
  100137:	83 e0 03             	and    $0x3,%eax
  10013a:	89 c2                	mov    %eax,%edx
  10013c:	a1 20 0a 11 00       	mov    0x110a20,%eax
  100141:	83 ec 04             	sub    $0x4,%esp
  100144:	52                   	push   %edx
  100145:	50                   	push   %eax
  100146:	68 41 38 10 00       	push   $0x103841
  10014b:	e8 45 01 00 00       	call   100295 <cprintf>
  100150:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
  100153:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100157:	0f b7 d0             	movzwl %ax,%edx
  10015a:	a1 20 0a 11 00       	mov    0x110a20,%eax
  10015f:	83 ec 04             	sub    $0x4,%esp
  100162:	52                   	push   %edx
  100163:	50                   	push   %eax
  100164:	68 4f 38 10 00       	push   $0x10384f
  100169:	e8 27 01 00 00       	call   100295 <cprintf>
  10016e:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
  100171:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100175:	0f b7 d0             	movzwl %ax,%edx
  100178:	a1 20 0a 11 00       	mov    0x110a20,%eax
  10017d:	83 ec 04             	sub    $0x4,%esp
  100180:	52                   	push   %edx
  100181:	50                   	push   %eax
  100182:	68 5d 38 10 00       	push   $0x10385d
  100187:	e8 09 01 00 00       	call   100295 <cprintf>
  10018c:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
  10018f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100193:	0f b7 d0             	movzwl %ax,%edx
  100196:	a1 20 0a 11 00       	mov    0x110a20,%eax
  10019b:	83 ec 04             	sub    $0x4,%esp
  10019e:	52                   	push   %edx
  10019f:	50                   	push   %eax
  1001a0:	68 6b 38 10 00       	push   $0x10386b
  1001a5:	e8 eb 00 00 00       	call   100295 <cprintf>
  1001aa:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
  1001ad:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001b1:	0f b7 d0             	movzwl %ax,%edx
  1001b4:	a1 20 0a 11 00       	mov    0x110a20,%eax
  1001b9:	83 ec 04             	sub    $0x4,%esp
  1001bc:	52                   	push   %edx
  1001bd:	50                   	push   %eax
  1001be:	68 79 38 10 00       	push   $0x103879
  1001c3:	e8 cd 00 00 00       	call   100295 <cprintf>
  1001c8:	83 c4 10             	add    $0x10,%esp
    round ++;
  1001cb:	a1 20 0a 11 00       	mov    0x110a20,%eax
  1001d0:	83 c0 01             	add    $0x1,%eax
  1001d3:	a3 20 0a 11 00       	mov    %eax,0x110a20
}
  1001d8:	90                   	nop
  1001d9:	c9                   	leave  
  1001da:	c3                   	ret    

001001db <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001db:	f3 0f 1e fb          	endbr32 
  1001df:	55                   	push   %ebp
  1001e0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001e2:	83 ec 08             	sub    $0x8,%esp
  1001e5:	cd 78                	int    $0x78
  1001e7:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001e9:	90                   	nop
  1001ea:	5d                   	pop    %ebp
  1001eb:	c3                   	ret    

001001ec <lab1_switch_to_kernel>:
static void
lab1_switch_to_kernel(void) {
  1001ec:	f3 0f 1e fb          	endbr32 
  1001f0:	55                   	push   %ebp
  1001f1:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001f3:	cd 79                	int    $0x79
  1001f5:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001f7:	90                   	nop
  1001f8:	5d                   	pop    %ebp
  1001f9:	c3                   	ret    

001001fa <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001fa:	f3 0f 1e fb          	endbr32 
  1001fe:	55                   	push   %ebp
  1001ff:	89 e5                	mov    %esp,%ebp
  100201:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
  100204:	e8 11 ff ff ff       	call   10011a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100209:	83 ec 0c             	sub    $0xc,%esp
  10020c:	68 88 38 10 00       	push   $0x103888
  100211:	e8 7f 00 00 00       	call   100295 <cprintf>
  100216:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
  100219:	e8 bd ff ff ff       	call   1001db <lab1_switch_to_user>
    lab1_print_cur_status();
  10021e:	e8 f7 fe ff ff       	call   10011a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100223:	83 ec 0c             	sub    $0xc,%esp
  100226:	68 a8 38 10 00       	push   $0x1038a8
  10022b:	e8 65 00 00 00       	call   100295 <cprintf>
  100230:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
  100233:	e8 b4 ff ff ff       	call   1001ec <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100238:	e8 dd fe ff ff       	call   10011a <lab1_print_cur_status>
}
  10023d:	90                   	nop
  10023e:	c9                   	leave  
  10023f:	c3                   	ret    

00100240 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100240:	f3 0f 1e fb          	endbr32 
  100244:	55                   	push   %ebp
  100245:	89 e5                	mov    %esp,%ebp
  100247:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  10024a:	83 ec 0c             	sub    $0xc,%esp
  10024d:	ff 75 08             	pushl  0x8(%ebp)
  100250:	e8 35 14 00 00       	call   10168a <cons_putc>
  100255:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
  100258:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025b:	8b 00                	mov    (%eax),%eax
  10025d:	8d 50 01             	lea    0x1(%eax),%edx
  100260:	8b 45 0c             	mov    0xc(%ebp),%eax
  100263:	89 10                	mov    %edx,(%eax)
}
  100265:	90                   	nop
  100266:	c9                   	leave  
  100267:	c3                   	ret    

00100268 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100268:	f3 0f 1e fb          	endbr32 
  10026c:	55                   	push   %ebp
  10026d:	89 e5                	mov    %esp,%ebp
  10026f:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  100272:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100279:	ff 75 0c             	pushl  0xc(%ebp)
  10027c:	ff 75 08             	pushl  0x8(%ebp)
  10027f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100282:	50                   	push   %eax
  100283:	68 40 02 10 00       	push   $0x100240
  100288:	e8 03 31 00 00       	call   103390 <vprintfmt>
  10028d:	83 c4 10             	add    $0x10,%esp
    return cnt;
  100290:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100293:	c9                   	leave  
  100294:	c3                   	ret    

00100295 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100295:	f3 0f 1e fb          	endbr32 
  100299:	55                   	push   %ebp
  10029a:	89 e5                	mov    %esp,%ebp
  10029c:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10029f:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a8:	83 ec 08             	sub    $0x8,%esp
  1002ab:	50                   	push   %eax
  1002ac:	ff 75 08             	pushl  0x8(%ebp)
  1002af:	e8 b4 ff ff ff       	call   100268 <vcprintf>
  1002b4:	83 c4 10             	add    $0x10,%esp
  1002b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002bd:	c9                   	leave  
  1002be:	c3                   	ret    

001002bf <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002bf:	f3 0f 1e fb          	endbr32 
  1002c3:	55                   	push   %ebp
  1002c4:	89 e5                	mov    %esp,%ebp
  1002c6:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
  1002c9:	83 ec 0c             	sub    $0xc,%esp
  1002cc:	ff 75 08             	pushl  0x8(%ebp)
  1002cf:	e8 b6 13 00 00       	call   10168a <cons_putc>
  1002d4:	83 c4 10             	add    $0x10,%esp
}
  1002d7:	90                   	nop
  1002d8:	c9                   	leave  
  1002d9:	c3                   	ret    

001002da <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002da:	f3 0f 1e fb          	endbr32 
  1002de:	55                   	push   %ebp
  1002df:	89 e5                	mov    %esp,%ebp
  1002e1:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
  1002e4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002eb:	eb 14                	jmp    100301 <cputs+0x27>
        cputch(c, &cnt);
  1002ed:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002f1:	83 ec 08             	sub    $0x8,%esp
  1002f4:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002f7:	52                   	push   %edx
  1002f8:	50                   	push   %eax
  1002f9:	e8 42 ff ff ff       	call   100240 <cputch>
  1002fe:	83 c4 10             	add    $0x10,%esp
    while ((c = *str ++) != '\0') {
  100301:	8b 45 08             	mov    0x8(%ebp),%eax
  100304:	8d 50 01             	lea    0x1(%eax),%edx
  100307:	89 55 08             	mov    %edx,0x8(%ebp)
  10030a:	0f b6 00             	movzbl (%eax),%eax
  10030d:	88 45 f7             	mov    %al,-0x9(%ebp)
  100310:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100314:	75 d7                	jne    1002ed <cputs+0x13>
    }
    cputch('\n', &cnt);
  100316:	83 ec 08             	sub    $0x8,%esp
  100319:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10031c:	50                   	push   %eax
  10031d:	6a 0a                	push   $0xa
  10031f:	e8 1c ff ff ff       	call   100240 <cputch>
  100324:	83 c4 10             	add    $0x10,%esp
    return cnt;
  100327:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10032a:	c9                   	leave  
  10032b:	c3                   	ret    

0010032c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10032c:	f3 0f 1e fb          	endbr32 
  100330:	55                   	push   %ebp
  100331:	89 e5                	mov    %esp,%ebp
  100333:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100336:	90                   	nop
  100337:	e8 82 13 00 00       	call   1016be <cons_getc>
  10033c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10033f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100343:	74 f2                	je     100337 <getchar+0xb>
        /* do nothing */;
    return c;
  100345:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100348:	c9                   	leave  
  100349:	c3                   	ret    

0010034a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10034a:	f3 0f 1e fb          	endbr32 
  10034e:	55                   	push   %ebp
  10034f:	89 e5                	mov    %esp,%ebp
  100351:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
  100354:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100358:	74 13                	je     10036d <readline+0x23>
        cprintf("%s", prompt);
  10035a:	83 ec 08             	sub    $0x8,%esp
  10035d:	ff 75 08             	pushl  0x8(%ebp)
  100360:	68 c7 38 10 00       	push   $0x1038c7
  100365:	e8 2b ff ff ff       	call   100295 <cprintf>
  10036a:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
  10036d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100374:	e8 b3 ff ff ff       	call   10032c <getchar>
  100379:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10037c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100380:	79 0a                	jns    10038c <readline+0x42>
            return NULL;
  100382:	b8 00 00 00 00       	mov    $0x0,%eax
  100387:	e9 82 00 00 00       	jmp    10040e <readline+0xc4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10038c:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100390:	7e 2b                	jle    1003bd <readline+0x73>
  100392:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100399:	7f 22                	jg     1003bd <readline+0x73>
            cputchar(c);
  10039b:	83 ec 0c             	sub    $0xc,%esp
  10039e:	ff 75 f0             	pushl  -0x10(%ebp)
  1003a1:	e8 19 ff ff ff       	call   1002bf <cputchar>
  1003a6:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
  1003a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ac:	8d 50 01             	lea    0x1(%eax),%edx
  1003af:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003b5:	88 90 40 0a 11 00    	mov    %dl,0x110a40(%eax)
  1003bb:	eb 4c                	jmp    100409 <readline+0xbf>
        }
        else if (c == '\b' && i > 0) {
  1003bd:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003c1:	75 1a                	jne    1003dd <readline+0x93>
  1003c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003c7:	7e 14                	jle    1003dd <readline+0x93>
            cputchar(c);
  1003c9:	83 ec 0c             	sub    $0xc,%esp
  1003cc:	ff 75 f0             	pushl  -0x10(%ebp)
  1003cf:	e8 eb fe ff ff       	call   1002bf <cputchar>
  1003d4:	83 c4 10             	add    $0x10,%esp
            i --;
  1003d7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  1003db:	eb 2c                	jmp    100409 <readline+0xbf>
        }
        else if (c == '\n' || c == '\r') {
  1003dd:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003e1:	74 06                	je     1003e9 <readline+0x9f>
  1003e3:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003e7:	75 8b                	jne    100374 <readline+0x2a>
            cputchar(c);
  1003e9:	83 ec 0c             	sub    $0xc,%esp
  1003ec:	ff 75 f0             	pushl  -0x10(%ebp)
  1003ef:	e8 cb fe ff ff       	call   1002bf <cputchar>
  1003f4:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
  1003f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003fa:	05 40 0a 11 00       	add    $0x110a40,%eax
  1003ff:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100402:	b8 40 0a 11 00       	mov    $0x110a40,%eax
  100407:	eb 05                	jmp    10040e <readline+0xc4>
        c = getchar();
  100409:	e9 66 ff ff ff       	jmp    100374 <readline+0x2a>
        }
    }
}
  10040e:	c9                   	leave  
  10040f:	c3                   	ret    

00100410 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100410:	f3 0f 1e fb          	endbr32 
  100414:	55                   	push   %ebp
  100415:	89 e5                	mov    %esp,%ebp
  100417:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
  10041a:	a1 40 0e 11 00       	mov    0x110e40,%eax
  10041f:	85 c0                	test   %eax,%eax
  100421:	75 5f                	jne    100482 <__panic+0x72>
        goto panic_dead;
    }
    is_panic = 1;
  100423:	c7 05 40 0e 11 00 01 	movl   $0x1,0x110e40
  10042a:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  10042d:	8d 45 14             	lea    0x14(%ebp),%eax
  100430:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100433:	83 ec 04             	sub    $0x4,%esp
  100436:	ff 75 0c             	pushl  0xc(%ebp)
  100439:	ff 75 08             	pushl  0x8(%ebp)
  10043c:	68 ca 38 10 00       	push   $0x1038ca
  100441:	e8 4f fe ff ff       	call   100295 <cprintf>
  100446:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  100449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10044c:	83 ec 08             	sub    $0x8,%esp
  10044f:	50                   	push   %eax
  100450:	ff 75 10             	pushl  0x10(%ebp)
  100453:	e8 10 fe ff ff       	call   100268 <vcprintf>
  100458:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  10045b:	83 ec 0c             	sub    $0xc,%esp
  10045e:	68 e6 38 10 00       	push   $0x1038e6
  100463:	e8 2d fe ff ff       	call   100295 <cprintf>
  100468:	83 c4 10             	add    $0x10,%esp
    
    cprintf("stack trackback:\n");
  10046b:	83 ec 0c             	sub    $0xc,%esp
  10046e:	68 e8 38 10 00       	push   $0x1038e8
  100473:	e8 1d fe ff ff       	call   100295 <cprintf>
  100478:	83 c4 10             	add    $0x10,%esp
    print_stackframe();
  10047b:	e8 25 06 00 00       	call   100aa5 <print_stackframe>
  100480:	eb 01                	jmp    100483 <__panic+0x73>
        goto panic_dead;
  100482:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100483:	e8 81 14 00 00       	call   101909 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100488:	83 ec 0c             	sub    $0xc,%esp
  10048b:	6a 00                	push   $0x0
  10048d:	e8 4c 08 00 00       	call   100cde <kmonitor>
  100492:	83 c4 10             	add    $0x10,%esp
  100495:	eb f1                	jmp    100488 <__panic+0x78>

00100497 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100497:	f3 0f 1e fb          	endbr32 
  10049b:	55                   	push   %ebp
  10049c:	89 e5                	mov    %esp,%ebp
  10049e:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
  1004a1:	8d 45 14             	lea    0x14(%ebp),%eax
  1004a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  1004a7:	83 ec 04             	sub    $0x4,%esp
  1004aa:	ff 75 0c             	pushl  0xc(%ebp)
  1004ad:	ff 75 08             	pushl  0x8(%ebp)
  1004b0:	68 fa 38 10 00       	push   $0x1038fa
  1004b5:	e8 db fd ff ff       	call   100295 <cprintf>
  1004ba:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
  1004bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004c0:	83 ec 08             	sub    $0x8,%esp
  1004c3:	50                   	push   %eax
  1004c4:	ff 75 10             	pushl  0x10(%ebp)
  1004c7:	e8 9c fd ff ff       	call   100268 <vcprintf>
  1004cc:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
  1004cf:	83 ec 0c             	sub    $0xc,%esp
  1004d2:	68 e6 38 10 00       	push   $0x1038e6
  1004d7:	e8 b9 fd ff ff       	call   100295 <cprintf>
  1004dc:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  1004df:	90                   	nop
  1004e0:	c9                   	leave  
  1004e1:	c3                   	ret    

001004e2 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004e2:	f3 0f 1e fb          	endbr32 
  1004e6:	55                   	push   %ebp
  1004e7:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004e9:	a1 40 0e 11 00       	mov    0x110e40,%eax
}
  1004ee:	5d                   	pop    %ebp
  1004ef:	c3                   	ret    

001004f0 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004f0:	f3 0f 1e fb          	endbr32 
  1004f4:	55                   	push   %ebp
  1004f5:	89 e5                	mov    %esp,%ebp
  1004f7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004fd:	8b 00                	mov    (%eax),%eax
  1004ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100502:	8b 45 10             	mov    0x10(%ebp),%eax
  100505:	8b 00                	mov    (%eax),%eax
  100507:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10050a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100511:	e9 d2 00 00 00       	jmp    1005e8 <stab_binsearch+0xf8>
        int true_m = (l + r) / 2, m = true_m;
  100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100519:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10051c:	01 d0                	add    %edx,%eax
  10051e:	89 c2                	mov    %eax,%edx
  100520:	c1 ea 1f             	shr    $0x1f,%edx
  100523:	01 d0                	add    %edx,%eax
  100525:	d1 f8                	sar    %eax
  100527:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10052a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10052d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100530:	eb 04                	jmp    100536 <stab_binsearch+0x46>
            m --;
  100532:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100536:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100539:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10053c:	7c 1f                	jl     10055d <stab_binsearch+0x6d>
  10053e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100541:	89 d0                	mov    %edx,%eax
  100543:	01 c0                	add    %eax,%eax
  100545:	01 d0                	add    %edx,%eax
  100547:	c1 e0 02             	shl    $0x2,%eax
  10054a:	89 c2                	mov    %eax,%edx
  10054c:	8b 45 08             	mov    0x8(%ebp),%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100555:	0f b6 c0             	movzbl %al,%eax
  100558:	39 45 14             	cmp    %eax,0x14(%ebp)
  10055b:	75 d5                	jne    100532 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
  10055d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100560:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100563:	7d 0b                	jge    100570 <stab_binsearch+0x80>
            l = true_m + 1;
  100565:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100568:	83 c0 01             	add    $0x1,%eax
  10056b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10056e:	eb 78                	jmp    1005e8 <stab_binsearch+0xf8>
        }

        // actual binary search
        any_matches = 1;
  100570:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100577:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10057a:	89 d0                	mov    %edx,%eax
  10057c:	01 c0                	add    %eax,%eax
  10057e:	01 d0                	add    %edx,%eax
  100580:	c1 e0 02             	shl    $0x2,%eax
  100583:	89 c2                	mov    %eax,%edx
  100585:	8b 45 08             	mov    0x8(%ebp),%eax
  100588:	01 d0                	add    %edx,%eax
  10058a:	8b 40 08             	mov    0x8(%eax),%eax
  10058d:	39 45 18             	cmp    %eax,0x18(%ebp)
  100590:	76 13                	jbe    1005a5 <stab_binsearch+0xb5>
            *region_left = m;
  100592:	8b 45 0c             	mov    0xc(%ebp),%eax
  100595:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100598:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  10059a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10059d:	83 c0 01             	add    $0x1,%eax
  1005a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1005a3:	eb 43                	jmp    1005e8 <stab_binsearch+0xf8>
        } else if (stabs[m].n_value > addr) {
  1005a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005a8:	89 d0                	mov    %edx,%eax
  1005aa:	01 c0                	add    %eax,%eax
  1005ac:	01 d0                	add    %edx,%eax
  1005ae:	c1 e0 02             	shl    $0x2,%eax
  1005b1:	89 c2                	mov    %eax,%edx
  1005b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b6:	01 d0                	add    %edx,%eax
  1005b8:	8b 40 08             	mov    0x8(%eax),%eax
  1005bb:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005be:	73 16                	jae    1005d6 <stab_binsearch+0xe6>
            *region_right = m - 1;
  1005c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005c3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c9:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1005cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005ce:	83 e8 01             	sub    $0x1,%eax
  1005d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005d4:	eb 12                	jmp    1005e8 <stab_binsearch+0xf8>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005dc:	89 10                	mov    %edx,(%eax)
            l = m;
  1005de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005e4:	83 45 18 01          	addl   $0x1,0x18(%ebp)
    while (l <= r) {
  1005e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005ee:	0f 8e 22 ff ff ff    	jle    100516 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
  1005f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005f8:	75 0f                	jne    100609 <stab_binsearch+0x119>
        *region_right = *region_left - 1;
  1005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fd:	8b 00                	mov    (%eax),%eax
  1005ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  100602:	8b 45 10             	mov    0x10(%ebp),%eax
  100605:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  100607:	eb 3f                	jmp    100648 <stab_binsearch+0x158>
        l = *region_right;
  100609:	8b 45 10             	mov    0x10(%ebp),%eax
  10060c:	8b 00                	mov    (%eax),%eax
  10060e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100611:	eb 04                	jmp    100617 <stab_binsearch+0x127>
  100613:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  100617:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061a:	8b 00                	mov    (%eax),%eax
  10061c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  10061f:	7e 1f                	jle    100640 <stab_binsearch+0x150>
  100621:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100624:	89 d0                	mov    %edx,%eax
  100626:	01 c0                	add    %eax,%eax
  100628:	01 d0                	add    %edx,%eax
  10062a:	c1 e0 02             	shl    $0x2,%eax
  10062d:	89 c2                	mov    %eax,%edx
  10062f:	8b 45 08             	mov    0x8(%ebp),%eax
  100632:	01 d0                	add    %edx,%eax
  100634:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100638:	0f b6 c0             	movzbl %al,%eax
  10063b:	39 45 14             	cmp    %eax,0x14(%ebp)
  10063e:	75 d3                	jne    100613 <stab_binsearch+0x123>
        *region_left = l;
  100640:	8b 45 0c             	mov    0xc(%ebp),%eax
  100643:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100646:	89 10                	mov    %edx,(%eax)
}
  100648:	90                   	nop
  100649:	c9                   	leave  
  10064a:	c3                   	ret    

0010064b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10064b:	f3 0f 1e fb          	endbr32 
  10064f:	55                   	push   %ebp
  100650:	89 e5                	mov    %esp,%ebp
  100652:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100655:	8b 45 0c             	mov    0xc(%ebp),%eax
  100658:	c7 00 18 39 10 00    	movl   $0x103918,(%eax)
    info->eip_line = 0;
  10065e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100661:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100668:	8b 45 0c             	mov    0xc(%ebp),%eax
  10066b:	c7 40 08 18 39 10 00 	movl   $0x103918,0x8(%eax)
    info->eip_fn_namelen = 9;
  100672:	8b 45 0c             	mov    0xc(%ebp),%eax
  100675:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10067c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10067f:	8b 55 08             	mov    0x8(%ebp),%edx
  100682:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100685:	8b 45 0c             	mov    0xc(%ebp),%eax
  100688:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10068f:	c7 45 f4 2c 41 10 00 	movl   $0x10412c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100696:	c7 45 f0 74 d1 10 00 	movl   $0x10d174,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10069d:	c7 45 ec 75 d1 10 00 	movl   $0x10d175,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1006a4:	c7 45 e8 83 f2 10 00 	movl   $0x10f283,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1006ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1006b1:	76 0d                	jbe    1006c0 <debuginfo_eip+0x75>
  1006b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006b6:	83 e8 01             	sub    $0x1,%eax
  1006b9:	0f b6 00             	movzbl (%eax),%eax
  1006bc:	84 c0                	test   %al,%al
  1006be:	74 0a                	je     1006ca <debuginfo_eip+0x7f>
        return -1;
  1006c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006c5:	e9 85 02 00 00       	jmp    10094f <debuginfo_eip+0x304>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1006ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1006d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1006d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1006d7:	c1 f8 02             	sar    $0x2,%eax
  1006da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006e0:	83 e8 01             	sub    $0x1,%eax
  1006e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006e6:	ff 75 08             	pushl  0x8(%ebp)
  1006e9:	6a 64                	push   $0x64
  1006eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006ee:	50                   	push   %eax
  1006ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006f2:	50                   	push   %eax
  1006f3:	ff 75 f4             	pushl  -0xc(%ebp)
  1006f6:	e8 f5 fd ff ff       	call   1004f0 <stab_binsearch>
  1006fb:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
  1006fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100701:	85 c0                	test   %eax,%eax
  100703:	75 0a                	jne    10070f <debuginfo_eip+0xc4>
        return -1;
  100705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10070a:	e9 40 02 00 00       	jmp    10094f <debuginfo_eip+0x304>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10070f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100712:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100715:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100718:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10071b:	ff 75 08             	pushl  0x8(%ebp)
  10071e:	6a 24                	push   $0x24
  100720:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100723:	50                   	push   %eax
  100724:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100727:	50                   	push   %eax
  100728:	ff 75 f4             	pushl  -0xc(%ebp)
  10072b:	e8 c0 fd ff ff       	call   1004f0 <stab_binsearch>
  100730:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
  100733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100736:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100739:	39 c2                	cmp    %eax,%edx
  10073b:	7f 78                	jg     1007b5 <debuginfo_eip+0x16a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10073d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100740:	89 c2                	mov    %eax,%edx
  100742:	89 d0                	mov    %edx,%eax
  100744:	01 c0                	add    %eax,%eax
  100746:	01 d0                	add    %edx,%eax
  100748:	c1 e0 02             	shl    $0x2,%eax
  10074b:	89 c2                	mov    %eax,%edx
  10074d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100750:	01 d0                	add    %edx,%eax
  100752:	8b 10                	mov    (%eax),%edx
  100754:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100757:	2b 45 ec             	sub    -0x14(%ebp),%eax
  10075a:	39 c2                	cmp    %eax,%edx
  10075c:	73 22                	jae    100780 <debuginfo_eip+0x135>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10075e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100761:	89 c2                	mov    %eax,%edx
  100763:	89 d0                	mov    %edx,%eax
  100765:	01 c0                	add    %eax,%eax
  100767:	01 d0                	add    %edx,%eax
  100769:	c1 e0 02             	shl    $0x2,%eax
  10076c:	89 c2                	mov    %eax,%edx
  10076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100771:	01 d0                	add    %edx,%eax
  100773:	8b 10                	mov    (%eax),%edx
  100775:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100778:	01 c2                	add    %eax,%edx
  10077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077d:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100780:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100783:	89 c2                	mov    %eax,%edx
  100785:	89 d0                	mov    %edx,%eax
  100787:	01 c0                	add    %eax,%eax
  100789:	01 d0                	add    %edx,%eax
  10078b:	c1 e0 02             	shl    $0x2,%eax
  10078e:	89 c2                	mov    %eax,%edx
  100790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100793:	01 d0                	add    %edx,%eax
  100795:	8b 50 08             	mov    0x8(%eax),%edx
  100798:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079b:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a1:	8b 40 10             	mov    0x10(%eax),%eax
  1007a4:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1007a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1007ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1007b3:	eb 15                	jmp    1007ca <debuginfo_eip+0x17f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b8:	8b 55 08             	mov    0x8(%ebp),%edx
  1007bb:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	83 ec 08             	sub    $0x8,%esp
  1007d3:	6a 3a                	push   $0x3a
  1007d5:	50                   	push   %eax
  1007d6:	e8 d2 26 00 00       	call   102ead <strfind>
  1007db:	83 c4 10             	add    $0x10,%esp
  1007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1007e1:	8b 52 08             	mov    0x8(%edx),%edx
  1007e4:	29 d0                	sub    %edx,%eax
  1007e6:	89 c2                	mov    %eax,%edx
  1007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007eb:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007ee:	83 ec 0c             	sub    $0xc,%esp
  1007f1:	ff 75 08             	pushl  0x8(%ebp)
  1007f4:	6a 44                	push   $0x44
  1007f6:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007f9:	50                   	push   %eax
  1007fa:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007fd:	50                   	push   %eax
  1007fe:	ff 75 f4             	pushl  -0xc(%ebp)
  100801:	e8 ea fc ff ff       	call   1004f0 <stab_binsearch>
  100806:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
  100809:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10080f:	39 c2                	cmp    %eax,%edx
  100811:	7f 24                	jg     100837 <debuginfo_eip+0x1ec>
        info->eip_line = stabs[rline].n_desc;
  100813:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	89 d0                	mov    %edx,%eax
  10081a:	01 c0                	add    %eax,%eax
  10081c:	01 d0                	add    %edx,%eax
  10081e:	c1 e0 02             	shl    $0x2,%eax
  100821:	89 c2                	mov    %eax,%edx
  100823:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100826:	01 d0                	add    %edx,%eax
  100828:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10082c:	0f b7 d0             	movzwl %ax,%edx
  10082f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100832:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100835:	eb 13                	jmp    10084a <debuginfo_eip+0x1ff>
        return -1;
  100837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10083c:	e9 0e 01 00 00       	jmp    10094f <debuginfo_eip+0x304>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100841:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100844:	83 e8 01             	sub    $0x1,%eax
  100847:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  10084a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100850:	39 c2                	cmp    %eax,%edx
  100852:	7c 56                	jl     1008aa <debuginfo_eip+0x25f>
           && stabs[lline].n_type != N_SOL
  100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100857:	89 c2                	mov    %eax,%edx
  100859:	89 d0                	mov    %edx,%eax
  10085b:	01 c0                	add    %eax,%eax
  10085d:	01 d0                	add    %edx,%eax
  10085f:	c1 e0 02             	shl    $0x2,%eax
  100862:	89 c2                	mov    %eax,%edx
  100864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100867:	01 d0                	add    %edx,%eax
  100869:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086d:	3c 84                	cmp    $0x84,%al
  10086f:	74 39                	je     1008aa <debuginfo_eip+0x25f>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100871:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100874:	89 c2                	mov    %eax,%edx
  100876:	89 d0                	mov    %edx,%eax
  100878:	01 c0                	add    %eax,%eax
  10087a:	01 d0                	add    %edx,%eax
  10087c:	c1 e0 02             	shl    $0x2,%eax
  10087f:	89 c2                	mov    %eax,%edx
  100881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100884:	01 d0                	add    %edx,%eax
  100886:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10088a:	3c 64                	cmp    $0x64,%al
  10088c:	75 b3                	jne    100841 <debuginfo_eip+0x1f6>
  10088e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100891:	89 c2                	mov    %eax,%edx
  100893:	89 d0                	mov    %edx,%eax
  100895:	01 c0                	add    %eax,%eax
  100897:	01 d0                	add    %edx,%eax
  100899:	c1 e0 02             	shl    $0x2,%eax
  10089c:	89 c2                	mov    %eax,%edx
  10089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008a1:	01 d0                	add    %edx,%eax
  1008a3:	8b 40 08             	mov    0x8(%eax),%eax
  1008a6:	85 c0                	test   %eax,%eax
  1008a8:	74 97                	je     100841 <debuginfo_eip+0x1f6>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008aa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008b0:	39 c2                	cmp    %eax,%edx
  1008b2:	7c 42                	jl     1008f6 <debuginfo_eip+0x2ab>
  1008b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b7:	89 c2                	mov    %eax,%edx
  1008b9:	89 d0                	mov    %edx,%eax
  1008bb:	01 c0                	add    %eax,%eax
  1008bd:	01 d0                	add    %edx,%eax
  1008bf:	c1 e0 02             	shl    $0x2,%eax
  1008c2:	89 c2                	mov    %eax,%edx
  1008c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008c7:	01 d0                	add    %edx,%eax
  1008c9:	8b 10                	mov    (%eax),%edx
  1008cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1008ce:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1008d1:	39 c2                	cmp    %eax,%edx
  1008d3:	73 21                	jae    1008f6 <debuginfo_eip+0x2ab>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d8:	89 c2                	mov    %eax,%edx
  1008da:	89 d0                	mov    %edx,%eax
  1008dc:	01 c0                	add    %eax,%eax
  1008de:	01 d0                	add    %edx,%eax
  1008e0:	c1 e0 02             	shl    $0x2,%eax
  1008e3:	89 c2                	mov    %eax,%edx
  1008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e8:	01 d0                	add    %edx,%eax
  1008ea:	8b 10                	mov    (%eax),%edx
  1008ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008ef:	01 c2                	add    %eax,%edx
  1008f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008f4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008fc:	39 c2                	cmp    %eax,%edx
  1008fe:	7d 4a                	jge    10094a <debuginfo_eip+0x2ff>
        for (lline = lfun + 1;
  100900:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100903:	83 c0 01             	add    $0x1,%eax
  100906:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100909:	eb 18                	jmp    100923 <debuginfo_eip+0x2d8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  10090b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10090e:	8b 40 14             	mov    0x14(%eax),%eax
  100911:	8d 50 01             	lea    0x1(%eax),%edx
  100914:	8b 45 0c             	mov    0xc(%ebp),%eax
  100917:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  10091a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10091d:	83 c0 01             	add    $0x1,%eax
  100920:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100923:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100926:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100929:	39 c2                	cmp    %eax,%edx
  10092b:	7d 1d                	jge    10094a <debuginfo_eip+0x2ff>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10092d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100930:	89 c2                	mov    %eax,%edx
  100932:	89 d0                	mov    %edx,%eax
  100934:	01 c0                	add    %eax,%eax
  100936:	01 d0                	add    %edx,%eax
  100938:	c1 e0 02             	shl    $0x2,%eax
  10093b:	89 c2                	mov    %eax,%edx
  10093d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100940:	01 d0                	add    %edx,%eax
  100942:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100946:	3c a0                	cmp    $0xa0,%al
  100948:	74 c1                	je     10090b <debuginfo_eip+0x2c0>
        }
    }
    return 0;
  10094a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10094f:	c9                   	leave  
  100950:	c3                   	ret    

00100951 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100951:	f3 0f 1e fb          	endbr32 
  100955:	55                   	push   %ebp
  100956:	89 e5                	mov    %esp,%ebp
  100958:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10095b:	83 ec 0c             	sub    $0xc,%esp
  10095e:	68 22 39 10 00       	push   $0x103922
  100963:	e8 2d f9 ff ff       	call   100295 <cprintf>
  100968:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10096b:	83 ec 08             	sub    $0x8,%esp
  10096e:	68 00 00 10 00       	push   $0x100000
  100973:	68 3b 39 10 00       	push   $0x10393b
  100978:	e8 18 f9 ff ff       	call   100295 <cprintf>
  10097d:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
  100980:	83 ec 08             	sub    $0x8,%esp
  100983:	68 02 38 10 00       	push   $0x103802
  100988:	68 53 39 10 00       	push   $0x103953
  10098d:	e8 03 f9 ff ff       	call   100295 <cprintf>
  100992:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
  100995:	83 ec 08             	sub    $0x8,%esp
  100998:	68 16 0a 11 00       	push   $0x110a16
  10099d:	68 6b 39 10 00       	push   $0x10396b
  1009a2:	e8 ee f8 ff ff       	call   100295 <cprintf>
  1009a7:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
  1009aa:	83 ec 08             	sub    $0x8,%esp
  1009ad:	68 80 1d 11 00       	push   $0x111d80
  1009b2:	68 83 39 10 00       	push   $0x103983
  1009b7:	e8 d9 f8 ff ff       	call   100295 <cprintf>
  1009bc:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009bf:	b8 80 1d 11 00       	mov    $0x111d80,%eax
  1009c4:	2d 00 00 10 00       	sub    $0x100000,%eax
  1009c9:	05 ff 03 00 00       	add    $0x3ff,%eax
  1009ce:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009d4:	85 c0                	test   %eax,%eax
  1009d6:	0f 48 c2             	cmovs  %edx,%eax
  1009d9:	c1 f8 0a             	sar    $0xa,%eax
  1009dc:	83 ec 08             	sub    $0x8,%esp
  1009df:	50                   	push   %eax
  1009e0:	68 9c 39 10 00       	push   $0x10399c
  1009e5:	e8 ab f8 ff ff       	call   100295 <cprintf>
  1009ea:	83 c4 10             	add    $0x10,%esp
}
  1009ed:	90                   	nop
  1009ee:	c9                   	leave  
  1009ef:	c3                   	ret    

001009f0 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009f0:	f3 0f 1e fb          	endbr32 
  1009f4:	55                   	push   %ebp
  1009f5:	89 e5                	mov    %esp,%ebp
  1009f7:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009fd:	83 ec 08             	sub    $0x8,%esp
  100a00:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100a03:	50                   	push   %eax
  100a04:	ff 75 08             	pushl  0x8(%ebp)
  100a07:	e8 3f fc ff ff       	call   10064b <debuginfo_eip>
  100a0c:	83 c4 10             	add    $0x10,%esp
  100a0f:	85 c0                	test   %eax,%eax
  100a11:	74 15                	je     100a28 <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100a13:	83 ec 08             	sub    $0x8,%esp
  100a16:	ff 75 08             	pushl  0x8(%ebp)
  100a19:	68 c6 39 10 00       	push   $0x1039c6
  100a1e:	e8 72 f8 ff ff       	call   100295 <cprintf>
  100a23:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a26:	eb 65                	jmp    100a8d <print_debuginfo+0x9d>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a2f:	eb 1c                	jmp    100a4d <print_debuginfo+0x5d>
            fnname[j] = info.eip_fn_name[j];
  100a31:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a37:	01 d0                	add    %edx,%eax
  100a39:	0f b6 00             	movzbl (%eax),%eax
  100a3c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a45:	01 ca                	add    %ecx,%edx
  100a47:	88 02                	mov    %al,(%edx)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100a4d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a50:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a53:	7c dc                	jl     100a31 <print_debuginfo+0x41>
        fnname[j] = '\0';
  100a55:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a5e:	01 d0                	add    %edx,%eax
  100a60:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a63:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a66:	8b 55 08             	mov    0x8(%ebp),%edx
  100a69:	89 d1                	mov    %edx,%ecx
  100a6b:	29 c1                	sub    %eax,%ecx
  100a6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a70:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a73:	83 ec 0c             	sub    $0xc,%esp
  100a76:	51                   	push   %ecx
  100a77:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a7d:	51                   	push   %ecx
  100a7e:	52                   	push   %edx
  100a7f:	50                   	push   %eax
  100a80:	68 e2 39 10 00       	push   $0x1039e2
  100a85:	e8 0b f8 ff ff       	call   100295 <cprintf>
  100a8a:	83 c4 20             	add    $0x20,%esp
}
  100a8d:	90                   	nop
  100a8e:	c9                   	leave  
  100a8f:	c3                   	ret    

00100a90 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a90:	f3 0f 1e fb          	endbr32 
  100a94:	55                   	push   %ebp
  100a95:	89 e5                	mov    %esp,%ebp
  100a97:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a9a:	8b 45 04             	mov    0x4(%ebp),%eax
  100a9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100aa0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100aa3:	c9                   	leave  
  100aa4:	c3                   	ret    

00100aa5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100aa5:	f3 0f 1e fb          	endbr32 
  100aa9:	55                   	push   %ebp
  100aaa:	89 e5                	mov    %esp,%ebp
  100aac:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100aaf:	89 e8                	mov    %ebp,%eax
  100ab1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100ab4:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  100ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100aba:	e8 d1 ff ff ff       	call   100a90 <read_eip>
  100abf:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100ac2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100ac9:	e9 8d 00 00 00       	jmp    100b5b <print_stackframe+0xb6>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100ace:	83 ec 04             	sub    $0x4,%esp
  100ad1:	ff 75 f0             	pushl  -0x10(%ebp)
  100ad4:	ff 75 f4             	pushl  -0xc(%ebp)
  100ad7:	68 f4 39 10 00       	push   $0x1039f4
  100adc:	e8 b4 f7 ff ff       	call   100295 <cprintf>
  100ae1:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
  100ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ae7:	83 c0 08             	add    $0x8,%eax
  100aea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100aed:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100af4:	eb 26                	jmp    100b1c <print_stackframe+0x77>
            cprintf("0x%08x ", args[j]);
  100af6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100af9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b03:	01 d0                	add    %edx,%eax
  100b05:	8b 00                	mov    (%eax),%eax
  100b07:	83 ec 08             	sub    $0x8,%esp
  100b0a:	50                   	push   %eax
  100b0b:	68 10 3a 10 00       	push   $0x103a10
  100b10:	e8 80 f7 ff ff       	call   100295 <cprintf>
  100b15:	83 c4 10             	add    $0x10,%esp
        for (j = 0; j < 4; j ++) {
  100b18:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100b1c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b20:	7e d4                	jle    100af6 <print_stackframe+0x51>
        }
        cprintf("\n");
  100b22:	83 ec 0c             	sub    $0xc,%esp
  100b25:	68 18 3a 10 00       	push   $0x103a18
  100b2a:	e8 66 f7 ff ff       	call   100295 <cprintf>
  100b2f:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
  100b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b35:	83 e8 01             	sub    $0x1,%eax
  100b38:	83 ec 0c             	sub    $0xc,%esp
  100b3b:	50                   	push   %eax
  100b3c:	e8 af fe ff ff       	call   1009f0 <print_debuginfo>
  100b41:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
  100b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b47:	83 c0 04             	add    $0x4,%eax
  100b4a:	8b 00                	mov    (%eax),%eax
  100b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b52:	8b 00                	mov    (%eax),%eax
  100b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100b57:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100b5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b5f:	74 0a                	je     100b6b <print_stackframe+0xc6>
  100b61:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b65:	0f 8e 63 ff ff ff    	jle    100ace <print_stackframe+0x29>
    }
}
  100b6b:	90                   	nop
  100b6c:	c9                   	leave  
  100b6d:	c3                   	ret    

00100b6e <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b6e:	f3 0f 1e fb          	endbr32 
  100b72:	55                   	push   %ebp
  100b73:	89 e5                	mov    %esp,%ebp
  100b75:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
  100b78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b7f:	eb 0c                	jmp    100b8d <parse+0x1f>
            *buf ++ = '\0';
  100b81:	8b 45 08             	mov    0x8(%ebp),%eax
  100b84:	8d 50 01             	lea    0x1(%eax),%edx
  100b87:	89 55 08             	mov    %edx,0x8(%ebp)
  100b8a:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  100b90:	0f b6 00             	movzbl (%eax),%eax
  100b93:	84 c0                	test   %al,%al
  100b95:	74 1e                	je     100bb5 <parse+0x47>
  100b97:	8b 45 08             	mov    0x8(%ebp),%eax
  100b9a:	0f b6 00             	movzbl (%eax),%eax
  100b9d:	0f be c0             	movsbl %al,%eax
  100ba0:	83 ec 08             	sub    $0x8,%esp
  100ba3:	50                   	push   %eax
  100ba4:	68 9c 3a 10 00       	push   $0x103a9c
  100ba9:	e8 c8 22 00 00       	call   102e76 <strchr>
  100bae:	83 c4 10             	add    $0x10,%esp
  100bb1:	85 c0                	test   %eax,%eax
  100bb3:	75 cc                	jne    100b81 <parse+0x13>
        }
        if (*buf == '\0') {
  100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb8:	0f b6 00             	movzbl (%eax),%eax
  100bbb:	84 c0                	test   %al,%al
  100bbd:	74 65                	je     100c24 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bbf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bc3:	75 12                	jne    100bd7 <parse+0x69>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bc5:	83 ec 08             	sub    $0x8,%esp
  100bc8:	6a 10                	push   $0x10
  100bca:	68 a1 3a 10 00       	push   $0x103aa1
  100bcf:	e8 c1 f6 ff ff       	call   100295 <cprintf>
  100bd4:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
  100bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bda:	8d 50 01             	lea    0x1(%eax),%edx
  100bdd:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100be0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bea:	01 c2                	add    %eax,%edx
  100bec:	8b 45 08             	mov    0x8(%ebp),%eax
  100bef:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bf1:	eb 04                	jmp    100bf7 <parse+0x89>
            buf ++;
  100bf3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  100bfa:	0f b6 00             	movzbl (%eax),%eax
  100bfd:	84 c0                	test   %al,%al
  100bff:	74 8c                	je     100b8d <parse+0x1f>
  100c01:	8b 45 08             	mov    0x8(%ebp),%eax
  100c04:	0f b6 00             	movzbl (%eax),%eax
  100c07:	0f be c0             	movsbl %al,%eax
  100c0a:	83 ec 08             	sub    $0x8,%esp
  100c0d:	50                   	push   %eax
  100c0e:	68 9c 3a 10 00       	push   $0x103a9c
  100c13:	e8 5e 22 00 00       	call   102e76 <strchr>
  100c18:	83 c4 10             	add    $0x10,%esp
  100c1b:	85 c0                	test   %eax,%eax
  100c1d:	74 d4                	je     100bf3 <parse+0x85>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c1f:	e9 69 ff ff ff       	jmp    100b8d <parse+0x1f>
            break;
  100c24:	90                   	nop
        }
    }
    return argc;
  100c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c28:	c9                   	leave  
  100c29:	c3                   	ret    

00100c2a <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c2a:	f3 0f 1e fb          	endbr32 
  100c2e:	55                   	push   %ebp
  100c2f:	89 e5                	mov    %esp,%ebp
  100c31:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c34:	83 ec 08             	sub    $0x8,%esp
  100c37:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c3a:	50                   	push   %eax
  100c3b:	ff 75 08             	pushl  0x8(%ebp)
  100c3e:	e8 2b ff ff ff       	call   100b6e <parse>
  100c43:	83 c4 10             	add    $0x10,%esp
  100c46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c4d:	75 0a                	jne    100c59 <runcmd+0x2f>
        return 0;
  100c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  100c54:	e9 83 00 00 00       	jmp    100cdc <runcmd+0xb2>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c60:	eb 59                	jmp    100cbb <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c62:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c68:	89 d0                	mov    %edx,%eax
  100c6a:	01 c0                	add    %eax,%eax
  100c6c:	01 d0                	add    %edx,%eax
  100c6e:	c1 e0 02             	shl    $0x2,%eax
  100c71:	05 00 00 11 00       	add    $0x110000,%eax
  100c76:	8b 00                	mov    (%eax),%eax
  100c78:	83 ec 08             	sub    $0x8,%esp
  100c7b:	51                   	push   %ecx
  100c7c:	50                   	push   %eax
  100c7d:	e8 4d 21 00 00       	call   102dcf <strcmp>
  100c82:	83 c4 10             	add    $0x10,%esp
  100c85:	85 c0                	test   %eax,%eax
  100c87:	75 2e                	jne    100cb7 <runcmd+0x8d>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c8c:	89 d0                	mov    %edx,%eax
  100c8e:	01 c0                	add    %eax,%eax
  100c90:	01 d0                	add    %edx,%eax
  100c92:	c1 e0 02             	shl    $0x2,%eax
  100c95:	05 08 00 11 00       	add    $0x110008,%eax
  100c9a:	8b 10                	mov    (%eax),%edx
  100c9c:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c9f:	83 c0 04             	add    $0x4,%eax
  100ca2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100ca5:	83 e9 01             	sub    $0x1,%ecx
  100ca8:	83 ec 04             	sub    $0x4,%esp
  100cab:	ff 75 0c             	pushl  0xc(%ebp)
  100cae:	50                   	push   %eax
  100caf:	51                   	push   %ecx
  100cb0:	ff d2                	call   *%edx
  100cb2:	83 c4 10             	add    $0x10,%esp
  100cb5:	eb 25                	jmp    100cdc <runcmd+0xb2>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cb7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cbe:	83 f8 02             	cmp    $0x2,%eax
  100cc1:	76 9f                	jbe    100c62 <runcmd+0x38>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cc3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100cc6:	83 ec 08             	sub    $0x8,%esp
  100cc9:	50                   	push   %eax
  100cca:	68 bf 3a 10 00       	push   $0x103abf
  100ccf:	e8 c1 f5 ff ff       	call   100295 <cprintf>
  100cd4:	83 c4 10             	add    $0x10,%esp
    return 0;
  100cd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cdc:	c9                   	leave  
  100cdd:	c3                   	ret    

00100cde <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cde:	f3 0f 1e fb          	endbr32 
  100ce2:	55                   	push   %ebp
  100ce3:	89 e5                	mov    %esp,%ebp
  100ce5:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100ce8:	83 ec 0c             	sub    $0xc,%esp
  100ceb:	68 d8 3a 10 00       	push   $0x103ad8
  100cf0:	e8 a0 f5 ff ff       	call   100295 <cprintf>
  100cf5:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
  100cf8:	83 ec 0c             	sub    $0xc,%esp
  100cfb:	68 00 3b 10 00       	push   $0x103b00
  100d00:	e8 90 f5 ff ff       	call   100295 <cprintf>
  100d05:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
  100d08:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d0c:	74 0e                	je     100d1c <kmonitor+0x3e>
        print_trapframe(tf);
  100d0e:	83 ec 0c             	sub    $0xc,%esp
  100d11:	ff 75 08             	pushl  0x8(%ebp)
  100d14:	e8 e1 0d 00 00       	call   101afa <print_trapframe>
  100d19:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100d1c:	83 ec 0c             	sub    $0xc,%esp
  100d1f:	68 25 3b 10 00       	push   $0x103b25
  100d24:	e8 21 f6 ff ff       	call   10034a <readline>
  100d29:	83 c4 10             	add    $0x10,%esp
  100d2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d33:	74 e7                	je     100d1c <kmonitor+0x3e>
            if (runcmd(buf, tf) < 0) {
  100d35:	83 ec 08             	sub    $0x8,%esp
  100d38:	ff 75 08             	pushl  0x8(%ebp)
  100d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  100d3e:	e8 e7 fe ff ff       	call   100c2a <runcmd>
  100d43:	83 c4 10             	add    $0x10,%esp
  100d46:	85 c0                	test   %eax,%eax
  100d48:	78 02                	js     100d4c <kmonitor+0x6e>
        if ((buf = readline("K> ")) != NULL) {
  100d4a:	eb d0                	jmp    100d1c <kmonitor+0x3e>
                break;
  100d4c:	90                   	nop
            }
        }
    }
}
  100d4d:	90                   	nop
  100d4e:	c9                   	leave  
  100d4f:	c3                   	ret    

00100d50 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d50:	f3 0f 1e fb          	endbr32 
  100d54:	55                   	push   %ebp
  100d55:	89 e5                	mov    %esp,%ebp
  100d57:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d61:	eb 3c                	jmp    100d9f <mon_help+0x4f>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d66:	89 d0                	mov    %edx,%eax
  100d68:	01 c0                	add    %eax,%eax
  100d6a:	01 d0                	add    %edx,%eax
  100d6c:	c1 e0 02             	shl    $0x2,%eax
  100d6f:	05 04 00 11 00       	add    $0x110004,%eax
  100d74:	8b 08                	mov    (%eax),%ecx
  100d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d79:	89 d0                	mov    %edx,%eax
  100d7b:	01 c0                	add    %eax,%eax
  100d7d:	01 d0                	add    %edx,%eax
  100d7f:	c1 e0 02             	shl    $0x2,%eax
  100d82:	05 00 00 11 00       	add    $0x110000,%eax
  100d87:	8b 00                	mov    (%eax),%eax
  100d89:	83 ec 04             	sub    $0x4,%esp
  100d8c:	51                   	push   %ecx
  100d8d:	50                   	push   %eax
  100d8e:	68 29 3b 10 00       	push   $0x103b29
  100d93:	e8 fd f4 ff ff       	call   100295 <cprintf>
  100d98:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < NCOMMANDS; i ++) {
  100d9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100da2:	83 f8 02             	cmp    $0x2,%eax
  100da5:	76 bc                	jbe    100d63 <mon_help+0x13>
    }
    return 0;
  100da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dac:	c9                   	leave  
  100dad:	c3                   	ret    

00100dae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100dae:	f3 0f 1e fb          	endbr32 
  100db2:	55                   	push   %ebp
  100db3:	89 e5                	mov    %esp,%ebp
  100db5:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100db8:	e8 94 fb ff ff       	call   100951 <print_kerninfo>
    return 0;
  100dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dc2:	c9                   	leave  
  100dc3:	c3                   	ret    

00100dc4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100dc4:	f3 0f 1e fb          	endbr32 
  100dc8:	55                   	push   %ebp
  100dc9:	89 e5                	mov    %esp,%ebp
  100dcb:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100dce:	e8 d2 fc ff ff       	call   100aa5 <print_stackframe>
    return 0;
  100dd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dd8:	c9                   	leave  
  100dd9:	c3                   	ret    

00100dda <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dda:	f3 0f 1e fb          	endbr32 
  100dde:	55                   	push   %ebp
  100ddf:	89 e5                	mov    %esp,%ebp
  100de1:	83 ec 18             	sub    $0x18,%esp
  100de4:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dea:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dee:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100df2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100df6:	ee                   	out    %al,(%dx)
}
  100df7:	90                   	nop
  100df8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dfe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e02:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e06:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e0a:	ee                   	out    %al,(%dx)
}
  100e0b:	90                   	nop
  100e0c:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e12:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e16:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e1a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e1e:	ee                   	out    %al,(%dx)
}
  100e1f:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e20:	c7 05 08 19 11 00 00 	movl   $0x0,0x111908
  100e27:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e2a:	83 ec 0c             	sub    $0xc,%esp
  100e2d:	68 32 3b 10 00       	push   $0x103b32
  100e32:	e8 5e f4 ff ff       	call   100295 <cprintf>
  100e37:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
  100e3a:	83 ec 0c             	sub    $0xc,%esp
  100e3d:	6a 00                	push   $0x0
  100e3f:	e8 39 09 00 00       	call   10177d <pic_enable>
  100e44:	83 c4 10             	add    $0x10,%esp
}
  100e47:	90                   	nop
  100e48:	c9                   	leave  
  100e49:	c3                   	ret    

00100e4a <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e4a:	f3 0f 1e fb          	endbr32 
  100e4e:	55                   	push   %ebp
  100e4f:	89 e5                	mov    %esp,%ebp
  100e51:	83 ec 10             	sub    $0x10,%esp
  100e54:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e5a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e5e:	89 c2                	mov    %eax,%edx
  100e60:	ec                   	in     (%dx),%al
  100e61:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e64:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e6a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e6e:	89 c2                	mov    %eax,%edx
  100e70:	ec                   	in     (%dx),%al
  100e71:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e74:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e7a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e7e:	89 c2                	mov    %eax,%edx
  100e80:	ec                   	in     (%dx),%al
  100e81:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e84:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e8a:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e8e:	89 c2                	mov    %eax,%edx
  100e90:	ec                   	in     (%dx),%al
  100e91:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e94:	90                   	nop
  100e95:	c9                   	leave  
  100e96:	c3                   	ret    

00100e97 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e97:	f3 0f 1e fb          	endbr32 
  100e9b:	55                   	push   %ebp
  100e9c:	89 e5                	mov    %esp,%ebp
  100e9e:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;
  100ea1:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ea8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eab:	0f b7 00             	movzwl (%eax),%eax
  100eae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb5:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eba:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebd:	0f b7 00             	movzwl (%eax),%eax
  100ec0:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100ec4:	74 12                	je     100ed8 <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;
  100ec6:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ecd:	66 c7 05 66 0e 11 00 	movw   $0x3b4,0x110e66
  100ed4:	b4 03 
  100ed6:	eb 13                	jmp    100eeb <cga_init+0x54>
    } else {
        *cp = was;
  100ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100edf:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee2:	66 c7 05 66 0e 11 00 	movw   $0x3d4,0x110e66
  100ee9:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eeb:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  100ef2:	0f b7 c0             	movzwl %ax,%eax
  100ef5:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ef9:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100efd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f01:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f05:	ee                   	out    %al,(%dx)
}
  100f06:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f07:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  100f0e:	83 c0 01             	add    $0x1,%eax
  100f11:	0f b7 c0             	movzwl %ax,%eax
  100f14:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f18:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f1c:	89 c2                	mov    %eax,%edx
  100f1e:	ec                   	in     (%dx),%al
  100f1f:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f22:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f26:	0f b6 c0             	movzbl %al,%eax
  100f29:	c1 e0 08             	shl    $0x8,%eax
  100f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f2f:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  100f36:	0f b7 c0             	movzwl %ax,%eax
  100f39:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f3d:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f41:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f45:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f49:	ee                   	out    %al,(%dx)
}
  100f4a:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f4b:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  100f52:	83 c0 01             	add    $0x1,%eax
  100f55:	0f b7 c0             	movzwl %ax,%eax
  100f58:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f5c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f60:	89 c2                	mov    %eax,%edx
  100f62:	ec                   	in     (%dx),%al
  100f63:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f66:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f6a:	0f b6 c0             	movzbl %al,%eax
  100f6d:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f73:	a3 60 0e 11 00       	mov    %eax,0x110e60
    crt_pos = pos;
  100f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f7b:	66 a3 64 0e 11 00    	mov    %ax,0x110e64
}
  100f81:	90                   	nop
  100f82:	c9                   	leave  
  100f83:	c3                   	ret    

00100f84 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f84:	f3 0f 1e fb          	endbr32 
  100f88:	55                   	push   %ebp
  100f89:	89 e5                	mov    %esp,%ebp
  100f8b:	83 ec 38             	sub    $0x38,%esp
  100f8e:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f94:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f98:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f9c:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fa0:	ee                   	out    %al,(%dx)
}
  100fa1:	90                   	nop
  100fa2:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100fa8:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fac:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fb0:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fb4:	ee                   	out    %al,(%dx)
}
  100fb5:	90                   	nop
  100fb6:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fbc:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fc0:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fc4:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fc8:	ee                   	out    %al,(%dx)
}
  100fc9:	90                   	nop
  100fca:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fd0:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fd4:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fd8:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fdc:	ee                   	out    %al,(%dx)
}
  100fdd:	90                   	nop
  100fde:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fe4:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fe8:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fec:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ff0:	ee                   	out    %al,(%dx)
}
  100ff1:	90                   	nop
  100ff2:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100ff8:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ffc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101000:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101004:	ee                   	out    %al,(%dx)
}
  101005:	90                   	nop
  101006:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  10100c:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101010:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101014:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101018:	ee                   	out    %al,(%dx)
}
  101019:	90                   	nop
  10101a:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101020:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101024:	89 c2                	mov    %eax,%edx
  101026:	ec                   	in     (%dx),%al
  101027:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  10102a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10102e:	3c ff                	cmp    $0xff,%al
  101030:	0f 95 c0             	setne  %al
  101033:	0f b6 c0             	movzbl %al,%eax
  101036:	a3 68 0e 11 00       	mov    %eax,0x110e68
  10103b:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101041:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101045:	89 c2                	mov    %eax,%edx
  101047:	ec                   	in     (%dx),%al
  101048:	88 45 f1             	mov    %al,-0xf(%ebp)
  10104b:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101051:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101055:	89 c2                	mov    %eax,%edx
  101057:	ec                   	in     (%dx),%al
  101058:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10105b:	a1 68 0e 11 00       	mov    0x110e68,%eax
  101060:	85 c0                	test   %eax,%eax
  101062:	74 0d                	je     101071 <serial_init+0xed>
        pic_enable(IRQ_COM1);
  101064:	83 ec 0c             	sub    $0xc,%esp
  101067:	6a 04                	push   $0x4
  101069:	e8 0f 07 00 00       	call   10177d <pic_enable>
  10106e:	83 c4 10             	add    $0x10,%esp
    }
}
  101071:	90                   	nop
  101072:	c9                   	leave  
  101073:	c3                   	ret    

00101074 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101074:	f3 0f 1e fb          	endbr32 
  101078:	55                   	push   %ebp
  101079:	89 e5                	mov    %esp,%ebp
  10107b:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10107e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101085:	eb 09                	jmp    101090 <lpt_putc_sub+0x1c>
        delay();
  101087:	e8 be fd ff ff       	call   100e4a <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10108c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101090:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101096:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10109a:	89 c2                	mov    %eax,%edx
  10109c:	ec                   	in     (%dx),%al
  10109d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1010a0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010a4:	84 c0                	test   %al,%al
  1010a6:	78 09                	js     1010b1 <lpt_putc_sub+0x3d>
  1010a8:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010af:	7e d6                	jle    101087 <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
  1010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  1010b4:	0f b6 c0             	movzbl %al,%eax
  1010b7:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010bd:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010c0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010c8:	ee                   	out    %al,(%dx)
}
  1010c9:	90                   	nop
  1010ca:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010d0:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010d4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010d8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010dc:	ee                   	out    %al,(%dx)
}
  1010dd:	90                   	nop
  1010de:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010e4:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010e8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010ec:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010f0:	ee                   	out    %al,(%dx)
}
  1010f1:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010f2:	90                   	nop
  1010f3:	c9                   	leave  
  1010f4:	c3                   	ret    

001010f5 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010f5:	f3 0f 1e fb          	endbr32 
  1010f9:	55                   	push   %ebp
  1010fa:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  1010fc:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101100:	74 0d                	je     10110f <lpt_putc+0x1a>
        lpt_putc_sub(c);
  101102:	ff 75 08             	pushl  0x8(%ebp)
  101105:	e8 6a ff ff ff       	call   101074 <lpt_putc_sub>
  10110a:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  10110d:	eb 1e                	jmp    10112d <lpt_putc+0x38>
        lpt_putc_sub('\b');
  10110f:	6a 08                	push   $0x8
  101111:	e8 5e ff ff ff       	call   101074 <lpt_putc_sub>
  101116:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
  101119:	6a 20                	push   $0x20
  10111b:	e8 54 ff ff ff       	call   101074 <lpt_putc_sub>
  101120:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
  101123:	6a 08                	push   $0x8
  101125:	e8 4a ff ff ff       	call   101074 <lpt_putc_sub>
  10112a:	83 c4 04             	add    $0x4,%esp
}
  10112d:	90                   	nop
  10112e:	c9                   	leave  
  10112f:	c3                   	ret    

00101130 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101130:	f3 0f 1e fb          	endbr32 
  101134:	55                   	push   %ebp
  101135:	89 e5                	mov    %esp,%ebp
  101137:	53                   	push   %ebx
  101138:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  10113b:	8b 45 08             	mov    0x8(%ebp),%eax
  10113e:	b0 00                	mov    $0x0,%al
  101140:	85 c0                	test   %eax,%eax
  101142:	75 07                	jne    10114b <cga_putc+0x1b>
        c |= 0x0700;
  101144:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10114b:	8b 45 08             	mov    0x8(%ebp),%eax
  10114e:	0f b6 c0             	movzbl %al,%eax
  101151:	83 f8 0d             	cmp    $0xd,%eax
  101154:	74 6c                	je     1011c2 <cga_putc+0x92>
  101156:	83 f8 0d             	cmp    $0xd,%eax
  101159:	0f 8f 9d 00 00 00    	jg     1011fc <cga_putc+0xcc>
  10115f:	83 f8 08             	cmp    $0x8,%eax
  101162:	74 0a                	je     10116e <cga_putc+0x3e>
  101164:	83 f8 0a             	cmp    $0xa,%eax
  101167:	74 49                	je     1011b2 <cga_putc+0x82>
  101169:	e9 8e 00 00 00       	jmp    1011fc <cga_putc+0xcc>
    case '\b':
        if (crt_pos > 0) {
  10116e:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  101175:	66 85 c0             	test   %ax,%ax
  101178:	0f 84 a4 00 00 00    	je     101222 <cga_putc+0xf2>
            crt_pos --;
  10117e:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  101185:	83 e8 01             	sub    $0x1,%eax
  101188:	66 a3 64 0e 11 00    	mov    %ax,0x110e64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10118e:	8b 45 08             	mov    0x8(%ebp),%eax
  101191:	b0 00                	mov    $0x0,%al
  101193:	83 c8 20             	or     $0x20,%eax
  101196:	89 c1                	mov    %eax,%ecx
  101198:	a1 60 0e 11 00       	mov    0x110e60,%eax
  10119d:	0f b7 15 64 0e 11 00 	movzwl 0x110e64,%edx
  1011a4:	0f b7 d2             	movzwl %dx,%edx
  1011a7:	01 d2                	add    %edx,%edx
  1011a9:	01 d0                	add    %edx,%eax
  1011ab:	89 ca                	mov    %ecx,%edx
  1011ad:	66 89 10             	mov    %dx,(%eax)
        }
        break;
  1011b0:	eb 70                	jmp    101222 <cga_putc+0xf2>
    case '\n':
        crt_pos += CRT_COLS;
  1011b2:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  1011b9:	83 c0 50             	add    $0x50,%eax
  1011bc:	66 a3 64 0e 11 00    	mov    %ax,0x110e64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011c2:	0f b7 1d 64 0e 11 00 	movzwl 0x110e64,%ebx
  1011c9:	0f b7 0d 64 0e 11 00 	movzwl 0x110e64,%ecx
  1011d0:	0f b7 c1             	movzwl %cx,%eax
  1011d3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  1011d9:	c1 e8 10             	shr    $0x10,%eax
  1011dc:	89 c2                	mov    %eax,%edx
  1011de:	66 c1 ea 06          	shr    $0x6,%dx
  1011e2:	89 d0                	mov    %edx,%eax
  1011e4:	c1 e0 02             	shl    $0x2,%eax
  1011e7:	01 d0                	add    %edx,%eax
  1011e9:	c1 e0 04             	shl    $0x4,%eax
  1011ec:	29 c1                	sub    %eax,%ecx
  1011ee:	89 ca                	mov    %ecx,%edx
  1011f0:	89 d8                	mov    %ebx,%eax
  1011f2:	29 d0                	sub    %edx,%eax
  1011f4:	66 a3 64 0e 11 00    	mov    %ax,0x110e64
        break;
  1011fa:	eb 27                	jmp    101223 <cga_putc+0xf3>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011fc:	8b 0d 60 0e 11 00    	mov    0x110e60,%ecx
  101202:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  101209:	8d 50 01             	lea    0x1(%eax),%edx
  10120c:	66 89 15 64 0e 11 00 	mov    %dx,0x110e64
  101213:	0f b7 c0             	movzwl %ax,%eax
  101216:	01 c0                	add    %eax,%eax
  101218:	01 c8                	add    %ecx,%eax
  10121a:	8b 55 08             	mov    0x8(%ebp),%edx
  10121d:	66 89 10             	mov    %dx,(%eax)
        break;
  101220:	eb 01                	jmp    101223 <cga_putc+0xf3>
        break;
  101222:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101223:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  10122a:	66 3d cf 07          	cmp    $0x7cf,%ax
  10122e:	76 59                	jbe    101289 <cga_putc+0x159>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101230:	a1 60 0e 11 00       	mov    0x110e60,%eax
  101235:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10123b:	a1 60 0e 11 00       	mov    0x110e60,%eax
  101240:	83 ec 04             	sub    $0x4,%esp
  101243:	68 00 0f 00 00       	push   $0xf00
  101248:	52                   	push   %edx
  101249:	50                   	push   %eax
  10124a:	e8 35 1e 00 00       	call   103084 <memmove>
  10124f:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101252:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101259:	eb 15                	jmp    101270 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  10125b:	a1 60 0e 11 00       	mov    0x110e60,%eax
  101260:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101263:	01 d2                	add    %edx,%edx
  101265:	01 d0                	add    %edx,%eax
  101267:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10126c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101270:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101277:	7e e2                	jle    10125b <cga_putc+0x12b>
        }
        crt_pos -= CRT_COLS;
  101279:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  101280:	83 e8 50             	sub    $0x50,%eax
  101283:	66 a3 64 0e 11 00    	mov    %ax,0x110e64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101289:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  101290:	0f b7 c0             	movzwl %ax,%eax
  101293:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101297:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10129b:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10129f:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012a3:	ee                   	out    %al,(%dx)
}
  1012a4:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012a5:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  1012ac:	66 c1 e8 08          	shr    $0x8,%ax
  1012b0:	0f b6 c0             	movzbl %al,%eax
  1012b3:	0f b7 15 66 0e 11 00 	movzwl 0x110e66,%edx
  1012ba:	83 c2 01             	add    $0x1,%edx
  1012bd:	0f b7 d2             	movzwl %dx,%edx
  1012c0:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012c4:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012c7:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012cb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012cf:	ee                   	out    %al,(%dx)
}
  1012d0:	90                   	nop
    outb(addr_6845, 15);
  1012d1:	0f b7 05 66 0e 11 00 	movzwl 0x110e66,%eax
  1012d8:	0f b7 c0             	movzwl %ax,%eax
  1012db:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012df:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012e3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012e7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012eb:	ee                   	out    %al,(%dx)
}
  1012ec:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012ed:	0f b7 05 64 0e 11 00 	movzwl 0x110e64,%eax
  1012f4:	0f b6 c0             	movzbl %al,%eax
  1012f7:	0f b7 15 66 0e 11 00 	movzwl 0x110e66,%edx
  1012fe:	83 c2 01             	add    $0x1,%edx
  101301:	0f b7 d2             	movzwl %dx,%edx
  101304:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101308:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10130b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10130f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101313:	ee                   	out    %al,(%dx)
}
  101314:	90                   	nop
}
  101315:	90                   	nop
  101316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101319:	c9                   	leave  
  10131a:	c3                   	ret    

0010131b <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  10131b:	f3 0f 1e fb          	endbr32 
  10131f:	55                   	push   %ebp
  101320:	89 e5                	mov    %esp,%ebp
  101322:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101325:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10132c:	eb 09                	jmp    101337 <serial_putc_sub+0x1c>
        delay();
  10132e:	e8 17 fb ff ff       	call   100e4a <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101333:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101337:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10133d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101341:	89 c2                	mov    %eax,%edx
  101343:	ec                   	in     (%dx),%al
  101344:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101347:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10134b:	0f b6 c0             	movzbl %al,%eax
  10134e:	83 e0 20             	and    $0x20,%eax
  101351:	85 c0                	test   %eax,%eax
  101353:	75 09                	jne    10135e <serial_putc_sub+0x43>
  101355:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10135c:	7e d0                	jle    10132e <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
  10135e:	8b 45 08             	mov    0x8(%ebp),%eax
  101361:	0f b6 c0             	movzbl %al,%eax
  101364:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10136a:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10136d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101371:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101375:	ee                   	out    %al,(%dx)
}
  101376:	90                   	nop
}
  101377:	90                   	nop
  101378:	c9                   	leave  
  101379:	c3                   	ret    

0010137a <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10137a:	f3 0f 1e fb          	endbr32 
  10137e:	55                   	push   %ebp
  10137f:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
  101381:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101385:	74 0d                	je     101394 <serial_putc+0x1a>
        serial_putc_sub(c);
  101387:	ff 75 08             	pushl  0x8(%ebp)
  10138a:	e8 8c ff ff ff       	call   10131b <serial_putc_sub>
  10138f:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101392:	eb 1e                	jmp    1013b2 <serial_putc+0x38>
        serial_putc_sub('\b');
  101394:	6a 08                	push   $0x8
  101396:	e8 80 ff ff ff       	call   10131b <serial_putc_sub>
  10139b:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
  10139e:	6a 20                	push   $0x20
  1013a0:	e8 76 ff ff ff       	call   10131b <serial_putc_sub>
  1013a5:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
  1013a8:	6a 08                	push   $0x8
  1013aa:	e8 6c ff ff ff       	call   10131b <serial_putc_sub>
  1013af:	83 c4 04             	add    $0x4,%esp
}
  1013b2:	90                   	nop
  1013b3:	c9                   	leave  
  1013b4:	c3                   	ret    

001013b5 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013b5:	f3 0f 1e fb          	endbr32 
  1013b9:	55                   	push   %ebp
  1013ba:	89 e5                	mov    %esp,%ebp
  1013bc:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013bf:	eb 33                	jmp    1013f4 <cons_intr+0x3f>
        if (c != 0) {
  1013c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013c5:	74 2d                	je     1013f4 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
  1013c7:	a1 84 10 11 00       	mov    0x111084,%eax
  1013cc:	8d 50 01             	lea    0x1(%eax),%edx
  1013cf:	89 15 84 10 11 00    	mov    %edx,0x111084
  1013d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013d8:	88 90 80 0e 11 00    	mov    %dl,0x110e80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013de:	a1 84 10 11 00       	mov    0x111084,%eax
  1013e3:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013e8:	75 0a                	jne    1013f4 <cons_intr+0x3f>
                cons.wpos = 0;
  1013ea:	c7 05 84 10 11 00 00 	movl   $0x0,0x111084
  1013f1:	00 00 00 
    while ((c = (*proc)()) != -1) {
  1013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1013f7:	ff d0                	call   *%eax
  1013f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013fc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101400:	75 bf                	jne    1013c1 <cons_intr+0xc>
            }
        }
    }
}
  101402:	90                   	nop
  101403:	90                   	nop
  101404:	c9                   	leave  
  101405:	c3                   	ret    

00101406 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101406:	f3 0f 1e fb          	endbr32 
  10140a:	55                   	push   %ebp
  10140b:	89 e5                	mov    %esp,%ebp
  10140d:	83 ec 10             	sub    $0x10,%esp
  101410:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101416:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10141a:	89 c2                	mov    %eax,%edx
  10141c:	ec                   	in     (%dx),%al
  10141d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101420:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101424:	0f b6 c0             	movzbl %al,%eax
  101427:	83 e0 01             	and    $0x1,%eax
  10142a:	85 c0                	test   %eax,%eax
  10142c:	75 07                	jne    101435 <serial_proc_data+0x2f>
        return -1;
  10142e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101433:	eb 2a                	jmp    10145f <serial_proc_data+0x59>
  101435:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10143b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10143f:	89 c2                	mov    %eax,%edx
  101441:	ec                   	in     (%dx),%al
  101442:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101445:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101449:	0f b6 c0             	movzbl %al,%eax
  10144c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10144f:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101453:	75 07                	jne    10145c <serial_proc_data+0x56>
        c = '\b';
  101455:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10145c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10145f:	c9                   	leave  
  101460:	c3                   	ret    

00101461 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  101461:	f3 0f 1e fb          	endbr32 
  101465:	55                   	push   %ebp
  101466:	89 e5                	mov    %esp,%ebp
  101468:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
  10146b:	a1 68 0e 11 00       	mov    0x110e68,%eax
  101470:	85 c0                	test   %eax,%eax
  101472:	74 10                	je     101484 <serial_intr+0x23>
        cons_intr(serial_proc_data);
  101474:	83 ec 0c             	sub    $0xc,%esp
  101477:	68 06 14 10 00       	push   $0x101406
  10147c:	e8 34 ff ff ff       	call   1013b5 <cons_intr>
  101481:	83 c4 10             	add    $0x10,%esp
    }
}
  101484:	90                   	nop
  101485:	c9                   	leave  
  101486:	c3                   	ret    

00101487 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101487:	f3 0f 1e fb          	endbr32 
  10148b:	55                   	push   %ebp
  10148c:	89 e5                	mov    %esp,%ebp
  10148e:	83 ec 28             	sub    $0x28,%esp
  101491:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101497:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10149b:	89 c2                	mov    %eax,%edx
  10149d:	ec                   	in     (%dx),%al
  10149e:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014a1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014a5:	0f b6 c0             	movzbl %al,%eax
  1014a8:	83 e0 01             	and    $0x1,%eax
  1014ab:	85 c0                	test   %eax,%eax
  1014ad:	75 0a                	jne    1014b9 <kbd_proc_data+0x32>
        return -1;
  1014af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014b4:	e9 5e 01 00 00       	jmp    101617 <kbd_proc_data+0x190>
  1014b9:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1014bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1014c3:	89 c2                	mov    %eax,%edx
  1014c5:	ec                   	in     (%dx),%al
  1014c6:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014c9:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014cd:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014d0:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014d4:	75 17                	jne    1014ed <kbd_proc_data+0x66>
        // E0 escape character
        shift |= E0ESC;
  1014d6:	a1 88 10 11 00       	mov    0x111088,%eax
  1014db:	83 c8 40             	or     $0x40,%eax
  1014de:	a3 88 10 11 00       	mov    %eax,0x111088
        return 0;
  1014e3:	b8 00 00 00 00       	mov    $0x0,%eax
  1014e8:	e9 2a 01 00 00       	jmp    101617 <kbd_proc_data+0x190>
    } else if (data & 0x80) {
  1014ed:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f1:	84 c0                	test   %al,%al
  1014f3:	79 47                	jns    10153c <kbd_proc_data+0xb5>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014f5:	a1 88 10 11 00       	mov    0x111088,%eax
  1014fa:	83 e0 40             	and    $0x40,%eax
  1014fd:	85 c0                	test   %eax,%eax
  1014ff:	75 09                	jne    10150a <kbd_proc_data+0x83>
  101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101505:	83 e0 7f             	and    $0x7f,%eax
  101508:	eb 04                	jmp    10150e <kbd_proc_data+0x87>
  10150a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150e:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101511:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101515:	0f b6 80 40 00 11 00 	movzbl 0x110040(%eax),%eax
  10151c:	83 c8 40             	or     $0x40,%eax
  10151f:	0f b6 c0             	movzbl %al,%eax
  101522:	f7 d0                	not    %eax
  101524:	89 c2                	mov    %eax,%edx
  101526:	a1 88 10 11 00       	mov    0x111088,%eax
  10152b:	21 d0                	and    %edx,%eax
  10152d:	a3 88 10 11 00       	mov    %eax,0x111088
        return 0;
  101532:	b8 00 00 00 00       	mov    $0x0,%eax
  101537:	e9 db 00 00 00       	jmp    101617 <kbd_proc_data+0x190>
    } else if (shift & E0ESC) {
  10153c:	a1 88 10 11 00       	mov    0x111088,%eax
  101541:	83 e0 40             	and    $0x40,%eax
  101544:	85 c0                	test   %eax,%eax
  101546:	74 11                	je     101559 <kbd_proc_data+0xd2>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101548:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10154c:	a1 88 10 11 00       	mov    0x111088,%eax
  101551:	83 e0 bf             	and    $0xffffffbf,%eax
  101554:	a3 88 10 11 00       	mov    %eax,0x111088
    }

    shift |= shiftcode[data];
  101559:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10155d:	0f b6 80 40 00 11 00 	movzbl 0x110040(%eax),%eax
  101564:	0f b6 d0             	movzbl %al,%edx
  101567:	a1 88 10 11 00       	mov    0x111088,%eax
  10156c:	09 d0                	or     %edx,%eax
  10156e:	a3 88 10 11 00       	mov    %eax,0x111088
    shift ^= togglecode[data];
  101573:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101577:	0f b6 80 40 01 11 00 	movzbl 0x110140(%eax),%eax
  10157e:	0f b6 d0             	movzbl %al,%edx
  101581:	a1 88 10 11 00       	mov    0x111088,%eax
  101586:	31 d0                	xor    %edx,%eax
  101588:	a3 88 10 11 00       	mov    %eax,0x111088

    c = charcode[shift & (CTL | SHIFT)][data];
  10158d:	a1 88 10 11 00       	mov    0x111088,%eax
  101592:	83 e0 03             	and    $0x3,%eax
  101595:	8b 14 85 40 05 11 00 	mov    0x110540(,%eax,4),%edx
  10159c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a0:	01 d0                	add    %edx,%eax
  1015a2:	0f b6 00             	movzbl (%eax),%eax
  1015a5:	0f b6 c0             	movzbl %al,%eax
  1015a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015ab:	a1 88 10 11 00       	mov    0x111088,%eax
  1015b0:	83 e0 08             	and    $0x8,%eax
  1015b3:	85 c0                	test   %eax,%eax
  1015b5:	74 22                	je     1015d9 <kbd_proc_data+0x152>
        if ('a' <= c && c <= 'z')
  1015b7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015bb:	7e 0c                	jle    1015c9 <kbd_proc_data+0x142>
  1015bd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015c1:	7f 06                	jg     1015c9 <kbd_proc_data+0x142>
            c += 'A' - 'a';
  1015c3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015c7:	eb 10                	jmp    1015d9 <kbd_proc_data+0x152>
        else if ('A' <= c && c <= 'Z')
  1015c9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015cd:	7e 0a                	jle    1015d9 <kbd_proc_data+0x152>
  1015cf:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015d3:	7f 04                	jg     1015d9 <kbd_proc_data+0x152>
            c += 'a' - 'A';
  1015d5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015d9:	a1 88 10 11 00       	mov    0x111088,%eax
  1015de:	f7 d0                	not    %eax
  1015e0:	83 e0 06             	and    $0x6,%eax
  1015e3:	85 c0                	test   %eax,%eax
  1015e5:	75 2d                	jne    101614 <kbd_proc_data+0x18d>
  1015e7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015ee:	75 24                	jne    101614 <kbd_proc_data+0x18d>
        cprintf("Rebooting!\n");
  1015f0:	83 ec 0c             	sub    $0xc,%esp
  1015f3:	68 4d 3b 10 00       	push   $0x103b4d
  1015f8:	e8 98 ec ff ff       	call   100295 <cprintf>
  1015fd:	83 c4 10             	add    $0x10,%esp
  101600:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101606:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10160a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10160e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101612:	ee                   	out    %al,(%dx)
}
  101613:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101614:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101617:	c9                   	leave  
  101618:	c3                   	ret    

00101619 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101619:	f3 0f 1e fb          	endbr32 
  10161d:	55                   	push   %ebp
  10161e:	89 e5                	mov    %esp,%ebp
  101620:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
  101623:	83 ec 0c             	sub    $0xc,%esp
  101626:	68 87 14 10 00       	push   $0x101487
  10162b:	e8 85 fd ff ff       	call   1013b5 <cons_intr>
  101630:	83 c4 10             	add    $0x10,%esp
}
  101633:	90                   	nop
  101634:	c9                   	leave  
  101635:	c3                   	ret    

00101636 <kbd_init>:

static void
kbd_init(void) {
  101636:	f3 0f 1e fb          	endbr32 
  10163a:	55                   	push   %ebp
  10163b:	89 e5                	mov    %esp,%ebp
  10163d:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
  101640:	e8 d4 ff ff ff       	call   101619 <kbd_intr>
    pic_enable(IRQ_KBD);
  101645:	83 ec 0c             	sub    $0xc,%esp
  101648:	6a 01                	push   $0x1
  10164a:	e8 2e 01 00 00       	call   10177d <pic_enable>
  10164f:	83 c4 10             	add    $0x10,%esp
}
  101652:	90                   	nop
  101653:	c9                   	leave  
  101654:	c3                   	ret    

00101655 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101655:	f3 0f 1e fb          	endbr32 
  101659:	55                   	push   %ebp
  10165a:	89 e5                	mov    %esp,%ebp
  10165c:	83 ec 08             	sub    $0x8,%esp
    cga_init();
  10165f:	e8 33 f8 ff ff       	call   100e97 <cga_init>
    serial_init();
  101664:	e8 1b f9 ff ff       	call   100f84 <serial_init>
    kbd_init();
  101669:	e8 c8 ff ff ff       	call   101636 <kbd_init>
    if (!serial_exists) {
  10166e:	a1 68 0e 11 00       	mov    0x110e68,%eax
  101673:	85 c0                	test   %eax,%eax
  101675:	75 10                	jne    101687 <cons_init+0x32>
        cprintf("serial port does not exist!!\n");
  101677:	83 ec 0c             	sub    $0xc,%esp
  10167a:	68 59 3b 10 00       	push   $0x103b59
  10167f:	e8 11 ec ff ff       	call   100295 <cprintf>
  101684:	83 c4 10             	add    $0x10,%esp
    }
}
  101687:	90                   	nop
  101688:	c9                   	leave  
  101689:	c3                   	ret    

0010168a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10168a:	f3 0f 1e fb          	endbr32 
  10168e:	55                   	push   %ebp
  10168f:	89 e5                	mov    %esp,%ebp
  101691:	83 ec 08             	sub    $0x8,%esp
    lpt_putc(c);
  101694:	ff 75 08             	pushl  0x8(%ebp)
  101697:	e8 59 fa ff ff       	call   1010f5 <lpt_putc>
  10169c:	83 c4 04             	add    $0x4,%esp
    cga_putc(c);
  10169f:	83 ec 0c             	sub    $0xc,%esp
  1016a2:	ff 75 08             	pushl  0x8(%ebp)
  1016a5:	e8 86 fa ff ff       	call   101130 <cga_putc>
  1016aa:	83 c4 10             	add    $0x10,%esp
    serial_putc(c);
  1016ad:	83 ec 0c             	sub    $0xc,%esp
  1016b0:	ff 75 08             	pushl  0x8(%ebp)
  1016b3:	e8 c2 fc ff ff       	call   10137a <serial_putc>
  1016b8:	83 c4 10             	add    $0x10,%esp
}
  1016bb:	90                   	nop
  1016bc:	c9                   	leave  
  1016bd:	c3                   	ret    

001016be <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016be:	f3 0f 1e fb          	endbr32 
  1016c2:	55                   	push   %ebp
  1016c3:	89 e5                	mov    %esp,%ebp
  1016c5:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1016c8:	e8 94 fd ff ff       	call   101461 <serial_intr>
    kbd_intr();
  1016cd:	e8 47 ff ff ff       	call   101619 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1016d2:	8b 15 80 10 11 00    	mov    0x111080,%edx
  1016d8:	a1 84 10 11 00       	mov    0x111084,%eax
  1016dd:	39 c2                	cmp    %eax,%edx
  1016df:	74 36                	je     101717 <cons_getc+0x59>
        c = cons.buf[cons.rpos ++];
  1016e1:	a1 80 10 11 00       	mov    0x111080,%eax
  1016e6:	8d 50 01             	lea    0x1(%eax),%edx
  1016e9:	89 15 80 10 11 00    	mov    %edx,0x111080
  1016ef:	0f b6 80 80 0e 11 00 	movzbl 0x110e80(%eax),%eax
  1016f6:	0f b6 c0             	movzbl %al,%eax
  1016f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  1016fc:	a1 80 10 11 00       	mov    0x111080,%eax
  101701:	3d 00 02 00 00       	cmp    $0x200,%eax
  101706:	75 0a                	jne    101712 <cons_getc+0x54>
            cons.rpos = 0;
  101708:	c7 05 80 10 11 00 00 	movl   $0x0,0x111080
  10170f:	00 00 00 
        }
        return c;
  101712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101715:	eb 05                	jmp    10171c <cons_getc+0x5e>
    }
    return 0;
  101717:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10171c:	c9                   	leave  
  10171d:	c3                   	ret    

0010171e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  10171e:	f3 0f 1e fb          	endbr32 
  101722:	55                   	push   %ebp
  101723:	89 e5                	mov    %esp,%ebp
  101725:	83 ec 14             	sub    $0x14,%esp
  101728:	8b 45 08             	mov    0x8(%ebp),%eax
  10172b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10172f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101733:	66 a3 50 05 11 00    	mov    %ax,0x110550
    if (did_init) {
  101739:	a1 8c 10 11 00       	mov    0x11108c,%eax
  10173e:	85 c0                	test   %eax,%eax
  101740:	74 38                	je     10177a <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
  101742:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101746:	0f b6 c0             	movzbl %al,%eax
  101749:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10174f:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101752:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101756:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10175a:	ee                   	out    %al,(%dx)
}
  10175b:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  10175c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101760:	66 c1 e8 08          	shr    $0x8,%ax
  101764:	0f b6 c0             	movzbl %al,%eax
  101767:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10176d:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101770:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101774:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101778:	ee                   	out    %al,(%dx)
}
  101779:	90                   	nop
    }
}
  10177a:	90                   	nop
  10177b:	c9                   	leave  
  10177c:	c3                   	ret    

0010177d <pic_enable>:

void
pic_enable(unsigned int irq) {
  10177d:	f3 0f 1e fb          	endbr32 
  101781:	55                   	push   %ebp
  101782:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
  101784:	8b 45 08             	mov    0x8(%ebp),%eax
  101787:	ba 01 00 00 00       	mov    $0x1,%edx
  10178c:	89 c1                	mov    %eax,%ecx
  10178e:	d3 e2                	shl    %cl,%edx
  101790:	89 d0                	mov    %edx,%eax
  101792:	f7 d0                	not    %eax
  101794:	89 c2                	mov    %eax,%edx
  101796:	0f b7 05 50 05 11 00 	movzwl 0x110550,%eax
  10179d:	21 d0                	and    %edx,%eax
  10179f:	0f b7 c0             	movzwl %ax,%eax
  1017a2:	50                   	push   %eax
  1017a3:	e8 76 ff ff ff       	call   10171e <pic_setmask>
  1017a8:	83 c4 04             	add    $0x4,%esp
}
  1017ab:	90                   	nop
  1017ac:	c9                   	leave  
  1017ad:	c3                   	ret    

001017ae <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017ae:	f3 0f 1e fb          	endbr32 
  1017b2:	55                   	push   %ebp
  1017b3:	89 e5                	mov    %esp,%ebp
  1017b5:	83 ec 40             	sub    $0x40,%esp
    did_init = 1;
  1017b8:	c7 05 8c 10 11 00 01 	movl   $0x1,0x11108c
  1017bf:	00 00 00 
  1017c2:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017c8:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017cc:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017d0:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017d4:	ee                   	out    %al,(%dx)
}
  1017d5:	90                   	nop
  1017d6:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1017dc:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017e0:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017e4:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017e8:	ee                   	out    %al,(%dx)
}
  1017e9:	90                   	nop
  1017ea:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017f0:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017f4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017f8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017fc:	ee                   	out    %al,(%dx)
}
  1017fd:	90                   	nop
  1017fe:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101804:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101808:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10180c:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101810:	ee                   	out    %al,(%dx)
}
  101811:	90                   	nop
  101812:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101818:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10181c:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101820:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101824:	ee                   	out    %al,(%dx)
}
  101825:	90                   	nop
  101826:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  10182c:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101830:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101834:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101838:	ee                   	out    %al,(%dx)
}
  101839:	90                   	nop
  10183a:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101840:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101844:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101848:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  10184c:	ee                   	out    %al,(%dx)
}
  10184d:	90                   	nop
  10184e:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  101854:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101858:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10185c:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101860:	ee                   	out    %al,(%dx)
}
  101861:	90                   	nop
  101862:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101868:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10186c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101870:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101874:	ee                   	out    %al,(%dx)
}
  101875:	90                   	nop
  101876:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10187c:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101880:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101884:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101888:	ee                   	out    %al,(%dx)
}
  101889:	90                   	nop
  10188a:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101890:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101894:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101898:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10189c:	ee                   	out    %al,(%dx)
}
  10189d:	90                   	nop
  10189e:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018a4:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018a8:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018ac:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018b0:	ee                   	out    %al,(%dx)
}
  1018b1:	90                   	nop
  1018b2:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018b8:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018bc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018c0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018c4:	ee                   	out    %al,(%dx)
}
  1018c5:	90                   	nop
  1018c6:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018cc:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018d0:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018d4:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1018d8:	ee                   	out    %al,(%dx)
}
  1018d9:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1018da:	0f b7 05 50 05 11 00 	movzwl 0x110550,%eax
  1018e1:	66 83 f8 ff          	cmp    $0xffff,%ax
  1018e5:	74 13                	je     1018fa <pic_init+0x14c>
        pic_setmask(irq_mask);
  1018e7:	0f b7 05 50 05 11 00 	movzwl 0x110550,%eax
  1018ee:	0f b7 c0             	movzwl %ax,%eax
  1018f1:	50                   	push   %eax
  1018f2:	e8 27 fe ff ff       	call   10171e <pic_setmask>
  1018f7:	83 c4 04             	add    $0x4,%esp
    }
}
  1018fa:	90                   	nop
  1018fb:	c9                   	leave  
  1018fc:	c3                   	ret    

001018fd <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1018fd:	f3 0f 1e fb          	endbr32 
  101901:	55                   	push   %ebp
  101902:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101904:	fb                   	sti    
}
  101905:	90                   	nop
    sti();
}
  101906:	90                   	nop
  101907:	5d                   	pop    %ebp
  101908:	c3                   	ret    

00101909 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101909:	f3 0f 1e fb          	endbr32 
  10190d:	55                   	push   %ebp
  10190e:	89 e5                	mov    %esp,%ebp

static inline void
cli(void) {
    asm volatile ("cli");
  101910:	fa                   	cli    
}
  101911:	90                   	nop
    cli();
}
  101912:	90                   	nop
  101913:	5d                   	pop    %ebp
  101914:	c3                   	ret    

00101915 <print_ticks>:
#include <kdebug.h>
#include <string.h>

#define TICK_NUM 100

static void print_ticks() {
  101915:	f3 0f 1e fb          	endbr32 
  101919:	55                   	push   %ebp
  10191a:	89 e5                	mov    %esp,%ebp
  10191c:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10191f:	83 ec 08             	sub    $0x8,%esp
  101922:	6a 64                	push   $0x64
  101924:	68 80 3b 10 00       	push   $0x103b80
  101929:	e8 67 e9 ff ff       	call   100295 <cprintf>
  10192e:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101931:	90                   	nop
  101932:	c9                   	leave  
  101933:	c3                   	ret    

00101934 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101934:	f3 0f 1e fb          	endbr32 
  101938:	55                   	push   %ebp
  101939:	89 e5                	mov    %esp,%ebp
  10193b:	83 ec 10             	sub    $0x10,%esp
      	//Step 1:Declcare the addrs of ISR
	extern uintptr_t __vectors[];
	
	//Step 2: Initialize the IDT
	int i;
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10193e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101945:	e9 c3 00 00 00       	jmp    101a0d <idt_init+0xd9>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  10194a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10194d:	8b 04 85 e0 05 11 00 	mov    0x1105e0(,%eax,4),%eax
  101954:	89 c2                	mov    %eax,%edx
  101956:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101959:	66 89 14 c5 a0 10 11 	mov    %dx,0x1110a0(,%eax,8)
  101960:	00 
  101961:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101964:	66 c7 04 c5 a2 10 11 	movw   $0x8,0x1110a2(,%eax,8)
  10196b:	00 08 00 
  10196e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101971:	0f b6 14 c5 a4 10 11 	movzbl 0x1110a4(,%eax,8),%edx
  101978:	00 
  101979:	83 e2 e0             	and    $0xffffffe0,%edx
  10197c:	88 14 c5 a4 10 11 00 	mov    %dl,0x1110a4(,%eax,8)
  101983:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101986:	0f b6 14 c5 a4 10 11 	movzbl 0x1110a4(,%eax,8),%edx
  10198d:	00 
  10198e:	83 e2 1f             	and    $0x1f,%edx
  101991:	88 14 c5 a4 10 11 00 	mov    %dl,0x1110a4(,%eax,8)
  101998:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10199b:	0f b6 14 c5 a5 10 11 	movzbl 0x1110a5(,%eax,8),%edx
  1019a2:	00 
  1019a3:	83 e2 f0             	and    $0xfffffff0,%edx
  1019a6:	83 ca 0e             	or     $0xe,%edx
  1019a9:	88 14 c5 a5 10 11 00 	mov    %dl,0x1110a5(,%eax,8)
  1019b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b3:	0f b6 14 c5 a5 10 11 	movzbl 0x1110a5(,%eax,8),%edx
  1019ba:	00 
  1019bb:	83 e2 ef             	and    $0xffffffef,%edx
  1019be:	88 14 c5 a5 10 11 00 	mov    %dl,0x1110a5(,%eax,8)
  1019c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c8:	0f b6 14 c5 a5 10 11 	movzbl 0x1110a5(,%eax,8),%edx
  1019cf:	00 
  1019d0:	83 e2 9f             	and    $0xffffff9f,%edx
  1019d3:	88 14 c5 a5 10 11 00 	mov    %dl,0x1110a5(,%eax,8)
  1019da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019dd:	0f b6 14 c5 a5 10 11 	movzbl 0x1110a5(,%eax,8),%edx
  1019e4:	00 
  1019e5:	83 ca 80             	or     $0xffffff80,%edx
  1019e8:	88 14 c5 a5 10 11 00 	mov    %dl,0x1110a5(,%eax,8)
  1019ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019f2:	8b 04 85 e0 05 11 00 	mov    0x1105e0(,%eax,4),%eax
  1019f9:	c1 e8 10             	shr    $0x10,%eax
  1019fc:	89 c2                	mov    %eax,%edx
  1019fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a01:	66 89 14 c5 a6 10 11 	mov    %dx,0x1110a6(,%eax,8)
  101a08:	00 
	for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101a09:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a10:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a15:	0f 86 2f ff ff ff    	jbe    10194a <idt_init+0x16>
	}
	// Set for switch from user to kernel
	SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101a1b:	a1 c4 07 11 00       	mov    0x1107c4,%eax
  101a20:	66 a3 68 14 11 00    	mov    %ax,0x111468
  101a26:	66 c7 05 6a 14 11 00 	movw   $0x8,0x11146a
  101a2d:	08 00 
  101a2f:	0f b6 05 6c 14 11 00 	movzbl 0x11146c,%eax
  101a36:	83 e0 e0             	and    $0xffffffe0,%eax
  101a39:	a2 6c 14 11 00       	mov    %al,0x11146c
  101a3e:	0f b6 05 6c 14 11 00 	movzbl 0x11146c,%eax
  101a45:	83 e0 1f             	and    $0x1f,%eax
  101a48:	a2 6c 14 11 00       	mov    %al,0x11146c
  101a4d:	0f b6 05 6d 14 11 00 	movzbl 0x11146d,%eax
  101a54:	83 e0 f0             	and    $0xfffffff0,%eax
  101a57:	83 c8 0e             	or     $0xe,%eax
  101a5a:	a2 6d 14 11 00       	mov    %al,0x11146d
  101a5f:	0f b6 05 6d 14 11 00 	movzbl 0x11146d,%eax
  101a66:	83 e0 ef             	and    $0xffffffef,%eax
  101a69:	a2 6d 14 11 00       	mov    %al,0x11146d
  101a6e:	0f b6 05 6d 14 11 00 	movzbl 0x11146d,%eax
  101a75:	83 c8 60             	or     $0x60,%eax
  101a78:	a2 6d 14 11 00       	mov    %al,0x11146d
  101a7d:	0f b6 05 6d 14 11 00 	movzbl 0x11146d,%eax
  101a84:	83 c8 80             	or     $0xffffff80,%eax
  101a87:	a2 6d 14 11 00       	mov    %al,0x11146d
  101a8c:	a1 c4 07 11 00       	mov    0x1107c4,%eax
  101a91:	c1 e8 10             	shr    $0x10,%eax
  101a94:	66 a3 6e 14 11 00    	mov    %ax,0x11146e
  101a9a:	c7 45 f8 60 05 11 00 	movl   $0x110560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101aa1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101aa4:	0f 01 18             	lidtl  (%eax)
}
  101aa7:	90                   	nop
	
	//Step 3: Load the IDT
	lidt(&idt_pd);
}
  101aa8:	90                   	nop
  101aa9:	c9                   	leave  
  101aaa:	c3                   	ret    

00101aab <trapname>:

static const char *
trapname(int trapno) {
  101aab:	f3 0f 1e fb          	endbr32 
  101aaf:	55                   	push   %ebp
  101ab0:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab5:	83 f8 13             	cmp    $0x13,%eax
  101ab8:	77 0c                	ja     101ac6 <trapname+0x1b>
        return excnames[trapno];
  101aba:	8b 45 08             	mov    0x8(%ebp),%eax
  101abd:	8b 04 85 e0 3e 10 00 	mov    0x103ee0(,%eax,4),%eax
  101ac4:	eb 18                	jmp    101ade <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ac6:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101aca:	7e 0d                	jle    101ad9 <trapname+0x2e>
  101acc:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101ad0:	7f 07                	jg     101ad9 <trapname+0x2e>
        return "Hardware Interrupt";
  101ad2:	b8 8a 3b 10 00       	mov    $0x103b8a,%eax
  101ad7:	eb 05                	jmp    101ade <trapname+0x33>
    }
    return "(unknown trap)";
  101ad9:	b8 9d 3b 10 00       	mov    $0x103b9d,%eax
}
  101ade:	5d                   	pop    %ebp
  101adf:	c3                   	ret    

00101ae0 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101ae0:	f3 0f 1e fb          	endbr32 
  101ae4:	55                   	push   %ebp
  101ae5:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101aee:	66 83 f8 08          	cmp    $0x8,%ax
  101af2:	0f 94 c0             	sete   %al
  101af5:	0f b6 c0             	movzbl %al,%eax
}
  101af8:	5d                   	pop    %ebp
  101af9:	c3                   	ret    

00101afa <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101afa:	f3 0f 1e fb          	endbr32 
  101afe:	55                   	push   %ebp
  101aff:	89 e5                	mov    %esp,%ebp
  101b01:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
  101b04:	83 ec 08             	sub    $0x8,%esp
  101b07:	ff 75 08             	pushl  0x8(%ebp)
  101b0a:	68 de 3b 10 00       	push   $0x103bde
  101b0f:	e8 81 e7 ff ff       	call   100295 <cprintf>
  101b14:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
  101b17:	8b 45 08             	mov    0x8(%ebp),%eax
  101b1a:	83 ec 0c             	sub    $0xc,%esp
  101b1d:	50                   	push   %eax
  101b1e:	e8 b4 01 00 00       	call   101cd7 <print_regs>
  101b23:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b26:	8b 45 08             	mov    0x8(%ebp),%eax
  101b29:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b2d:	0f b7 c0             	movzwl %ax,%eax
  101b30:	83 ec 08             	sub    $0x8,%esp
  101b33:	50                   	push   %eax
  101b34:	68 ef 3b 10 00       	push   $0x103bef
  101b39:	e8 57 e7 ff ff       	call   100295 <cprintf>
  101b3e:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b48:	0f b7 c0             	movzwl %ax,%eax
  101b4b:	83 ec 08             	sub    $0x8,%esp
  101b4e:	50                   	push   %eax
  101b4f:	68 02 3c 10 00       	push   $0x103c02
  101b54:	e8 3c e7 ff ff       	call   100295 <cprintf>
  101b59:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5f:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b63:	0f b7 c0             	movzwl %ax,%eax
  101b66:	83 ec 08             	sub    $0x8,%esp
  101b69:	50                   	push   %eax
  101b6a:	68 15 3c 10 00       	push   $0x103c15
  101b6f:	e8 21 e7 ff ff       	call   100295 <cprintf>
  101b74:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b77:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7a:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b7e:	0f b7 c0             	movzwl %ax,%eax
  101b81:	83 ec 08             	sub    $0x8,%esp
  101b84:	50                   	push   %eax
  101b85:	68 28 3c 10 00       	push   $0x103c28
  101b8a:	e8 06 e7 ff ff       	call   100295 <cprintf>
  101b8f:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b92:	8b 45 08             	mov    0x8(%ebp),%eax
  101b95:	8b 40 30             	mov    0x30(%eax),%eax
  101b98:	83 ec 0c             	sub    $0xc,%esp
  101b9b:	50                   	push   %eax
  101b9c:	e8 0a ff ff ff       	call   101aab <trapname>
  101ba1:	83 c4 10             	add    $0x10,%esp
  101ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  101ba7:	8b 52 30             	mov    0x30(%edx),%edx
  101baa:	83 ec 04             	sub    $0x4,%esp
  101bad:	50                   	push   %eax
  101bae:	52                   	push   %edx
  101baf:	68 3b 3c 10 00       	push   $0x103c3b
  101bb4:	e8 dc e6 ff ff       	call   100295 <cprintf>
  101bb9:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbf:	8b 40 34             	mov    0x34(%eax),%eax
  101bc2:	83 ec 08             	sub    $0x8,%esp
  101bc5:	50                   	push   %eax
  101bc6:	68 4d 3c 10 00       	push   $0x103c4d
  101bcb:	e8 c5 e6 ff ff       	call   100295 <cprintf>
  101bd0:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd6:	8b 40 38             	mov    0x38(%eax),%eax
  101bd9:	83 ec 08             	sub    $0x8,%esp
  101bdc:	50                   	push   %eax
  101bdd:	68 5c 3c 10 00       	push   $0x103c5c
  101be2:	e8 ae e6 ff ff       	call   100295 <cprintf>
  101be7:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bea:	8b 45 08             	mov    0x8(%ebp),%eax
  101bed:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bf1:	0f b7 c0             	movzwl %ax,%eax
  101bf4:	83 ec 08             	sub    $0x8,%esp
  101bf7:	50                   	push   %eax
  101bf8:	68 6b 3c 10 00       	push   $0x103c6b
  101bfd:	e8 93 e6 ff ff       	call   100295 <cprintf>
  101c02:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c05:	8b 45 08             	mov    0x8(%ebp),%eax
  101c08:	8b 40 40             	mov    0x40(%eax),%eax
  101c0b:	83 ec 08             	sub    $0x8,%esp
  101c0e:	50                   	push   %eax
  101c0f:	68 7e 3c 10 00       	push   $0x103c7e
  101c14:	e8 7c e6 ff ff       	call   100295 <cprintf>
  101c19:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c23:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c2a:	eb 3f                	jmp    101c6b <print_trapframe+0x171>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2f:	8b 50 40             	mov    0x40(%eax),%edx
  101c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c35:	21 d0                	and    %edx,%eax
  101c37:	85 c0                	test   %eax,%eax
  101c39:	74 29                	je     101c64 <print_trapframe+0x16a>
  101c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c3e:	8b 04 85 80 05 11 00 	mov    0x110580(,%eax,4),%eax
  101c45:	85 c0                	test   %eax,%eax
  101c47:	74 1b                	je     101c64 <print_trapframe+0x16a>
            cprintf("%s,", IA32flags[i]);
  101c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c4c:	8b 04 85 80 05 11 00 	mov    0x110580(,%eax,4),%eax
  101c53:	83 ec 08             	sub    $0x8,%esp
  101c56:	50                   	push   %eax
  101c57:	68 8d 3c 10 00       	push   $0x103c8d
  101c5c:	e8 34 e6 ff ff       	call   100295 <cprintf>
  101c61:	83 c4 10             	add    $0x10,%esp
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101c68:	d1 65 f0             	shll   -0x10(%ebp)
  101c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c6e:	83 f8 17             	cmp    $0x17,%eax
  101c71:	76 b9                	jbe    101c2c <print_trapframe+0x132>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c73:	8b 45 08             	mov    0x8(%ebp),%eax
  101c76:	8b 40 40             	mov    0x40(%eax),%eax
  101c79:	c1 e8 0c             	shr    $0xc,%eax
  101c7c:	83 e0 03             	and    $0x3,%eax
  101c7f:	83 ec 08             	sub    $0x8,%esp
  101c82:	50                   	push   %eax
  101c83:	68 91 3c 10 00       	push   $0x103c91
  101c88:	e8 08 e6 ff ff       	call   100295 <cprintf>
  101c8d:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
  101c90:	83 ec 0c             	sub    $0xc,%esp
  101c93:	ff 75 08             	pushl  0x8(%ebp)
  101c96:	e8 45 fe ff ff       	call   101ae0 <trap_in_kernel>
  101c9b:	83 c4 10             	add    $0x10,%esp
  101c9e:	85 c0                	test   %eax,%eax
  101ca0:	75 32                	jne    101cd4 <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca5:	8b 40 44             	mov    0x44(%eax),%eax
  101ca8:	83 ec 08             	sub    $0x8,%esp
  101cab:	50                   	push   %eax
  101cac:	68 9a 3c 10 00       	push   $0x103c9a
  101cb1:	e8 df e5 ff ff       	call   100295 <cprintf>
  101cb6:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbc:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cc0:	0f b7 c0             	movzwl %ax,%eax
  101cc3:	83 ec 08             	sub    $0x8,%esp
  101cc6:	50                   	push   %eax
  101cc7:	68 a9 3c 10 00       	push   $0x103ca9
  101ccc:	e8 c4 e5 ff ff       	call   100295 <cprintf>
  101cd1:	83 c4 10             	add    $0x10,%esp
    }
}
  101cd4:	90                   	nop
  101cd5:	c9                   	leave  
  101cd6:	c3                   	ret    

00101cd7 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101cd7:	f3 0f 1e fb          	endbr32 
  101cdb:	55                   	push   %ebp
  101cdc:	89 e5                	mov    %esp,%ebp
  101cde:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ce4:	8b 00                	mov    (%eax),%eax
  101ce6:	83 ec 08             	sub    $0x8,%esp
  101ce9:	50                   	push   %eax
  101cea:	68 bc 3c 10 00       	push   $0x103cbc
  101cef:	e8 a1 e5 ff ff       	call   100295 <cprintf>
  101cf4:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  101cfa:	8b 40 04             	mov    0x4(%eax),%eax
  101cfd:	83 ec 08             	sub    $0x8,%esp
  101d00:	50                   	push   %eax
  101d01:	68 cb 3c 10 00       	push   $0x103ccb
  101d06:	e8 8a e5 ff ff       	call   100295 <cprintf>
  101d0b:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d11:	8b 40 08             	mov    0x8(%eax),%eax
  101d14:	83 ec 08             	sub    $0x8,%esp
  101d17:	50                   	push   %eax
  101d18:	68 da 3c 10 00       	push   $0x103cda
  101d1d:	e8 73 e5 ff ff       	call   100295 <cprintf>
  101d22:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d25:	8b 45 08             	mov    0x8(%ebp),%eax
  101d28:	8b 40 0c             	mov    0xc(%eax),%eax
  101d2b:	83 ec 08             	sub    $0x8,%esp
  101d2e:	50                   	push   %eax
  101d2f:	68 e9 3c 10 00       	push   $0x103ce9
  101d34:	e8 5c e5 ff ff       	call   100295 <cprintf>
  101d39:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d3f:	8b 40 10             	mov    0x10(%eax),%eax
  101d42:	83 ec 08             	sub    $0x8,%esp
  101d45:	50                   	push   %eax
  101d46:	68 f8 3c 10 00       	push   $0x103cf8
  101d4b:	e8 45 e5 ff ff       	call   100295 <cprintf>
  101d50:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d53:	8b 45 08             	mov    0x8(%ebp),%eax
  101d56:	8b 40 14             	mov    0x14(%eax),%eax
  101d59:	83 ec 08             	sub    $0x8,%esp
  101d5c:	50                   	push   %eax
  101d5d:	68 07 3d 10 00       	push   $0x103d07
  101d62:	e8 2e e5 ff ff       	call   100295 <cprintf>
  101d67:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6d:	8b 40 18             	mov    0x18(%eax),%eax
  101d70:	83 ec 08             	sub    $0x8,%esp
  101d73:	50                   	push   %eax
  101d74:	68 16 3d 10 00       	push   $0x103d16
  101d79:	e8 17 e5 ff ff       	call   100295 <cprintf>
  101d7e:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d81:	8b 45 08             	mov    0x8(%ebp),%eax
  101d84:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d87:	83 ec 08             	sub    $0x8,%esp
  101d8a:	50                   	push   %eax
  101d8b:	68 25 3d 10 00       	push   $0x103d25
  101d90:	e8 00 e5 ff ff       	call   100295 <cprintf>
  101d95:	83 c4 10             	add    $0x10,%esp
}
  101d98:	90                   	nop
  101d99:	c9                   	leave  
  101d9a:	c3                   	ret    

00101d9b <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d9b:	f3 0f 1e fb          	endbr32 
  101d9f:	55                   	push   %ebp
  101da0:	89 e5                	mov    %esp,%ebp
  101da2:	57                   	push   %edi
  101da3:	56                   	push   %esi
  101da4:	53                   	push   %ebx
  101da5:	83 ec 1c             	sub    $0x1c,%esp
    char c;

    switch (tf->tf_trapno) {
  101da8:	8b 45 08             	mov    0x8(%ebp),%eax
  101dab:	8b 40 30             	mov    0x30(%eax),%eax
  101dae:	83 f8 79             	cmp    $0x79,%eax
  101db1:	0f 84 7f 02 00 00    	je     102036 <trap_dispatch+0x29b>
  101db7:	83 f8 79             	cmp    $0x79,%eax
  101dba:	0f 87 ec 02 00 00    	ja     1020ac <trap_dispatch+0x311>
  101dc0:	83 f8 78             	cmp    $0x78,%eax
  101dc3:	0f 84 d1 01 00 00    	je     101f9a <trap_dispatch+0x1ff>
  101dc9:	83 f8 78             	cmp    $0x78,%eax
  101dcc:	0f 87 da 02 00 00    	ja     1020ac <trap_dispatch+0x311>
  101dd2:	83 f8 2f             	cmp    $0x2f,%eax
  101dd5:	0f 87 d1 02 00 00    	ja     1020ac <trap_dispatch+0x311>
  101ddb:	83 f8 2e             	cmp    $0x2e,%eax
  101dde:	0f 83 fe 02 00 00    	jae    1020e2 <trap_dispatch+0x347>
  101de4:	83 f8 24             	cmp    $0x24,%eax
  101de7:	74 43                	je     101e2c <trap_dispatch+0x91>
  101de9:	83 f8 24             	cmp    $0x24,%eax
  101dec:	0f 87 ba 02 00 00    	ja     1020ac <trap_dispatch+0x311>
  101df2:	83 f8 20             	cmp    $0x20,%eax
  101df5:	74 0a                	je     101e01 <trap_dispatch+0x66>
  101df7:	83 f8 21             	cmp    $0x21,%eax
  101dfa:	74 57                	je     101e53 <trap_dispatch+0xb8>
  101dfc:	e9 ab 02 00 00       	jmp    1020ac <trap_dispatch+0x311>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101e01:	a1 08 19 11 00       	mov    0x111908,%eax
  101e06:	83 c0 01             	add    $0x1,%eax
  101e09:	a3 08 19 11 00       	mov    %eax,0x111908
        if (ticks % TICK_NUM == 0) {
  101e0e:	8b 0d 08 19 11 00    	mov    0x111908,%ecx
  101e14:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e19:	89 c8                	mov    %ecx,%eax
  101e1b:	f7 e2                	mul    %edx
  101e1d:	89 d0                	mov    %edx,%eax
  101e1f:	c1 e8 05             	shr    $0x5,%eax
  101e22:	6b c0 64             	imul   $0x64,%eax,%eax
  101e25:	29 c1                	sub    %eax,%ecx
            //print_ticks();
        }
        break;
  101e27:	e9 c0 02 00 00       	jmp    1020ec <trap_dispatch+0x351>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e2c:	e8 8d f8 ff ff       	call   1016be <cons_getc>
  101e31:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e34:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101e38:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101e3c:	83 ec 04             	sub    $0x4,%esp
  101e3f:	52                   	push   %edx
  101e40:	50                   	push   %eax
  101e41:	68 34 3d 10 00       	push   $0x103d34
  101e46:	e8 4a e4 ff ff       	call   100295 <cprintf>
  101e4b:	83 c4 10             	add    $0x10,%esp
        
        break;
  101e4e:	e9 99 02 00 00       	jmp    1020ec <trap_dispatch+0x351>
    case IRQ_OFFSET + IRQ_KBD:
    //LAB1 CHALLENGE 2 : MY CODE
	c = cons_getc();
  101e53:	e8 66 f8 ff ff       	call   1016be <cons_getc>
  101e58:	88 45 e7             	mov    %al,-0x19(%ebp)
	cprintf("kbd [%03d] %c\n", c, c);
  101e5b:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101e5f:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101e63:	83 ec 04             	sub    $0x4,%esp
  101e66:	52                   	push   %edx
  101e67:	50                   	push   %eax
  101e68:	68 46 3d 10 00       	push   $0x103d46
  101e6d:	e8 23 e4 ff ff       	call   100295 <cprintf>
  101e72:	83 c4 10             	add    $0x10,%esp
	if(c == '0'){
  101e75:	80 7d e7 30          	cmpb   $0x30,-0x19(%ebp)
  101e79:	75 79                	jne    101ef4 <trap_dispatch+0x159>
	    if (tf->tf_cs != KERNEL_CS) {
  101e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e7e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e82:	66 83 f8 08          	cmp    $0x8,%ax
  101e86:	0f 84 59 02 00 00    	je     1020e5 <trap_dispatch+0x34a>
	    
	    tf->tf_cs = KERNEL_CS;
  101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8f:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
	    tf->tf_ds = tf->tf_es = KERNEL_DS;
  101e95:	8b 45 08             	mov    0x8(%ebp),%eax
  101e98:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea1:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea8:	66 89 50 2c          	mov    %dx,0x2c(%eax)
	    tf->tf_eflags &= ~FL_IOPL_MASK;
  101eac:	8b 45 08             	mov    0x8(%ebp),%eax
  101eaf:	8b 40 40             	mov    0x40(%eax),%eax
  101eb2:	80 e4 cf             	and    $0xcf,%ah
  101eb5:	89 c2                	mov    %eax,%edx
  101eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  101eba:	89 50 40             	mov    %edx,0x40(%eax)
	    switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec0:	8b 40 44             	mov    0x44(%eax),%eax
  101ec3:	83 e8 44             	sub    $0x44,%eax
  101ec6:	a3 6c 19 11 00       	mov    %eax,0x11196c
	    memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101ecb:	a1 6c 19 11 00       	mov    0x11196c,%eax
  101ed0:	83 ec 04             	sub    $0x4,%esp
  101ed3:	6a 44                	push   $0x44
  101ed5:	ff 75 08             	pushl  0x8(%ebp)
  101ed8:	50                   	push   %eax
  101ed9:	e8 a6 11 00 00       	call   103084 <memmove>
  101ede:	83 c4 10             	add    $0x10,%esp
	    *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101ee1:	8b 15 6c 19 11 00    	mov    0x11196c,%edx
  101ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  101eea:	83 e8 04             	sub    $0x4,%eax
  101eed:	89 10                	mov    %edx,(%eax)
	    switchk2u.tf_eflags |= FL_IOPL_MASK;
		
	    *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
	    }
	}
        break;
  101eef:	e9 f1 01 00 00       	jmp    1020e5 <trap_dispatch+0x34a>
	else if(c == '3'){
  101ef4:	80 7d e7 33          	cmpb   $0x33,-0x19(%ebp)
  101ef8:	0f 85 e7 01 00 00    	jne    1020e5 <trap_dispatch+0x34a>
	    if (tf->tf_cs != USER_CS) {
  101efe:	8b 45 08             	mov    0x8(%ebp),%eax
  101f01:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f05:	66 83 f8 1b          	cmp    $0x1b,%ax
  101f09:	0f 84 d6 01 00 00    	je     1020e5 <trap_dispatch+0x34a>
	    switchk2u = *tf;
  101f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  101f12:	b8 20 19 11 00       	mov    $0x111920,%eax
  101f17:	89 d3                	mov    %edx,%ebx
  101f19:	ba 4c 00 00 00       	mov    $0x4c,%edx
  101f1e:	8b 0b                	mov    (%ebx),%ecx
  101f20:	89 08                	mov    %ecx,(%eax)
  101f22:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
  101f26:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
  101f2a:	8d 78 04             	lea    0x4(%eax),%edi
  101f2d:	83 e7 fc             	and    $0xfffffffc,%edi
  101f30:	29 f8                	sub    %edi,%eax
  101f32:	29 c3                	sub    %eax,%ebx
  101f34:	01 c2                	add    %eax,%edx
  101f36:	83 e2 fc             	and    $0xfffffffc,%edx
  101f39:	89 d0                	mov    %edx,%eax
  101f3b:	c1 e8 02             	shr    $0x2,%eax
  101f3e:	89 de                	mov    %ebx,%esi
  101f40:	89 c1                	mov    %eax,%ecx
  101f42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	    switchk2u.tf_cs = USER_CS;
  101f44:	66 c7 05 5c 19 11 00 	movw   $0x1b,0x11195c
  101f4b:	1b 00 
	    switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101f4d:	66 c7 05 68 19 11 00 	movw   $0x23,0x111968
  101f54:	23 00 
  101f56:	0f b7 05 68 19 11 00 	movzwl 0x111968,%eax
  101f5d:	66 a3 48 19 11 00    	mov    %ax,0x111948
  101f63:	0f b7 05 48 19 11 00 	movzwl 0x111948,%eax
  101f6a:	66 a3 4c 19 11 00    	mov    %ax,0x11194c
	    switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;            
  101f70:	8b 45 08             	mov    0x8(%ebp),%eax
  101f73:	83 c0 44             	add    $0x44,%eax
  101f76:	a3 64 19 11 00       	mov    %eax,0x111964
	    switchk2u.tf_eflags |= FL_IOPL_MASK;
  101f7b:	a1 60 19 11 00       	mov    0x111960,%eax
  101f80:	80 cc 30             	or     $0x30,%ah
  101f83:	a3 60 19 11 00       	mov    %eax,0x111960
	    *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101f88:	8b 45 08             	mov    0x8(%ebp),%eax
  101f8b:	83 e8 04             	sub    $0x4,%eax
  101f8e:	ba 20 19 11 00       	mov    $0x111920,%edx
  101f93:	89 10                	mov    %edx,(%eax)
        break;
  101f95:	e9 4b 01 00 00       	jmp    1020e5 <trap_dispatch+0x34a>
        
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f9d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101fa1:	66 83 f8 1b          	cmp    $0x1b,%ax
  101fa5:	0f 84 3d 01 00 00    	je     1020e8 <trap_dispatch+0x34d>
            switchk2u = *tf;
  101fab:	8b 55 08             	mov    0x8(%ebp),%edx
  101fae:	b8 20 19 11 00       	mov    $0x111920,%eax
  101fb3:	89 d3                	mov    %edx,%ebx
  101fb5:	ba 4c 00 00 00       	mov    $0x4c,%edx
  101fba:	8b 0b                	mov    (%ebx),%ecx
  101fbc:	89 08                	mov    %ecx,(%eax)
  101fbe:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
  101fc2:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
  101fc6:	8d 78 04             	lea    0x4(%eax),%edi
  101fc9:	83 e7 fc             	and    $0xfffffffc,%edi
  101fcc:	29 f8                	sub    %edi,%eax
  101fce:	29 c3                	sub    %eax,%ebx
  101fd0:	01 c2                	add    %eax,%edx
  101fd2:	83 e2 fc             	and    $0xfffffffc,%edx
  101fd5:	89 d0                	mov    %edx,%eax
  101fd7:	c1 e8 02             	shr    $0x2,%eax
  101fda:	89 de                	mov    %ebx,%esi
  101fdc:	89 c1                	mov    %eax,%ecx
  101fde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101fe0:	66 c7 05 5c 19 11 00 	movw   $0x1b,0x11195c
  101fe7:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101fe9:	66 c7 05 68 19 11 00 	movw   $0x23,0x111968
  101ff0:	23 00 
  101ff2:	0f b7 05 68 19 11 00 	movzwl 0x111968,%eax
  101ff9:	66 a3 48 19 11 00    	mov    %ax,0x111948
  101fff:	0f b7 05 48 19 11 00 	movzwl 0x111948,%eax
  102006:	66 a3 4c 19 11 00    	mov    %ax,0x11194c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;            
  10200c:	8b 45 08             	mov    0x8(%ebp),%eax
  10200f:	83 c0 44             	add    $0x44,%eax
  102012:	a3 64 19 11 00       	mov    %eax,0x111964
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  102017:	a1 60 19 11 00       	mov    0x111960,%eax
  10201c:	80 cc 30             	or     $0x30,%ah
  10201f:	a3 60 19 11 00       	mov    %eax,0x111960
		
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  102024:	8b 45 08             	mov    0x8(%ebp),%eax
  102027:	83 e8 04             	sub    $0x4,%eax
  10202a:	ba 20 19 11 00       	mov    $0x111920,%edx
  10202f:	89 10                	mov    %edx,(%eax)
        }
        break;
  102031:	e9 b2 00 00 00       	jmp    1020e8 <trap_dispatch+0x34d>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  102036:	8b 45 08             	mov    0x8(%ebp),%eax
  102039:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10203d:	66 83 f8 08          	cmp    $0x8,%ax
  102041:	0f 84 a4 00 00 00    	je     1020eb <trap_dispatch+0x350>
            tf->tf_cs = KERNEL_CS;
  102047:	8b 45 08             	mov    0x8(%ebp),%eax
  10204a:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  102050:	8b 45 08             	mov    0x8(%ebp),%eax
  102053:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  102059:	8b 45 08             	mov    0x8(%ebp),%eax
  10205c:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  102060:	8b 45 08             	mov    0x8(%ebp),%eax
  102063:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  102067:	8b 45 08             	mov    0x8(%ebp),%eax
  10206a:	8b 40 40             	mov    0x40(%eax),%eax
  10206d:	80 e4 cf             	and    $0xcf,%ah
  102070:	89 c2                	mov    %eax,%edx
  102072:	8b 45 08             	mov    0x8(%ebp),%eax
  102075:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  102078:	8b 45 08             	mov    0x8(%ebp),%eax
  10207b:	8b 40 44             	mov    0x44(%eax),%eax
  10207e:	83 e8 44             	sub    $0x44,%eax
  102081:	a3 6c 19 11 00       	mov    %eax,0x11196c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  102086:	a1 6c 19 11 00       	mov    0x11196c,%eax
  10208b:	83 ec 04             	sub    $0x4,%esp
  10208e:	6a 44                	push   $0x44
  102090:	ff 75 08             	pushl  0x8(%ebp)
  102093:	50                   	push   %eax
  102094:	e8 eb 0f 00 00       	call   103084 <memmove>
  102099:	83 c4 10             	add    $0x10,%esp
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  10209c:	8b 15 6c 19 11 00    	mov    0x11196c,%edx
  1020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1020a5:	83 e8 04             	sub    $0x4,%eax
  1020a8:	89 10                	mov    %edx,(%eax)
        }
        break;
  1020aa:	eb 3f                	jmp    1020eb <trap_dispatch+0x350>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  1020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1020af:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1020b3:	0f b7 c0             	movzwl %ax,%eax
  1020b6:	83 e0 03             	and    $0x3,%eax
  1020b9:	85 c0                	test   %eax,%eax
  1020bb:	75 2f                	jne    1020ec <trap_dispatch+0x351>
            print_trapframe(tf);
  1020bd:	83 ec 0c             	sub    $0xc,%esp
  1020c0:	ff 75 08             	pushl  0x8(%ebp)
  1020c3:	e8 32 fa ff ff       	call   101afa <print_trapframe>
  1020c8:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
  1020cb:	83 ec 04             	sub    $0x4,%esp
  1020ce:	68 55 3d 10 00       	push   $0x103d55
  1020d3:	68 e1 00 00 00       	push   $0xe1
  1020d8:	68 71 3d 10 00       	push   $0x103d71
  1020dd:	e8 2e e3 ff ff       	call   100410 <__panic>
        break;
  1020e2:	90                   	nop
  1020e3:	eb 07                	jmp    1020ec <trap_dispatch+0x351>
        break;
  1020e5:	90                   	nop
  1020e6:	eb 04                	jmp    1020ec <trap_dispatch+0x351>
        break;
  1020e8:	90                   	nop
  1020e9:	eb 01                	jmp    1020ec <trap_dispatch+0x351>
        break;
  1020eb:	90                   	nop
        }
    }
}
  1020ec:	90                   	nop
  1020ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  1020f0:	5b                   	pop    %ebx
  1020f1:	5e                   	pop    %esi
  1020f2:	5f                   	pop    %edi
  1020f3:	5d                   	pop    %ebp
  1020f4:	c3                   	ret    

001020f5 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  1020f5:	f3 0f 1e fb          	endbr32 
  1020f9:	55                   	push   %ebp
  1020fa:	89 e5                	mov    %esp,%ebp
  1020fc:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  1020ff:	83 ec 0c             	sub    $0xc,%esp
  102102:	ff 75 08             	pushl  0x8(%ebp)
  102105:	e8 91 fc ff ff       	call   101d9b <trap_dispatch>
  10210a:	83 c4 10             	add    $0x10,%esp
}
  10210d:	90                   	nop
  10210e:	c9                   	leave  
  10210f:	c3                   	ret    

00102110 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $0
  102112:	6a 00                	push   $0x0
  jmp __alltraps
  102114:	e9 67 0a 00 00       	jmp    102b80 <__alltraps>

00102119 <vector1>:
.globl vector1
vector1:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $1
  10211b:	6a 01                	push   $0x1
  jmp __alltraps
  10211d:	e9 5e 0a 00 00       	jmp    102b80 <__alltraps>

00102122 <vector2>:
.globl vector2
vector2:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $2
  102124:	6a 02                	push   $0x2
  jmp __alltraps
  102126:	e9 55 0a 00 00       	jmp    102b80 <__alltraps>

0010212b <vector3>:
.globl vector3
vector3:
  pushl $0
  10212b:	6a 00                	push   $0x0
  pushl $3
  10212d:	6a 03                	push   $0x3
  jmp __alltraps
  10212f:	e9 4c 0a 00 00       	jmp    102b80 <__alltraps>

00102134 <vector4>:
.globl vector4
vector4:
  pushl $0
  102134:	6a 00                	push   $0x0
  pushl $4
  102136:	6a 04                	push   $0x4
  jmp __alltraps
  102138:	e9 43 0a 00 00       	jmp    102b80 <__alltraps>

0010213d <vector5>:
.globl vector5
vector5:
  pushl $0
  10213d:	6a 00                	push   $0x0
  pushl $5
  10213f:	6a 05                	push   $0x5
  jmp __alltraps
  102141:	e9 3a 0a 00 00       	jmp    102b80 <__alltraps>

00102146 <vector6>:
.globl vector6
vector6:
  pushl $0
  102146:	6a 00                	push   $0x0
  pushl $6
  102148:	6a 06                	push   $0x6
  jmp __alltraps
  10214a:	e9 31 0a 00 00       	jmp    102b80 <__alltraps>

0010214f <vector7>:
.globl vector7
vector7:
  pushl $0
  10214f:	6a 00                	push   $0x0
  pushl $7
  102151:	6a 07                	push   $0x7
  jmp __alltraps
  102153:	e9 28 0a 00 00       	jmp    102b80 <__alltraps>

00102158 <vector8>:
.globl vector8
vector8:
  pushl $8
  102158:	6a 08                	push   $0x8
  jmp __alltraps
  10215a:	e9 21 0a 00 00       	jmp    102b80 <__alltraps>

0010215f <vector9>:
.globl vector9
vector9:
  pushl $9
  10215f:	6a 09                	push   $0x9
  jmp __alltraps
  102161:	e9 1a 0a 00 00       	jmp    102b80 <__alltraps>

00102166 <vector10>:
.globl vector10
vector10:
  pushl $10
  102166:	6a 0a                	push   $0xa
  jmp __alltraps
  102168:	e9 13 0a 00 00       	jmp    102b80 <__alltraps>

0010216d <vector11>:
.globl vector11
vector11:
  pushl $11
  10216d:	6a 0b                	push   $0xb
  jmp __alltraps
  10216f:	e9 0c 0a 00 00       	jmp    102b80 <__alltraps>

00102174 <vector12>:
.globl vector12
vector12:
  pushl $12
  102174:	6a 0c                	push   $0xc
  jmp __alltraps
  102176:	e9 05 0a 00 00       	jmp    102b80 <__alltraps>

0010217b <vector13>:
.globl vector13
vector13:
  pushl $13
  10217b:	6a 0d                	push   $0xd
  jmp __alltraps
  10217d:	e9 fe 09 00 00       	jmp    102b80 <__alltraps>

00102182 <vector14>:
.globl vector14
vector14:
  pushl $14
  102182:	6a 0e                	push   $0xe
  jmp __alltraps
  102184:	e9 f7 09 00 00       	jmp    102b80 <__alltraps>

00102189 <vector15>:
.globl vector15
vector15:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $15
  10218b:	6a 0f                	push   $0xf
  jmp __alltraps
  10218d:	e9 ee 09 00 00       	jmp    102b80 <__alltraps>

00102192 <vector16>:
.globl vector16
vector16:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $16
  102194:	6a 10                	push   $0x10
  jmp __alltraps
  102196:	e9 e5 09 00 00       	jmp    102b80 <__alltraps>

0010219b <vector17>:
.globl vector17
vector17:
  pushl $17
  10219b:	6a 11                	push   $0x11
  jmp __alltraps
  10219d:	e9 de 09 00 00       	jmp    102b80 <__alltraps>

001021a2 <vector18>:
.globl vector18
vector18:
  pushl $0
  1021a2:	6a 00                	push   $0x0
  pushl $18
  1021a4:	6a 12                	push   $0x12
  jmp __alltraps
  1021a6:	e9 d5 09 00 00       	jmp    102b80 <__alltraps>

001021ab <vector19>:
.globl vector19
vector19:
  pushl $0
  1021ab:	6a 00                	push   $0x0
  pushl $19
  1021ad:	6a 13                	push   $0x13
  jmp __alltraps
  1021af:	e9 cc 09 00 00       	jmp    102b80 <__alltraps>

001021b4 <vector20>:
.globl vector20
vector20:
  pushl $0
  1021b4:	6a 00                	push   $0x0
  pushl $20
  1021b6:	6a 14                	push   $0x14
  jmp __alltraps
  1021b8:	e9 c3 09 00 00       	jmp    102b80 <__alltraps>

001021bd <vector21>:
.globl vector21
vector21:
  pushl $0
  1021bd:	6a 00                	push   $0x0
  pushl $21
  1021bf:	6a 15                	push   $0x15
  jmp __alltraps
  1021c1:	e9 ba 09 00 00       	jmp    102b80 <__alltraps>

001021c6 <vector22>:
.globl vector22
vector22:
  pushl $0
  1021c6:	6a 00                	push   $0x0
  pushl $22
  1021c8:	6a 16                	push   $0x16
  jmp __alltraps
  1021ca:	e9 b1 09 00 00       	jmp    102b80 <__alltraps>

001021cf <vector23>:
.globl vector23
vector23:
  pushl $0
  1021cf:	6a 00                	push   $0x0
  pushl $23
  1021d1:	6a 17                	push   $0x17
  jmp __alltraps
  1021d3:	e9 a8 09 00 00       	jmp    102b80 <__alltraps>

001021d8 <vector24>:
.globl vector24
vector24:
  pushl $0
  1021d8:	6a 00                	push   $0x0
  pushl $24
  1021da:	6a 18                	push   $0x18
  jmp __alltraps
  1021dc:	e9 9f 09 00 00       	jmp    102b80 <__alltraps>

001021e1 <vector25>:
.globl vector25
vector25:
  pushl $0
  1021e1:	6a 00                	push   $0x0
  pushl $25
  1021e3:	6a 19                	push   $0x19
  jmp __alltraps
  1021e5:	e9 96 09 00 00       	jmp    102b80 <__alltraps>

001021ea <vector26>:
.globl vector26
vector26:
  pushl $0
  1021ea:	6a 00                	push   $0x0
  pushl $26
  1021ec:	6a 1a                	push   $0x1a
  jmp __alltraps
  1021ee:	e9 8d 09 00 00       	jmp    102b80 <__alltraps>

001021f3 <vector27>:
.globl vector27
vector27:
  pushl $0
  1021f3:	6a 00                	push   $0x0
  pushl $27
  1021f5:	6a 1b                	push   $0x1b
  jmp __alltraps
  1021f7:	e9 84 09 00 00       	jmp    102b80 <__alltraps>

001021fc <vector28>:
.globl vector28
vector28:
  pushl $0
  1021fc:	6a 00                	push   $0x0
  pushl $28
  1021fe:	6a 1c                	push   $0x1c
  jmp __alltraps
  102200:	e9 7b 09 00 00       	jmp    102b80 <__alltraps>

00102205 <vector29>:
.globl vector29
vector29:
  pushl $0
  102205:	6a 00                	push   $0x0
  pushl $29
  102207:	6a 1d                	push   $0x1d
  jmp __alltraps
  102209:	e9 72 09 00 00       	jmp    102b80 <__alltraps>

0010220e <vector30>:
.globl vector30
vector30:
  pushl $0
  10220e:	6a 00                	push   $0x0
  pushl $30
  102210:	6a 1e                	push   $0x1e
  jmp __alltraps
  102212:	e9 69 09 00 00       	jmp    102b80 <__alltraps>

00102217 <vector31>:
.globl vector31
vector31:
  pushl $0
  102217:	6a 00                	push   $0x0
  pushl $31
  102219:	6a 1f                	push   $0x1f
  jmp __alltraps
  10221b:	e9 60 09 00 00       	jmp    102b80 <__alltraps>

00102220 <vector32>:
.globl vector32
vector32:
  pushl $0
  102220:	6a 00                	push   $0x0
  pushl $32
  102222:	6a 20                	push   $0x20
  jmp __alltraps
  102224:	e9 57 09 00 00       	jmp    102b80 <__alltraps>

00102229 <vector33>:
.globl vector33
vector33:
  pushl $0
  102229:	6a 00                	push   $0x0
  pushl $33
  10222b:	6a 21                	push   $0x21
  jmp __alltraps
  10222d:	e9 4e 09 00 00       	jmp    102b80 <__alltraps>

00102232 <vector34>:
.globl vector34
vector34:
  pushl $0
  102232:	6a 00                	push   $0x0
  pushl $34
  102234:	6a 22                	push   $0x22
  jmp __alltraps
  102236:	e9 45 09 00 00       	jmp    102b80 <__alltraps>

0010223b <vector35>:
.globl vector35
vector35:
  pushl $0
  10223b:	6a 00                	push   $0x0
  pushl $35
  10223d:	6a 23                	push   $0x23
  jmp __alltraps
  10223f:	e9 3c 09 00 00       	jmp    102b80 <__alltraps>

00102244 <vector36>:
.globl vector36
vector36:
  pushl $0
  102244:	6a 00                	push   $0x0
  pushl $36
  102246:	6a 24                	push   $0x24
  jmp __alltraps
  102248:	e9 33 09 00 00       	jmp    102b80 <__alltraps>

0010224d <vector37>:
.globl vector37
vector37:
  pushl $0
  10224d:	6a 00                	push   $0x0
  pushl $37
  10224f:	6a 25                	push   $0x25
  jmp __alltraps
  102251:	e9 2a 09 00 00       	jmp    102b80 <__alltraps>

00102256 <vector38>:
.globl vector38
vector38:
  pushl $0
  102256:	6a 00                	push   $0x0
  pushl $38
  102258:	6a 26                	push   $0x26
  jmp __alltraps
  10225a:	e9 21 09 00 00       	jmp    102b80 <__alltraps>

0010225f <vector39>:
.globl vector39
vector39:
  pushl $0
  10225f:	6a 00                	push   $0x0
  pushl $39
  102261:	6a 27                	push   $0x27
  jmp __alltraps
  102263:	e9 18 09 00 00       	jmp    102b80 <__alltraps>

00102268 <vector40>:
.globl vector40
vector40:
  pushl $0
  102268:	6a 00                	push   $0x0
  pushl $40
  10226a:	6a 28                	push   $0x28
  jmp __alltraps
  10226c:	e9 0f 09 00 00       	jmp    102b80 <__alltraps>

00102271 <vector41>:
.globl vector41
vector41:
  pushl $0
  102271:	6a 00                	push   $0x0
  pushl $41
  102273:	6a 29                	push   $0x29
  jmp __alltraps
  102275:	e9 06 09 00 00       	jmp    102b80 <__alltraps>

0010227a <vector42>:
.globl vector42
vector42:
  pushl $0
  10227a:	6a 00                	push   $0x0
  pushl $42
  10227c:	6a 2a                	push   $0x2a
  jmp __alltraps
  10227e:	e9 fd 08 00 00       	jmp    102b80 <__alltraps>

00102283 <vector43>:
.globl vector43
vector43:
  pushl $0
  102283:	6a 00                	push   $0x0
  pushl $43
  102285:	6a 2b                	push   $0x2b
  jmp __alltraps
  102287:	e9 f4 08 00 00       	jmp    102b80 <__alltraps>

0010228c <vector44>:
.globl vector44
vector44:
  pushl $0
  10228c:	6a 00                	push   $0x0
  pushl $44
  10228e:	6a 2c                	push   $0x2c
  jmp __alltraps
  102290:	e9 eb 08 00 00       	jmp    102b80 <__alltraps>

00102295 <vector45>:
.globl vector45
vector45:
  pushl $0
  102295:	6a 00                	push   $0x0
  pushl $45
  102297:	6a 2d                	push   $0x2d
  jmp __alltraps
  102299:	e9 e2 08 00 00       	jmp    102b80 <__alltraps>

0010229e <vector46>:
.globl vector46
vector46:
  pushl $0
  10229e:	6a 00                	push   $0x0
  pushl $46
  1022a0:	6a 2e                	push   $0x2e
  jmp __alltraps
  1022a2:	e9 d9 08 00 00       	jmp    102b80 <__alltraps>

001022a7 <vector47>:
.globl vector47
vector47:
  pushl $0
  1022a7:	6a 00                	push   $0x0
  pushl $47
  1022a9:	6a 2f                	push   $0x2f
  jmp __alltraps
  1022ab:	e9 d0 08 00 00       	jmp    102b80 <__alltraps>

001022b0 <vector48>:
.globl vector48
vector48:
  pushl $0
  1022b0:	6a 00                	push   $0x0
  pushl $48
  1022b2:	6a 30                	push   $0x30
  jmp __alltraps
  1022b4:	e9 c7 08 00 00       	jmp    102b80 <__alltraps>

001022b9 <vector49>:
.globl vector49
vector49:
  pushl $0
  1022b9:	6a 00                	push   $0x0
  pushl $49
  1022bb:	6a 31                	push   $0x31
  jmp __alltraps
  1022bd:	e9 be 08 00 00       	jmp    102b80 <__alltraps>

001022c2 <vector50>:
.globl vector50
vector50:
  pushl $0
  1022c2:	6a 00                	push   $0x0
  pushl $50
  1022c4:	6a 32                	push   $0x32
  jmp __alltraps
  1022c6:	e9 b5 08 00 00       	jmp    102b80 <__alltraps>

001022cb <vector51>:
.globl vector51
vector51:
  pushl $0
  1022cb:	6a 00                	push   $0x0
  pushl $51
  1022cd:	6a 33                	push   $0x33
  jmp __alltraps
  1022cf:	e9 ac 08 00 00       	jmp    102b80 <__alltraps>

001022d4 <vector52>:
.globl vector52
vector52:
  pushl $0
  1022d4:	6a 00                	push   $0x0
  pushl $52
  1022d6:	6a 34                	push   $0x34
  jmp __alltraps
  1022d8:	e9 a3 08 00 00       	jmp    102b80 <__alltraps>

001022dd <vector53>:
.globl vector53
vector53:
  pushl $0
  1022dd:	6a 00                	push   $0x0
  pushl $53
  1022df:	6a 35                	push   $0x35
  jmp __alltraps
  1022e1:	e9 9a 08 00 00       	jmp    102b80 <__alltraps>

001022e6 <vector54>:
.globl vector54
vector54:
  pushl $0
  1022e6:	6a 00                	push   $0x0
  pushl $54
  1022e8:	6a 36                	push   $0x36
  jmp __alltraps
  1022ea:	e9 91 08 00 00       	jmp    102b80 <__alltraps>

001022ef <vector55>:
.globl vector55
vector55:
  pushl $0
  1022ef:	6a 00                	push   $0x0
  pushl $55
  1022f1:	6a 37                	push   $0x37
  jmp __alltraps
  1022f3:	e9 88 08 00 00       	jmp    102b80 <__alltraps>

001022f8 <vector56>:
.globl vector56
vector56:
  pushl $0
  1022f8:	6a 00                	push   $0x0
  pushl $56
  1022fa:	6a 38                	push   $0x38
  jmp __alltraps
  1022fc:	e9 7f 08 00 00       	jmp    102b80 <__alltraps>

00102301 <vector57>:
.globl vector57
vector57:
  pushl $0
  102301:	6a 00                	push   $0x0
  pushl $57
  102303:	6a 39                	push   $0x39
  jmp __alltraps
  102305:	e9 76 08 00 00       	jmp    102b80 <__alltraps>

0010230a <vector58>:
.globl vector58
vector58:
  pushl $0
  10230a:	6a 00                	push   $0x0
  pushl $58
  10230c:	6a 3a                	push   $0x3a
  jmp __alltraps
  10230e:	e9 6d 08 00 00       	jmp    102b80 <__alltraps>

00102313 <vector59>:
.globl vector59
vector59:
  pushl $0
  102313:	6a 00                	push   $0x0
  pushl $59
  102315:	6a 3b                	push   $0x3b
  jmp __alltraps
  102317:	e9 64 08 00 00       	jmp    102b80 <__alltraps>

0010231c <vector60>:
.globl vector60
vector60:
  pushl $0
  10231c:	6a 00                	push   $0x0
  pushl $60
  10231e:	6a 3c                	push   $0x3c
  jmp __alltraps
  102320:	e9 5b 08 00 00       	jmp    102b80 <__alltraps>

00102325 <vector61>:
.globl vector61
vector61:
  pushl $0
  102325:	6a 00                	push   $0x0
  pushl $61
  102327:	6a 3d                	push   $0x3d
  jmp __alltraps
  102329:	e9 52 08 00 00       	jmp    102b80 <__alltraps>

0010232e <vector62>:
.globl vector62
vector62:
  pushl $0
  10232e:	6a 00                	push   $0x0
  pushl $62
  102330:	6a 3e                	push   $0x3e
  jmp __alltraps
  102332:	e9 49 08 00 00       	jmp    102b80 <__alltraps>

00102337 <vector63>:
.globl vector63
vector63:
  pushl $0
  102337:	6a 00                	push   $0x0
  pushl $63
  102339:	6a 3f                	push   $0x3f
  jmp __alltraps
  10233b:	e9 40 08 00 00       	jmp    102b80 <__alltraps>

00102340 <vector64>:
.globl vector64
vector64:
  pushl $0
  102340:	6a 00                	push   $0x0
  pushl $64
  102342:	6a 40                	push   $0x40
  jmp __alltraps
  102344:	e9 37 08 00 00       	jmp    102b80 <__alltraps>

00102349 <vector65>:
.globl vector65
vector65:
  pushl $0
  102349:	6a 00                	push   $0x0
  pushl $65
  10234b:	6a 41                	push   $0x41
  jmp __alltraps
  10234d:	e9 2e 08 00 00       	jmp    102b80 <__alltraps>

00102352 <vector66>:
.globl vector66
vector66:
  pushl $0
  102352:	6a 00                	push   $0x0
  pushl $66
  102354:	6a 42                	push   $0x42
  jmp __alltraps
  102356:	e9 25 08 00 00       	jmp    102b80 <__alltraps>

0010235b <vector67>:
.globl vector67
vector67:
  pushl $0
  10235b:	6a 00                	push   $0x0
  pushl $67
  10235d:	6a 43                	push   $0x43
  jmp __alltraps
  10235f:	e9 1c 08 00 00       	jmp    102b80 <__alltraps>

00102364 <vector68>:
.globl vector68
vector68:
  pushl $0
  102364:	6a 00                	push   $0x0
  pushl $68
  102366:	6a 44                	push   $0x44
  jmp __alltraps
  102368:	e9 13 08 00 00       	jmp    102b80 <__alltraps>

0010236d <vector69>:
.globl vector69
vector69:
  pushl $0
  10236d:	6a 00                	push   $0x0
  pushl $69
  10236f:	6a 45                	push   $0x45
  jmp __alltraps
  102371:	e9 0a 08 00 00       	jmp    102b80 <__alltraps>

00102376 <vector70>:
.globl vector70
vector70:
  pushl $0
  102376:	6a 00                	push   $0x0
  pushl $70
  102378:	6a 46                	push   $0x46
  jmp __alltraps
  10237a:	e9 01 08 00 00       	jmp    102b80 <__alltraps>

0010237f <vector71>:
.globl vector71
vector71:
  pushl $0
  10237f:	6a 00                	push   $0x0
  pushl $71
  102381:	6a 47                	push   $0x47
  jmp __alltraps
  102383:	e9 f8 07 00 00       	jmp    102b80 <__alltraps>

00102388 <vector72>:
.globl vector72
vector72:
  pushl $0
  102388:	6a 00                	push   $0x0
  pushl $72
  10238a:	6a 48                	push   $0x48
  jmp __alltraps
  10238c:	e9 ef 07 00 00       	jmp    102b80 <__alltraps>

00102391 <vector73>:
.globl vector73
vector73:
  pushl $0
  102391:	6a 00                	push   $0x0
  pushl $73
  102393:	6a 49                	push   $0x49
  jmp __alltraps
  102395:	e9 e6 07 00 00       	jmp    102b80 <__alltraps>

0010239a <vector74>:
.globl vector74
vector74:
  pushl $0
  10239a:	6a 00                	push   $0x0
  pushl $74
  10239c:	6a 4a                	push   $0x4a
  jmp __alltraps
  10239e:	e9 dd 07 00 00       	jmp    102b80 <__alltraps>

001023a3 <vector75>:
.globl vector75
vector75:
  pushl $0
  1023a3:	6a 00                	push   $0x0
  pushl $75
  1023a5:	6a 4b                	push   $0x4b
  jmp __alltraps
  1023a7:	e9 d4 07 00 00       	jmp    102b80 <__alltraps>

001023ac <vector76>:
.globl vector76
vector76:
  pushl $0
  1023ac:	6a 00                	push   $0x0
  pushl $76
  1023ae:	6a 4c                	push   $0x4c
  jmp __alltraps
  1023b0:	e9 cb 07 00 00       	jmp    102b80 <__alltraps>

001023b5 <vector77>:
.globl vector77
vector77:
  pushl $0
  1023b5:	6a 00                	push   $0x0
  pushl $77
  1023b7:	6a 4d                	push   $0x4d
  jmp __alltraps
  1023b9:	e9 c2 07 00 00       	jmp    102b80 <__alltraps>

001023be <vector78>:
.globl vector78
vector78:
  pushl $0
  1023be:	6a 00                	push   $0x0
  pushl $78
  1023c0:	6a 4e                	push   $0x4e
  jmp __alltraps
  1023c2:	e9 b9 07 00 00       	jmp    102b80 <__alltraps>

001023c7 <vector79>:
.globl vector79
vector79:
  pushl $0
  1023c7:	6a 00                	push   $0x0
  pushl $79
  1023c9:	6a 4f                	push   $0x4f
  jmp __alltraps
  1023cb:	e9 b0 07 00 00       	jmp    102b80 <__alltraps>

001023d0 <vector80>:
.globl vector80
vector80:
  pushl $0
  1023d0:	6a 00                	push   $0x0
  pushl $80
  1023d2:	6a 50                	push   $0x50
  jmp __alltraps
  1023d4:	e9 a7 07 00 00       	jmp    102b80 <__alltraps>

001023d9 <vector81>:
.globl vector81
vector81:
  pushl $0
  1023d9:	6a 00                	push   $0x0
  pushl $81
  1023db:	6a 51                	push   $0x51
  jmp __alltraps
  1023dd:	e9 9e 07 00 00       	jmp    102b80 <__alltraps>

001023e2 <vector82>:
.globl vector82
vector82:
  pushl $0
  1023e2:	6a 00                	push   $0x0
  pushl $82
  1023e4:	6a 52                	push   $0x52
  jmp __alltraps
  1023e6:	e9 95 07 00 00       	jmp    102b80 <__alltraps>

001023eb <vector83>:
.globl vector83
vector83:
  pushl $0
  1023eb:	6a 00                	push   $0x0
  pushl $83
  1023ed:	6a 53                	push   $0x53
  jmp __alltraps
  1023ef:	e9 8c 07 00 00       	jmp    102b80 <__alltraps>

001023f4 <vector84>:
.globl vector84
vector84:
  pushl $0
  1023f4:	6a 00                	push   $0x0
  pushl $84
  1023f6:	6a 54                	push   $0x54
  jmp __alltraps
  1023f8:	e9 83 07 00 00       	jmp    102b80 <__alltraps>

001023fd <vector85>:
.globl vector85
vector85:
  pushl $0
  1023fd:	6a 00                	push   $0x0
  pushl $85
  1023ff:	6a 55                	push   $0x55
  jmp __alltraps
  102401:	e9 7a 07 00 00       	jmp    102b80 <__alltraps>

00102406 <vector86>:
.globl vector86
vector86:
  pushl $0
  102406:	6a 00                	push   $0x0
  pushl $86
  102408:	6a 56                	push   $0x56
  jmp __alltraps
  10240a:	e9 71 07 00 00       	jmp    102b80 <__alltraps>

0010240f <vector87>:
.globl vector87
vector87:
  pushl $0
  10240f:	6a 00                	push   $0x0
  pushl $87
  102411:	6a 57                	push   $0x57
  jmp __alltraps
  102413:	e9 68 07 00 00       	jmp    102b80 <__alltraps>

00102418 <vector88>:
.globl vector88
vector88:
  pushl $0
  102418:	6a 00                	push   $0x0
  pushl $88
  10241a:	6a 58                	push   $0x58
  jmp __alltraps
  10241c:	e9 5f 07 00 00       	jmp    102b80 <__alltraps>

00102421 <vector89>:
.globl vector89
vector89:
  pushl $0
  102421:	6a 00                	push   $0x0
  pushl $89
  102423:	6a 59                	push   $0x59
  jmp __alltraps
  102425:	e9 56 07 00 00       	jmp    102b80 <__alltraps>

0010242a <vector90>:
.globl vector90
vector90:
  pushl $0
  10242a:	6a 00                	push   $0x0
  pushl $90
  10242c:	6a 5a                	push   $0x5a
  jmp __alltraps
  10242e:	e9 4d 07 00 00       	jmp    102b80 <__alltraps>

00102433 <vector91>:
.globl vector91
vector91:
  pushl $0
  102433:	6a 00                	push   $0x0
  pushl $91
  102435:	6a 5b                	push   $0x5b
  jmp __alltraps
  102437:	e9 44 07 00 00       	jmp    102b80 <__alltraps>

0010243c <vector92>:
.globl vector92
vector92:
  pushl $0
  10243c:	6a 00                	push   $0x0
  pushl $92
  10243e:	6a 5c                	push   $0x5c
  jmp __alltraps
  102440:	e9 3b 07 00 00       	jmp    102b80 <__alltraps>

00102445 <vector93>:
.globl vector93
vector93:
  pushl $0
  102445:	6a 00                	push   $0x0
  pushl $93
  102447:	6a 5d                	push   $0x5d
  jmp __alltraps
  102449:	e9 32 07 00 00       	jmp    102b80 <__alltraps>

0010244e <vector94>:
.globl vector94
vector94:
  pushl $0
  10244e:	6a 00                	push   $0x0
  pushl $94
  102450:	6a 5e                	push   $0x5e
  jmp __alltraps
  102452:	e9 29 07 00 00       	jmp    102b80 <__alltraps>

00102457 <vector95>:
.globl vector95
vector95:
  pushl $0
  102457:	6a 00                	push   $0x0
  pushl $95
  102459:	6a 5f                	push   $0x5f
  jmp __alltraps
  10245b:	e9 20 07 00 00       	jmp    102b80 <__alltraps>

00102460 <vector96>:
.globl vector96
vector96:
  pushl $0
  102460:	6a 00                	push   $0x0
  pushl $96
  102462:	6a 60                	push   $0x60
  jmp __alltraps
  102464:	e9 17 07 00 00       	jmp    102b80 <__alltraps>

00102469 <vector97>:
.globl vector97
vector97:
  pushl $0
  102469:	6a 00                	push   $0x0
  pushl $97
  10246b:	6a 61                	push   $0x61
  jmp __alltraps
  10246d:	e9 0e 07 00 00       	jmp    102b80 <__alltraps>

00102472 <vector98>:
.globl vector98
vector98:
  pushl $0
  102472:	6a 00                	push   $0x0
  pushl $98
  102474:	6a 62                	push   $0x62
  jmp __alltraps
  102476:	e9 05 07 00 00       	jmp    102b80 <__alltraps>

0010247b <vector99>:
.globl vector99
vector99:
  pushl $0
  10247b:	6a 00                	push   $0x0
  pushl $99
  10247d:	6a 63                	push   $0x63
  jmp __alltraps
  10247f:	e9 fc 06 00 00       	jmp    102b80 <__alltraps>

00102484 <vector100>:
.globl vector100
vector100:
  pushl $0
  102484:	6a 00                	push   $0x0
  pushl $100
  102486:	6a 64                	push   $0x64
  jmp __alltraps
  102488:	e9 f3 06 00 00       	jmp    102b80 <__alltraps>

0010248d <vector101>:
.globl vector101
vector101:
  pushl $0
  10248d:	6a 00                	push   $0x0
  pushl $101
  10248f:	6a 65                	push   $0x65
  jmp __alltraps
  102491:	e9 ea 06 00 00       	jmp    102b80 <__alltraps>

00102496 <vector102>:
.globl vector102
vector102:
  pushl $0
  102496:	6a 00                	push   $0x0
  pushl $102
  102498:	6a 66                	push   $0x66
  jmp __alltraps
  10249a:	e9 e1 06 00 00       	jmp    102b80 <__alltraps>

0010249f <vector103>:
.globl vector103
vector103:
  pushl $0
  10249f:	6a 00                	push   $0x0
  pushl $103
  1024a1:	6a 67                	push   $0x67
  jmp __alltraps
  1024a3:	e9 d8 06 00 00       	jmp    102b80 <__alltraps>

001024a8 <vector104>:
.globl vector104
vector104:
  pushl $0
  1024a8:	6a 00                	push   $0x0
  pushl $104
  1024aa:	6a 68                	push   $0x68
  jmp __alltraps
  1024ac:	e9 cf 06 00 00       	jmp    102b80 <__alltraps>

001024b1 <vector105>:
.globl vector105
vector105:
  pushl $0
  1024b1:	6a 00                	push   $0x0
  pushl $105
  1024b3:	6a 69                	push   $0x69
  jmp __alltraps
  1024b5:	e9 c6 06 00 00       	jmp    102b80 <__alltraps>

001024ba <vector106>:
.globl vector106
vector106:
  pushl $0
  1024ba:	6a 00                	push   $0x0
  pushl $106
  1024bc:	6a 6a                	push   $0x6a
  jmp __alltraps
  1024be:	e9 bd 06 00 00       	jmp    102b80 <__alltraps>

001024c3 <vector107>:
.globl vector107
vector107:
  pushl $0
  1024c3:	6a 00                	push   $0x0
  pushl $107
  1024c5:	6a 6b                	push   $0x6b
  jmp __alltraps
  1024c7:	e9 b4 06 00 00       	jmp    102b80 <__alltraps>

001024cc <vector108>:
.globl vector108
vector108:
  pushl $0
  1024cc:	6a 00                	push   $0x0
  pushl $108
  1024ce:	6a 6c                	push   $0x6c
  jmp __alltraps
  1024d0:	e9 ab 06 00 00       	jmp    102b80 <__alltraps>

001024d5 <vector109>:
.globl vector109
vector109:
  pushl $0
  1024d5:	6a 00                	push   $0x0
  pushl $109
  1024d7:	6a 6d                	push   $0x6d
  jmp __alltraps
  1024d9:	e9 a2 06 00 00       	jmp    102b80 <__alltraps>

001024de <vector110>:
.globl vector110
vector110:
  pushl $0
  1024de:	6a 00                	push   $0x0
  pushl $110
  1024e0:	6a 6e                	push   $0x6e
  jmp __alltraps
  1024e2:	e9 99 06 00 00       	jmp    102b80 <__alltraps>

001024e7 <vector111>:
.globl vector111
vector111:
  pushl $0
  1024e7:	6a 00                	push   $0x0
  pushl $111
  1024e9:	6a 6f                	push   $0x6f
  jmp __alltraps
  1024eb:	e9 90 06 00 00       	jmp    102b80 <__alltraps>

001024f0 <vector112>:
.globl vector112
vector112:
  pushl $0
  1024f0:	6a 00                	push   $0x0
  pushl $112
  1024f2:	6a 70                	push   $0x70
  jmp __alltraps
  1024f4:	e9 87 06 00 00       	jmp    102b80 <__alltraps>

001024f9 <vector113>:
.globl vector113
vector113:
  pushl $0
  1024f9:	6a 00                	push   $0x0
  pushl $113
  1024fb:	6a 71                	push   $0x71
  jmp __alltraps
  1024fd:	e9 7e 06 00 00       	jmp    102b80 <__alltraps>

00102502 <vector114>:
.globl vector114
vector114:
  pushl $0
  102502:	6a 00                	push   $0x0
  pushl $114
  102504:	6a 72                	push   $0x72
  jmp __alltraps
  102506:	e9 75 06 00 00       	jmp    102b80 <__alltraps>

0010250b <vector115>:
.globl vector115
vector115:
  pushl $0
  10250b:	6a 00                	push   $0x0
  pushl $115
  10250d:	6a 73                	push   $0x73
  jmp __alltraps
  10250f:	e9 6c 06 00 00       	jmp    102b80 <__alltraps>

00102514 <vector116>:
.globl vector116
vector116:
  pushl $0
  102514:	6a 00                	push   $0x0
  pushl $116
  102516:	6a 74                	push   $0x74
  jmp __alltraps
  102518:	e9 63 06 00 00       	jmp    102b80 <__alltraps>

0010251d <vector117>:
.globl vector117
vector117:
  pushl $0
  10251d:	6a 00                	push   $0x0
  pushl $117
  10251f:	6a 75                	push   $0x75
  jmp __alltraps
  102521:	e9 5a 06 00 00       	jmp    102b80 <__alltraps>

00102526 <vector118>:
.globl vector118
vector118:
  pushl $0
  102526:	6a 00                	push   $0x0
  pushl $118
  102528:	6a 76                	push   $0x76
  jmp __alltraps
  10252a:	e9 51 06 00 00       	jmp    102b80 <__alltraps>

0010252f <vector119>:
.globl vector119
vector119:
  pushl $0
  10252f:	6a 00                	push   $0x0
  pushl $119
  102531:	6a 77                	push   $0x77
  jmp __alltraps
  102533:	e9 48 06 00 00       	jmp    102b80 <__alltraps>

00102538 <vector120>:
.globl vector120
vector120:
  pushl $0
  102538:	6a 00                	push   $0x0
  pushl $120
  10253a:	6a 78                	push   $0x78
  jmp __alltraps
  10253c:	e9 3f 06 00 00       	jmp    102b80 <__alltraps>

00102541 <vector121>:
.globl vector121
vector121:
  pushl $0
  102541:	6a 00                	push   $0x0
  pushl $121
  102543:	6a 79                	push   $0x79
  jmp __alltraps
  102545:	e9 36 06 00 00       	jmp    102b80 <__alltraps>

0010254a <vector122>:
.globl vector122
vector122:
  pushl $0
  10254a:	6a 00                	push   $0x0
  pushl $122
  10254c:	6a 7a                	push   $0x7a
  jmp __alltraps
  10254e:	e9 2d 06 00 00       	jmp    102b80 <__alltraps>

00102553 <vector123>:
.globl vector123
vector123:
  pushl $0
  102553:	6a 00                	push   $0x0
  pushl $123
  102555:	6a 7b                	push   $0x7b
  jmp __alltraps
  102557:	e9 24 06 00 00       	jmp    102b80 <__alltraps>

0010255c <vector124>:
.globl vector124
vector124:
  pushl $0
  10255c:	6a 00                	push   $0x0
  pushl $124
  10255e:	6a 7c                	push   $0x7c
  jmp __alltraps
  102560:	e9 1b 06 00 00       	jmp    102b80 <__alltraps>

00102565 <vector125>:
.globl vector125
vector125:
  pushl $0
  102565:	6a 00                	push   $0x0
  pushl $125
  102567:	6a 7d                	push   $0x7d
  jmp __alltraps
  102569:	e9 12 06 00 00       	jmp    102b80 <__alltraps>

0010256e <vector126>:
.globl vector126
vector126:
  pushl $0
  10256e:	6a 00                	push   $0x0
  pushl $126
  102570:	6a 7e                	push   $0x7e
  jmp __alltraps
  102572:	e9 09 06 00 00       	jmp    102b80 <__alltraps>

00102577 <vector127>:
.globl vector127
vector127:
  pushl $0
  102577:	6a 00                	push   $0x0
  pushl $127
  102579:	6a 7f                	push   $0x7f
  jmp __alltraps
  10257b:	e9 00 06 00 00       	jmp    102b80 <__alltraps>

00102580 <vector128>:
.globl vector128
vector128:
  pushl $0
  102580:	6a 00                	push   $0x0
  pushl $128
  102582:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102587:	e9 f4 05 00 00       	jmp    102b80 <__alltraps>

0010258c <vector129>:
.globl vector129
vector129:
  pushl $0
  10258c:	6a 00                	push   $0x0
  pushl $129
  10258e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102593:	e9 e8 05 00 00       	jmp    102b80 <__alltraps>

00102598 <vector130>:
.globl vector130
vector130:
  pushl $0
  102598:	6a 00                	push   $0x0
  pushl $130
  10259a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10259f:	e9 dc 05 00 00       	jmp    102b80 <__alltraps>

001025a4 <vector131>:
.globl vector131
vector131:
  pushl $0
  1025a4:	6a 00                	push   $0x0
  pushl $131
  1025a6:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1025ab:	e9 d0 05 00 00       	jmp    102b80 <__alltraps>

001025b0 <vector132>:
.globl vector132
vector132:
  pushl $0
  1025b0:	6a 00                	push   $0x0
  pushl $132
  1025b2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1025b7:	e9 c4 05 00 00       	jmp    102b80 <__alltraps>

001025bc <vector133>:
.globl vector133
vector133:
  pushl $0
  1025bc:	6a 00                	push   $0x0
  pushl $133
  1025be:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1025c3:	e9 b8 05 00 00       	jmp    102b80 <__alltraps>

001025c8 <vector134>:
.globl vector134
vector134:
  pushl $0
  1025c8:	6a 00                	push   $0x0
  pushl $134
  1025ca:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1025cf:	e9 ac 05 00 00       	jmp    102b80 <__alltraps>

001025d4 <vector135>:
.globl vector135
vector135:
  pushl $0
  1025d4:	6a 00                	push   $0x0
  pushl $135
  1025d6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1025db:	e9 a0 05 00 00       	jmp    102b80 <__alltraps>

001025e0 <vector136>:
.globl vector136
vector136:
  pushl $0
  1025e0:	6a 00                	push   $0x0
  pushl $136
  1025e2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1025e7:	e9 94 05 00 00       	jmp    102b80 <__alltraps>

001025ec <vector137>:
.globl vector137
vector137:
  pushl $0
  1025ec:	6a 00                	push   $0x0
  pushl $137
  1025ee:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1025f3:	e9 88 05 00 00       	jmp    102b80 <__alltraps>

001025f8 <vector138>:
.globl vector138
vector138:
  pushl $0
  1025f8:	6a 00                	push   $0x0
  pushl $138
  1025fa:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1025ff:	e9 7c 05 00 00       	jmp    102b80 <__alltraps>

00102604 <vector139>:
.globl vector139
vector139:
  pushl $0
  102604:	6a 00                	push   $0x0
  pushl $139
  102606:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10260b:	e9 70 05 00 00       	jmp    102b80 <__alltraps>

00102610 <vector140>:
.globl vector140
vector140:
  pushl $0
  102610:	6a 00                	push   $0x0
  pushl $140
  102612:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102617:	e9 64 05 00 00       	jmp    102b80 <__alltraps>

0010261c <vector141>:
.globl vector141
vector141:
  pushl $0
  10261c:	6a 00                	push   $0x0
  pushl $141
  10261e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102623:	e9 58 05 00 00       	jmp    102b80 <__alltraps>

00102628 <vector142>:
.globl vector142
vector142:
  pushl $0
  102628:	6a 00                	push   $0x0
  pushl $142
  10262a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10262f:	e9 4c 05 00 00       	jmp    102b80 <__alltraps>

00102634 <vector143>:
.globl vector143
vector143:
  pushl $0
  102634:	6a 00                	push   $0x0
  pushl $143
  102636:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10263b:	e9 40 05 00 00       	jmp    102b80 <__alltraps>

00102640 <vector144>:
.globl vector144
vector144:
  pushl $0
  102640:	6a 00                	push   $0x0
  pushl $144
  102642:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102647:	e9 34 05 00 00       	jmp    102b80 <__alltraps>

0010264c <vector145>:
.globl vector145
vector145:
  pushl $0
  10264c:	6a 00                	push   $0x0
  pushl $145
  10264e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102653:	e9 28 05 00 00       	jmp    102b80 <__alltraps>

00102658 <vector146>:
.globl vector146
vector146:
  pushl $0
  102658:	6a 00                	push   $0x0
  pushl $146
  10265a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10265f:	e9 1c 05 00 00       	jmp    102b80 <__alltraps>

00102664 <vector147>:
.globl vector147
vector147:
  pushl $0
  102664:	6a 00                	push   $0x0
  pushl $147
  102666:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10266b:	e9 10 05 00 00       	jmp    102b80 <__alltraps>

00102670 <vector148>:
.globl vector148
vector148:
  pushl $0
  102670:	6a 00                	push   $0x0
  pushl $148
  102672:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102677:	e9 04 05 00 00       	jmp    102b80 <__alltraps>

0010267c <vector149>:
.globl vector149
vector149:
  pushl $0
  10267c:	6a 00                	push   $0x0
  pushl $149
  10267e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102683:	e9 f8 04 00 00       	jmp    102b80 <__alltraps>

00102688 <vector150>:
.globl vector150
vector150:
  pushl $0
  102688:	6a 00                	push   $0x0
  pushl $150
  10268a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10268f:	e9 ec 04 00 00       	jmp    102b80 <__alltraps>

00102694 <vector151>:
.globl vector151
vector151:
  pushl $0
  102694:	6a 00                	push   $0x0
  pushl $151
  102696:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10269b:	e9 e0 04 00 00       	jmp    102b80 <__alltraps>

001026a0 <vector152>:
.globl vector152
vector152:
  pushl $0
  1026a0:	6a 00                	push   $0x0
  pushl $152
  1026a2:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1026a7:	e9 d4 04 00 00       	jmp    102b80 <__alltraps>

001026ac <vector153>:
.globl vector153
vector153:
  pushl $0
  1026ac:	6a 00                	push   $0x0
  pushl $153
  1026ae:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1026b3:	e9 c8 04 00 00       	jmp    102b80 <__alltraps>

001026b8 <vector154>:
.globl vector154
vector154:
  pushl $0
  1026b8:	6a 00                	push   $0x0
  pushl $154
  1026ba:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1026bf:	e9 bc 04 00 00       	jmp    102b80 <__alltraps>

001026c4 <vector155>:
.globl vector155
vector155:
  pushl $0
  1026c4:	6a 00                	push   $0x0
  pushl $155
  1026c6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1026cb:	e9 b0 04 00 00       	jmp    102b80 <__alltraps>

001026d0 <vector156>:
.globl vector156
vector156:
  pushl $0
  1026d0:	6a 00                	push   $0x0
  pushl $156
  1026d2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1026d7:	e9 a4 04 00 00       	jmp    102b80 <__alltraps>

001026dc <vector157>:
.globl vector157
vector157:
  pushl $0
  1026dc:	6a 00                	push   $0x0
  pushl $157
  1026de:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1026e3:	e9 98 04 00 00       	jmp    102b80 <__alltraps>

001026e8 <vector158>:
.globl vector158
vector158:
  pushl $0
  1026e8:	6a 00                	push   $0x0
  pushl $158
  1026ea:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1026ef:	e9 8c 04 00 00       	jmp    102b80 <__alltraps>

001026f4 <vector159>:
.globl vector159
vector159:
  pushl $0
  1026f4:	6a 00                	push   $0x0
  pushl $159
  1026f6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1026fb:	e9 80 04 00 00       	jmp    102b80 <__alltraps>

00102700 <vector160>:
.globl vector160
vector160:
  pushl $0
  102700:	6a 00                	push   $0x0
  pushl $160
  102702:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102707:	e9 74 04 00 00       	jmp    102b80 <__alltraps>

0010270c <vector161>:
.globl vector161
vector161:
  pushl $0
  10270c:	6a 00                	push   $0x0
  pushl $161
  10270e:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102713:	e9 68 04 00 00       	jmp    102b80 <__alltraps>

00102718 <vector162>:
.globl vector162
vector162:
  pushl $0
  102718:	6a 00                	push   $0x0
  pushl $162
  10271a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10271f:	e9 5c 04 00 00       	jmp    102b80 <__alltraps>

00102724 <vector163>:
.globl vector163
vector163:
  pushl $0
  102724:	6a 00                	push   $0x0
  pushl $163
  102726:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10272b:	e9 50 04 00 00       	jmp    102b80 <__alltraps>

00102730 <vector164>:
.globl vector164
vector164:
  pushl $0
  102730:	6a 00                	push   $0x0
  pushl $164
  102732:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102737:	e9 44 04 00 00       	jmp    102b80 <__alltraps>

0010273c <vector165>:
.globl vector165
vector165:
  pushl $0
  10273c:	6a 00                	push   $0x0
  pushl $165
  10273e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102743:	e9 38 04 00 00       	jmp    102b80 <__alltraps>

00102748 <vector166>:
.globl vector166
vector166:
  pushl $0
  102748:	6a 00                	push   $0x0
  pushl $166
  10274a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10274f:	e9 2c 04 00 00       	jmp    102b80 <__alltraps>

00102754 <vector167>:
.globl vector167
vector167:
  pushl $0
  102754:	6a 00                	push   $0x0
  pushl $167
  102756:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10275b:	e9 20 04 00 00       	jmp    102b80 <__alltraps>

00102760 <vector168>:
.globl vector168
vector168:
  pushl $0
  102760:	6a 00                	push   $0x0
  pushl $168
  102762:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102767:	e9 14 04 00 00       	jmp    102b80 <__alltraps>

0010276c <vector169>:
.globl vector169
vector169:
  pushl $0
  10276c:	6a 00                	push   $0x0
  pushl $169
  10276e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102773:	e9 08 04 00 00       	jmp    102b80 <__alltraps>

00102778 <vector170>:
.globl vector170
vector170:
  pushl $0
  102778:	6a 00                	push   $0x0
  pushl $170
  10277a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10277f:	e9 fc 03 00 00       	jmp    102b80 <__alltraps>

00102784 <vector171>:
.globl vector171
vector171:
  pushl $0
  102784:	6a 00                	push   $0x0
  pushl $171
  102786:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10278b:	e9 f0 03 00 00       	jmp    102b80 <__alltraps>

00102790 <vector172>:
.globl vector172
vector172:
  pushl $0
  102790:	6a 00                	push   $0x0
  pushl $172
  102792:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102797:	e9 e4 03 00 00       	jmp    102b80 <__alltraps>

0010279c <vector173>:
.globl vector173
vector173:
  pushl $0
  10279c:	6a 00                	push   $0x0
  pushl $173
  10279e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1027a3:	e9 d8 03 00 00       	jmp    102b80 <__alltraps>

001027a8 <vector174>:
.globl vector174
vector174:
  pushl $0
  1027a8:	6a 00                	push   $0x0
  pushl $174
  1027aa:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1027af:	e9 cc 03 00 00       	jmp    102b80 <__alltraps>

001027b4 <vector175>:
.globl vector175
vector175:
  pushl $0
  1027b4:	6a 00                	push   $0x0
  pushl $175
  1027b6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1027bb:	e9 c0 03 00 00       	jmp    102b80 <__alltraps>

001027c0 <vector176>:
.globl vector176
vector176:
  pushl $0
  1027c0:	6a 00                	push   $0x0
  pushl $176
  1027c2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1027c7:	e9 b4 03 00 00       	jmp    102b80 <__alltraps>

001027cc <vector177>:
.globl vector177
vector177:
  pushl $0
  1027cc:	6a 00                	push   $0x0
  pushl $177
  1027ce:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1027d3:	e9 a8 03 00 00       	jmp    102b80 <__alltraps>

001027d8 <vector178>:
.globl vector178
vector178:
  pushl $0
  1027d8:	6a 00                	push   $0x0
  pushl $178
  1027da:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1027df:	e9 9c 03 00 00       	jmp    102b80 <__alltraps>

001027e4 <vector179>:
.globl vector179
vector179:
  pushl $0
  1027e4:	6a 00                	push   $0x0
  pushl $179
  1027e6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1027eb:	e9 90 03 00 00       	jmp    102b80 <__alltraps>

001027f0 <vector180>:
.globl vector180
vector180:
  pushl $0
  1027f0:	6a 00                	push   $0x0
  pushl $180
  1027f2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1027f7:	e9 84 03 00 00       	jmp    102b80 <__alltraps>

001027fc <vector181>:
.globl vector181
vector181:
  pushl $0
  1027fc:	6a 00                	push   $0x0
  pushl $181
  1027fe:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102803:	e9 78 03 00 00       	jmp    102b80 <__alltraps>

00102808 <vector182>:
.globl vector182
vector182:
  pushl $0
  102808:	6a 00                	push   $0x0
  pushl $182
  10280a:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10280f:	e9 6c 03 00 00       	jmp    102b80 <__alltraps>

00102814 <vector183>:
.globl vector183
vector183:
  pushl $0
  102814:	6a 00                	push   $0x0
  pushl $183
  102816:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10281b:	e9 60 03 00 00       	jmp    102b80 <__alltraps>

00102820 <vector184>:
.globl vector184
vector184:
  pushl $0
  102820:	6a 00                	push   $0x0
  pushl $184
  102822:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102827:	e9 54 03 00 00       	jmp    102b80 <__alltraps>

0010282c <vector185>:
.globl vector185
vector185:
  pushl $0
  10282c:	6a 00                	push   $0x0
  pushl $185
  10282e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102833:	e9 48 03 00 00       	jmp    102b80 <__alltraps>

00102838 <vector186>:
.globl vector186
vector186:
  pushl $0
  102838:	6a 00                	push   $0x0
  pushl $186
  10283a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10283f:	e9 3c 03 00 00       	jmp    102b80 <__alltraps>

00102844 <vector187>:
.globl vector187
vector187:
  pushl $0
  102844:	6a 00                	push   $0x0
  pushl $187
  102846:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10284b:	e9 30 03 00 00       	jmp    102b80 <__alltraps>

00102850 <vector188>:
.globl vector188
vector188:
  pushl $0
  102850:	6a 00                	push   $0x0
  pushl $188
  102852:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102857:	e9 24 03 00 00       	jmp    102b80 <__alltraps>

0010285c <vector189>:
.globl vector189
vector189:
  pushl $0
  10285c:	6a 00                	push   $0x0
  pushl $189
  10285e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102863:	e9 18 03 00 00       	jmp    102b80 <__alltraps>

00102868 <vector190>:
.globl vector190
vector190:
  pushl $0
  102868:	6a 00                	push   $0x0
  pushl $190
  10286a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10286f:	e9 0c 03 00 00       	jmp    102b80 <__alltraps>

00102874 <vector191>:
.globl vector191
vector191:
  pushl $0
  102874:	6a 00                	push   $0x0
  pushl $191
  102876:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10287b:	e9 00 03 00 00       	jmp    102b80 <__alltraps>

00102880 <vector192>:
.globl vector192
vector192:
  pushl $0
  102880:	6a 00                	push   $0x0
  pushl $192
  102882:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102887:	e9 f4 02 00 00       	jmp    102b80 <__alltraps>

0010288c <vector193>:
.globl vector193
vector193:
  pushl $0
  10288c:	6a 00                	push   $0x0
  pushl $193
  10288e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102893:	e9 e8 02 00 00       	jmp    102b80 <__alltraps>

00102898 <vector194>:
.globl vector194
vector194:
  pushl $0
  102898:	6a 00                	push   $0x0
  pushl $194
  10289a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10289f:	e9 dc 02 00 00       	jmp    102b80 <__alltraps>

001028a4 <vector195>:
.globl vector195
vector195:
  pushl $0
  1028a4:	6a 00                	push   $0x0
  pushl $195
  1028a6:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1028ab:	e9 d0 02 00 00       	jmp    102b80 <__alltraps>

001028b0 <vector196>:
.globl vector196
vector196:
  pushl $0
  1028b0:	6a 00                	push   $0x0
  pushl $196
  1028b2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1028b7:	e9 c4 02 00 00       	jmp    102b80 <__alltraps>

001028bc <vector197>:
.globl vector197
vector197:
  pushl $0
  1028bc:	6a 00                	push   $0x0
  pushl $197
  1028be:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1028c3:	e9 b8 02 00 00       	jmp    102b80 <__alltraps>

001028c8 <vector198>:
.globl vector198
vector198:
  pushl $0
  1028c8:	6a 00                	push   $0x0
  pushl $198
  1028ca:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1028cf:	e9 ac 02 00 00       	jmp    102b80 <__alltraps>

001028d4 <vector199>:
.globl vector199
vector199:
  pushl $0
  1028d4:	6a 00                	push   $0x0
  pushl $199
  1028d6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1028db:	e9 a0 02 00 00       	jmp    102b80 <__alltraps>

001028e0 <vector200>:
.globl vector200
vector200:
  pushl $0
  1028e0:	6a 00                	push   $0x0
  pushl $200
  1028e2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1028e7:	e9 94 02 00 00       	jmp    102b80 <__alltraps>

001028ec <vector201>:
.globl vector201
vector201:
  pushl $0
  1028ec:	6a 00                	push   $0x0
  pushl $201
  1028ee:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1028f3:	e9 88 02 00 00       	jmp    102b80 <__alltraps>

001028f8 <vector202>:
.globl vector202
vector202:
  pushl $0
  1028f8:	6a 00                	push   $0x0
  pushl $202
  1028fa:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1028ff:	e9 7c 02 00 00       	jmp    102b80 <__alltraps>

00102904 <vector203>:
.globl vector203
vector203:
  pushl $0
  102904:	6a 00                	push   $0x0
  pushl $203
  102906:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10290b:	e9 70 02 00 00       	jmp    102b80 <__alltraps>

00102910 <vector204>:
.globl vector204
vector204:
  pushl $0
  102910:	6a 00                	push   $0x0
  pushl $204
  102912:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102917:	e9 64 02 00 00       	jmp    102b80 <__alltraps>

0010291c <vector205>:
.globl vector205
vector205:
  pushl $0
  10291c:	6a 00                	push   $0x0
  pushl $205
  10291e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102923:	e9 58 02 00 00       	jmp    102b80 <__alltraps>

00102928 <vector206>:
.globl vector206
vector206:
  pushl $0
  102928:	6a 00                	push   $0x0
  pushl $206
  10292a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10292f:	e9 4c 02 00 00       	jmp    102b80 <__alltraps>

00102934 <vector207>:
.globl vector207
vector207:
  pushl $0
  102934:	6a 00                	push   $0x0
  pushl $207
  102936:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10293b:	e9 40 02 00 00       	jmp    102b80 <__alltraps>

00102940 <vector208>:
.globl vector208
vector208:
  pushl $0
  102940:	6a 00                	push   $0x0
  pushl $208
  102942:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102947:	e9 34 02 00 00       	jmp    102b80 <__alltraps>

0010294c <vector209>:
.globl vector209
vector209:
  pushl $0
  10294c:	6a 00                	push   $0x0
  pushl $209
  10294e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102953:	e9 28 02 00 00       	jmp    102b80 <__alltraps>

00102958 <vector210>:
.globl vector210
vector210:
  pushl $0
  102958:	6a 00                	push   $0x0
  pushl $210
  10295a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10295f:	e9 1c 02 00 00       	jmp    102b80 <__alltraps>

00102964 <vector211>:
.globl vector211
vector211:
  pushl $0
  102964:	6a 00                	push   $0x0
  pushl $211
  102966:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10296b:	e9 10 02 00 00       	jmp    102b80 <__alltraps>

00102970 <vector212>:
.globl vector212
vector212:
  pushl $0
  102970:	6a 00                	push   $0x0
  pushl $212
  102972:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102977:	e9 04 02 00 00       	jmp    102b80 <__alltraps>

0010297c <vector213>:
.globl vector213
vector213:
  pushl $0
  10297c:	6a 00                	push   $0x0
  pushl $213
  10297e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102983:	e9 f8 01 00 00       	jmp    102b80 <__alltraps>

00102988 <vector214>:
.globl vector214
vector214:
  pushl $0
  102988:	6a 00                	push   $0x0
  pushl $214
  10298a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10298f:	e9 ec 01 00 00       	jmp    102b80 <__alltraps>

00102994 <vector215>:
.globl vector215
vector215:
  pushl $0
  102994:	6a 00                	push   $0x0
  pushl $215
  102996:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10299b:	e9 e0 01 00 00       	jmp    102b80 <__alltraps>

001029a0 <vector216>:
.globl vector216
vector216:
  pushl $0
  1029a0:	6a 00                	push   $0x0
  pushl $216
  1029a2:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1029a7:	e9 d4 01 00 00       	jmp    102b80 <__alltraps>

001029ac <vector217>:
.globl vector217
vector217:
  pushl $0
  1029ac:	6a 00                	push   $0x0
  pushl $217
  1029ae:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1029b3:	e9 c8 01 00 00       	jmp    102b80 <__alltraps>

001029b8 <vector218>:
.globl vector218
vector218:
  pushl $0
  1029b8:	6a 00                	push   $0x0
  pushl $218
  1029ba:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1029bf:	e9 bc 01 00 00       	jmp    102b80 <__alltraps>

001029c4 <vector219>:
.globl vector219
vector219:
  pushl $0
  1029c4:	6a 00                	push   $0x0
  pushl $219
  1029c6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1029cb:	e9 b0 01 00 00       	jmp    102b80 <__alltraps>

001029d0 <vector220>:
.globl vector220
vector220:
  pushl $0
  1029d0:	6a 00                	push   $0x0
  pushl $220
  1029d2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1029d7:	e9 a4 01 00 00       	jmp    102b80 <__alltraps>

001029dc <vector221>:
.globl vector221
vector221:
  pushl $0
  1029dc:	6a 00                	push   $0x0
  pushl $221
  1029de:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1029e3:	e9 98 01 00 00       	jmp    102b80 <__alltraps>

001029e8 <vector222>:
.globl vector222
vector222:
  pushl $0
  1029e8:	6a 00                	push   $0x0
  pushl $222
  1029ea:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1029ef:	e9 8c 01 00 00       	jmp    102b80 <__alltraps>

001029f4 <vector223>:
.globl vector223
vector223:
  pushl $0
  1029f4:	6a 00                	push   $0x0
  pushl $223
  1029f6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1029fb:	e9 80 01 00 00       	jmp    102b80 <__alltraps>

00102a00 <vector224>:
.globl vector224
vector224:
  pushl $0
  102a00:	6a 00                	push   $0x0
  pushl $224
  102a02:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102a07:	e9 74 01 00 00       	jmp    102b80 <__alltraps>

00102a0c <vector225>:
.globl vector225
vector225:
  pushl $0
  102a0c:	6a 00                	push   $0x0
  pushl $225
  102a0e:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102a13:	e9 68 01 00 00       	jmp    102b80 <__alltraps>

00102a18 <vector226>:
.globl vector226
vector226:
  pushl $0
  102a18:	6a 00                	push   $0x0
  pushl $226
  102a1a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102a1f:	e9 5c 01 00 00       	jmp    102b80 <__alltraps>

00102a24 <vector227>:
.globl vector227
vector227:
  pushl $0
  102a24:	6a 00                	push   $0x0
  pushl $227
  102a26:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102a2b:	e9 50 01 00 00       	jmp    102b80 <__alltraps>

00102a30 <vector228>:
.globl vector228
vector228:
  pushl $0
  102a30:	6a 00                	push   $0x0
  pushl $228
  102a32:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102a37:	e9 44 01 00 00       	jmp    102b80 <__alltraps>

00102a3c <vector229>:
.globl vector229
vector229:
  pushl $0
  102a3c:	6a 00                	push   $0x0
  pushl $229
  102a3e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102a43:	e9 38 01 00 00       	jmp    102b80 <__alltraps>

00102a48 <vector230>:
.globl vector230
vector230:
  pushl $0
  102a48:	6a 00                	push   $0x0
  pushl $230
  102a4a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102a4f:	e9 2c 01 00 00       	jmp    102b80 <__alltraps>

00102a54 <vector231>:
.globl vector231
vector231:
  pushl $0
  102a54:	6a 00                	push   $0x0
  pushl $231
  102a56:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102a5b:	e9 20 01 00 00       	jmp    102b80 <__alltraps>

00102a60 <vector232>:
.globl vector232
vector232:
  pushl $0
  102a60:	6a 00                	push   $0x0
  pushl $232
  102a62:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102a67:	e9 14 01 00 00       	jmp    102b80 <__alltraps>

00102a6c <vector233>:
.globl vector233
vector233:
  pushl $0
  102a6c:	6a 00                	push   $0x0
  pushl $233
  102a6e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102a73:	e9 08 01 00 00       	jmp    102b80 <__alltraps>

00102a78 <vector234>:
.globl vector234
vector234:
  pushl $0
  102a78:	6a 00                	push   $0x0
  pushl $234
  102a7a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102a7f:	e9 fc 00 00 00       	jmp    102b80 <__alltraps>

00102a84 <vector235>:
.globl vector235
vector235:
  pushl $0
  102a84:	6a 00                	push   $0x0
  pushl $235
  102a86:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102a8b:	e9 f0 00 00 00       	jmp    102b80 <__alltraps>

00102a90 <vector236>:
.globl vector236
vector236:
  pushl $0
  102a90:	6a 00                	push   $0x0
  pushl $236
  102a92:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102a97:	e9 e4 00 00 00       	jmp    102b80 <__alltraps>

00102a9c <vector237>:
.globl vector237
vector237:
  pushl $0
  102a9c:	6a 00                	push   $0x0
  pushl $237
  102a9e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102aa3:	e9 d8 00 00 00       	jmp    102b80 <__alltraps>

00102aa8 <vector238>:
.globl vector238
vector238:
  pushl $0
  102aa8:	6a 00                	push   $0x0
  pushl $238
  102aaa:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102aaf:	e9 cc 00 00 00       	jmp    102b80 <__alltraps>

00102ab4 <vector239>:
.globl vector239
vector239:
  pushl $0
  102ab4:	6a 00                	push   $0x0
  pushl $239
  102ab6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102abb:	e9 c0 00 00 00       	jmp    102b80 <__alltraps>

00102ac0 <vector240>:
.globl vector240
vector240:
  pushl $0
  102ac0:	6a 00                	push   $0x0
  pushl $240
  102ac2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102ac7:	e9 b4 00 00 00       	jmp    102b80 <__alltraps>

00102acc <vector241>:
.globl vector241
vector241:
  pushl $0
  102acc:	6a 00                	push   $0x0
  pushl $241
  102ace:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102ad3:	e9 a8 00 00 00       	jmp    102b80 <__alltraps>

00102ad8 <vector242>:
.globl vector242
vector242:
  pushl $0
  102ad8:	6a 00                	push   $0x0
  pushl $242
  102ada:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102adf:	e9 9c 00 00 00       	jmp    102b80 <__alltraps>

00102ae4 <vector243>:
.globl vector243
vector243:
  pushl $0
  102ae4:	6a 00                	push   $0x0
  pushl $243
  102ae6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102aeb:	e9 90 00 00 00       	jmp    102b80 <__alltraps>

00102af0 <vector244>:
.globl vector244
vector244:
  pushl $0
  102af0:	6a 00                	push   $0x0
  pushl $244
  102af2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102af7:	e9 84 00 00 00       	jmp    102b80 <__alltraps>

00102afc <vector245>:
.globl vector245
vector245:
  pushl $0
  102afc:	6a 00                	push   $0x0
  pushl $245
  102afe:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102b03:	e9 78 00 00 00       	jmp    102b80 <__alltraps>

00102b08 <vector246>:
.globl vector246
vector246:
  pushl $0
  102b08:	6a 00                	push   $0x0
  pushl $246
  102b0a:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102b0f:	e9 6c 00 00 00       	jmp    102b80 <__alltraps>

00102b14 <vector247>:
.globl vector247
vector247:
  pushl $0
  102b14:	6a 00                	push   $0x0
  pushl $247
  102b16:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102b1b:	e9 60 00 00 00       	jmp    102b80 <__alltraps>

00102b20 <vector248>:
.globl vector248
vector248:
  pushl $0
  102b20:	6a 00                	push   $0x0
  pushl $248
  102b22:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102b27:	e9 54 00 00 00       	jmp    102b80 <__alltraps>

00102b2c <vector249>:
.globl vector249
vector249:
  pushl $0
  102b2c:	6a 00                	push   $0x0
  pushl $249
  102b2e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102b33:	e9 48 00 00 00       	jmp    102b80 <__alltraps>

00102b38 <vector250>:
.globl vector250
vector250:
  pushl $0
  102b38:	6a 00                	push   $0x0
  pushl $250
  102b3a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102b3f:	e9 3c 00 00 00       	jmp    102b80 <__alltraps>

00102b44 <vector251>:
.globl vector251
vector251:
  pushl $0
  102b44:	6a 00                	push   $0x0
  pushl $251
  102b46:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102b4b:	e9 30 00 00 00       	jmp    102b80 <__alltraps>

00102b50 <vector252>:
.globl vector252
vector252:
  pushl $0
  102b50:	6a 00                	push   $0x0
  pushl $252
  102b52:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102b57:	e9 24 00 00 00       	jmp    102b80 <__alltraps>

00102b5c <vector253>:
.globl vector253
vector253:
  pushl $0
  102b5c:	6a 00                	push   $0x0
  pushl $253
  102b5e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102b63:	e9 18 00 00 00       	jmp    102b80 <__alltraps>

00102b68 <vector254>:
.globl vector254
vector254:
  pushl $0
  102b68:	6a 00                	push   $0x0
  pushl $254
  102b6a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102b6f:	e9 0c 00 00 00       	jmp    102b80 <__alltraps>

00102b74 <vector255>:
.globl vector255
vector255:
  pushl $0
  102b74:	6a 00                	push   $0x0
  pushl $255
  102b76:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102b7b:	e9 00 00 00 00       	jmp    102b80 <__alltraps>

00102b80 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102b80:	1e                   	push   %ds
    pushl %es
  102b81:	06                   	push   %es
    pushl %fs
  102b82:	0f a0                	push   %fs
    pushl %gs
  102b84:	0f a8                	push   %gs
    pushal
  102b86:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102b87:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102b8c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102b8e:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102b90:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102b91:	e8 5f f5 ff ff       	call   1020f5 <trap>

    # pop the pushed stack pointer
    popl %esp
  102b96:	5c                   	pop    %esp

00102b97 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102b97:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102b98:	0f a9                	pop    %gs
    popl %fs
  102b9a:	0f a1                	pop    %fs
    popl %es
  102b9c:	07                   	pop    %es
    popl %ds
  102b9d:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102b9e:	83 c4 08             	add    $0x8,%esp
    iret
  102ba1:	cf                   	iret   

00102ba2 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102ba2:	55                   	push   %ebp
  102ba3:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba8:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102bab:	b8 23 00 00 00       	mov    $0x23,%eax
  102bb0:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102bb2:	b8 23 00 00 00       	mov    $0x23,%eax
  102bb7:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102bb9:	b8 10 00 00 00       	mov    $0x10,%eax
  102bbe:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102bc0:	b8 10 00 00 00       	mov    $0x10,%eax
  102bc5:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102bc7:	b8 10 00 00 00       	mov    $0x10,%eax
  102bcc:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102bce:	ea d5 2b 10 00 08 00 	ljmp   $0x8,$0x102bd5
}
  102bd5:	90                   	nop
  102bd6:	5d                   	pop    %ebp
  102bd7:	c3                   	ret    

00102bd8 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102bd8:	f3 0f 1e fb          	endbr32 
  102bdc:	55                   	push   %ebp
  102bdd:	89 e5                	mov    %esp,%ebp
  102bdf:	83 ec 10             	sub    $0x10,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102be2:	b8 80 19 11 00       	mov    $0x111980,%eax
  102be7:	05 00 04 00 00       	add    $0x400,%eax
  102bec:	a3 a4 18 11 00       	mov    %eax,0x1118a4
    ts.ts_ss0 = KERNEL_DS;
  102bf1:	66 c7 05 a8 18 11 00 	movw   $0x10,0x1118a8
  102bf8:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102bfa:	66 c7 05 08 0a 11 00 	movw   $0x68,0x110a08
  102c01:	68 00 
  102c03:	b8 a0 18 11 00       	mov    $0x1118a0,%eax
  102c08:	66 a3 0a 0a 11 00    	mov    %ax,0x110a0a
  102c0e:	b8 a0 18 11 00       	mov    $0x1118a0,%eax
  102c13:	c1 e8 10             	shr    $0x10,%eax
  102c16:	a2 0c 0a 11 00       	mov    %al,0x110a0c
  102c1b:	0f b6 05 0d 0a 11 00 	movzbl 0x110a0d,%eax
  102c22:	83 e0 f0             	and    $0xfffffff0,%eax
  102c25:	83 c8 09             	or     $0x9,%eax
  102c28:	a2 0d 0a 11 00       	mov    %al,0x110a0d
  102c2d:	0f b6 05 0d 0a 11 00 	movzbl 0x110a0d,%eax
  102c34:	83 c8 10             	or     $0x10,%eax
  102c37:	a2 0d 0a 11 00       	mov    %al,0x110a0d
  102c3c:	0f b6 05 0d 0a 11 00 	movzbl 0x110a0d,%eax
  102c43:	83 e0 9f             	and    $0xffffff9f,%eax
  102c46:	a2 0d 0a 11 00       	mov    %al,0x110a0d
  102c4b:	0f b6 05 0d 0a 11 00 	movzbl 0x110a0d,%eax
  102c52:	83 c8 80             	or     $0xffffff80,%eax
  102c55:	a2 0d 0a 11 00       	mov    %al,0x110a0d
  102c5a:	0f b6 05 0e 0a 11 00 	movzbl 0x110a0e,%eax
  102c61:	83 e0 f0             	and    $0xfffffff0,%eax
  102c64:	a2 0e 0a 11 00       	mov    %al,0x110a0e
  102c69:	0f b6 05 0e 0a 11 00 	movzbl 0x110a0e,%eax
  102c70:	83 e0 ef             	and    $0xffffffef,%eax
  102c73:	a2 0e 0a 11 00       	mov    %al,0x110a0e
  102c78:	0f b6 05 0e 0a 11 00 	movzbl 0x110a0e,%eax
  102c7f:	83 e0 df             	and    $0xffffffdf,%eax
  102c82:	a2 0e 0a 11 00       	mov    %al,0x110a0e
  102c87:	0f b6 05 0e 0a 11 00 	movzbl 0x110a0e,%eax
  102c8e:	83 c8 40             	or     $0x40,%eax
  102c91:	a2 0e 0a 11 00       	mov    %al,0x110a0e
  102c96:	0f b6 05 0e 0a 11 00 	movzbl 0x110a0e,%eax
  102c9d:	83 e0 7f             	and    $0x7f,%eax
  102ca0:	a2 0e 0a 11 00       	mov    %al,0x110a0e
  102ca5:	b8 a0 18 11 00       	mov    $0x1118a0,%eax
  102caa:	c1 e8 18             	shr    $0x18,%eax
  102cad:	a2 0f 0a 11 00       	mov    %al,0x110a0f
    gdt[SEG_TSS].sd_s = 0;
  102cb2:	0f b6 05 0d 0a 11 00 	movzbl 0x110a0d,%eax
  102cb9:	83 e0 ef             	and    $0xffffffef,%eax
  102cbc:	a2 0d 0a 11 00       	mov    %al,0x110a0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102cc1:	68 10 0a 11 00       	push   $0x110a10
  102cc6:	e8 d7 fe ff ff       	call   102ba2 <lgdt>
  102ccb:	83 c4 04             	add    $0x4,%esp
  102cce:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102cd4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102cd8:	0f 00 d8             	ltr    %ax
}
  102cdb:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102cdc:	90                   	nop
  102cdd:	c9                   	leave  
  102cde:	c3                   	ret    

00102cdf <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102cdf:	f3 0f 1e fb          	endbr32 
  102ce3:	55                   	push   %ebp
  102ce4:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102ce6:	e8 ed fe ff ff       	call   102bd8 <gdt_init>
}
  102ceb:	90                   	nop
  102cec:	5d                   	pop    %ebp
  102ced:	c3                   	ret    

00102cee <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102cee:	f3 0f 1e fb          	endbr32 
  102cf2:	55                   	push   %ebp
  102cf3:	89 e5                	mov    %esp,%ebp
  102cf5:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102cf8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102cff:	eb 04                	jmp    102d05 <strlen+0x17>
        cnt ++;
  102d01:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (*s ++ != '\0') {
  102d05:	8b 45 08             	mov    0x8(%ebp),%eax
  102d08:	8d 50 01             	lea    0x1(%eax),%edx
  102d0b:	89 55 08             	mov    %edx,0x8(%ebp)
  102d0e:	0f b6 00             	movzbl (%eax),%eax
  102d11:	84 c0                	test   %al,%al
  102d13:	75 ec                	jne    102d01 <strlen+0x13>
    }
    return cnt;
  102d15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102d18:	c9                   	leave  
  102d19:	c3                   	ret    

00102d1a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102d1a:	f3 0f 1e fb          	endbr32 
  102d1e:	55                   	push   %ebp
  102d1f:	89 e5                	mov    %esp,%ebp
  102d21:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102d24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102d2b:	eb 04                	jmp    102d31 <strnlen+0x17>
        cnt ++;
  102d2d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102d31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102d34:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102d37:	73 10                	jae    102d49 <strnlen+0x2f>
  102d39:	8b 45 08             	mov    0x8(%ebp),%eax
  102d3c:	8d 50 01             	lea    0x1(%eax),%edx
  102d3f:	89 55 08             	mov    %edx,0x8(%ebp)
  102d42:	0f b6 00             	movzbl (%eax),%eax
  102d45:	84 c0                	test   %al,%al
  102d47:	75 e4                	jne    102d2d <strnlen+0x13>
    }
    return cnt;
  102d49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102d4c:	c9                   	leave  
  102d4d:	c3                   	ret    

00102d4e <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102d4e:	f3 0f 1e fb          	endbr32 
  102d52:	55                   	push   %ebp
  102d53:	89 e5                	mov    %esp,%ebp
  102d55:	57                   	push   %edi
  102d56:	56                   	push   %esi
  102d57:	83 ec 20             	sub    $0x20,%esp
  102d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  102d5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d63:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102d66:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d6c:	89 d1                	mov    %edx,%ecx
  102d6e:	89 c2                	mov    %eax,%edx
  102d70:	89 ce                	mov    %ecx,%esi
  102d72:	89 d7                	mov    %edx,%edi
  102d74:	ac                   	lods   %ds:(%esi),%al
  102d75:	aa                   	stos   %al,%es:(%edi)
  102d76:	84 c0                	test   %al,%al
  102d78:	75 fa                	jne    102d74 <strcpy+0x26>
  102d7a:	89 fa                	mov    %edi,%edx
  102d7c:	89 f1                	mov    %esi,%ecx
  102d7e:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102d81:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102d84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102d8a:	83 c4 20             	add    $0x20,%esp
  102d8d:	5e                   	pop    %esi
  102d8e:	5f                   	pop    %edi
  102d8f:	5d                   	pop    %ebp
  102d90:	c3                   	ret    

00102d91 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102d91:	f3 0f 1e fb          	endbr32 
  102d95:	55                   	push   %ebp
  102d96:	89 e5                	mov    %esp,%ebp
  102d98:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102da1:	eb 21                	jmp    102dc4 <strncpy+0x33>
        if ((*p = *src) != '\0') {
  102da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da6:	0f b6 10             	movzbl (%eax),%edx
  102da9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dac:	88 10                	mov    %dl,(%eax)
  102dae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102db1:	0f b6 00             	movzbl (%eax),%eax
  102db4:	84 c0                	test   %al,%al
  102db6:	74 04                	je     102dbc <strncpy+0x2b>
            src ++;
  102db8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  102dbc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  102dc0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    while (len > 0) {
  102dc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102dc8:	75 d9                	jne    102da3 <strncpy+0x12>
    }
    return dst;
  102dca:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102dcd:	c9                   	leave  
  102dce:	c3                   	ret    

00102dcf <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102dcf:	f3 0f 1e fb          	endbr32 
  102dd3:	55                   	push   %ebp
  102dd4:	89 e5                	mov    %esp,%ebp
  102dd6:	57                   	push   %edi
  102dd7:	56                   	push   %esi
  102dd8:	83 ec 20             	sub    $0x20,%esp
  102ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  102dde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  102de4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102de7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ded:	89 d1                	mov    %edx,%ecx
  102def:	89 c2                	mov    %eax,%edx
  102df1:	89 ce                	mov    %ecx,%esi
  102df3:	89 d7                	mov    %edx,%edi
  102df5:	ac                   	lods   %ds:(%esi),%al
  102df6:	ae                   	scas   %es:(%edi),%al
  102df7:	75 08                	jne    102e01 <strcmp+0x32>
  102df9:	84 c0                	test   %al,%al
  102dfb:	75 f8                	jne    102df5 <strcmp+0x26>
  102dfd:	31 c0                	xor    %eax,%eax
  102dff:	eb 04                	jmp    102e05 <strcmp+0x36>
  102e01:	19 c0                	sbb    %eax,%eax
  102e03:	0c 01                	or     $0x1,%al
  102e05:	89 fa                	mov    %edi,%edx
  102e07:	89 f1                	mov    %esi,%ecx
  102e09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e0c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102e0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102e12:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102e15:	83 c4 20             	add    $0x20,%esp
  102e18:	5e                   	pop    %esi
  102e19:	5f                   	pop    %edi
  102e1a:	5d                   	pop    %ebp
  102e1b:	c3                   	ret    

00102e1c <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102e1c:	f3 0f 1e fb          	endbr32 
  102e20:	55                   	push   %ebp
  102e21:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102e23:	eb 0c                	jmp    102e31 <strncmp+0x15>
        n --, s1 ++, s2 ++;
  102e25:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  102e29:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102e2d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102e35:	74 1a                	je     102e51 <strncmp+0x35>
  102e37:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3a:	0f b6 00             	movzbl (%eax),%eax
  102e3d:	84 c0                	test   %al,%al
  102e3f:	74 10                	je     102e51 <strncmp+0x35>
  102e41:	8b 45 08             	mov    0x8(%ebp),%eax
  102e44:	0f b6 10             	movzbl (%eax),%edx
  102e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e4a:	0f b6 00             	movzbl (%eax),%eax
  102e4d:	38 c2                	cmp    %al,%dl
  102e4f:	74 d4                	je     102e25 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102e51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102e55:	74 18                	je     102e6f <strncmp+0x53>
  102e57:	8b 45 08             	mov    0x8(%ebp),%eax
  102e5a:	0f b6 00             	movzbl (%eax),%eax
  102e5d:	0f b6 d0             	movzbl %al,%edx
  102e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e63:	0f b6 00             	movzbl (%eax),%eax
  102e66:	0f b6 c0             	movzbl %al,%eax
  102e69:	29 c2                	sub    %eax,%edx
  102e6b:	89 d0                	mov    %edx,%eax
  102e6d:	eb 05                	jmp    102e74 <strncmp+0x58>
  102e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102e74:	5d                   	pop    %ebp
  102e75:	c3                   	ret    

00102e76 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102e76:	f3 0f 1e fb          	endbr32 
  102e7a:	55                   	push   %ebp
  102e7b:	89 e5                	mov    %esp,%ebp
  102e7d:	83 ec 04             	sub    $0x4,%esp
  102e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e83:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102e86:	eb 14                	jmp    102e9c <strchr+0x26>
        if (*s == c) {
  102e88:	8b 45 08             	mov    0x8(%ebp),%eax
  102e8b:	0f b6 00             	movzbl (%eax),%eax
  102e8e:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102e91:	75 05                	jne    102e98 <strchr+0x22>
            return (char *)s;
  102e93:	8b 45 08             	mov    0x8(%ebp),%eax
  102e96:	eb 13                	jmp    102eab <strchr+0x35>
        }
        s ++;
  102e98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  102e9f:	0f b6 00             	movzbl (%eax),%eax
  102ea2:	84 c0                	test   %al,%al
  102ea4:	75 e2                	jne    102e88 <strchr+0x12>
    }
    return NULL;
  102ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102eab:	c9                   	leave  
  102eac:	c3                   	ret    

00102ead <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102ead:	f3 0f 1e fb          	endbr32 
  102eb1:	55                   	push   %ebp
  102eb2:	89 e5                	mov    %esp,%ebp
  102eb4:	83 ec 04             	sub    $0x4,%esp
  102eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eba:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102ebd:	eb 0f                	jmp    102ece <strfind+0x21>
        if (*s == c) {
  102ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec2:	0f b6 00             	movzbl (%eax),%eax
  102ec5:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102ec8:	74 10                	je     102eda <strfind+0x2d>
            break;
        }
        s ++;
  102eca:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s != '\0') {
  102ece:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed1:	0f b6 00             	movzbl (%eax),%eax
  102ed4:	84 c0                	test   %al,%al
  102ed6:	75 e7                	jne    102ebf <strfind+0x12>
  102ed8:	eb 01                	jmp    102edb <strfind+0x2e>
            break;
  102eda:	90                   	nop
    }
    return (char *)s;
  102edb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102ede:	c9                   	leave  
  102edf:	c3                   	ret    

00102ee0 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102ee0:	f3 0f 1e fb          	endbr32 
  102ee4:	55                   	push   %ebp
  102ee5:	89 e5                	mov    %esp,%ebp
  102ee7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102eea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102ef1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102ef8:	eb 04                	jmp    102efe <strtol+0x1e>
        s ++;
  102efa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102efe:	8b 45 08             	mov    0x8(%ebp),%eax
  102f01:	0f b6 00             	movzbl (%eax),%eax
  102f04:	3c 20                	cmp    $0x20,%al
  102f06:	74 f2                	je     102efa <strtol+0x1a>
  102f08:	8b 45 08             	mov    0x8(%ebp),%eax
  102f0b:	0f b6 00             	movzbl (%eax),%eax
  102f0e:	3c 09                	cmp    $0x9,%al
  102f10:	74 e8                	je     102efa <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  102f12:	8b 45 08             	mov    0x8(%ebp),%eax
  102f15:	0f b6 00             	movzbl (%eax),%eax
  102f18:	3c 2b                	cmp    $0x2b,%al
  102f1a:	75 06                	jne    102f22 <strtol+0x42>
        s ++;
  102f1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102f20:	eb 15                	jmp    102f37 <strtol+0x57>
    }
    else if (*s == '-') {
  102f22:	8b 45 08             	mov    0x8(%ebp),%eax
  102f25:	0f b6 00             	movzbl (%eax),%eax
  102f28:	3c 2d                	cmp    $0x2d,%al
  102f2a:	75 0b                	jne    102f37 <strtol+0x57>
        s ++, neg = 1;
  102f2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102f30:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102f37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f3b:	74 06                	je     102f43 <strtol+0x63>
  102f3d:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102f41:	75 24                	jne    102f67 <strtol+0x87>
  102f43:	8b 45 08             	mov    0x8(%ebp),%eax
  102f46:	0f b6 00             	movzbl (%eax),%eax
  102f49:	3c 30                	cmp    $0x30,%al
  102f4b:	75 1a                	jne    102f67 <strtol+0x87>
  102f4d:	8b 45 08             	mov    0x8(%ebp),%eax
  102f50:	83 c0 01             	add    $0x1,%eax
  102f53:	0f b6 00             	movzbl (%eax),%eax
  102f56:	3c 78                	cmp    $0x78,%al
  102f58:	75 0d                	jne    102f67 <strtol+0x87>
        s += 2, base = 16;
  102f5a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102f5e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102f65:	eb 2a                	jmp    102f91 <strtol+0xb1>
    }
    else if (base == 0 && s[0] == '0') {
  102f67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f6b:	75 17                	jne    102f84 <strtol+0xa4>
  102f6d:	8b 45 08             	mov    0x8(%ebp),%eax
  102f70:	0f b6 00             	movzbl (%eax),%eax
  102f73:	3c 30                	cmp    $0x30,%al
  102f75:	75 0d                	jne    102f84 <strtol+0xa4>
        s ++, base = 8;
  102f77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  102f7b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102f82:	eb 0d                	jmp    102f91 <strtol+0xb1>
    }
    else if (base == 0) {
  102f84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f88:	75 07                	jne    102f91 <strtol+0xb1>
        base = 10;
  102f8a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102f91:	8b 45 08             	mov    0x8(%ebp),%eax
  102f94:	0f b6 00             	movzbl (%eax),%eax
  102f97:	3c 2f                	cmp    $0x2f,%al
  102f99:	7e 1b                	jle    102fb6 <strtol+0xd6>
  102f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  102f9e:	0f b6 00             	movzbl (%eax),%eax
  102fa1:	3c 39                	cmp    $0x39,%al
  102fa3:	7f 11                	jg     102fb6 <strtol+0xd6>
            dig = *s - '0';
  102fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  102fa8:	0f b6 00             	movzbl (%eax),%eax
  102fab:	0f be c0             	movsbl %al,%eax
  102fae:	83 e8 30             	sub    $0x30,%eax
  102fb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102fb4:	eb 48                	jmp    102ffe <strtol+0x11e>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  102fb9:	0f b6 00             	movzbl (%eax),%eax
  102fbc:	3c 60                	cmp    $0x60,%al
  102fbe:	7e 1b                	jle    102fdb <strtol+0xfb>
  102fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  102fc3:	0f b6 00             	movzbl (%eax),%eax
  102fc6:	3c 7a                	cmp    $0x7a,%al
  102fc8:	7f 11                	jg     102fdb <strtol+0xfb>
            dig = *s - 'a' + 10;
  102fca:	8b 45 08             	mov    0x8(%ebp),%eax
  102fcd:	0f b6 00             	movzbl (%eax),%eax
  102fd0:	0f be c0             	movsbl %al,%eax
  102fd3:	83 e8 57             	sub    $0x57,%eax
  102fd6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102fd9:	eb 23                	jmp    102ffe <strtol+0x11e>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  102fde:	0f b6 00             	movzbl (%eax),%eax
  102fe1:	3c 40                	cmp    $0x40,%al
  102fe3:	7e 3c                	jle    103021 <strtol+0x141>
  102fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  102fe8:	0f b6 00             	movzbl (%eax),%eax
  102feb:	3c 5a                	cmp    $0x5a,%al
  102fed:	7f 32                	jg     103021 <strtol+0x141>
            dig = *s - 'A' + 10;
  102fef:	8b 45 08             	mov    0x8(%ebp),%eax
  102ff2:	0f b6 00             	movzbl (%eax),%eax
  102ff5:	0f be c0             	movsbl %al,%eax
  102ff8:	83 e8 37             	sub    $0x37,%eax
  102ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103001:	3b 45 10             	cmp    0x10(%ebp),%eax
  103004:	7d 1a                	jge    103020 <strtol+0x140>
            break;
        }
        s ++, val = (val * base) + dig;
  103006:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  10300a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10300d:	0f af 45 10          	imul   0x10(%ebp),%eax
  103011:	89 c2                	mov    %eax,%edx
  103013:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103016:	01 d0                	add    %edx,%eax
  103018:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  10301b:	e9 71 ff ff ff       	jmp    102f91 <strtol+0xb1>
            break;
  103020:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  103021:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103025:	74 08                	je     10302f <strtol+0x14f>
        *endptr = (char *) s;
  103027:	8b 45 0c             	mov    0xc(%ebp),%eax
  10302a:	8b 55 08             	mov    0x8(%ebp),%edx
  10302d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10302f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103033:	74 07                	je     10303c <strtol+0x15c>
  103035:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103038:	f7 d8                	neg    %eax
  10303a:	eb 03                	jmp    10303f <strtol+0x15f>
  10303c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10303f:	c9                   	leave  
  103040:	c3                   	ret    

00103041 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103041:	f3 0f 1e fb          	endbr32 
  103045:	55                   	push   %ebp
  103046:	89 e5                	mov    %esp,%ebp
  103048:	57                   	push   %edi
  103049:	83 ec 24             	sub    $0x24,%esp
  10304c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10304f:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103052:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  103056:	8b 55 08             	mov    0x8(%ebp),%edx
  103059:	89 55 f8             	mov    %edx,-0x8(%ebp)
  10305c:	88 45 f7             	mov    %al,-0x9(%ebp)
  10305f:	8b 45 10             	mov    0x10(%ebp),%eax
  103062:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  103065:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  103068:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10306c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10306f:	89 d7                	mov    %edx,%edi
  103071:	f3 aa                	rep stos %al,%es:(%edi)
  103073:	89 fa                	mov    %edi,%edx
  103075:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103078:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  10307b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  10307e:	83 c4 24             	add    $0x24,%esp
  103081:	5f                   	pop    %edi
  103082:	5d                   	pop    %ebp
  103083:	c3                   	ret    

00103084 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  103084:	f3 0f 1e fb          	endbr32 
  103088:	55                   	push   %ebp
  103089:	89 e5                	mov    %esp,%ebp
  10308b:	57                   	push   %edi
  10308c:	56                   	push   %esi
  10308d:	53                   	push   %ebx
  10308e:	83 ec 30             	sub    $0x30,%esp
  103091:	8b 45 08             	mov    0x8(%ebp),%eax
  103094:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103097:	8b 45 0c             	mov    0xc(%ebp),%eax
  10309a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10309d:	8b 45 10             	mov    0x10(%ebp),%eax
  1030a0:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1030a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030a6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1030a9:	73 42                	jae    1030ed <memmove+0x69>
  1030ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1030b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030ba:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1030bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1030c0:	c1 e8 02             	shr    $0x2,%eax
  1030c3:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1030c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1030c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030cb:	89 d7                	mov    %edx,%edi
  1030cd:	89 c6                	mov    %eax,%esi
  1030cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1030d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1030d4:	83 e1 03             	and    $0x3,%ecx
  1030d7:	74 02                	je     1030db <memmove+0x57>
  1030d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1030db:	89 f0                	mov    %esi,%eax
  1030dd:	89 fa                	mov    %edi,%edx
  1030df:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1030e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1030e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  1030e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  1030eb:	eb 36                	jmp    103123 <memmove+0x9f>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1030ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030f0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030f6:	01 c2                	add    %eax,%edx
  1030f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030fb:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1030fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103101:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  103104:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103107:	89 c1                	mov    %eax,%ecx
  103109:	89 d8                	mov    %ebx,%eax
  10310b:	89 d6                	mov    %edx,%esi
  10310d:	89 c7                	mov    %eax,%edi
  10310f:	fd                   	std    
  103110:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103112:	fc                   	cld    
  103113:	89 f8                	mov    %edi,%eax
  103115:	89 f2                	mov    %esi,%edx
  103117:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10311a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  10311d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  103120:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  103123:	83 c4 30             	add    $0x30,%esp
  103126:	5b                   	pop    %ebx
  103127:	5e                   	pop    %esi
  103128:	5f                   	pop    %edi
  103129:	5d                   	pop    %ebp
  10312a:	c3                   	ret    

0010312b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10312b:	f3 0f 1e fb          	endbr32 
  10312f:	55                   	push   %ebp
  103130:	89 e5                	mov    %esp,%ebp
  103132:	57                   	push   %edi
  103133:	56                   	push   %esi
  103134:	83 ec 20             	sub    $0x20,%esp
  103137:	8b 45 08             	mov    0x8(%ebp),%eax
  10313a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10313d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103140:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103143:	8b 45 10             	mov    0x10(%ebp),%eax
  103146:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103149:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10314c:	c1 e8 02             	shr    $0x2,%eax
  10314f:	89 c1                	mov    %eax,%ecx
    asm volatile (
  103151:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103154:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103157:	89 d7                	mov    %edx,%edi
  103159:	89 c6                	mov    %eax,%esi
  10315b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10315d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  103160:	83 e1 03             	and    $0x3,%ecx
  103163:	74 02                	je     103167 <memcpy+0x3c>
  103165:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103167:	89 f0                	mov    %esi,%eax
  103169:	89 fa                	mov    %edi,%edx
  10316b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10316e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  103171:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  103174:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  103177:	83 c4 20             	add    $0x20,%esp
  10317a:	5e                   	pop    %esi
  10317b:	5f                   	pop    %edi
  10317c:	5d                   	pop    %ebp
  10317d:	c3                   	ret    

0010317e <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10317e:	f3 0f 1e fb          	endbr32 
  103182:	55                   	push   %ebp
  103183:	89 e5                	mov    %esp,%ebp
  103185:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  103188:	8b 45 08             	mov    0x8(%ebp),%eax
  10318b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  10318e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103191:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  103194:	eb 30                	jmp    1031c6 <memcmp+0x48>
        if (*s1 != *s2) {
  103196:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103199:	0f b6 10             	movzbl (%eax),%edx
  10319c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10319f:	0f b6 00             	movzbl (%eax),%eax
  1031a2:	38 c2                	cmp    %al,%dl
  1031a4:	74 18                	je     1031be <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1031a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031a9:	0f b6 00             	movzbl (%eax),%eax
  1031ac:	0f b6 d0             	movzbl %al,%edx
  1031af:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1031b2:	0f b6 00             	movzbl (%eax),%eax
  1031b5:	0f b6 c0             	movzbl %al,%eax
  1031b8:	29 c2                	sub    %eax,%edx
  1031ba:	89 d0                	mov    %edx,%eax
  1031bc:	eb 1a                	jmp    1031d8 <memcmp+0x5a>
        }
        s1 ++, s2 ++;
  1031be:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1031c2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
    while (n -- > 0) {
  1031c6:	8b 45 10             	mov    0x10(%ebp),%eax
  1031c9:	8d 50 ff             	lea    -0x1(%eax),%edx
  1031cc:	89 55 10             	mov    %edx,0x10(%ebp)
  1031cf:	85 c0                	test   %eax,%eax
  1031d1:	75 c3                	jne    103196 <memcmp+0x18>
    }
    return 0;
  1031d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1031d8:	c9                   	leave  
  1031d9:	c3                   	ret    

001031da <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1031da:	f3 0f 1e fb          	endbr32 
  1031de:	55                   	push   %ebp
  1031df:	89 e5                	mov    %esp,%ebp
  1031e1:	83 ec 38             	sub    $0x38,%esp
  1031e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1031e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1031ea:	8b 45 14             	mov    0x14(%ebp),%eax
  1031ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1031f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1031f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1031f9:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1031fc:	8b 45 18             	mov    0x18(%ebp),%eax
  1031ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103202:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103205:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103208:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10320b:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10320e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103211:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103214:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103218:	74 1c                	je     103236 <printnum+0x5c>
  10321a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10321d:	ba 00 00 00 00       	mov    $0x0,%edx
  103222:	f7 75 e4             	divl   -0x1c(%ebp)
  103225:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10322b:	ba 00 00 00 00       	mov    $0x0,%edx
  103230:	f7 75 e4             	divl   -0x1c(%ebp)
  103233:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103236:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103239:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10323c:	f7 75 e4             	divl   -0x1c(%ebp)
  10323f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103242:	89 55 dc             	mov    %edx,-0x24(%ebp)
  103245:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103248:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10324b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10324e:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103251:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103254:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  103257:	8b 45 18             	mov    0x18(%ebp),%eax
  10325a:	ba 00 00 00 00       	mov    $0x0,%edx
  10325f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  103262:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  103265:	19 d1                	sbb    %edx,%ecx
  103267:	72 37                	jb     1032a0 <printnum+0xc6>
        printnum(putch, putdat, result, base, width - 1, padc);
  103269:	8b 45 1c             	mov    0x1c(%ebp),%eax
  10326c:	83 e8 01             	sub    $0x1,%eax
  10326f:	83 ec 04             	sub    $0x4,%esp
  103272:	ff 75 20             	pushl  0x20(%ebp)
  103275:	50                   	push   %eax
  103276:	ff 75 18             	pushl  0x18(%ebp)
  103279:	ff 75 ec             	pushl  -0x14(%ebp)
  10327c:	ff 75 e8             	pushl  -0x18(%ebp)
  10327f:	ff 75 0c             	pushl  0xc(%ebp)
  103282:	ff 75 08             	pushl  0x8(%ebp)
  103285:	e8 50 ff ff ff       	call   1031da <printnum>
  10328a:	83 c4 20             	add    $0x20,%esp
  10328d:	eb 1b                	jmp    1032aa <printnum+0xd0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  10328f:	83 ec 08             	sub    $0x8,%esp
  103292:	ff 75 0c             	pushl  0xc(%ebp)
  103295:	ff 75 20             	pushl  0x20(%ebp)
  103298:	8b 45 08             	mov    0x8(%ebp),%eax
  10329b:	ff d0                	call   *%eax
  10329d:	83 c4 10             	add    $0x10,%esp
        while (-- width > 0)
  1032a0:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  1032a4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1032a8:	7f e5                	jg     10328f <printnum+0xb5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1032aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1032ad:	05 b0 3f 10 00       	add    $0x103fb0,%eax
  1032b2:	0f b6 00             	movzbl (%eax),%eax
  1032b5:	0f be c0             	movsbl %al,%eax
  1032b8:	83 ec 08             	sub    $0x8,%esp
  1032bb:	ff 75 0c             	pushl  0xc(%ebp)
  1032be:	50                   	push   %eax
  1032bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1032c2:	ff d0                	call   *%eax
  1032c4:	83 c4 10             	add    $0x10,%esp
}
  1032c7:	90                   	nop
  1032c8:	c9                   	leave  
  1032c9:	c3                   	ret    

001032ca <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1032ca:	f3 0f 1e fb          	endbr32 
  1032ce:	55                   	push   %ebp
  1032cf:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1032d1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1032d5:	7e 14                	jle    1032eb <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  1032d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1032da:	8b 00                	mov    (%eax),%eax
  1032dc:	8d 48 08             	lea    0x8(%eax),%ecx
  1032df:	8b 55 08             	mov    0x8(%ebp),%edx
  1032e2:	89 0a                	mov    %ecx,(%edx)
  1032e4:	8b 50 04             	mov    0x4(%eax),%edx
  1032e7:	8b 00                	mov    (%eax),%eax
  1032e9:	eb 30                	jmp    10331b <getuint+0x51>
    }
    else if (lflag) {
  1032eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1032ef:	74 16                	je     103307 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  1032f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f4:	8b 00                	mov    (%eax),%eax
  1032f6:	8d 48 04             	lea    0x4(%eax),%ecx
  1032f9:	8b 55 08             	mov    0x8(%ebp),%edx
  1032fc:	89 0a                	mov    %ecx,(%edx)
  1032fe:	8b 00                	mov    (%eax),%eax
  103300:	ba 00 00 00 00       	mov    $0x0,%edx
  103305:	eb 14                	jmp    10331b <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  103307:	8b 45 08             	mov    0x8(%ebp),%eax
  10330a:	8b 00                	mov    (%eax),%eax
  10330c:	8d 48 04             	lea    0x4(%eax),%ecx
  10330f:	8b 55 08             	mov    0x8(%ebp),%edx
  103312:	89 0a                	mov    %ecx,(%edx)
  103314:	8b 00                	mov    (%eax),%eax
  103316:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10331b:	5d                   	pop    %ebp
  10331c:	c3                   	ret    

0010331d <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10331d:	f3 0f 1e fb          	endbr32 
  103321:	55                   	push   %ebp
  103322:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103324:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103328:	7e 14                	jle    10333e <getint+0x21>
        return va_arg(*ap, long long);
  10332a:	8b 45 08             	mov    0x8(%ebp),%eax
  10332d:	8b 00                	mov    (%eax),%eax
  10332f:	8d 48 08             	lea    0x8(%eax),%ecx
  103332:	8b 55 08             	mov    0x8(%ebp),%edx
  103335:	89 0a                	mov    %ecx,(%edx)
  103337:	8b 50 04             	mov    0x4(%eax),%edx
  10333a:	8b 00                	mov    (%eax),%eax
  10333c:	eb 28                	jmp    103366 <getint+0x49>
    }
    else if (lflag) {
  10333e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103342:	74 12                	je     103356 <getint+0x39>
        return va_arg(*ap, long);
  103344:	8b 45 08             	mov    0x8(%ebp),%eax
  103347:	8b 00                	mov    (%eax),%eax
  103349:	8d 48 04             	lea    0x4(%eax),%ecx
  10334c:	8b 55 08             	mov    0x8(%ebp),%edx
  10334f:	89 0a                	mov    %ecx,(%edx)
  103351:	8b 00                	mov    (%eax),%eax
  103353:	99                   	cltd   
  103354:	eb 10                	jmp    103366 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  103356:	8b 45 08             	mov    0x8(%ebp),%eax
  103359:	8b 00                	mov    (%eax),%eax
  10335b:	8d 48 04             	lea    0x4(%eax),%ecx
  10335e:	8b 55 08             	mov    0x8(%ebp),%edx
  103361:	89 0a                	mov    %ecx,(%edx)
  103363:	8b 00                	mov    (%eax),%eax
  103365:	99                   	cltd   
    }
}
  103366:	5d                   	pop    %ebp
  103367:	c3                   	ret    

00103368 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  103368:	f3 0f 1e fb          	endbr32 
  10336c:	55                   	push   %ebp
  10336d:	89 e5                	mov    %esp,%ebp
  10336f:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
  103372:	8d 45 14             	lea    0x14(%ebp),%eax
  103375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  103378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10337b:	50                   	push   %eax
  10337c:	ff 75 10             	pushl  0x10(%ebp)
  10337f:	ff 75 0c             	pushl  0xc(%ebp)
  103382:	ff 75 08             	pushl  0x8(%ebp)
  103385:	e8 06 00 00 00       	call   103390 <vprintfmt>
  10338a:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
  10338d:	90                   	nop
  10338e:	c9                   	leave  
  10338f:	c3                   	ret    

00103390 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  103390:	f3 0f 1e fb          	endbr32 
  103394:	55                   	push   %ebp
  103395:	89 e5                	mov    %esp,%ebp
  103397:	56                   	push   %esi
  103398:	53                   	push   %ebx
  103399:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  10339c:	eb 17                	jmp    1033b5 <vprintfmt+0x25>
            if (ch == '\0') {
  10339e:	85 db                	test   %ebx,%ebx
  1033a0:	0f 84 8f 03 00 00    	je     103735 <vprintfmt+0x3a5>
                return;
            }
            putch(ch, putdat);
  1033a6:	83 ec 08             	sub    $0x8,%esp
  1033a9:	ff 75 0c             	pushl  0xc(%ebp)
  1033ac:	53                   	push   %ebx
  1033ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b0:	ff d0                	call   *%eax
  1033b2:	83 c4 10             	add    $0x10,%esp
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1033b5:	8b 45 10             	mov    0x10(%ebp),%eax
  1033b8:	8d 50 01             	lea    0x1(%eax),%edx
  1033bb:	89 55 10             	mov    %edx,0x10(%ebp)
  1033be:	0f b6 00             	movzbl (%eax),%eax
  1033c1:	0f b6 d8             	movzbl %al,%ebx
  1033c4:	83 fb 25             	cmp    $0x25,%ebx
  1033c7:	75 d5                	jne    10339e <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1033c9:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1033cd:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1033d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1033d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1033da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1033e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1033e4:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1033e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1033ea:	8d 50 01             	lea    0x1(%eax),%edx
  1033ed:	89 55 10             	mov    %edx,0x10(%ebp)
  1033f0:	0f b6 00             	movzbl (%eax),%eax
  1033f3:	0f b6 d8             	movzbl %al,%ebx
  1033f6:	8d 43 dd             	lea    -0x23(%ebx),%eax
  1033f9:	83 f8 55             	cmp    $0x55,%eax
  1033fc:	0f 87 06 03 00 00    	ja     103708 <vprintfmt+0x378>
  103402:	8b 04 85 d4 3f 10 00 	mov    0x103fd4(,%eax,4),%eax
  103409:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10340c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103410:	eb d5                	jmp    1033e7 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103412:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  103416:	eb cf                	jmp    1033e7 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103418:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10341f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103422:	89 d0                	mov    %edx,%eax
  103424:	c1 e0 02             	shl    $0x2,%eax
  103427:	01 d0                	add    %edx,%eax
  103429:	01 c0                	add    %eax,%eax
  10342b:	01 d8                	add    %ebx,%eax
  10342d:	83 e8 30             	sub    $0x30,%eax
  103430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103433:	8b 45 10             	mov    0x10(%ebp),%eax
  103436:	0f b6 00             	movzbl (%eax),%eax
  103439:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10343c:	83 fb 2f             	cmp    $0x2f,%ebx
  10343f:	7e 39                	jle    10347a <vprintfmt+0xea>
  103441:	83 fb 39             	cmp    $0x39,%ebx
  103444:	7f 34                	jg     10347a <vprintfmt+0xea>
            for (precision = 0; ; ++ fmt) {
  103446:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
  10344a:	eb d3                	jmp    10341f <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  10344c:	8b 45 14             	mov    0x14(%ebp),%eax
  10344f:	8d 50 04             	lea    0x4(%eax),%edx
  103452:	89 55 14             	mov    %edx,0x14(%ebp)
  103455:	8b 00                	mov    (%eax),%eax
  103457:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  10345a:	eb 1f                	jmp    10347b <vprintfmt+0xeb>

        case '.':
            if (width < 0)
  10345c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103460:	79 85                	jns    1033e7 <vprintfmt+0x57>
                width = 0;
  103462:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  103469:	e9 79 ff ff ff       	jmp    1033e7 <vprintfmt+0x57>

        case '#':
            altflag = 1;
  10346e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  103475:	e9 6d ff ff ff       	jmp    1033e7 <vprintfmt+0x57>
            goto process_precision;
  10347a:	90                   	nop

        process_precision:
            if (width < 0)
  10347b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10347f:	0f 89 62 ff ff ff    	jns    1033e7 <vprintfmt+0x57>
                width = precision, precision = -1;
  103485:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103488:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10348b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  103492:	e9 50 ff ff ff       	jmp    1033e7 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  103497:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  10349b:	e9 47 ff ff ff       	jmp    1033e7 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1034a0:	8b 45 14             	mov    0x14(%ebp),%eax
  1034a3:	8d 50 04             	lea    0x4(%eax),%edx
  1034a6:	89 55 14             	mov    %edx,0x14(%ebp)
  1034a9:	8b 00                	mov    (%eax),%eax
  1034ab:	83 ec 08             	sub    $0x8,%esp
  1034ae:	ff 75 0c             	pushl  0xc(%ebp)
  1034b1:	50                   	push   %eax
  1034b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1034b5:	ff d0                	call   *%eax
  1034b7:	83 c4 10             	add    $0x10,%esp
            break;
  1034ba:	e9 71 02 00 00       	jmp    103730 <vprintfmt+0x3a0>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1034bf:	8b 45 14             	mov    0x14(%ebp),%eax
  1034c2:	8d 50 04             	lea    0x4(%eax),%edx
  1034c5:	89 55 14             	mov    %edx,0x14(%ebp)
  1034c8:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1034ca:	85 db                	test   %ebx,%ebx
  1034cc:	79 02                	jns    1034d0 <vprintfmt+0x140>
                err = -err;
  1034ce:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1034d0:	83 fb 06             	cmp    $0x6,%ebx
  1034d3:	7f 0b                	jg     1034e0 <vprintfmt+0x150>
  1034d5:	8b 34 9d 94 3f 10 00 	mov    0x103f94(,%ebx,4),%esi
  1034dc:	85 f6                	test   %esi,%esi
  1034de:	75 19                	jne    1034f9 <vprintfmt+0x169>
                printfmt(putch, putdat, "error %d", err);
  1034e0:	53                   	push   %ebx
  1034e1:	68 c1 3f 10 00       	push   $0x103fc1
  1034e6:	ff 75 0c             	pushl  0xc(%ebp)
  1034e9:	ff 75 08             	pushl  0x8(%ebp)
  1034ec:	e8 77 fe ff ff       	call   103368 <printfmt>
  1034f1:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  1034f4:	e9 37 02 00 00       	jmp    103730 <vprintfmt+0x3a0>
                printfmt(putch, putdat, "%s", p);
  1034f9:	56                   	push   %esi
  1034fa:	68 ca 3f 10 00       	push   $0x103fca
  1034ff:	ff 75 0c             	pushl  0xc(%ebp)
  103502:	ff 75 08             	pushl  0x8(%ebp)
  103505:	e8 5e fe ff ff       	call   103368 <printfmt>
  10350a:	83 c4 10             	add    $0x10,%esp
            break;
  10350d:	e9 1e 02 00 00       	jmp    103730 <vprintfmt+0x3a0>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103512:	8b 45 14             	mov    0x14(%ebp),%eax
  103515:	8d 50 04             	lea    0x4(%eax),%edx
  103518:	89 55 14             	mov    %edx,0x14(%ebp)
  10351b:	8b 30                	mov    (%eax),%esi
  10351d:	85 f6                	test   %esi,%esi
  10351f:	75 05                	jne    103526 <vprintfmt+0x196>
                p = "(null)";
  103521:	be cd 3f 10 00       	mov    $0x103fcd,%esi
            }
            if (width > 0 && padc != '-') {
  103526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10352a:	7e 76                	jle    1035a2 <vprintfmt+0x212>
  10352c:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103530:	74 70                	je     1035a2 <vprintfmt+0x212>
                for (width -= strnlen(p, precision); width > 0; width --) {
  103532:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103535:	83 ec 08             	sub    $0x8,%esp
  103538:	50                   	push   %eax
  103539:	56                   	push   %esi
  10353a:	e8 db f7 ff ff       	call   102d1a <strnlen>
  10353f:	83 c4 10             	add    $0x10,%esp
  103542:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103545:	29 c2                	sub    %eax,%edx
  103547:	89 d0                	mov    %edx,%eax
  103549:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10354c:	eb 17                	jmp    103565 <vprintfmt+0x1d5>
                    putch(padc, putdat);
  10354e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  103552:	83 ec 08             	sub    $0x8,%esp
  103555:	ff 75 0c             	pushl  0xc(%ebp)
  103558:	50                   	push   %eax
  103559:	8b 45 08             	mov    0x8(%ebp),%eax
  10355c:	ff d0                	call   *%eax
  10355e:	83 c4 10             	add    $0x10,%esp
                for (width -= strnlen(p, precision); width > 0; width --) {
  103561:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  103565:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103569:	7f e3                	jg     10354e <vprintfmt+0x1be>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10356b:	eb 35                	jmp    1035a2 <vprintfmt+0x212>
                if (altflag && (ch < ' ' || ch > '~')) {
  10356d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103571:	74 1c                	je     10358f <vprintfmt+0x1ff>
  103573:	83 fb 1f             	cmp    $0x1f,%ebx
  103576:	7e 05                	jle    10357d <vprintfmt+0x1ed>
  103578:	83 fb 7e             	cmp    $0x7e,%ebx
  10357b:	7e 12                	jle    10358f <vprintfmt+0x1ff>
                    putch('?', putdat);
  10357d:	83 ec 08             	sub    $0x8,%esp
  103580:	ff 75 0c             	pushl  0xc(%ebp)
  103583:	6a 3f                	push   $0x3f
  103585:	8b 45 08             	mov    0x8(%ebp),%eax
  103588:	ff d0                	call   *%eax
  10358a:	83 c4 10             	add    $0x10,%esp
  10358d:	eb 0f                	jmp    10359e <vprintfmt+0x20e>
                }
                else {
                    putch(ch, putdat);
  10358f:	83 ec 08             	sub    $0x8,%esp
  103592:	ff 75 0c             	pushl  0xc(%ebp)
  103595:	53                   	push   %ebx
  103596:	8b 45 08             	mov    0x8(%ebp),%eax
  103599:	ff d0                	call   *%eax
  10359b:	83 c4 10             	add    $0x10,%esp
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  10359e:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1035a2:	89 f0                	mov    %esi,%eax
  1035a4:	8d 70 01             	lea    0x1(%eax),%esi
  1035a7:	0f b6 00             	movzbl (%eax),%eax
  1035aa:	0f be d8             	movsbl %al,%ebx
  1035ad:	85 db                	test   %ebx,%ebx
  1035af:	74 26                	je     1035d7 <vprintfmt+0x247>
  1035b1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1035b5:	78 b6                	js     10356d <vprintfmt+0x1dd>
  1035b7:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  1035bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1035bf:	79 ac                	jns    10356d <vprintfmt+0x1dd>
                }
            }
            for (; width > 0; width --) {
  1035c1:	eb 14                	jmp    1035d7 <vprintfmt+0x247>
                putch(' ', putdat);
  1035c3:	83 ec 08             	sub    $0x8,%esp
  1035c6:	ff 75 0c             	pushl  0xc(%ebp)
  1035c9:	6a 20                	push   $0x20
  1035cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ce:	ff d0                	call   *%eax
  1035d0:	83 c4 10             	add    $0x10,%esp
            for (; width > 0; width --) {
  1035d3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  1035d7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1035db:	7f e6                	jg     1035c3 <vprintfmt+0x233>
            }
            break;
  1035dd:	e9 4e 01 00 00       	jmp    103730 <vprintfmt+0x3a0>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  1035e2:	83 ec 08             	sub    $0x8,%esp
  1035e5:	ff 75 e0             	pushl  -0x20(%ebp)
  1035e8:	8d 45 14             	lea    0x14(%ebp),%eax
  1035eb:	50                   	push   %eax
  1035ec:	e8 2c fd ff ff       	call   10331d <getint>
  1035f1:	83 c4 10             	add    $0x10,%esp
  1035f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1035f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  1035fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1035fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103600:	85 d2                	test   %edx,%edx
  103602:	79 23                	jns    103627 <vprintfmt+0x297>
                putch('-', putdat);
  103604:	83 ec 08             	sub    $0x8,%esp
  103607:	ff 75 0c             	pushl  0xc(%ebp)
  10360a:	6a 2d                	push   $0x2d
  10360c:	8b 45 08             	mov    0x8(%ebp),%eax
  10360f:	ff d0                	call   *%eax
  103611:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
  103614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10361a:	f7 d8                	neg    %eax
  10361c:	83 d2 00             	adc    $0x0,%edx
  10361f:	f7 da                	neg    %edx
  103621:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103624:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  103627:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10362e:	e9 9f 00 00 00       	jmp    1036d2 <vprintfmt+0x342>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  103633:	83 ec 08             	sub    $0x8,%esp
  103636:	ff 75 e0             	pushl  -0x20(%ebp)
  103639:	8d 45 14             	lea    0x14(%ebp),%eax
  10363c:	50                   	push   %eax
  10363d:	e8 88 fc ff ff       	call   1032ca <getuint>
  103642:	83 c4 10             	add    $0x10,%esp
  103645:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103648:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10364b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103652:	eb 7e                	jmp    1036d2 <vprintfmt+0x342>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  103654:	83 ec 08             	sub    $0x8,%esp
  103657:	ff 75 e0             	pushl  -0x20(%ebp)
  10365a:	8d 45 14             	lea    0x14(%ebp),%eax
  10365d:	50                   	push   %eax
  10365e:	e8 67 fc ff ff       	call   1032ca <getuint>
  103663:	83 c4 10             	add    $0x10,%esp
  103666:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103669:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  10366c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  103673:	eb 5d                	jmp    1036d2 <vprintfmt+0x342>

        // pointer
        case 'p':
            putch('0', putdat);
  103675:	83 ec 08             	sub    $0x8,%esp
  103678:	ff 75 0c             	pushl  0xc(%ebp)
  10367b:	6a 30                	push   $0x30
  10367d:	8b 45 08             	mov    0x8(%ebp),%eax
  103680:	ff d0                	call   *%eax
  103682:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
  103685:	83 ec 08             	sub    $0x8,%esp
  103688:	ff 75 0c             	pushl  0xc(%ebp)
  10368b:	6a 78                	push   $0x78
  10368d:	8b 45 08             	mov    0x8(%ebp),%eax
  103690:	ff d0                	call   *%eax
  103692:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103695:	8b 45 14             	mov    0x14(%ebp),%eax
  103698:	8d 50 04             	lea    0x4(%eax),%edx
  10369b:	89 55 14             	mov    %edx,0x14(%ebp)
  10369e:	8b 00                	mov    (%eax),%eax
  1036a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  1036aa:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  1036b1:	eb 1f                	jmp    1036d2 <vprintfmt+0x342>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  1036b3:	83 ec 08             	sub    $0x8,%esp
  1036b6:	ff 75 e0             	pushl  -0x20(%ebp)
  1036b9:	8d 45 14             	lea    0x14(%ebp),%eax
  1036bc:	50                   	push   %eax
  1036bd:	e8 08 fc ff ff       	call   1032ca <getuint>
  1036c2:	83 c4 10             	add    $0x10,%esp
  1036c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  1036cb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  1036d2:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1036d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036d9:	83 ec 04             	sub    $0x4,%esp
  1036dc:	52                   	push   %edx
  1036dd:	ff 75 e8             	pushl  -0x18(%ebp)
  1036e0:	50                   	push   %eax
  1036e1:	ff 75 f4             	pushl  -0xc(%ebp)
  1036e4:	ff 75 f0             	pushl  -0x10(%ebp)
  1036e7:	ff 75 0c             	pushl  0xc(%ebp)
  1036ea:	ff 75 08             	pushl  0x8(%ebp)
  1036ed:	e8 e8 fa ff ff       	call   1031da <printnum>
  1036f2:	83 c4 20             	add    $0x20,%esp
            break;
  1036f5:	eb 39                	jmp    103730 <vprintfmt+0x3a0>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1036f7:	83 ec 08             	sub    $0x8,%esp
  1036fa:	ff 75 0c             	pushl  0xc(%ebp)
  1036fd:	53                   	push   %ebx
  1036fe:	8b 45 08             	mov    0x8(%ebp),%eax
  103701:	ff d0                	call   *%eax
  103703:	83 c4 10             	add    $0x10,%esp
            break;
  103706:	eb 28                	jmp    103730 <vprintfmt+0x3a0>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  103708:	83 ec 08             	sub    $0x8,%esp
  10370b:	ff 75 0c             	pushl  0xc(%ebp)
  10370e:	6a 25                	push   $0x25
  103710:	8b 45 08             	mov    0x8(%ebp),%eax
  103713:	ff d0                	call   *%eax
  103715:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
  103718:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10371c:	eb 04                	jmp    103722 <vprintfmt+0x392>
  10371e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103722:	8b 45 10             	mov    0x10(%ebp),%eax
  103725:	83 e8 01             	sub    $0x1,%eax
  103728:	0f b6 00             	movzbl (%eax),%eax
  10372b:	3c 25                	cmp    $0x25,%al
  10372d:	75 ef                	jne    10371e <vprintfmt+0x38e>
                /* do nothing */;
            break;
  10372f:	90                   	nop
    while (1) {
  103730:	e9 67 fc ff ff       	jmp    10339c <vprintfmt+0xc>
                return;
  103735:	90                   	nop
        }
    }
}
  103736:	8d 65 f8             	lea    -0x8(%ebp),%esp
  103739:	5b                   	pop    %ebx
  10373a:	5e                   	pop    %esi
  10373b:	5d                   	pop    %ebp
  10373c:	c3                   	ret    

0010373d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10373d:	f3 0f 1e fb          	endbr32 
  103741:	55                   	push   %ebp
  103742:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103744:	8b 45 0c             	mov    0xc(%ebp),%eax
  103747:	8b 40 08             	mov    0x8(%eax),%eax
  10374a:	8d 50 01             	lea    0x1(%eax),%edx
  10374d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103750:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  103753:	8b 45 0c             	mov    0xc(%ebp),%eax
  103756:	8b 10                	mov    (%eax),%edx
  103758:	8b 45 0c             	mov    0xc(%ebp),%eax
  10375b:	8b 40 04             	mov    0x4(%eax),%eax
  10375e:	39 c2                	cmp    %eax,%edx
  103760:	73 12                	jae    103774 <sprintputch+0x37>
        *b->buf ++ = ch;
  103762:	8b 45 0c             	mov    0xc(%ebp),%eax
  103765:	8b 00                	mov    (%eax),%eax
  103767:	8d 48 01             	lea    0x1(%eax),%ecx
  10376a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10376d:	89 0a                	mov    %ecx,(%edx)
  10376f:	8b 55 08             	mov    0x8(%ebp),%edx
  103772:	88 10                	mov    %dl,(%eax)
    }
}
  103774:	90                   	nop
  103775:	5d                   	pop    %ebp
  103776:	c3                   	ret    

00103777 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103777:	f3 0f 1e fb          	endbr32 
  10377b:	55                   	push   %ebp
  10377c:	89 e5                	mov    %esp,%ebp
  10377e:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  103781:	8d 45 14             	lea    0x14(%ebp),%eax
  103784:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10378a:	50                   	push   %eax
  10378b:	ff 75 10             	pushl  0x10(%ebp)
  10378e:	ff 75 0c             	pushl  0xc(%ebp)
  103791:	ff 75 08             	pushl  0x8(%ebp)
  103794:	e8 0b 00 00 00       	call   1037a4 <vsnprintf>
  103799:	83 c4 10             	add    $0x10,%esp
  10379c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10379f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1037a2:	c9                   	leave  
  1037a3:	c3                   	ret    

001037a4 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  1037a4:	f3 0f 1e fb          	endbr32 
  1037a8:	55                   	push   %ebp
  1037a9:	89 e5                	mov    %esp,%ebp
  1037ab:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  1037ae:	8b 45 08             	mov    0x8(%ebp),%eax
  1037b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1037b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037b7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1037ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1037bd:	01 d0                	add    %edx,%eax
  1037bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1037c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1037c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1037cd:	74 0a                	je     1037d9 <vsnprintf+0x35>
  1037cf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1037d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1037d5:	39 c2                	cmp    %eax,%edx
  1037d7:	76 07                	jbe    1037e0 <vsnprintf+0x3c>
        return -E_INVAL;
  1037d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1037de:	eb 20                	jmp    103800 <vsnprintf+0x5c>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1037e0:	ff 75 14             	pushl  0x14(%ebp)
  1037e3:	ff 75 10             	pushl  0x10(%ebp)
  1037e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1037e9:	50                   	push   %eax
  1037ea:	68 3d 37 10 00       	push   $0x10373d
  1037ef:	e8 9c fb ff ff       	call   103390 <vprintfmt>
  1037f4:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
  1037f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037fa:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1037fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103800:	c9                   	leave  
  103801:	c3                   	ret    
