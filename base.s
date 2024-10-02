.data
    buffer: .space 5

.text
.globl _start

_start:
    jal main
    jal _exit

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, buffer       # buffer to write the data
    li a2, 5            # size
    li a7, 63           # syscall read (63)
    ecall
ret

write:
    li a0, 1                # file descriptor = 1 (stdout)
    li a7, 64               # syscall write (64)
    ecall
ret

main:
    la s0, return
    sw ra, 0(s0) # Salva o endereço de retorno em return

########################################################

########################################################

    la s0, return
    lw ra, 0(s0)
    ret

_exit:
    li a0, 0
    li a7, 93
    ecall
