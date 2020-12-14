.eqv dtframe 20
.eqv hpdrain_dt 48
.eqv hpdrain_amount -1
.eqv kick_damage -15

.data
    # Static buffers to put backgrounds in
    .word 0 # for alignment purposes
    player0.ss: .space 58000
    player1.ss: .space 58000
    bgbuf0: .space 38424

    str.wins: .string " Wins"
    str.flawless: .string "Flawless Victory"
    str.finish: .string "Finish him!"
    str.kickality: .string "Kickality"

.text