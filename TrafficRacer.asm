###################################################################### 
# CSCB58 Summer 2022 Project 
# University of Toronto, Scarborough 
# 
# Student Name: Bryan Wan, Student Number: 1007096642, UTorID: wanbrya1 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256 
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 
# 
# Basic features that were implemented successfully 
# - Draw the background of the game
# - Draw objects of the game: lines, player car, enemy cars, extra life, invisibility
# - Keyboard input moves car left/right, and increase/decrease speed.
# - Objects move in both directions
# - It car collides with enemy cars or roadside, reset the starting position
# - Total number of lives currently is displayed
# - Cars move at different speeds depening on difficulty/player speed
# - Retry Screen after player runs out of lives. If 'y' is pressed, retry. If 'n' is pressed, finish the program.
# Additional features that were implemented successfully 
# - Added 2 pickups such as extra life and invisibility/invinsibility
# - Display the current score at the bottom right. Score is reset when collision occurs.
# - Current level of difficulty displayed at bottom left
# - When score is greater than 10, the harder levels starts. Cars move much faster and enemy cars appear in groups of 2.
#  
# Link to the video demo 
# - https://youtu.be/TJyV6dBUfOk
# 
# Any additional information that the TA needs to know: 
# - Write here, if any 
#  
###################################################################### 
.data
	linestop: .word 0x10006FFC
	displayAddress: .word 0x10008000
	hiddenAddress: .word 0x10007E00 
	hiddenend: .word 0x10009280
	obstaCar1: .word 0x10008088
	obstaCar2: .word 0x100080A4
	obstaCar3: .word 0x100092CC 
	obstaCar4: .word 0x100092E8
	road1car: .word 0x10008708
	road2car: .word 0x10008724
	road3car: .word 0x1000874C
	road4car: .word 0x10008768
	maincarcol: .word 0x800080
	enemycarcol: .word 0xff0000
	roadcolour: .word 0x708090
	tire: .word 0x000000 
	yellow: .word 0xFFD700
	endscreen: .word 0x100092E8
	heart: .word 0xBA55D3
	white: .word 0xFFFFFF
	scorecolor: .word 0x90EE90
.text


restart:
	addi $t7, $zero, 3
	jal setup
	j refreshstate
removelife:
	addi $t7, $t7, -1
	beq $t7, 0, iszero

iszero:	beq $t7, 0, EndScreen
	
starthere: 
	jal collidedsetup

refreshstate:

	beq $s1, 1, lane1	
	beq $s1, 2, lane2	
	beq $s1, 3, lane3	
	beq $s1, 4, lane4

lane1: 	jal refreshscreen
	li $v0, 32  
	li $a0, 25 
	syscall 
	
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	bne $t0, 1, lane1
	
	lw $t0, 4($t1)
	beq $t0, 0x71, restart
	beq $t0, 0x64, lane1right
	bgtz $s4, see1
	beq $t0, 0x61, removelife
see1:	beq $t0, 0x77, incr
	beq $t0, 0x73, decr	
	j cont
incr:	beq $s5, 2, cont
	addi $s5, $s5, 1
	j cont
decr:	beq $s5, 0, cont
	addi $s5, $s5, -1
cont:	j lane1
lane1right:
	
	lw $a0, road1car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	
	lw $a0, road2car
	lw $a3, white
	lw $t0, 4($a0)
	beq $t0, $a3, makeinvis
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis
	
	j noinv
makeinvis:
	li $s4, 5
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 2
	jal reprintcar
	
noinv:	ble $s4, 0, noninvis
	lw $a0, road2car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	j sendinv
noninvis:
	
	lw $a0, road2car 
	lw $a1, maincarcol 
	lw $a2, tire 

	lw $a3, heart
	
	lw $t0, 4($a0)
	beq $t0, $a3, addlife1r
	lw $t0, 132($a0)
	beq $t0, $a3, addlife1r
	lw $t0, 260($a0)
	beq $t0, $a3, addlife1r

	j nolr
addlife1r:
	addi $t7, $t7, 1
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 2
	jal reprintcar
	j sendinv
	
nolr:	lw $a3, roadcolour
	lw $t0, 0($a0)
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	
	
	jal printcar

sendinv:li $s1, 2
	j refreshstate
	
lane2: 	
	jal refreshscreen
	li $v0, 32  
	li $a0, 25 
	syscall 
	
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	
	bne $t0, 1, lane2

	lw $t0, 4($t1)
	beq $t0, 0x71, restart
	beq $t0, 0x61, lane2left
	beq $t0, 0x64, lane2right
	
	beq $t0, 0x77, incr1
	beq $t0, 0x73, decr1	
	j cont1
incr1:	beq $s5, 2, cont1
	addi $s5, $s5, 1
	j cont1
decr1:	beq $s5, 0, cont1
	addi $s5, $s5, -1
cont1:	j lane2
lane2left:
	lw $a0, road2car
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	lw $a0, road1car
	lw $a3, white
	lw $0, 4($a0)
	beq $t0, $a3, makeinvis1
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis1
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis1
	j noinv1
makeinvis1:
	li $s4, 5
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 1
	jal reprintcar
	
	
noinv1:	ble $s4, 0, noninvis1
	
	lw $a0, road1car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar

	j sendinv1
noninvis1:
	lw $a0, road1car 
	lw $a1, maincarcol 
	lw $a2, tire

	lw $a3, heart
	beq $t0, $a3, addlife2l
	lw $t0, 132($a0)
	beq $t0, $a3, addlife2l
	lw $t0, 256($a0)
	beq $t0, $a3, addlife2l
	j no2l
addlife2l:
	addi $t7, $t7, 1
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 1
	jal reprintcar
	
	j sendinv1
	
no2l:	lw $a3, roadcolour
	lw $t0, 0($a0)
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	jal printcar
sendinv1:
	li $s1, 1
	j refreshstate
lane2right:
	
	lw $a0, road2car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	lw $a0, road3car
	lw $a1, maincarcol 
	lw $a2, tire 

	lw $a3, white
	lw $t0, 4($a0)
	beq $t0, $a3, makeinvis2
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis2
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis2
	j noinv2
makeinvis2:
	li $s4, 5
	li $t4, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 3
	jal reprintcar

noinv2:	ble $s4, 0, noninvis2
	lw $a0, road3car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	j sendinv2
noninvis2:
	lw $a0, road3car 
	lw $a1, maincarcol 
	lw $a2, tire 
	
	lw $a3, heart
	beq $t0, $a3, addlife2r
	lw $t0, 132($a0)
	beq $t0, $a3, addlife2r 
	lw $t0, 256($a0)
	beq $t0, $a3, addlife2r
	j no2r
addlife2r:
	addi $t7, $t7, 1
	li $t4, 0
	
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 3
	jal reprintcar
	
	j sendinv2
	
no2r:	lw $a3, roadcolour
	lw $t0, 0($a0)
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	jal printcar
sendinv2:
	li $s1, 3
	j refreshstate
lane3: 	
	jal refreshscreen
	li $v0, 32  
	li $a0, 25 
	
	syscall 
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	bne $t0, 1, lane3
	
	lw $t0, 4($t1)
	beq $t0, 0x71, restart
	beq $t0, 0x61, lane3left
	beq $t0, 0x64, lane3right
	
	beq $t0, 0x77, incr2
	beq $t0, 0x73, decr2	
	j cont2
incr2:	beq $s5, 2, cont2
	addi $s5, $s5, 1
	j cont2
decr2:	beq $s5, 0, cont2
	addi $s5, $s5, -1	
cont2:	j lane3
lane3left:
	lw $a0, road3car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	lw $a0, road2car
	lw $a3, white
	lw $t0, 4($a0)
	beq $t0, $a3, makeinvis3
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis3
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis3
	j noinv3
makeinvis3:
	
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 4
	jal reprintcar
	li $s4, 5
	
noinv3:	ble $s4, 0, noninvis3
	lw $a0, road2car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	j sendinv3
noninvis3:
	lw $a0, road2car 
	lw $a1, maincarcol 
	lw $a2, tire 
	
	lw $a3, heart
	
	lw $t0, 4($a0)
	beq $t0, $a3, addlife3l
	lw $t0, 132($a0)
	beq $t0, $a3, addlife3l
	lw $t0, 260($a0)
	beq $t0, $a3, addlife3l
	j no3l
	
addlife3l:	
	addi $t7, $t7, 1
	li $s3, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 2
	jal reprintcar
	j sendinv3
	
no3l:	lw $t0, 0($a0)
	lw $a3, roadcolour
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	jal printcar
sendinv3:
	li $s1, 2
	j refreshstate
lane3right:
	lw $a0, road3car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	lw $a0, road4car
	lw $a3, white
	lw $t0, 4($a0)
	beq $t0, $a3, makeinvis4
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis4
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis4
	j noinv4
makeinvis4:
	li $t4, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 4
	jal reprintcar
	li $s4, 5

noinv4:	ble $s4, 0, noninvis4
	lw $a0, road4car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	j sendinv4
noninvis4:
	lw $a0, road4car 
	lw $a1, maincarcol 
	lw $a2, tire 

	lw $a3, heart
	lw $t0, 4($a0)
	beq $t0, $a3, addlife3r
	lw $t0, 132($a0)
	beq $t0, $a3, addlife3r
	lw $t0, 260($a0)
	beq $t0, $a3, addlife3r
	lw $a3, roadcolour
	j no3r
	
addlife3r:
	addi $t7, $t7, 1
	li $t4, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 4
	jal reprintcar
	j sendinv4
	
no3r:	lw $t0, 0($a0)
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	jal printcar
sendinv4:	
	li $s1, 4
	j refreshstate	
lane4: 	
	jal refreshscreen
	li $v0, 32  
	li $a0, 25 
	
	syscall 
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	bne $t0, 1, lane4
	
	lw $t0, 4($t1)
	beq $t0, 0x71, restart
	beq $t0, 0x61, lane4left
	bgtz $s4, see2
	beq $t0, 0x64, removelife
see2:	beq $t0, 0x77, incr3
	beq $t0, 0x73, decr3	
	j cont3
incr3:	beq $s5, 2, cont3
	addi $s5, $s5, 1
	j cont3
decr3:	beq $s5, 0, cont3
	addi $s5, $s5, -1
cont3:	j lane4
lane4left:
	lw $a0, road4car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	lw $a0, road3car
	lw $a3, white
	lw $t0, 4($a0)
	beq $t0, $a3, makeinvis5
	lw $t0, 132($a0)
	beq $t0, $a3, makeinvis5
	lw $t0, 260($a0)
	beq $t0, $a3, makeinvis5
	j noinv5
makeinvis5:
	li $t4, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 3
	jal reprintcar
	li $s4, 5

noinv5:	ble $s4, 0, noninvis5
	lw $a0, road3car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	j sendinv5
noninvis5:
	lw $a0, road3car 
	lw $a1, maincarcol 
	lw $a2, tire 	
	
	lw $a3, heart
	lw $t0, 4($a0)
	beq $t0, $a3, addlife4l
	lw $t0, 132($a0)
	beq $t0, $a3, addlife4l
	lw $t0, 260($a0)
	beq $t0, $a3, addlife4l
	j no4l
addlife4l:
	addi $t7, $t7, 1
	li $t4, 0
	lw $a1, roadcolour
	jal clearcircle
	lw $a1, maincarcol
	lw $a2, tire 
	li $s1, 3
	jal reprintcar
	j sendinv5
	
no4l:	lw $t0, 0($a0)
	lw $a3, roadcolour
	bne $t0, $a3, removelife 
	lw $t0, 132($a0)
	bne $t0, $a3, removelife 
	lw $t0, 256($a0)
	bne $t0, $a3, removelife
	jal printcar
sendinv5:	
	li $s1, 3
	j refreshstate
	


printbackground:
	addi $t3, $zero, 0
	addi $t4, $zero, 0
start:	beq $t3, 32, end
	lw $t0, displayAddress 
	add $t0, $t0, $t4
	addi $t2, $zero, 0
	addi $t3, $t3, 1
	addi $t4, $t4, 4
loop:	beq $t2, 48, start
	li $t1, 0x708090                   
	sw $t1, 0($t0)             
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j loop
end:	lw $t0, displayAddress
	addi $t0, $t0, 0
	addi $t2, $zero, 0
border2:beq $t2, 32, end3
	li $t1, 0x000000                   
	sw $t1, 0($t0)             
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j border2
end3:	lw $t0, displayAddress
	addi $t0, $t0, 124
	addi $t2, $zero, 0
border3:beq $t2, 32, end4
	li $t1, 0x000000                   
	sw $t1, 0($t0)             
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j border3
end4:	lw $t0, displayAddress
	addi $t0, $t0, 60
	addi $t2, $zero, 0
middle: beq $t2, 32, end5
	lw $t1, yellow                
	sw $t1, -4($t0)             
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j middle
end5:	lw $t0, displayAddress
	addi $t0, $t0, 64
	addi $t2, $zero, 0
middle2:beq $t2, 32, returnBackground
	lw $t1, yellow                 
	sw $t1, 4($t0)             
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j middle2
returnBackground:
	jr $ra
	
		
#------------------------------------------------------------------------------------------------
printlines:
	

	lw $t2, roadcolour                  
	sw $t1, 32($t8)
	sw $t1, 160($t8)                 
	sw $t2, 288($t8)
	sw $t2, 416($t8)                 
	sw $t1, 544($t8)
	sw $t1, 672($t8)                 
	sw $t2, 800($t8)
	sw $t2, 928($t8)                 
	sw $t1, 1056($t8)
	sw $t1, 1184($t8)                 
	sw $t2, 1312($t8)
	sw $t2, 1440($t8)                 
	sw $t1, 1568($t8)
	sw $t1, 1696($t8)                 
	sw $t2, 1824($t8)
	sw $t2, 1952($t8)                 
	sw $t1, 2080($t8)
	sw $t1, 2208($t8)                 
	sw $t2, 2336($t8)
	sw $t2, 2464($t8)                 
	sw $t1, 2592($t8)
	sw $t1, 2720($t8)                 
	sw $t2, 2848($t8)
	sw $t2, 2976($t8)                 
	sw $t1, 3104($t8)
	sw $t1, 3232($t8)  
	sw $t2, 3360($t8)  
	sw $t2, 3488($t8)  
	sw $t1, 3616($t8)  
	sw $t1, 3744($t8)  
	sw $t2, 3872($t8)  
	sw $t2, 4000($t8)
	
	sw $t1, 4128($t8)
	sw $t1, 4256($t8)                 
	sw $t2, 4384($t8)
	sw $t2, 4512($t8)                 
	sw $t1, 4640($t8)
	sw $t1, 4768($t8)                 
	sw $t2, 4896($t8)
	sw $t2, 5024($t8)                 
	sw $t1, 5152($t8)
	sw $t1, 5280($t8)                 
	sw $t2, 5408($t8)
	sw $t2, 5536($t8)                 
	sw $t1, 5664($t8)
	sw $t1, 5792($t8)                 
	sw $t2, 5920($t8)
	sw $t2, 6048($t8)                 
	sw $t1, 6176($t8)
	sw $t1, 6304($t8)                 
	sw $t2, 6432($t8)
	sw $t2, 6560($t8)                 
	sw $t1, 6688($t8)
	sw $t1, 6816($t8)                 
	sw $t2, 6944($t8)
	sw $t2, 7072($t8)                 
	sw $t1, 7200($t8)
	sw $t1, 7328($t8)  
	sw $t2, 7456($t8)  
	sw $t2, 7584($t8)  
	sw $t1, 7712($t8)
	sw $t1, 7840($t8)  
     	sw $t2, 7968($t8)  
	sw $t2, 8096($t8)  
	jr $ra

printcar:	
	
	move $t0, $a0
	move $t1, $a1
	move $t2, $a2

	sw $t2, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t2, 12($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t2, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t2, 268($t0)
	
	jr $ra

printcircle:	
	
	move $t0, $a0
	move $t1, $a1

	sw $t1, 4($t0)
	sw $t1, 8($t0)

	sw $t1, 132($t0)
	sw $t1, 136($t0)


	
	jr $ra
	
clearcircle:	
	
	move $t0, $a0
	move $t1, $a1

	sw $t1, -124($t0)
	sw $t1, -120($t0)

	sw $t1, 4($t0)
	sw $t1, 8($t0)

	sw $t1, 132($t0)
	sw $t1, 136($t0)

	sw $t1, 260($t0)
	sw $t1, 264($t0)
	
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	jr $ra	
	
setup: 	addi $sp, $sp, -4
	sw $ra, 0($sp)


	jal printbackground
	li $s3, 0
	li $t3, 0
	li $s0, -2
	li $t9, 0
	li $s4, 0
	lw $a0, road2car 
	lw $a1, maincarcol 
	lw $a2, tire 
	jal printcar
	li $t1, 0xF8F8FF 
	lw $t8, linestop
	jal printlines
	addi $t8, $t8, 68
	jal printlines
	addi $t8, $t8, -68
	jal liveone
	jal printlives
	li $t4, 0

	j CheckStart
	
collidedsetup:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printbackground
	li $s3, 0
	li $t3, 0
	li $t9, 0
	li $s0, 0
	li $s4, 0
	lw $a0, road2car 
	lw $a1, maincarcol 
	lw $a2, tire 
	jal printcar
	li $t1, 0xF8F8FF 
	lw $t8, linestop
	jal printlines
	addi $t8, $t8, 68
	jal printlines
	addi $t8, $t8, -68
	li $v0, 32  
	li $a0, 200
	syscall 
	jal printlives
	li $s1, 2 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

CheckStart:
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	bne $t0, 1, sleep100
	
	li $s5, 0
	
	lw $t0, 4($t1)

	li $s1, 2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
sleep100:
	li $v0, 32  
	li $a0, 100 
	syscall 
	j CheckStart

movetoleft:
	lw $a0, road2car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar

	lw $a0, road1car 
	lw $a1, maincarcol 
	lw $a2, tire 
	jal printcar
	
	li $s1, 1 
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
movetoright:
	lw $a0, road2car 
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	li $s1, 3 
	

	lw $a0, road3car 
	lw $a1, maincarcol 
	lw $a2, tire 
	jal printcar
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

refreshscreen:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal createobstacars
	j movelines
linesmove:
	j checkleft
rightcheck:
	j checkright
lives:	

	jal liveone
	j finish

finish:	
	jal printlives
	jal printscore
	jal printlevel
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


movelines:
	bgt $t8, 0x100080A8, resetlines
	lw $t1, roadcolour 
	jal printlines
	addi $t8, $t8, 68
	jal printlines

	
	addi $t8, $t8, -68
	
	bne $t3, 0, slowlines

	beq $s5, 0, speed1lines
	beq $s5, 1, speed2lines
	beq $s5, 2, speed3lines
speed1lines:
	addi $t8, $t8, 128
	j slowfactorlines
speed2lines:
	addi $t8, $t8, 256
	j slowfactorlines
speed3lines:
	addi $t8, $t8, 384
	
slowfactorlines:
	bge $s0, 10, fastest
	addi $t3, $t3, 10
	j slowlines
fastest:addi $t3, $t3, 5
slowlines:
	li $t1, 0xF8F8FF 
	jal printlines
	addi $t8, $t8, 68
	jal printlines
	addi $t8, $t8, -68
	addi $t3, $t3, -1
	j linesmove
resetlines:
	lw $t8, linestop
	j linesmove	
	
checkleft:
	jal updateleft
	j rightcheck
checkright:
	jal updateright
	j lives

updateleft:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bgt $s6, 0x10009288, reset
	bgt $s6, 0x100092A8, reset
	move $a0, $s6 

	beq $t5, 1, life
	beq $t5, 2, invis
	beq $t5, 3, doubleside
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	
	bne $s7, 0, slow

	beq $s5, 0, speed1
	beq $s5, 1, speed2
	beq $s5, 2, speed3
speed1:	addi $s6, $s6, 128
	j slowfactor
speed2:	addi $s6, $s6, 256
	j slowfactor
speed3:	addi $s6, $s6, 384	
	
slowfactor:
	bge $s0, 10, faster
	addi $s7, $s7, 8
	j slow
faster: addi $s7, $s7, 3
slow:	move $a0, $s6
	lw $a1, enemycarcol 
	lw $a2, tire 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife	

	jal printcar
	addi $s7, $s7, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
reset:	li $s3, 0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

life:	
	lw $a1, roadcolour 
	jal printcircle
	
	bne $s7, 0, slowh

	beq $s5, 0, speed1h
	beq $s5, 1, speed2h
	beq $s5, 2, speed3h
speed1h:	addi $s6, $s6, 128
	j slowfactorh
speed2h:	addi $s6, $s6, 256
	j slowfactorh
speed3h:	addi $s6, $s6, 384	
	
slowfactorh:
	bge $s0, 10, fasterh
	addi $s7, $s7, 8
	j slowh
fasterh:addi $s7, $s7, 3
	
slowh:	move $a0, $s6
	lw $a1, heart 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, addlife 
	lw $t0, 132($a0)
	beq $t0, $a3, addlife 
	lw $t0, 260($a0)
	beq $t0, $a3, addlife
	j nolife
addlife:addi $t7, $t7, 1
	li $s3, 0
	lw $a1, maincarcol
	lw $a2, tire 
	jal reprintcar
nolife:	jal printcircle
	addi $s7, $s7, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
invis:	
	lw $a1, roadcolour 
	jal printcircle
	
	bne $s7, 0, slowi

	beq $s5, 0, speed1i
	beq $s5, 1, speed2i
	beq $s5, 2, speed3i
speed1i:	addi $s6, $s6, 128
	j slowfactori
speed2i:	addi $s6, $s6, 256
	j slowfactori
speed3i:	addi $s6, $s6, 384	
	
slowfactori:
	bge $s0, 10, fasteri
	addi $s7, $s7, 8
	j slowi
fasteri:
	addi $s7, $s7, 3
	
slowi:	move $a0, $s6
	lw $a1, white 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, goinvis 
	lw $t0, 132($a0)
	beq $t0, $a3, goinvis 
	lw $t0, 260($a0)
	beq $t0, $a3, goinvis
	j noinvis
goinvis:	
	
	li $s3, 0
	lw $a1, roadcolour
	lw $a2, roadcolour 
	jal reprintcar
	li $s4, 5

noinvis:
	jal printcircle
	addi $s7, $s7, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

doubleside:
lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	addi $a0, $a0, 28
	jal printcar
	addi $a0, $a0, -28
	bne $s7, 0, slowd

	beq $s5, 0, speed1d
	beq $s5, 1, speed2d
	beq $s5, 2, speed3d
speed1d:	addi $s6, $s6, 128
	j slowfactord
speed2d:	addi $s6, $s6, 256
	j slowfactord
speed3d:	addi $s6, $s6, 384	
	
slowfactord:
	bge $s0, 10, fasterd
	addi $s7, $s7, 8
	j slowd
fasterd:
	addi $s7, $s7, 3
	
slowd:	move $a0, $s6
	lw $a1, enemycarcol 
	lw $a2, tire 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife	
	jal printcar
	addi $a0, $a0, 28
	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife	
	jal printcar
	addi $a0, $a0, -28
	addi $s7, $s7, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

updateright:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	blt $s2, 0x10007EC4, resetr
	blt $s2, 0x10007EE4, resetr
	bgt $s2, 0x100092E8, resetr
	move $a0, $s2 
	
	beq $t6, 1, lifer
	beq $t6, 2, invisr
	beq $t6, 3, doubleside1
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar

	bne $t9, 0, slowr

	beq $s5, 0, speed1r
	beq $s5, 1, speed2r
	beq $s5, 2, speed3r

speed1r:addi $s2, $s2, -256
	
	j slowfactorr
speed2r:addi $s2, $s2, -128
	j slowfactorr
speed3r:addi $s2, $s2, 128	
	
slowfactorr:
	bge $s0, 10, fasterr
	addi $t9, $t9, 9
	j slowr
fasterr:
	addi $t9, $t9, 5

slowr:	move $a0, $s2

	lw $a1, enemycarcol 
	lw $a2, tire 
	
	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife
	
	jal printcar

	addi $t9, $t9, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
resetr:	li $t4, 0

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra		

lifer:	
	lw $a1, roadcolour 
	jal printcircle

	bne $t9, 0, slowrh

	beq $s5, 0, speed1rh
	beq $s5, 1, speed2rh
	beq $s5, 2, speed3rh

speed1rh:addi $s2, $s2, -256
	j slowfactorrh
speed2rh:addi $s2, $s2, -128
	j slowfactorrh
speed3rh:addi $s2, $s2, 128	
	
slowfactorrh:
	bge $s0, 10, fasterrh
	addi $t9, $t9, 9
	j slowrh
fasterrh:
	addi $t9, $t9, 5
slowrh:	move $a0, $s2

	lw $a1, heart 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, addlifer  
	lw $t0, 132($a0)
	beq $t0, $a3, addlifer  
	lw $t0, 260($a0)
	beq $t0, $a3, addlifer

	j nolifer
addlifer:
	addi $t7, $t7, 1
	li $t4, 0
	lw $a1, maincarcol
	lw $a2, tire 
	jal reprintcar
	
nolifer:jal printcircle
	addi $t9, $t9, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
invisr:
	lw $a1, roadcolour 
	jal printcircle

	bne $t9, 0, slowri

	beq $s5, 0, speed1ri
	beq $s5, 1, speed2ri
	beq $s5, 2, speed3ri

speed1ri:addi $s2, $s2, -256
	j slowfactorri
speed2ri:addi $s2, $s2, -128
	j slowfactorri
speed3ri:addi $s2, $s2, 128	
	
slowfactorri:
	bge $s0, 10, fasterri
	addi $t9, $t9, 9
	j slowri
fasterri: addi $t9, $t9, 5
slowri:	move $a0, $s2

	lw $a1, white 

	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, goinvisr 
	lw $t0, 132($a0)
	beq $t0, $a3, goinvisr
	lw $t0, 260($a0)
	beq $t0, $a3, goinvisr 
	j noinvisr
goinvisr:
	li $t4, 0
	lw $a1, roadcolour
	lw $a2, roadcolour 
	jal reprintcar
	li $s4, 5
	
noinvisr:
	jal printcircle
	addi $t9, $t9, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

doubleside1:
	lw $a1, roadcolour 
	lw $a2, roadcolour 
	jal printcar
	addi $a0, $a0, 28
	jal printcar
	addi $a0, $a0, -28
	bne $t9, 0, slowrd

	beq $s5, 0, speed1rd
	beq $s5, 1, speed2rd
	beq $s5, 2, speed3rd

speed1rd:addi $s2, $s2, -256

	j slowfactorrd
speed2rd:addi $s2, $s2, -128
	j slowfactorrd
speed3rd:addi $s2, $s2, 128	
	
slowfactorrd:
	bge $s0, 10, fasterrd
	addi $t9, $t9, 9
	j slowrd
fasterrd:
	addi $t9, $t9, 5
slowrd:	move $a0, $s2

	lw $a1, enemycarcol 
	lw $a2, tire 
	
	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife
	jal printcar
	
	addi $a0, $a0, 28
	lw $t0, 4($a0)
	lw $a3, maincarcol
	beq $t0, $a3, removelife 
	lw $t0, 132($a0)
	beq $t0, $a3, removelife 
	lw $t0, 260($a0)
	beq $t0, $a3, removelife
	jal printcar
	addi $a0, $a0, -28
	addi $t9, $t9, -1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra


createobstacars:
	addi $sp, $sp, -4
	sw $ra, ($sp)	

	beq $s3, 0, randomcar1
randotwo:
	beq $t4, 0, randomcar2
ret:	lw $ra, ($sp)
	add $sp , $sp , 4
	jr $ra
randomcar1:
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	blez $s4,resee
	addi $s4, $s4, -1
	j nosee
resee:	lw $a1, maincarcol
	lw $a2, tire 
	jal reprintcar
	
nosee:	lw $t0, hiddenAddress
	li $v0, 42
	li $a0, 0
	bge $s0, 10, harder1
	li $a1, 16
	j easy1
harder1:li $a1, 22	
easy1:	syscall
	ble $a0, 0  heartenemy
	ble $a0, 1, heartenemy1
	ble $a0, 2  invisenemy
	ble $a0, 3, invisenemy1
	ble $a0, 9  enemy1
	ble $a0, 15, enemy2
	beq $a0, 21, double

double:
	li $t5, 3
	lw $s6, obstaCar1
	j randotwo
enemy1:
	li $t5, 0
	lw $s6, obstaCar1
	j randotwo
enemy2:
	li $t5, 0
	lw $s6, obstaCar2
	j randotwo
heartenemy:
	li $t5, 1
	lw $s6, obstaCar1
	j randotwo
heartenemy1:
	li $t5, 1
	lw $s6, obstaCar2
	j randotwo
	
invisenemy:
	li $t5, 2
	lw $s6, obstaCar1
	j randotwo
invisenemy1:
	li $t5, 2
	lw $s6, obstaCar2
	j randotwo
	
randomcar2:
	addi $s0, $s0, 1
	addi $t4, $t4, 1	
	blez $s4, resee1
	addi $s4, $s4, -1
	j nosee1
resee1:	lw $a1, maincarcol
	lw $a2, tire 
	jal reprintcar
	
nosee1:	lw $t0, hiddenAddress
	li $v0, 42
	li $a0, 0
	bge $s0, 10, harder
	li $a1, 10
	j easy
harder: li $a1, 22
easy:	syscall
	ble $a0, 0  heartenemy3
	ble $a0, 1, heartenemy4
	ble $a0, 2  invisenemy3
	ble $a0, 3, invisenemy4
	ble $a0, 9  enemy3
	ble $a0, 15, enemy4
	beq $a0, 21, double1
double1:
	li $t6, 3
	beq $s5, 2, upd
	lw $s2, obstaCar3
	j ret
upd:	li $s2, 0x1000814C
	j ret	
enemy3:
	li $t6, 0
	beq $s5, 2, up
	lw $s2, obstaCar3
	j ret
up:	li $s2, 0x1000814C
	j ret
enemy4:
	li $t6, 0
	beq $s5, 2, up1
	lw $s2, obstaCar4
	j ret
up1:	li $s2, 0x10008168
	j ret
heartenemy3:
	li $t6, 1
	beq $s5, 2, up2
	lw $s2, obstaCar3
	j ret
up2:	li $s2, 0x1000814C
	j ret
heartenemy4:
	li $t6, 1
	beq $s5, 2, up3
	lw $s2, obstaCar4
	j ret
up3:	li $s2, 0x10008168
	j ret
invisenemy3:
	li $t6, 2
	beq $s5, 2, up4
	lw $s2, obstaCar3
	j ret
up4:	li $s2, 0x1000814C
	j ret

invisenemy4:
	li $t6, 2
	beq $s5, 2, up5
	lw $s2, obstaCar4
	j ret
up5:	li $s2, 0x10008168
	j ret
	
EndScreen:
	addi $t3, $zero, 0
	addi $t4, $zero, 0
starter:beq $t3, 32, Game
	lw $t0, displayAddress 
	add $t0, $t0, $t4
	addi $t2, $zero, 0
	addi $t3, $t3, 1
	addi $t4, $t4, 4
looper:	beq $t2, 48, starter
	li $t1, 0x000000                
	sw $t1, 0($t0)            
	addi $t0, $t0, 128
	addi $t2, $t2, 1
	j looper
Game:	lw $t0, displayAddress 
	lw $t1, endscreen
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 392($t0)
	sw $t1, 520($t0)
	sw $t1, 648($t0)
	sw $t1, 776($t0)
	sw $t1, 904($t0)
	sw $t1, 1032($t0)
	sw $t1, 404($t0)
	sw $t1, 532($t0)
	sw $t1, 660($t0)
	sw $t1, 656($t0)
	sw $t1, 652($t0)
	sw $t1, 780($t0)
	sw $t1, 912($t0)
	sw $t1, 1044($t0)
	
	sw $t1, 284($t0)
	sw $t1, 288($t0)
	sw $t1, 292($t0)
	sw $t1, 296($t0)
	sw $t1, 412($t0)
	sw $t1, 540($t0)
	sw $t1, 668($t0)
	sw $t1, 672($t0)
	sw $t1, 676($t0)
	sw $t1, 680($t0)
	
	sw $t1, 796($t0)
	sw $t1, 924($t0)
	sw $t1, 1052($t0)
	sw $t1, 1056($t0)
	sw $t1, 1060($t0)
	sw $t1, 1064($t0)
	
	sw $t1, 304($t0)
	sw $t1, 308($t0)
	sw $t1, 312($t0)
	sw $t1, 316($t0)
	sw $t1, 320($t0)
	
	sw $t1, 440($t0)
	sw $t1, 568($t0)
	sw $t1, 696($t0)
	sw $t1, 824($t0)
	sw $t1, 952($t0)
	sw $t1, 1080($t0)

	sw $t1, 328($t0)
	sw $t1, 332($t0)
	sw $t1, 336($t0)
	sw $t1, 340($t0)
	sw $t1, 456($t0)
	sw $t1, 584($t0)
	sw $t1, 712($t0)
	sw $t1, 840($t0)
	sw $t1, 968($t0)
	sw $t1, 1096($t0)

	sw $t1, 468($t0)
	sw $t1, 596($t0)
	sw $t1, 724($t0)
	sw $t1, 720($t0)
	sw $t1, 716($t0)

	sw $t1, 844($t0)
	sw $t1, 976($t0)
	sw $t1, 1108($t0)
	
	sw $t1, 348($t0) 
	sw $t1, 480($t0) 
	sw $t1, 612($t0)  
	sw $t1, 488($t0)  
	sw $t1, 364($t0)  
	sw $t1, 740($t0)  
	sw $t1, 868($t0)  
	sw $t1, 996($t0)  
	sw $t1, 1124($t0)  
	
	sw $t1, 1564($t0) 
	sw $t1, 1696($t0) 
	sw $t1, 1828($t0)  
	sw $t1, 1704($t0)  
	sw $t1, 1580($t0)  
	sw $t1, 1956($t0)  
	sw $t1, 2084($t0)  
	sw $t1, 2212($t0)  
	
	sw $t1, 2476($t0) 
	sw $t1, 2352($t0)
	sw $t1, 2224($t0)
	sw $t1, 2100($t0)
	sw $t1, 1972($t0)
	sw $t1, 1848($t0)
	sw $t1, 1720($t0)
	sw $t1, 1596($t0)
	sw $t1, 1468($t0)
	
	sw $t1, 1608($t0)
	sw $t1, 1736($t0)
	sw $t1, 1864($t0)
	sw $t1, 1992($t0)
	sw $t1, 2120($t0)
	sw $t1, 2248($t0)
	
	sw $t1, 1740($t0)
	sw $t1, 1872($t0)
	sw $t1, 2004($t0)
	sw $t1, 2136($t0)
	sw $t1, 2268($t0)
	sw $t1, 2140($t0)
	sw $t1, 2012($t0)
	sw $t1, 1884($t0)
	sw $t1, 1756($t0)
	sw $t1, 1628($t0)
	
checkdecision:
	li $t1, 0xffff0000 
	lw $t0, 0($t1)
	bne $t0, 1, checkdecision

	lw $t0, 4($t1)
	beq $t0, 0x79, restart
	beq $t0, 0x6E, Exit
	j checkdecision

liveone:               
	lw $t0, displayAddress    

	addi $t0, $t0, 28
	lw $t1, heart
	sw $t1, 132($t0)  
	sw $t1, 136($t0)  
	sw $t1, 144($t0)    
	sw $t1, 148($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 392($t0) 
	sw $t1, 396($t0)  
	sw $t1, 400($t0) 
	sw $t1, 524($t0) 
	
	jr $ra

	
printscore:
	lw $t0, displayAddress	
	li $t1, 100
	div $s0, $t1
	mflo $a0
	mfhi $a1
	addi $t0, $t0, 3396
	lw $t2, scorecolor

digitone:
	move $a3, $t0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearscore
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	li $a2, 2
	beq $a0, 0, zero
	beq $a0, 1, one
	beq $a0, 2, two
	beq $a0, 3, three
	beq $a0, 4, four
	beq $a0, 5, five
	beq $a0, 6, six
	beq $a0, 7, seven
	beq $a0, 8, eight
	beq $a0, 9, nine
		
digittwo:
	lw $t0, displayAddress	
	addi $t0, $t0, 3396
	move $a3, $t0
	addi $a3, $a3, 16
	li $a2, 1
	li $t1, 10
	div $a1, $t1
	mflo $a0
	mfhi $a1
	
	beq $a0, 0, zero
	beq $a0, 1, one
	beq $a0, 2, two
	beq $a0, 3, three
	beq $a0, 4, four
	beq $a0, 5, five
	beq $a0, 6, six
	beq $a0, 7, seven
	beq $a0, 8, eight
	beq $a0, 9, nine
	
digitthree:
	lw $t0, displayAddress	
	addi $t0, $t0, 3412
	move $a3, $t0
	addi $a3, $a3, 16
	li $a2, 0
	beq $a1, 0, zero
	beq $a1, 1, one
	beq $a1, 2, two
	beq $a1, 3, three
	beq $a1, 4, four
	beq $a1, 5, five
	beq $a1, 6, six
	beq $a1, 7, seven
	beq $a1, 8, eight
	beq $a1, 9, nine
	
zero:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
one:

	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
two:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
three:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
four:
	sw $t2, 0($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
five:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
six:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
seven:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
eight:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done	
nine:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	beq $a2, 2, digittwo
	beq $a2, 1, digitthree
	beq $a2, 0, done		
done: 	addi $a3, $a3, -16
	jr $ra


clearscore:
	lw $t0, displayAddress
	lw $t1, yellow
	lw $t0, roadcolour
	sw $t1, 0($a3)
	sw $t0, 4($a3)
	sw $t0, 8($a3)
	sw $t1, 128($a3)
	sw $t0, 132($a3)
	sw $t0, 136($a3)
	sw $t1, 256($a3)
	sw $t0, 260($a3)
	sw $t0, 264($a3)
	sw $t1, 384($a3)
	sw $t0, 388($a3)
	sw $t0, 392($a3)
	sw $t1, 512($a3)
	sw $t0, 516($a3)
	sw $t0, 520($a3)
	
	addi $a3, $a3, 16
	sw $t0, -4($a3)
	sw $t0, 124($a3)
	sw $t0, 252($a3)
	sw $t0, 380($a3)
	sw $t0, 508($a3)
	sw $t0, 0($a3)
	sw $t0, 4($a3)
	sw $t0, 8($a3)
	sw $t0, 128($a3)
	sw $t0, 132($a3)
	sw $t0, 136($a3)
	sw $t0, 256($a3)
	sw $t0, 260($a3)
	sw $t0, 264($a3)
	sw $t0, 384($a3)
	sw $t0, 388($a3)
	sw $t0, 392($a3)
	sw $t0, 512($a3)
	sw $t0, 516($a3)
	sw $t0, 520($a3)
	
	addi $a3, $a3, 16
	sw $t0, 0($a3)
	sw $t0, 4($a3)
	sw $t0, 8($a3)
	sw $t0, 128($a3)
	sw $t0, 132($a3)
	sw $t0, 136($a3)
	sw $t0, 256($a3)
	sw $t0, 260($a3)
	sw $t0, 264($a3)
	sw $t0, 384($a3)
	sw $t0, 388($a3)
	sw $t0, 392($a3)
	sw $t0, 512($a3)
	sw $t0, 516($a3)
	sw $t0, 520($a3)
	addi $a3, $a3, -32
	jr $ra
	
printlives:
	lw $t0, displayAddress	

	addi $t0, $t0, 56
	lw $t2, heart
	move $a3, $t0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearscore1
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	move $a0, $t7
	beq $a0, 0, zero1
	beq $a0, 1, one1
	beq $a0, 2, two1
	beq $a0, 3, three1
	beq $a0, 4, four1
	beq $a0, 5, five1
	beq $a0, 6, six1
	beq $a0, 7, seven1
	beq $a0, 8, eight1
	beq $a0, 9, nine1
	
zero1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
one1:

	sw $t2, 4($a3)
	sw $t2, 132($a3)
	sw $t2, 260($a3)
	sw $t2, 388($a3)
	sw $t2, 516($a3)
	j done		
two1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
three1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
four1:
	sw $t2, 0($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	j done		
five1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
six1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
seven1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 136($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	j done		
eight1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j done		
nine1:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 392($a3)
	sw $t2, 520($a3)
	j done1	
done1: 	addi $a3, $a3, -16
	jr $ra


clearscore1:
	lw $t0, displayAddress
	lw $t1, yellow
	lw $t0, roadcolour
	sw $t1, 0($a3)
	sw $t0, 4($a3)
	sw $t0, 8($a3)
	sw $t1, 128($a3)
	sw $t0, 132($a3)
	sw $t0, 136($a3)
	sw $t1, 256($a3)
	sw $t0, 260($a3)
	sw $t0, 264($a3)
	sw $t1, 384($a3)
	sw $t0, 388($a3)
	sw $t0, 392($a3)
	sw $t1, 512($a3)
	sw $t0, 516($a3)
	sw $t0, 520($a3)
	
	jr $ra	
	
reprintcar:
	beq $s1, 1, rep1
	beq $s1, 2, rep2
	beq $s1, 3, rep3
	beq $s1, 4, rep4
rep1:	lw $a0, road1car 
	j updat
rep2:	lw $a0, road2car 
	j updat
rep3:	lw $a0, road3car 
	j updat
rep4:	lw $a0, road4car 
updat:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printcar
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
printlevel:
	lw $t0, displayAddress	

	addi $t0, $t0, 3336
	li $t2, 0x4B0082
	move $a3, $t0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal clearlevel
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $a0, $t7
	bge $s0, 10, hardlevel
easylevel:
	sw $t2, 0($a3)
	sw $t2, 4($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 512($a3)
	sw $t2, 516($a3)
	sw $t2, 520($a3)
	j donelevel
hardlevel:
	sw $t2, 0($a3)
	sw $t2, 8($a3)
	sw $t2, 128($a3)
	sw $t2, 136($a3)
	sw $t2, 256($a3)
	sw $t2, 260($a3)
	sw $t2, 264($a3)
	sw $t2, 384($a3)
	sw $t2, 392($a3)
	sw $t2, 512($a3)
	sw $t2, 520($a3)
donelevel:
	jr $ra
	
clearlevel:
	lw $t0, displayAddress
	lw $t0, roadcolour
	sw $t0, 0($a3)
	sw $t0, 4($a3)
	sw $t0, 8($a3)
	sw $t0, 128($a3)
	sw $t0, 132($a3)
	sw $t0, 136($a3)
	sw $t0, 256($a3)
	sw $t0, 260($a3)
	sw $t0, 264($a3)
	sw $t0, 384($a3)
	sw $t0, 388($a3)
	sw $t0, 392($a3)
	sw $t0, 512($a3)
	sw $t0, 516($a3)
	sw $t0, 520($a3)
	
	jr $ra	
Exit:	li $v0, 10 
	syscall	
