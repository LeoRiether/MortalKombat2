.include "anim_eqvs.s"
.data

    liu_kang:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk
                  aCrouch aCrouch
                  aKick aKick aKick aKick
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 42 98 42 99 42 100 42 100 42 99 42 98 # aIdle
                        42 103 42 104 42 104 42 104 42 103 42 103 42 103 44 102 42 101 # aWalk
                        42 73 40 55 # aCrouch
                        38 101 40 100 54 93 72 89 # aKick
        player0.sizes_end:
        player0.delays: .byte funmed funmed funmed funmed funmed funmed # aIdle
                        funmed funmed funmed funmed funmed funmed funmed funmed funmed # aWalk
                        funmed funmed # aCrouch
                        funmed funfast funmed 7 # aKick
        player0.next: .half 1 2 3 4 5 0 # aIdle
                            7 8 9 10 11 12 13 14 6 # aWalk
                            16 16 # aCrouch
                            18 19 20 0 # aKick
        player0.starts: .half
            0 # aIdle
            6 # aWalk
            15 # aCrouch
            17 # aKick