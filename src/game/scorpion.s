.include "anim_eqvs.s"
.data

    scorpion:
        id: .half aIdle aIdle aIdle aIdle aIdle aIdle # 6
        .word 0, 0 # prefix sum needs this
        sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        sizes_end:
        delays: .byte funmed funmed funmed funmed funmed funmed # aIdle
        next: .half 1, 2, 3, 4, 5, 0
        back: .space 128

        starts: .half
            0