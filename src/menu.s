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
    li a2 1
    call sprites.load

    # Draw titlescreen
    la a0 bgbuf0 # sprite
    li a1 0 # row
    li a2 0 # column
    mv a3 s11 # frame
    call sprites.draw

    # j menu.main.exit

    sleep(1200)

    li a7 104
    la a0 str.press_play
    li a1 80
    li a2 215
    li a3 0xc7ff
    mv a4 s11
    ecall

menu.main.wait_for_keypress:
    li t1 KDMMIO_Ctrl
    lw t0 0(t1)
    lw t2 4(t1)
    # debug_int(t0)
    sleep(100)
    beqz t0 menu.main.wait_for_keypress

menu.main.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret
