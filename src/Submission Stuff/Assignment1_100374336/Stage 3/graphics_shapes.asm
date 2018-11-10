%include "graphics_drawing.asm"

; ========================================================
; =----------------------CIRCLE--------------------------=
; ========================================================

;circle params
%assign originx 4
%assign originy 6
%assign radius 8

;circle vars
%assign circlex 2
%assign circley 4
%assign circleerr 6

Verify_Circle_Params:
	mov cx, [bp + originx]
	add cx, [bp + radius]

	cmp cx, 319d
	jg Set_Default_Circle_Params

	mov cx, [bp + originx]
	sub cx, [bp + radius]

	cmp cx, 0d
	jl Set_Default_Circle_Params

	mov cx, [bp + originy]
	add cx, [bp + radius]

	cmp cx, 199d
	jg Set_Default_Circle_Params

	mov cx, [bp + originy]
	sub cx, [bp + radius]

	cmp cx, 0d
	jl Set_Default_Circle_Params

	ret

Set_Default_Circle_Params:
	mov [bp + originx], word 100d
	mov [bp + originy], word 100d
	mov [bp + radius], word 25d

	ret

Draw_Circle:
	push bp
	mov bp, sp
	sub sp, 6

	push si
	push cx
	push dx

	call Verify_Circle_Params

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
	push dx
	push cx
	call Draw_Pixel

	mov cx, [bp + originx]
	sub cx, [bp - circley]
	mov dx, [bp + originy]
	sub dx, [bp - circlex]
	push dx
	push cx
	call Draw_Pixel

	mov cx, [bp + originx]
	add cx, [bp - circlex]
	mov dx, [bp + originy]
	sub dx, [bp - circley]
	push dx
	push cx
	call Draw_Pixel

	mov cx, [bp + originx]
	add cx, [bp - circley]
	mov dx, [bp + originy]
	add dx, [bp - circlex]
	push dx
	push cx
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

; ========================================================
; =----------------------RECTANGLE-----------------------=
; ========================================================

;rect params
%assign rectxstart 4
%assign rectystart 6
%assign rectheight 8
%assign rectlength 10

;rect vars
%assign xfinish 2
%assign yfinish 4

Verify_Rectangle_Params:
	mov dx, [bp + rectxstart]
	add dx, [bp + rectlength]

	cmp dx, 319d
	jg Set_Default_Rectangle_Params

	mov dx, [bp + rectystart]
	add dx, [bp + rectheight]

	cmp dx, 199d
	jg Set_Default_Rectangle_Params

	ret

Set_Default_Rectangle_Params:
	mov [bp + rectxstart], word 100d
	mov [bp + rectystart], word 100d
	mov [bp + rectlength], word 100d
	mov [bp + rectheight], word 50d

	ret

Draw_Rectangle:
	push bp
	mov bp, sp
	sub sp, 4

	push dx
	push ax
	push si
	
	call Verify_Rectangle_Params

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

	ret 8

Draw_Rectangle_Loop_Hook:
	inc si
	jmp Draw_Rectangle_Loop

;rect line params
%assign xstart 4
%assign ystart 6
%assign length 8

Draw_Line_Horizontal:
	push bp
	mov bp, sp

	push bx
	push dx
	push cx

	mov bx, [bp + xstart]
	add bx, [bp + length]
	dec bx

	mov cx, [bp + xstart]
	mov dx, [bp + ystart]
	
Draw_Line_Horizontal_Loop:
	push dx
	push cx
	call Draw_Pixel

	cmp cx, bx
	jl Draw_Line_Horizontal_Inc_Then_Loop

	pop cx
	pop dx
	pop bx

	mov sp, bp
	pop bp
	
	ret 6

Draw_Line_Horizontal_Inc_Then_Loop:
	inc cx
	jmp Draw_Line_Horizontal_Loop