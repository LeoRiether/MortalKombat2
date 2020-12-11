#
# Various .data definitions for game.s
#

.data
    subzero:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk
                  aCrouch aCrouch
                  aKick aKick aKick aKick aKick
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 38 99, 38 100, 38 101, 38 101, 40 100, 40 99, 40 100, 38 101, 38 101, 38 100 # aIdle
                     36 104, 32 104, 32 107, 34 103, 36 103, 32 103, 32 104, 34 105, 44 103 # aWalk
                     40 76, 40 59 # aCrouch
                     40 106, 44 104, 76 92, 38 94, 44 104 # aKick
        player0.sizes_end:
        player0.delays: .byte funmed funmed funmed funmed funmed funslow funmed funmed funmed funmed # aIdle
                      funfast funfast funfast funfast funfast funfast funfast funfast funfast # aWalk
                      funfast funfast # aCrouch
                      funmed funfast funmed 7 funmed # aKick
        player0.next: .half 1 2 3 4 5 6 7 8 9 0 # aIdle
                            11 12 13 14 15 16 17 18 10 # aWalk
                            20 20 # aCrouch
                            22 23 24 25 0 # aKick
        player0.back: .space 128
        player0.starts: .half
            0 # aIdle
            10 # aWalk
            19 # aCrouch
            21 # aKick

    scorpion:
        player1.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player1.sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        player1.sizes_end:
        player1.delays: .byte funmed funmed funmed funmed funmed funmed # aIdle
        player1.next: .half 1, 2, 3, 4, 5, 0
        player1.back: .space 128
        player1.starts: .half
            0
            0

    # TODO: define the maximum spritesheet size
    .word 0 # for alignment purposes
    player0.ss: .space 76808
    player1.ss: .space 76808

    player0.cur: .half 0, 0 # current animation, how many frames until an update should be made
    player1.cur: .half 0, 0

    player0.side: .byte 0
    player1.side: .byte 1

    player0.health: .byte 50
    player1.health: .byte 1

    .word 0
    player0.position: .half 213, 26
    player1.position: .half 213, 250

    player0.name: .string "Sub Zero"
    player1.name: .string "Scorpion"