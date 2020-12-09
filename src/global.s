.data
    # Static buffers to put backgrounds in
    bgbuf0: .space 38424

    unimplemented.str: .string "reached unimplemented function!\n"

.text

unimplemented:
    la a0 unimplemented.str
    li a7 4
    ecall
    j main.exit