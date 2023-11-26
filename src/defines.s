bits 64

; syscalls

%define SYS_READ	0x0
%define SYS_WRITE	0x1
%define SYS_OPEN	0x2
%define SYS_CLOSE	0x3
%define SYS_LSEEK	0x8
%define SYS_MMAP	0x9
%define SYS_MUNMAP	0xb
%define SYS_EXIT	0x3c

; for mmap

%define PROT_READ	0x1
%define PROT_WRITE	0x2
%define PROT_EXEC	0x4

%define MAP_PRIVATE		0x2
%define MAP_ANONYMOUS	0x20

; for open

%define O_RDONLY 0x0

; for lseek

%define SEEK_SET 0x0
%define SEEK_END 0x2

; for elf

%define ELF_MAGICK	0x464C457F

%define ET_EXEC	0x2
%define ET_DYN	0x3

%define SHF_ALLOC	0x2

%define SHT_RELA	0x4
%define SHT_NOBITS	0x8
%define SHT_REL		0x9

%define R_X86_64_RELATIVE 0x8
%define R_X86_64_IRELATIV 0x25

; for auxiliary vectors
; /usr/include/linux/auxvec.h and asm/auxvec.h

%define AT_NULL         0               ;/* End of vector */
%define AT_IGNORE       1               ;/* Entry should be ignored */
%define AT_EXECFD       2               ;/* File descriptor of program */
%define AT_PHDR         3               ;/* Program headers for program */
%define AT_PHENT        4               ;/* Size of program header entry */
%define AT_PHNUM        5               ;/* Number of program headers */
%define AT_PAGESZ       6               ;/* System page size */
%define AT_BASE         7               ;/* Base address of interpreter */
%define AT_FLAGS        8               ;/* Flags */
%define AT_ENTRY        9               ;/* Entry point of program */
%define AT_NOTELF       10              ;/* Program is not ELF */
%define AT_UID          11              ;/* Real uid */
%define AT_EUID         12              ;/* Effective uid */
%define AT_GID          13              ;/* Real gid */
%define AT_EGID         14              ;/* Effective gid */
%define AT_CLKTCK       17              ;/* Frequency of times() */
%define AT_SYSINFO      32
%define AT_SYSINFO_EHDR 33
