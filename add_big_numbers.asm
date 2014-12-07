masm
model   small
stack   256
.data
b   db  3, 1 ; unpacked number 13
c   db  0, 8, 6   ; unpacked number 680
max_digits equ 3 ; number of digits of the bigger number
sum db 8 dup (0)
res_len equ 8 ; the number of digits for the output
.code
main:   
    mov ax,@data
    mov ds,ax

    ; initialize registers to zero
    xor ax,ax
    xor dx, dx
    xor si, si
    mov cx, max_digits

; add each digit from b to each digit for c
; keeping in mind the carry values
m1:
    mov al, b[si]
    adc al, c[si]
    aaa ; addition correction

    mov sum[si], al ; save result in sum
    inc si
    loop m1
    adc sum[si], 0 ; acknowledge last carry value

; prepare for print loop
    mov cx, res_len
print:
    mov si, cx
    dec si

    mov ah, 02h
    mov dl, sum[si]
    add dl, 30h
    int 21h

    loop print

exit:
    mov ax,4c00h
    int 21h
end main