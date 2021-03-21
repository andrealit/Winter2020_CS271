TITLE Program #5	(Program5.asm)

; Author: Andrea Tongsak
; Last Modified: Feb 19, 2021
; OSU email address: tongsaka@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: Program #5               Due Date: Feb 14, 2021
; Description: A program to show both an unsorted and sorted list of integers

; This program will...
; 1. Display the programmer's name and display instructions
; 2. Ask user to enter the number of numbers they want [15, 200]
; 3. Verify user input and reprompt if need be
; 4. Generate random numbers in the range [100, 999]
; 5. Display the random numbers, 10 per line BEFORE SORTING
; 6. Display the random numbers, 10 per line AFTER SORTING

INCLUDE Irvine32.inc

; Constants

MAX = 200
MIN = 15
LO = 100
HI = 999


.data

	; PROCEDURES CANNOT REFERENCE .DATA SEGMENT VARIABLES BY NAME
	; INSTEAD, USE THEM AS PARAMETERS
	; GLOBAL CONSTANTS OK
	; LOCAL VARIABLES OK

	; Introduction
	intro			BYTE	"---------------------------------------------------------------------------", 13, 10,
							"   Composite Calculator by Andrea Tongsak ", 13, 10,
							"---------------------------------------------------------------------------", 0

	name_ask		BYTE	"Enter your name: ", 0
	user_name		BYTE	40 DUP(0)		; DUP(0) declares an array of 40 bytes
											; each byte is initialized to 0

	welcome_msg		BYTE	"Welcome, ", 0
	welcome_msg2	BYTE	"! This is the Sorting Random Integers Calculator.", 0

	instructions	BYTE	"The program will sort a generated list of values [100 ... 999] in descending order,", 13, 10,
							"display the numbers 10 per line, and calculate the median value rounded to the nearest integer.", 0
	
	number_ask		BYTE	" How many random numbers do you want to view? [15 ... 200]: ", 0
	range_warning	BYTE	" Warning: User input must be in the range [15 ... 200]", 0


	label_sort		BYTE	" SORTED LIST: ", 0
	label_unsorted	BYTE	" UNSORTED LIST: ", 0
	label_median	BYTE	" The median is: ", 0

	; Variables
	number_Print	DWORD	?			; how many numbers need to be printed

	userInput		DWORD	?			; store user numbers

	numPrinted		DWORD	0

	perLine			DWORD	0			; stores the number of composites per line
	space			BYTE	"    ", 0

	; declares an uninitialized array named list with space
	list			DWORD	MAX		DUP(?)

	; Goodbye
	exit_msg1		BYTE	"Are you impressed? Have a good day, ", 0
	exit_msg2		BYTE	"!", 0

.code


;******************** MAIN ************************
; main
;	Calls all the arithmetic operators, introduction, and goodbye
;	Receives: N/A
;	Returns: N/A
;	Preconditions: N/A 
;	Postconditions: The program prints out all instructions, gets user input, prints unsorted list, median, and sorted
;	Registers Changed: 
;**************************************************
main PROC

	call	introduction

	call	getData

	; ---------------------------------
	; ----- fillArray procedure -------
	; ---------------------------------

	push	OFFSET list
									; [ESP + 8]
	push	userInput
									; [ESP + 4]
	call	fillArray				
									; [ESP]

	; ---------------------------------
	; ----- displayList procedure -----
	; ---------------------------------

	push	OFFSET list
									; [ESP + 12]
	push	userInput
									; [ESP + 8]
	push	OFFSET label_unsorted
									; [ESP + 4]
	call	displayList
									; [ESP]
	
	; ---------------------------------
	; ----- sortList procedure -----
	; ---------------------------------
	push	OFFSET list
									; [ESP + 8]
	push	userInput
									; [ESP + 4]
	call	sortList
									; [ESP]


	; ---------------------------------
	; ----- displayMedian procedure -----
	; ---------------------------------

	push	OFFSET list
									; [ESP + 12]
	push	userInput
									; [ESP + 8]
	push	OFFSET label_median
									; [ESP + 4]
	call	displayMedian
									; [ESP]


	; ---------------------------------
	; ----- displayList procedure -----
	; ---------------------------------
	push	OFFSET list
									; [ESP + 12]
	push	userInput
									; [ESP + 8]
	push	OFFSET label_sort
									; [ESP + 4]
	call	displayList
									; [ESP]

	
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

	ret

introduction	ENDP



; ***************** getData *****************
; getData
;	use request reference stack to retrieve data from the user
;	Receives: user input
;	Returns:  N/A
;	Preconditions: 
;	Postconditions: 
;	Registers Changed: EDX, ECX
;**************************************************
getData		PROC

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

getData		ENDP


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

	; ask for user inputted number [15, 200]
	CHECKINPUT:
		mov		edx, OFFSET number_ask
		call	WriteString
		call	ReadDec
		mov		[ebx], eax					; store the user input in an address at ebx
		mov		userInput, eax

		; check that the number is in range, using a post test loop
		mov		ecx, userInput
		cmp		ecx, MAX
		jg		REPEATASK
		cmp		ecx, MIN
		jl		REPEATASK
		jmp		skip1

	; repeat the ask with a warning if out of range.
	REPEATASK: 
		mov		edx, OFFSET range_warning
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		CHECKINPUT

	skip1:
		ret

validate		ENDP


; ***************** fillArray *****************
; fillArray
;	procedure to get random values into the array
;	Receives: address of the array (reference), request (value) 
;	Returns: array with random numbers
;	Preconditions: the array is unfilled
;	Postconditions: the array is filled with random numbers, unsorted
;	Registers Changed: eax, ebx, ecx, edi
;**************************************************
fillArray		PROC

	; initialize the values of the stack with edi
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp + 12]		; @array in edi
	mov		ecx, [ebp + 8]		; count in ecx

	call	Randomize

; populate the array of the stack with random numbers
getRandom:
	mov		eax, HI				
	sub		eax, LO				; take the difference + 1 to get a range
	inc		eax
	call	RandomRange
	add		eax, LO				; now, the eax is going to store a random number in the range

	mov		[edi], eax
	add		edi, 4

	loop	getRandom			; continue filling the array with random numbers
	
	pop		ebp
	ret		8

fillArray		ENDP



;*************** SORTLIST **************************
; sortList
;	Sorts the list in descending order (high to low)
;	Returns: sorted list
;	Receives: array of list (reference), user request (value)
;	Preconditions: there are values of the array that are not sorted
;	Postconditions: the array is sorted
;	Registers Changed: eax, ebx, edx, ecx, edp, edi
;**************************************************
sortList	PROC

	; set up the address of the array
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]			; the request is stored in ecx

	dec		ecx						; ecx = request - 1 (so our counter is correct)

	; for(k = 0; j < request - 1; k++)
outerLoop:
	push	ecx						; save outer loop count in stack
	mov		edi, [ebp+12]			; @list

	; for(j = k+1; j < request; j++)
innerLoop:
	mov		eax, [edi]				; first element in array
	cmp		[edi+4], eax			; next value in array
	jl		repeatInner
	
	xchg	eax, [edi+4]			; exchange elements
	mov		[edi], eax

repeatInner:
	add		edi, 4					; allow esi to move to the next element
	loop	innerLoop

	; outer loop return
	pop		ecx						; restore count for the loop
	loop	outerLoop

	pop		ebp
	ret		8

sortList	ENDP



;*************** DISPLAYMEDIAN **************************
; displayMedian
;	Calculate and find the median of the sorted list
;	Returns: a median
;	Receives: array (reference), request (value)
;	Preconditions: the median isn't found
;	Postconditions: the median is found
;	Registers Changed: EBP, ESP, EDX, EDI, EAX
;**************************************************
displayMedian	PROC
	push	ebp
	mov		ebp, esp

	; display the median
	mov		edx, [ebp + 8]
	call	WriteString

	mov		edi, [ebp + 16]		; @list
	mov		eax, [ebp + 12]		; value of userInput
	mov		ebx, 2
	mov		edx, 0
	div		ebx
	cmp		edx, 0
	je		evenNumber
	jne		oddNumber

evenNumber:
	mov		edx, 4
	mul		edx
	add		edi, eax
	mov		eax, [edi]
	add		eax, [edi-4]		; DIFFERENCE between even and odd is this line
	mov		edx, 0
	div		ebx					; ebx still has 2
	call	WriteDec			; the average is going to be the mean of those two numbers
	call	CrLf

	jmp		doneMedian

oddNumber:
	mov		edx, 4
	mul		edx					; eax * 4 gets position
	add		edi, eax			; @array = edi + the position in the array
	mov		eax, [edi]			; store the [edi] in eax
	call	WriteDec
	call	CrLf
	
doneMedian:
	pop		ebp
	ret		12

displayMedian	ENDP


;*************** DISPLAYLIST **************************
; displayList
;	Display the list to the user, whether unsorted or sorted
;	Returns: elements of array are printed to the stack
;	Receives: address of the list
;	Preconditions: there are variables for exit message and user name is stored
;	Postconditions: the goodbye is printed
;	Registers Changed: EBP, ESP, EAX, EDX, ECX, EDI
;**************************************************
displayList	PROC

	; reference an array without knowing the array's name
	; edi will point to the beginning of the array
	push	ebp
	mov		ebp, esp
	mov		edi, [ebp+16]		; @list in edi
	mov		ecx, [ebp+12]		; value of count in ecx

	; display type of list to the screen, using title by reference
	call	CrLf
	mov		edx, [ebp+8]		; whether sorting or unsorting, result message
	call	WriteString
	call	CrLf

	; display array, number by number to the screen
eachNumber:
	mov		eax, [edi]			; moves the array value to eax
	call	WriteDec
	mov		edx, OFFSET space
	call	WriteString

	inc		numPrinted			; update print count
	inc		perLine
	mov		ebx, perLine
	cmp		ebx, 10				; make sure the 10 per line is printed
	
	jl		notALine
	call	CrLf
	mov		perLine, 0			; reassign the perLine to 0

notALine: 
	add		edi, 4				; go to the next element in the array
	loop	eachNumber

	call	CrLf
	pop		ebp
	ret		12					; adds to the stack so we don't have to pop everything

displayList	ENDP



;*************** GOODBYE **************************
; goodbye
;	Wishes the user a goodbye message, verify results
;	Returns: N/A
;	Receives: N/A
;	Preconditions: there are variables for exit message and user name is stored
;	Postconditions: the goodbye is printed
;	Registers Changed: EDX
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
