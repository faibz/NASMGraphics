Set_Background_Colour:
	mov ah, 0Bh
	mov bh, 00h
	mov bl, 13h

	int 10h

	ret

Set_Line_Colour:
	sub al, 49d
	cmp al, byte 7d
	jg Set_Line_Colour_Default
	cmp al, byte 1d
	jl Set_Line_Colour_Default

Set_Line_Colour_Continue:
	xor ah, ah
	cbw
	mov si, ax

	mov si, [si + available_colors]
	mov ax, si
	mov [line_colour], byte al

	ret

Set_Line_Colour_Default:
	mov [line_colour], byte 9d
	jmp Set_Line_Colour_Continue

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
	mov bx, word [x_end]
	sub bx, word [x_start]

	cmp bx, word 0d
	jge DX_Not_Negative
	neg bx

DX_Not_Negative:
	mov [x_delta], word bx

	mov bx, word [y_end]
	sub bx, word [y_start]

	cmp bx, word 0d
	jge DY_Not_Negative
	neg bx

DY_Not_Negative:
	mov [y_delta], word bx

	mov bx, word [x_start]
	cmp bx, word [x_end]

	mov bx, 1d
	jl X0_Less_Than_X1

	mov bx, word -1d

X0_Less_Than_X1:
	mov [_sx], word bx

	mov bx, word [y_start]
	cmp bx, word [y_end]

	mov bx, word 1d
	jl Y0_Less_Than_Y1

	mov bx, word -1d

Y0_Less_Than_Y1:
	mov [_sy], bx

	mov bx, word [x_delta] ;err
	sub bx, word [y_delta]

	mov cx, word [x_start] ;column
	mov dx, word [y_start] ;row

Loop_Start:
	call Draw_Pixel

	cmp cx, word [x_end]

	jne Not_Final_X_Point

	cmp dx, word [y_end]
	je Loop_Exit

Not_Final_X_Point:
	mov ax, bx ;e2
	add ax, ax

	mov si, word [y_delta]
	neg si
	cmp ax, si

	jng E2_Less_Than_Or_Equal_To_Neg_DY

	sub bx, word [y_delta]
	add cx, word [_sx]

E2_Less_Than_Or_Equal_To_Neg_DY:
	cmp ax, word [x_delta]
	jnl E2_Greater_Than_DX

	add bx, word [x_delta]
	add dx, word [_sy]

E2_Greater_Than_DX:
	jmp Loop_Start

Loop_Exit:
	ret

x_start dw 25d
x_end dw 75d
y_start dw 150d
y_end dw 100d

x_delta dw 0d
y_delta dw 0d

_sx dw 0d
_sy dw 0d

line_colour db 9d

colour_select_message db 'Select a colour for the lines. 1: Blue (default) | 2: Green | 3: Cyan | 4: Red | 5: Magenta | 6: Yellow | 7: White', 0

available_colors 	db 9
					db 10
					db 11
					db 12
					db 13
					db 14
					db 15