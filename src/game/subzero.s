.include "anim_eqvs.s"
.data

    subzero:
        player0.id: .half aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle aIdle
        .word 0, 0 # prefix sum needs this
        player0.sizes: .word 37 99, 37 100, 37 101, 38 101, 39 100, 39 99, 39 100, 38 101, 37 101, 37 100
        player0.next: .half 1 2 3 4 5 6 7 8 9 0
        player0.cur: .half 0