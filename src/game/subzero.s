.include "anim_eqvs.s"
.data

    subzero:
        id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle # 10
                  aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk aWalk # 9
        .word 0, 0 # prefix sum needs this
        sizes: .word
            37 99, 37 100, 37 101, 38 101, 39 100, 39 99, 39 100, 38 101, 37 101, 37 100 # aIdle
            36 104, 31 104, 31 107, 34 103, 35 103, 31 103, 31 104, 34 105, 43 103 # aWalk
        sizes_end:
        delays: .byte funmed funmed funmed funmed funmed funslow funmed funmed funmed funmed # aIdle
                      funfast funfast funfast funfast funfast funfast funfast funfast funfast # aWalk
        next: .half 1 2 3 4 5 6 7 8 9 0 11 12 13 14 15 16 17 18 10
        back: .space 128

        starts: .half
            0 # aIdle
            10 # aWalk
