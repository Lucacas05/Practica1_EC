# Ejercicio 1: Binomio de Newton con enteros

.text

Binomial_coef:
    # guardamos registros en pila
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp) # n
    sw s1, 12(sp) # k
    sw s2, 8(sp) # n!
    sw s3, 4(sp) # k!
    sw s4, 0(sp) # (n-k)!
    
    mv s0, a0
    mv s1, a1
    
    # calculo n!
    li t0, 1 # resultado = 1
    li t1, 1 # contador = 1
    ble s0, zero, factorial_n_end # si n <= 0, factorial = 1
factorial_n_loop:
    bgt t1, s0, factorial_n_end #si contador > n, termina el factorial
    mul t0, t0, t1
    addi t1, t1, 1
    j factorial_n_loop
factorial_n_end:
    mv s2, t0
    
    # calculo de k! 
    li t0, 1
    li t1, 1
    ble s1, zero, factorial_k_end # si k <= 0, factorial = 1
factorial_k_loop:
    bgt t1, s1, factorial_k_end #si contador > k, termina el factorial
    mul t0, t0, t1
    addi t1, t1, 1
    j factorial_k_loop
factorial_k_end:
    mv s3, t0
    
    # calculo (n-k)! 
    sub t2, s0, s1 # t2 = n - k
    li t0, 1
    li t1, 1
    ble t2, zero, factorial_nk_end # si (n-k) <= 0, factorial = 1
factorial_nk_loop:
    bgt t1, t2, factorial_nk_end #si contador > (n-k) , termina el factorial
    mul t0, t0, t1
    addi t1, t1, 1
    j factorial_nk_loop
factorial_nk_end:
    mv s4, t0
    
    # calculo del binomio n! / (k! * (n-k)!)
    mul t0, s3, s4 # k! * (n-k)!
    div a0, s2, t0 # n! / (k! * (n-k)!)
    
    # restauramos registros 
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    
    jr ra

Newton_int:
    # guardamos registros en pila
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp) # n
    sw s1, 24(sp) # k: contador
    sw s2, 20(sp) # C(n,k)
    fsw fs0, 16(sp) # a: flotante
    fsw fs1, 12(sp) # b: flotante
    fsw fs2, 8(sp) # resultado acumulado
    fsw fs3, 4(sp) # a^(n-k)
    fsw fs4, 0(sp) # b^k
    
    mv s0, a0
    fmv.s fs0, fa0
    fmv.s fs1, fa1
    
    fcvt.s.w fs2, zero # resultado = 0
    
    li s1, 0 # k = 0
    
newton_loop:
    # si k > n, terminamos
    bgt s1, s0, newton_end
    
    # calculamos C(n,k) usando Binomial_coef
    mv a0, s0 # n
    mv a1, s1 # k
    jal ra, Binomial_coef
    mv s2, a0 # C(n,k)
    
    # calculo a^(n-k)
    fmv.s fa0, fs0 # a
    sub a0, s0, s1 # n - k
    jal ra, pow # usamos la libreria pow
    fmv.s fs3, fa0
    
    # calculo b^k
    fmv.s fa0, fs1 # b
    mv a0, s1 # k
    jal ra, pow
    fmv.s fs4, fa0
    
    # calculamos C(n,k) * a^(n-k) * b^k
    fcvt.s.w ft0, s2
    fmul.s ft1, ft0, fs3   
    fmul.s ft1, ft1, fs4
    
    # acumulamos resultado
    fadd.s fs2, fs2, ft1 # resultado += término
    
    # incrementamos el contador
    addi s1, s1, 1 # k += 1
    j newton_loop
    
newton_end:
    fmv.s fa0, fs2 # resultado
    
    # restauramos registros
    lw ra, 32(sp)
    lw s0, 28(sp)
    lw s1, 24(sp)
    lw s2, 20(sp)
    flw fs0, 16(sp)
    flw fs1, 12(sp)
    flw fs2, 8(sp)
    flw fs3, 4(sp)
    flw fs4, 0(sp)
    addi sp, sp, 36
    
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
    mv s0, a0
    
    # llama a Newton_int(a, b, n)
    fmv.s fa0, fs0
    fmv.s fa1, fs1
    mv a0, s0
    jal ra, Newton_int
    
    # imprime resultado
    li a7, 2
    ecall
    
    # salir
    li a7, 10
    ecall