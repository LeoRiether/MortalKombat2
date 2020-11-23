.include "anim_eqvs.s"
.data

    scorpion:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 43 102, 44 101, 43 100, 42 101, 43 102, 43 103
        player0.next: .half 1, 2, 3, 4, 5, 0
        player0.cur: .half 0