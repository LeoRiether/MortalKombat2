.include "lamar/MACROSv21.s"
.include "macros.s"

.text
    j main

.include "global.s"
.include "sprites/sprites.s"
.include "menu.s"
.include "player/player.s"

.data


.text
main:
    jal menu.main

main.exit:
    li a7 10
    ecall

.include "lamar/SYSTEMv21.s"
