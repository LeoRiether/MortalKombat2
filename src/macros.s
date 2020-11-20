.macro sleep(%ms)
    li a7 32
    li a0 %ms
    ecall
.end_macro