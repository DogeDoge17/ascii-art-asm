extern _puts
extern _ExitProcess@4
extern _malloc
extern _free
extern _loadPixelInfo
extern _generateArt
extern _copyToClipboard
extern _getchar

global _main

section .data

; const char*
noArgsErr db "Not enough args. Please include the path to bitmap", 0

section .text

_main:
	push ebp
  mov ebp, esp

	cmp dword [ebp + 8], 1
	jg .yesArgs
		push noArgsErr ; "Not enough args. Please include the path to bitmap"
		call _puts
	  add esp, 4
		push -1
		call _ExitProcess@4

.yesArgs:	

	mov ebx, [ebp + 12]
	mov esi, [ebx + 4]
	call _loadPixelInfo
	
	call _generateArt

	push ebp
    mov ebp, esp
    sub esp, 8
	mov [ebp - 4], ebx
	mov [ebp - 8], eax
	%define outputData [ebp - 8]
	%define outputLen [ebp - 8]




	mov esp, ebp
	pop ebp

	push 0
	call _ExitProcess@4
	