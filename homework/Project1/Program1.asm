TITLE Program #1	(Program1.asm)

; Author: Andrea Tongsak
; OSU email address: atongsak@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: Program #1
; Due Date: Jan 15, 2020

; Description:
	; This program will prompt the user for two positive integers, and perform math operations
	; on the stored variables. 

	; 1. Display name and program title on output screen
	; 2. Display instructions for the user
	; 3. Prompt user to enter two numbers
	; 4. Calculate sum difference, product, quotient & remainder
	; 5. Goodbye message.

INCLUDE Irvine32.inc

.data

; Constants

	; Introduction
	intro			BYTE	"---------------------------------------------------------------------------", 13, 10,
					"   Elementary Arithmetic by Andrea Tongsak ", 13, 10,
					"---------------------------------------------------------------------------", 0

	extra_credit	BYTE	"**EC1: Program verifies second number is less than first.", 13, 10,
				"**EC2: Display the square of each number.", 0

	instructions	BYTE	"Enter two numbers, and I'll show the sum, difference, product, quotient, and remainder.", 13, 10,
				"Warning: the first number MUST be greater than the second. (ie. 10, 5)", 0
	
	userInput_1		BYTE	"First number: ", 0
	userInput_2		BYTE	"Second number: ", 0
	size_warning		BYTE	" Warning: Second number must be smaller than the first.", 13, 10,
					" Re-enter second number.", 0
	undefined_msg		BYTE	"UNDEFINED", 0
	square_msg		BYTE	"Square of ", 0

	; Arithmetic
	equal			BYTE	" = ", 0
	plus			BYTE	" + ", 0
	minus			BYTE	" - ", 0
	times			BYTE	" x ", 0
	divided			BYTE	" / ", 0
	remainder		BYTE	" remainder ", 0
	operatorpm		BYTE	" ", 0

	; Variables
	userNum_1		DWORD	?
	userNum_2		DWORD	?
	result			DWORD	?
	quotient		DWORD	?
	remain			DWORD	?

	; Goodbye
	exitMsg			BYTE	"Are you impressed? Have a good day!"


.code



; **************** INTRODUCTION *******************
;
; introduction
;	Displays greeting message to the user
;	Receives: N/A
;	Returns:  N/A
;**************************************************
introduction	PROC

	mov     edx, OFFSET intro					; Introduction
	call    WriteString
	call    CrLf
	call    CrLf

	mov	edx, OFFSET extra_credit			; Extra Credit 1 and 2
	call	WriteString
	call	CrLf
	call	CrLf

	mov	edx, OFFSET instructions			; Instructions
	call	WriteString
	call	CrLf
	call	CrLf

	ret

introduction	ENDP



; **************** getUserData *******************
;
; getUserData
;	Takes user data as input
;	Receives: user input
;	Returns:  N/A
;**************************************************
getUserData		PROC

	inputNum1:
		mov		edx, OFFSET userInput_1
		call		WriteString
		call		ReadInt
		mov		userNum_1, eax
		jmp		inputNum2

	inputNum2:
		mov		edx, OFFSET userInput_2
		call		WriteString
		call		ReadInt
		mov		userNum_2, eax
		cmp		userNum_1, eax
		jl		reaskSecond
		jmp		skip1

	reaskSecond:								; Extra Credit 1: Will reask if the value is larger than first
		mov		edx, OFFSET size_warning
		call		WriteString
		call		CrLf
		jmp		inputNum2

	skip1:
		ret

getUserData ENDP



;*********** SHOW CALCULATION *************
; showCalculation
;	Displays the calculations of the numbers. This is the "template" for most of the basic calculations, save square and division
;	Receives: userNum_1, userNum_2
;	Returns: sum, difference, product, quotient and remainder
;**************************************************

showCalculation PROC

	; write out numbers

	A1:
		mov		eax, userNum_1
		call		WriteDec

	A2:
		mov		al, cl
		cmp		al, 1
		je		printPlus
		
		cmp		al, 2
		je		printMinus
		
		cmp		al, 3
		je		printTimes

		cmp		al, 4
		je		printDivision

		jmp		skipC
		
	printPlus:								; Addition version
		mov		edx, OFFSET plus
		call		WriteString
		jmp		A3
			
	printMinus:								; Subtraction version
		mov		edx, OFFSET minus
		call		WriteString
		jmp		A3

	printTimes:								; Multiplication version
		mov		edx, OFFSET times
		call		WriteString
		jmp		A3

	printDivision:							; Division version
		mov		edx, OFFSET divided
		call		WriteString
		jmp		A4

	A3:
		mov		eax, userNum_2
		call		WriteDec
		
		mov		edx, OFFSET equal
		call		WriteString

		mov		eax, result
		call		WriteDec

		jmp		skipC

	A4:										;  Division needs to have both quotient and remainder
		mov		eax, userNum_2
		call		WriteDec

		mov		edx, OFFSET equal
		call		WriteString

		mov		eax, quotient
		call		WriteDec

		mov		edx, OFFSET remainder
		call		WriteString

		mov		eax, remain
		call		WriteDec

	skipC:

		call	CrLf

		ret

showCalculation ENDP



;*********** SHOW ADDITION CALCULATION *************
; showAddition
;	Displays the sum of the numbers
;	Recieves: N/A
;	Returns: calculation of addition
;**************************************************
showAddition PROC

	; do addition
		mov		cl, 1
		mov		eax, userNum_1
		mov		ebx, userNum_2
		add		eax, ebx
		mov		result, eax
		
		call	showCalculation

		ret

showAddition ENDP



;*********** SHOW SUBTRACTION CALCULATION *************
; showSubtraction
;	Displays the difference of the numbers
;	Receives: N/A
;	Returns: the subtracted value
;**************************************************
showSubtraction PROC

	; do subtraction
		mov		cl, 2
		mov		eax, userNum_1
		mov		ebx, userNum_2
		sub		eax, ebx
		mov		result, eax
		
		call	showCalculation

		ret

showSubtraction ENDP



;*********** SHOW MULTIPLICATION CALCULATION *************
; showMultiplication
;	Displays the product of the numbers
;	Receives: N/A
;	Returns: multiplied values!
;**************************************************
showMultiplication PROC

	; do times
		mov		cl, 3
		mov		eax, userNum_1
		mov		ebx, userNum_2
		mul		ebx
		mov		result, eax
		
		call	showCalculation

		ret

showMultiplication ENDP



;*********** SHOW DIVISION CALCULATION *************
; showDivision
;	Displays the quotient and remainder of the numbers
;	Receives: N/A
;	Returns: the division result & remainder
;**************************************************
showDivision PROC

	; check if num 2 zero
		mov		eax, userNum_2
		cmp		eax, 0
		je		D1
		
	; check if num 1 is zero
		mov		eax, userNum_1
		cmp		eax, 0
		je		D2

	; do division
		mov		cl, 4
		mov		eax, userNum_1
		mov		ebx, userNum_2
		cdq								; convert doubleword to quadword
		idiv	ebx
		mov		quotient, eax
		mov		remain, edx

		call	showCalculation
		jmp		skipDiv

	D1:									; if the second value is zero, then UNDEFINED
		mov		eax, userNum_1
		call	WriteDec

		mov		edx, OFFSET divided
		call	WriteString

		mov		eax, userNum_2
		call	WriteDec

		mov		edx, OFFSET equal
		call	WriteString

		mov		edx, OFFSET undefined_msg
		call	WriteString
		call	CrLf
		jmp		skipDiv

	D2:									; if the first number is 0, then the value is 0.
		mov		quotient, 0
		mov		remain, 0
		jmp		skipDiv
		
	skipDiv:
		ret

showDivision ENDP



;*********** SHOW SQUARES CALCULATION *************
; showSquares
;	Displays the quotient and remainder of the numbers
;	Receives: userNum_1, userNum_2
;	Returns: Square of 1, 2
;**************************************************
showSquares PROC
	
	; FIRST VALUE
	
	mov		edx, OFFSET square_msg
	call	WriteString

	mov		eax, userNum_1
	call	WriteDec

	mov		edx, OFFSET equal
	call	WriteString

	mov		ebx, eax
	mul		ebx
	call	WriteDec

	call	CrLf

	; SECOND VALUE

	mov		edx, OFFSET square_msg
	call	WriteString

	mov		eax, userNum_2
	call	WriteDec

	mov		edx, OFFSET equal
	call	WriteString

	mov		ebx, eax
	mul		ebx
	call	WriteDec

	call	CrLf

	ret

showSquares	ENDP



;*********** TERMINATING *************
; terminate
;	Wishes the user a goodbye message, verified results
;	Recieves:
;
;**************************************************
terminate PROC
	call	CrLf
	mov		edx, OFFSET exitMsg
	call	WriteString
	call	CrLf
	
	ret

terminate ENDP



;*********** MAIN *************
; main
;	Calls all the arithmetic operators, introduction, and goodbye
;	Receives: N/A
;	Returns: N/A
;**************************************************
main PROC

	call	introduction
	call    getUserData
	call	showAddition
	call	showSubtraction
	call	showMultiplication
	call	showDivision
	call	showSquares

	call	terminate

	exit

main ENDP 

END main
