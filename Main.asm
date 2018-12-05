; Main.asm
; Name: Kameron Davis and Albert Xia
; UTEid: kad3346 and ax463
; Continuously reads from x4600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
.ORIG x4000
; initialize the stack pointer
	
	LD R6, Stack

; set up the keyboard interrupt vector table entry

	LD R0, INTERRUPT
	STI R0, IVT

; enable keyboard interrupts
	AND R0, R0, 0
	AND R1, R1, 0
	AND R2, R2, 0
	AND R3, R3, 0
	AND R4, R4, 0			; Clear registers before loop in case the user wants to rerun the program.

	LD R0, KBENABLE			; Load into R0 the value to set bit 14 to 1
	STI R0, KBSR			; Set bit 14 of KBSR to 1

; start of actual program

loop
	LDI R0, MAILOUT			; Load in the current value at x4600
	BRz loop				; If there was nothing, check again
	STI R1, MAILOUT			; Clear the mailbox to prepare for the next character
	
	AND R3, R3, 0			; Clear R3
	ADD R3, R1, -1			; Check to see if we're in phase 1, where we are looking for the U of AUG
	BRz Utwo
	
	AND R3, R3, 0			; Clear R3
	ADD R3, R1, -2			; Check to see if we're in phase 2, where we are looking for the G of AUG
	BRz Gthree
	
	AND R3, R3, 0			; Clear R3
	ADD R3, R1, -3			; Check to see if we're in phase 3, where we're past the start codon
	BRz postStart
	
	BRnzp Aone				; If we're in phase 0, where we are looking for the A of AUG, go to Aone
	
	; R1 will be our phase counter before the start codon
	preStart
	TRAP x21				; Prints char
	AND R1, R1, 0			; Set R1 to phase 0
	BRnzp reset
	
	Aone
	LD R2, NEGA
	ADD R2, R2, R0			; Compare the current character to -A
	BRnp preStart			; If it wasn't an A, jump to the indeterminant block
	TRAP x21				; Puts char onto screen
	AND R1, R1, 0			; Clears R1
	ADD R1, R1, 1			; Set to phase 1
	BRnzp reset
	
	Utwo
	LD R2, NEGA
	ADD R2, R2, R0			; Compare the current character to -A
	BRz Aone				; If it was an A, go to Aone and reinitiate phase 1
	LD R2, NEGU				;
	ADD R2,R2,R0			; Compare to -U
	BRnp preStart			; If it wasn't U, go back to phase 0
	TRAP x21
	AND R1, R1, 0			; Clear R1 
	ADD R1, R1, 2			; R1 = 2 for the next phase if it was U
	BRnzp reset
	
	Gthree
	LD R2, NEGG
	ADD R2, R2, R0			; Compare the current character to -G
	BRnp preStart			; If it wasn't a G, start over looking for AUG
	TRAP x21
	AND R1, R1, 0
	ADD R1, R1, 3			; Go to phase 3 to denote that the start codon has been found
	LD R0, pipe
	TRAP x21
	BRnzp reset
	
	; R4 will be our phase counter for after the start codon
	postStart
	LD R2, NEGC			; R2 = -C
	ADD R2, R2, R0		; Compare the current character to -C
	BRz Cend			; If it was a C, restart
	
	LD R2, NEGU			; R2 = -U
	;AND R3, R3, 0
	ADD R2, R2, R0		; Compare the current character to -U
	BRz	endU			; If it was a U, jump to start phase 1
	
	ADD R3, R4, -1		; Check to see if we're in phase 2, where we're looking for an A or G
	BRz AGend
	
	AND R3, R3, 0		; Clear R3
	ADD R3, R4, -2		; Check to see if we're in the final phase, looking for the last A or G
	BRz Finale
	
	restartEnd
	TRAP x21
	AND R4, R0, 0		; Restart the search for the end codon
	BRnzp reset
	
	endU
	TRAP x21
	AND R4, R4, 0
	ADD R4, R4, 1		; Set the counter to phase 1
	BRnzp reset
	
	AGend
	LD R2, NEGA
	ADD R2, R2, R0		; Compare the current character to -A 
	BRz endSecond		; If it was an A, look for the last A/G
	LD R2, NEGG			; Comare the current character to -G
	ADD R2, R2, R0		
	BRz endSecond		; If it was a G, look for the last A
	BRnzp restartEnd	; If it was a U (C was caught earlier), restart the search
	
	endSecond
	ST R0, SECONDCHAR	; Store second character for final phase
	TRAP x21
	AND R4, R4, 0
	ADD R4, R4, 2		; R4 = 2, the final phase
	BRnzp reset
	
	Finale
	LD R2, NEGA
	ADD R2, R2, R0		; Comare the current character to -A
	BRz bye				; If it was an A we got UAA or UGA and we're done
	LD R5, SECONDCHAR	; If it wasn't an A but the second char was, then we must check for G for the final char as well
	LD R2, NEGA
	ADD R2, R2, R5		; Check to see if second char was A
	BRz Gend			; If it was, check for a G
	BRnzp restartEnd	; If it was neither, restart
	
	Gend
	LD R2, NEGG
	ADD R2, R2, R0		; Compare the current character to -G
	BRz bye				; If we got UAG, we're done
	
	Cend
	AND R4, R4, 0
	TRAP x21
	
	reset
	AND R0, R0, 0			; Clear R0
	STI R0, MAILOUT			; Empty the mailbox		
	BRnzp loop
	
	bye
	TRAP x21
	AND R1, R1, 0
	STI R1, MAILOUT			; Clear the mailbox to prepare for the next character
	TRAP x25
	

Stack .FILL x4000
IVT .FILL x0180
INTERRUPT .FILL x2600
KBENABLE .FILL x4000
KBSR .FILL xFE00
MAILOUT .FILL x4600
SECONDCHAR .BLKW 1
NEGA .FILL -65
NEGC .FILL -67
NEGG .FILL -71
NEGU .FILL -85
pipe .FILL 124
.END