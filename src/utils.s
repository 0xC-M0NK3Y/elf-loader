bits 64

%include "src/defines.s"
%include "src/macros.s"

SECTION .text

global open_file
global _memcpy

;uint8_t *open_file(char *s);
open_file:
	push rbp
	mov rbp, rsp
	sub rsp, 0x20
	mov rsi, O_RDONLY
	xor rdx, rdx
	mov rax, SYS_OPEN
	syscall
	cmp eax, 0
	jl fail_open_file
	mov DWORD [rbp - 0x4], eax
	mov edi, eax
	xor rsi, rsi
	mov edx, SEEK_END
	mov rax, SYS_LSEEK
	syscall
	cmp rax, 0
	jl fail_close_open_file
	mov QWORD [rbp - 0xC], rax
	mmap QWORD [rbp - 0xC]
	cmp rax, 0
	jl fail_close_open_file
	mov QWORD [rbp - 0x14], rax
	mov edi, DWORD [rbp - 0x4]
	xor rsi, rsi
	mov edx, SEEK_SET
	mov rax, SYS_LSEEK
	syscall
	cmp rax, 0
	jl fail_free_close_open_file
	read DWORD [rbp - 0x4], QWORD [rbp - 0x14], QWORD [rbp - 0xC]
	cmp rax, 0
	jl fail_free_close_open_file
	mov edi, DWORD [rbp - 0x14]
	mov rax, SYS_CLOSE
	syscall

	mov rax, QWORD [rbp - 0x14]
	mov rsp, rbp
	pop rbp
	ret
fail_free_close_open_file:
	munmap QWORD [rbp - 0x14], QWORD [rbp - 0xC]
fail_close_open_file:
	mov edi, DWORD [rbp - 0x4]
	mov rax, SYS_CLOSE
	syscall
fail_open_file:
	xor rax, rax
	mov rsp, rbp
	pop rbp
	ret


; void *_memcpy(void *dst, void *src, size_t s);
_memcpy:
	push rcx
	push r8
	xor rcx, rcx
	jmp _memcpy_for
_memcpy_loop:
	mov r8b, BYTE [rsi + rcx]
	mov BYTE [rdi + rcx], r8b
	inc rcx
_memcpy_for:
	cmp rcx, rdx
	jb _memcpy_loop
	mov rax, rdi
	pop r8
	pop rcx
	ret






