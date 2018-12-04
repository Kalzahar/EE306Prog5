; ISR.asm
; Name: Kameron Davis
; UTEid: kad3346
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x4600
.ORIG x2600
	
	ST R0, SR0
	ST R1, SR1		; Save registers that will be modified
	
	LD R0, KBDR		; Put the current char in R0
	
	; Check A
	LD R1, NEGA		; -A -> R1
	ADD R1, R0, R1	; Char - A -> R1
	BRz Valid
	
	; Check C
	LD R1, NEGC		; -C -> R1
	ADD R1, R0, R1	; Char - C -> R1
	BRz Valid
	
	; Check G
	LD R1, NEGG		; -G -> R1
	ADD R1, R0, R1	; Char - G -> R1
	BRz Valid
	
	; Check U
	LD R1, NEGU		; -U -> R1
	ADD R1, R0, R1	; Char - U -> R1
	BRz Valid
	
	BRnzp Invalid
	
	Valid
	STI R0, MAILIN
	
	Invalid	
	LD R0, SR0
	LD R1, SR1		; Restore modified registers
	RTI
	
KBDR .FILL xFE02
NEGA .FILL -65
NEGC .FILL -67
NEGG .FILL -71
NEGU .FILL -85
MAILIN .FILL x4600
SR0 .BLKW 1
SR1 .BLKW 1

.END