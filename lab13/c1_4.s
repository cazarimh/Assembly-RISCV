.text
    .globl operation

operation:
    add a0, a1, a2      # a0 <-- b + c
    sub a0, a0, a5      # a0 <-- b + c - f
    add a0, a0, a7      # a0 <-- b + c - f + h

    lw a1, 8(sp)        # a1 <-- k
    lw a2, 16(sp)       # a2 <-- m

    add a0, a0, a1      # a0 <-- b + c - f + h + k
    sub a0, a0, a2      # a0 <-- b + c - f + h + k - m
ret