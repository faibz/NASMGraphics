%include "graphics_shapes.asm"

Set_Video_Mode:
	mov ah, byte 00h
	mov al, byte 13h

	int 10h

	ret