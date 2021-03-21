TITLE Program #2	(Program2.asm)

; Author: Andrea Tongsak
; OSU email address: tongsaka@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: Program #2
; Due Date: Jan 24, 2020

; Description:
	; This program will prompt the user for a number input in a range and display that number of Fibonnaci numbers

	; 1. Display user's name and program title on output screen
	; 2. Display instructions for the user
	; 3. Prompt user to enter a number from 1-46
	; 4. Get and validate user input
	; 5. Print out that number of Fibonnaci numbers
	; 6. Goodbye message

INCLUDE Irvine32.inc

FIB_MAX = 46
MIN = 1

.data

; Constants

	; Introduction
	intro			BYTE	"---------------------------------------------------------------------------", 13, 10,
							"   Fibonnaci Numbers by Andrea Tongsak ", 13, 10,
							"---------------------------------------------------------------------------", 0

	extra_credit	BYTE	"**EC1: Fibonnaci numbers are displayed in columns.", 0

	name_ask		BYTE	"Enter your name: ", 0
	user_name		BYTE	40 DUP(0)		; DUP(0) declares an array of 40 bytes
											; each byte is initialized to 0

	welcome_msg		BYTE	"Welcome, ", 0
	welcome_msg2	BYTE	"! This is the Fibonnaci Program.", 0

	instructions	BYTE	"The program will display the number of Fibonnaci terms you wish to see.", 13, 10,
							"It will require your name and a number you input between [1-46].", 0
	
	fib_ask			BYTE	"Enter the number of Fibonnaci terms you want [1-46]: ", 0
	range_warning	BYTE	" Warning: Number must be in the range [1 ... 46]", 0

	; Variables
	name_entered	BYTE	?
	number_Fib		DWORD	?
	count			DWORD	?
	fibTerm1		DWORD	1
	fibTerm2		DWORD	1

	; Goodbye
	exit_msg		BYTE	"Are you impressed? Have a good day!", 0


.code



; **************** INTRODUCTION *******************
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

	mov		edx, OFFSET extra_credit			; Extra Credit 1 and 2
	call	WriteString
	call	CrLf
	call	CrLf
	
	ret

introduction	ENDP



; **************** displayInstructions *******************
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



; **************** getUserInfo *******************
; getUserInfo
;	Takes user data as input and validates the number using a post-test loop
;	Receives: user input
;	Returns:  N/A
;**************************************************
getUserInfo		PROC

	; Ask for user name
	mov		edx, OFFSET name_ask					
	call	WriteString

	mov		edx, OFFSET user_name
	mov		ecx, 41
	call	ReadString

	; Print out user name
	mov		edx, OFFSET welcome_msg					
	call	WriteString
	mov		edx, OFFSET user_name
	call	WriteString
	mov		edx, OFFSET welcome_msg2
	call	WriteString

	call	CrLf
	call	CrLf

	CHECKINPUT:
		mov		edx, OFFSET fib_ask
		call	WriteString
		call	ReadInt
		mov		number_Fib, eax

	; check that the user num is within the limits using a post test loop
		mov		ecx, number_Fib
		cmp		ecx, FIB_MAX
		jg		REPEATASK
		cmp		ecx, MIN
		jl		REPEATASK
		jmp		skip1

	; echo the out of range warning to the user, then will loop back to reask
	REPEATASK:
		mov		edx, OFFSET range_warning
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		CHECKINPUT


	skip1:
		ret

getUserInfo ENDP



;*********** displayFibs *************
; displayFibs
;	calculate and display the Fibonnaci sequence using the counted loop
;	Receives: N/A
;	Returns: N/A
;**************************************************
displayFibs		PROC

	; set up loop counter
		mov		ecx, number_Fib	
		mov		count, 0

	; start the calculation
	FIBSTART:
		mov		eax, fibTerm1
		call	WriteDec
		cmp		fibTerm1, 999999999
		jbe		TAB2
		ja		TAB1

	; EXTRACREDIT: 9 is the ascii code for tabs
	TAB1:
		mov		al, 9
		call	WriteChar
		jmp		FIBPROGRESS

	TAB2:
		mov		al, 9
		call	WriteChar
		call	WriteChar

	; this will replace the first with the second, then sum fibNum1+fibNum2
	FIBPROGRESS:
		mov		eax, fibTerm1
		mov		ebx, fibTerm2
		mov		fibTerm1, ebx
		add		eax, fibTerm1
		mov		fibTerm2, eax
		inc		count

		; check for next line
		mov		edx, count
		cmp		edx, 5
		je		NEWLINE

	; the MASM loop instruction is used, sees if ecx is 0
	CONTINUE:
		loop	FIBSTART	
		jmp		ENDFIB

	NEWLINE:
		call	CrLF
		mov		count,0
		jmp		CONTINUE

	ENDFIB:
		call	CrLf
		call	CrLf

		ret

displayFibs		ENDP


;*********** GOODBYE **************************
; goodbye
;	Wishes the user a goodbye message, verified results
;
;**************************************************
goodbye		PROC
	call	CrLf
	mov		edx, OFFSET exit_msg
	call	WriteString
	call	CrLf
	
	ret

goodbye		ENDP


;*********** MAIN *************
; main
;	Calls all the arithmetic operators, introduction, and goodbye
;	Receives: N/A
;	Returns: N/A
;**************************************************
main		PROC

	call	introduction
	call	displayInstructions
	call	getUserInfo
	call	displayFibs

	call	goodbye

	exit

main ENDP 

END main
