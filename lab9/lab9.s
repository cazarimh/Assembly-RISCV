.data
    return: .word 0
    result: .space 8
    buffer: .space 6

.text
.globl _start

_start:
    jal main
    jal _exit

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer       # buffer to write the data
    li a2, 6            # size
    li a7, 63           # syscall read (63)
    ecall
ret

write:
    li a0, 1                # file descriptor = 1 (stdout)
    li a7, 64               # syscall write (64)
    ecall
ret

# string_to_int
# 
# Percorre uma string até um espaço em branco para transformá-la em inteiro
# 
# param: a0 - endereço da string
# return: a0 - inteiro representado na string
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

    mv a0, a1

ret

# int_to_string
# 
# Escreve um número em uma string
# 
# param: a0 - endereço da string; a1 - número inteiro
# return: a0 - endereço do início; a1 - quantidade de caracteres
int_to_string:
    addi a0, a0, 5 # Vai até o último char do número atual
    li s1, 48 # Valor do char '0'
    li s2, 10

    bnez a1, 2f
        sb s1, 0(a0)
    2:

    li t0, 2
    1:
        beqz a1, 2f
        addi a0, a0, -1
        rem t1, a1, s2 # t1 <-- a1 % 10
        div a1, a1, s2 # a1 <-- a1 / 10
        add t1, t1, s1 # Transforma int em char (t1 + '0')
        sb t1, 0(a0) # Escreve o resto da divisão na string
        addi t0, t0, 1
        j 1b
    2:

    mv a1, t0
    
ret


# search
# 
# Percorre a lista ligada em busca da soma que resulta o número
# 
# param: a0 - número a ser buscado
# return: a0 - índice do nó
search:
    la a1, head_node

    li s0, 0 # indice
    li s1, 0 # indicador
    1:
        beqz a1, 3f

        lw a2, 0(a1)
        lw a3, 4(a1)

        add a2, a2, a3

        bne a0, a2, 2f
            addi s1, s1, 1
            j 3f
        2:

        lw a1, 8(a1)
        addi s0, s0, 1
        j 1b
    3:

    mv a0, s0

    bnez s1, 1f
        li a0, -1
    1:

ret

main:
    la s0, return
    sw ra, 0(s0) # Salva o endereço de retorno em return

########################################################

    jal read # buffer = "SDDDDD"
    la a0, buffer # a0 <-- &buffer[0]

    lb t0, 0(a0)
    li t1, '-'
    li a7, 0
    bne t0, t1, 2f
        li a7, 1
        addi a0, a0, 1
    2:

    jal string_to_int
    
    beqz a7, 2f
        li t0, -1
        mul a0, a0, t0
    2:

    jal search

########################################################

    mv a1, a0
    
    la a0, result

    li t0, 0
    li t1, '\n'

    sb t0, 7(a0)
    sb t1, 6(a0)

    bgez a1, 1f
        li t0, 49
        li t1, '-'

        sb t0, 5(a0)
        sb t1, 4(a0)

        addi a0, a0, 4
        li a1, 4
        j 2f
    1:
        jal int_to_string
    2:

    mv a2, a1
    mv a1, a0

    jal write

########################################################

    la s0, return
    lw ra, 0(s0)
    ret

_exit:
    li a0, 0
    li a7, 93
    ecall
