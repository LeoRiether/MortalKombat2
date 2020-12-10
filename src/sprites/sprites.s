#
# Stuff related to drawing sprites
#

.include "files.s"

.text

# Draws a sprite on (row=a1, col=a2) of the screen, on frame a3
# ~~PLEASE make sure the width is a multiple of 2! This is important and faster and stuff!~~
# Currently does not require the stuff above, but this function is a contender for optimization
# using the constraints above
# a0 = address of the sprite
# a1 = row
# a2 = column
# a3 = frame, either 0 or 1
sprites.draw:
    mv t3 a0
    addi a0 a0 16

    lw a4 4(a0) # height
    lw a5 0(a0) # width
    addi a0 a0 8

    srai a5 a5 1

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

        lbu t2 0(a0)
        andi t5 t2 0xf
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 0(t1)
        srli t5 t2 4
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 1(t1)

        addi a0 a0 1
        addi t1 t1 2
        addi t0 t0 -1

        j sprites.draw.inner

sprites.draw.outer.control:
    addi a4 a4 -1
    addi a3 a3 NUMCOLUNAS

    j sprites.draw.outer

sprites.draw.exit:
    ret

# Draws a CROPPED sprite from a spritesheet with the following arguments:
# a0 = address of the spritesheet
# a1 = row
# a2 = column
# a3 = sprite column (row is always 0)
# a4 = sprite width
# a5 = sprite height
# a6 = frame
# a7 = flip?
sprites.cdraw:
    mv t3 a0
    addi a0 a0 16

    srai a4 a4 1

    lw t6 0(a0) # t6 = width of the sprite
    srai t6 t6 1 # every byte stores 2 pixels!
    addi a0 a0 8

    li t0 NUMCOLUNAS
    mul t0 a1 t0
    add t0 t0 a2
    li t1 0xFF000000
    slli a6 a6 20
    or a6 t1 a6
    add a6 t0 a6
    # a6 = first pixel position in memory (on the right frame already)

    srai a3 a3 1
    add a0 a0 a3
    # a0 = first sprite pixel position in memory

sprites.cdraw.outer:
    # We use a5=sprite height as a decrementing counter from now on
    blez a5 sprites.cdraw.exit

    mv t0 a4 # also a decrementing counter, now for the remaining width
    mv t1 a6 # copy of the memory position we're drawing/writing to
    mv t2 a0 # copy of the sprite buffer we're reading from

    beqz a7 sprites.cdraw.inner # don't flip
    add t2 t2 a4 # excitingly start from the other side
    addi t2 t2 -1

    sprites.cdraw.inner:
        blez t0 sprites.cdraw.outer.control
        bnez a7 sprites.cdraw.inner_flipped

    sprites.cdraw.inner_not_flipped:
        # Draw 2 pixels
        lbu t4 0(t2)
        andi t5 t4 0xf
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 0(t1)
        srli t5 t4 4
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 1(t1)

        addi t2 t2 1
        j sprites.cdraw.inner_after

    sprites.cdraw.inner_flipped:
        # Draw 2 pixels
        lbu t4 0(t2)
        andi t5 t4 0xf
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 1(t1)
        srli t5 t4 4
        add t5 t5 t3 # position of the color in the palette
        lbu t5 0(t5)
        sb t5 0(t1)

        addi t2 t2 -1

    sprites.cdraw.inner_after:
        addi t1 t1 2
        addi t0 t0 -1

        j sprites.cdraw.inner

sprites.cdraw.outer.control:
    addi a5 a5 -1
    addi a6 a6 NUMCOLUNAS
    add  a0 a0 t6

    j sprites.cdraw.outer

sprites.cdraw.exit:
    ret

# Loads a sprite from a file and stores it in a buffer
# You better hope the buffer has enough space (it should be at least `width × height / 2 + 8 + 16`,
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
    li a2 24 # Read the palette and (width, height)
    ecall

    lw t0 16(s1)
    lw t1 20(s1)
    mul a2 t0 t1 # Read t0 * t1 / 2 more bytes
    srai a2 a2 1

    li a7 63
    mv a0 s0
    addi a1 s1 24
    ecall

sprites.load.exit:
    lw s0 0(sp)
    lw s1 4(sp)
    lw ra 8(sp)
    addi sp sp 12
    ret

# Draws a health bar
# a0 = hp
# a1 = column
# a2 = frame
sprites.draw_hp:
    li a3 10 # Remaining height

    li a7 0xff001400 # Start of line 16ish in the video memory
    slli a2 a2 20
    or a7 a7 a2
    add a7 a7 a1

sprites.draw_hp.outer:
    li a4 100 # Current health position (counts down to 1)
    addi a6 a7 99 # position in video memory (last pixel of the bar)

    sprites.draw_hp.inner:
        li t6 48 # load green
        ble a4 a0 sprites.draw_hp.inner.control # don't load the red
        li t6 5 # do load the red
        sprites.draw_hp.inner.control:

        sb t6 0(a6)
        addi a6 a6 -1
        addi a4 a4 -1
        bgez a4 sprites.draw_hp.inner

    addi a3 a3 -1
    addi a7 a7 320
    bgez a3 sprites.draw_hp.outer

sprites.draw_hp.exit:
    ret
