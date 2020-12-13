#
# Everything the AI does
#

.data
    ai_list: .word 3, ai.random ai.nothing ai.kick

    ai: ai.kick

.text

# Chooses a random AI
ai.random:
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


