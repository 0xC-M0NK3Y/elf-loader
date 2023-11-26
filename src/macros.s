bits 64

%include "src/defines.s"

%macro mmap 1
	xor rdi, rdi
	mov rsi, %1
	mov edx, PROT_READ | PROT_WRITE
	mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
	xor r8, r8
	xor r9, r9
	mov rax, SYS_MMAP
	syscall
%endmacro

%macro mmap_exec 1
	;xor rdi, rdi
	mov rdi, 0x40000
	mov rsi, %1
	mov edx, PROT_READ | PROT_WRITE | PROT_EXEC
	mov r10d, MAP_PRIVATE | MAP_ANONYMOUS
	xor r8, r8
	xor r9, r9
	mov rax, SYS_MMAP
	syscall
%endmacro

%macro munmap 2
	mov rdi, %1
	mov rsi, %2
	mov rax, SYS_MUNMAP
	syscall
%endmacro

%macro read 3
	mov edi, %1
	mov rsi, %2
	mov rdx, %3
	mov rax, SYS_READ
	syscall
%endmacro

%macro write 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	mov rax, SYS_WRITE
	syscall
%endmacro

%macro memset_zero 2
	xor rcx, rcx
	mov rdi, %1
	mov rsi, %2
	jmp memset_zero_for
memset_zero_loop:
	mov [rdi + rcx], BYTE 0
	inc rcx
memset_zero_for:
	cmp rcx, rsi
	jb memset_zero_loop
%endmacro

%macro set_aux_val 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	call set_aux_value
%endmacro
