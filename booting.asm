;
; A Simple boot sector program that loops forever
;

org 0x7c00                      ; we'll put this code in this address memory

MAGIC_NUMBER equ 0xaa55         ; The magic number that tells the BIOS
                                ; that this is the bootloader

main:
    mov eax, 0xcafecafe     ; putting some reference to 'cafe' into EAX
    jmp $                   ; endless loop to this same instruction


times 510-($-$$) db 0   ; our bootloader must be 512 bytes
                        ; 510 bytes with 0's and the 'MAGIC_NUMBER' after
dw MAGIC_NUMBER         ; we place the magic number in the bytes 511 and 512


