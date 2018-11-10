%include "graphics_shapes.asm"

Set_Video_Mode:
	mov ah, byte 00h
	mov al, byte 13h

	int 10h

	ret

Draw_House_Scene:
	;ground
	mov word [colour], 2d
	push word 80d ;length
	push word 25d ;height
	push word 125d ;ystart
	push word 220d ;xstart
	call Draw_Rectangle

	;sky
	mov word [colour], 11d
	push word 80d
	push word 100d
	push word 25d
	push word 220d
	call Draw_Rectangle

	;house
	mov word [colour], 6d
	push word 40d
	push word 25d
	push word 100d
	push word 240d
	call Draw_Rectangle

	;path
	mov word [colour], 8d
	push word 6d
	push word 20d
	push word 125d
	push word 257d
	call Draw_Rectangle

	;road
	push word 80d
	push word 6d
	push word 140d
	push word 220d
	call Draw_Rectangle 
	
	;door
	mov word [colour], 4d
	push word 6d
	push word 10d
	push word 115d
	push word 257d
	call Draw_Rectangle

	;window
	mov word [colour], 15d
	push word 7d
	push word 7d
	push word 110d
	push word 245d
	call Draw_Rectangle

	;window 2
	push word 7d
	push word 7d
	push word 110d
	push word 268d
	call Draw_Rectangle

	;roof
	mov word [colour], 0d
	push word 22d ;height
	push word 76d ;ystart
	push word 260d ;xstart
	call Draw_Triangle

	;sun
	mov word [colour], 14d
	push word 5d ;radius
	push word 50d; origin y
	push word 260d; origin x
	call Draw_Circle

	push word 4d ;radius
	push word 50d; origin y
	push word 260d; origin x
	call Draw_Circle

	push word 3d ;radius
	push word 50d; origin y
	push word 260d; origin x
	call Draw_Circle

	push word 2d ;radius
	push word 50d; origin y
	push word 260d; origin x
	call Draw_Circle

	push word 1d ;radius
	push word 50d; origin y
	push word 260d; origin x
	call Draw_Circle

	ret

Run_Animation:
	push bp
	mov bp, sp

	push cx
	push dx
	push ax
	push si

	mov cx, word 35d
	mov dx, word 55d
	xor ax, ax
	xor si, si

	mov [colour], word 0d

Run_Animation_Loop:
	call Short_Wait

	push dx
	push cx
	call Draw_Pixel

	push dx
	push cx
	call Draw_Pixel

	inc dx
	inc ax

	cmp ax, word 40d
	jl Run_Animation_Loop

	cmp si, word 2d
	jl Run_Animation_Inc_Then_Loop

	mov cx, word 36d
	mov dx, word 75d
	xor ax, ax

Run_Animation_Loop_End:
	call Short_Wait

	push dx
	push cx
	call Draw_Pixel

	inc cx
	inc ax
	cmp ax, word 25d
	jl Run_Animation_Loop_End

	pop si
	pop ax
	pop dx
	pop cx

	mov sp, bp
	pop bp

	ret

Run_Animation_Inc_Then_Loop:
	inc si
	add cx, 25d
	sub dx, 40d
	xor ax, ax

	jmp Run_Animation_Loop

Short_Wait:
	push cx
	push dx
	push ax

	xor cx, cx
	mov dx, 02710h
	mov ah, 86h
	int 15h

	pop ax
	pop dx
	pop cx

	ret