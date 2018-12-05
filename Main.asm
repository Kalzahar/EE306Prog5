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
	loop
	LD R0, KBENABLE		; Load into R0 the value to set bit 14 to 1
	STI R0, KBSR		; Set bit 14 of KBSR to 1

; start of actual program

	LD R0, MAILOUT		; Load char into R0
	LDR R0,R0,0
	AND R3,R3,0			; Clear R3
	LD R2,NEGA			; R2 -->-65
	ADD R2,R2,R0		;Check to see if there is a character in x4600
	BRn loop
	BRz Aone
	ADD R3,R1,-1		;Check to see if char is in second phase
	BRz Utwo
	AND R3,R3,0			;Clear R3
	ADD R3,R1,-2		; Check to see if char is in final phase
	BRz Gthree
	
	noOrder
	TRAP x21			;Prints char
	AND R1,R1,0			; Make sure R1 is set to phase 0
	BRnzp reset
	
	Aone
	TRAP x21			; Puts char onto screen
	AND R1,R1,0			; Clears R1
	ADD R1,R1,1			; Allows us to know that it is in the second phase
	BRnzp reset
	
	Utwo
	LD R2,NEGU
	ADD R2,R2,R0		;Check to see if the next char is a U 
	BRnp noOrder
	TRAP x21
	AND R1,R1,0			; Sets R1 to zero 
	ADD R1,R1,2			; R1 should be 2 setting it into the next phase
	BRnzp reset
	
	Gthree
	LD R2,NEGG
	Add R2,R2,R0		; Check to see if next char is a G 
	BRnp noOrder
	TRAP x21
	AND R1,R1,0
	LD R0,pipe
	TRAP x21
	
	reset
	AND R0,R0,0			; Clear R0
	STI R0,MAILOUT		
	BRnzp loop
	

Stack .FILL x4000
IVT .FILL x0180
INTERRUPT .FILL x2600
KBENABLE .FILL x4000
KBSR .FILL xFE00
MAILOUT .FILL x4600
NEGA .FILL -65
NEGC .FILL -67
NEGG .FILL -71
NEGU .FILL -85
pipe .FILL 124
.END