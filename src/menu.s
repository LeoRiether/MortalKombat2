#
#  Displays a menu and that's it
#

.text
menu.main:
    addi sp sp -4
    sw ra 0(sp)

    # Store the titlescreen in bgbuf0
    la a0 file.titlescreen_static
    la a1 bgbuf0
    call sprites.load

    la a0 file.sub_zero
    la a1 bgbuf1
    call sprites.load

    li s1 0 # player column
    li s11 0 # frame

menu.loop:
    csrr s0 time

    # Draw titlescreen
    la a0 bgbuf0 # sprite
    li a1 0 # row
    li a2 0 # column
    mv a3 s11 # frame
    call sprites.draw

    # Draw player
    la a0 bgbuf1
    li a1 50
    mv a2 s1
    mv a3 s11 # frame
    call sprites.draw

    swap_frame(s11, t0)

    addi t0 s0 dtframe # next frame time
menu.loop.wait:
    csrr t1 time
    blt t1 t0 menu.loop.wait

    addi s1 s1 1
    li t0 320
    rem s2 s2 t0
    j menu.loop

menu.exit:
    sleep(2500)

menu.main.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret
