TITLE TSA Final Project	(FinalProject.asm)

; Author: Andrea Tongsak
; Last Modified: Mar 7, 2021
; OSU email address: tongsaka@oregonstate.edu
; Course number/section: CS271-001
; Assignment Number: FinalProgram              Due Date: Mar 17, 2021
; Description: A program that will accept a message from a .data segment and then encrypt or decrypt the message.


INCLUDE Irvine32.inc

; Constants

; Setting the ASCII range from "a" to "z"
ASCII_LOWER = 97
ASCII_HIGHER = 122

; Length of myKey is 26: the alphabet "a to z"
KEY_LENGTH = 26

displayMessage  MACRO	buffer
	push	edx						;save edx register
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx						;restore edx
ENDM

.data

;; TEST DATA FOR DECOY SCENARIO -----------------------------------------------
operand1       WORD    1000     
operand2       WORD    -8000
; dest           DWORD   0

;; TEST DATA FOR ENCRYPTING SCENARIO ------------------------------------------
myKey          BYTE   "edgsaqyftiuopwmxlnbvhczrkj"
message        BYTE   "but we were something, don't you think so? roaring 20s, tossing pennies in the pool", 0

dest           DWORD   -1
msgCharCount   DWORD   0

;; TEST DATA FOR DECRYPTING SCENARIO ------------------------------------------
;myKey          BYTE   "efbcdghijklmnopqrstuvwxyza"
;message      BYTE   "uid bpoudout pg uijt ndttehd xjmm fd e nztudsz.",0

;dest         DWORD   -2


.code


;******************** DECOYCOMPUTE ************************
; decoyCompute
;	decoyCompute will set up the stack frame, place WORDS onto the stack, then compute their sum
;	Receives: operand1, operand2
;	Returns: operand1 + operand2
;	Preconditions: N/A
;	Postconditions: The sum of the two registers is stored in [edi]
;	Registers Changed: EAX, AX, EBX, BX, EBP, EDI
;**********************************************************
decoyCompute PROC

   push  ebp
   mov   ebp, esp            ; base of stack frame

   mov	edi, [ebp + 8]		 ; address of dest
   mov	ax, WORD PTR [ebp+12]
   
   movsx eax, ax

   mov	bx, WORD PTR [ebp+14]
   
   movsx ebx, bx

   add	eax, ebx

   mov	[edi], eax			 ; store address of dest

   pop   ebp  

   ret	 8					; clean up the stack

decoyCompute ENDP



;******************** ENCRYPTCOMPUTE ************************
; encryptCompute
;	encryptCompute will get the length of the message, then loop through and replace each byte in the message array with its key
;	Receives: myKey, message
;	Returns: Correct encrypted message
;	Preconditions: Normal message not yet encrypted
;	Postconditions: The message is encrypted and shown to the user
;	Registers Changed: ESI, EBP, AL, EDI, AH, EBX
;**********************************************************
encryptCompute PROC

   push  ebp
   mov   ebp, esp            ; base of stack frame
   
   ; first get the length of message using Irvine Str_length library function
   ; the length of the string will be saved in eax
   ; we then keep the counter in ecx to help with the loop counter

   INVOKE  Str_length, ADDR message 

   call  CrLf

   mov   msgCharCount, eax
   mov   ecx, msgCharCount
   
   ; allow edi and esi to hold addresses of myKey and message
   mov   edi, [ebp+16]
   mov   esi, [ebp+12]


; is the code 
COUNTER:
   mov   al, [esi]           ; get byte value from message 
   

   ; check if the al is greater than or less than 122
   cmp   al, ASCII_LOWER              
							 ; is the char < 97?
   jl    SKIP                

   cmp   al, ASCII_HIGHER             

   jg    SKIP                
							 ; jump to SKIP if so
   
   sub   al, ASCII_LOWER    
							 ; we subtract 97 to get what char we need in myKey

   ; the movsx instruction expands the register
   movsx ebx, al             
							 ; convert al one BYTE size to DWORD size
   add   edi, ebx			

   mov   ah, [edi]           
							 ; get the byte value from myKey
   mov   [esi], ah           
							 ; save the encrypted byte value back into message indirectly

SKIP:
   add   esi, 1              
							 ; increment esi to iterate towards next char of the message
   mov   edi, [ebp+16]       
							 ; set edi to the beginning address of myKey
   loop  COUNTER             
							 ; loop until ecx counter is 0
  
DONE_ENCRYPT:
   pop   ebp  
   ret   8                   ; clean up the stack

encryptCompute ENDP


;******************** DECRYPTCOMPUTE ************************
; decryptCompute
;	decryptCompute will get the length of the encrypted message, take the message as an array of bytes, and loop through the key to find its match
;	Receives: myKey, message
;	Returns: Correct decrypted message
;	Preconditions: Message is encrypted.
;	Postconditions: The message is decrypted and shown to the user
;	Registers Changed: EAX, ESI, EBP, EDI, ECX, ESP, AL, BL
;**********************************************************
decryptCompute PROC

   push  ebp
   mov   ebp, esp            ; base of stack frame
   
   ; first get the length of message using Irvine Str_length library function
   ; the length of the string will be saved in eax
   ; we keep the counter in ecx to help with the loop counter

   INVOKE  Str_length, ADDR message

   call  CrLf
   
   ; ecx has num chars of message for looping array
   mov   msgCharCount, eax
   mov   ecx, msgCharCount
   
   ; make edi and esi to hold addresses of myKey and message, repectively
   mov   edi, [ebp+16]
   mov   esi, [ebp+12]
 

COUNTER:
   mov   al, [esi]           ; get byte value from message 
   
   ; use bl as counter to traversing myKey for the index we need
   mov   bl, 0

   ; looking for encrptyed char we picked in myKey
   SEARCH:
      cmp  al, [edi]         ; is the char from myKey matching? 
      je   FOUND             ; jump to FOUND if they are match
      add  edi, 1            ; if not, move to the next char in myKey
      add  bl, 1             ; increment bl so we know what position we are in myKey
      cmp  bl, KEY_LENGTH    ; have we reached end of myKey?
      jge  SKIP              ; if yes then there is no match to find and we go to SKIP
      jmp  SEARCH            ; else jump back to LK1
   
   FOUND:
      mov  al, bl            ; al now has the position of char we found in myKey
      add  al, ASCII_LOWER   ; al will have the decrypted char now after adding 97
      mov  [esi], al         ; save the decrypted char back to the message

SKIP:
   add   esi, 1              ; increment esi for next char of the message
   mov   edi, [ebp+16]       ; reset edi to the beginning address of myKey
   loop  COUNTER
  
DONE_ECRYPT:

   pop   ebp  
   ret   8                   ; clean up the stack

decryptCompute ENDP



;***************** COMPUTE ************************
; compute
;	Calls decoy, encrypt, and decrypt modes using the system stack.
;	Receives: N/A
;	Returns: N/A
;	Preconditions: N/A
;	Postconditions: The program will check the dest then correctly call the subprocedure
;	Registers Changed: EBX
;**************************************************
compute PROC

	; dereference the OFFSET of the dest and check if it is 0, -1, or -2
	mov    ebx, [dest]

	cmp    ebx, 0
	je     DECOY
	cmp    ebx, -1
	je     ENCRYPT
	cmp    ebx, -2
	je     DECRYPT

	jmp    TOLEAVE

DECOY:
	
	push   operand1                 ; push operand1 - will be at [ebp+14] of stack
    push   operand2                 ; push operand2 - will be at [ebp+12] of stack
	push   OFFSET dest              ; push OFFSET dest - will be at [ebp+8] 
    call   decoyCompute
	mov    eax, dest                ; currently dest holds the result value
 	call   WriteInt                 ; display the result 
    call   CrLf
	jmp    TOLEAVE

	call   CrLf


ENCRYPT:

   displayMessage message
   call   CrLf

   push   OFFSET myKey				; push OFFSET myKey - will be at [ebp+16] of stack
   push   OFFSET message			; push OFFSET message - will be at [ebp+12] of stack
   push   OFFSET dest				; push OFFSET dest - at [ebp+8]
   call   encryptCompute			; call to encrypt the message and result in message
   displayMessage message
   call   CrLf
   call   CrLf
	
   jmp    TOLEAVE

   
DECRYPT:

   displayMessage message
   call   CrLf

   push   OFFSET myKey
   push   OFFSET message
   push   OFFSET dest
   call   decryptCompute
   displayMessage message
   call   CrLf
   call   CrLf

   jmp    TOLEAVE

TOLEAVE:

	exit


compute ENDP



;******************** MAIN ************************
; main
;	User controlled, pushes values onto the stack for compute to handle
;	Receives: N/A
;	Returns: N/A
;	Preconditions: N/A
;	Postconditions: The modes are called and proper mode is handled
;	Registers Changed: N/A
;**************************************************
main PROC

	push	OFFSET myKey
	push	OFFSET message
	push	OFFSET dest
	call	compute

	mov		edx, OFFSET message
	call	WriteString
    

main ENDP

END main
