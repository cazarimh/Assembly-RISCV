.text
    .globl middle_value_int, middle_value_short, middle_value_char, value_matrix

middle_value_int:
    srli a1, a1, 1
    li t0, 4
    mul a1, a1, t0
    add a0, a0, a1
    lw a0, 0(a0)
ret

middle_value_short:
    srli a1, a1, 1
    li t0, 2
    mul a1, a1, t0
    add a0, a0, a1
    lh a0, 0(a0)
ret

middle_value_char:
    srli a1, a1, 1
    li t0, 1
    mul a1, a1, t0
    add a0, a0, a1
    lb a0, 0(a0)
ret

value_matrix:
    li t0, 42
    mul a1, t0, a1
    add a1, a1, a2
    li t0, 4
    mul a1, a1, t0
    add a0, a0, a1
    lw a0, 0(a0)
ret