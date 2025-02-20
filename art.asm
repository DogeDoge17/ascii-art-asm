extern _puts
extern _malloc
extern _free
extern _calcRowSize

extern _max
extern _min

global _generateArt

section .data

lightMap db " `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@"
lightMapCount equ $ - lightMap
section .text

_generateArt:
  ; (DWORD) byte* dipHeader
  ; (DWORD) byte* pixelData
  ; (DWORD) byte* outputBuffer
  ; (DWORD) int x
  ; (DWORD) int y  
  ; (DWORD) int i  
  ; (DWORD) int width 
  ; (DWORD) int height 
  ; (BYTE)  byte lightLevel
  push ebp
  mov ebp, esp
  sub esp, 37

  %define dipHeader [ebp - 4]
  %define pixelData [ebp - 8]
  %define outputBuffer [ebp - 12]
  %define x [ebp - 16]
  %define y [ebp - 20]
  %define i [ebp - 24]
  %define width [ebp - 28]
  %define height [ebp - 32]
  %define rowSize [ebp - 36]
  %define lightLevel [ebp - 37]

  mov pixelData, eax
  mov dipHeader, ebx 
  mov dword x, 0

  mov ecx, dipHeader
  mov eax, [ecx + 4]
  mov width, eax
  mov eax, [ecx + 8]  
  mov height, eax
  mov y, eax

  call _calcRowSize
  mov rowSize, eax

.loopY:
  dec dword y 
  cmp dword y, 0
  jl .loopEnd
  mov dword x, -1
  .loopX
    inc dword x
    mov eax, x
    cmp eax, width
    jge .loopY
      ; int pixelIndex = (y * rowSize) + (x * 3);
      mov ebx, 3
      mul ebx
      mov edx, eax

      mov eax, y
      mov ebx, rowSize
      mul ebx
      add eax, edx      
      
      mov ebx, pixelData

      xor ecx, ecx
      movzx ecx, byte [ebx + eax]
      push ecx
      movzx ecx, byte [ebx + eax+1]
      push ecx
      movzx ecx, byte [ebx + eax+2]
      push ecx
      call _getLightLevel
      add esp, 12
      
      push placeHolder
      call _puts
      add esp, 4
    jmp .loopX
  jmp .loopY


.loopEnd:

  %undef dipHeader
  %undef pixelData
  %undef outputBuffer
  %undef x 
  %undef y 
  %undef i
  %undef width
  %undef height
  %undef lightLevel

  mov esp, ebp
  pop ebp
  ret

  ; r = [esp - 4]
  ; g = [esp - 8]
  ; b = [esp - 12]
_getLightLevel:
  mov eax, [esp + 4]
  mov ebx, [esp + 8]
  call _max
  mov ebx, [esp + 12]
  call _max
  mov ecx, eax

  mov eax, [esp + 4]
  mov ebx, [esp + 8]
  call _min
  mov ebx, [esp + 12]
  call _min
  add eax, ecx
  
  mov ebx, 2
  xor edx,edx
  div ebx

  ret