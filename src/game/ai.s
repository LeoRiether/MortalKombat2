#
# Everything the AI does
#

.data
    ai_list: .word 4, ai.nothing ai.kick ai.crouch ai.smart ai.random

    ai: ai.random

.text

# Chooses a random AI
ai.random:
    li a7 40
    li a0 1
    csrr a1 time
    ecall # Rand seed

    li a7 42
    li a0 1
    lw a1 ai_list
    addi a1 a1 -1 # exclude ai.random from the options
    ecall # Rand int in [0, ai_list.length)

    la t0 ai_list
    addi a0 a0 1
    slli a0 a0 2
    add t0 t0 a0
    lw t0 0(t0)

    sw t0 ai t1

    ret

# Does nothing
ai.nothing:
    ret

# Just kicks
ai.kick:
    la t0 player1.cur
    lhu t1 0(t0)
    slli t1 t1 1
    la t2 player1.id
    add t1 t1 t2
    lhu t1 0(t1) # t1 = animation id

    li t2 aIdle
    bne t1 t2 ai.kick.exit # if we're not idling, exit

    # Set animation to aKick
    la t1 player1.starts
    li t2 aKick
    slli t2 t2 1
    add t1 t1 t2
    lhu t1 0(t1) # t1 = start of kicking animation
    sh t1 0(t0) # set current animation

ai.kick.exit:
    ret

# Just crouches
ai.crouch:
    la t0 player1.starts
    lhu t0 4(t0) # 4(player1.starts) => aCrouch start
    addi t0 t0 1 # second frame
    la t1 player1.cur
    sh t0 0(t1)
    ret

# Gets close and kicks
ai.smart:
    la t0 player1.cur
    lhu t1 0(t0)
    slli t1 t1 1
    la t2 player1.id
    add t1 t1 t2
    lhu t1 0(t1) # t1 = animation id

    li t0 aKick
    beq t1 t0 ai.smart.exit # Already kicking

    li t0 aHit
    beq t1 t0 ai.smart.exit # We're hit, nothing to do

    li t0 aWalk
    bne t1 t0 ai.smart.set_walking # not walking? let's walk. If we decide to kick later, we override player1.cur
    ai.smart.after_set_walking:

    # We're either in aWalk or aIdle and need to decide what to do next
    la a0 player0.position
    lh a0 2(a0) # player0 column
    la a1 player1.position
    lh a1 2(a1) # player1 column

    blt a1 a0 ai.smart.to_left

    # We're to the right
    addi a2 a1 -38
    ble a2 a0 ai.smart.set_kicking # we're very close to the player! let's kick him

    # not close enough, let's walk towards the player
    addi a1 a1 -3
    la a0 player1.position
    sh a1 2(a0)

    ret

ai.smart.to_left:

    # We're to the left
    addi a2 a0 -45 # better range!
    ble a2 a1 ai.smart.set_kicking # we're very close to the player! let's kick him

    # not close enough, let's walk towards the player
    addi a1 a1 3
    la a0 player1.position
    sh a1 2(a0)

ai.smart.exit:
    ret

ai.smart.set_walking:
    li t0 aWalk
    slli t0 t0 1
    la a0 player1.starts
    add t0 a0 t0
    lhu t0 0(t0) # t0 = aWalk start frame

    # Set current animation as aWalk
    la a0 player1.cur
    sh t0 0(a0)
    li t0 funmed
    sh t0 2(a0)

    j ai.smart.after_set_walking

ai.smart.set_kicking:
    li t0 aKick
    slli t0 t0 1
    la a0 player1.starts
    add t0 a0 t0
    lhu t0 0(t0) # t0 = aKick start frame

    # Set current animation as aKick
    la a0 player1.cur
    sh t0 0(a0)
    li t0 funmed
    sh t0 2(a0)

    ret