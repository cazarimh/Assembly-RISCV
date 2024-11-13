.text
    .globl fill_array_int, fill_array_short, fill_array_char

fill_array_int:
    addi sp, sp,-16
    sw ra, 0(sp)

    addi sp, sp, -400

    li t0, 0
    0:
        li t1, 100
        beq t0, t1, 1f

        sw t0, 0(sp)
        addi sp, sp, 4
        addi t0, t0, 1
        
        j 0b
    1:

    addi sp, sp, -400

    mv a0, sp
    jal mystery_function_int

    addi sp, sp, 400

    lw ra, 0(sp)
    addi sp, sp, 16
ret

fill_array_short:
    addi sp, sp,-16
    sw ra, 0(sp)

    addi sp, sp, -200

    li t0, 0
    0:
        li t1, 100
        beq t0, t1, 1f

        sh t0, 0(sp)
        addi sp, sp, 2
        addi t0, t0, 1
        
        j 0b
    1:

    addi sp, sp, -200

    mv a0, sp
    jal mystery_function_short

    addi sp, sp, 200

    lw ra, 0(sp)
    addi sp, sp, 16
ret

fill_array_char:
    addi sp, sp,-16
    sw ra, 0(sp)

    addi sp, sp, -100

    li t0, 0
    0:
        li t1, 100
        beq t0, t1, 1f

        sb t0, 0(sp)
        addi sp, sp, 1
        addi t0, t0, 1
        
        j 0b
    1:

    addi sp, sp, -100

    mv a0, sp
    jal mystery_function_char

    addi sp, sp, 100

    lw ra, 0(sp)
    addi sp, sp, 16
ret