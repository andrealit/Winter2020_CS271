TITLE Program #4	(Program4.asm)

; Author: Andrea Tongsak
; Last Modified: Feb 1, 2021
; OSU email address: tongsaka@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: Program #4               Due Date: Feb 14, 2021
; Description: A program to calculate composite numbers from a user-inputed range

; This program will...
; 1. Display the programmer's name and display instructions
; 2. Ask user to enter the number of composite numbers they want [1, 300]
; 3. Verify user input and reprompt if need be
; 4. Calculate the composite
; 5. Display the composite numbers, 10 per line and at least 3 spaces in between

INCLUDE Irvine32.inc

; Constants

UPPER_LIMIT = 300
LOWER_LIMIT = 1

.data

	; Introduction
	intro			BYTE	"---------------------------------------------------------------------------", 13, 10,
							"   Composite Calculator by Andrea Tongsak ", 13, 10,
							"---------------------------------------------------------------------------", 0

	extra_credit	BYTE	"**EC: Give users option to display only ODD composite numbers.", 0

	name_ask		BYTE	"Enter your name: ", 0
	user_name		BYTE	40 DUP(0)		; DUP(0) declares an array of 40 bytes
											; each byte is initialized to 0

	welcome_msg		BYTE	"Welcome, ", 0
	welcome_msg2	BYTE	"! This is the Composite Number Calculator.", 0

	instructions	BYTE	"The program will generate a list of composite values.", 13, 10,
							"Simply let me know how many you'd like to see.", 13, 10,
							"I'll accept orders for up to 300 composites.", 0
	
	odd_ask			BYTE	" Select [0] to view all composites, [1] to view only odd composites: ", 0
	odd_warning		BYTE	" Warning: Number must be either [0, 1]", 0
	number_ask		BYTE	" How many composites do you want to view? [1, 300]: ", 0
	range_warning	BYTE	" Warning: Number must be in the range [1, 300]", 0

	; Variables
	number_Comp		DWORD	?			; how many composites need to be printed
	oddChoice		DWORD	?			; whether we're printing all (0) or just odds (1)
	countFactors	DWORD	?			; counter to track how many factors 


	numPrinted		DWORD	0
	
	numerator		DWORD	1
	divisor			DWORD	?

	perLine			DWORD	0			; stores the number of composites per line
	space			BYTE	"    ", 0


	; Goodbye
	exit_msg1		BYTE	"Are you impressed? Have a good day, ", 0
	exit_msg2		BYTE	"!", 0

.code


;******************** MAIN ************************
; main
;	Calls all the introduction, gets user data, prints composite numbers, and goodbye
;	Receives: N/A
;	Returns: N/A
;	Preconditions: N/A
;	Postconditions: The program prints out all instructions, gets user input, and prints composites
;	Registers Changed: EAX, EBX, ECX, EDX
;**************************************************
main PROC

	call	introduction

	call	getUserData

	call	showComposites

	call	goodbye

	exit

main ENDP


; **************** INTRODUCTION *******************
; introduction
;	Displays the program's purpose to the user, and displays instructions
;	Receives: N/A
;	Returns: N/A
;	Preconditions: N/A
;	Postconditions: The program message is printed out
;	Registers Changed: EDX
;**************************************************
introduction	PROC

	mov     edx, OFFSET intro					; Introduction
	call    WriteString
	call    CrLf
	call    CrLf

	mov		edx, OFFSET instructions
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET extra_credit
	call	WriteString
	call	CrLf
	call	CrLf
	
	ret

introduction	ENDP



; ***************** getUserData *****************
; getUserData
;	ask user for their name and displays hello
;	Receives: user input
;	Returns:  N/A
;	Preconditions: N/A
;	Postconditions: The user name is entered and welcomed, other data is stored
;	Registers Changed: EDX, ECX
;**************************************************
getUserData		PROC

	; get user name, keep, and display back
	mov     edx, OFFSET name_ask
	call    WriteString

	mov		edx, OFFSET user_name
	mov		ecx, 40							; ecx = 1-40 non-null chars to read in
	call	ReadString

	; welcome message with name
	mov		edx, OFFSET welcome_msg
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	mov		edx, OFFSET welcome_msg2
	call	WriteString

	call    CrLf
	call	CrLf

	call	validate

	ret

getUserData		ENDP



;*************** VALIDATE *************************
; validate
;	Takes in user-inputed values, and check if in range
;	Returns: N/A
;	Receives: user-input number
;	Preconditions: N/A
;	Postconditions: the odd choice is validated, the number of composites is validated
;	Registers Changed: EDX, ECX
;**************************************************
validate		PROC

	; EXTRA CREDIT: ask for 0 or 1, whether to show all or just odds
	askOdd:
		mov		edx, OFFSET odd_ask
		call	WriteString
		call	ReadDec
		mov		oddChoice, eax

		; check that the input is either 0 or 1
		mov		ecx, oddChoice
		cmp		ecx, 0
		jl		askOddAgain
		cmp		ecx, 1
		jg		askOddAgain
		jmp		checkInput

	askOddAgain:
		mov		edx, OFFSET odd_warning
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		askOdd


	; ask for user inputted number of composites [1, 300]
	checkInput:
		mov		edx, OFFSET number_ask
		call	WriteString
		call	ReadDec
		mov		number_Comp, eax

		; check that the number is in range using a post-test loop
		mov		ecx, number_Comp
		cmp		ecx, UPPER_LIMIT
		jg		repeatAsk
		cmp		ecx, LOWER_LIMIT
		jl		repeatAsk
		jmp		skip1

	; repeat the ask with a warning if out of range.
	repeatAsk: 
		mov		edx, OFFSET range_warning
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		checkInput


	skip1:
		ret


validate		ENDP



;*************** SHOWCOMPOSITES *******************
; showComposites
;	Takes in user-inputed values, and check if in range
;	Returns: N/A
;	Receives: user-input number
;	Preconditions: the user-entered number(s) is stored and validated
;	Postconditions: all composite numbers are printed out
;	Registers Changed: EAX, EBX, EDX
;**************************************************
showComposites		PROC

	; using a while loop to print out composite numbers
	L1:
		mov		eax, numPrinted			; check if number of printed composites is correct, will continue until numPrinted = number_Comp
		cmp		eax, number_Comp	
		jge		printDone				; if equal or over limit, then done
		mov		countFactors, 0			; else, reset the factors
		mov		divisor, 1				; reset the divisor to 1
		call	isComposite				; check for composites by dividing

	factorCheck:
		mov		eax, countFactors
		cmp		eax, 2					; if the number of factors is less than or equal to two (1 and itself)
		jle		outerRepeat				; not a composite, so check the next number

		; check whether we are only printing odd numbers
		mov		eax, oddChoice			; check whether we only want odd composites
		cmp		eax, 1
		je		checkOdd				; if 1 flag, then check whether it's odd
		jmp		printNum				; else, just print as normal

	checkOdd:
		mov		eax, numerator
		mov		ebx, 2
		mov		edx, 0					; clear edx
		div		ebx
		cmp		edx, 0
		jne		printNum				; if the remainder is not 0, then it is odd
		jmp		outerRepeat				; else, it is even and DO NOT PRINT. increment the numerator and continue loop
				
	printNum:
		mov		eax, numerator			
		call	WriteDec				; else it is a composite number, so print the value

	TAB1:
		mov		edx, OFFSET space
		call	WriteString
		call	WriteString

	contPrint:
		inc		numPrinted				; update print count

		inc		perLine
		mov		eax, perLine
		cmp		eax, 10					; ensure that 10 per line is printed
		jl		outerRepeat
		call	CrLf					; if equals 10, create a new line
		mov		perLine, 0


	outerRepeat:						; go to the next number to be checked as composite
		inc		numerator
		jmp		L1

	printDone:
		ret


showComposites		ENDP



;*************** ISCOMPOSITE **********************
; isComposite
;	Reads in the number and checks whether the number to be printed is composite
;	Returns: Check if numberator is composite
;	Receives: user-entered number and numerator
;	Preconditions: The numerator is initialized to a value
;	Postconditions: The numerator is determined to be either composite or not
;	Registers Changed: ECX, EAX, EBX, EDX
;**************************************************
isComposite		PROC

	; inner counter loop for numerator (check if composite)
	mov		ecx, numerator		; repeat the loop for how large the "numerator" number we are checking is
								; ex: 5 will check whether factors 1, 2, 3, 4, 5 are divisible

	L2:
		mov		eax, numerator
		mov		ebx, divisor
		mov		edx, 0			; clear the edx
		div		ebx
		cmp		edx, 0			; compare the remainder with 0
		jne		remNotZero		; if not equal, then it is not a factor. increment the divisor
		inc		countFactors	; else, increase the count of factors
	
	remNotZero:
		inc		divisor			; increase divisor by one (1, 2, 3...)
		loop	L2

		ret

isComposite		ENDP



;*************** GOODBYE **************************
; goodbye
;	Wishes the user a goodbye message, verify results
;	Returns: N/A
;	Receives: N/A
;	Preconditions: there are variables for exit message and user name is stored
;	Postconditions: the goodbye is printed
;	Registers Changed: N/A
;**************************************************
goodbye		PROC
	call	CrLf
	mov		edx, OFFSET exit_msg1
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	mov		edx, OFFSET exit_msg2
	call	WriteString

	call	CrLf
	
	ret

goodbye		ENDP



END main
