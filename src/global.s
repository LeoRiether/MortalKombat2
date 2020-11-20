.data
    # Static buffers to put stuff backgrounds in
    bgbuf0: .space 76808
    bgbuf1: .space 76808

    unimplemented.str: .string "reached unimplemented function!\n"

.text

unimplemented:
    la a0 unimplemented.str
    li a7 4
    ecall
    j main.exit