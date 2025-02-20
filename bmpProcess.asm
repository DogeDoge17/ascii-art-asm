extern _CreateFileA@28
extern _ReadFile@20
extern _ExitProcess@4
extern _CloseHandle@4
extern _GetLastError@0
extern _malloc
extern _puts


 
global _loadPixelInfo ; takes in char*
global _calcRowSize ; takes in DIBHeader*

section .data
; consts
INVALID_HANDLE_VALUE    equ -1
GENERIC_READ            equ 0x80000000
OPEN_EXISTING           equ 3
FILE_ATTRIBUTE_NORMAL   equ 0x00000080
BMP_HEADER_SIZE equ 14
DIB_HEADER_SIZE equ 40

; const char*
failMsg db "failed to load the path.", 0

section .text

_loadPixelInfo:  

  ; DWORD(?) fileHandle 
  ; void* BMP_HEADER 
  ; void* DIP_HEADER 
  ; void* PIXEL_DATA
  push ebp
  mov ebp, esp
  sub esp, 16
  %define fileHandle [ebp - 4]
  %define bmpHeader [ebp - 8]
  %define dipHeader [ebp - 12]
  %define pixelData [ebp - 16]

  push esi
  call _puts

	;push 0                 ; hTemplateFile = NULL
  push 0                  ; dwFlagsAndAttributes = 0
  push 3                  ; dwCreationDisposition = OPEN_EXISTING
  push 0                  ; lpSecurityAttributes = NULL
  push 1                  ; dwShareMode = FILE_SHARE_READ
  push 0x80000000         ; dwDesiredAccess = GENERIC_READ
  push esi                ; lpFileName
  call _CreateFileA@28
  mov fileHandle, eax
  
  cmp eax, INVALID_HANDLE_VALUE
    je _fail  

  ; -- LOAD BMP HEADER
  push BMP_HEADER_SIZE ; size of BmpHeader
  call _malloc
  add esp, 4
  mov bmpHeader, eax

  push 0                  ; lpOverlapped = NULL
  push 0                  ; lpNumberOfBytesRead
  push BMP_HEADER_SIZE    ; nNumberOfBytesToRead
  push eax                ; lpBuffer
  push dword fileHandle         ; hFile (saved handle)
  call _ReadFile@20
  test eax, eax
  jz _fail
  
  ; -- LOAD DIP HEADER
  push DIB_HEADER_SIZE ; size of BmpHeader
  call _malloc
  add esp, 4
  mov dipHeader, eax

  push 0                  ; lpOverlapped = NULL
  push 0                  ; lpNumberOfBytesRead
  push DIB_HEADER_SIZE    ; nNumberOfBytesToRead
  push eax                ; lpBuffer
  push dword fileHandle   ; hFile (saved handle)
  call _ReadFile@20
  test eax, eax
  jz _fail

  ; Create pixel buffer by extracting dimensions

  mov ecx, dipHeader
  call _calcRowSize
  mov ebx, [ecx + 8]
  mul ebx

  push eax
  push eax
  call _malloc
  add esp, 4
  test eax, eax
  jz _fail
  mov pixelData, eax

  pop ecx
  
  push 0                  ; lpOverlapped = NULL
  push 0                  ; lpNumberOfBytesRead
  push ecx                ; nNumberOfBytesToRead
  push dword pixelData    ; lpBuffer
  push dword fileHandle   ; hFile (saved handle)
  call _ReadFile@20
  test eax, eax
  jz _fail


  push dword fileHandle
  call _CloseHandle@4

  ; return all the pointers
  mov eax, pixelData 
  mov ebx, dipHeader
  mov ecx, bmpHeader

  %undef fileHandle
  %undef bmpHeader
  %undef dipHeader
  %undef pixelData

  mov esp, ebp
  pop ebp
  ret

_fail:
    push failMsg
    call _puts
    add esp, 4

    xor eax, eax
    call _GetLastError@0    
    call _ExitProcess@4


;int rowSize = ((dibHeader.bpp * dibHeader.width + 31) / 32) * 4;
_calcRowSize:
    xor eax, eax
    mov ax, [ecx+14]
    mov ebx, [ecx+4]
    mul ebx
    add eax, 31

    xor edx, edx
    mov ebx, 32
    div ebx

    mov ebx, 4
    mul ebx
    ret
    