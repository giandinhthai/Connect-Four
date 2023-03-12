#Chuong trinh: ten chuong trinh
#Data segment
	.data
#Cac dinh nghia bien

#Cac cau nhac nhap du lieu
displayAddress:	.word	0x10040000
int_arr:	.byte 0 0 0 0 0 0 0
		.byte 0 0 0 0 0 0 0
		.byte 0 0 0 0 0 0 0
		.byte 0 0 0 0 0 0 0
		.byte 0 0 0 0 0 0 0
		.byte 0 0 0 0 0 0 0
	
int_col:	.byte 0 0 0 0 0 0 0
CheckWin_chien_thang_1:	.asciiz "Player 1 wins!!!"
CheckWin_chien_thang_2:	.asciiz "Player 2 wins!!!"
CheckWin_hoa:		.asciiz "Tie!!!"
nhaplai: .asciiz "\n Please input again (from 1 to 7):"
chaomung: .asciiz "Welcome to the Connect 4."
luotnguoi1: .asciiz "\nPlayer 1's turn: "
luotnguoi2: .asciiz "\nPlayer 2's turn: "
xuongdong: .asciiz "\n"
#Code segment
	.text
	.globl	main
main:	
	lw $t1, displayAddress	# $t1 stores the base address for display
	li $s1, 0x0096FF	# $s1 stores the blue colour code
	li $s2, 0xffff00	# $s2 stores the player 1 colour code
	li $s3, 0xff0000	# $s3 stores the player 2 colour code
	li $t9, 0xFFFFFF        # white
#In cau dan va khoi tao
#Gameboard:
	jal GameBoard
	la $a0, chaomung
	li $v0,4
	syscall
	li $s0, 1
	li $s4,0
	li $s6,0
	li $s7,0
	
	la $a0, luotnguoi1 
	li $v0,4
	syscall

Input:
	li $v0, 5
	syscall
	
#Kiem tra co can nhap lai ko
	slti $t0,$v0,1
	bne $t0,0,Nhaplai
	li $t0,8
	slt $t0, $v0, $t0
	bne $t0,1,Nhaplai
	move $s4, $v0
	jal CheckInput 
	
#Tinh toan phan tu trong mang can luu
	li $t0,7
	mult $t0,$s7
	mflo $t0
	add $t0, $t0,$s4
	
#Tinh toan vi tri dia chi trong mang can luu	
	subi	$sp,$sp,4
	sw	$t1,0($sp)
	
	la $t1, int_arr
	add $t0,$t0, $t1
	sb $s0,0($t0)
	
	lw	$t1,0($sp)
	addi	$sp,$sp,4
	
#Goi cac ham check
	beq $s0, 2, player2_color
	add $t9, $s2, $zero
	j exit_player1_color
player2_color:
	add $t9, $s3, $zero
exit_player1_color:
	

	jal DrawTokens
	jal CheckWin
	jal CheckTie
	
	
	bne $s0,1,nguoi2
	nguoi1:
	la $a0, luotnguoi1 
	li $v0,4
	syscall
	j Input
	
	nguoi2:
	la $a0, luotnguoi2
	li $v0,4
	syscall
	j Input
	
	
	#j end
#Thong bao nhap lai
Nhaplai:
	la $a0, nhaplai
	li $v0, 4
	syscall
	j Input


#test

#test:
	
#	li $t1,0
#	li $t2,64
#	li $t3,0	
#	la $t0,int_arr
#	
#	
#loop:
#	addi $t1,$t1,1
#	li $v0, 1
#	lw $a0,0($t0)
#	addi $t0,$t0, 4
#	syscall
#	la $a0, xuongdong
#	li $v0, 4
#	syscall
#	slt $t4,$t1,$t2
#	bne $t4,0,loop
# end
############################################
############# phan 2 #######################
CheckInput:
	
	#bao ve t0 t1
	subi	$sp,$sp,8
	sw	$t0,0($sp)
	sw	$t1,4($sp)
	
	
	#tinh theo hang trong board
	subi	$s4,$s4,1
	lb	$t0,int_col($s4)
	#kiem tra <=5
	slti	$t1,$t0,6
	beqz	$t1,Nhaplai
	#$s7=int_col[$s4]
	add	$s7,$zero,$t0
	#int_col[$s4]++
	addi	$t0,$t0,1
	sb	$t0,int_col($s4)
	#back 
	#load t0 t1 back sp
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	addi	$sp,$sp,8
	jr 	$ra
#Xu ly

#Xuat ket qua (syscall):	

#ket thuc chuong trinh (syscall)
CheckWin:
	#bao ve t0 t1 t2 t3
	subi	$sp,$sp,16
	sw	$t0,0($sp)
	sw	$t1,4($sp)
	sw	$t2,8($sp)
	sw	$t2,12($sp)
	
	
	# t3 luu gia tri 7
	addi	$t3,$zero,7
	# chinh s6
	addi	$s6,$zero,1
	##t0 lam bien dem phan tu trong mang
	addi	$t0,$zero,0
	
	
	CheckWin_loop:
	slti	$t1,$t0,42
	beqz	$t1,CheckWin_exit
	#neu =0:o trong thi thay s6=0
	lb	$t1,int_arr($t0)
	bnez	$t1,CheckWin_cheo_len
	addi	$s6,$zero,0
	
	
	CheckWin_cheo_len:
	#kiem tra co du 4 o tinh tu o dang kiem tra theo hang cheo len
	addi	$t1,$zero,17
	slt	$t1,$t1,$t0
	bnez	$t1,CheckWin_cheo_xuong
	#kiem tra so cot <4
	divu	$t0,$t3
	mfhi	$t1
	slti	$t1,$t1,4
	beqz	$t1,CheckWin_cheo_xuong
	
	#kiem tra tung o gan t1 lam dia chi o dau tien kiem tra
	la	$t1,int_arr($t0)
	lb	$t2,($t1)
	bne	$t2,$s0,CheckWin_cheo_xuong
	lb	$t2,8($t1)
	bne	$t2,$s0,CheckWin_cheo_xuong
	lb	$t2,16($t1)
	bne	$t2,$s0,CheckWin_cheo_xuong
	lb	$t2,24($t1)
	bne	$t2,$s0,CheckWin_cheo_xuong
	#neu deu bang s0
	j	CheckWin_printWinner
	
	
	
	CheckWin_cheo_xuong:
	#kiem tra co du 4 o tinh tu o dang kiem tra theo hang cheo len
	addi	$t1,$zero,23
	slt	$t1,$t1,$t0
	bnez	$t1,CheckWin_ngang
	#kiem tra so cot <3
	divu	$t0,$t3
	mfhi	$t1
	slti	$t1,$t1,3
	bnez	$t1,CheckWin_ngang
	#kiem tra tung o gan t1 lam dia chi o dau tien kiem tra
	la	$t1,int_arr($t0)
	lb	$t2,($t1)
	bne	$t2,$s0,CheckWin_ngang
	lb	$t2,6($t1)
	bne	$t2,$s0,CheckWin_ngang
	lb	$t2,12($t1)
	bne	$t2,$s0,CheckWin_ngang
	lb	$t2,18($t1)
	bne	$t2,$s0,CheckWin_ngang
	#neu deu bang s0
	j	CheckWin_printWinner
	
	
	
	
	
	
	CheckWin_ngang:
	#kiem tra co 4 o lien tiep ($t0%7<4)
	divu	$t0,$t3
	mfhi	$t1
	slti	$t1,$t1,4
	beqz	$t1,CheckWin_doc
	#kiem tra tung o gan t1 lam dia chi o dau tien kiem tra
	la	$t1,int_arr($t0)
	lb	$t2,($t1)
	bne	$t2,$s0,CheckWin_doc
	lb	$t2,1($t1)
	bne	$t2,$s0,CheckWin_doc
	lb	$t2,2($t1)
	bne	$t2,$s0,CheckWin_doc
	lb	$t2,3($t1)
	bne	$t2,$s0,CheckWin_doc
	#neu deu bang s0
	j	CheckWin_printWinner
	
	
	CheckWin_doc:
	addi	$t1,$zero,20
	slt	$t1,$t1,$t0
	bnez	$t1,CheckWin_backToLoop
	#kiem tra tung o gan t1 lam dia chi o dau tien kiem tra
	la	$t1,int_arr($t0)
	lb	$t2,($t1)
	bne	$t2,$s0,CheckWin_backToLoop
	lb	$t2,7($t1)
	bne	$t2,$s0,CheckWin_backToLoop
	lb	$t2,14($t1)
	bne	$t2,$s0,CheckWin_backToLoop
	lb	$t2,21($t1)
	bne	$t2,$s0,CheckWin_backToLoop
	#neu deu bang s0
	j	CheckWin_printWinner
	
	
	
	#back to loop
	CheckWin_backToLoop:
	addi	$t0,$t0,1
	j 	CheckWin_loop
	
	
	CheckWin_printWinner:
	#nguoi 1 thang
	la	$a0,CheckWin_chien_thang_1
	beq	$s0,1,CheckWin_nguoi_1
	#nguoi 2 thang
	la	$a0,CheckWin_chien_thang_2
	CheckWin_nguoi_1:
	li	$v0,4
	syscall
	j	Exit
	
	
	CheckWin_exit:
	#load t0 t1 back sp
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	lw	$t2,8($sp)
	lw	$t2,12($sp)
	addi	$sp,$sp,16
	jr 	$ra
	
	
	CheckTie:
	bnez	$s6,CheckWin_draw
	subi	$sp,$sp,4
	sw	$t0,0($sp)
	
	addi	$t0,$zero,3
	sub	$s0,$t0,$s0
	
	lw	$t0,0($sp)
	addi	$sp,$sp,4
	jr 	$ra
	CheckWin_draw:
	la	$a0,CheckWin_hoa
	li	$v0,4
	syscall
	j	Exit

Exit:
	li	$v0,10
	syscall
######################################################
############## phan 3 ################################
GameBoard: 
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t6, $zero, $zero

	add $t6, $zero, $zero
Loop_Row_N:                       # Draw Rows
	jal Draw_Row_N
	beq $t6, 13824, Exit_Loop_Row_N    #(Row 54) * 64*4  
	addi $t6, $t6, 256          #2304 = 64*4 * 9
	j Loop_Row_N
Exit_Loop_Row_N:

	addi $t6, $zero, 14080
Loop_Decor_N:                       # Draw Rows
	jal Draw_Row_N
	beq $t6, 16128, Exit_Loop_Decor_N    #(Row 64) * 64*4  
	addi $t6, $t6, 256          #2304 = 64*4 * 9
	j Loop_Decor_N
Exit_Loop_Decor_N:
	
	addi $s7, $zero, -1
	add $t9, $t9, $zero
	
Loop_DrawCBoard_N:
	addi $s7, $s7, 1
	beq $s7 , 6, Exit_Loop_DrawCBoard_N
	add $s4, $zero,$zero
Loop_DrawCBoardHelp_N:	
	jal DrawTokens
	addi $s4,$s4, 1
	beq $s4 , 7, Loop_DrawCBoard_N
	j Loop_DrawCBoardHelp_N
Exit_Loop_DrawCBoard_N:

	jal Decor_N
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra	
#end GameBoard

#begin DrawRow
Draw_Row_N:	
	addiu $sp, $sp, -4
	sw $ra, ($sp)

	add $t4, $t1, $t6  #paint first column red
	add $t5, $zero,$zero	
Loop_DRow_N:	
	sw $s1, 0($t4)
	addi $t4, $t4,4	 
	addi $t5,$t5, 1
	beq $t5 , 64, Exit_Loop_DRow_N
	j Loop_DRow_N
Exit_Loop_DRow_N:
	
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra
### end DrawRow
			
### begin DrawTokens
DrawTokens:	
### debug
	lw $t1, displayAddress
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#add $t9, $t9, $zero doi mau o
	
	addi $t6, $zero, 36
	mul  $t6, $t6, $s4    #offset col
	
	
	
	add $t4, $t1, $t6  #paint first column red
	addi $t6, $zero, 5
	sub $t6, $t6, $s7
	
	
	add $t7, $zero, 2304
	mul $t6, $t6, $t7
	
	
	add $t4, $t4, $t6
	addi $t4, $t4, 260   #t4 is in (0,0) of 8x8
	
	
	
	addi $t6, $t4, 8
	
	
	addi $t7, $t4, 1800
	add $t5, $zero,$zero
Loop_DrawCircle1_N:	

	sw $t9, 0($t6)
	sw $t9, 0($t7)
	addi $t6, $t6,4
	addi $t7, $t7,4	 
	addi $t5,$t5, 1
	beq $t5 , 4, Exit_Loop_DrawCircle1_N
	j Loop_DrawCircle1_N
Exit_Loop_DrawCircle1_N:


	addi $t6, $t4, 260
	addi $t7, $t4, 1540
	add $t5, $zero,$zero
Loop_DrawCircle2_N:	
	sw $t9, 0($t6)
	sw $t9, 0($t7)
	addi $t6, $t6,4	 
	addi $t7, $t7, 4
	addi $t5,$t5, 1
	beq $t5 , 6, Exit_Loop_DrawCircle2_N
	j Loop_DrawCircle2_N
Exit_Loop_DrawCircle2_N:

	addi $t6, $t4, 256
	
	add $t7, $zero, $zero 
	
Loop_DrawCircle3_N:
	addi $t6, $t6, 256
	addi $t7, $t7, 1
	beq $t7 , 5, Exit_Loop_DrawCircle3_N
	add $t5, $zero,$zero
	add $t8, $t6, $zero
Loop_DrawCircle3Help_N:	
	sw $t9, 0($t8)
	addi $t8, $t8,4	 
	addi $t5,$t5, 1
	
	beq $t5 , 8, Loop_DrawCircle3_N
	
	j Loop_DrawCircle3Help_N
	
Exit_Loop_DrawCircle3_N:
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra	

Decor_N:
	lw $t1, displayAddress
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#add $t9, $t9, $zero doi mau o
	addi $t6, $t1, 14080 
	
	### 1 
	sw $t9, 20($t6)
	sw $t9, 276($t6)
	sw $t9, 532($t6)
	sw $t9, 788($t6)
	sw $t9, 1044($t6)
	sw $t9, 1300($t6)
	sw $t9, 1556($t6)
	
	#### 2
	sw $t9, 48($t6)
	sw $t9, 52($t6)
	sw $t9, 56($t6)
	sw $t9, 60($t6)
	
	sw $t9, 816($t6)
	sw $t9, 820($t6)
	sw $t9, 824($t6)
	sw $t9, 828($t6)
	
	sw $t9, 1584($t6)
	sw $t9, 1588($t6)
	sw $t9, 1592($t6)
	sw $t9, 1596($t6)
	
	sw $t9, 316($t6)
	sw $t9, 572($t6)
	
	sw $t9, 1072($t6)
	sw $t9, 1328($t6)
	
	### 3
	sw $t9, 84($t6)
	sw $t9, 88($t6)
	sw $t9, 92($t6)
	sw $t9, 96($t6)
	
	sw $t9, 352($t6)
	sw $t9, 608($t6)
	
	sw $t9, 852($t6)
	sw $t9, 856($t6)
	sw $t9, 860($t6)
	sw $t9, 864($t6)
	
	sw $t9, 1120($t6)
	sw $t9, 1376($t6)
	
	sw $t9, 1620($t6)
	sw $t9, 1624($t6)
	sw $t9, 1628($t6)
	sw $t9, 1632($t6)
	
	### 4
	sw $t9, 120($t6)
	sw $t9, 376($t6)
	sw $t9, 632($t6)
	sw $t9, 888($t6)
	sw $t9, 892($t6)
	sw $t9, 896($t6)
	
	sw $t9, 132($t6)
	sw $t9, 388($t6)
	sw $t9, 644($t6)
	sw $t9, 900($t6)
	sw $t9, 1156($t6)
	sw $t9, 1412($t6)
	sw $t9, 1668($t6)
	# sw $t9, ($t6)
	### 5
	sw $t9, 156($t6)
	sw $t9, 160($t6)
	sw $t9, 164($t6)
	sw $t9, 168($t6)
	
	sw $t9, 412($t6)
	sw $t9, 668($t6)
	sw $t9, 924($t6)
	sw $t9, 928($t6)
	sw $t9, 932($t6)
	sw $t9, 936($t6)
	
	sw $t9, 1192($t6)
	sw $t9, 1448($t6)
	sw $t9, 1704($t6)
	sw $t9, 1700($t6)
	sw $t9, 1696($t6)
	sw $t9, 1692($t6)
	
	##6
	sw $t9, 192($t6)
	sw $t9, 196($t6)
	sw $t9, 200($t6)
	sw $t9, 204($t6)
	
	sw $t9, 448($t6)
	sw $t9, 704($t6)
	sw $t9, 960($t6)
	sw $t9, 964($t6)
	sw $t9, 968($t6)
	sw $t9, 972($t6)
	sw $t9, 1228($t6)
	sw $t9, 1484($t6)
	sw $t9, 1216($t6)
	
	sw $t9, 1472($t6)
	sw $t9, 1728($t6)
	sw $t9, 1732($t6)
	sw $t9, 1736($t6)
	sw $t9, 1740($t6)
	
	###7
	sw $t9, 228($t6)
	sw $t9, 232($t6)
	sw $t9, 236($t6)
	sw $t9, 240($t6)
	sw $t9, 496($t6)
	sw $t9, 752($t6)
	sw $t9, 1008($t6)
	sw $t9, 1264($t6)
	sw $t9, 1520($t6)
	sw $t9, 1776($t6)
	#sw $t9, ($t6)
	#sw $t9, ($t6)
	
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra	

