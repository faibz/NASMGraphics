%assign xstart 4
%assign xfinish 6
%assign ystart 8
%assign yfinish 10

%assign sy 2
%assign sx 4
%assign ydelta 6
%assign xdelta 8

Set_Background_Colour:
	mov ah, 0Bh
	mov bh, 00h
	mov bl, 13h

	int 10h

	ret

Get_And_Set_Line_Colour:
	mov si, colour_select_message
	call Console_WriteLine_16

	xor ah, ah
	int 16h

	sub al, 49d
	cmp al, byte 7d
	jg Set_Line_Colour_Default
	cmp al, byte 1d
	jl Set_Line_Colour_Default

	xor ah, ah
	cbw
	mov si, ax

	mov si, [si + available_colors]
	mov ax, si
	mov [line_colour], byte al

	ret

Set_Line_Colour_Default:
	mov ah, byte 9d

	ret

Set_Video_Mode:
	mov ah, byte 00h
	mov al, byte 13h

	int 10h

	ret

Draw_Pixel:
	mov ah, byte 0Ch
	mov al, byte [line_colour]

	int 10h

	ret
	
Draw_Line_Bresenham:
	push bp
	mov bp, sp
	sub sp, 8
	push dx
	push cx
	push bx
	push ax
	push si

	mov bx, word [bp + xfinish]
	sub bx, word [bp + xstart]

	cmp bx, word 0d
	jge DX_Not_Negative
	neg bx

DX_Not_Negative:
	mov [bp - xdelta], word bx

	mov bx, word [bp + yfinish]
	sub bx, word [bp + ystart]

	cmp bx, word 0d
	jge DY_Not_Negative
	neg bx

DY_Not_Negative:
	mov [bp - ydelta], word bx

	mov bx, word [bp + xstart]
	cmp bx, word [bp + xfinish]

	mov bx, word 1d
	jl X0_Less_Than_X1

	mov bx, word -1d

X0_Less_Than_X1:
	mov [bp - sx], word bx

	mov bx, word [bp + ystart]
	cmp bx, word [bp + yfinish]

	mov bx, word 1d
	jl Y0_Less_Than_Y1

	mov bx, word -1d

Y0_Less_Than_Y1:
	mov [bp - sy], word bx

	mov bx, word [bp - xdelta]
	sub bx, word [bp - ydelta]

	mov cx, word [bp + xstart]
	mov dx, word [bp + ystart]

Loop_Start:
	;cx = col num
	;dx = row num
	;e2 -> ax
	;err -> bx

	call Draw_Pixel

	cmp cx, word [bp + xfinish]

	jne Not_Final_X_Point

	cmp dx, word [bp + yfinish]
	je Loop_Exit

Not_Final_X_Point:
	mov ax, bx
	add ax, ax

	mov si, word [bp - ydelta]
	neg si
	cmp ax, si

	jng E2_Less_Than_Or_Equal_To_Neg_DY

	sub bx, word [bp - ydelta]
	add cx, word [bp - sx]

E2_Less_Than_Or_Equal_To_Neg_DY:
	cmp ax, word [bp - xdelta]
	jnl E2_Greater_Than_DX

	add bx, word [bp - xdelta]
	add dx, word [bp - sy]

E2_Greater_Than_DX:
	jmp Loop_Start

Loop_Exit:
	pop si
	pop ax
	pop bx
	pop cx
	pop dx

	mov sp, bp
	pop bp

	ret 8

line_colour db 9d

available_colors 	db 9
					db 10
					db 11
					db 12
					db 13
					db 14
					db 15