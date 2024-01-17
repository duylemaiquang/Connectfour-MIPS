#I take reference from github, which me using storeInput, winCheck method

.data
boardArray: .byte 0:42	#This will be the array that represents the gameboard: 0=Empty 1=Player1 2=Player2
boardline1: .space 28
boardline2: .space 28
boardline3: .space 28
boardline4: .space 28
boardline5: .space 28
boardline6: .space 28
boardline7: .space 28
list1: .space 16 #violation, undo, block, turn
list2: .space 16
nline: .asciiz"\n"
dounline: .asciiz"\n"
name1: .space 20
name2: .space 20
in_name1: .asciiz "Please enter player 1's name: \n"
in_name2: .asciiz "Please enter player 2's name: \n"
prompt0: .asciiz "Welcome to Connect4!\nInput 4 at first to drop the piece of the random player\nEnter 1-7 to choose which column to place the game piece in.\nOnce Player 1 goes, Player 2 may then take their turn.\nEach player have 3 times to undo their move and 1 time to block the next player move.\nPlease input your move from 1-7, else you will be counted as 1 violation.\nIf you violated 3 times, you will be lose.\n"
prompt1: .asciiz "-It's your turn: \n"
prompt3: .asciiz "-You Wins!\n"
prompt4: .asciiz "-Please place the piece in the center column of the board!\n"
prompt5: .asciiz "Please enter a number between 1 and 7 (inclusive)\n"
prompt6: .asciiz "The column you have chosen is full. Select a different column\n"
prompt7: .asciiz "It's a Tie!\n"
prompt8: .asciiz "Please try again (4 is a good option)\n"
prompt9: .asciiz "Do you want to undo your move (choose:0-No; 1-Yes): \n"
prompt10: .asciiz "Other player violated 3 times\n"
prompt11: .asciiz "You can not block anymore\n"
prompt12: .asciiz "Do you want to block other player's next move (choose:0-No; 1-Yes): \n"
prompt13: .asciiz "Please choose 1-No or 2-Yes\n"
prompt14: .asciiz "You can not undo anymore\n"
promptvio: .asciiz "Violation(s): "
promptundo: .asciiz "Undo(s): "
promptblo: .asciiz "Block: "
promptcou: .asciiz "Piece(s): "
.text


#Load Welcome Prompt
la $a0, prompt0	
li $v0, 4
syscall

main:
#given violation and undo
li $s1, 3
li $s2, 1

la $a1, list1
sb $s1, 4($a1)
sb $s2, 8($a1)

la $a1, list2
sb $s1, 4($a1)
sb $s2, 8($a1)

la $a0, in_name1
li $v0, 4
syscall

li $v0, 8
la $a0, name1
li $a1, 20
move $t0, $a0
syscall

la $a0, in_name2
li $v0, 4
syscall

li $v0, 8
la $a0, name2
li $a1, 20
move $t0, $a0
syscall

li $s1, 0 #count 1
li $s2, 0 #count 2
li $s3, 0 #count 3
li $s4, 0 #count 4
li $s5, 0 #count 5
li $s6, 0 #count 6
li $s7, 0 #count 7

firstMove:
la $a0, prompt4
li $v0, 4
syscall
li $v0,5
syscall
beq $v0,4,randomPlayer
la $a0, prompt8
li $v0, 4
syscall
j firstMove

randomPlayer:
li $a1, 2
li $v0, 42
syscall
add $a0, $a0, 1
li $t0, 0
addu $t0, $t0, $a0
li $v0, 4
jal StoreInput
jal printBoard
beq $t0, 1, countFirstmove1
j countFirstmove2

countFirstmove1:
	la $a3, list1
	lb $t0, 12($a3)
	addiu $t0,$t0,1
	sb $t0, 12($a3)
	j playerTwo
countFirstmove2:
	la $a3, list2
	lb $t0, 12($a3)
	addiu $t0,$t0,1
	sb $t0, 12($a3)
	j playerOne
############################
#1. Get player input
#2. Ask if undo
#3. Store input
#4. Count step(s)
#5. Check if there is winner
#6. print the board
#7. Print the status
#8. Ask if player want to block
#9. Move to the next player

#Get Player 1 Input
playerOne:
la $a0, name1
li $v0, 4
syscall
la $a0, prompt1
li $v0, 4
syscall

li $v0, 5
syscall

move $t5, $v0
jal UndoP1
#Place User Input into Array and Error Check
move $v0,$t5
li $a0, 1
jal StoreInput

#count piece(s)
jal Count1

#Check for Player 1 "Connect 4"
#If found, go to Player 1 win
#If not found, continue game
jal WinCheck

jal printBoard
jal printStatus1

jal BlockP1

#Get Player 2 Input
playerTwo:
la $a0, name2
li $v0, 4
syscall
la $a0, prompt1
li $v0, 4
syscall
li $v0, 5
syscall

move $t5, $v0
jal UndoP2
#Place User Input into Array and Error Check
move $v0,$t5
li $a0, 2
jal StoreInput

jal Count2
#Check for Player 2 "Connect 4"
#If found, go to Player 2 win
#If not found, go back to Player 1 turn
jal WinCheck

jal printBoard
jal printStatus2

jal BlockP2

j playerOne	#Play next set of turns
################################  End Main ################################

#undo the player last move
UndoP1:
	la $a0, prompt9
	li $v0, 4
	syscall
	
	li $v0 ,5
	syscall
	
	beq $v0, 0, returnU1
	bgt $v0, 1, outRangeU1
	
	la $a3, list1
	lb $t0, 4($a3)
	beqz $t0, outUndo1
	addiu $t0,$t0,-1
	sb $t0, 4($a3)
	j playerOne
	outRangeU1:
		la $a0, prompt13
		li $v0, 4
		syscall
		j UndoP1
	outUndo1:
		la $a0, prompt14
		li $v0,4
		syscall
		jr $ra
	returnU1:
		jr $ra
UndoP2:
	la $a0, prompt9
	li $v0, 4
	syscall
	
	li $v0 ,5
	syscall
	
	beq $v0, 0, returnU2
	bgt $v0, 1, outRangeU2
	
	la $a3, list2
	lb $t0, 4($a3)
	beqz $t0, outUndo2
	addiu $t0,$t0,-1
	sb $t0, 4($a3)
	j playerTwo
	outRangeU2:
		la $a0, prompt13
		li $v0, 4
		syscall
		j UndoP2
	outUndo2:
		la $a0, prompt14
		li $v0,4
		syscall
		jr $ra
	returnU2:
		jr $ra

#block the next player turn
BlockP1:
	la $a0, prompt12
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, 0, return1
	bgt $v0, 1, outRange1
	
	la $a3, list1
	lb $t0, 8($a3)
	beqz $t0, outBlock1
	addiu $t0,$t0,-1
	sb $t0, 8($a3)
	j playerOne
	
	outRange1:
		la $a0, prompt13
		li $v0, 4
		syscall
		j BlockP1
	outBlock1:
		la $a0, prompt11
		li $v0,4
		syscall
		jr $ra
	return1:
		jr $ra
BlockP2:
	la $a0, prompt12
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, 0, return2
	bgt $v0, 1, outRange2
	
	la $a3, list2
	lb $t0, 8($a3)
	beqz $t0, outBlock2
	addiu $t0,$t0,-1
	sb $t0, 8($a3)
	j playerTwo
	
	outRange2:
		la $a0, prompt13
		li $v0, 4
		syscall
		j BlockP2
	outBlock2:
		la $a0, prompt11
		li $v0,4
		syscall
		jr $ra
	return2:
		jr $ra

#count the turn of the plaer
Count1:
	la $a3, list1
	lb $t0, 12($a3)
	addiu $t0,$t0,1
	sb $t0, 12($a3)
	jr $ra
Count2:
	la $a3, list2
	lb $t0, 12($a3)
	addiu $t0,$t0,1
	sb $t0, 12($a3)
	jr $ra

#checking the violation after 1 turn 
VioCheck1:
	la $a3, list1
	lb $t0, 0($a3)
	li $a0, 2
	beq $t0, 3, PlayerWon
	li $a0, 1
	j playerOne
VioCheck2:
	la $a3, list2
	lb $t0, 0($a3)
	li $a0, 1
	beq $t0, 3, PlayerWon
	li $a0, 2
	j playerTwo
StoreInput:
	li $t6, 0
	addu $t6, $t6, $v0 #index
	li $t7, 0
	addu $t7, $t7, $a0 #player number
	
	addiu $v0, $v0, -8	#Convert user input into Array notation(-1) and subtract for nextCheck Loop(-7)
	bltu $v0, -7, OOBError
	bgtu $v0, -1, OOBError
	
	#Find out (in the column) where the next available row is
	nextCheck:
	addiu $v0, $v0, 7	#Increment row
	bgtu $v0, 41, ColumnFull#If column is full go to error
	lb $t1, boardArray($v0)	#Load byte from boardArray that user has chosen
	bnez $t1, nextCheck	#If loaded byte is NOT EMPTY(1 or 2) then try next row up (add 7 to array index)
	
	#Only reach here if boardArray(base + offset) = 0
	sb $a0, boardArray($v0)	#Place player number into boardArray at location player's chip will end
	
	#check the collumn to input the data
	beq $t6, 1, check1
	beq $t6, 2, check2
	beq $t6, 3, check3
	beq $t6, 4, check4
	beq $t6, 5, check5
	beq $t6, 6, check6
	beq $t6, 7, check7
	
	jr $ra	#Finished Procedure Successfully
	
	#check the input to store chips to the array
	check1:
		beq $s1,0,board00
		beq $s1,1,board01
		beq $s1,2,board02
		beq $s1,3,board03
		beq $s1,4,board04
		beq $s1,5,board05
		beq $s1,6,board06
	check2:
		beq $s2,0,board10
		beq $s2,1,board11
		beq $s2,2,board12
		beq $s2,3,board13
		beq $s2,4,board14
		beq $s2,5,board15
		beq $s2,6,board16
	check3:
		beq $s3,0,board20
		beq $s3,1,board21
		beq $s3,2,board22
		beq $s3,3,board23
		beq $s3,4,board24
		beq $s3,5,board25
		beq $s3,6,board26
	check4:
		beq $s4,0,board30
		beq $s4,1,board31
		beq $s4,2,board32
		beq $s4,3,board33
		beq $s4,4,board34
		beq $s4,5,board35
		beq $s4,6,board36
	check5:
		beq $s5,0,board40
		beq $s5,1,board41
		beq $s5,2,board42
		beq $s5,3,board43
		beq $s5,4,board44
		beq $s5,5,board45
		beq $s5,6,board46
	check6:
		beq $s6,0,board50
		beq $s6,1,board51
		beq $s6,2,board52
		beq $s6,3,board53
		beq $s6,4,board54
		beq $s6,5,board55
		beq $s6,6,board56
	check7:
		beq $s7,0,board60
		beq $s7,1,board61
		beq $s7,2,board62
		beq $s7,3,board63
		beq $s7,4,board64
		beq $s7,5,board65
		beq $s7,6,board66
	#######Adding the chips to the board (1-Player1; 2-Player2)
	board00:
		li $s1, 1
		li $t5, 0
		sb $t7, boardline1($t5)
		jr $ra
	board01:
		li $s1, 2
		li $t5, 0
		sb $t7, boardline2($t5)
		jr $ra
	board02:
		li $s1, 3
		li $t5, 0
		sb $t7, boardline3($t5)
		jr $ra
	board03:
		li $s1, 4
		li $t5, 0
		sb $t7, boardline4($t5)
		jr $ra
	board04:
		li $s1, 5
		li $t5, 0
		sb $t7, boardline5($t5)
		jr $ra
	board05:
		li $s1, 6
		li $t5, 0
		sb $t7, boardline6($t5)
		jr $ra
	board06:
		li $s1, 7
		li $t5, 0
		sb $t7, boardline7($t5)
		jr $ra
	#######
	board10:
		li $s2, 1
		li $t5, 4
		sb $t7, boardline1($t5)
		jr $ra
	board11:
		li $s2, 2
		li $t5, 4
		sb $t7, boardline2($t5)
		jr $ra
	board12:
		li $s2, 3
		li $t5, 4
		sb $t7, boardline3($t5)
		jr $ra
	board13:
		li $s2, 4
		li $t5, 4
		sb $t7, boardline4($t5)
		jr $ra
	board14:
		li $s2, 5
		li $t5, 4
		sb $t7, boardline5($t5)
		jr $ra
	board15:
		li $s2, 6
		li $t5, 4
		sb $t7, boardline6($t5)
		jr $ra
	board16:
		li $s2, 7
		li $t5, 4
		sb $t7, boardline7($t5)
		jr $ra
	#######	
	board20:
		li $s3, 1
		li $t5, 8
		sb $t7, boardline1($t5)
		jr $ra
	board21:
		li $s3, 2
		li $t5, 8
		sb $t7, boardline2($t5)
		jr $ra
	board22:
		li $s3, 3
		li $t5, 8
		sb $t7, boardline3($t5)
		jr $ra
	board23:
		li $s3, 4
		li $t5, 8
		sb $t7, boardline4($t5)
		jr $ra
	board24:
		li $s3, 5
		li $t5, 8
		sb $t7, boardline5($t5)
		jr $ra
	board25:
		li $s3, 6
		li $t5, 8
		sb $t7, boardline6($t5)
		jr $ra
	board26:
		li $s3, 7
		li $t5, 8
		sb $t7, boardline7($t5)
		jr $ra
	#######
	board30:
		li $s4, 1
		li $t5, 12
		sb $t7, boardline1($t5)
		jr $ra
	board31:
		li $s4, 2
		li $t5, 12
		sb $t7, boardline2($t5)
		jr $ra
	board32:
		li $s4, 3
		li $t5, 12
		sb $t7, boardline3($t5)
		jr $ra
	board33:
		li $s4, 4
		li $t5, 12
		sb $t7, boardline4($t5)
		jr $ra
	board34:
		li $s4, 5
		li $t5, 12
		sb $t7, boardline5($t5)
		jr $ra
	board35:
		li $s4, 6
		li $t5, 12
		sb $t7, boardline6($t5)
		jr $ra
	board36:
		li $s4, 7
		li $t5, 12
		sb $t7, boardline7($t5)
		jr $ra
	#######
	board40:
		li $s5, 1
		li $t5, 16
		sb $t7, boardline1($t5)
		jr $ra
	board41:
		li $s5, 2
		li $t5, 16
		sb $t7, boardline2($t5)
		jr $ra
	board42:
		li $s5, 3
		li $t5, 16
		sb $t7, boardline3($t5)
		jr $ra
	board43:
		li $s5, 4
		li $t5, 16
		sb $t7, boardline4($t5)
		jr $ra
	board44:
		li $s5, 5
		li $t5, 16
		sb $t7, boardline5($t5)
		jr $ra
	board45:
		li $s5, 6
		li $t5, 16
		sb $t7, boardline6($t5)
		jr $ra
	board46:
		li $s5, 7
		li $t5, 16
		sb $t7, boardline7($t5)
		jr $ra
	#######
	board50:
		li $s6, 1
		li $t5, 20
		sb $t7, boardline1($t5)
		jr $ra
	board51:
		li $s6, 2
		li $t5, 20
		sb $t7, boardline2($t5)
		jr $ra
	board52:
		li $s6, 3
		li $t5, 20
		sb $t7, boardline3($t5)
		jr $ra
	board53:
		li $s6, 4
		li $t5, 20
		sb $t7, boardline4($t5)
		jr $ra
	board54:
		li $s6, 5
		li $t5, 20
		sb $t7, boardline5($t5)
		jr $ra
	board55:
		li $s6, 6
		li $t5, 20
		sb $t7, boardline6($t5)
		jr $ra
	board56:
		li $s6, 7
		li $t5, 20
		sb $t7, boardline7($t5)
		jr $ra
	#######
	board60:
		li $s7, 1
		li $t5, 24
		sb $t7, boardline1($t5)
		jr $ra
	board61:
		li $s7, 2
		li $t5, 24
		sb $t7, boardline2($t5)
		jr $ra
	board62:
		li $s7, 3
		li $t5, 24
		sb $t7, boardline3($t5)
		jr $ra
	board63:
		li $s7, 4
		li $t5, 24
		sb $t7, boardline4($t5)
		jr $ra
	board64:
		li $s7, 5
		li $t5, 24
		sb $t7, boardline5($t5)
		jr $ra
	board65:
		li $s7, 6
		li $t5, 24
		sb $t7, boardline6($t5)
		jr $ra
	board66:
		li $s7, 7
		li $t5, 24
		sb $t7, boardline7($t5)
		jr $ra
	#######
	#Out of Bounds Error Catching
	OOBError:
	move $t0, $a0
	la $a0, prompt5
	li $v0, 4
	syscall
	move $a0, $t0
	j returnToPlayer
	
	#Column Full Error Catching
	ColumnFull:
	move $t0, $a0
	la $a0, prompt6
	li $v0, 4
	syscall
	move $a0, $t0
	
	returnToPlayer:
	beq $a0, 1, ViolationCount1
	beq $a0, 2, ViolationCount2

	ViolationCount1:
	la $a3, list1
	lb $t0, 0($a3)
	addiu $t0,$t0,1
	sb $t0, 0($a3)
	j VioCheck1
	ViolationCount2:
	la $a3, list2
	lb $t0, 0($a3)
	addiu $t0,$t0,1
	sb $t0, 0($a3)
	j VioCheck2	
#printBoard
printBoard: 
	li $v0,1
	lb $a0,boardline7($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline7($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline7($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline7($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline7($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline7($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline7($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline6($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline6($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline6($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline6($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline6($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline6($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline6($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline5($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline5($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline5($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline5($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline5($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline5($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline5($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline4($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline4($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline4($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline4($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline4($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline4($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline4($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline3($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline3($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline3($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline3($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline3($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline3($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline3($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline2($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline2($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline2($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline2($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline2($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline2($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline2($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	#######
	li $v0,1
	lb $a0,boardline1($zero)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,4
	lb $a0,boardline1($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,8
	lb $a0,boardline1($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,12
	lb $a0,boardline1($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
	
	li $v0,1
	li $t5,16
	lb $a0,boardline1($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
	li $v0,1
	li $t5,20
	lb $a0,boardline1($t5)
	syscall
	li $a0, 32
    	li $v0, 11  
    	syscall
    	
    	li $v0,1
	li $t5,24
	lb $a0,boardline1($t5)
	syscall
	
	li $v0,4
	la $a0,nline
	syscall
	
	jr $ra
printStatus1: #print remaining
	la $a0, promptvio
	li $v0, 4
	syscall
	la $a3, list1
	lb $a0, 0($a3)
	li $v0, 1
	syscall
	li $v0,4
	la $a0,nline
	syscall
	
	la $a0, promptundo
	li $v0, 4
	syscall
	lb $a0, 4($a3)
	li $v0, 1
	syscall
	li $v0,4
	la $a0,nline
	syscall
	
	la $a0, promptblo
	li $v0, 4
	syscall
	lb $a0, 8($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	
	la $a0, promptcou
	li $v0, 4
	syscall
	lb $a0, 12($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	
	la $a0, name1
	li $v0,4
	syscall
	la $a0,nline
	syscall
	jr $ra

printStatus2:
	la $a0, promptvio
	li $v0, 4
	syscall
	la $a3, list2
	lb $a0, 0($a3)
	li $v0, 1
	syscall
	li $v0,4
	la $a0,nline
	syscall
	
	la $a0, promptundo
	li $v0, 4
	syscall
	lb $a0, 4($a3)
	li $v0, 1
	syscall
	li $v0,4
	la $a0,nline
	syscall
	
	la $a0, promptblo
	li $v0, 4
	syscall
	lb $a0, 8($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	
	la $a0, promptcou
	li $v0, 4
	syscall
	lb $a0, 12($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	
	la $a0, name2
	li $v0,4
	syscall
	la $a0,nline
	syscall
	jr $ra

################################  Start WinCheck ################################ 
WinCheck:    	
     	#Must check FOUR different directions a win can happen:
     	#1. Horizontal Line
     	#2. Vertical Line
     	#3. Forward Slash
     	#4. Backward Slas
     	#5. Check for Full Board (Tie)
     	
     	addiu $sp, $sp, -4
     	sw $ra, ($sp)
     	
        li $t8, 7		#Constant 7 used for modulo divison for left-most and right-most checking
          	 	
    	#-----------------Check horizontal-----------------#
     	#From start, go LEFT as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching LEFT
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching RIGHT
        checkLeft:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the leftmost slot, skip to check right
     	div $t2, $t8
     	mfhi $t3		#The modulo result of offset value % 7 
     	beqz $t3, checkRight	#If result = 0 then go to check right
     	
     	#Else look at slot to our left
     	lb $t1, -1($t0)			#Left of current location
     	bne $t1, $a0, checkRight	#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next left
     	addiu $t2, $t2, -1
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkLeft
     	
     	#From start, go RIGHT as far possible
	checkRight:
	la $t0, boardArray($t4)
	
	#If we are at rightmost slot, end horizontal checking
	div $t4, $t8
	mfhi $t3
	beq $t3, 6, endHorz	#If modulo result = 6 then we know we are in rightmost slot
	
	#Else look at slot to our right
	lb $t1, 1($t0)		#Right of current location
	bne $t1, $a0, endHorz	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, 1	#Move to next value to the right
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkRight
	
	endHorz:
	#-----------------End Horizontal Check-----------------#
     	
     	#-----------------Check vertical-----------------#
     	#From start, go UP as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UP
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DOWN
        checkUp:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row, skip to checkDown
     	bgtu $t2, 34, checkDown	#If our offset is greater than 34 that means we are on the top row
     	
     	#Else look at slot above us
     	lb $t1, 7($t0)			#Left of current location
     	bne $t1, $a0, checkDown		#If value is not equal to player number, then proceed to check down
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next row up
     	addiu $t2, $t2, 7
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUp
     	
     	#From start, go DOWN as far possible
	checkDown:
	la $t0, boardArray($t4)
	
	#If we are at bottom row, end vertical checking
	bltu $t4, 7, endVert
	
	#Else look at slot below us
	lb $t1, -7($t0)		#Below current location
	bne $t1, $a0, endVert	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -7	#Move to next value below current location
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDown
	
	endVert:  
     	#-----------------End Vertical Check-----------------#
     	
     	#-----------------Check forward-slash diagonal-----------------#
	#From start, go UP-RIGHT (UR) as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UR
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DL
        checkUR:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row OR we are at the rightmost coloumn, then skip to down-left
     	bgtu $t2, 34, checkDL	#If our offset is greater than 34 that means we are on the top row
	div $t2, $t8
	mfhi $t3
	beq $t3, 6, checkDL	#If modulo result = 6 then we know we are in rightmost slot
     	
     	#Else look at slot above us and over to the right 
     	lb $t1, 8($t0)			#UR of current location
     	bne $t1, $a0, checkDL		#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next value in pattern
     	addiu $t2, $t2, 8
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUR
     	
     	#From start, go DOWN-LEFT (DL) as far possible
	checkDL:
	la $t0, boardArray($t4)
	
	#If we are at bottom row OR leftmost column, then end FSDiag checking
	bltu $t4, 7, endFSDiag	#Bottom row test
	div $t4, $t8
	mfhi $t3
	beq $t3, 0, endFSDiag	#Leftmost column test
	
	#Else look at slot below us and over to the left one
	lb $t1, -8($t0)		#DL of current location
	bne $t1, $a0, endFSDiag	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -8	#Move to next value
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDL
	
	endFSDiag:  
     	#-----------------End Forward-Slash Diagonal Check-----------------#
     
     	#-----------------Check backward-slash diagonal-----------------#
	#From start, go UP-LEFT (UL) as far possible
     	li $t9, 1		#Counter - once reaches 4 then player-$a0 wins
	move $t2, $v0		#Copy the ORIGINAL offset into $t2 for manipulation when searching UL
	move $t4, $v0		#Copy the ORIGINAL offset into $t4 for manipulation when searching DR
        checkUL:
     	la $t0, boardArray($t2)	#Load our current chip address
     	
        #If we are at the top row OR we are at the leftmost coloumn, then skip to down-right
     	bgtu $t2, 34, checkDR	#Top row test
	div $t2, $t8
	mfhi $t3
	beq $t3, 0, checkDR	#Left-most column test
     	
     	#Else look at slot above us and over to the left 
     	lb $t1, 6($t0)			#Up and Left of current position
     	bne $t1, $a0, checkDR		#If value is not equal to player number, then proceed to check right
     	addiu $t9, $t9, 1		#Else value IS player number, increment counter and check next value in pattern
     	addiu $t2, $t2, 6
	bgt $t9, 3, PlayerWon		#If player has more than 3 connected (so 4+), then they won
     	j checkUL
     	
     	#From start, go DOWN-RIGHT (DR) as far possible
	checkDR:
	la $t0, boardArray($t4)
	
	#If we are at bottom row OR rightmost column, then end BSDiag checking
	bltu $t4, 7, endBSDiag	#Bottom row test
	div $t4, $t8
	mfhi $t3
	beq $t3, 6, endBSDiag	#Right-most column test
	
	#Else look at slot below us and over to the right one
	lb $t1, -6($t0)		#BR of current location
	bne $t1, $a0, endBSDiag	#If value is not player number, end checking
	addiu $t9, $t9, 1	#Else increment coutner
	addiu $t4, $t4, -6	#Move to next value
	bgt $t9, 3, PlayerWon	#If player has more than 3 connected (so 4+), then they won
	j checkDR
	
	endBSDiag:     	
     	#-----------------End Backward-Slash Diagonal Check-----------------#
     	
     	#-----------------Start Full Board Check-----------------#
     	li $t9, 35		#Load the offset for the top row of the gameboard
     	la $t0, boardArray($t9)
     	
     	li $t2, 0		#Counter for # of player chips in top row
    	checkTop:
    	lb $t1, ($t0)
    	beqz $t1, endTie	#If a blank slot is found then stop checking
    	addi $t0, $t0, 1
    	add $t2, $t2, 1	
    	beq $t2, 7, GameTie	#If there are 7 chips in top row, it's a tie
    	j checkTop	
    
    	endTie:
     	#-----------------End Full Board Check-----------------#
     	
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra	#Return to game after all checks are made
	

################################  End WinCheck ################################ 

#Sub-Procedure: GameTie
#Triggered when the top row of game board is filled and no one is a winner
GameTie:
	la $a0, prompt7
	li $v0, 4
	syscall
	jal printBoard
	li $v0, 10
	syscall


#Procedure: PlayerWon
#Input: $a0 - Player Number
#Triggered when a player wins a game
#Will show winner message then exit program
PlayerWon:
	beq $a0, 1 player1Win	#If player 1 won, jump to second instruction set
	
	#Player 2 Won
	jal printBoard
	la $a0, name2
	li $v0,4
	syscall
	la $a0, prompt3
	li $v0, 4
	syscall
	la $a0, promptcou
	li $v0, 4
	syscall
	la $a3, list2
	lb $a0, 12($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	la $a3, list1
	lb $t0, 0($a3)
	beq $t0, 3, Reason
	li $v0, 10
	syscall
	
	#Player 1 Won
	player1Win:
	jal printBoard
	la $a0, name1
	li $v0,4
	syscall
	la $a0, prompt3
	li $v0, 4
	syscall
	la $a0, promptcou
	li $v0, 4
	syscall
	la $a3, list1
	lb $a0, 12($a3)
	li $v0, 1
	syscall
	la $a0,nline
	li $v0, 4
	syscall
	la $a3, list2
	lb $t0, 0($a3)
	beq $t0, 3, Reason
	li $v0, 10
	syscall

	Reason:
	la $a0, prompt10
	li $v0, 4
	syscall








