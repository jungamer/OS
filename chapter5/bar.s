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
	pushl	%ebp
	movl	%esp, %ebp
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
