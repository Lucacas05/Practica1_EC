.text
E:
    addi sp, sp, -20
    sw   ra, 16(sp)
    fsw  fs0, 12(sp)
    fsw  fs1, 8(sp)
    fsw  fs2, 4(sp)

    # primer término
    fmv.s fs0, fa0      # fs0 = x

    li t0, 1            # para comenzar la serie en 1
    fcvt.s.w fs1, t0    # sum = 1
    fcvt.s.w fs2, t0    # term = 1
    li t1, 1            # contador k = 1

E_bucle:
    li t2, 20           # límite de la serie
    bge t1, t2, E_fin   # si k >= 20 salir

    # term = term * x / k
    fcvt.s.w ft0, t1    # convertir k a float
    fmul.s fs2, fs2, fs0 # term *= x
    fdiv.s fs2, fs2, ft0 # term = term / k
    fadd.s fs1, fs1, fs2 # sum += term
    addi t1, t1, 1       # k++
    j E_bucle

E_fin:
    fmv.s fa0, fs1      # retornar sum en fa0

    # restaurar los registros
    lw   ra, 16(sp)
    flw  fs0, 12(sp)
    flw  fs1, 8(sp)
    flw  fs2, 4(sp)
    addi sp, sp, 20
    jr   ra


Arctanh:
    addi sp, sp, -20
    sw   ra, 16(sp)
    fsw  fs0, 12(sp)   # y
    fsw  fs1, 8(sp)    # term
    fsw  fs2, 4(sp)    # sum

    fmv.s fs0, fa0     # y
    fmv.s fs1, fa0     # term = y
    fmv.s fs2, fa0     # sum = y
    li t1, 1            # k = 1

Arctanh_bucle:

    li t2, 20
    bge t1, t2, Arctanh_final

    # term = term * y * y
    fmul.s fs1, fs1, fs0
    fmul.s fs1, fs1, fs0
    # divisor = 2*k + 1
    add  t3, t1, t1   # t3 = t1 + t1 = 2*k
    addi t3, t3, 1    # t3 = 2*k + 1
    fcvt.s.w ft0, t3

    # sum += term / divisor
    fdiv.s ft1, fs1, ft0
    fadd.s fs2, fs2, ft1

    addi t1, t1, 1
    j Arctanh_bucle

Arctanh_final:
    fmv.s fa0, fs2

    # restaurar los registros
    lw   ra, 16(sp)
    flw  fs0, 12(sp)
    flw  fs1, 8(sp)
    flw  fs2, 4(sp)
    addi sp, sp, 20
    jr   ra

Ln:
    addi sp, sp, -16
    sw   ra, 12(sp)
    fsw  fs0, 8(sp)
    fsw  fs1, 4(sp)

    fmv.s fs0, fa0        # x

# comprobacion de NAN (si x es negativo)
    fmv.s ft0, fs0
    fsub.s ft0, ft0, ft0    # ft0 = 0.0
    fle.s t0, fs0, ft0      # t0 = 1 si x <= 0
    bne t0, zero, Ln_nan    # saltar si x <= 0


    li t0, 1
    fcvt.s.w ft0, t0
    fsub.s ft1, fs0, ft0  # x - 1
    fadd.s ft2, fs0, ft0  # x + 1
    fdiv.s fs1, ft1, ft2  # y = (x-1)/(x+1)

    fmv.s fa0, fs1
    jal ra, Arctanh       # llama Arctanh
    li t1, 2
    fcvt.s.w ft0, t1
    fmul.s fa0, fa0, ft0  # ln(x) = 2 * artanh(y)

Ln_nan:
    li   t1, 0x7FC00000     # patrón IEEE-754 de NaN
    fmv.w.x fa0, t1         # moverlo a fa0 (resultado NaN)
    j    Ln_fin

Ln_fin:
    lw   ra, 12(sp)
    flw  fs0, 8(sp)
    flw  fs1, 4(sp)
    addi sp, sp, 16
    jr ra


powf:
    addi sp, sp, -24
    sw   ra, 20(sp)
    fsw  fs0, 16(sp)
    fsw  fs1, 12(sp)

    fmv.s fs0, fa0
    fmv.s fs1, fa1
    fmv.s fa0, fs0
    jal  ra, Ln
    fmul.s fa0, fa0, fs1
    jal  ra, E

    flw  fs1, 12(sp)
    flw  fs0, 16(sp)
    lw   ra, 20(sp)
    addi sp, sp, 24
    jr ra


Newton_real:
    addi sp, sp, -40
    sw   ra, 36(sp)
    fsw  fs0, 32(sp)
    fsw  fs1, 28(sp)
    fsw  fs2, 24(sp)
    fsw  fs3, 20(sp)
    fsw  fs4, 16(sp)

    fmv.s fs0, fa0        # fs0 = a
    fmv.s fs1, fa1        # fs1 = b
    fmv.s fs2, fa2        # fs2 = n

    # ---- comprobación de dominio: n < 0 → devolver NaN ----
    fmv.s ft0, fs2
    fsub.s ft0, ft0, ft0    # ft0 = 0.0
    flt.s t0, fs2, ft0      # t0 = 1 si n < 0
    bne  t0, zero, Newton_NAN   # saltar si n < 0

    # term0 = a^n
    fmv.s fa0, fs0
    fmv.s fa1, fs2
    jal   ra, powf
    fmv.s fs3, fa0
    fmv.s fs4, fs3
    li   t1, 1

Newton_bucle:
    li   t2, 20
    bge  t1, t2, Newton_fin

    fcvt.s.w ft0, t1
    addi t3, t1, -1
    fcvt.s.w ft1, t3
    fsub.s ft2, fs2, ft1
    fdiv.s ft3, ft2, ft0
    fdiv.s ft4, fs1, fs0
    fmul.s fs3, fs3, ft3
    fmul.s fs3, fs3, ft4
    fadd.s fs4, fs4, fs3
    addi t1, t1, 1
    j Newton_bucle

Newton_NAN:
    li   t1, 0x7FC00000     # patrón IEEE-754 de NaN
    fmv.w.x fa0, t1         # fa0 = NaN
    j Newton_fin

Newton_fin:
    fmv.s fa0, fs4

    flw  fs4, 16(sp)
    flw  fs3, 20(sp)
    flw  fs2, 24(sp)
    flw  fs1, 28(sp)
    flw  fs0, 32(sp)
    lw   ra, 36(sp)
    addi sp, sp, 40
    jr ra



main:
    # input de a (float)
    li a7, 6
    ecall
    fmv.s fs0, fa0

    # input de b (float)
    li a7, 6
    ecall
    fmv.s fs1, fa0

    # input de n (int)
    li a7, 5
    ecall
    fcvt.s.w fs2, a0        # convertir entero a float

    # llama a Newton_real(a, b, n)
    fmv.s fa0, fs0
    fmv.s fa1, fs1
    fmv.s fa2, fs2
    jal ra, Newton_real

    # imprime resultado (solo número)
    li a7, 2
    ecall

    # salir
    li a7, 10
    ecall
