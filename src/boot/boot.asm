; Copyright (C) 2014  Arjun Sreedharan
; License: GPL version 2 or higher http://www.gnu.org/licenses/gpl.html

bits 32
section .text
        ;multiboot spec
        align 4
        dd 0x1BADB002              ;magic
        dd 0x00                    ;flags
        dd - (0x1BADB002 + 0x00)   ;checksum. m+f+c should be zero

global start
global keyboard_handler
global read_port
global write_port
global load_idt
global shutdown

extern boot 		;this is defined in the c file
extern keyboard_handler_main
extern clear_screen

read_port:
    mov edx, [esp + 4]
            ;al is the lower 8 bits of eax
    in al, dx	;dx is the lower 16 bits of edx
    ret

write_port:
    mov   edx, [esp + 4]    
    mov   al, [esp + 4 + 4]  
    out   dx, al  
    ret

load_idt:
    mov edx, [esp + 4]
    lidt [edx]
    sti 				;turn on interrupts
    ret

keyboard_handler:                 
    call    keyboard_handler_main
    iretd

start:
    cli 				;block interrupts
    mov esp, stack_space
    call boot
    hlt 				;halt the CPU

shutdown:
    cli 				;block interrupts
    call clear_screen
    
    ; Perform a software reset to shut down the system
    mov ax, 0xFFFF
    mov dx, 0x0040
    out dx, ax
    mov dx, 0x0060
    out dx, ax
    hlt 				;halt the CPU

section .bss
resb 8192; 8KB for stack
stack_space: