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

ai.smart.exit:
    ret