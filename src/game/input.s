#
# Handles game input
# Requires "anim_eqvs.s" to be included before
#

.eqv scanRight 1 # 32, keymap 1
.eqv scanLeft 0x40000000 # 30, keymap 0
.eqv scanUp 0x20000 # 17, keymap 0
.eqv scanDown 0x80000000 # 31 keymap 0
.eqv scanKick 0x400000 # 22 keymap 0

input.print_scancode:
    li a7 KDMMIO_Ctrl
    lw t0 0(a7)
    beqz t0 input.print_scancode.exit

    lw t0 4(a7) # clear the bit
    li a7 Buffer0Teclado
    lb t0 0(a7)
    debug_int(t0)

input.print_scancode.exit:
    ret


# Read input and decide if something should be done about it
input.handle:
    # Load animation status, it's always useful
    lb t1 player0.cur # current animation frame
    la a1 player0.id
    slli t2 t1 1
    add t2 t2 a1 # pointer to animation id
    lh t2 0(t2) # current animation id

    # We should not accept input if the animation is an attack (> aCrouch)
    li t0 aCrouch
    bgt t2 t0 input.handle.exit


    li a7 KeyMap0

    # This seems loop-able

    # u (kick)
    lw t0 0(a7)
    andi t0 t0 scanKick
    bnez t0 input.handle.kick

    # right
    lw t0 4(a7)
    andi t0 t0 scanRight
    bnez t0 input.handle.right

    # left
    lw t0 0(a7)
    andi t0 t0 scanLeft
    bnez t0 input.handle.left

    # up
    lw t0 0(a7)
    andi t0 t0 scanUp
    bnez t0 input.handle.up

    # down
    lw t0 0(a7)
    andi t0 t0 scanDown
    bnez t0 input.handle.down

input.handle.none:
    # Stop walking
    li t3 aWalk
    beq t2 t3 input.handle.reset_anim_to_idle

    # Stop crouching
    li t3 aCrouch
    beq t2 t3 input.handle.reset_anim_to_idle

input.handle.exit:
    ret

input.handle.reset_anim_to_idle:
    la t0 player0.cur
    sw zero 0(t0) # stores both the new animation frame and frames until next update
    ret

input.handle.right:
    # Move player
    la a7 player0.position
    lh t0 2(a7)
    addi t0 t0 3
    sh t0 2(a7)

    # Set animation to aWalk
    li t0 aWalk
    beq t2 t0 input.handle.exit # no need

    la a7 player0.cur
    sh zero 2(a7)
    slli t0 t0 1
    la t1 player0.starts
    add t0 t0 t1
    lh t0 0(t0)
    sh t0 0(a7)

    ret

input.handle.left:
    # Move player
    la a7 player0.position
    lh t0 2(a7)
    addi t0 t0 -3
    bltz t0 input.handle.left.skip_negative
    sh t0 2(a7)
input.handle.left.skip_negative:

    # Set animation to aWalk
    li t0 aWalk
    beq t2 t0 input.handle.exit # no need

    la a7 player0.cur
    sh zero 2(a7)
    slli t0 t0 1
    la t1 player0.starts
    add t0 t0 t1
    lh t0 0(t0)
    sh t0 0(a7)

    ret

input.handle.up:
    # Move player
    la a7 player0.position
    lh t0 0(a7)
    addi t0 t0 -3
    sh t0 0(a7)

    ret

input.handle.down:
    # Change animation to aCrouch
    li t0 aCrouch
    beq t2 t0 input.handle.exit # no need

    slli t0 t0 1
    la t1 player0.starts
    add t1 t0 t1
    lh t1 0(t1)

    la t0 player0.cur
    sh t1 0(t0)

    ret

input.handle.kick:
    li t0 aIdle
    beq t2 t0 input.handle.kick.default

    li t0 aWalk
    beq t2 t0 input.handle.kick.default

    # can't kick
    ret

input.handle.kick.default:
    # t1 = aKick start frame
    li t0 aKick
    slli t0 t0 1
    la t1 player0.starts
    add t1 t0 t1
    lh t1 0(t1)

    la t0 player0.cur
    sh t1 0(t0)

    ret