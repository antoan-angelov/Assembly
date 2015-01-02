; This program checks whether a user entered word exists in a text file.
; It is case insensitive. Text file must be less than 256 bytes and entered word can be at most 10 characters.
masm
model medium
.386
.stack  256
.data
myword db 10 dup (0) ; word is max 10 characters long
word_max equ $-myword
filename db "file.txt", 0
point_fname dd filename
buffer db 255 dup(?)
buffer_size equ $-buffer
enter_word_message db 'Enter word to search: $'
success_message db 'Word was successfully found.$'
fail_message db 'Word was not found.$'
point_read  dd buffer
handle dw 0
word_len dw 0
bytes_read db 0
start_pos dw 0
match_count db 0
.code
main:
    mov ax,@data
    mov ds,ax
    
    ; opening file
    lds dx, point_fname    
    xor ax, ax
    xor cx, cx
    mov ah,3Dh    
    int 21h
    mov handle, ax
    
    ; exit if file not found
    jc exit

; show enter word message
input:
    mov ah, 09h
    mov dx, offset enter_word_message
    int 21h
    mov cx, word_max
    xor si, si

; enter characters until enter was pressed
loop_input:
    
    ; get entered byte
    mov ah, 01h
    int 21h
    
    ; stop reading if enter key was pressed
    cmp al, 0Dh
    je read_chunk
    
    ; check if ASCII code >= 65 ('A')
    cmp al, 65
    jge check_less1
    jmp checked1
    
    ; if it is, then check if ASCII code <= 90 ('Z')
check_less1:
    cmp al, 90
    jle make_lowercase1
    jmp checked1

    ; if ASCII code is between 'A' and 'Z', add 32 to make it lowercase
make_lowercase1:
    add al, 32
    
checked1:
    ; otherwise, save read byte to myword
    mov myword[si], al 
    ; increment counter
    inc si
    ; save current read word length
    mov word_len, si
    
    ; repeat 10 times at most
    loop loop_input 
    
    ; if word exceeds 10 characters, automatically print \r\n
    mov ah, 02h
    mov dl, 13
    mov cx, 0
    mov bl, 0
    int 21h
      
    mov ah, 02h
    mov dl, 10
    mov cx, 0
    mov bl, 0
    int 21h
     
read_chunk:
    ; reading from file
     xor ax, ax
     xor bx, handle
     lds dx, point_read
     mov ah, 3Fh
     mov cx, buffer_size
     int 21h
     mov bytes_read, al
     ; close file if an error was encountered
     jc close_file
     
     ; if entered word is somehow longer than the buffer itself, immediately display word was not found message
     mov bh, 0
     mov bl, bytes_read
     cmp bx, word_len
     jl fail
     
check:
    mov match_count, 0
    xor si, si
    mov di, start_pos
    mov cx, word_len

; loop each character from myword and compare it to the file contents, incrementing offset each time
loop_check:
    mov bl, buffer[di]
    
    ; check if ASCII code >= 65 ('A')
    cmp bl, 65
    jge check_less2
    jmp checked2
    
    ; if it is, then check if ASCII code <= 90 ('Z')
check_less2:
    cmp bl, 90
    jle make_lowercase2
    jmp checked2
    
    ; if ASCII code is between 'A' and 'Z', add 32 to make it lowercase
make_lowercase2:
    add bl, 32

checked2:
    cmp bl, myword[si]
    
    je increment
    jne reset

increment:
    inc di
    inc si
    inc match_count
    
    ; check if the number of matching bytes equals the entered word length
    xor bx, bx
    mov bl, match_count
    cmp bx, word_len
    je success
    
    loop loop_check
    
    jmp fail
    
reset:
    xor di, di
    inc start_pos
    
    xor bx, bx
    mov bl, bytes_read
    sub bx, word_len
    inc bx
    cmp bx, start_pos
    jne check
    je fail

; word was found in file
success:
    mov ah, 09h
    mov dx, offset success_message
    int 21h
    jmp close_file

; word was not found in file`
fail:
    mov ah, 09h
    mov dx, offset fail_message
    int 21h
    jmp close_file
    
close_file:
    mov ah, 3eh
    mov bx, handle
    int 21h

exit:
    mov ax,4c00h    
    int 21h 
end main        
