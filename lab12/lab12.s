.data
    number1: .space 32
    number2: .space 32
    output: .space 32

.text
    .set    WRITE,          0xFFFF0100
    .set    BYTE_TO_WRITE,  0xFFFF0101
    .set    READ,           0xFFFF0102
    .set    BYTE_READ,      0xFFFF0103

    .globl _start
    

_start:
    jal main
    jal _exit

# itoa
#
# Recebe um inteiro e o transforma em string
#
# param: a0 - (int) value; a1 - (char*) str; a2 - (int) base
# return: a0 - (char*) str
itoa:
	li a3, 0
	bgez a0, 1f
        li t0, 10
        bne a2, t0, 1f
            li t0, -1
            li a3, 1
            mul a0, a0, t0      # a0 <-- |a0|
	1:
	
    addi a1, a1, 31         # vai até o final da string (possui no máximo 32 dígitos)
	li t0, 0
	1:
		remu t1, a0, a2
		divu a0, a0, a2
		li t2, 10
		bge t1, t2, 2f      # se t1 >= 10, converte para [a, b, c, ...], senão, converte para [0, 1, 2, ...]
			addi t1, t1, '0'
			j 3f
		2:
			addi t1, t1, -10
			addi t1, t1, 'A'
		3:
		sb t1, 0(a1)
		addi a1, a1, -1
		addi t0, t0, 1
		bnez a0, 1b
	
	mv a0, a1
	beqz a3, 1f
        li t0, 10
        bne a2, t0, 1f
            li t0, '-'
            sb t0, 0(a0)
            j 2f
	1:
        addi a0, a0, 1
    2:

ret

# atoi
#
# Recebe uma em string e a transfora em inteiro
#
# param: a0 - (const char*) str
# return: a0 - (int) value
atoi:	
	li t0, ' '				# carrega o char espaço para pular se houver na string
	1:
		lb a1, 0(a0)
		bne a1, t0, 2f
		addi a0, a0, 1
		j 1b
	2:

	lb a1, 0(a0)
	li a2, 1

	li t0, '-'
	bgt a1, t0, 1f          # se o primeiro char for '+' ou '-' salva o multiplicador 1 ou -1
		bne a1, t0, 2f
			li a2, -1
		2:
		addi a0, a0, 1
	1:
	mv a1, a2
	
	li a2, 0
	1:
		lb t0, 0(a0)
		beqz t0, 2f         # caminha na string até 0 '\0'
		li t1, 10
		mul a2, a2, t1
		addi t0, t0, -'0'
		add a2, a2, t0
        addi a0, a0, 1
		j 1b
	2:
	mul a0, a2, a1
ret

# read_byte
#
# Lê um byte e o retorna
#
# param: -
# return: a0 - (char) byte
read_byte:
    li a0, READ
    li t0, 1
    sb t0, 0(a0)

    0:
        lb t0, 0(a0)
        bnez t0, 0b
    
    li a0, BYTE_READ
    lb a0, 0(a0)
ret

# write_byte
#
# Escreve o byte recebido
#
# param: a0 - (char) byte
# return: -
write_byte:
    li a1, BYTE_TO_WRITE
    sb a0, 0(a1)

    li a0, WRITE
    li t0, 1
    sb t0, 0(a0)

    0:
        lb t0, 0(a0)
        bnez t0, 0b
ret

operation_1:
    addi sp, sp, -16
    sw ra, 0(sp)

    0:
        jal read_byte

        li t1, '\n'
        beq a0, t1, 1f
        jal write_byte
        j 0b
    1:

    lw ra, 0(sp)
    addi sp, sp, 16
ret

operation_2:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    li s0, 0
    0:
        jal read_byte

        li t1, '\n'
        beq a0, t1, 1f

        addi sp, sp, -1
        sb a0, 0(sp)

        addi s0, s0, 1
        j 0b
    1:

    0:
        beqz s0, 1f

        lb a0, 0(sp)
        addi sp, sp, 1
        jal write_byte

        addi s0, s0, -1
        j 0b
    1:

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
ret

operation_3:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)

    la s0, number1

    0:
        jal read_byte

        li t1, '\n'
        beq a0, t1, 1f

        sb a0, 0(s0)

        addi s0, s0, 1
        j 0b
    1:

    la a0, number1
    jal atoi

    la a1, output
    li a2, 16
    jal itoa

    mv s0, a0

    0:
        lb a0, 0(s0)
        beqz a0, 1f

        jal write_byte

        addi s0, s0, 1
        j 0b
    1:

    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
ret

operation_4:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    la s0, number1

    0:
        jal read_byte

        li t1, 32
        beq a0, t1, 1f

        sb a0, 0(s0)

        addi s0, s0, 1
        j 0b
    1:

    la a0, number1
    jal atoi
    mv s2, a0

    jal read_byte
    mv s1, a0

    jal read_byte

    la s0, number2

    0:
        jal read_byte

        li t1, '\n'
        beq a0, t1, 1f

        sb a0, 0(s0)

        addi s0, s0, 1
        j 0b
    1:

    la a0, number2
    jal atoi
    mv s0, a0

    li t0, '+'
    bne s1, t0, 0f
        add a0, s2, s0
        j 3f
    0:

    li t0, '-'
    bne s1, t0, 1f
        sub a0, s2, s0
        j 3f
    1:

    li t0, '*'
    bne s1, t0, 2f
        mul a0, s2, s0
        j 3f
    2:

    li t0, '/'
    bne s1, t0, 3f
        div a0, s2, s0
    3:

    la a1, output
    li a2, 10
    jal itoa

    mv s0, a0

    0:
        lb a0, 0(s0)
        beqz a0, 1f

        jal write_byte

        addi s0, s0, 1
        j 0b
    1:

    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16

ret

main:
    addi sp, sp, -16
    sw ra, 0(sp)

    jal read_byte
    addi a0, a0, -'0'

    li t0, 1
    bne a0, t0, 0f
        jal read_byte
        jal operation_1
        j 3f
    0:

    li t0, 2
    bne a0, t0, 1f
        jal read_byte
        jal operation_2
        j 3f
    1:

    li t0, 3
    bne a0, t0, 2f
        jal read_byte
        jal operation_3
        j 3f
    2:

    li t0, 4
    bne a0, t0, 3f
        jal read_byte
        jal operation_4
    3:

    li a0, '\n'
    jal write_byte

    lw ra, 0(sp)
    addi sp, sp, 16
    li a0, 0
ret

_exit:
    li a7, 93
    ecall
