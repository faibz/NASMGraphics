Get_And_Set_Colour:
	mov si, colour_select_message
	call Console_WriteLine_16

	xor ah, ah
	int 16h

	sub al, 49d
	cmp al, byte 7d
	jg Set_Colour_Default
	cmp al, byte 1d
	jl Set_Colour_Default

	xor ah, ah
	cbw
	mov si, ax

	mov si, [si + available_colors]
	mov ax, si
	mov [colour], byte al

	ret

Set_Colour_Default:
	mov ah, byte 9d

	ret

colour db 9d
colour_select_message db 'Select a colour. 1: Blue (default) | 2: Green | 3: Cyan | 4: Red | 5: Magenta | 6: Yellow | 7: White', 0
available_colors 	db 1
					db 2
					db 3
					db 4
					db 5
					db 14
					db 15