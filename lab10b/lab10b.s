.text
.globl gets, puts, itoa, atoi, recursive_tree_search, exit

# gets
#
# Recebe uma em string do stdin e retorna o que foi recebido
#
# param: a0 - (const char*) buffer
# return: a0 - (char*) str
gets:
	addi sp, sp, -4
	sw a0, 0(sp) 	    	# salva o valor de a0 para adquirir e retornar
	
	mv a1, a0
	
	1:
		li a0, 0          	# file descriptor = 0 (stdin)
		li a2, 1            # size
		li a7, 63           # syscall read (63)
		ecall
		
		lb t0, 0(a1)
		li t1, '\n'
		beq t0, t1, 2f
		addi a1, a1, 1
		j 1b
	2:

    li t0, 0
    sb t0, 0(a1)
	
	lw a0, 0(sp) 	    	# recupera o valor de a0 (endereço do buffer)
	addi sp, sp, 4
ret

# puts
#
# Recebe uma em string e a printa
#
# param: a0 - (const char*) str
# return: -
puts:
	mv a1, a0               # copia o endereço de a0 para a1
	li a2, 0
	1:
		lb t0, 0(a0)
		beqz t0, 2f         # se t0 = '\0', finaliza
		addi a2, a2, 1      # contador (tamanho)
		addi a0, a0, 1      # caminha pela string
		j 1b
	2:

    li t0, '\n'
    sb t0, 0(a0)
    addi a2, a2, 1
	
	li a0, 1
	li a7, 64
	ecall
ret

# itoa
#
# Recebe um inteiro e o transforma em string
#
# param: a0 - (int) value; a1 - (char*) str; a2 - (int) base
# return: a0 - (char*) str
itoa:
	li a3, 0
	bgez a0, 1f
		li t0, -1
		li a3, 1
		mul a0, a0, t0      # a0 <-- |a0|
	1:
	
    addi a1, a1, 31         # vai até o final da string (possui no máximo 32 dígitos)
	li t0, 0
	1:
		rem t1, a0, a2
		div a0, a0, a2
		li t2, 10
		bge t1, t2, 2f      # se t1 >= 10, converte para [a, b, c, ...], senão, converte para [0, 1, 2, ...]
			addi t1, t1, '0'
			j 3f
		2:
			addi t1, t1, -10
			addi t1, t1, 'A'
		3:
		sb t1, 0(a1)
		addi a1, a1, -1
		addi t0, t0, 1
		bnez a0, 1b
	
	mv a0, a1
	beqz a3, 1f
		li t0, '-'
		sb t0, 0(a0)
        j 2f
	1:
        addi a0, a0, 1
    2:

ret

# atoi
#
# Recebe uma em string e a transfora em inteiro
#
# param: a0 - (const char*) str
# return: a0 - (int) value
atoi:	
	li t0, ' '				# carrega o char espaço para pular se houver na string
	1:
		lb a1, 0(a0)
		bne a1, t0, 2f
		addi a0, a0, 1
		j 1b
	2:

	lb a1, 0(a0)
	li a2, 1

	li t0, '-'
	bgt a1, t0, 1f          # se o primeiro char for '+' ou '-' salva o multiplicador 1 ou -1
		bne a1, t0, 2f
			li a2, -1
		2:
		addi a0, a0, 1
	1:
	mv a1, a2
	
	li a2, 0
	1:
		lb t0, 0(a0)
		beqz t0, 2f         # caminha na string até 0 '\0'
		li t1, 10
		mul a2, a2, t1
		addi t0, t0, -'0'
		add a2, a2, t0
        addi a0, a0, 1
		j 1b
	2:
	mul a0, a2, a1
ret

# recursive_tree_search
#
# Recebe um valor e o procura em uma árvore, retorna a profundidade encontrada ou 0
#
# param: a0 - (Node *) root_node; a1 - (int) val
# return: a0 - (int) depth
recursive_tree_search:
	addi sp, sp, -16
	sw s0, 12(sp)
	sw ra, 8(sp)
	sw a0, 4(sp)

    li s0, 0                # indice do andar atual

    recursive:
        addi s0, s0, 1

        addi sp, sp, -16

        sw ra, 4(sp)
        sw a0, 0(sp)

        lw a2, 0(a0)
        lw a3, 4(a0)
        lw a4, 8(a0)

        beq a1, a2, there_is

			left_node:

            beqz a3, right_node
                mv a0, a3
                jal recursive       # recursão no braço esquerdo

            right_node:

            beqz a4, finish
                mv a0, a4
                jal recursive       # recursão no braço direito

            finish:

            lw ra, 4(sp)
            lw a0, 16(sp)           # endereço do nó pai

            lw a3, 4(a0)            # endereço do nó da esquerda do pai
            lw a4, 8(a0)            # endereço do nó da direita do pai

            addi sp, sp, 16
            addi s0, s0, -1         # volta na profundidade
            ret

        there_is:
    
    li t0, 16
    mul t0, s0, t0
    add sp, sp, t0                  # desaloca o espaço dos nós

    mv a0, s0                       # passa a profundidade encontrada para a0

    lw s0, 12(sp)                   # devolve o valor original de s0
    lw ra, 8(sp)                    # puxa da memória o ra original
    addi sp, sp, 16                 # desaloca o espaço inicial do nó
ret

exit:
    li a7, 93
    ecall
