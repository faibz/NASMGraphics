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

;circle params
%assign originx 4
%assign originy 6
%assign radius 8

;circle vars
%assign circlex 2
%assign circley 4
%assign circleerr 6

Draw_Circle:
	push bp
	mov bp, sp
	sub sp, 6

	push si
	push cx
	push dx

	mov si, [bp + radius]
	mov [bp - circlex], si
	neg word [bp - circlex]

	mov [bp - circley], word 0d

	mov [bp - circleerr], word 2d
	mov si, [bp + radius]
	add si, si
	sub [bp - circleerr], si

Draw_Circle_Loop:
	mov cx, [bp + originx]
	sub cx, [bp - circlex]
	mov dx, [bp + originy]
	add dx, [bp - circley]
	call Draw_Pixel

	mov cx, [bp + originx]
	sub cx, [bp - circley]
	mov dx, [bp + originy]
	sub dx, [bp - circlex]
	call Draw_Pixel

	mov cx, [bp + originx]
	add cx, [bp - circlex]
	mov dx, [bp + originy]
	sub dx, [bp - circley]
	call Draw_Pixel

	mov cx, [bp + originx]
	add cx, [bp - circley]
	mov dx, [bp + originy]
	add dx, [bp - circlex]
	call Draw_Pixel

	mov si, [bp - circleerr]
	mov [bp + radius], si
	
	mov si, [bp - circley]
	cmp [bp + radius], si
	jg Draw_Circle_Radius_NotLessThanOrEqualTo_CircleY

	add [bp - circley], word 1d
	mov si, [bp - circley]
	add [bp - circleerr], si
	add [bp - circleerr], si
	add [bp - circleerr], word 1d

Draw_Circle_Radius_NotLessThanOrEqualTo_CircleY:
	mov si, [bp - circlex]
	cmp [bp + radius], si
	jle Draw_Circle_Radius_NotGreaterThan_CircleX

	add [bp - circlex], word 1d
	mov si, [bp - circlex]
	add [bp - circleerr], si
	add [bp - circleerr], si
	add [bp - circleerr], word 1d

Draw_Circle_Radius_NotGreaterThan_CircleX:
	jg Draw_Circle_Err_NotGreaterThan_CircleY ;if the first condition was met and actions taken, they won't be taken again

	mov si, [bp - circley]
	cmp [bp - circleerr], si
	jle Draw_Circle_Err_NotGreaterThan_CircleY

	add [bp - circlex], word 1d
	mov si, [bp - circlex]
	add [bp - circleerr], si
	add [bp - circleerr], si
	add [bp - circleerr], word 1d

Draw_Circle_Err_NotGreaterThan_CircleY:
	cmp [bp - circlex], word 0d
	jl Draw_Circle_Loop

	pop dx
	pop cx
	pop si

	mov sp, bp
	pop bp

	ret 6

;rect params
%assign rectxstart 4
%assign rectystart 6
%assign rectheight 8
%assign rectlength 10

;rect vars
%assign xfinish 2
%assign yfinish 4

;rect line params
%assign xstart 4
%assign ystart 6
%assign length 8

Draw_Rectangle:
	push bp
	mov bp, sp
	sub sp, 4

	push dx
	push ax
	push si

	mov ax, [bp + xstart]
	add ax, [bp + rectlength]
	mov [bp - xfinish], ax

	mov ax, [bp + ystart]
	add ax, [bp + rectheight]
	mov [bp - yfinish], ax

	mov dx, [bp + rectystart]

	mov si, word 1d

Draw_Rectangle_Loop:
	push word [bp + rectlength]
	push word dx
	push word [bp + rectxstart]
	call Draw_Line_Horizontal

	inc dx

	cmp si, word [bp + rectheight]
	jl Draw_Rectangle_Loop_Hook

	pop si
	pop ax
	pop dx

	mov sp, bp
	pop bp

	ret 4

Draw_Rectangle_Loop_Hook:
	inc si
	jmp Draw_Rectangle_Loop

Draw_Pixel:
	push ax

	mov ah, byte 0Ch
	mov al, byte [line_colour]

	int 10h

	pop ax

	ret

Draw_Line_Horizontal:
	push bp
	mov bp, sp

	push dx
	push cx

	mov bx, [bp + xstart]
	add bx, [bp + length]

	mov cx, [bp + xstart]
	mov dx, [bp + ystart]

	call Draw_Line_Horizontal_Repeat

	pop cx
	pop dx

	mov sp, bp
	pop bp
	ret

Draw_Line_Horizontal_Repeat:
	call Draw_Pixel

	cmp cx, bx
	je Draw_Line_Horizontal_Exit

	inc cx

	jmp Draw_Line_Horizontal_Repeat

Draw_Line_Horizontal_Exit:
	ret

;bresenham line params
%assign xstart 4
%assign xfinish 6
%assign ystart 8
%assign yfinish 10

;bresenham line vars
%assign sy 2
%assign sx 4
%assign ydelta 6
%assign xdelta 8

Draw_Line_Bresenham:
	mov bx, word [bp - xfinish]
	sub bx, word [bp + xstart]

	cmp bx, word 0d
	jge DX_Not_Negative
	neg bx

DX_Not_Negative:
	mov [bp - xdelta], word bx

	mov bx, word [bp - yfinish]
	sub bx, word [bp + ystart]

	cmp bx, word 0d
	jge DY_Not_Negative
	neg bx

DY_Not_Negative:
	mov [bp - ydelta], word bx

	mov bx, word [bp + xstart]
	cmp bx, word [bp - xfinish]

	mov bx, word 1d
	jl X0_Less_Than_X1

	mov bx, word -1d

X0_Less_Than_X1:
	mov [bp - sx], word bx

	mov bx, word [bp + ystart]
	cmp bx, word [bp - yfinish]

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

	cmp cx, word [bp - xfinish]

	jne Not_Final_X_Point

	cmp dx, word [bp - yfinish]
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
	ret

line_colour db 9d

available_colors 	db 9
					db 10
					db 11
					db 12
					db 13
					db 14
					db 15