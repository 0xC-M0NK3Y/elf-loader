bits 64

%include "src/defines.s"
%include "src/macros.s"

SECTION .data
	err1: db "Usage ./loader <elf>", 0xA, 0
	err1_len equ $ - err1
	err2: db "Error opening elf", 0xA, 0
	err2_len equ $ - err2
	err3: db "Error loading elf", 0xA, 0
	err3_len equ $ - err3

SECTION .text

extern open_file
extern load_elf

global _start

_start:
	mov rdi, rsp
	mov rsi, [rdi]
	cmp rsi, 2
	jne _exit_err1
	add rdi, 0x10
	mov rdi, [rdi]
	call open_file
	cmp rax, 0
	je _exit_err2

	mov rdi, rax
	mov rsi, rsp
	call load_elf
	cmp rax, 0
	jl _exit_err3

_exit:
	mov rdi, 0
	mov rax, SYS_EXIT
	syscall

_exit_err1:
	write 1, err1, err1_len
	jmp _exit
_exit_err2:
	write 1, err2, err2_len
	jmp _exit
_exit_err3:
	write 1, err3, err3_len
	jmp _exit
