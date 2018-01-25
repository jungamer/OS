# 操作系统
- Bochs环境安装
    - [制作虚拟软盘]
- [实模式下打印HelloWorld](实模式下打印HelloWorld)

## 实模式下打印HelloWorld
实现汇编代码;    
[HelloWorld.asm](/chapter1/HelloWorld.asm)  
汇编代码编译成机器码;      
nasm HelloWorld.asm -o HelloWorld.bin  
制作虚拟软盘a.img;    
把机器码HelloWorld.bin写到软盘a.img;  

```bash
dd if=HelloWorld.bin of=a.img bs=512 count=1 conv=notrunc
```
bochs虚拟机启动时, bios加载软盘a.img前512字节到内存0:7c00处并执行;  

```bash
bochs -f ./bochsrc
```
运行结果  
![运行结果](/res/HelloWorld.png)

