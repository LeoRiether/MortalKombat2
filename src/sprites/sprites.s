#
# Stuff related to drawing sprites
#

.text

# Draws a sprite on (row=a1, col=a2) of the screen, on frame a3
# PLEASE make sure the width is a multiple of 4! This is important and faster and stuff!
# a0 = address of the sprite
# a1 = row
# a2 = column
# a3 = frame, either 0 or 1
sprites.draw:
    lw a4 4(a0) # height
    lw a5 0(a0) # width
    addi a0 a0 8

    li t0 NUMCOLUNAS
    mul t0 a1 t0
    add t0 t0 a2
    li t1 0xFF000000
    slli a3 a3 20
    or a3 t1 a3
    add a3 t0 a3
    # a3 = first pixel position in memory (on the right frame already)

sprites.draw.outer:
    # We use a4=height as a decrementing counter from now on
    blez a4 sprites.draw.exit

    mv t0 a5 # also a decrementing counter, now for the remaining width
    mv t1 a3 # copy of the memory position we're drawing/writing to
    sprites.draw.inner:
        blez t0 sprites.draw.outer.control

        # This is faster:
        # lw t2 0(a0)
        # sw t2 0(t1)
        # addi a0 a0 4
        # addi t1 t1 4
        # addi t0 t0 -4

        # Slower, but supports transparency:
        lbu t2 0(a0)
        addi t3 t2 -0xc7
        beqz t3 sprites.draw.skip
        sb t2 0(t1)
    sprites.draw.skip:
        addi a0 a0 1
        addi t1 t1 1
        addi t0 t0 -1

        j sprites.draw.inner

sprites.draw.outer.control:
    addi a4 a4 -1
    addi a3 a3 NUMCOLUNAS

    j sprites.draw.outer

sprites.draw.exit:
    ret

# Loads a sprite from a file and stores it in a buffer
# You better hope the buffer has enough space (it should be at least `width × height + 8`,
# the 8 is for 2 words: (width, height))
# a0 = file string
# a1 = buffer address
sprites.load:
    addi sp sp -12
    sw s0 0(sp)
    sw s1 4(sp)
    sw ra 8(sp)

    mv s1 a1

    # Open file
    # a0 is the file string here
    li a7 1024
    li a1 0
    ecall

    mv s0 a0

    li a7 63
    mv a1 s1
    li a2 8 # Read the first two words
    ecall

    lw t0 0(s1)
    lw t1 4(s1)
    mul a2 t0 t1 # Read t0 * t1 more bytes

    li a7 63
    mv a0 s0
    addi a1 s1 8
    ecall

sprites.load.exit:
    lw s0 0(sp)
    lw s1 4(sp)
    lw ra 8(sp)
    addi sp sp 12
    ret