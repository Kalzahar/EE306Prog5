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
	AND R0,R0,0
	AND R1,R1,0
	AND R2,R2,0
	AND R3,R3,0
	AND R4,R4,0			; Clear registers before loop in case the user wants to re run the program.
	
	LD R0, KBENABLE		; Load into R0 the value to set bit 14 to 1
	STI R0, KBSR		; Set bit 14 of KBSR to 1

; start of actual program
loop
	LDI R0, MAILOUT		; Load in the current value at x4600
	BRz loop			; If there was nothing, check again
	
	AND R3, R3, 0		; Clear R3
	ADD R3,R1,-1		; Check to see if char is in second phase
	BRz Utwo
	AND R3,R3,0			; Clear R3
	ADD R3,R1,-2		; Check to see if char is in final phase
	BRz Gthree
	ADD R3,R1,-3		; Check to see if char is inside the Start codon
	BRz insideStart
	ADD R2,R2,0			; If the current character was actually an A and we aren't in a different phase, go to Aone
	BRz Aone
	; R1 will be our phase counter before the start codon
	noOrder
	TRAP x21			; Prints char
	AND R1,R1,0			; Make sure R1 is set to phase 0
	BRnzp reset
	
	Aone
	TRAP x21			; Puts char onto screen
	AND R1,R1,0			; Clears R1
	ADD R1,R1,1			; Allows us to know that it is in the second phase
	BRnzp reset
	
	Utwo
	LD R2,NEGA
	ADD R2,R2,R0
	BRz Aone
	LD R2,NEGU
	ADD R2,R2,R0		; Check to see if the next char is a U 
	BRnp noOrder
	TRAP x21
	AND R1,R1,0			; Sets R1 to zero 
	ADD R1,R1,2			; R1 should be 2 setting it into the next phase
	BRnzp reset
	
	Gthree
	LD R2,NEGG
	ADD R2,R2,R0		; Check to see if next char is a G 
	BRnp noOrder
	TRAP x21
	AND R1,R1,0
	ADD R1,R1,3			; Tells PC we are in the inside phase
	LD R0,pipe
	TRAP x21
	BRnzp reset
	; R4 will be our phase counter for the codons inside the start codon
	insideStart
	LD R2,NEGU
	AND R3,R3,0
	ADD R2,R2,R0
	BRz	Uend
	ADD R3,R4,-1		; Check to see if char is in second phase
	BRz AGend
	AND R3,R3,0			; Clear R3
	ADD R3,R4,-2		; Check to see if char is in final phase
	BRz Finale
	
	RandomJunk
	TRAP x21
	AND R4,R0,0			; Make sure to stay in initial phase
	BRnzp reset
	
	Uend
	TRAP x21
	AND R4,R4,0
	ADD R4,R4,1			; Moves to phase 1
	BRnzp reset
	
	AGend
	LD R2,NEGA
	ADD R2,R2,R0		; Check to see if R0 is A 
	BRz GAend
	LD R2,NEGG			; Check to see if R0 is G 
	ADD R2,R2,R0		
	BRz GAend
	BRnzp RandomJunk
	
	GAend
	ST R0,SECONDCHAR	; Store second character for final phase
	TRAP x21
	AND R4,R4,0
	ADD R4,R4,2			; Moves R4 to the final phase
	BRnzp reset
	
	Finale
	LD R2,NEGA
	ADD R2,R2,R0
	BRz bye
	LD R5,SECONDCHAR	; If the second char was an A then we must check for G for the final char as well
	LD R2,NEGA
	ADD R2,R2,R5		;Check to see if second char was ADD
	BRz Gend
	BRnzp RandomJunk
	
	Gend
	LD R2,NEGG
	ADD R2,R2,R0
	BRz bye
	
	reset
	AND R0,R0,0			; Clear R0
	STI R0,MAILOUT		
	BRnzp loop
	
	bye
	TRAP x21
	AND R0, R0, 0
	STI R0, MAILOUT		; Clear the mailbox to prepare for a reload
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