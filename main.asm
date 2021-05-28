.data
    .align 0

    BinNum: .asciiz "1001"
    HexNum: .asciiz "6AAA32BA"
    
    HexMsgErroDigitoInvalido: .asciiz "Seu hexadecimal possui um ou mais digito(s) invalido(s).\n"
    BinMsgErroDigitoInvalido: .asciiz "Seu binário possui um ou mais digito(s) invalido(s).\n"
    MsgErroOverflow: .asciiz "O número digitado é grande demais (o número deve estar entre 0 e 2^32-1), ou você não digitou nada.\n"
    MsgResultadoBin: .asciiz "Seu número em binário é:\n"
    MsgResultadoHex: .asciiz "Seu número em hexadecimal é:\n"
    MsgResultadoDec: .asciiz "Seu número em decimal é:\n"
    
    QuebraDeLinha: .asciiz "\n"

.text
    .globl Main

Main:
	# TODO: Quando o numero fica muito grande, a conversão dec to hex para de funcionar. Acho que é algo relacionado a overflow
	# TODO: Verificar se no binario de entrada so tem 0 e 1 (e nao 3 por exemplo), e mostrar mensagem BinMsgErroDigitoInvalido
	# TODO: Pedir os valores para o usuario, em vez usar BinNum e HexNum
	# TODO: Mensagens pedindo pro usuario a entrada dele, e mensagens deixando claro o que a saida representa

	testeConversaoHexadecimal:
		# O hexadecimal maximo permitido e FFFFFFFF (2^32-1)
		
		la $s0, HexNum      # salva endereço do número em s0
    	move $a0, $s0       # endereco como parametro
    	jal TamanhoString   # pega o tamanho da string digitada

    	move $s1, $v0       # salva tamanho da string em s1

    	move $a0, $s0
    	move $a1, $s1
    	li $a2, 8
    	jal VerificaEntrada # funÃ§Ã£o que recebe numero, tamanho da str e tamanho permitido, retornando 1 caso valido e 0 caso nao
    	
    	move $a0, $s0
    	move $a1, $s1
    	jal ConverteHexToDec  # funcao que converte string binaria em um decimal

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
	    la $s0, BinNum      # salva endereço do número em s0
    	move $a0, $s0       # endereco como parametro
    	jal TamanhoString   # pega o tamanho da string digitada

    	move $s1, $v0       # salva tamanho da string em s1

    	move $a0, $s0
    	move $a1, $s1
    	li $a2, 32
    	jal VerificaEntrada # função que recebe numero, tamanho da str e tamanho permitido, retornando 1 caso valido e 0 caso nao

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
    	
    	
    	# agora, converte decimal para uma string de um binário
    	
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
# v0 = inteiro unsigned, resultado da conversÃ£o
ConverteDecToHex:
	move $t0, $a0   # guarda valor decimal em t0

    li $v0, 9
    li $a0, 9       # aloca string de 9 bytes
    syscall

    move $t1, $v0     # salva em t1 o endereco da string alocada    
    
    move $t2, $t1     # salva em t2 a posicao atual na string (comeca no fim)
    add  $t2, $t2, 7  # posiciona ponteiro da string no fim dela

	sb $zero, 1($t2)  # insere \0 no fim da string

	li $t3, 16      # t3 é a base (fixo em 16)
	li $t4, 10      # t4 é fixo em 10
	
	decToHexInicioDoLoop:
		blt  $t2, $t1, decToHexRetornar
	
		div  $t0, $t3 # t0 / 16: calcula o resto e o quociente
		mfhi $t5 	 # resto é movido para $t5
		mflo $t0 	 # quociente é movido para $t0

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

# a0 = endereÃ§o da string
# a1 = tamanho da string
# v0 = inteiro unsigned, resultado da conversÃ£o
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
		
		lb $t2, ($t0) # t2 é o char atual na string
	
		move $a0, $t2 				   # passa o char atual para a funcao
		jal HexConverteLetraParaNumero # converte em numero
		move $t4, $v0 				   # t4 é o char convertido em decimal
		
		mul $t4, $t4, $t7 # t4 *= 16^i
		mul $t7, $t7, $t8 # t7 *= 16
		
		add $t6, $t6, $t4 # adiciona ao resultado o t4
		
		addi $t0, $t0, -1 # incrementa um no endereço
		
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
    move $t0, $a0   # endereço da string
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
        
        sb $t5, 0($t1)       # salva '0' na posição atual
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
	move $t0, $a0	# copia endereço da string para t0
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
	

# a0 = endereço da string
# a1 = tamanho da string
# a2 = tamanho maximo permitido da string
# v0 = 0 se invalido e 1 se valido
VerificaEntrada:
    li  $t8, '0'
    move $t0, $a0       # salva endereço da string em t0
    move $t1, $a1       # salva tamanho da string em t1
    move $t2, $a2       # salva tamanho maximo permitido em t2

	ble $t1, $zero, fimNPermitido # caso o tamanho seja <= 0
    ble $t1, $t2, fimPermitido    # caso o tamanho seja menor ou igual ao valor permitido

    # caso string seja maior que o valor permitido, entra aqui

    move $t3, $t1       # salva contador de bit mais significativo atual

    loopVerificaChar:
        beq $t3, $t2, fimPermitido   # se o contador for igual a 32, sai do loop 

        lb  $t4, 0($t0) # salva caractere atual em t4
        
        bne $t4, $t8, fimNPermitido  # se o caractere não for '0', sai do loop

        addi $t3, $t3, -1
        addi $t0, $t0, 1
        j loopVerificaChar 

    fimPermitido:
        li $v0, 1       # 1 significa valor permitido
        jr $ra

    fimNPermitido:
        li $v0, 0       # 0 significa valor não permitido
        
        li $v0, 4
        la $a0, MsgErroOverflow
        syscall
        
        li $v0, 10
        syscall
