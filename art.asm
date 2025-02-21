extern _puts
extern _malloc
extern _free
extern _calcRowSize

extern _max
extern _min

global _generateArt

section .data

lightMap db ". ',;:clodxkO0KXNN"
lightMapCount equ $ - lightMap-1
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
  sub esp, 36

  %define dipHeader [ebp - 4]
  %define pixelData [ebp - 8]
  %define outputBuffer [ebp - 12]
  %define x [ebp - 16]
  %define y [ebp - 20]
  %define width [ebp - 24]
  %define height [ebp - 28]
  %define rowSize [ebp - 32]
  %define outputStart [ebp - 36]  

  mov pixelData, eax
  mov dipHeader, ebx 

  push ecx
  call _free

  mov dword x, 0

  mov ecx, dipHeader
  mov eax, [ecx + 4]
  mov width, eax
  mov eax, [ecx + 8]  
  mov height, eax
  dec eax ; y = height - 1
  mov y, eax 

  call _calcRowSize
  mov rowSize, eax
  
  ;outputBuffer = _malloc( ((width+1) * height) + 1 )

  mov eax, width
  inc eax
  mov ebx, height
  mul ebx
  inc eax
  push eax
  call _malloc
  mov outputBuffer, eax
  mov outputStart, eax

.loopY:
  ;dec dword y 
  cmp dword y, -1
  jz .loopEndY

  mov dword x, 0
  .loopX:
    mov eax, x
    cmp eax, width
    jge .loopEndX
      ; int pixelIndex = (y * rowSize) + (x * 3);
      mov ebx, 3
      mul ebx
      mov ecx, eax

      mov eax, y
      mov ebx, rowSize
      mul ebx
      add eax, ecx      
      
      mov ebx, pixelData

      xor ecx, ecx
      movzx ecx, byte [ebx + eax]
      push ecx
      movzx ecx, byte [ebx + eax + 1]
      push ecx
      movzx ecx, byte [ebx + eax + 2]
      push ecx
      call _getLightLevel
      add esp, 12
     
      ; light / (255 / lightMapCount)

      mov ecx, eax
      mov eax, 255
      mov ebx, lightMapCount
      xor edx, edx
      div ebx
      mov ebx, eax
      mov eax, ecx
      xor edx, edx
      div ebx

      ; *outputBuffer = lightMap[~];
      ; outputBuffer++;
      mov edi, outputBuffer
      mov bl, [lightMap + eax]
      mov [edi], bl
      inc dword outputBuffer

    inc dword x
    jmp .loopX
    .loopEndX:
  mov edi, outputBuffer
  mov byte [edi], 10
  inc dword outputBuffer
  dec dword y
  jmp .loopY
.loopEndY:
  mov edi, outputBuffer
  mov byte [edi], 0

  push dword outputStart
  call _puts
  add esp, 4

  push dword dipHeader
  call _free
  push dword pixelData
  call _free

  mov eax, outputBuffer
  mov ebx, outputStart
  sub eax, ebx


  %undef dipHeader
  %undef pixelData
  %undef outputBuffer
  %undef x 
  %undef y 
  %undef width
  %undef height

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