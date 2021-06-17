.data
    .align 0

	MsgInicio:	.asciiz "Bem vindo ao conversor de bases!\nDigite a base origem.\n\tPara binario, digite 'B'.\n\tPara decimal digite 'D'.\n\tPara hexadecimal digite 'H'.\n"
	MsgLeitura:	.asciiz "Digite o valor que sera lido\n"
	MsgMeio:	.asciiz "Digite a base para a qual deseja converter\n"

	MsgErro_BaseInvalida: .asciiz "\nA base nao eh valida, o programa sera encerrado.\n"
	MsgErro_ValorInvalido: .asciiz "\nO digito nao eh valido, o programa sera encerrado.\n"
 	MsgErro_Overflow: .asciiz "O numero digitado eh grande demais (o numero deve estar entre 0 e 2^32-1).\n"

	MsgResultado_Bin: .asciiz "Seu numero em binario eh:\n"
	MsgResultado_Hex: .asciiz "Seu numero em hexadecimal eh:\n"
	MsgResultado_Dec: .asciiz "Seu numero em decimal eh:\n"

	QuebraDeLinha:	.asciiz "\n"

	valorEntrada:	.space 33

	# $s0 -> Base de origem
	# $s1 -> Endereco do valor lido em string
	# $s2 -> Tamanho da string
	# $s3 -> Valor em Decimal
	# $s4 -> Base de destino
	# $s5 -> Endereco do valor na base final em string
#

.text
.globl Main

Main:
	# Salva a string que vai armazenar a entrada do usuario
	la	$s1, valorEntrada

	# Printa a mensagem inicial
	li	$v0, 4
	la	$a0, MsgInicio
	syscall

	# Le e salva a base de origem
	li	$v0, 12
	syscall
	move	$s0, $v0

	# Le o '\n' que sobra
	li 		$v0, 12
	syscall

	# Confere se a base de origem eh valida
	li		$t0 'B'
	beq		$s0, $t0, OrigemBinaria
	li		$t0 'H'
	beq		$s0, $t0, OrigemHexadecimal
	li		$t0 'D'
	beq		$s0, $t0, OrigemDecimal

	j		Erro_BaseInvalida
#
Meio:
	# Menasgem para pessoa digitar base de destino
	li	$v0, 4
	la	$a0, MsgMeio
	syscall

	# Le e salva a base de destino
	li 		$v0, 12
	syscall
	move 	$s4, $v0

	# Le o '\n' que sobra
	li 		$v0, 12
	syscall

	# Confere se a base de origem eh valida
	li		$t0 'B'
	beq		$s4, $t0, DestinoBinario
	li		$t0 'H'
	beq		$s4, $t0, DestinoHexadecimal
	li		$t0 'D'
	beq		$s4, $t0, DestinoDecimal

	j		Erro_BaseInvalida
#
Encerrar:
	li $v0, 10
	syscall     # finaliza programa
#


#	LER INPUT DO USUARIO

OrigemBinaria:
	# Printa a mensagem de valor
	li	$v0, 4
	la	$a0, MsgLeitura
	syscall

	li		$a0, 0		# parâmetro para "confereChar"
	li		$t0, 33		# numero maximo de caracteres
	li		$t1, 0		# numero atual de caracteres
	move	$t2, $s1	# ponteiro para a posicao atual da string

	OrigemBinaria_loop:
		# Le entrada
		li 		$v0, 12
		syscall
		move	$a1, $v0

		# Confere entrada
		jal		ConfereChar

		# Se o char for '\n' termina o loop
		beq		$v0, $zero, OrigemBinaria_loop_fim

		# caso contrario adiciona a string
		sb		$a1, 0 ($t2)
		addi	$t2, $t2, 1

		# condição de parada: i > n
		addi	$t1, $t1, 1
		bgt		$t0, $t1, OrigemBinaria_loop
		j		Erro_OverFlow

		OrigemBinaria_loop_fim:
			# salvo o tamanho da string
			move	$s2, $t1

			# converto em inteiro decimal e salvo
			move	$a0, $s1
			move	$a1, $s2
			jal		ConverteBinToDec
			move	$s3, $v0

			# retorno para o codigo
			j		Meio			
		#
	#
#
OrigemDecimal:
	# Printa a mensagem de valor
	li	$v0, 4
	la	$a0, MsgLeitura
	syscall

	# para o valor de origem em decimal usa-se um metodo diferente
	# vamos apenas ler ele como inteiro e retornar
	li		$v0, 5
	syscall
	move	$s3, $v0
	j		Meio
#
OrigemHexadecimal:
	# Printa a mensagem de valor
	li	$v0, 4
	la	$a0, MsgLeitura
	syscall
	
	li		$a0, 2		# parametro para "confereChar"
	li		$t0, 9		# numero maximo de caracteres
	li		$t1, 0		# numero atual de caracteres
	move	$t2, $s1	# ponteiro para a posicao atual da string

	OrigemHexadecimal_loop:
		# Le entrada
		li 		$v0, 12
		syscall
		move	$a1, $v0

		# Confere entrada
		jal		ConfereChar

		# Se o char for '\n' termina o loop
		beq		$v0, $zero, OrigemHexadecimal_loop_fim

		# caso contrário adiciona a string
		sb		$a1, 0 ($t2)
		addi	$t2, $t2, 1

		# condicao de parada: i > n
		addi	$t1, $t1, 1
		bgt		$t0, $t1, OrigemHexadecimal_loop
		j		Erro_OverFlow

		OrigemHexadecimal_loop_fim:
			# salvo o tamanho da string
			move	$s2, $t1

			# converto em inteiro decimal e salvo
			move	$a0, $s1
			move	$a1, $s2
			jal		ConverteHexToDec
			move	$s3, $v0

			# retorno para o codigo
			j		Meio	
		#
	#
#


#	CONVERTER PARA A BASE DESEJADA

DestinoBinario:
	# Pega a string do valor em binario
	move	$a0, $s3
	jal		ConverteDecToBin
	move	$s5, $v0

	# Imprime o valor
	li 		$v0, 4
	la		$a0, MsgResultado_Bin
	syscall

	move	$a0, $s5
	syscall

	# finaliza
	j		Encerrar
#
DestinoHexadecimal:
	# Pega string com valor em Hexadecimal
	move	$a0, $s3
	jal		ConverteDecToHex
	move	$s5, $v0
	
	# Imprime o valor
	li 		$v0, 4
	la		$a0, MsgResultado_Hex
	syscall

	move	$a0, $s5
	syscall

	# finaliza
	j		Encerrar
#
DestinoDecimal:
	# Imprime o valor
	li 		$v0, 4
	la		$a0, MsgResultado_Dec
	syscall

	li		$v0, 1
	move	$a0, $s3
	syscall

	# finaliza
	j	Encerrar
#


#	POSSIVEIS ERROS

Erro_ValorInvalido:
	li $v0, 4
	la $a0, MsgErro_ValorInvalido
	syscall

	j Encerrar
#
Erro_OverFlow:
	li $v0, 4
	la $a0, MsgErro_Overflow
	syscall

	j Encerrar
#
Erro_BaseInvalida:
	# Se chegou aqui base é invalida
	li $v0, 4
	la $a0, MsgErro_BaseInvalida
	syscall

	j		Encerrar
#



#	FUNCOES AUXILIARES


#	Confere se o caracter faz parte dos algarismos da base desejada
	# @param	$a0 ->	| 0: binaria
	#					| 1: decimal
	#					| 2: hexadecimal
	# @param	$a1 -> caracter
	# @return	$v0	->	| 0: fim de string
	#					| 1: char válido
ConfereChar:
	# confere se eh fim de string
	li		$t3, '\n'
	beq		$a1, $t3, ConfereChar_fim

	# Binario Decimal e Hexadecimal
	li		$t3 '0'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '1'
	beq		$a1, $t3, ConfereChar_valido

	# String binária deve ser 0 ou 1
	li		$t5, 0
	beq 	$a0, $t5, Erro_ValorInvalido

	# Decimal e Hexadecimal
	li		$t3 '2'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '3'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '4'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '5'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '6'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '7'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '8'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '9'
	beq		$a1, $t3, ConfereChar_valido

	# String decimal deve ser de 0 a 9
	li		$t5, 1
	beq 	$a0, $t5, Erro_ValorInvalido
	
	# Hexadecimal
	li		$t3 'A'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 'B'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 'C'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 'D'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 'E'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 'F'
	beq		$a1, $t3, ConfereChar_valido
	li		$t3 '\n'
	beq		$a1, $t3, ConfereChar_valido

	# Confere se eh minusculo e converte pra maiusculo
	li		$t3 'a'
	beq		$a1, $t3, ConfereChar_minusculo
	li		$t3 'b'
	beq		$a1, $t3, ConfereChar_minusculo
	li		$t3 'c'
	beq		$a1, $t3, ConfereChar_minusculo
	li		$t3 'd'
	beq		$a1, $t3, ConfereChar_minusculo
	li		$t3 'e'
	beq		$a1, $t3, ConfereChar_minusculo
	li		$t3 'f'
	beq		$a1, $t3, ConfereChar_minusculo

	# Valor eh invalido
	j		Erro_ValorInvalido

	ConfereChar_minusculo:
		addi	$a1, $a1, -32
	#
	ConfereChar_valido:
		# Se o char eh valido podemos retornar
		li	$v0, 1
		jr	$ra
	#
	ConfereChar_fim:
		# Se o char eh '\n', a string terminou
		li	$v0, 0
		jr	$ra
	#
#


#	Converte um unsigned int 32 bits em uma string hexadecimal
	# @param	$a0 -> valor decimal
	# @return	$v0 -> endereco de uma string hexadecimal
ConverteDecToHex:
	move $t0, $a0   # guarda valor decimal em t0

    li $v0, 9
    li $a0, 9       # aloca string de 9 bytes
    syscall

    move $t1, $v0     # salva em t1 o endereco da string alocada    
    
    move $t2, $t1     # salva em t2 a posicao atual na string (comeca no fim)
    add  $t2, $t2, 7  # posiciona ponteiro da string no fim dela

	sb $zero, 1($t2)  # insere \0 no fim da string

	li $t4, 10      # t4 eh fixo em 10
	
	decToHexInicioDoLoop:
		blt  $t2, $t1, decToHexRetornar
	
		srl  $t3, $t0, 4 # calcula t3 = t0 / 16
		sll  $t5, $t3, 4 # t5 � o resto
		
		sub  $t5, $t0, $t5
		move $t0, $t3    # quociente � movido para $t0

		blt	 $t5, $t4, restoMenorQue10 # se $t0 < 16 vai para restoMenorQue10
	
		# Se nao, executa restoMaiorOuIgualA10
	#

	restoMaiorOuIgualA10:
		addi $t5, $t5, 'A'
		addi $t5, $t5, -10 # converte decimal em letra
		j decToHexFimloop
	#

	restoMenorQue10:
		addi $t5, $t5, '0' # converte decimal em letra
		j decToHexFimloop
	#

	decToHexFimloop:
		sb   $t5, ($t2)   # guarda a letra resultante no ponteiro atual
		addi $t2, $t2, -1 # decrementa um no ponteiro da posicao atual na string
		j decToHexInicioDoLoop
	#

	decToHexRetornar:
		move $v0, $t1 # retorna o endereco da string alocada
		jr 	 $ra
	#
#

#	Converte uma string hexadecimal em um unsigned int
	# @param	$a0 -> endereço da string hex
	# @param	$a1 -> tamanho da string hex
	# @return	$v0 -> resultado da conversão
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
		
		lb $t2, ($t0) # t2 eh o char atual na string
	
		move $a0, $t2 				   # passa o char atual para a funcao
		jal HexConverteLetraParaNumero # converte em numero
		move $t4, $v0 				   # t4 eh o char convertido em decimal
		
		mul $t4, $t4, $t7 # t4 *= 16^i
		mul $t7, $t7, $t8 # t7 *= 16
		
		add $t6, $t6, $t4 # adiciona ao resultado o t4
		
		addi $t0, $t0, -1 # incrementa um no endereco
		
		j loopHexToDec
	#
	
	fimHexToDec:
		move $v0, $t6
		jr $t3 # retorna
	#
#


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
		la $a0, MsgErro_ValorInvalido # printa msg de erro
		syscall

		li $v0, 10
   		syscall # finaliza programa
	#

	# Caso valido, faz a conversao
	letraEntre0e9:
		subi $a0, $a0, '0'
		move $v0, $a0
		jr $t9
	#

	maisculaValida:
		subi $a0, $a0, 'A'
		addi $a0, $a0, 10
		move $v0, $a0
		jr $t9
	#

	minusculaValida:
		subi $a0, $a0, 'a'
		addi $a0, $a0, 10
		move $v0, $a0
		jr $t9
	#
#

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
#


# Converte uma string de valor binario em um inteiro
	# @param	$a0 -> endereco da string
	# @param	$a1 -> tamanho da string
	# @return	$v0 -> valor decimal
ConverteBinToDec:
    move $t0, $a0	# endereco da string
    move $t1, $a1	# tamanho da string

    add $t0, $t0, $t1	# posiciona t0 no final da string (bit menos significativo)
    addi $t0, $t0, -1	# posiciona t0 no final da string (bit menos significativo)


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
		#
	#

    fimConverteBinToDec:
        move $v0, $t8
        jr $ra
	#
#

#	Converte um valor inteiro em uma string binária
	# @param	$a0 -> valor inteiro
	# @return	$v0 -> string binária
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
        
        sb $t5, 0($t1)       # salva '0' na posicao atual
        j decrementaPonteiro
        
        coloca1:
            sb $t4, 0($t1)    # salva '1' na posicao atual
		#

        decrementaPonteiro:
            addi $t1, $t1, -1
            addi $t2, $t2, -1
            j loopDecToBin
		#
	#

    fimDecToBin:
        addi $t1, $t1, 1
        sb $zero, 32($t1)
        move $v0, $t1

        jr $ra
	#
#
