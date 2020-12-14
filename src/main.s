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

    call menu.main
    call cpl.main
    mv s0 a0
    call cbg.main
    mv a2 a0
    mv a0 s0
    call game.main

main.exit:
    li a7 10
    ecall

.include "lamar/SYSTEMv21.s"

.data
    __last_byte: .byte 0