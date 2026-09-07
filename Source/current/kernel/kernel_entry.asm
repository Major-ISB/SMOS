;; kernel_entry.asm => kernel.c loader

bits 32		;nasm directive
section .text
	;multiboot spec
	align 4
	dd 0x1BADB002			;magic
	dd 0x00				;flags
	dd - (0x1BADB002 + 0x00)	;checksum. m+f+c should be zero

global _start
extern kmain	;kmain is defined in the kernel.c file

_start:
	cli  ; stop interrupts
	call k_main
	hlt ; halt the CPU

%include "libs/asmlib.asm"
