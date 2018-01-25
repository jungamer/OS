## 3 从实模式到保护模式  
[代码](/chapter2/real2protect.asm)  

```assembly

%include	"pm.inc"	; 常量, 宏, 以及一些说明
org 07c00h
    jmp LABEL_BEGIN

[SECTION .gdt]
; GDT
;                              段基址,       段界限     , 属性
LABEL_GDT:	   Descriptor       0,                0, 0           ; 空描述符
LABEL_DESC_CODE32: Descriptor       0, SegCode32Len - 1, DA_C + DA_32; 非一致代码段
LABEL_DESC_VIDEO:  Descriptor 0B8000h,           0ffffh, DA_DRW	     ; 显存首地址
; GDT 结束

GdtLen		equ	$ - LABEL_GDT	; GDT长度
GdtPtr		dw	GdtLen - 1	; GDT界限 用GdtLen-1初始化前四个字节表示GDT的界限
		dd	0		; GDT基地址 GdtPtr的后面两个字节表示Gdt的基地址，先初始化为0

; GDT 选择子
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0100h

    ; 初始化 GDT中 32 位代码段描述符
    xor eax, eax ; 清零
    mov ax, cs   ; ax指向代码段
    shl eax, 4   ; 左移4位
    add eax, LABEL_SEG_CODE32 ; eax 中实地址为 cs*16+LABEL_SEG_CODE32,
                              ; 也就是LABEL_SEG_CODE32实际的物理地址。
    mov word [LABEL_DESC_CODE32 + 2], ax ; 下面四行用代码段的实际物理地址初始化gdt中对应的描述符
    shr eax, 16
    mov byte [LABEL_DESC_CODE32 + 4], al
    mov byte [LABEL_DESC_CODE32 + 7], ah

    ; 为加载 GDTR 作准备
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_GDT          ; eax 中实地址为 cs*16+LABEL_GDT
    mov dword [GdtPtr + 2], eax ; gdt段的基地址存入GdtPtr+2地址中

    ; 加载 GDTR
    lgdt    [GdtPtr]

    ; 关中断
    cli

    ; 打开地址线A20
    in  al, 92h
    or  al, 00000010b
    out 92h, al

    ; 准备切换到保护模式
    mov eax, cr0
    or  eax, 1
    mov cr0, eax ; cr0第一位置为1，让cpu运行在保护模式

    ; 真正进入保护模式
    jmp dword SelectorCode32:0  ; 执行这一句会把 SelectorCode32 装入 cs,
                    ; 并跳转到 Code32Selector:0  处
; END of [SECTION .s16]

[SECTION .s32]; 32 位代码段. 由实模式跳入.
[BITS   32]

LABEL_SEG_CODE32:
    mov ax, SelectorVideo
    mov gs, ax          ; 视频段选择子(目的)

    mov edi, (80 * 11 + 79) * 2 ; 屏幕第 11 行, 第 79 列。
    mov ah, 0Ch         ; 0000: 黑底    1100: 红字
    mov al, 'P'
    mov [gs:edi], ax

    ; 到此停止
    jmp $
SegCode32Len    equ $ - LABEL_SEG_CODE32
; END of [SECTION .s32]
```
