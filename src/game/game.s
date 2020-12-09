#
#  Fights and stuff
#

.include "anim_eqvs.s"
.include "input.s"

.data

    subzero:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk
                  aCrouch aCrouch
                  aKick aKick aKick aKick aKick
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 38 99, 38 100, 38 101, 38 101, 40 100, 40 99, 40 100, 38 101, 38 101, 38 100 # aIdle
                     36 104, 32 104, 32 107, 34 103, 36 103, 32 103, 32 104, 34 105, 44 103 # aWalk
                     40 76, 40 59 # aCrouch
                     40 106, 44 104, 76 92, 38 94, 44 104 # aKick
        player0.sizes_end:
        player0.delays: .byte funmed funmed funmed funmed funmed funslow funmed funmed funmed funmed # aIdle
                      funfast funfast funfast funfast funfast funfast funfast funfast funfast # aWalk
                      funfast funfast # aCrouch
                      funmed funmed funslow funmed funmed # aKick
        player0.next: .half 1 2 3 4 5 6 7 8 9 0 # aIdle
                            11 12 13 14 15 16 17 18 10 # aWalk
                            20 20 # aCrouch
                            22 23 24 25 0 # aKick
        player0.back: .space 128
        player0.starts: .half
            0 # aIdle
            10 # aWalk
            19 # aCrouch
            21 # aKick

    scorpion:
        player1.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player1.sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        player1.sizes_end:
        player1.delays: .byte funmed funmed funmed funmed funmed funmed # aIdle
        player1.next: .half 1, 2, 3, 4, 5, 0
        player1.back: .space 128
        player1.starts: .half
            0
            0

    # TODO: define the maximum spritesheet size
    .word 0 # for alignment purposes
    player0.ss: .space 76808
    player1.ss: .space 76808

    player0.cur: .half 0, 0 # current animation, how many frames until an update should be made
    player1.cur: .half 0, 0

    player0.side: .byte 0
    player1.side: .byte 1

    .word 0
    player0.position: .half 213, 36
    player1.position: .half 213, 240

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
    jal game.reset

    li s11 0 # frame
    csrr s10 time
game.main.loop:
    mv t0 s10
    csrr s10 time # now

    # Update time to end round
    sub t0 s10 t0 # now - last frame
    sub s9 s9 t0

    # Update animation frames
    la a0 player0.cur
    la a1 player0.next
    la a2 player0.delays
    call game.update_animation
    la a0 player1.cur
    la a1 player1.next
    la a2 player1.delays
    call game.update_animation

    # Do the thing written in the lines below (unless it's commented)
    # call input.print_scancode
    call input.handle

    # Load positions for legacy reasons
    la a0 player0.position
    lh t0 2(a0)
    lh t1 6(a0)

    # Update sides (gets t0 and t1 from the block above)
    la a0 player0.side
    slt t0 t1 t0
    sb t0 0(a0)
    xori t0 t0 1
    sb t0 1(a0)

    # Draw background
    la a0 bgbuf0
    mv a1 zero
    mv a2 zero
    mv a3 s11
    call sprites.draw

    # Draw player 1
    la a0 player1.ss
    la a2 player1.position
    lhu a1 0(a2)
    lhu a2 2(a2)
    lh t0 player1.cur
    slli t0 t0 3
    la t1 player1.sizes
    add t0 t0 t1
    lw a3 -8(t0) # column
    lw a4 0(t0)
    sub a4 a4 a3 # width is calculated using psum
    lw a5 4(t0) # height
    sub a1 a1 a5 # drawn from bottom
    mv a6 s11
    lbu a7 player1.side
    call sprites.cdraw

    # Draw player 0
    la a0 player0.ss
    la a2 player0.position
    lhu a1 0(a2)
    lhu a2 2(a2)
    lh t0 player0.cur
    slli t0 t0 3
    la t1 player0.sizes
    add t0 t0 t1
    lw a3 -8(t0) # column
    lw a4 0(t0)
    sub a4 a4 a3 # width is calculated using psum
    lw a5 4(t0) # height
    sub a1 a1 a5 # drawn from bottom
    mv a6 s11
    lbu a7 player0.side
    call sprites.cdraw


    addi t0 s10 dtframe # next time we should enter the loop
game.main.loop.wait:
    csrr t1 time
    blt t1 t0 game.main.loop.wait

    swap_frame(s11, t0)

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
    la a0 file.portal
    la a1 bgbuf0
    call sprites.load

    # Load first player
    la a0 ss.subzero
    la a1 player0.ss
    call sprites.load

    la a0 player0.sizes
    la a1 player0.sizes_end
    jal game.psum_widths

    # Load second player
    la a0 ss.scorpion
    la a1 player1.ss
    call sprites.load

    la a0 player1.sizes
    la a1 player1.sizes_end
    jal game.psum_widths

game.load_assets.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret

# Resets the game so a previous round doesn't affect the initial player positions and stuff
game.reset:
    # Reset player positions
    # player0.position: .half 213, 36
    # player1.position: .half 213, 240
    la a0 player0.position
    li t0 3670229
    sw t0 0(a0)
    li t0 15728853
    sw t0 4(a0)

    # Reset time to end round
    # I don't really know why I use a register for this
    li s9 99999

game.reset.exit:
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
# a2 = player.delays
game.update_animation:
    lh t1 2(a0) # how many frames until we should change frame
    addi t1 t1 -1
    sh t1 2(a0)
    bgtz t1 game.update_animation.exit

    lh t0 0(a0) # current frame

    # Update frame
    slli t0 t0 1
    add t0 t0 a1
    lh t0 0(t0) # next frame
    sw t0 0(a0)

    # Update how many frames until change
    add a2 t0 a2
    lbu a2 0(a2)
    sh a2 2(a0)

game.update_animation.exit:
    ret