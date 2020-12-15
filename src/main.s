#######################
#                     #
#  Controls:          #
#     A: move left    #
#     D: move right   #
#     S: crouch       #
#     U: kick         #
#                     #
#######################

.include "lamar/MACROSv21.s"
.include "macros.s"

.text
    j main

.include "global.s"
.include "sprites/sprites.s"

.include "menu.s"
.include "game/game.s"
.include "choose_player.s"
.include "choose_bg.s"

.text
main:
    la a0 __last_byte
    debug_int(a0)

    # Psum player widths right at the beginning!
    la a0 player0.sizes
    la a1 player0.sizes_end
    call game.psum_widths
    la a0 player1.sizes
    la a1 player1.sizes_end
    call game.psum_widths

    call menu.main
    call cpl.main
    mv s0 a0
    call cbg.main

    addi sp sp -8
    sw s0 0(sp) # game.main a0
    sw a0 4(sp) # game.main a2
main.loop:
    lw a0 0(sp)
    lw a2 4(sp)
    call game.main
    j main.loop # doesn't ever exit

    addi sp sp 8

main.exit:
    li a7 10
    ecall

.include "lamar/SYSTEMv21.s"

.data
    __last_byte: .byte 0