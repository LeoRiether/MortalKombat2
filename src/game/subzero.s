.include "anim_eqvs.s"
.data

    subzero:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk
                  aCrouch aCrouch
                  aKick aKick aKick aKick aKick
                  aHit
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 38 99, 38 100, 38 101, 38 101, 40 100, 40 99, 40 100, 38 101, 38 101, 38 100 # aIdle
                    36 104, 32 104, 32 107, 34 103, 36 103, 32 103, 32 104, 34 105, 44 103 # aWalk
                    40 76, 40 59 # aCrouch
                    40 106, 44 104, 76 92, 38 94, 44 104 # aKick
                    36 103 # aHit
        player0.sizes_end:
        player0.delays: .byte funmed funmed funmed funmed funmed funslow funmed funmed funmed funmed # aIdle
                      funfast funfast funfast funfast funfast funfast funfast funfast funfast # aWalk
                      funfast funfast # aCrouch
                      funmed funfast funmed 7 funmed # aKick
                      funslowestestest # aHit
        player0.next: .half 1 2 3 4 5 6 7 8 9 0 # aIdle
                            11 12 13 14 15 16 17 18 10 # aWalk
                            20 20 # aCrouch
                            22 23 24 25 0 # aKick
                            0
        player0.starts: .half
            0 # aIdle
            10 # aWalk
            19 # aCrouch
            21 # aKick
            26 # aHit
