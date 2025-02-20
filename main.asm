extern _puts
extern _ExitProcess@4
extern _malloc
extern _free
extern _loadPixelInfo
extern _generateArt

global _main

section .data


; const char*
msg db "hello world",0
noArgsErr db "Not enough args. Please include the path to bitmap",0

section .text

_main:
	push ebp
  mov ebp, esp
	
	cmp dword [ebp + 8], 1
	jg .yesArgs
		push noArgsErr ;  "Not enough args. Please include the path to bitmap"
		call _puts
	  add esp, 4
		push -1
		call _ExitProcess@4

.yesArgs:
	push msg
	call _puts	
	add esp, 4


	mov ebx, [ebp + 12]
	mov esi, [ebx + 4]
	call _loadPixelInfo
	
	call _generateArt

	push 0
	call _ExitProcess@4
	