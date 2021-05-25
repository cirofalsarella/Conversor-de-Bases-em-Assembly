.data
    .align 0

    BinNum: .asciiz "1101"

.text
    .globl main

    main:

        la $s0, BinNum      #salva endereço do número em s0

        move $a0, $s0       #endereço como parametro

        jal tamanho_string  #pega o tamanho da string digitada

        move $s1, $v0       #salva tamanho da string em s1

        #li $v0, 1
        #move $a0, $s1       #printa tamanho
        #syscall

        move $a0, $s0
        move $a1, $s1
        jal VerificaBin     #função que recebe numero e tamanho, retornando 1 caso valido e 0 caso nao

        move $t0, $v0
        beq $t0, $zero, fimProg     #se 0, fim do programa

        move $a0, $s0
        move $a1, $s1
        jal ConverteBinToDec  #funcao que converte string binaria em um decimal

        move $s2, $v0

        move $a0, $s2
        jal ConverteDecToBin    #funcao que converte inteiro decimal em string do numero em bin

        move $s3, $v0           #salva string binaria em s3
        
        li $v0, 4
        move $a0, $s3
        syscall

        li $v0, 36
        move $a0, $s2
        syscall


    fimProg:
        li $v0, 10
        syscall             #finaliza programa


tamanho_string:
	move $t0, $a0	#copia endereço da string para t0
	li $t1, 0	#valor inicial do tamanho da string
	lb $t2, 0($t0)	#primeira letra da string
	
	loop:
	beq $t2, $zero, fim
	
	addi $t1, $t1, 1
	addi $t0, $t0, 1
	lb $t2, 0($t0)
	j loop
	
	fim:
	move $v0, $t1
	jr $ra


VerificaBin:
    li  $t8, '0'
    move $t0, $a0       #salva endereço da string em t0
    move $t1, $a1       #salva tamanho da string em t1

    li $t2, 32          #salva tamanho maximo permitido em t2

    ble $t1, $t2, FimPermitido  #caso tamanho seja menor ou igual a 32, valor permitido

    # caso string seja maior que 32, entra aqui

    move $t3, $t1       #salva contador de bit mais significativo atual

    loopVerificaChar:
        beq $t3, $t2, FimPermitido     #se o contador for igual a 32, sai do loop 

        lb  $t4, 0($t0) #salva caractere atual em t4
        
        bne $t4, $t8, FimNPermitido  #se o caractere não for '0', sai do loop

        addi $t3, $t3, -1
        addi $t0, $t0, 1
        j loopVerificaChar 

    FimPermitido:
        li $v0, 1       # 1 significa valor permitido
        jr $ra

    FimNPermitido:
        li $v0, 0       # 0 significa valor não permitido
        jr $ra


ConverteBinToDec:
    move $t0, $a0   #endereço da string
    move $t1, $a1   #tamanho da string

    add $t0, $t0, $t1      #posiciona t0 no final da string (bit menos significativo)
    addi $t0, $t0, -1 #posiciona t0 no final da string (bit menos significativo)


    move $t8, $zero         #valor do numero em binario
    move $t7, $zero
    addi $t7, $t7, 1        #carrega 1 em t7

    li $t6, '0'             #caractere '0'

    li $t5, 2               #base 2

    loopBinDec:
        beq $t1, $zero, fimConverteBinToDec     #caso contador seja zero, fim

        lb $t2, 0($t0)  #carrega byte atual em t2
        beq $t2, $t6, proximoBitBin     #se caractere for '0', nao adiciona

        add $t8, $t8, $t7       #adiciona ao resultado o valor de t7

        proximoBitBin:
            addi $t0, $t0, -1   #aponta para o proximo bit da string
            mul $t7, $t7, $t5   #multiplica t7 por 2
            addi $t1, $t1, -1   #decrementa contador/tamanho da string
            j loopBinDec

    fimConverteBinToDec:
        move $v0, $t8
        jr $ra


ConverteDecToBin:
    move $t0, $a0   #guarda valor decimal em t0

    li $v0, 9
    li $a0, 33      #aloca string de 33 bytes
    syscall

    move $t1, $v0   #salva string em t1

    li $t2, 31      #salva contador de loop em t2

    add $t1, $t1, $t2   #posiciona ponteiro da string no bit menos significativo do numero binario

    li $t3, 2       #base 2

    li $t4, '1'       #valor '1'
    li $t5, '0'       #valor '0'


    loopDecToBin:
        blt $t2, $zero, fimDecToBin     #contador menor que 0, fim do algoritmo

        div $t0, $t3        #divide numero pela base
        
        mfhi $t6            #recuperando resto
        mflo $t7            #recuperando quociente

        move $t0, $t7       #salva resultado

        bne $t6, $zero, coloca1     #verifica valor do resto
        
        sb $t5, 0($t1)       #salva '0' na posição atual
        j decrementaPonteiro
        
        coloca1:
            sb $t4, 0($t1)    #salva '1' na posicao atual

        decrementaPonteiro:
            addi $t1, $t1, -1
            addi $t2, $t2, -1
            j loopDecToBin

    fimDecToBin:
        addi $t1, $t1, 1
        sb $zero, 32($t1)
        move $v0, $t1

        jr $ra