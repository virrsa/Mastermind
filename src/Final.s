/*	
	Mastermind Game - ARM Assembly
*/

.global _start

_start:

	BL _help
		
choiceLoop:
	
	LDR R1, =choice				@ loads address of the string into register 1
	LDR R2, =choicelen			@ loads the address of the length into register 2
	BL _strPrint
	
	MOV R7, #3					@ set r7 to read (3)
	MOV R0, #0					@ display destination to stdin
	LDR R1, =input				@ loads address of the string into input
	MOV R2, #5					@ sets the length of the input
	SWI 0
	
	LDR R1, =input				@ load the input into R1
	BL _strFix					@ terminate the string with a NULL
	LDR R1, =input				@ load the input once again into R1
	BL _strLower				@ make everything lower case
	
	LDR R1, =input				@ load the input into R1
	LDRB R0, [R1]				@ load the first character in R1 in R0
	
	CMP R0, #115				@ compare value in R0 with s
	BLEQ gameStart
	CMP R0, #104				@ compare value in R0 with h
	BLEQ _help
	CMP R0, #113				@ compare value in R0 with q
	BLEQ _end
	
	BAL choiceLoop

gameStart:

	BL _genRandom				@ generate the 4 random numbers
	LDR R6, =genrand			@ testing 
	LDR R1, =gensuccess			@ succesful pattern generation message
	LDR R2, =genlen				@ set the length of the string
	BL _strPrint
	
	MOV R3, #0					@ counter to track attempts

guessStart:
	
	LDR R1, =guess				@ ask the user for their guess
	LDR R2, =guesslen			@ set the length of the string
	BL _strPrint
	
	MOV R7, #3					@ set r7 to read (3)
	MOV R0, #0					@ display destination to stdin
	LDR R1, =userguess			@ loads address of the users guess into R1
	MOV R2, #5					@ sets the length of the input
	SWI 0

@ check if the input is a character
	
	LDR R1, =userguess			@ load the users guess into R1
	BL _strFix					@ terminate the string with a NULL
	LDR R1, =userguess			@ load the users guess into R1
	LDRB R0, [R1]				@ load the first character in R1 in R0
	CMP R0, #65					@ compare byte in R0 with 'A'
	BGE charaInput
	
@ if the input is not a character

	LDR R1, =userguess			@ load the users guess into R1
	BL _toNum					@ convert from ascii to num
	LDR R1, =userguess			@ load the users guess into R1
	
	LDR R9, =userguess			@ load the users guess into R9
	LDR R6, =genrand			@ load the random generated numbers into R6
	ADD R3, R3, #1				@ increment attempt counter
	MOV R4, #0					@ counter to track correct guesses
	
@ check the first character

	LDRB R8, [R9]				@ load the first character in R9 in R8
	LDRB R5, [R6]				@ load the first character in R6 in R5

	CMP R8, R5					@ compare the first numbers
	ADDEQ R4, R4, #1			@ if equal, increment counter
	
	ADD R9, R9, #1				@ move address to the next character
	ADD R6, R6, #1				@ move address to the next character
	
@ check the second character

	LDRB R8, [R9]				@ load the second character in R9 in R8
	LDRB R5, [R6]				@ load the second character in R6 in R5

	CMP R8, R5					@ compare the second numbers
	ADDEQ R4, R4, #1			@ if equal, increment counter
	
	ADD R9, R9, #1				@ move address to the next character
	ADD R6, R6, #1				@ move address to the next character
	
@ check the third character
	
	LDRB R8, [R9]				@ load the third character in R9 in R8
	LDRB R5, [R6]				@ load the third character in R6 in R5

	CMP R8, R5					@ compare the third numbers
	ADDEQ R4, R4, #1			@ if equal, increment counter
	
	ADD R9, R9, #1				@ move address to the next character
	ADD R6, R6, #1				@ move address to the next character
	
@ check the fourth character

	LDRB R8, [R9]				@ load the fourth character in R9 in R8
	LDRB R5, [R6]				@ load the fourth character in R6 in R5

	CMP R8, R5					@ compare the fourth numbers
	ADDEQ R4, R4, #1			@ if equal, increment counter
	
@ checking for correct inputs but not in the right spot

	LDR R6, =genrand			@ load the random generated numbers into R6
	LDR R1, =cmpgen				@ load variable which will copy from genrand
	MOV R2, #0					@ set counter to 0
	BL _strCpy
	
	LDR R9, =userguess			@ load the users guess into R9
	
	MOV R0, #5					@ put the value five into R0
	MOV R10, #0					@ set correct character counter to 0
	MOV R11, #0					@ set guessLoop counter to 0
	
guessLoop:

	LDRB R8, [R9]				@ load the first character in R9 in R8
	
	ADD R11, R11, #1			@ increment counter
	CMP R11, #5					@ compare counter value with 4
	BEQ winCondition
	
	LDR R6, =cmpgen				@ load the copied random generated numbers into R6
	MOV R12, #0					@ set cmpLoop counter to 0
	
	cmpLoop:
		LDRB R5, [R6]			@ load the first character in R6 in R5
		
		ADD R12, R12, #1		@ increment counter	
		CMP R12, #5				@ compare counter value with 4
		ADDEQ R9, R9, #1		@ increment to the next address for input
		BEQ guessLoop
		
		CMP R8, R5				@ compare the value from the user input and generated value
		ADDEQ R10, R10, #1		@ increment correct number loop
		STREQB R0, [R6]			@ replace value to avoid duplicate counting for duplicate numbers
		ADDEQ R9, R9, #1		@ increment to the next address for input
		BEQ guessLoop
		
		ADD R6, R6, #1			@ increment to the next address for generated nums
		BAL cmpLoop
	
@ winning condition checking
winCondition:

	LDR R1, =resultone			@ load the address of the string into R1
	LDR R2, =resultonelen		@ load length of the string into R2
	BL _strPrint
	
	CMP R10, #0					@ compare R10 with 0
	LDREQ R1, =numzero			@ load "zero" into R1
	MOVEQ R2, #5				@ load length of the string into R2
	BLEQ _strPrint
	CMP R10, #1					@ compare R10 with 1
	LDREQ R1, =numone			@ load "one" into R1
	MOVEQ R2, #4				@ load length of the string into R2
	BLEQ _strPrint
	CMP R10, #2					@ compare R10 with 2
	LDREQ R1, =numtwo			@ load "two" into R1
	MOVEQ R2, #4				@ load length of the string into R2
	BLEQ _strPrint
	CMP R10, #3					@ compare R10 with 3		
	LDREQ R1, =numthree			@ load "three" into R1
	MOVEQ R2, #6				@ load length of the string into R2
	BLEQ _strPrint
	CMP R10, #4					@ compare R10 with 4
	LDREQ R1, =numfour			@ load "four" into R1
	MOVEQ R2, #5				@ load length of the string into R2
	BLEQ _strPrint
	
	LDR R1, =resulttwo			@ load the address of the string into R1
	LDR R2, =resulttwolen		@ load length of the string into R2
	BL _strPrint
	
	CMP R4, #0					@ compare R4 with 0
	LDREQ R1, =numzero			@ load "zero" into R1
	MOVEQ R2, #5				@ load length of the string into R2
	BLEQ _strPrint
	CMP R4, #1					@ compare R4 with 1			
	LDREQ R1, =numone			@ load "one" into R1
	MOVEQ R2, #4				@ load length of the string into R2
	BLEQ _strPrint
	CMP R4, #2					@ compare R4 with 2
	LDREQ R1, =numtwo			@ load "two" into R1
	MOVEQ R2, #4				@ load length of the string into R2
	BLEQ _strPrint
	CMP R4, #3					@ compare R4 with 3
	LDREQ R1, =numthree			@ load "three" into R1
	MOVEQ R2, #6				@ load length of the string into R2
	BLEQ _strPrint
	CMP R4, #4					@ compare R4 with 4
	LDREQ R1, =numfour			@ load "four" into R1
	MOVEQ R2, #5				@ load length of the string into R2
	BLEQ _strPrint

	LDR R1, =resultthree		@ load the address of the string into R1
	LDR R2, =resultthreelen		@ load length of the string into R2
	BL _strPrint

	CMP R4, #4					@ compare value in R4 with 4
	BEQ win
	
	CMP R3, #10					@ compare value in R3 with 10
	BEQ lose
	
	BNE guessStart

charaInput:
	
	LDR R1, =userguess			@ load the input if greater than 'A'
	BL _strLower
	
	LDR R1, =userguess			@ load the input into R1
	LDRB R0, [R1]				@ load the first character in R1 in R0
	
	CMP R0, #104				@ compare value in R0 with h
	BLEQ _help
	CMP R0, #113				@ compare value in R0 with q
	BLEQ _end
	
	BAL guessStart

win:

	LDR R1, =winning			@ load the message in R1
	LDR R2, =winninglen			@ set length of the string
	BL _strPrint
	
	BAL _end	

lose:
	
	LDR R1, =losing				@ load the message in R1
	LDREQ R2, =losinglen		@ set length of the string
	BL _strPrint	
	
	BAL _end
	
_end:

	MOV R7, #1
	SWI 0
	
.data
choice:		 .asciz "Please enter a command: "
choicelen = .-choice
input:		 .space 5
gensuccess:  .asciz "Successfully generated a pattern.\n"
genlen = .-gensuccess	
guess:		 .asciz "Please enter a guess: "
guesslen = .-guess
userguess:	 .space 5
winning:	 .asciz "Congratulations, you guessed it right and won the game!\n"
winninglen = .-winning
losing:		 .asciz "Sorry, your guesses exceeded the allowed attempts. You lose.\n"
losinglen = .-losing
resultone:   .asciz "You have guessed "
resultonelen = .-resultone
resulttwo:   .asciz " of the numbers and "
resulttwolen = .-resulttwo
resultthree: .asciz " of the numbers are in the correct position.\n"
resultthreelen = .-resultthree
numzero:     .asciz "none"
numone: 	 .asciz "one"
numtwo:		 .asciz "two"
numthree:    .asciz "three"
numfour:     .asciz "four"
cmpgen: 	 .space 5
