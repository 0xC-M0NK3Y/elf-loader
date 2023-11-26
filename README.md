# elf-loader
Assembly written simple elf loader

## Overview

It's an x86_64 linux assembly written loader,  
that can load **statically linked, position independant executable**, elf.  
does not handle elf that use an interpreter  
(https://www.cs.cmu.edu/afs/cs/academic/class/15213-f00/docs/elf.pdf x86 elf in documentation, but basically the same)  

It take an elf, does a very minimalistic parsing,  
maps it into memory (without adequate memory protections, all is RWX),  
does relocations if needed (see comments in code when relocating in load_elf),  
then arrange the base stack frame and the auxiliary vectors,  
(https://articles.manugarg.com/aboutelfauxiliaryvectors only documentation I found about)  
then starts it on jumping at his entrypoint.  

## Test

```c
  #include <stdio.h>

  int main()
  {
    printf("Bonjour\n");
    return 0;
  }
```
```sh
  $ gcc -static-pie main.c -o test
  $ ./loader test
```
