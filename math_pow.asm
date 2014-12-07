; prints the value of base to the power of exp
; base and exp must be single digits
masm
model small
stack 256
.data
base db 6
exp db 2
.code    
main:
    ; loading data segment
    mov ax,@data
    mov ds,ax

    ; cleaning registers and initializing ax to 1
    ; since we are going to multiply it by 'base' 'exp' times
    xor cx, cx
    mov ax, 01h
    mov cl, exp
loop1: 
    ; multiplying al by base and repeat exp times
    mul base
    aam
    loop loop1
print:
    ; copying value of ax to bx
    mov bx, ax

    ; printing the most significant BCD digit
    ; in this case, it prints the digit '3'
    mov ah, 02h
    mov dl, bh
    add dl, 30h
    int 21h

    ; printing the least significant BCD digit
    ; in this case, it prints the digit '6', thus printing '36'
    mov dl, bl
    add dl, 30h
    int 21h
exit:
    mov ax,4c00h    
    int 21h
end main        