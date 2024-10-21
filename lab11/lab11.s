.text
    .set    SDC_GPS,            0xFFFF0100
    .set    SDC_POS_X,          0xFFFF0110
    .set    SDC_POS_Y,          0xFFFF0114
    .set    SDC_POS_Z,          0xFFFF0118
    .set    SDC_STEERING_WHEEL, 0xFFFF0120
    .set    SDC_ENGINE,         0xFFFF0121
    .set    SDC_HAND_BRAKE,     0xFFFF0122

    .globl _start

_start:
    jal controlling_car
    jal _exit

# read_GPS:
#
# Emprega a técnica de Busy Waiting para a leitura das coordenadas
# do SDC (Self-Driving Car) C = (Xc; Yc; Zc) e as retorna
#
# param: -
# return: a0 - (int) Xc; a1 - (int) Yc; a2 - (int) Zc
read_GPS:
    li a0, SDC_GPS
    li t0, 1
    sb t0, 0(a0)
    0:
        lb a1, 0(a0)
        bnez a1, 0b
    
    li a0, SDC_POS_X
    lw a0, 0(a0)

    li a1, SDC_POS_Y
    lw a1, 0(a1)

    li a2, SDC_POS_Z
    lw a2, 0(a2)

ret

# distance_to_track
#
# Calcula a distância do carro até a pista de testes e retorna 1 se for menor que 15m
#
# param: a0 - (int) Xc; a1 - (int) Yc; a2 - (int) Zc
# return: a0 - (int) indicator
distance_to_track:
    li t0, 73
    li t1, -19

    sub t0, t0, a0          # t0 <-- t0 - a0 = (Xt - Xc)
    sub t1, t1, a2          # t1 <-- t1 - a2 = (Zt - Zc)

    mul t0, t0, t0          # t0 <-- t0^2 = (Xt - Xc)^2
    mul t1, t1, t1          # t1 <-- t1^2 = (Zt - Zc)^2

    add t0, t0, t1          # t0 <-- t0^2 + t1^2 = (Xt - Xc)^2 + (Zt - Zc)^2 = distance^2

    li t1, 225              # t1 <-- 15^2

    li a0, 0
    bgt t0, t1, 0f
        li a0, 1            # indica que a distância é menor que 15m
    0:

ret

# controlling_car
#
# Controla o carro do ponto inicial até a pista de testes
#
# param: -
# return: -
controlling_car:
    addi sp, sp, -16
    sw ra, 0(sp)

    0:
        jal read_GPS
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)

        jal distance_to_track
        bnez a0, 1f

        li a0, SDC_ENGINE
        li t0, 1
        sb t0, 0(a0)

        li t0, 89
        li t1, 107

        lw a0, 4(sp)
        lw a2, 12(sp)

        mul t0, t0, a0
        mul t1, t1, a2

        add t0, t0, t1

        li t1, 4464

        li a0, SDC_STEERING_WHEEL
        bne t0, t1, 2f
            li t2, 0
            j 3f
        2:
            lb t2, 0(a0)

            blt t0, t1, 4f
                addi t2, t2, -10
                li t3, -127

                bge t2, t3, 3f
                    li t2, -127
                    j 3f
                
                j 3f
            4:
                addi t2, t2, 10
                li t3, 127

                ble t2, t3, 3f
                    li t2, 127                
        3:
        sb t2, 0(a0)
        
        j 0b
    1:

    li a0, SDC_STEERING_WHEEL
    li t0, 0
    sb t0, 0(a0)

    li a0, SDC_HAND_BRAKE
    li t0, 1
    sb t0, 0(a0)

    li a0, SDC_ENGINE
    li t0, 0
    sb t0, 0(a0)

    lw ra, 0(sp)
    addi sp, sp, 16
ret

_exit:
    li a0, 0
    li a7, 93
    ecall