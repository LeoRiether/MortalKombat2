
# Maybe draws "KICKALITY" on the screen
# Maybe just says which player won
kickality:
    addi sp sp -8
    sw ra 0(sp)
    sw s8 4(sp)

    # Load kickality sprite
    la a0 sprite.kickality
    la a1 bgbuf0
    li a2 1
    call sprites.load

    # Write some spaces to erase "finish him"
    call kickality.draw_spaces

    # Change str.player_win string to have the right player
    bgtz s8 kickality.p1_win
kickality.p0_win:
    lw a0 player0.name
    j kickality.p_win.after

kickality.p1_win:
    la a0 player1.name

kickality.p_win.after:

    # Write "{player name} Wins"
    li a1 108
    li a2 37
    li a3 0x00ff
    xori a4 s11 1
    call printString
    la a0 str.wins
    xori a4 s11 1
    call printString
    lw s8 4(sp)

    sleep(1500)

    li t0 gs_p0_kickality
    beq s8 t0 kickality.yes_kickality
    li t0 gs_p1_kickality
    beq s8 t0 kickality.yes_kickality
    j kickality.after_kickality
kickality.yes_kickality:

    # KICKALITY
    la a0 bgbuf0
    li a1 50
    li a2 95
    xori a3 s11 1
    call sprites.draw

kickality.after_kickality:

    # Flawless victory?
    la a0 player0.health
    li t1 100
    lb t0 0(a0)
    beq t0 t1 kickality.flawless
    lb t0 1(a0)
    beq t0 t1 kickality.flawless
    j kickality.after_flawless

kickality.flawless:

    # Flawless victory!
    sleep(1500)
    la a0 str.flawless
    li a1 97
    li a2 78
    li a3 0x00ff
    xori a4 s11 1
    call printString
    lw s8 4(sp)

kickality.after_flawless:

    sleep(4000)

kickality.exit:
    lw s8 4(sp)
    lw ra 0(sp)
    addi sp sp 8
    ret


# Draws some spaces to erase "finish him"
kickality.draw_spaces:
    addi sp sp -12
    sw ra 0(sp)
    sw s8 8(sp)

    la a0 str.spaces
    li a1 80
    li a2 37
    li a3 0x0000
    xori a4 s11 1
    call printString

kickality.draw_spaces.exit:

    lw ra 0(sp)
    lw s8 8(sp)
    addi sp sp 12
    ret