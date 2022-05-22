.data
	soBiChia:	.asciiz "Nhap so bi chia: "
	soChia:		.asciiz "Nhap so chia: "
	ketQua:		.asciiz "Ket qua: "
	chiaCho0:	.asciiz "Khong the chia cho 0"
	negative0:	.word 0x80000000
	phanSoCheck:	.word 0x00800000
.text
main:
	li $v0, 4
	la $a0, soBiChia
	syscall
	li $v0, 6
	syscall
	mfc1 $t0, $f0
	li $v0, 4
	la $a0, soChia
	syscall
	li $v0, 6
	syscall
	mfc1 $t1, $f0
	move $a0, $t0
	move $a1, $t1
	jal ChiaHaiSoThuc
	mtc1 $v0, $f12
	li $v0, 4
	la $a0, ketQua
	syscall
	li $v0, 2
	syscall
	j exit

ChiaHaiSoThuc:
# Xu ly hai truong hop dac biet
	lw $t0, negative0
	beq $a1, $0, MauSo0
	beq $a1, $t0, MauSo0
	beq $a0, $0, TuSo0
	beq $a0, $t0, TuSo0
posOrNeg:
# Xet dau roi sau dó nhet vao bit lon nhat cua v0
	andi $t1, $a0, 0x80000000
	andi $t2, $a1, 0x80000000
	xor $t1, $t1, $t2
	move $v0, $t1
soMu:
# Lay so mu
	andi $t4 $a0, 0x7F800000
	andi $t5, $a1, 0x7F800000
	subi $t6,$t4,0x7F800000
	beq $t6,$zero,infiniteRes
	subi $t6,$t5,0x7F800000
	beq $t6,$zero,TuSo0
	sub $t3, $t4, $t5
	addi $t3, $t3, 0x3F800000
# Neu bit dau != 0 => Van con bieu dien duoc. Neu bit dau = 0 thi de so mu la 0
	andi $t0, $t3, 0x80000000
	beq $t0, $zero, skip
	move $t3, $zero
# Luu so mu vao trong $s0
skip:
	andi $t3, $t3, 0x7F800000
	move $s0, $t3
# Lay phan so
phanSo:
	andi $t1, $a0, 0x007FFFFF
	beq $t4,$zero,noAdd1_1
	addi $t1, $t1, 0x00800000
noAdd1_1:
	andi $t2, $a1, 0x007FFFFF
	beq $t5,$zero,noAdd1_2
	addi $t2, $t2, 0x00800000
noAdd1_2:
	li $t0, 24
# Tim mantissa bang cach so sanh so bi chia(t1) va so chia(t2),
# Neu so bi chia > so chia thi tru va them bit 1 vao cuoi t3
# Con ko thi giu nguyen roi them 0 vao cuoi t3
# Sau do thi shift left t1.
findMantis:
	beq $t0, $zero, out
	sub $t1, $t1, $t2
	slt $t4, $t1, $zero
	beq $t4, $zero, else
	add $t1, $t1, $t2
	sll $t3, $t3, 1
	sll $t1, $t1, 1
	addi $t0, $t0, -1
	j findMantis
else:
	sll $t3, $t3, 1
	addi $t3, $t3, 1
	sll $t1, $t1, 1
	addi $t0, $t0 -1
	j findMantis
# Check phan so va chuyen no ve dang hop le	 
out:
	lw $t0, phanSoCheck	
checking:
	slt $t1, $t3, $t0
	beq $t1, $zero, outShift
	beq $s0, $zero, outShift
	sll $t3, $t3, 1
	addi $s0, $s0, -0x00800000
	j checking
# Don tat ca ve v0
outShift:
	andi $t3, $t3, 0x007FFFFF
	add $v0, $v0, $s0
	add $v0, $v0, $t3
	mtc1 $v0, $f12
	jr $ra
infiniteRes:
	move $v0,$a0
	jr $ra
TuSo0:	
	add $v0, $0, $0
	jr $ra
	
MauSo0:
	li $v0, 4
	la $a0, chiaCho0
	syscall
exit: