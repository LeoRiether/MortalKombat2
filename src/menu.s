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

    # Draw titlescreen
    la a0 bgbuf0 # sprite
    li a1 0 # row
    li a2 0 # column
    mv a3 s11 # frame
    call sprites.draw

    sleep(10000)

menu.main.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret
