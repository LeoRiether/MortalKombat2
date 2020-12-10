#
# Draws a 16×16 color thingy with all the 8bit colors supported by FPGRARS
# I thought
#

.text

li s0 0 # color
li s1 0 # row
outer:
    li t0 256
    bge s0 t0 exit

    li s2 0 # column
    inner:
        mv a0 s1
        mv a1 s2
        jal rect

        addi s0 s0 1
        addi s2 s2 1
        li t0 16
        blt s2 t0 inner

    addi s1 s1 1
    j outer

# Draws a rectangle
# a0 = row
# a1 = column
rect:
    li a7 0xFF000000 # Video memory start
    slli a0 a0 3
    slli a1 a1 3
    li t0 320
    mul a0 a0 t0
    add a0 a0 a1
    add a7 a7 a0 # Where we should start drawing

    li t0 8 # Remaining height
rect.outer:
    li t1 8 # Remaining width
    mv a0 a7 # Video memory position
    rect.inner:
        sb s0 0(a0) # draw

        addi a0 a0 1
        addi t1 t1 -1
        bgtz t1 rect.inner

    addi a7 a7 320 # next line
    addi t0 t0 -1
    bgtz t0 rect.outer

rect.exit:
    ret

# bad naming, does the exact opposite
exit:
    # sleep for 500ms
    li a7 32
    li a0 500
    ecall

    # and repeat
    j exit

