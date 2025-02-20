section .text

global _max
global _min

_max:
  cmp eax,ebx
	jl .b
	ret
.b:
		mov eax, ebx
		ret

_min:
  cmp eax, ebx
	jg .b
	ret
.b:
		mov eax, ebx
		ret
