.data
    buffer: .space 28
    satellites: .space 8
    timestamps: .space 16
    distances: .space 12
    result: .space 16

.text
.globl _start

_start:
    jal main
    jal _exit

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer       # buffer to write the data
    li a2, 30           # size
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 22           # size
    li a7, 64           # syscall write (64)
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
# Pega as distâncias a partir dos timestamps
# 
# param: a0 - endereço do vetor distances; a1 - Yb
# return: a0 - Y
get_y:
    lw t0, 0(a0) # t0 <-- distances[0] = Da
    lw t1, 4(a0) # t1 <-- distances[1] = Db

    mul t0, t0, t0 # t0 <-- t0 * t0
    mul t1, t1, t1 # t1 <-- t1 * t1
    mul t2, a1, a1 # t2 <-- a1 * a1

    sub t0, t0, t1 # t0 <-- t0 - t1
    add t0, t0, t2 # t0 <-- t0 + t2

    div t0, t0, t1 # t0 <-- t0 / t1

    srai t0, t0, 1 # t0 <-- t0 / 2

    mv a0, t0 # a0 <-- t0

    ret

main:
    la s0, satellites # s0 <-- sattelites

    jal read # buffer = "SDDDD SDDDD\n"
    la a0, buffer # a0 <-- buffer

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

    jal read # buffer = "DDDD DDDD DDDD DDDD\n"
    la a0, buffer # a0 <-- buffer

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

    ret

_exit:
    li a0, 0
    li a7, 93
    ecall
