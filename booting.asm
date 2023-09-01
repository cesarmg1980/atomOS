;
; A Simple boot sector program that loops forever
;

org 0x7c00                      ; we'll put this code in this address memory

MAGIC_NUMBER equ 0xaa55         ; The magic number that tells the BIOS
                                ; that this is the bootloader

main:
    mov ah, 0x0e            ; 0x0e Teletype
    mov al, 'H'             ; we put the char 'H' in al
    int 0x10                ; int 0x10, video irq
    mov al, 'e'             
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'l'
    int 0x10
    mov al, 'o'
    int 0x10
    jmp $                   ; endless loop to this same instruction


times 510-($-$$) db 0   ; our bootloader must be 512 bytes
                        ; 510 bytes with 0's and the 'MAGIC_NUMBER' after
dw MAGIC_NUMBER         ; we place the magic number in the bytes 511 and 512


