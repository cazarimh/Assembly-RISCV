.text
    .globl my_function


my_function:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)            # salvando a na pilha
    sw a1, 8(sp)            # salvando b na pilha
    sw a2, 12(sp)           # salvando c na pilha

    add a0, a1, a0          # a0 <-- a + b
    lw a1, 4(sp)            # a1 <-- a
    jal mystery_function    # a0 <-- CALL 1

    lw a1, 8(sp)            # a1 <-- b
    sub a0, a1, a0          # a0 <-- b - CALL 1

    lw a1, 12(sp)           # a1 <-- c
    add a0, a0, a1          # a0 <-- aux = b - CALL 1 + c

    sw a0, 4(sp)            # salvando aux na pilha (onde estava a)
    lw a1, 8(sp)            # a1 <-- b
    jal mystery_function    # a0 <-- CALL 2

    lw a1, 12(sp)           # a1 <-- c
    sub a0, a1, a0          # a0 <-- c - CALL 2

    lw a1, 4(sp)            # a1 <-- aux
    add a0, a0, a1          # a0 <-- c - CALL 2 + aux

    lw ra, 0(sp)
    addi sp, sp, 16
ret