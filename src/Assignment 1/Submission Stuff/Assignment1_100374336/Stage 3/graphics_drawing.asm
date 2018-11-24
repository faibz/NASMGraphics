%include "graphics_colours.asm"

%assign columnNum 4
%assign rowNum 6

Draw_Pixel:
	push bp
	mov bp, sp

	push ax
	push cx
	push dx

	mov ah, byte 0Ch
	mov al, byte [colour]

	mov cx, [bp + columnNum]
	mov dx, [bp + rowNum]

	int 10h

	pop dx
	pop cx
	pop ax

	mov sp, bp
	pop bp

	ret	4

;bresenham line params
%assign xstart 4
%assign xfinish 6
%assign ystart 8
%assign yfinish 10

;bresenham line vars
%assign xdelta 2
%assign ydelta 4
%assign sx 6
%assign sy 8

Verify_Bresenham_Line_Params:
	cmp [bp + xstart], word 0d
	jl Set_Default_Bresenham_Line_Params
	cmp [bp + xstart], word 319d
	jg Set_Default_Bresenham_Line_Params

	cmp [bp + xfinish], word 0d
	jl Set_Default_Bresenham_Line_Params
	cmp [bp + xfinish], word 319d
	jg Set_Default_Bresenham_Line_Params

	cmp [bp + ystart], word 0d
	jl Set_Default_Bresenham_Line_Params
	cmp [bp + ystart], word 199d
	jg Set_Default_Bresenham_Line_Params

	cmp [bp + yfinish], word 0d
	jl Set_Default_Bresenham_Line_Params
	cmp [bp + yfinish], word 199d
	jg Set_Default_Bresenham_Line_Params

	ret

Set_Default_Bresenham_Line_Params:
	mov [bp + xstart], word 25d
	mov [bp + xfinish], word 50d
	mov [bp + yfinish], word 64d
	mov [bp + ystart], word 15d

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

	call Verify_Bresenham_Line_Params

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

	mov bx, word [bp - xdelta] ;err
	sub bx, word [bp - ydelta]

	mov cx, word [bp + xstart] ;column
	mov dx, word [bp + ystart] ;row

Loop_Start:
	push dx
	push cx
	call Draw_Pixel

	cmp cx, word [bp + xfinish]

	jne Not_Final_X_Point

	cmp dx, word [bp + yfinish]
	je Loop_Exit

Not_Final_X_Point:
	mov ax, bx ;e2
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