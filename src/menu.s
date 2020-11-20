#
#  Displays a menu and that's it
#

.data
    titlescreen_static.file: .string "assets/sub_test.d.bin"
    .align 3

.text
menu.main:
    addi sp sp -4
    sw ra 0(sp)

    # Store the titlescreen in bgbuf0
    la a0 titlescreen_static.file
    la a1 bgbuf0
    call sprites.load

    # Draw titlescreen
    la a0 bgbuf0 # sprite
    li a1 0 # row
    li a2 0 # column
    li a3 0 # frame
    call sprites.draw

    sleep(2500)
    li a7 110
    ecall

menu.main.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret
