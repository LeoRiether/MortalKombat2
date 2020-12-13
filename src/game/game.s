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
    la a0 player0.cur
    la a1 player0.next
    la a2 player0.delays
    call game.update_animation
    la a0 player1.cur
    la a1 player1.next
    la a2 player1.delays
    call game.update_animation

    # Kill player0 slowly
    call dificuldade_crescente

    # Do the thing written in the lines below (unless it's commented)
    # call input.print_scancode
    call input.handle

    # Update width and height from sprites
    # Update player 1
    lh t0 player1.cur
    slli t0 t0 3
    la t1 player1.sizes
    add t0 t0 t1
    lw a3 -8(t0) # column
    lw a4 0(t0)
    sub a4 a4 a3 # width is calculated using psum
    lw a5 4(t0) # height
    # a4 = width, a5 = height
    la t0 player1.position
    sh a4 4(t0)
    sh a5 6(t0)

    mv s0 a3 # sprite column for player 1 (only used until we draw player 1)

    # Update player 0
    lh t0 player0.cur
    slli t0 t0 3
    la t1 player0.sizes
    add t0 t0 t1
    lw a3 -8(t0) # column
    lw a4 0(t0)
    sub a4 a4 a3 # width is calculated using psum
    lw a5 4(t0) # height
    # a4 = width, a5 = height
    la t0 player0.position
    sh a4 4(t0)
    sh a5 6(t0)

    mv s1 a3 # sprite column for player 0 (only used until we draw player 0)

    # Clamp positions
    la a0 player0.position
    call game.clamp_position
    la a0 player1.position
    call game.clamp_position

    # Load positions for legacy reasons
    la a0 player0.position
    lh t0 2(a0)
    lh t1 10(a0)

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
    la a5 player1.position
    lhu a1 0(a5)
    lhu a2 2(a5)
    mv a3 s0
    lhu a4 4(a5)
    lhu a5 6(a5)
    sub a1 a1 a5 # we store the bottom row, but draw from the top
    mv a6 s11
    lbu a7 player1.side
    call sprites.cdraw

    # Draw player 0
    la a0 player0.ss
    la a5 player0.position
    lhu a1 0(a5)
    lhu a2 2(a5)
    mv a3 s1
    lhu a4 4(a5)
    lhu a5 6(a5)
    sub a1 a1 a5 # we store the bottom row, but draw from the top
    mv a6 s11
    lbu a7 player0.side
    call sprites.cdraw

    # Draw health bars
    la a0 player0.health
    lbu a0 0(a0)
    li a1 16
    mv a2 s11
    call sprites.draw_hp
    la a0 player1.health
    lbu a0 0(a0)
    li a1 204
    mv a2 s11
    call sprites.draw_hp

    # Careful with the steps that use SYSTEm calls, some arguments carry over from one function to the other!
    # for example, a4 = frame is only set in the next call
    # Also, SYSTEMv21 calls use some saved registers!
    # So let's save the ones we need, hopefully we won't forget any
    addi sp sp -12
    sw s11 0(sp)
    sw s10 4(sp)
    sw s9 8(sp)

    # Draw player names
    la a0 player0.name
    li a1 16 # x
    li a2 18 # y
    li a3 0xc700
    mv a4 s11
    call printString
    la a0 player1.name
    li a1 204 # x
    li a2 18 # y
    call printString

    # Draw number of wins
    li a0 0
    li a1 15
    li a2 3
    li a3 0xc7ff
    call printIntUnsigned
    li a0 1 # actual number of wins
    call printIntUnsigned
    la a0 str.wins
    li a1 38
    call printString

    # Draw timer
    lw s9 8(sp)
    srai a0 s9 10 # poor man's divide by 1000
    li a1 150
    li a2 18
    call printIntUnsigned

    # Restore saved registers
    lw s11 0(sp)
    lw s10 4(sp)
    lw s9 8(sp)
    addi sp sp 12

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
# Arguments are passed in saved registers because reasons
# s2 = stage index
game.load_assets:
    addi sp sp -4
    sw ra 0(sp)

    # Load background
    slli t0 s2 2
    la a0 bgs
    add a0 a0 t0
    lw a0 0(a0)
    la a1 bgbuf0
    li a2 1
    call sprites.load

    # Load first player
    la a0 ss.subzero
    la a1 player0.ss
    li a2 1
    call sprites.load

    la a0 player0.sizes
    la a1 player0.sizes_end
    call game.psum_widths

    # Load second player
    la a0 ss.liu_kang
    la a1 player1.ss
    li a2 1
    call sprites.load

    la a0 player1.sizes
    la a1 player1.sizes_end
    call game.psum_widths

game.load_assets.exit:
    lw ra 0(sp)
    addi sp sp 4
    ret

# Resets the game so a previous round doesn't affect the initial player positions and stuff
game.reset:
    # Reset player positions
    # player0.position: .half 213, 26, 0, 0
    # player1.position: .half 213, 250, 0, 0
    la a0 player0.position
    li t0 1704149
    sw t0 0(a0)
    li t0 16384213
    sw t0 8(a0)

    # Reset hp
    la a0 player0.health
    li t0 25700 # 100 hp for both
    sh t0 0(a0)

    # Reset time to end round
    # I don't really know why I use a register for this
    li s9 102390

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

# Clamps the player position between the borders
# Actually, does not check if the column is less than zero, that's done in input.handle
# because otherwise I can't get it to work
# ¯\_(ツ)_/¯
# a0 = player.position
game.clamp_position:
    lh t0 2(a0) # column

    li t2 319
    lhu t1 4(a0) # width
    sub t1 t2 t1 # t1 = maximum valid column

    ble t0 t1 game.clamp_position.skip
    sh t1 2(a0)
game.clamp_position.skip:

    ret

# Kills player0 slowly
dificuldade_crescente:
    la a0 player0.hp_countdown
    lbu t0 0(a0)
    addi t0 t0 -1
    beqz t0 dificuldade_crescente.damage
    sb t0 0(a0)
    ret

dificuldade_crescente.damage:
    li t0 80
    sb t0 0(a0)

    la a0 player0.health
    lbu t0 0(a0)
    addi t0 t0 -1
    sb t0 0(a0)
    ret
