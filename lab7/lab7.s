.data
    binary: .space 16
    parity: .space 12
    return: .word 0
    encoded: .string "0000000\n"
    decoded: .string "0000\n"
    error: .string "0\n"
    buffer1: .space 5
    buffer2: .space 8

.text
.globl _start

_start:
    jal main
    jal _exit

read1:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer1      # buffer to write the data
    li a2, 5            # size
    li a7, 63           # syscall read (63)
    ecall
    ret

read2:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer2      # buffer to write the data
    li a2, 8            # size
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1                # file descriptor = 1 (stdout)
    li a7, 64               # syscall write (64)
    ecall
    ret

# string_to_int_binary
# 
# Transforma a entrada em números inteiros e armazena no vetor binary
# 
# param: a0 - endereço da string
# return: -
string_to_int_binary:
    la a7, binary

    li t0, 4
    1:
        beqz t0, 2f
        lb t1, 0(a0) # t1 <-- buffer[0]
        addi t1, t1, -48 # t1 <-- (int) t1
        sw t1, 0(a7) # binary[0] <-- t1

        addi a0, a0, 1
        addi a7, a7, 4
        addi t0, t0, -1
        j 1b
    2:

ret

# encoding
# 
# Utiliza o algoritmo de Hamming Code
# 
# param: -
# return: -
encoding:
    la a7, binary # a7 <-- binary = [d1, d2, d3, d4]
    la a6, parity # a6 <-- parity = [p1, p2, p3]

    lw a0, 12(a7) # a0 <-- d4


    lw a2, 0(a7) # a2 <-- d1
    lw a3, 4(a7) # a3 <-- d2

    xor a1, a2, a3 # a1 <-- a2 xor a3 = d1 xor d2
    xor a1, a1, a0 # a1 <-- a1 xor a0 => p1 = (d1 xor d2) xor d4
    sw a1, 0(a6) # parity[0] <-- a1 = p1


    lw a2, 0(a7) # a2 <-- d1
    lw a3, 8(a7) # a3 <-- d3

    xor a1, a2, a3 # a1 <-- a2 xor a3 = d1 xor d3
    xor a1, a1, a0 # a1 <-- a1 xor a0 => p2 = (d1 xor d3) xor d4
    sw a1, 4(a6) # parity[1] <-- a1 = p2


    lw a2, 4(a7) # a2 <-- d2
    lw a3, 8(a7) # a3 <-- d3

    xor a1, a2, a3 # a1 <-- a2 xor a3 = d2 xor d3
    xor a1, a1, a0 # a1 <-- a1 xor a0 => p3 = (d2 xor d3) xor d4
    sw a1, 8(a6) # parity[2] <-- a1 = p3


    la a0, parity
    la a1, binary
    la a2, encoded

    li t0, 2
    1:
        beqz t0, 2f
        lw t1, 0(a0) # t1 <-- parity[n]
        addi t1, t1, 48 # t1 <-- (char) t1
        sb t1, 0(a2) # encoded[n] <-- t1

        addi a0, a0, 4
        addi a2, a2, 1
        addi t0, t0, -1
        j 1b
    2:

    lw t1, 0(a1) # t1 <-- binary[0]
    addi t1, t1, 48 # t1 <-- (char) t1
    sb t1, 0(a2) # encoded[2] <-- t1

    addi a1, a1, 4
    addi a2, a2, 1


    lw t1, 0(a0) # t1 <-- parity[2]
    addi t1, t1, 48 # t1 <-- (char) t1
    sb t1, 0(a2) # encoded[3] <-- t1

    addi a2, a2, 1

    li t0, 3
    1:
        beqz t0, 2f
        lw t1, 0(a1) # t1 <-- binary[n]
        addi t1, t1, 48 # t1 <-- (char) t1
        sb t1, 0(a2) # encoded[n] <-- t1

        addi a1, a1, 4
        addi a2, a2, 1
        addi t0, t0, -1
        j 1b
    2:

ret

# decoding
# 
# Utiliza o algoritmo de Hamming Code
# 
# param: a0 - endereço da string
# return: -
decoding:
    la a1, binary

    lb t1, 2(a0) # t1 <-- buffer[2]
    addi t1, t1, -48 # t1 <-- (int) t1
    sw t1, 0(a1) # binary[0] <-- t1

    addi a0, a0, 4
    addi a1, a1, 4

    li t0, 3
    1:
        beqz t0, 2f
        lb t1, 0(a0) # t1 <-- buffer[n]
        addi t1, t1, -48 # t1 <-- (int) t1
        sw t1, 0(a1) # binary[n] <-- t1

        addi a0, a0, 1
        addi a1, a1, 4
        addi t0, t0, -1
        j 1b
    2:


    la a1, binary
    la a2, decoded
    li t0, 4
    1:
        beqz t0, 2f
        lw t1, 0(a1) # t1 <-- binary[n]
        addi t1, t1, 48 # t1 <-- (int) t1
        sb t1, 0(a2) # decoded[n] <-- t1

        addi a1, a1, 4
        addi a2, a2, 1
        addi t0, t0, -1
        j 1b
    2:


    la a0, buffer2
    la a1, parity

    lb t1, 3(a0) # t1 <-- buffer[3]
    addi t1, t1, -48 # t1 <-- (int) t1
    sw t1, 8(a1) # parity[2] <-- t1

    li t0, 2
    1:
        beqz t0, 2f
        lb t1, 0(a0) # t1 <-- buffer[n]
        addi t1, t1, -48 # t1 <-- (int) t1
        sw t1, 0(a1) # parity[n] <-- t1

        addi a0, a0, 1
        addi a1, a1, 4
        addi t0, t0, -1
        j 1b
    2:

ret

# compare
# 
# Compara o buffer com o código codificado para encontrar o erro
# 
# param: a0 - endereço do buffer; a1 - endereço de encoded
# return: a0 - endereço de error
compare:
    li t3, 0
    li t0, 7
    1:
        beqz t0, 2f
        lb t1, 0(a0) # t1 <-- buffer[n]
        lb t2, 0(a1) # t2 <-- encoded[n]
        beq t1, t2, equal
            li t3, 1 # error = 1
            j 2f
        equal:
        addi a0, a0, 1
        addi a1, a1, 1
        addi t0, t0, -1
        j 1b
    2:

    la a0, error
    addi t3, t3, 48 # t3 <-- (char) t3
    sb t3, 0(a0) # error[0] <-- t3

ret

main:
    la s0, return
    sw ra, 0(s0) # Salva o endereço de retorno em return

########################################################

    jal read1 # buffer1 = "BBBB\n"
    la a0, buffer1 # a0 <-- buffer1

    jal string_to_int_binary

    jal encoding
    la a1, encoded          # string
    li a2, 9                # size
    jal write

########################################################

    jal read2 # buffer2 = "BBBBBBB\n"
    la a0, buffer2 # a0 <-- buffer2

    jal decoding
    la a1, decoded          # string
    li a2, 6                # size
    jal write

########################################################

    jal encoding

    la a0, buffer2 # a0 <-- buffer2
    la a1, encoded # a1 <-- encoded
    jal compare
    la a1, error            # string
    li a2, 3                # size
    jal write
    
########################################################

    la s0, return
    lw ra, 0(s0)
    ret

_exit:
    li a0, 0
    li a7, 93
    ecall
