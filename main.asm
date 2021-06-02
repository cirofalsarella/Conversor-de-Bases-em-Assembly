.data
    .align 0

    BinNum: .asciiz "1001"
    HexNum: .asciiz "FFFFFFFF"
    
    HexMsgErroDigitoInvalido: .asciiz "Seu hexadecimal possui um ou mais digito(s) invalido(s).\n"
    BinMsgErroDigitoInvalido: .asciiz "Seu bin�rio possui um ou mais digito(s) invalido(s).\n"
    MsgErroOverflow: .asciiz "O n�mero digitado � grande demais (o n�mero deve estar entre 0 e 2^32-1), ou voc� n�o digitou nada.\n"
    MsgResultadoBin: .asciiz "Seu n�mero em bin�rio �:\n"
    MsgResultadoHex: .asciiz "Seu n�mero em hexadecimal �:\n"
    MsgResultadoDec: .asciiz "Seu n�mero em decimal �:\n"
    
    QuebraDeLinha: .asciiz "\n"

.text
    .globl Main

Main:
	# TODO: Verificar se no binario de entrada so tem 0 e 1 (e nao 3 por exemplo), e mostrar mensagem BinMsgErroDigitoInvalido
	# TODO: Pedir os valores para o usuario, em vez usar BinNum e HexNum
	# TODO: Mensagens pedindo pro usuario a entrada dele, e mensagens deixando claro o que a saida representa

	testeConversaoHexadecimal:
		# O hexadecimal maximo permitido e FFFFFFFF (2^32-1)
		
		la $s0, HexNum      # salva endere�o do n�mero em s0
    	move $a0, $s0       # endereco como parametro
    	jal TamanhoString   # pega o tamanho da string digitada

    	move $s1, $v0       # salva tamanho da string em s1

    	move $a0, $s0
    	move $a1, $s1
    	li $a2, 8
    	jal VerificaEntrada # função que recebe numero, tamanho da str e tamanho permitido, retornando 1 caso valido e 0 caso nao
    	
    	move $a0, $s0
    	move $a1, $s1
    	jal ConverteHexToDec  # funcao que converte string hexadecimal em um decimal

    	move $s2, $v0 # s2 e o resultado em decimal
    	
    	
    	# printa o resultado em decimal
    	
    	jal NovaLinha
    	
		li $v0, 4
    	la $a0, MsgResultadoDec
    	syscall
    	
    	li $v0, 36
    	move $a0, $s2
    	syscall
    	
    	jal NovaLinha
 
 
 		# agora, convertemos de decimal para hexadecimal
    	
		move $a0, $s2
    	jal ConverteDecToHex  # funcao que converte decimal em string de hexadecimal

    	move $s3, $v0 # salva string binaria em s3
    	
    	# printa o resultado em hexadecimal
    	jal NovaLinha
    	
    	li $v0, 4
    	la $a0, MsgResultadoHex
    	syscall
    	
    	li $v0, 4
    	move $a0, $s3
    	syscall
    	
    	jal NovaLinha

	testeConversaoBinario:
	    la $s0, BinNum      # salva endere�o do n�mero em s0
    	move $a0, $s0       # endereco como parametro
    	jal TamanhoString   # pega o tamanho da string digitada

    	move $s1, $v0       # salva tamanho da string em s1

		move $a0, $s0
		loadi $a1, 0
		jal VerificaStringChar	# verifica se string binária é composta apenas por 0 e 1 

    	move $a0, $s0
    	move $a1, $s1
    	li $a2, 32
    	jal VerificaEntrada # fun��o que recebe numero, tamanho da str e tamanho permitido, retornando 1 caso valido e 0 caso nao

    	move $a0, $s0
    	move $a1, $s1
    	jal ConverteBinToDec  # funcao que converte string binaria em um decimal

    	move $s2, $v0 # s2 e o resultado em decimal
    	
    	# printa o resultado em decimal
    	jal NovaLinha
    	
    	li $v0, 4
    	la $a0, MsgResultadoDec
    	syscall
    	
    	li $v0, 36
    	move $a0, $s2
    	syscall
    	
    	jal NovaLinha
    	
    	
    	# agora, converte decimal para uma string de um bin�rio
    	
    	move $a0, $s2
    	jal ConverteDecToBin # funcao que converte inteiro decimal em string do numero em bin

    	move $s3, $v0 # salva string binaria em s3
    	
    	# Printa o resultado
    	jal NovaLinha
    
    	li $v0, 4
    	la $a0, MsgResultadoBin
    	syscall
    
    	li $v0, 4
    	move $a0, $s3
    	syscall
    	
    	jal NovaLinha

	fimProg:
    	li $v0, 10
    	syscall     # finaliza programa




#########################
# HEXADECIMAL e DECIMAL #
#########################

# a0 = valor decimal
# v0 = inteiro unsigned, resultado da conversão
ConverteDecToHex:
	move $t0, $a0   # guarda valor decimal em t0

    li $v0, 9
    li $a0, 9       # aloca string de 9 bytes
    syscall

    move $t1, $v0     # salva em t1 o endereco da string alocada    
    
    move $t2, $t1     # salva em t2 a posicao atual na string (comeca no fim)
    add  $t2, $t2, 7  # posiciona ponteiro da string no fim dela

	sb $zero, 1($t2)  # insere \0 no fim da string

	li $t4, 10      # t4 � fixo em 10
	
	decToHexInicioDoLoop:
		blt  $t2, $t1, decToHexRetornar
	
		srl  $t3, $t0, 4 # calcula t3 = t0 / 16
		sll  $t5, $t3, 4 # t5 � o resto
		
		sub  $t5, $t0, $t5
		move $t0, $t3    # quociente � movido para $t0

		blt	 $t5, $t4, restoMenorQue10 # se $t0 < 16 vai para restoMenorQue10
	
		# Se nao, executa restoMaiorOuIgualA10

	restoMaiorOuIgualA10:
		addi $t5, $t5, 'A'
		addi $t5, $t5, -10 # converte decimal em letra
		j decToHexFimloop

	restoMenorQue10:
		addi $t5, $t5, '0' # converte decimal em letra
		j decToHexFimloop
	
	decToHexFimloop:
		sb   $t5, ($t2)   # guarda a letra resultante no ponteiro atual
		addi $t2, $t2, -1 # decrementa um no ponteiro da posicao atual na string
		j decToHexInicioDoLoop
	
	decToHexRetornar:
		move $v0, $t1 # retorna o endereco da string alocada
		jr 	 $ra

# a0 = endereço da string
# a1 = tamanho da string
# v0 = inteiro unsigned, resultado da conversão
ConverteHexToDec:
    move $t0, $a0  # endereco atual na string (muda durante a funcao)
    move $t5, $a0  # endereco inicial da string
    move $t1, $a1  # tamanho da string
	move $t3, $ra  # t3 e para onde teremos que voltar (jmp)
    
    # move t0 para o fim da string
    add $t0, $t0, $t1
    addi $t0, $t0, -1
    
    li $t6, 0  # t6 e o resultado
	li $t7, 1  # t7 e 1, depois 16, depois 16^2, ...
	li $t8, 16 # t8 e a base (16)
	
	loopHexToDec: 
		blt $t0, $t5, fimHexToDec
		
		lb $t2, ($t0) # t2 � o char atual na string
	
		move $a0, $t2 				   # passa o char atual para a funcao
		jal HexConverteLetraParaNumero # converte em numero
		move $t4, $v0 				   # t4 � o char convertido em decimal
		
		mul $t4, $t4, $t7 # t4 *= 16^i
		mul $t7, $t7, $t8 # t7 *= 16
		
		add $t6, $t6, $t4 # adiciona ao resultado o t4
		
		addi $t0, $t0, -1 # incrementa um no endere�o
		
		j loopHexToDec
	fimHexToDec:
		move $v0, $t6
		jr $t3 # retorna
	
# Converte uma letra hexadecimal no seu valor decimal. Esse funcao usa o t9.
# a0 = '0' => v0 = 0,
# a0 = 'A' => v0 = 10
HexConverteLetraParaNumero:
	move $t9, $ra # temos que voltar para o t9

	# Note que a0 ja e D
	# Se '0' <= D <= '9', vai para $a3
	li $a1, '0'
	li $a2, '9'
	la $a3, letraEntre0e9
	jal ChecarSeNumeroEstaNaRange
	
	
	# Se 'A' <= D <= 'F', vai para $a3
	li $a1, 'A'
	li $a2, 'F'
	la $a3, maisculaValida
	jal ChecarSeNumeroEstaNaRange
	
	
	# Se 'a' <= D <= 'f', vai para $a3
	li $a1, 'a'
	li $a2, 'f'
	la $a3, minusculaValida
	jal ChecarSeNumeroEstaNaRange
	
	# Se chegamos aqui, o digito e invalido
	finalizaComErro:
		li $v0, 4
		la $a0, HexMsgErroDigitoInvalido # printa msg de erro
		syscall

		li $v0, 10
   		syscall # finaliza programa
	
	# Caso valido, faz a conversao
	letraEntre0e9:
		subi $a0, $a0, '0'
		move $v0, $a0
		jr $t9
	
	maisculaValida:
		subi $a0, $a0, 'A'
		addi $a0, $a0, 10
		move $v0, $a0
		jr $t9
	
	minusculaValida:
		subi $a0, $a0, 'a'
		addi $a0, $a0, 10
		move $v0, $a0
		jr $t9


# Se a1 <= a0 <= a2, vai para a3. Se nao continua a execucao.
# a0 = numero
# a1 = minimo da range (inclusivo)
# a2 = maximo da range (inclusivo)
# a3 = vai para a3
# v0 = retorno (0 ou 1)
ChecarSeNumeroEstaNaRange:
	# if (a1 <= a0 <= a2)
	blt $a0, $a1, pequenoDemais
	bgt $a0, $a2, grandeDemais
	
	# if true, retorna 1 e vai para a3
	li $v0, 1
	jr $a3
	
	# else, retorna 0 e segue a execucao
	pequenoDemais:
	grandeDemais:
		li $v0, 0
		jr $ra





#######################
# BINARIO e DECIMAL   #
#######################

ConverteBinToDec:
    move $t0, $a0   # endere�o da string
    move $t1, $a1   # tamanho da string

    add $t0, $t0, $t1      # posiciona t0 no final da string (bit menos significativo)
    addi $t0, $t0, -1 # posiciona t0 no final da string (bit menos significativo)


    move $t8, $zero         # valor do numero em binario
    move $t7, $zero
    addi $t7, $t7, 1        # carrega 1 em t7

    li $t6, '0'             # caractere '0'

    li $t5, 2               # base 2

    loopBinDec:
        beq $t1, $zero, fimConverteBinToDec     # caso contador seja zero, fim

        lb $t2, 0($t0)  # carrega byte atual em t2
        beq $t2, $t6, proximoBitBin     # se caractere for '0', nao adiciona

        add $t8, $t8, $t7       # adiciona ao resultado o valor de t7

        proximoBitBin:
            addi $t0, $t0, -1   # aponta para o proximo bit da string
            mul $t7, $t7, $t5   # multiplica t7 por 2
            addi $t1, $t1, -1   # decrementa contador/tamanho da string
            j loopBinDec

    fimConverteBinToDec:
        move $v0, $t8
        jr $ra

# a0 = Valor decimal
ConverteDecToBin:
    move $t0, $a0   # guarda valor decimal em t0

    li $v0, 9
    li $a0, 33      # aloca string de 33 bytes
    syscall

    move $t1, $v0   # salva string em t1

    li $t2, 31      # salva contador de loop em t2

    add $t1, $t1, $t2   # posiciona ponteiro da string no bit menos significativo do numero binario

    li $t3, 2         # base 2

    li $t4, '1'       # valor '1'
    li $t5, '0'       # valor '0'


    loopDecToBin:
        blt $t2, $zero, fimDecToBin     # contador menor que 0, fim do algoritmo

        div $t0, $t3        # divide numero pela base
        
        mfhi $t6            # recuperando resto
        mflo $t7            # recuperando quociente

        move $t0, $t7       # salva resultado

        bne $t6, $zero, coloca1     # verifica valor do resto
        
        sb $t5, 0($t1)       # salva '0' na posi��o atual
        j decrementaPonteiro
        
        coloca1:
            sb $t4, 0($t1)    # salva '1' na posicao atual

        decrementaPonteiro:
            addi $t1, $t1, -1
            addi $t2, $t2, -1
            j loopDecToBin

    fimDecToBin:
        addi $t1, $t1, 1
        sb $zero, 32($t1)
        move $v0, $t1

        jr $ra



##############
# UTILIDADES #
##############

NovaLinha:
	li $v0, 4
   	la $a0, QuebraDeLinha
    syscall
    jr $ra

TamanhoString:
	move $t0, $a0	# copia endere�o da string para t0
	li $t1, 0	# valor inicial do tamanho da string
	lb $t2, 0($t0)	# primeira letra da string
	
	loop:
		beq $t2, $zero, fim
	
		addi $t1, $t1, 1
		addi $t0, $t0, 1
		lb $t2, 0($t0)
		j loop
	
	fim:
		move $v0, $t1
		jr $ra


VerificaStringChar:	
	move $t0, $a0	# guarda ponteiro da string
	move $t5, $a1	# parametro que guarda se a verificação é decimal ou binaria
					# 0: binario	1: decimal 

	loadi $t3, '\0'	# critério de parada

	LoopVerificaChar:
		loadb $t4, 0($t0)

		beq $t4, $zero, StringValida	# verifica se chegou ao final da string

		loadi $t1, '0'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é '0'

		loadi $t1, '1'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''1'

		beq $t5, $zero, valorInvalidoChar	# caso a verificação seja binaria, vem ate aqui

		loadi $t1, '2'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''2'

		loadi $t1, '3'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''3'

		loadi $t1, '4'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''4'

		loadi $t1, '5'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''5'

		loadi $t1, '6'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''6'

		loadi $t1, '7'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''7'

		loadi $t1, '8'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''8'

		loadi $t1, '9'
		beq $t4, $t1, valorValidoChar	# verifica se t4 é ''9'

		j valorInvalidoChar	# t4 possui um valor invalido 


		valorValidoChar:
			addi $t0, $t0, 1
			j LoopVerificaHexDec

		valorInvalidoChar:
			loadi $v0, 0	# código de retorno para string inválida
			jr $ra

	StringValida:
		loadi $v0, 1
		jr $ra

# a0 = endere�o da string
# a1 = tamanho da string
# a2 = tamanho maximo permitido da string
# v0 = 0 se invalido e 1 se valido
VerificaEntrada:
    li  $t8, '0'
    move $t0, $a0       # salva endere�o da string em t0
    move $t1, $a1       # salva tamanho da string em t1
    move $t2, $a2       # salva tamanho maximo permitido em t2

	ble $t1, $zero, fimNPermitido # caso o tamanho seja <= 0
    ble $t1, $t2, fimPermitido    # caso o tamanho seja menor ou igual ao valor permitido

    # caso string seja maior que o valor permitido, entra aqui

    move $t3, $t1       # salva contador de bit mais significativo atual

    loopVerificaChar:
        beq $t3, $t2, fimPermitido   # se o contador for igual a t2, sai do loop 

        lb  $t4, 0($t0) # salva caractere atual em t4
        
        bne $t4, $t8, fimNPermitido  # se o caractere n�o for '0', sai do loop

        addi $t3, $t3, -1
        addi $t0, $t0, 1
        j loopVerificaChar 

    fimPermitido:
        li $v0, 1       # 1 significa valor permitido
        jr $ra

    fimNPermitido:
        li $v0, 0       # 0 significa valor n�o permitido
        
        li $v0, 4
        la $a0, MsgErroOverflow
        syscall
        
        li $v0, 10
        syscall
