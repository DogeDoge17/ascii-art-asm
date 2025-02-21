extern _OpenClipboard@4
extern _EmptyClipboard@0
extern _GlobalAlloc@8
extern _GlobalLock@4
extern _GlobalUnlock@4
extern _SetClipboardData@8
extern _CloseClipboard@0
extern _puts

global _copyToClipboard

section .data
cantOpen db "failed to open the clipboard...", 0


section .text

_copyToClipboard:
		push 0
		call _OpenClipboard@4
		test eax, eax
		jz openFail

		ret 

openFail:
		push cantOpen
		call _puts
		add esp, 4

		ret
