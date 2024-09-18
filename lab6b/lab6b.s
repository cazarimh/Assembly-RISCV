.data
    buffer1: .space 12
    buffer2: .space 20
    satellites: .space 8
    timestamps: .space 16
    distances: .space 12
    result: .space 8
    return: .word 0
    result_string: .string "+0000 +0000\n"

.text
.globl _start

_start:
    jal main
    jal _exit

read1:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer1      # buffer to write the data
    li a2, 12           # size
    li a7, 63           # syscall read (63)
    ecall
    ret

read2:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer2      # buffer to write the data
    li a2, 20           # size
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1                # file descriptor = 1 (stdout)
    la a1, result_string    # string
    li a2, 13               # size
    li a7, 64               # syscall write (64)
    ecall
    ret

# string_to_int
# 
# Transforma uma string com 4 caracteres em um inteiro
# 
# param: a0 - endereço da string
# return: a1 - inteiro representado na string
string_to_int:
    li t6, 10
    li a1, 0

    li t1, 4
    loop:
        beqz t1, stop
        mul a1, a1, t6 # a1 <-- a1 * 10
        lb t2, 0(a0) # Carrega o char no endereço a0
        addi t2, t2, -48 # Transforma o char em int
        add a1, a1, t2 # a1 <-- a1 + t2
        addi a0, a0, 1 # Incrementa 1 no endereço de a0
        addi t1, t1, -1
        j loop
    stop:

    addi a0, a0, -4 # Decrementa 4 no endereço de a0

    ret

# int_to_string
# 
# Escreve um número em uma string
# 
# param: a0 - endereço da string; a1 - número inteiro
# return: -
int_to_string:
    addi a0, a0, 4 # Vai até o último char do número atual
    li s1, 48 # Valor do char '0'
    li s2, 10

    li t1, 4
    repeat:
        beqz t1, finish
        addi a0, a0, -1
        rem t2, a1, s2 # t2 <-- a1 % 10
        div a1, a1, s2 # a1 <-- a1 / 10
        add t2, t2, s1 # Transforma int em char (t2 + '0')
        sb t2, 0(a0) # Escreve o resto da divisão na string
        beqz a1, finish
        addi t1, t1, -1
        j repeat
    finish:
    
    ret

# square_root
# 
# Calcula a raiz quadrada aproximada pelo método babilônico
# 
# param: a0 - inteiro
# return: a0 - raiz quadrada do original
square_root:
    srli t3, a0, 1 # t3 <-- k = y/2

    li t2, 21
    for:
        beqz t2, skip
        div t4, a0, t3 # t4 <-- y/k
        add t4, t4, t3 # t4 <-- k + y/k
        srli t3, t4, 1 # t3 <-- (k + y/k)/2
        addi t2, t2, -1
        j for
    skip:
    
    mv a0, t3 # a0 <-- t3

    ret

# get_distances
# 
# Pega as distâncias a partir dos timestamps
# 
# param: a0 - endereço do vetor timestamps; a1 - endereço do vetor distances
# return: -
get_distances:
    lw t6, 12(a0) # t6 <-- Tr
    li t5, 3
    li t4, 10

    li t0, 3
    1:
        beqz t0, 2f
        lw t1, 0(a0) # Pega o timestamp x

        sub t1, t6, t1 # t1 <-- Tr - Tx
        mul t1, t1, t5 # t1 <-- t1 * 3
        div t1, t1, t4 # t1 <-- t1 / 10

        sw t1, 0(a1) # Salva a distância na posição respectiva

        addi a0, a0, 4
        addi a1, a1, 4
        addi t0, t0, -1
        j 1b
    2:

    ret

# get_y
# 
# Calcula Y a partir das distâncias e de Yb
# 
# param: a0 - endereço do vetor distances; a1 - Yb
# return: a0 - Y
get_y:
    lw t0, 0(a0) # t0 <-- distances[0] = Da
    lw t1, 4(a0) # t1 <-- distances[1] = Db

    mul t0, t0, t0 # t0 <-- t0 * t0 (Da^2)
    mul t1, t1, t1 # t1 <-- t1 * t1 (Db^2)
    mul t2, a1, a1 # t2 <-- a1 * a1 (Yb^2)

    sub t0, t0, t1 # t0 <-- t0 - t1
    add t0, t0, t2 # t0 <-- t0 + t2

    div t0, t0, a1 # t0 <-- t0 / a1

    srai t0, t0, 1 # t0 <-- t0 / 2

    mv a0, t0 # a0 <-- t0

    la t6, result
    sw a0, 0(t6) # result[0] <-- Y

    ret

# get_x
# 
# Calcula X a partir das distâncias e de Y
# 
# param: a0 - endereço do vetor distances; a1 - Y; a2 - Xc
# return: a0 - X
get_x:
    lw t0, 0(a0) # t0 <-- distances[0] = Da
    lw t1, 8(a0) # t1 <-- distances[2] = Dc

    mul t0, t0, t0 # t0 <-- t0 * t0 = (Da^2)
    mul t1, t1, t1 # t1 <-- t1 * t1 = (Dc^2)
    mul a1, a1, a1 # a1 <-- a1 * a1 = (Y^2)

    sub t0, t0, a1 # t0 <-- t0 - a1

    mv a0, t0 # a0 <-- t0
    
    mv s0, ra
    jal square_root
    mv ra, s0

    sub t0, a0, a2 # t0 <-- a0 - a2 = X - Xc
    mul t0, t0, t0 # t0 <-- t0 * t0 = (X - Xc)^2
    add t0, t0, a1 # t0 <-- t0 + a1 = (X - Xc)^2 + Y^2

    li t6, -1

    mul t2, t6, a0 # t2 <-- t6 * a0 = -X
    sub t2, t2, a2 # t2 <-- t2 - a2 = -X - Xc
    mul t2, t2, t2 # t2 <-- t2 * t2 = (-X - Xc)^2
    add t2, t2, a1 # t2 <-- t2 + a1 = (-X - Xc)^2 + Y^2

    sub t0, t0, t1 # t0 <-- t0 - t1
    sub t2, t2, t1 # t2 <-- t2 - t1

    bgt t0, zero, 1f
    mul t0, t0, t6 # t0 <-- -t0
    1:

    bgt t2, zero, 1f
    mul t2, t2, t6 # t2 <-- -t2
    1:

    blt t0, t2, 1f
    mul a0, a0, t6 # a0 <-- -a0 = -X
    1:
    
    la t6, result
    sw a0, 4(t6) # result[1] <-- X

    ret

main:
    la s0, return
    sw ra, 0(s0) # Salva o endereço de retorno em return

###############################################################

    la s0, satellites # s0 <-- sattelites

    jal read1 # buffer1 = "SDDDD SDDDD\n"
    la a0, buffer1 # a0 <-- buffer1

    li t0, 2
    1:
        beqz t0, 2f
        lb s11, 0(a0)
        slti s11, s11, 44 # s11 <-- 1 se s11 for '+'; 0 se s11 for '-'

        addi a0, a0, 1
        jal string_to_int # a1 <-- (int) a0

        bnez s11, positive_number # Se o número for negativo:
        li t6, -1
        mul a1, a1, t6 # a1 <-- a1 * -1
        positive_number:

        sw a1, 0(s0) # satellites[0] = a1
        addi s0, s0, 4 # Próxima posição do vetor

        addi a0, a0, 5 # Vai até o sinal do próximo número

        addi t0, t0, -1
        j 1b
    2:

###############################################################

    la s0, timestamps # s0 <-- timestamps

    jal read2 # buffer2 = "DDDD DDDD DDDD DDDD\n"
    la a0, buffer2 # a0 <-- buffer2

    li t0, 4
    1:
        beqz t0, 2f
        jal string_to_int # a1 <-- (int) a0

        sw a1, 0(s0) # timestamps[0] = a1
        addi s0, s0, 4 # Próxima posição do vetor

        addi a0, a0, 5 # Vai até o sinal do próximo número

        addi t0, t0, -1
        j 1b
    2:

###############################################################

    la a0, timestamps # a0 <-- timestamps
    la a1, distances # a1 <-- distances
    jal get_distances

###############################################################

    la a0, distances # a0 <-- distances
    la a1, satellites # a1 <-- satellites
    lw a1, 0(a1) # a1 <-- satellites[0] = Yb
    jal get_y

    mv a1, a0 # a1 <-- return get_y

###############################################################

    la a0, distances # a0 <-- distances
    la a2, satellites # a2 <-- satellites
    lw a2, 4(a2) # a2 <-- satellites[1] = Xc
    jal get_x

###############################################################
# Escreve X na string
    la a0, result_string
    la a1, result
    lw a1, 4(a1)
    bgt a1, zero, 1f
    li t0, '-'
    sb t0, 0(a0)
    li t0, -1
    mul a1, a1, t0
    1:
    addi a0, a0, 1
    jal int_to_string

# Escreve Y na string
    la a0, result_string
    la a1, result
    lw a1, 0(a1)
    bgt a1, zero, 1f
    li t0, '-'
    sb t0, 6(a0)
    li t0, -1
    mul a1, a1, t0
    1:
    addi a0, a0, 7
    jal int_to_string

    jal write

###############################################################

    la s0, return
    lw ra, 0(s0)
    ret

_exit:
    li a0, 0
    li a7, 93
    ecall
