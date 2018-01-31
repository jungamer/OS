##ring0特权级转移到ring3特权级

retf指令可以从高特权级转低特权级
核心代码部分:
```assembly
LABEL_SEG_CODE32:
	mov	ax, SelectorData
	mov	ds, ax			; 数据段选择子
	mov	ax, SelectorVideo
	mov	gs, ax			; 视频段选择子

	mov	ax, SelectorStack
	mov	ss, ax			; 堆栈段选择子

	mov	esp, TopOfStack

	; Load TSS
	mov	ax, SelectorTSS
	ltr	ax	; tss 里保存了ring0的堆栈 TopOfStack, SelectorStack

	push	SelectorStack3
	push	TopOfStack3
	push	SelectorCodeRing3
	push	0
	retf		; Ring0 -> Ring3 将打印数字 '4'。 ring3执行，ring3有自己的堆栈SelectorStack3 TopOfStack3

```

```assembly
; TSS ---------------------------------------------------------------------------------------------
[SECTION .tss]
ALIGN	32
[BITS	32]
LABEL_TSS:
		DD	0			; Back
		DD	TopOfStack		; 0 级堆栈
		DD	SelectorStack		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	0			; CR3
		DD	0			; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	0			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	0			; CS
		DD	0			; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	0			; LDT
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen		equ	$ - LABEL_TSS
```
运行结果
![运行结果](/res/ring02ring3.png)
