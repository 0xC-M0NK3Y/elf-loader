bits 64

%include "src/defines.s"
%include "src/macros.s"
%include "src/elf.s"

SECTION .text

extern _memcpy

global load_elf

; int load_elf(uint8_t *buff, stack_pointer);

load_elf:
	push rbp
	mov rbp, rsp
	sub rsp, 0x40

	mov QWORD [rbp - 0x28], rsi  ; stack_pointer
	mov QWORD [rbp - 0x8], rdi   ; elf buffer

	; mini elf parsing
	cmp rdi, 0
	je fail_load_elf
	cmp DWORD [rdi], ELF_MAGICK
	jne fail_load_elf
	cmp BYTE [rdi + elf_header.ei_class], 2 ; check 64bits
	jne fail_load_elf
	cmp WORD [rdi + elf_header.e_type], ET_DYN
	jne fail_load_elf

	mov rdi, QWORD [rbp - 0x8]
	mov rax, QWORD [rdi + elf_header.e_entry]
	mov QWORD [rbp - 0x20], rax ; pointer to entrypoint

	call get_elf_size
	mov QWORD [rbp - 0x10], rax ; size_of_image

	mmap_exec rax
	cmp rax, 0
	je fail_load_elf
	mov QWORD [rbp - 0x18], rax ; image_base

	; mmap initialize memory to 0, useless but I don't trust the kernel
	memset_zero QWORD [rbp - 0x18], QWORD [rbp - 0x10]

	; map the elf file
	mov rdi, QWORD [rbp - 0x8]
	mov rsi, QWORD [rbp - 0x18]
	call map_elf

	; relocate if needed
	; from what I saw, its done in the libc startup
	; for elf compiled with -nostartfiles or -nostdlib
	; you'll need to make the relocation
	;mov rdi, QWORD [rbp - 0x8]
	;mov rsi, QWORD [rbp - 0x18]
	;call relocate_elf
	;cmp rax, 0
	;jl fail_free_load_elf

	; get pointeur to auxiliary vectors in the initial stack frame
	mov rdi, QWORD [rbp - 0x28]
	call get_aux_pointeur
	mov QWORD [rbp - 0x30], rax ; pointer to aux

	mov rcx, QWORD [rbp - 0x8]
	mov rbx, QWORD [rcx + elf_header.e_phoff]
	add rcx, rbx
	set_aux_val QWORD [rbp - 0x30], AT_PHDR, rcx

	mov rcx, QWORD [rbp - 0x8]
	xor rbx, rbx
	mov bx, WORD [rcx + elf_header.e_phentsize]
	set_aux_val QWORD [rbp - 0x30], AT_PHENT, rbx

	mov rcx, QWORD [rbp - 0x8]
	xor rbx, rbx
	mov bx, WORD [rcx + elf_header.e_phnum]
	set_aux_val QWORD [rbp - 0x30], AT_PHNUM, rbx

	; AT_PAGESZ already set, not changing
	; AT_BASE interpreter already to 0
	; AT_FLAGS already at 0

	mov rcx, QWORD [rbp - 0x18]
	add rcx, QWORD [rbp - 0x20]
	set_aux_val QWORD [rbp - 0x30], AT_ENTRY, rcx

	; AT_NOTELF i'm not sure for this one, don't change

	; AT_UID don't change
	; AT_EUID don't change
	; AT_GID don't change
	; AT_EGID don't change

	; AT_CLKTCK not sure for this one, don't change

	; AT_SYSINFO don't touch
	; AT_SYSINFO_EHDR don't touch

	mov r15, QWORD [rbp - 0x18]
	add r15, QWORD [rbp - 0x20]
	mov rsp, QWORD [rbp - 0x28]
	xor rbp, rbp
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9
	xor r10, r10
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor rdi, rdi
	xor rsi, rsi
	jmp r15

	xor eax, eax
	mov rsp, rbp
	pop rbp
	ret

fail_free_load_elf:
	munmap QWORD [rbp - 0x18], QWORD [rbp - 0x10]
fail_load_elf:
	mov rax, -1
	mov rsp, rbp
	pop rbp
	ret

; rdi = elf buffer, return SizeOfImage
get_elf_size:
	xor r15, r15
	mov r15w, WORD [rdi + elf_header.e_shnum]
	mov r14, QWORD [rdi + elf_header.e_shoff]
	xor r13, r13
	mov r13w, WORD [rdi + elf_header.e_shentsize]
	xor rax, rax
	xor rcx, rcx
	jmp get_elf_size_for
get_elf_size_loop:
	mov r8, rcx
	imul r8, r13
	add r8, rdi
	add r8, r14
	test QWORD [r8 + elf_section_header.sh_flags], SHF_ALLOC
	je get_elf_size_continue
	mov r9, QWORD [r8 + elf_section_header.sh_addr]
	add r9, QWORD [r8 + elf_section_header.sh_size]
	cmp r9, rax
	jb get_elf_size_continue
	mov rax, r9
get_elf_size_continue:
	inc rcx
get_elf_size_for:
	cmp rcx, r15
	jb get_elf_size_loop
	ret


; rdi elf buffer, rsi elf pointeur
map_elf:
	mov rbx, rdi
	mov r8, rdi
	mov r9, rsi

	mov rdi, r9
	mov rsi, rbx
	xor rdx, rdx
	mov dx, WORD [rbx + elf_header.e_ehsize]
	call _memcpy

	xor r14, r14
	mov r14w, WORD [rbx + elf_header.e_shnum]
	xor r13, r13
	mov r13w, WORD [rbx + elf_header.e_shentsize]
	mov r15, QWORD [rbx + elf_header.e_shoff]
	add rbx, r15

	xor rcx, rcx
	jmp map_elf_for
map_elf_loop:
	mov r12, rcx
	imul r12, r13
	add r12, rbx
	test QWORD [r12 + elf_section_header.sh_flags], SHF_ALLOC
	je map_elf_pass
	cmp DWORD [r12 + elf_section_header.sh_type], SHT_NOBITS
	je map_elf_pass
	mov r10, [r12 + elf_section_header.sh_addr]
	mov rdi, r9
	add rdi, r10
	mov r10, [r12 + elf_section_header.sh_offset]
	mov rsi, r8
	add rsi, r10
	mov r10, [r12 + elf_section_header.sh_size]
	mov rdx, r10
	call _memcpy
map_elf_pass:
	inc rcx
map_elf_for:
	cmp rcx, r14
	jb map_elf_loop
	ret



; rdi elf buffer, rsi elf pointer
relocate_elf:
	push rbp
	mov rbp, rsp
	sub rsp, 0x20

	mov [rbp - 0x8], rdi
	mov [rbp - 0x10], rsi
	xor r14, r14
	mov r14w, WORD [rdi + elf_header.e_shnum]
	xor r13, r13
	mov r13w, WORD [rdi + elf_header.e_shentsize]
	mov r15, QWORD [rdi + elf_header.e_shoff]
	mov rbx, [rbp - 0x8]
	add rbx, r15
	mov [rbp - 0x18], rbx
	xor rcx, rcx
	inc rcx
	jmp relocate_elf_for
relocate_elf_loop:
	mov r12, rcx
	imul r12, r13
	add r12, QWORD [rbp - 0x18]
	cmp DWORD [r12 + elf_section_header.sh_type], SHT_REL
	je relocate_rel
	cmp DWORD [r12 + elf_section_header.sh_type], SHT_RELA
	je relocate_rela
	;jmp fail_relocate_elf
	jmp next_reloc
relocate_rel:
	mov r8, QWORD [r12 + elf_section_header.sh_entsize]
	mov r9, QWORD [r12 + elf_section_header.sh_size]
	mov r11, QWORD [r12 + elf_section_header.sh_link]
	mov rax, r9
	div r8
	mov r9, rax
	xor r10, r10
	jmp next_reloc
relocate_rel_loop:
	mov rdi, r10
	mov rsi, r8
	imul rdi, rsi
	add rdi, r11
	add rdi, [rbp - 0x8]
	mov rdx, [rdi + elf_rel.r_info]
	;and rdx, 0xffffffff
	cmp edx, R_X86_64_RELATIVE
	jne fail_relocate_elf
	mov rsi, QWORD [rbp - 0x10]
	add rsi, QWORD [rdi + elf_rel.r_offset]
	mov rdi, QWORD [rbp - 0x10]
	add QWORD [rsi], rdi
	inc r10
relocate_rel_for:
	cmp r10, r9
	jb relocate_rel_loop
	jmp next_reloc
relocate_rela:
	mov r8, QWORD [r12 + elf_section_header.sh_entsize]
	mov r9, QWORD [r12 + elf_section_header.sh_size]
	mov r11, QWORD [r12 + elf_section_header.sh_offset]
	mov rax, r9
	cdq
	div r8
	mov r9, rax
	xor r10, r10
	jmp relocate_rela_for
relocate_rela_loop:
	mov rdi, r10
	mov rsi, r8
	imul rdi, rsi
	add rdi, r11
	add rdi, [rbp - 0x8]
	mov rdx, [rdi + elf_rela.r_info]
	;and rdx, 0xffffffff
	cmp edx, R_X86_64_RELATIVE
	je relocate_rela_l
	cmp edx, R_X86_64_IRELATIV
	je relocate_rela_l
	jmp next_relocate_rela
relocate_rela_l:
	mov rsi, QWORD [rbp - 0x10]
	add rsi, QWORD [rdi + elf_rela.r_offset]
	mov r15, QWORD [rbp - 0x10]
	mov [rsi], r15
	mov r15, QWORD [rdi + elf_rela.r_addend]
	add [rsi], r15
next_relocate_rela:
	inc r10
relocate_rela_for:
	cmp r10, r9
	jb relocate_rela_loop
	jmp next_reloc
next_reloc:
	inc rcx
relocate_elf_for:
	cmp rcx, r14
	jb relocate_elf_loop
	xor rax, rax
	mov rsp, rbp
	pop rbp
	ret
fail_relocate_elf:
	mov rax, -1
	mov rsp, rbp
	pop rbp
	ret

; rdi pointer to auxiliary vectors, rsi vector type, rdx value to set
set_aux_value:
	mov r15, QWORD [rdi]
	cmp r15, 0
	je set_aux_value_end
	cmp rsi, r15
	je set_aux_value_and_end
	add rdi, 0x10
	jmp set_aux_value
set_aux_value_and_end:
	mov QWORD [rdi + 8], rdx
set_aux_value_end:
	ret

; rdi pointeur to stack, passing argv, and env searching auxiliry vectors
get_aux_pointeur:
	mov r15, QWORD [rdi]
	add rdi, 0x8
	imul r15, 0x8
	add rdi, r15
get_aux_pointer_for:
	add rdi, 0x8
	mov r15, QWORD [rdi]
	cmp r15, 0
	jne get_aux_pointer_for
	add rdi, 0x8
	mov rax, rdi
	ret
