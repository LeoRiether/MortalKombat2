.eqv dtframe 20
.eqv hpdrain_dt 80
.eqv hpdrain_amount -1
.eqv kick_damage -20

.data
    # Static buffers to put backgrounds in
    .word 0 # for alignment purposes
    player0.ss: .space 58000
    player1.ss: .space 58000
    bgbuf0: .space 38424

    str.wins: .string "wins"
    str.flawless: .string "Flawless Victory"

.text