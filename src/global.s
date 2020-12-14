.eqv dtframe 20
.eqv hpdrain_dt 48
.eqv hpdrain_amount 0
.eqv kick_damage -15

.data
    # Static buffers to put backgrounds in
    .word 0 # for alignment purposes
    player0.ss: .space 58000
    player1.ss: .space 58000
    bgbuf0: .space 38424

    str.wins: .string "wins"
    str.player_win: .string "Player X Wins" # X is in the index 7
    str.flawless: .string "Flawless Victory"
    str.finish: .string "Finish him!"
    str.kickality: .string "Kickality"

.text