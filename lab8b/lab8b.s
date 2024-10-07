.data
    return: .word 0
    width: .word 0
    height: .word 0
    maxval: .word 0
    matrix_filter: .word -1, -1, -1, -1, 8, -1, -1, -1, -1
    file: .string "image.pgm"
    buffer: .space 262159

.text
.globl _start

_start:
    jal main
    jal _exit

open:
    la a0, file          # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open (1024)
    ecall
ret

close:
    li a0, 3             # file descriptor (fd) 3
    li a7, 57            # syscall close (57)
    ecall
ret

read:
    la a1, buffer        # buffer to write the data
    li a2, 262159        # size
    li a7, 63            # syscall read (63)
    ecall
ret

setPixel:
    li a7, 2200          # syscall setPixel (2200)
    ecall
ret

setCanvasSize:
    li a7, 2201          # syscall setCanvasSize (2201)
    ecall
ret

# string_to_int
# 
# Percorre uma string até um espaço em branco para transformá-la em inteiro
# 
# param: a0 - endereço da string
# return: a1 - inteiro representado na string
string_to_int:
    li a1, 0
    li t0, 10
    li t1, 32 # 32 => caracter espaço na ascii

    1:
        lb t2, 0(a0) # Carrega o char no endereço a0
        ble t2, t1, 2f # Caso t2 for um espaço em branco, encerra
        mul a1, a1, t0 # a1 <-- a1 * 10
        addi t2, t2, -48 # Transforma o char em int
        add a1, a1, t2 # a1 <-- a1 + t2
        addi a0, a0, 1 # Incrementa 1 no endereço de a0
        j 1b
    2:
ret

# filter
# 
# Aplica o filtro de imagem e coloca em matrix (Mout)
# Mout[i][j] = w[k][q]*Min[i+k-1][j+q-1]
# 
# param: s0 - endereço do pixel atual
# return: a2 - valor do pixel em rgba
filter:
    la a2, matrix_filter
    li s11, 3

    la s10, width
    lw s10, 0(s10)

    sub a3, s0, s10
    addi a3, a3, -1 # a3 <-- endereço de Min[i-1][j-1]

    li a7, 0 # resultado no registrador a7

    li t2, 0
    sum1:
        beq t2, s11, 1f
        
        li t3, 0
        sum2:
            beq t3, s11, 2f

            lw t4, 0(a2)

            lbu t5, 0(a3)

            mul t4, t4, t5

            add a7, a7, t4

            addi a2, a2, 4
            addi a3, a3, 1
            addi t3, t3, 1
            j sum2
        2:

        add a3, a3, s10
        addi a3, a3, -3

        addi t2, t2, 1
        j sum1
    1:

    li t2, 255

    blt a7, t2, 1f
        li a7, 255
    1:

    bgez a7, 1f
        li a7, 0
    1:

    mv a2, a7

    slli a2, a2, 8 # a2 <-- Red

    or a2, a2, a7 # a2 <-- Red + Green
    slli a2, a2, 8

    or a2, a2, a7 # a2 <-- Red + Green + Blue
    slli a2, a2, 8

    ori a2, a2, 255 # a2 <-- Red + Green + Blue + Alpha

ret

main:
    la s0, return
    sw ra, 0(s0) # Salva o endereço de retorno em return

########################################################

    jal open
    jal read # buffer = "P5 width height maxval values"
    jal close

    la a0, buffer # a0 <-- &buffer[0]
    addi a0, a0, 3 # a0 <-- &buffer[width]

    jal string_to_int # a1 <-- width
    la a2, width
    sw a1, 0(a2) # width <-- a1

    addi a0, a0, 1 # a0 <-- &buffer[height]

    jal string_to_int # a1 <-- height
    la a2, height
    sw a1, 0(a2) # height <-- a1

    addi a0, a0, 1 # a0 <-- &buffer[maxval]

    jal string_to_int # a1 <-- maxval
    la a2, maxval
    sw a1, 0(a2) # maxval <-- a1

########################################################

    addi a0, a0, 1 # a0 <-- &values[0][0] := &buffer[values]
    mv s0, a0 # s0 <-- a0 = &values[0][0]
    
    la a0, width
    lw a0, 0(a0)
    mv s1, a0

    la a1, height
    lw a1, 0(a1)
    mv s2, a1

    jal setCanvasSize

    li t0, 0
    mul t1, s1, s2 # t1 <-- quantidade de pixels (contador)
    1:
        beq t0, t1, 2f
       
        rem a0, t0, s1 # x = a0 <-- indice % width
        div a1, t0, s1 # y = a1 <-- indice / width

        addi t2, s1, -1 # t2 <-- x máximo
        addi t3, s2, -1 # t3 <-- y máximo

        beqz a0, corner         # Se a0 ou a1 for 0
        beqz a1, corner         # ou o índice máximo
        beq a0, t2, corner      # seta o pixel como
        beq a1, t3, corner      # preto

            jal filter
            jal setPixel

            j end

        corner:
            li a2, 255
            jal setPixel
        end:

        addi s0, s0, 1
        addi t0, t0, 1
        j 1b
    2:
    
########################################################

    la s0, return
    lw ra, 0(s0)
ret

_exit:
    li a0, 0
    li a7, 93
    ecall