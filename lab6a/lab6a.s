.data
    buffer: .space 30

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
    la a1, buffer       # buffer
    li a2, 22           # size
    li a7, 64           # syscall write (64)
    ecall
    ret

# int_to_string
# 
# Escreve na string original o resultado da raiz quadrada
# 
# param: a0 - endereço da string; a1 - raiz quadrada
# return: -
int_to_string:
    addi a0, a0, 4 # Vai até o último char do número atual
    li s1, 48 # Valor do char '0'
    li s2, 10

    li t1, 4
    repeat:
        beqz t1, finish
        addi a0, a0, -1
        sb s1, 0(a0) # Escreve o char s1 no endereço a0
        rem t2, a1, s2 # t2 <-- a1 % 10
        div a1, a1, s2 # a1 <-- a1 / 10
        add t2, t2, s1 # Transforma int em char (t2 + '0')
        sb t2, 0(a0) # Escreve o resto da divisão na string
        addi t1, t1, -1
        j repeat
    finish:

    li t1, 0
    sb t1, 20(a0)
    
    ret

# square_root
# 
# Calcula a raiz quadrada aproximada pelo método babilônico
# 
# param: a1 - inteiro
# return: a1 - raiz quadrada do original
square_root:
    srli t2, a1, 1 # t2 <-- k = y/2

    li t1, 10
    for:
        beqz t1, skip
        div t3, a1, t2 # t3 <-- y/k
        add t3, t3, t2 # t3 <-- k + y/k
        srli t2, t3, 1 # t2 <-- (k + y/k)/2
        addi t1, t1, -1
        j for
    skip:
    
    mv a1, t2 # a1 <-- t2

    mv s0, ra # Afim de não perder o endereço de ra, salvamos em s0
    jal int_to_string
    mv ra, s0

    ret

# string_to_int
# 
# Transforma uma string com 4 caracteres em um inteiro
# 
# param: a0 - endereço da string
# return: a1 - inteiro representado na string
string_to_int:
    li s0, 10
    li a1, 0

    li t1, 4
    loop:
        beqz t1, stop
        mul a1, a1, s0 # a1 <-- a1 * 10
        lb t2, 0(a0) # Carrega o char no endereço a0
        addi t2, t2, -48 # Transforma o char em int
        add a1, a1, t2 # a1 <-- a1 + t2
        addi a0, a0, 1 # Incrementa 1 no endereço de a0
        addi t1, t1, -1
        j loop
    stop:

    addi a0, a0, -4 # Decrementa 4 no endereço de a0

    ret


main:
    jal read
    la a0, buffer # Armazena em a0 a string lida

    li t0, 4 # Contador para o laço de repetição
    while:
        beqz t0, end
        jal string_to_int # Transforma cada parte da string em um inteiro
        jal square_root # Calcula a raiz quadrada do numero e escreve na string
        addi a0, a0, 5 # Passa para o próximo número (incremento de 5 no endereço de a0)
        addi t0, t0, -1
        j while
    end:

    jal write

    li a0, 0
    ret

_exit:
    li a0, 0
    li a7, 93
    ecall

