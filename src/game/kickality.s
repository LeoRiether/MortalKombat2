
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

    la a0 player0.ss
    li a1 0x03
    xori a2 s11 1
    call random_fill_screen

kickality.exit:
    lw ra 0(sp)
    lw s8 4(sp)
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

# Fills screen with the color on a1 randomly, using a0 as a buffer
# a0 = buffer
# a1 = color
# a2 = frame
random_fill_screen:
    li t0 0xFF000000
    slli a2 a2 20
    or t0 t0 a2
    li t1 0x12C00

    slli a7 a1 8
    or a7 a7 a1 # a7 = color

    add a1 a0 t1 # a1 = buffer end

    add t1 t1 t0
    # t0 = video begin, t1 = video end

    # fills [a0, a1) with t0, t0+2, t0+4, ...
    # completely unreadable
    mv a2 a0 # a2 = copy of begin
    li t1 160
rfs.fill:
    sw t0 0(a2)
    addi a2 a2 4
    addi t0 t0 2
    addi t1 t1 -1
    beqz t1 rfs.fill_skip_line
    blt a2 a1 rfs.fill
    j rfs.fill.out

rfs.fill_skip_line:
    li t1 160
    addi t0 t0 NUMCOLUNAS
    blt a2 a1 rfs.fill

rfs.fill.out:

    # Allocate space on the stack
    addi sp sp -16
    sw ra 0(sp)
    sw s0 4(sp)
    sw s1 8(sp)
    sw s2 12(sp)
    mv s0 a0 # begin
    mv s1 a1 # end
    mv s2 a7 # color
    # draws a random permutation of [a0, a1) to the screen
rfs.draw:
    li t0 4000
    rfs.draw.wait:
        addi t0 t0 -1
        bgez t0 rfs.draw.wait

    # choose random number in [s0, s1)
    li a0 1
    sub a1 s1 s0
    li a7 42
    ecall

    li t0 3
    xori t0 t0 -1
    and a0 a0 t0 # align the chosen number
    add a0 a0 s0 # offset by s0

    # Load the memory position we should write to and draw a 2x2 square
    lw t0 0(a0)
    sh s2 0(t0)
    sh s2 NUMCOLUNAS(t0)

    # Swap 0(a0) and -4(s1)
    # But we don't actually need to store anything in -4(s1) -- it's never going to be read
    lw t0 -4(s1)
    sw t0 0(a0)

    addi s1 s1 -4
    blt s0 s1 rfs.draw

random_fill_screen.exit:
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    addi sp sp 16
    ret