TITLE Program #3     (Program3.asm)

; Author: Andrea Tongsak
; Last Modified: Jan 24, 2021
; OSU email address: tongsaka@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: Program #3               Due Date: Jan 24, 2021
; Description: An data validation and arithmetic calculator for negative numbers

; Description:
	; This program will prompt the user for negative number repeatedly and display the calculations in the 

	; 1. Display user's name and program title on output screen
	; 2. Display instructions for the user
	; 3. Repeatedly prompt user to enter a number from [-100, -1]
	; 4. Get and validate user input, counting and accumulate until a non-negative number is entered
	; 5. Calculate the rounded integer average of negative numbers
	; 6. Display 
	;		a) number of negative numbers, 
	;		b) sum of negative numbers, 
	;		c) the average rounded to the nearest thousandths, 
	;		d) goodbye message with user's name


INCLUDE Irvine32.inc

UPPER_LIMIT = -1
LOWER_LIMIT = -100

.data

; Constants

	; Introduction
	intro			BYTE	"---------------------------------------------------------------------------", 13, 10,
							"   Negative Integer Calculator by Andrea Tongsak ", 13, 10,
							"---------------------------------------------------------------------------", 0

	name_ask		BYTE	"Enter your name: ", 0
	user_name		BYTE	40 DUP(0)		; DUP(0) declares an array of 40 bytes
											; each byte is initialized to 0

	welcome_msg		BYTE	"Welcome, ", 0
	welcome_msg2	BYTE	"! This is the Negative Number Calculator.", 0

	instructions	BYTE	"The program will display the amount, sum, and average of negative numbers you entered.", 13, 10,
							"Please enter numbers in [-100, -1].", 13, 10,
							"Enter a non-negative number when you are finished to see results.", 0
	
	neg_ask			BYTE	" Enter number [-100, -1]: ", 0
	range_warning	BYTE	" Warning: Number must be in the range [-100 ... -1]", 0
	special_msg		BYTE	"No negative numbers were entered!", 0

	count_msg		BYTE	"The number of valid numbers entered: ", 0
	sum_msg			BYTE	"The sum of valid numbers: ", 0
	ave_round_msg	BYTE	"The rounded average to the nearest number: -", 0
	average_msg		BYTE	"The average: -", 0
	point			BYTE	".", 0


	; Variables
	userNum			DWORD	?
	count			DWORD	?
	sum				DWORD	?
	average			DWORD	?
	fract			DWORD	?
	lineEnter		DWORD	1
	thous			DWORD	1000

	; Goodbye
	exit_msg1		BYTE	"Are you impressed? Have a good day, ", 0
	exit_msg2		BYTE	"!", 0


.code


;******************** MAIN ************************
; main
;	Calls all the arithmetic operators, introduction, and goodbye
;	Receives: N/A
;	Returns: N/A
;**************************************************
main PROC

	call	introduction
	call	getUserName
	call	displayInstructions

	call	getUserNumber
	call	performCalculation

	call	goodbye

	exit

main ENDP


; **************** INTRODUCTION *******************
; introduction
;	Displays the program's purpose to the user
;	Receives: N/A
;	Returns:  N/A
;**************************************************
introduction	PROC

	mov     edx, OFFSET intro					; Introduction
	call    WriteString
	call    CrLf
	call    CrLf
	
	ret

introduction	ENDP



; **************** getUserName ********************
; getUserName
;	Displays greeting message to the user
;	Receives: user entered name
;	Returns:  N/A
;**************************************************
getUserName	PROC

	; get user name, keep, and display back
	mov     edx, OFFSET name_ask
	call    WriteString

	mov		edx, OFFSET user_name
	mov		ecx, 40							; ecx = 1-40 non-null chars to read in
	call	ReadString

	mov		edx, OFFSET welcome_msg
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	mov		edx, OFFSET welcome_msg2
	call	WriteString

	call    CrLf
	call	CrLf
	
	ret

getUserName	ENDP



; **************** displayInstructions ************
; displayInstructions
;	displays the instructions for the user to user the program
;	Receives: N/A
;	Returns:  N/A
;**************************************************
displayInstructions		PROC
	mov		edx, OFFSET instructions
	call	WriteString
	call	CrLf
	call	CrLf

	ret

displayInstructions		ENDP



; ***************** getUserNumber *****************
; getUserNumber
;	ask user to enter negative numbers
;	Receives: user input (negative numbers)
;	Returns:  N/A
;**************************************************
getUserNumber		PROC

	GETNUM: 
		mov		eax, lineEnter
		call	WriteDec

		mov		edx, OFFSET neg_ask
		call	WriteString
		call	ReadInt

		; check whether user number is non-negative
		cmp		eax, UPPER_LIMIT
		jg		SKIP
		

	CHECKLOW:
		cmp		eax, LOWER_LIMIT
		jl		OUTOFRANGE

		; else, it's a valid number and needs to be added to the count & sum
		add		sum, eax
		inc		count
		inc		lineEnter

		; repeat
		jmp		GETNUM


	OUTOFRANGE:
		mov		edx, OFFSET range_warning
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		GETNUM


	SKIP:
		ret

getUserNumber		ENDP



;*************** performCalculation ***************
; performCalculation
;	Wishes the user a goodbye message, verified results
;
;**************************************************
performCalculation		PROC

	; display the count 
	call	CrLf
	mov		edx, OFFSET count_msg
	call	WriteString
	mov		eax, count
	call	WriteDec
	call	CrLf

	cmp		eax, 0
	je		NONEG
	jmp		SUMMING

NONEG: 
	mov		edx, OFFSET special_msg
	call	WriteString
	call	CrLF
	jmp		DONE
	
SUMMING:
	; display the sum
	mov		edx, OFFSET sum_msg
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf

	; calculate the average
	cdq
	mov		ebx, count
	idiv	ebx					; for signed numbers division
	mov		average, eax		; main quotient

	; calculate the rounding
	mov		eax, edx
	mov		ebx, 2
	mul		ebx
	cmp		eax, count			; compare the remainder with half the divisor
	jb		NOROUND
	jae		ROUNDUP

	; display the average

ROUNDUP:
	; increment the place by 1
	mov		edx, OFFSET ave_round_msg
	call	WriteString
	neg		average
	mov		eax, average
	; since it was rounded up, you need to increment it
	inc		eax
	call	WriteDec
	jmp		DONE
	

NOROUND:
	mov		edx, OFFSET average_msg
	call	WriteString
	neg		average
	mov		eax, average
	call	WriteDec

DONE:
	call	CrLf
	call	CrLf
	
	ret

performCalculation		ENDP



;*************** GOODBYE **************************
; goodbye
;	Wishes the user a goodbye message, verified results
;
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
