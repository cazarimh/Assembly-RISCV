.data
    _system_time: .word 0

.bss
    isr_stack:
    .skip 1024
    isr_stack_end:

.text
    .set    GPT_READ_TIME,      0xFFFF0100 # (byte)
    .set    GPT_TIME,           0xFFFF0104 # (word)
    .set    GPT_EXT_INT,        0xFFFF0108 # (word)

    .set    MIDI_CHANNEL,       0xFFFF0300 # (byte)
    .set    MIDI_INSTRUMENT,    0xFFFF0302 # (short)
    .set    MIDI_NOTE,          0xFFFF0304 # (byte)
    .set    MIDI_NOTE_VEL,      0xFFFF0305 # (byte)
    .set    MIDI_NOTE_DUR,      0xFFFF0306 # (short)
    
    .globl _start, _system_time, play_note

_start:
    la t0, int_service_routine
    csrw mtvec, t0
    la t0, isr_stack_end
    csrw mscratch, t0

    csrr t1, mstatus
    ori t1, t1, 0x8
    csrw mstatus, t1

    csrr t1, mie
    li t2, 0x800
    or t1, t1, t2
    csrw mie, t1

    li a0, GPT_EXT_INT
    li t0, 100
    sw t0, 0(a0)

    jal main


# int_service_routine
#
# Salva o contexto, trata a interrupção e restaura o contexto
#
# param: -
# return: -
int_service_routine:
    # Salvar o contexto
    csrrw sp, mscratch, sp
    addi sp, sp, -64
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    sw a7, 28(sp)
    sw t0, 32(sp)
    sw t1, 36(sp)
    sw t2, 40(sp)
    sw t3, 44(sp)
    sw t4, 48(sp)
    sw t5, 52(sp)
    sw t6, 56(sp)
    sw ra, 60(sp)

    # Trata a interrupção
    li a0, GPT_EXT_INT
    li t0, 100
    sw t0, 0(a0)

    la a0, _system_time
    lw t0, 0(a0)
    addi t0, t0, 100
    sw t0, 0(a0)

    # Recupera o contexto
    lw ra, 60(sp)
    lw t6, 56(sp)
    lw t5, 52(sp)
    lw t4, 48(sp)
    lw t3, 44(sp)
    lw t2, 40(sp)
    lw t1, 36(sp)
    lw t0, 32(sp)
    lw a7, 28(sp)
    lw a6, 24(sp)
    lw a5, 20(sp)
    lw a4, 16(sp)
    lw a3, 12(sp)
    lw a2, 8(sp)
    lw a1, 4(sp)
    lw a0, 0(sp)
    addi sp, sp, 64
    csrrw sp, mscratch, sp

mret

# play_note
#
# Toca uma nota através de um MIDI audio player
#
# param: a0 - (int) channel; a1 - (int) instrument ID; a2 - (int) musical note; a3 - (int) note velocity; a4 - (int) note duration  
# return: -
play_note:
    li t1, MIDI_INSTRUMENT
    sh a1, 0(t1)

    li t2, MIDI_NOTE
    sb a2, 0(t2)

    li t3, MIDI_NOTE_VEL
    sb a3, 0(t3)

    li t4, MIDI_NOTE_DUR
    sh a4, 0(t4)

    li t0, MIDI_CHANNEL
    sb a0, 0(t0)

ret