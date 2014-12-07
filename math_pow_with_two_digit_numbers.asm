masm
model   small
stack   256
.data
b   db  7,2 ; the unpacked number 27
len equ 2 ; number of digits in the number
mult1  db  4 dup (0)
mult2  db  4 dup (0)
res db 4 dup (0)
.code
main:   
    mov ax, @data
    mov ds, ax

    ; initialize registers to zeroes
    xor ax, ax
    xor bx, bx
    xor dx, dx
    xor si, si
    mov cx, len  ; cx now has the number of digits of the base

; multiply the least significant digit of the base by the base
; and save the number in BCD format in mult1
m1:
    mov al,b[si]
    mul b[0]
    aam     ; multiplication correction
    adc al,dl   ; acknowledge carry
    aaa ; addition correction
    mov dl,ah   ; remember carry value
    mov mult1[si],al

    inc si
    loop m1
    mov mult1[si],dl   ; acknowledge last carry value

; prepare for m2 loop
    xor si, si
    xor dx, dx
    mov cx, len

; multiply the most significant digit of the base by the base
; and save the number in BCD format in mult2
m2:
    mov al,b[si]
    mul b[1]
    aam     ; multiplication correction
    adc al,dl   ; acknowledge carry value
    aaa ; addition correction
    mov dl,ah   ; remember carry value
    mov mult2[si],al

    inc si
    loop m2
    mov mult2[si],dl   ; acknowledge last carry value

    mov cx, 4
    xor si, si

    ; keep in mind that the BCD number, described by
    ; mult2, must be shifted once to the left and then
    ; add it to mult1; that's why we add mult1's first digit to res
    mov al, mult1[0]
    mov res[0], al

; prepare for adding loop
    xor si, si
    mov cx, 4
    dec cx

; add mult1 and mult2 together, forming the final result
adding:
    
    mov bx, si
    inc bx

    mov al, mult1[bx]
    adc al, mult2[si]
    aaa ; addition correction

    mov res[bx], al

    inc si
    loop adding
    adc res[si], 0

    mov cx, 4

; loop through and print every digit in reverse order
print:
    mov si, cx
    dec si
    mov dl, res[si]
    mov ah, 02h
    add dl, 30h ; convert to ASCII digit character
    int 21h
    loop print

exit:
    mov ax,4c00h
    int 21h
end main