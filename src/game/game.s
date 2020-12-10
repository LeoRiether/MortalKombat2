#
#  Fights and stuff
#

.include "anim_eqvs.s"
.include "input.s"
.include "data.s"

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
    la a0 player0
    call game.update_animation
    la a0 player1
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
    call game.psum_widths

    la a0 player0.back
    la a1 player0.next
    call game.build_back_anim

    # Load second player
    la a0 ss.scorpion
    la a1 player1.ss
    call sprites.load

    la a0 player1.sizes
    la a1 player1.sizes_end
    call game.psum_widths

    la a0 player1.back
    la a1 player1.next
    call game.build_back_anim

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

# Builds player.back based on player.next
# Assumes begin(player.back) = end(player.next)
# a0 = player.back
# a1 = player.next
game.build_back_anim:
    li a2 0 # current animation frame index
game.bba.loop:
    # beware the pointer manipulation
    lhu t0 0(a1) # t0 = next[i]
    slli t0 t0 1
    add t0 t0 a0 # t0 = &back[next[i]]
    sh a2 0(t0) # back[next[i]] = a2

    addi a1 a1 2
    addi a2 a2 1
    blt a1 a0 game.bba.loop

game.bba.exit:
    ret

# Goes to the next animation frame of player `a0`
# a0 = player
game.update_animation:
    lw a1 28(a0) # player.cur
    lh t1 2(a1) # how many frames until we should change frame
    addi t1 t1 -1
    sh t1 2(a1)
    bgtz t1 game.update_animation.exit

    lhu t0 0(a1) # current frame

    # Update frame
    lw a2 12(a0) # player.next
    slli t0 t0 1
    add t0 t0 a2
    lh t0 0(t0) # next frame
    sw t0 0(a1)

    # Update how many frames until change
    lw a3 8(a0) # player.delays
    add a3 t0 a3
    lbu a3 0(a3)
    sh a3 2(a1)

game.update_animation.exit:
    ret