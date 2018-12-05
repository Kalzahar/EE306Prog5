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
	loop
	LD R0, INTERRUPT
	STI R0, IVT

; enable keyboard interrupts
	
	LD R0, KBENABLE		; Load into R0 the value to set bit 14 to 1
	STI R0, KBSR		; Set bit 14 of KBSR to 1

; start of actual program

	LD R0, MAILOUT		; Load char into R0
	LDR R0,R0,0
	LD R2,NEGA			; R2 -->-65
	ADD R2,R2,R0		;Check to see if there is a character in x4600
	BRzp prchar
	BRnzp loop
	prchar
	TRAP x21			; Puts char onto screen
	AND R0,R0,0			; Clear R0
	ST R0,MAILOUT		
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
.END