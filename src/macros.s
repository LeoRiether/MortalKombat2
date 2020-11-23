.eqv dtframe 20

.macro sleep(%ms)
    li a7 32
    li a0 %ms
    ecall
.end_macro

.macro swap_frame(%frame, %aux)
    li %aux VGAFRAMESELECT
    sw %frame 0(%aux)
    xori %frame %frame 1
.end_macro

.macro push(%arg, %into, %offset)
    sw %into %offset(sp)
    mv %into %arg
.end_macro

.macro linebreak()
    li a7 11
    li a0 '\n'
    ecall
.end_macro

.macro print_int()
    li a7 1
    ecall
.end_macro

# Prints the thing in %reg without changing any registers
# Calls ecall %ecall
.macro debug_with(%reg, %ecall)
    addi sp sp -8
    sw a0 0(sp)
    sw a7 4(sp)
    li a7 %ecall
    mv a0 %reg
    ecall
    li a7 11
    li a0 '\n'
    ecall
    lw a0 0(sp)
    lw a7 4(sp)
    addi sp sp 8
.end_macro

.macro debug_int(%reg)
    debug_with(%reg, 1)
.end_macro

.macro debug_hex(%reg)
    debug_with(%reg, 34)
.end_macro

.macro debug_char(%reg)
    debug_with(%reg, 11)
.end_macro