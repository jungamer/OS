## 4 C与汇编相互调用

[foo.asm](/chapter5/foo.asm)

```assembly
extern choose	; int choose(int a, int b); 声明外部函数

[section .data]	; 数据段

num1st		dd	3
num2nd		dd	4

[section .text]	; 代码段

global _start	; 导出 _start 这个入口，以便让链接器识别。
global myprint	; 导出这个函数为了让 bar.c 使用

_start:
	push	dword [num2nd]	; 调用参数压入堆栈
	push	dword [num1st]	; 调用参数压入堆栈
	call	choose		;  | choose(num1st, num2nd); 返回地址压入堆栈
	add	esp, 8		; 参数都出栈

	mov	ebx, 0
	mov	eax, 1		; sys_exit
	int	0x80		; 系统调用

; void myprint(char* msg, int len)
myprint:
	mov	edx, [esp + 8]	; len
	mov	ecx, [esp + 4]	; msg
	mov	ebx, 1
	mov	eax, 4		; sys_write
	int	0x80		; 系统调用
	ret

```

[bar.c](/chapter5/bar.c)

```c
void myprint(char* msg, int len);

int choose(int a, int b)
{
	if(a >= b){
		myprint("the 1st one\n", 13);
	}
	else{
		myprint("the 2nd one\n", 13);
	}

	return 0;
}
```

由bar.c生成汇编代码bar.s
```bash
gcc -fno-asynchronous-unwind-tables -S -m32 -o bar.s bar.c
```
[bar.s](/chapter5/bar.s)

```assembly
	.file	"bar.c"
	.section	.rodata
.LC0:
	.string	"the 1st one\n"
.LC1:
	.string	"the 2nd one\n"
	.text
	.globl	choose
	.type	choose, @function
choose:
	pushl	%ebp            ;之前的ebp入栈保存, esp=esp+4
	movl	%esp, %ebp      ;ebp保存当前堆栈指针, 当前函数堆栈上的数据基于ebp来操作
	subl	$8, %esp       
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	jl	.L2
	subl	$8, %esp
	pushl	$13
	pushl	$.LC0
	call	myprint
	addl	$16, %esp
	jmp	.L3
.L2:
	subl	$8, %esp
	pushl	$13
	pushl	$.LC1
	call	myprint
	addl	$16, %esp
.L3:
	movl	$0, %eax
	leave
	ret
	.size	choose, .-choose
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.5) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits

```

```bash
#把foo.asm编译成elf格式文件
nasm -f elf -o foo.o foo.asm 
#编译bar.c -m32 -m elf_i386 为了编译以及链接都是32位
gcc -m32 -c -o bar.o bar.c
#链接 
ld -m elf_i386 -s -o foobar foo.o bar.o
./foobar
#执行结果 
the 2nd one
```
