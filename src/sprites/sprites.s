#
# Stuff related to drawing sprites
#

.text

# a0 = address of the sprite
# a1 = row
# a2 = column
# a3 = frame
sprites.draw:
sprites.draw.outer:

sprites.draw.outer.control:

sprites.draw.exit:
    ret

# Loads a sprite from a file and stores it in a buffer
# You better hope the buffer has enough space (it should be at least `width × height + 8`,
# the 8 is for 2 words: (height, width))
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
    addi a1 s1 4
    ecall

sprites.load.exit:
    lw s0 0(sp)
    lw s1 4(sp)
    lw ra 8(sp)
    addi sp sp 12
    ret