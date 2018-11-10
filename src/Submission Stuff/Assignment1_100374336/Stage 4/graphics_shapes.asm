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

	push si

	call Verify_Rectangle_Params

	mov si, word 1d

Draw_Rectangle_Loop:
	push word [bp + rectlength]
	push word [bp + rectystart]
	push word [bp + rectxstart]
	call Draw_Line_Horizontal

	inc word [bp + rectystart]

	cmp si, [bp + rectheight]
	jl Draw_Rectangle_Inc_Then_Loop

	pop si

	mov sp, bp
	pop bp

	ret 8

Draw_Rectangle_Inc_Then_Loop:
	inc si
	jmp Draw_Rectangle_Loop

; ========================================================
; =-----------------------ELLIPSE------------------------=
; ========================================================

;ellipse params
%assign ellipsexstart 4
%assign ellipseystart 6
%assign ellipsexend 8
%assign ellipseyend 10

;ellipse vars
%assign ellipsea 2
%assign ellipseb 4
%assign ellipseb1 6
%assign ellipsedx 8
%assign ellipsedy 10
%assign ellipseerr 12
%assign ellipsee2 14

Verify_Ellipse_Params:
	cmp [bp + ellipsexstart], word 0d
	jl Set_Default_Ellipse_Params
	cmp [bp + ellipsexstart], word 319d
	jg Set_Default_Ellipse_Params

	cmp [bp + ellipsexend], word 0d
	jl Set_Default_Ellipse_Params
	cmp [bp + ellipsexend], word 319d
	jg Set_Default_Ellipse_Params

	cmp [bp + ellipseystart], word 0d
	jl Set_Default_Ellipse_Params
	cmp [bp + ellipseystart], word 199d
	jg Set_Default_Ellipse_Params

	cmp [bp + ellipseyend], word 0d
	jl Set_Default_Ellipse_Params
	cmp [bp + ellipseyend], word 199d
	jg Set_Default_Ellipse_Params

	ret

Set_Default_Ellipse_Params:
	mov [bp + ellipsexstart], word 1d
	mov [bp + ellipseystart], word 1d
	mov [bp + ellipsexend], word 8d
	mov [bp + ellipseyend], word 4d

	ret

Draw_Ellipse:
	push bp
	mov bp, sp
	sub sp, 14

	push ax
	push cx
	push dx

	call Verify_Ellipse_Params

	mov ax, [bp + ellipsexend]
	sub ax, [bp + ellipsexstart]
	cmp ax, word 0d

	jge Ellipse_DX_Not_Negative
	neg ax

Ellipse_DX_Not_Negative:
	mov [bp - ellipsea], ax

	mov ax, [bp + ellipseyend]
	sub ax, [bp + ellipseystart]
	cmp ax, word 0d

	jge Ellipse_DY_Not_Negative
	neg ax

Ellipse_DY_Not_Negative:
	mov [bp - ellipseb], ax

	mov [bp - ellipseb1], ax
	and [bp - ellipseb1], word 1d

	mov ax, word 1d
	sub ax, [bp - ellipsea]
	mov cx, word 4d
	mul cx
	mul word [bp - ellipseb]
	mul word [bp - ellipseb]

	mov [bp - ellipsedx], ax

	mov ax, word 1d
	add ax, [bp - ellipseb1]
	mov cx, word 4d
	mul cx
	mul word [bp - ellipsea]
	mul word [bp - ellipsea]

	mov [bp - ellipsedy], ax

	mov ax, [bp - ellipseb1]
	mul word [bp - ellipsea]
	mul word [bp - ellipsea]
	add ax, [bp - ellipsedx]
	add ax, [bp - ellipsedy]

	mov [bp - ellipseerr], ax

	mov ax, [bp + ellipsexstart]
	cmp ax, [bp + ellipsexend]

	jle Ellipse_XStart_Not_GreaterThan_XEnd

	mov ax, [bp + ellipsexend]
	mov [bp + ellipsexstart], ax

	mov ax, [bp + ellipsexend]
	add ax, [bp - ellipsea]
	mov [bp + ellipsexend], ax

Ellipse_XStart_Not_GreaterThan_XEnd:
	mov ax, [bp + ellipseystart]
	cmp ax, [bp + ellipseyend]

	jle Ellipse_YStart_Not_GreaterThan_YEnd

	mov ax, [bp + ellipseyend]
	mov [bp + ellipsexstart], ax

Ellipse_YStart_Not_GreaterThan_YEnd:
	mov ax, [bp - ellipseb]
	add ax, 1

	mov cx, 2d
	div cx

	add [bp + ellipseystart], ax

	mov ax, [bp + ellipseystart]
	sub ax, [bp - ellipseb1]

	mov [bp + ellipseyend], ax

	mov ax, 8d
	mul word [bp - ellipsea]
	mul word [bp - ellipsea]
	mov [bp - ellipsea], ax

	mov ax, 8d
	mul word [bp - ellipseb]
	mul word [bp - ellipseb]
	mov [bp - ellipseb1], ax

Draw_Ellipse_Loop:
	push word [bp + ellipseystart]
	push word [bp + ellipsexend]
	call Draw_Pixel

	push word [bp + ellipseystart]
	push word [bp + ellipsexstart]
	call Draw_Pixel

	push word [bp + ellipseyend]
	push word [bp + ellipsexstart]
	call Draw_Pixel

	push word [bp + ellipseyend]
	push word [bp + ellipsexend]
	call Draw_Pixel

	mov ax, 2d
	mul word [bp - ellipseerr]
	mov [bp - ellipsee2], ax

	mov ax, [bp - ellipsee2]
	cmp ax, [bp - ellipsedy]
	jg Ellipse_E2_Not_LessThanOrEqualTo_DY

	inc word [bp + ellipseystart]
	dec word [bp + ellipseyend]

	mov ax, [bp - ellipsedy]
	add ax, [bp - ellipsea]
	mov [bp - ellipsedy], ax

	add [bp - ellipseerr], ax

Ellipse_E2_Not_LessThanOrEqualTo_DY:
	mov cx, [bp - ellipsee2]
	cmp cx, [bp - ellipsedx]

	jl Ellipse_E2_Not_GreaterThanOrEqualTo_Dx

	inc word [bp + ellipsexstart]
	dec word [bp + ellipsexend]

	mov ax, [bp - ellipsedx]
	add ax, [bp - ellipseb1]
	mov [bp - ellipsedx], ax

	add [bp - ellipseerr], ax

Ellipse_E2_Not_GreaterThanOrEqualTo_Dx:
	mov ax, [bp + ellipsexstart]
	cmp ax, [bp + ellipsexend]

	jle Draw_Ellipse_Loop

Draw_Ellipse_Loop_Two:
	mov ax, [bp + ellipseystart]
	sub ax, [bp + ellipseyend]
	cmp ax, [bp - ellipseb]

	jge Ellipse_Y0_Minus_Y1_Not_LessThan_B

	mov cx, [bp + ellipsexstart]
	dec cx
	push cx
	push word [bp + ellipseystart]

	call Draw_Pixel

	mov cx, [bp + ellipsexend]
	inc cx
	push word [bp + ellipseystart]
	push cx
	inc word [bp + ellipseystart]

	call Draw_Pixel

	mov cx, [bp + ellipsexstart]
	dec cx
	mov dx, [bp + ellipseyend]
	push word [bp + ellipseyend]
	push cx

	call Draw_Pixel

	mov cx, [bp + ellipsexend]
	inc cx
	mov dx, [bp + ellipseyend]
	dec word [bp + ellipseyend]
	push dx
	push cx

	call Draw_Pixel

	jmp Draw_Ellipse_Loop_Two

Ellipse_Y0_Minus_Y1_Not_LessThan_B:
	pop dx
	pop cx
	pop ax

	mov sp, bp
	pop bp

	ret 8

; ========================================================
; =-----------------------TRIANGLE-----------------------=
; ========================================================

;triangle params
%assign trianglexstart 4
%assign triangleystart 6
%assign triangleheight 8

;triangle vars
%assign trianglexbegin 2
%assign trianglexend 4
%assign triangely 6

Verify_Triangle_Params:
	mov cx, [bp + triangleystart]
	add cx, [bp + triangleheight]

	cmp cx, word 199d
	jg Set_Default_Triangle_Params

	mov cx, [bp + trianglexstart]
	sub cx, [bp + triangleheight]
	
	cmp cx, word 0d
	jl Set_Default_Triangle_Params

	mov cx, [bp + trianglexstart]
	add cx, [bp + triangleheight]

	cmp cx, word 319d
	jg Set_Default_Triangle_Params

	ret

Set_Default_Triangle_Params:
	mov [bp + trianglexstart], word 200d
	mov [bp + triangleystart], word 150d
	mov [bp + triangleheight], word 15d

	ret

Draw_Triangle:
	push bp
	mov bp, sp
	sub sp, 6

	push cx

	call Verify_Triangle_Params

	mov cx, [bp + trianglexstart]
	mov [bp - trianglexbegin], cx
	mov [bp - trianglexend], cx
	mov cx, [bp + triangleystart]
	mov [bp - triangely], cx

Draw_Triangle_Loop:
	mov cx, [bp - trianglexend]
	sub cx, [bp - trianglexbegin]

	push word cx
	push word [bp - triangely]
	push word [bp - trianglexbegin]
	call Draw_Line_Horizontal

	mov cx, [bp - triangely]
	sub cx, [bp + triangleystart]

	dec word [bp - trianglexbegin]
	inc word [bp - trianglexend]
	inc word [bp - triangely]

	cmp cx, [bp + triangleheight]
	jle Draw_Triangle_Loop

Draw_Triangle_Exit:
	pop cx

	mov sp, bp
	pop bp

	ret 6