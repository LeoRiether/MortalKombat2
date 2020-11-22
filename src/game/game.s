#
#  Fights and stuff
#

.eqv aIdle 0

.data
    scorpion:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        player0.next: .half 1, 2, 3, 4, 5, 0
        player0.cur: .half 0

    also_scorpion:
        player1.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player1.sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        player1.next: .half 1, 2, 3, 4, 5, 0
        player1.cur: .half 0

    # TODO: define the maximum spritesheet size
    .word 0 # for alignment purposes
    player0.ss: .space 76808
    player1.ss: .space 76808

.text

# Runs a full fight
# a0 = player 0 index
# a1 = player 1 index
# a2 = stage index
# a3 = ai update function pointer
game.main:
    addi sp sp -20
    sw ra 0(sp)
    push(a0 s0 4)
    push(a1 s1 8)
    push(a2 s2 12)
    push(a3 s3 16)

    jal game.load_assets

    li s11 0 # frame
game.main.loop:
    csrr s10 time # now

    # Update animation frames
    la a0 player0.cur
    la a1 player0.next
    call game.update_animation
    la a0 player1.cur
    la a1 player1.next
    call game.update_animation

    # Draw background
    la a0 bgbuf0
    mv a1 zero
    mv a2 zero
    mv a3 s11
    call sprites.draw

    # Draw players
    la a0 player0.ss
    li a1 213
    li a2 36
    lh t0 player0.cur
    slli t0 t0 3
    la t1 player0.sizes
    add t0 t0 t1
    lw a3 -8(t0) # column
    lw a4 0(t0)
    sub a4 a4 a3 # width is calculated using psum
    lw a5 4(t0) # height
    sub a1 a1 a5
    mv a6 s11
    call sprites.cdraw

    swap_frame(s11, t0)

    addi t0 s10 dtframe # next time we should enter the loop
    addi t0 t0 100
game.main.loop.wait:
    csrr t1 time
    blt t1 t0 game.main.loop.wait

    j game.main.loop

game.main.exit:
    lw ra 0(sp)
    lw s0 4(sp)
    lw s1 8(sp)
    lw s2 12(sp)
    lw s3 16(sp)
    addi sp sp 20
    ret

# Loads game assets
game.load_assets:
    addi sp sp -4
    sw ra 0(sp)

    # Load background
    la a0 file.deadpool
    la a1 bgbuf0
    call sprites.load

    # Load first player
    la a0 ss.scorpion
    la a1 player0.ss
    call sprites.load

    la a0 player0.sizes
    la a1 player0.next # technically a hack
    jal game.psum_widths

    # Load second player
    la a0 ss.scorpion
    la a1 player1.ss
    call sprites.load

game.load_assets.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret

# Makes the widths of a player.sizes a prefix sum
# a0 = begin
# a1 = end
game.psum_widths:
    bge a0 a1 game.psw.exit

    lw t0 0(a0) # current
    lw t1 -8(a0) # previous
    add t0 t0 t1
    sw t0 0(a0)

    addi a0 a0 8
    j game.psum_widths

game.psw.exit:
    ret

# Goes to the next animation frame of player `a0`
# a0 = player.cur
# a1 = player.next
game.update_animation:
    lh t0 0(a0) # current frame

    slli t0 t0 1
    add t0 t0 a1
    lh t0 0(t0) # next frame
    sw t0 0(a0)

    ret
