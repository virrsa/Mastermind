/*	
	Mastermind Game Libraries - ARM Assembly
*/

.global _help
.global _strFix
.global _strLower
.global _strPrint
.global _genRandom
.global _toNum
.global _strCpy

.equ	OPEN, 5		@ opens a data source
.equ	READ, 3		@ reads from a data source
.equ	CLOSE, 6	@ closes an open data source
.equ 	RDRW, 02	@ flag for read/write mode

_help:

	LDR R1, =welcome			@ loads address of the string into register 1
	LDR R2, =len				@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =one				@ loads address of the string into register 1
	LDR R2, =lenone				@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =two				@ loads address of the string into register 1
	LDR R2, =lentwo				@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =three				@ loads address of the string into register 1
	LDR R2, =lenthree			@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =four				@ loads address of the string into register 1
	LDR R2, =lenfour				@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =seven				@ loads address of the string into register 1
	LDR R2, =lenseven			@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =five				@ loads address of the string into register 1
	LDR R2, =lenfive			@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	LDR R1, =six				@ loads address of the string into register 1
	LDR R2, =lensix				@ loads the address of the length into register 2
	PUSH {LR}					@ push LR onto the stack
	BL _strPrint				
	POP {LR}					@ pop LR off of the stack
	
	MOV PC, LR

_strFix:

	MOV R2, #0			@ set counter to 0
	
replacerLoop:

	LDRB R0, [R1]		@ load the character address in r1 into r0
	ADD R2, R2, #1		@ increment counter
	CMP R2, #10			@ checks to see if the counter is at 10
	BGE replaceCharacter
	
	CMP R0, #10			@ compare character with newline
	ADDNE R1, R1, #1	@ move address to the next character
	BNE replacerLoop
	
replaceCharacter:

	MOV R4, #0			@ insert NULL in R3
	STRB R4, [R1]		@ replace end of string with NULL	
	
	MOV PC, LR			@ move back to _start

_strLower:
	
lowerCaseLoop:

	LDRB R0, [R1]		@ load the character address in r1 into r0
	CMP R0, #0			@ compares R0 with NULL
	BEQ lbreak
	
	CMP R0, #65			@ compare character with ascii value of A
	CMPGE R0, #90			@ compare character with ascii value of Z
	BLE lowerCharacter
	
	ADDNE R1, R1, #1	@ move address to the next character
	BAL lowerCaseLoop	
	
lowerCharacter:
	
	ADD R0, R0, #32		@ add 32 to character to make it lowercase
	STRB R0, [R1]		@ store the new value back in the original address
	ADDNE R1, R1, #1	@ move address to the next character
	BAL lowerCaseLoop

lbreak:
	
	MOV PC, LR

_strPrint:
	
	MOV R7, #4			@ call sys_write (4)
	MOV R0, #1			@ display message to stdout (1)
	SWI 0					
	
	MOV PC, LR			

_genRandom:
	
	MOV R5, #4				@ set maximum number for the generator
	
	LDR R3, =open			@ loads the address of open
	LDM	R3, {R0, R1, R7}	@ uses the values in open to populate R0, R1, and R7
	SWI 0
	
	MOV R4, R0				@ loads file pointer into R4
	LDR R3, =read			@ load in the address of read
	LDM R3, {R1, R2, R7}	@ set up registers for READ syscall
	SWI 0
	
	MOV R0, R4				@ puts file pointer into R0		
	MOV R7, #CLOSE			@ CLOSE syscall
	SWI 0
	
	LDR R1, =buffer			@ load the buffer into R1
	LDR R6, =genrand		@ load the variable to place the random numbers
	MOV R9, #0				@ set counter to 0
	
genRandomNumbers:

	LDRB R0, [R1]			@ load a byte from the buffer into R0
	LDRB R8, [R6]			@ load a byte from genrand into R8
	ADD R9, R9, #1			@ increment counter
	CMP R9, #4				@ compare counter with 4
	MOVGE PC, LR			@ if equal, exit the subroutine
	
genRandomLoop:
	
	CMP R0, R5				@ compare the byte with the value in R5
	SUBGE R0, R0, R5		@ if greater, then subtract it with the value
	BGE genRandomLoop
	STRB R0, [R6]			@ store the byte from the buffer into genrand
	ADD R1, R1, #1			@ move the address to the next location
	ADD R6, R6, #1			@ move the address to the next location
	BAL genRandomNumbers

_toNum:

numLoop:

	LDRB R0, [R1]		@ load the character address in r1 into r0
	CMP R0, #0			@ compares R0 with NULL
	MOVEQ PC, LR
	
	SUB R0, R0, #48		@ subtract 48 to character to make it non ascii
	STRB R0, [R1]		@ store the new value back in the original address
	ADDNE R1, R1, #1	@ move address to the next character
	
	BAL numLoop	
	
_strCpy:
	
copyLoop:

	LDRB R5, [R6]		@ load the character address in r1 into r0
	LDRB R0, [R1]		@ load the character address in r4 into r3
	STRB R5, [R1]		@ copy character in r0 to r4
	ADD R2, R2, #1		@ increment counter
	CMP R2, #5			@ compares counter with length of input
	MOVEQ PC, LR
	
	ADDNE R6, R6, #1	@ move address to the next character
	ADDNE R1, R1, #1	@ move address to the next character
	BNE copyLoop

.data
welcome:	.asciz "Welcome to Mastermind!\nRules:\n"
len = .-welcome
one:	.asciz "1. A code will be generated in a random sequence.\n"		
lenone = .-one	
two:	.asciz "2. The code will be a mix of numbers from 0 to 4. Note that numbers may repeat.\n"
lentwo = .-two
three:  .asciz "3. When guessing, write 4 numbers in a row with nothing in between them.\n"
lenthree = .-three
four:	.asciz "4. You will have 10 guesses. If that is exceeded, the player will lose.\n"
lenfour = .-four
five:	.asciz "5. Type 'h' to view the rules during the game.\n"
lenfive = .-five
six:	.asciz "6. Type 'q' to quit the game.\n"
lensix = .-six
seven:  .asciz "7. Type 's' to start the game.\n"
lenseven = .-seven
genrand: .space 5
dir_file: .asciz "/dev/random"
open: .word dir_file, RDRW, OPEN
buffer: .word	0
read: .word buffer, 4, READ

