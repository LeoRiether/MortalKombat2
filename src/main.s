.include "lamar/MACROSv21.s"
.include "macros.s"

.text
    j main

.include "global.s"
.include "sprites/sprites.s"

.include "menu.s"
.include "game/game.s"

.data


.text
main:
    call menu.main
    call game.main

main.exit:
    li a7 10
    ecall

.include "lamar/SYSTEMv21.s"
