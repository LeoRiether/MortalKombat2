.data
    # do NOT put anything here
    # we use too much memory already

.text

# Runs the "choose background" screen
# Returns the index of the chosen one in a0
cbg.main:
    addi sp sp -4
    sw ra 0(sp)

    # Load the background
    la a0 file.choose_bg
    la a1 player0.ss # reuse the spritesheets! (overflows into player1.ss, but it's fine)
    li a2 0
    call sprites.load

    # Draw it
    la a0 player0.ss
    li a1 0
    li a2 0
    mv a3 s11
    call sprites.draw2

cbg.input:
    li t0 KDMMIO_Ctrl
    lw t1 0(t0) # t1 = kdmmio control bit
    andi t1 t1 1
    beqz t1 cbg.input

    lw t1 4(t0) # t1 = key
    li a0 '1'
    li a1 '5'
    blt t1 a0 cbg.input # too low
    bgt t1 a1 cbg.input # too high

    # just right
    sub a0 t1 a0 # a0 = map index

cbg.main.exit:

    lw ra 0(sp)
    addi sp sp 4
    ret
