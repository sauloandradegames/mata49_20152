; UNIVERSIDADE FEDERAL DA BAHIA
; MATA49-PROGRAMACAO DE SOFTWARE BASICO
; PROFESSOR: ALBERTO VIANNA
; ALUNO: SAULO RIBEIRO DE ANDRADE

; TRABALHO PRATICO 2015.2
; Rodar com make
; ./Saulo_TrabalhoPratico

%include "asm_io.inc"

; colocar anotacao para alberto: representacao de fibonacci ate o ultimo elemento da sequencia menor que a entrada
; fatorial: dw suporta fatorial ate 12. 13 gera overflow. msg de erro caso entrada maior do que isso

segment .data
	text_prompt1     DB ">> Insira 10 numeros.", 0
	
	text_menu_titulo DB ">> Selecione uma funcao", 0
	text_menu_opcao1 DB "[1] Numeros excessivos", 0
	text_menu_opcao2 DB "[2] Numeros perfeitos", 0
	text_menu_opcao3 DB "[3] Numeros deficientes", 0
	text_menu_opcao4 DB "[4] Numeros amigaveis", 0
	text_menu_opcao5 DB "[5] Numeros sociaveis", 0
	text_menu_opcao6 DB "[6] Numeros primos", 0
	text_menu_opcao7 DB "[7] Sequencia de fibonacci", 0
	text_menu_opcao8 DB "[8] Fatorial", 0
	text_menu_opcao9 DB "[9] Sair", 0
	
	text_res_excessivo   DB ">> Numeros Excessivos : ", 0
	text_res_perfeito    DB ">> Numeros Perfeitos  : ", 0
	text_res_deficiente  DB ">> Numeros Deficientes: ", 0
	text_res_amigavel    DB ">> Pares de numeros amigaveis: ", 0
	text_res_sociavel    DB ">> Ciclos de numeros sociaveis: ", 0
	text_res_primo       DB ">> Numeros Primos     : ", 0
	text_res_fibonacci   DB ">> Fibonacci", 0
	text_res_fatorial    DB ">> Fatorial", 0
	
	colchete_abre  DB "[ ", 0
	colchete_fecha DB " ]", 0
	nulo           DB "---", 0
	espaco         DB " , ", 0
	igual          DB " = ", 0
	
	indice       DD 0 ; Armazena indice do vetor
	indice2      DD 0 ; Armazena indice do vetor
	
	vetor_entrada TIMES 10 DD -1
	vetor_soma_divisores TIMES 10 DD -1

	testificate  DD 220 ;1 2 3 4 6 12 = 28
	testificate2 DD 284 ;1 2 4 7 14 28 = 56
	testificate3 DD 10
	;12 excessivo
	;28 perfeito
	;10 deficiente
	;12496, 14288, 15472, 14536 e 14264 formam um ciclo sociavel
	
segment .bss
	
	vetor_primos            RESD 100
	vetor_divisores         RESD 100
	vetor_candidatos        RESD 100 ; armazena candidatos a numeros amigaveis ou sociaveis
	
	vetor_emCiclo           RESD 10  ; indica se a entrada da posicao i ja se encontra em algum ciclo
	
	inicio_ciclo            RESD 1   ; armazena valor que comeca ciclo sociavel
	param_crivo             RESD 1
	param_divisor           RESD 1
	param_soma              RESD 1
	divisor_param1          RESD 1   ; armazena soma dos divisores do 1o parametro de amigavel()
	divisor_param2          RESD 1   ; armazena soma dos divisores do 2o parametro de amigavel()
	contador                RESD 1   ; armazena valor de ECX durante loop calcula_divisores

segment .text
	GLOBAL asm_main
	
;=======================================================================
;========================= PROCEDIMENTOS      ==========================
;=======================================================================

;-----------------------------------------------------------------------
; indica se o parametro de entrada eh um numero excessivo
; (soma dos divisores > entrada)
; entrada:
;    1 valor na pilha
; saida:
;    EAX = 0, se o numero nao eh excessivo
;    EAX = 1, se o numero eh excessivo
excessivo:
	ENTER 4, 0
	
	MOV EBX, [EBP + 8]
	CALL soma_divisores
	
	CMP EAX, [EBP + 8]
	JG eh_excessivo
	JMP nao_excessivo
	
eh_excessivo:
	MOV EAX, 1
	JMP end

nao_excessivo:
	MOV EAX, 0
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; indica se o parametro de entrada eh um numero perfeito
; (soma dos divisores = entrada)
; entrada:
;    1 valor na pilha
; saida:
;    EAX = 0, se o numero nao eh perfeito
;    EAX = 1, se o numero eh perfeito
perfeito:
	ENTER 4, 0
	
	MOV EBX, [EBP + 8]
	CALL soma_divisores
	
	CMP EAX, [EBP + 8]
	JZ eh_perfeito
	JMP nao_perfeito
	
eh_perfeito:
	MOV EAX, 1
	JMP end

nao_perfeito:
	MOV EAX, 0
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; indica se o parametro de entrada eh um numero deficiente
; (soma dos divisores < entrada)
; entrada:
;    1 valor na pilha
; saida:
;    EAX = 0, se o numero nao eh deficiente
;    EAX = 1, se o numero eh deficiente
deficiente:
	ENTER 4, 0
	
	MOV EBX, [EBP + 8]
	CALL soma_divisores
	
	CMP EAX, [EBP + 8]
	JL eh_deficiente
	JMP nao_deficiente
	
eh_deficiente:
	MOV EAX, 1
	JMP end

nao_deficiente:
	MOV EAX, 0
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; indica se dois argumentos de entrada sao amigaveis
; (soma dos divisores de n1 = n2) &&
; (soma dos divisores de n2 = n1)
; entrada:
;    2 valores na pilha
; saida:
;    EAX = 0, se os numeros nao sao amigaveis
;    EAX = 1, se os numeros sao amigaveis
amigavel:
	ENTER 8, 0
	
	MOV EBX, [EBP + 12]
	CALL soma_divisores
	MOV [divisor_param1], EAX
	
	MOV EBX, [EBP + 8]
	CALL soma_divisores
	MOV [divisor_param2], EAX
	
	MOV EBX, [EBP + 12]
	CMP EBX, [divisor_param2]
	JNZ nao_amigavel
	MOV EBX, [EBP + 8]
	CMP EBX, [divisor_param1]
	JNZ nao_amigavel
	JMP eh_amigavel
	
nao_amigavel:
	MOV EAX, 0
	JMP end
	
eh_amigavel:
	MOV EAX, 1
	JMP end
	
;[ebp + 12]\/[vsd + 4] [220] (220)
;[ebp +  8]/\[vsd + 0] (284) [284]
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; retorna a soma dos divisores do argumento de entrada
; entrada:
;    1 valor em EBX
; saida:
;    EAX = soma dos divisores de EBX
soma_divisores:
	ENTER 0, 0
	
	MOV [param_soma], EBX
	
	CALL divisor
	
	MOV ESI, vetor_divisores
	MOV EBX, 0
	
somatorio:
	LODSD
	CMP EAX, [param_soma]
	JZ encerra_somatorio
	ADD EBX, EAX
	JMP somatorio
	
encerra_somatorio:
	XCHG EBX, EAX
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; retorna os divisores do argumento de entrada
; entrada:
;    1 valor em EBX
; saida:
;    vetor_divisores = lista dos divisores de EBX
divisor:
	ENTER 0, 0
	
	MOV [param_divisor], EBX
	MOV EAX, EBX
	MOV ECX, EBX
	MOV EDI, vetor_divisores
	
	;eax: dividendo / quociente
	;ecx: divisor
teste_divisao:
	MOV EAX, [param_divisor]
	MOV EDX, 0
	CDQ
	IDIV ECX
	CMP EDX, 0
	JZ adiciona_divisor
	LOOP teste_divisao
	JMP end
	
adiciona_divisor:
	STOSD
	LOOP teste_divisao
	JMP end

;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; retorna todos os numeros primos entre 0 e o argumento de entrada
; entrada:
;    1 valor em EBX
; saida:
;    vetor_primos = numeros primos entre 0 e EBX
crivo:
	ENTER 0, 0
	
	MOV EDI, vetor_primos
	MOV ECX, 0

teste_crivo:
	MOV [param_crivo], EBX
	PUSH EBX
	CALL primo
	
	MOV EBX, [param_crivo]
	CMP EAX, 0
	JZ proximo
	MOV EAX, EBX
	STOSD
	INC ECX

proximo:
	DEC EBX
	CMP EBX, 1
	JZ end
	JMP teste_crivo
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; indica se o parametro de entrada eh um numero primo
; entrada:
;    1 valor na pilha
; saida:
;    EAX = 0, se o numero nao eh primo
;    EAX = 1, se o numero eh primo
primo:
	ENTER 4, 0
	
	MOV EAX, [EBP + 8]
	MOV EBX, 2
	
teste_primo:
	CMP EAX, 0
	JZ nao_primo
	CMP EAX, 1
	JZ nao_primo
	CMP EAX, EBX
	JZ eh_primo
	
	MOV EDX, 0
	CDQ
	IDIV EBX
	CMP EDX, 0
	JZ nao_primo
	
	MOV EAX, [EBP + 8]
	INC EBX
	JMP teste_primo
	
nao_primo:
	MOV EAX, 0
	JMP end
	
eh_primo:
	MOV EAX, 1
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; imprime na tela a sequencia de fibonacci para o parametro de entrada
; entrada:
;    1 valor na pilha
; saida:
;    padrao: sequencia de fibonacci ate o parametro de entrada
fibonacci:
	ENTER 4, 0
	
	MOV EAX, [EBP + 8]
	CMP EAX, 0
	JZ end
	
	MOV EBX, 1 ; numero atual
	MOV ECX, 0 ; numero anterior
	MOV EDX, 0 ; numero anterior do anterior
	
	MOV EAX, [EBP + 8]
	CMP EAX, 0
	JZ end

insere_fibonacci:
	MOV EAX, EBX
	CALL print_int

	MOV EDX, ECX
	MOV ECX, EBX
	
	MOV EBX, 0
	ADD EBX, ECX
	ADD EBX, EDX
	CMP EBX, [EBP + 8]
	JG end

	MOV EAX, espaco
	CALL print_string
	
	JMP insere_fibonacci
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; retorna o fatorial do parametro de entrada
; entrada:
;    1 valor na pilha
; saida:
;    EAX = fatorial do parametro de entrada
fatorial:
	ENTER 4, 0
	
	MOV EAX, [EBP + 8]
	CMP EAX, 0
	JZ fat_zero
	CMP EAX, 1
	JZ fat_zero
	
	MOV EAX, 1
	MOV ECX, [EBP + 8]
fat_lp:
	IMUL EAX, ECX
	LOOP fat_lp
	JMP end
	
fat_zero:
	MOV EAX, 1
	JMP end
	
	CALL print_int
	CALL print_nl
	
	JMP end
;-----------------------------------------------------------------------

;=======================================================================
;========================= PROGRAMA PRINCIPAL ==========================
;=======================================================================
	
asm_main:
	; inicializacao
	ENTER 0, 0
	PUSHA
	
	;prompt, insira 10 numeros
	MOV EAX, text_prompt1
	CALL print_string
	CALL print_nl
	
	MOV EDI, vetor_entrada
	MOV ECX, 10
	
	;insira 10 numeros
ler_numeros:
	CALL read_int
	STOSD
	LOOP ler_numeros
	
	MOV ECX, 10
	CALL print_nl
	
	;calcule para cada numero a soma de seus divisores
calcula_divisores:
	MOV [contador], ECX
	MOV EDX, [indice]
	
	MOV EBX, [vetor_entrada + EDX]
	
	CALL soma_divisores

	MOV EDX, [indice]
	MOV [vetor_soma_divisores + EDX], EAX
	
	ADD EDX, 4
	MOV [indice], EDX
	MOV ECX, [contador]
	LOOP calcula_divisores
	
	;inicializa vetor emCiclo, para registrar elementos que ja pertencem a algum ciclo sociavel

inicializa_emCiclo:
	MOV EDI, vetor_emCiclo
	MOV EAX, 0
	MOV ECX, 10
	REP STOSD
	
;;;
	MOV EBX, 0
debug1:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EBX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	ADD EBX, 4
	CMP EBX, 40
	JL debug1
	CALL print_nl
	MOV EBX, 0
debug2:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_soma_divisores + EBX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	ADD EBX, 4
	CMP EBX, 40
	JL debug2
	CALL print_nl
;;;
	
	;entre no menu
imprime_menu:
	MOV EAX, text_menu_titulo
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao1
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao2
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao3
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao4
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao5
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao6
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao7
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao8
	CALL print_string
	CALL print_nl
	
	MOV EAX, text_menu_opcao9
	CALL print_string
	CALL print_nl

menu:
	CALL read_int
	CMP EAX, 1
	JZ check_excessivo
	CMP EAX, 2
	JZ check_perfeito
	CMP EAX, 3
	JZ check_deficiente
	CMP EAX, 4
	JZ check_amigavel
	CMP EAX, 5
	JZ check_sociavel
	CMP EAX, 6
	JZ check_primo
	CMP EAX, 7
	JZ check_fibonacci
	CMP EAX, 8
	JZ check_fatorial
	JMP end
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_excessivo:
	MOV EAX, text_res_excessivo
	CALL print_string
	
	MOV ECX, 10
	MOV EDX, 0 ;indice para entrada e soma
	
lp_excessivo:
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JG insere_excessivo
	
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_excessivo
	
	JMP voltar_menu
	
insere_excessivo:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_excessivo
	JMP voltar_menu

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_perfeito:
	MOV EAX, text_res_perfeito
	CALL print_string
	
	MOV ECX, 10
	MOV EDX, 0 ;indice para entrada e soma
	
lp_perfeito:
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JZ insere_perfeito
	
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_perfeito
	
	JMP voltar_menu
	
insere_perfeito:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_perfeito
	JMP voltar_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_deficiente:
	MOV EAX, text_res_deficiente
	CALL print_string
	
	MOV ECX, 10
	MOV EDX, 0 ;indice para entrada e soma
	
lp_deficiente:
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JL insere_deficiente
	
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_deficiente
	
	JMP voltar_menu
	
insere_deficiente:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD EDX, 4
	LOOP lp_deficiente
	JMP voltar_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_amigavel:
	; EAX = soma_divisores[A]
	; EBX = soma_divisores[B]
	MOV EAX, text_res_amigavel
	CALL print_string
	
	MOV ECX, 0 ; Indice para elemento A do vetor_entrada [0~36]
	MOV EDX, 4 ; Indice para elemento B do vetor_entrada [0~36]
	
teste_amigavel:
	MOV EAX, [vetor_soma_divisores + ECX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EAX, [vetor_entrada + EDX]
	JNZ prox
	CMP EBX, [vetor_entrada + ECX]
	JNZ prox
	JMP insere_amigavel
	
prox:
	ADD EDX, 4
	CMP EDX, 40
	JGE reiniciar
	JMP teste_amigavel
	
reiniciar:
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	MOV EDX, ECX
	ADD EDX, 4
	JMP teste_amigavel
	
insere_amigavel:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	MOV EAX, espaco
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	JMP prox
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_sociavel:
	MOV ECX, 0 ;[0~36] navega por vetor_entrada (loop externo)
	MOV EDX, 0 ;[0~36] navega por vetor_entrada (loop interno)
	MOV EBX, 0 ;numero de candidatos
	MOV EDI, vetor_candidatos
	
	MOV EAX, text_res_sociavel
	CALL print_string
	
	MOV EAX, [vetor_entrada + ECX]
	STOSD
	INC EBX
	
	MOV [inicio_ciclo], EAX
	MOV EAX, [vetor_soma_divisores + ECX]
	
busca_sociavel:
	CMP EAX, [vetor_entrada + EDX]
	JZ insere_candidato
	ADD EDX, 4
	CMP EDX, 40
	JGE reiniciar_sociavel
	JMP busca_sociavel
	
insere_candidato:
	MOV EAX, [vetor_entrada + EDX]
	CMP EAX, [inicio_ciclo]
	JZ encerra_busca_sociavel
	STOSD
	INC EBX
	MOV [vetor_emCiclo + EDX], EAX
	MOV EAX, [vetor_soma_divisores + EDX]
	MOV EDX, 0
	JMP busca_sociavel
	
encerra_busca_sociavel:
	CMP EBX, 3
	JL reiniciar_sociavel
	

	MOV EAX, colchete_abre
	CALL print_string
	
	MOV ESI, vetor_candidatos
	XCHG ECX, EBX

insere_sociavel:
	LODSD
	CALL print_int
	CMP ECX, 1
	JZ fim_insere_sociavel
	MOV EAX, espaco
	CALL print_string
	LOOP insere_sociavel
fim_insere_sociavel:
	MOV EAX, colchete_fecha
	CALL print_string
	XCHG ECX, EBX
	JMP reiniciar_sociavel
	
reiniciar_sociavel:
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	MOV EDX, 0
	MOV EBX, 0
	MOV EDI, vetor_candidatos
	MOV EAX, [vetor_entrada + ECX]
	STOSD
	INC EBX
	MOV [inicio_ciclo], EAX
	MOV EAX, [vetor_soma_divisores + ECX]
	JMP busca_sociavel
	
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_primo:
	MOV ECX, 0 ; ECX = 0~36
	MOV EAX, text_res_primo
	CALL print_string

primo_lp:
	MOV EAX, [vetor_entrada + ECX]
	PUSH EAX
	CALL primo
	
	CMP EAX, 1
	JZ insere_primo
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP primo_lp
	
insere_primo:
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP primo_lp
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_fibonacci:
	MOV ECX, 0 ; indice
	
check_fibo_lp:
	MOV EAX, text_res_fibonacci
	CALL print_string
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	PUSH EAX
	MOV EAX, colchete_fecha
	CALL print_string
	MOV EAX, igual
	CALL print_string
	MOV [indice], ECX
	CALL fibonacci
	
	CALL print_nl
	MOV ECX, [indice]
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP check_fibo_lp
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_fatorial:
	MOV ECX, 0 ; indice
	
check_fat_lp:
	MOV EAX, text_res_fatorial
	CALL print_string
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	PUSH EAX
	MOV EAX, colchete_fecha
	CALL print_string
	MOV EAX, igual
	CALL print_string
	MOV [indice], ECX
	CALL fatorial
	
	CALL print_int
	CALL print_nl
	MOV ECX, [indice]
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP check_fat_lp
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
voltar_menu:
	CALL print_nl
	JMP imprime_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
end:
	LEAVE
	RET
