bits 64

;typedef struct {
;    uint32_t    ei_magic;
;    uint8_t     ei_class;
;    uint8_t     ei_data;
;    uint8_t     ei_version;
;    uint8_t     ei_osabi;
;    uint8_t     ei_abiversion;
;    uint8_t     ei_pad[7];
;    uint16_t    e_type;
;    uint16_t    e_machine;
;    uint32_t    e_version;
;    elf_addr_t  e_entry;
;    elf_off_t   e_phoff;
;    elf_off_t   e_shoff;
;    uint32_t    e_flags;
;    uint16_t    e_ehsize;
;    uint16_t    e_phentsize;
;    uint16_t    e_phnum;
;    uint16_t    e_shentsize;
;    uint16_t    e_shnum;
;    uint16_t    e_shstrndx;
;} __attribute__((__packed__)) elf_hdr_t;

struc elf_header
	.ei_magic		resd 1
    .ei_class		resb 1
    .ei_data		resb 1
    .ei_version		resb 1
    .ei_osabi		resb 1
    .ei_abiversion	resb 1
    .ei_pad	 		resb 7
    .e_type 		resw 1
    .e_machine 		resw 1
    .e_version 		resd 1
    .e_entry 		resq 1
    .e_phoff 		resq 1
    .e_shoff 		resq 1
    .e_flags 		resd 1
    .e_ehsize 		resw 1
    .e_phentsize 	resw 1
    .e_phnum 		resw 1
    .e_shentsize 	resw 1
    .e_shnum 		resw 1
	.e_shstrndx 	resw 1
endstruc

;typedef struct {
;    uint32_t    sh_name;
;    uint32_t    sh_type;
;    elf_size_t  sh_flags;
;    elf_addr_t  sh_addr;
;    elf_off_t   sh_offset;
;    elf_addr_t  sh_size;
;    uint32_t    sh_link;
;    uint32_t    sh_info;
;    elf_size_t  sh_addralign;
;    elf_size_t  sh_entsize;
;} __attribute__((__packed__)) elf_shdr_t;

struc elf_section_header
    .sh_name		resd 1
    .sh_type		resd 1
    .sh_flags		resq 1
    .sh_addr		resq 1
    .sh_offset		resq 1
    .sh_size		resq 1
    .sh_link		resd 1
    .sh_info		resd 1
    .sh_addralign	resq 1
	.sh_entsize		resq 1
endstruc


;typedef struct {
;    elf_addr_t          r_offset;
;    elf_uint_bitdep_t   r_info;
;} elf_rel_t;

struc elf_rel
	.r_offset	resq 1
	.r_info		resq 1
endstruc

;typedef struct {
;    elf_addr_t          r_offset;
;    elf_uint_bitdep_t   r_info;
;    elf_int_bitdep_t    r_addend;
;} elf_rela_t;

struc elf_rela
	.r_offset	resq 1
	.r_info		resq 1
	.r_addend	resq 1
endstruc
