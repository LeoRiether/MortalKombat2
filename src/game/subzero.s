.include "anim_eqvs.s"
.data

    subzero:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk
                  aCrouch aCrouch
                  aKick aKick aKick aKick aKick
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 37 99, 37 100, 37 101, 38 101, 39 100, 39 99, 39 100, 38 101, 37 101, 37 100 # aIdle
                     36 104, 31 104, 31 107, 34 103, 35 103, 31 103, 31 104, 34 105, 43 103 # aWalk
                     40 76, 40 59 # aCrouch
                     40 106, 44 104, 76 92, 38 94, 44 104 # aKick
        player0.sizes_end:
        player0.delays: .byte funmed funmed funmed funmed funmed funslow funmed funmed funmed funmed # aIdle
                      funfast funfast funfast funfast funfast funfast funfast funfast funfast # aWalk
                      funmed funmed # aCrouch
                      funmed funmed funslow funmed funmed # aKick
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