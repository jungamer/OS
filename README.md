# 操作系统
- [1 Bochs环境安装]
    - [制作虚拟软盘]
- [2 实模式下打印HelloWorld](#2)
- [3 从实模式到保护模式](/chapter2/real2protect.md)

<h2 name="2">2 实模式下打印HelloWorld</h2>  

(1)实现汇编代码 [HelloWorld.asm](/chapter1/HelloWorld.asm);     
(2)汇编代码编译成机器码:      

```bash
nasm HelloWorld.asm -o HelloWorld.bin  
```
(3)制作虚拟软盘a.img;    
(4)把机器码HelloWorld.bin写到软盘a.img;  

```bash
dd if=HelloWorld.bin of=a.img bs=512 count=1 conv=notrunc
```
(5)bochs虚拟机启动时, bios加载软盘a.img前512字节到内存0:7c00处并执行;  

```bash
bochs -f ./bochsrc
```
(6)运行结果  
![运行结果](/res/HelloWorld.png)

<h2 name="3">3 从实模式到保护模式</h2>  
