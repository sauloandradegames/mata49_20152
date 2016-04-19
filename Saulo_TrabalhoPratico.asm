; UNIVERSIDADE FEDERAL DA BAHIA
; MATA49-PROGRAMACAO DE SOFTWARE BASICO
; PROFESSOR: ALBERTO VIANNA
; ALUNO: SAULO RIBEIRO DE ANDRADE

; TRABALHO PRATICO 2015.2
; Rodar com make
; ./Saulo_TrabalhoPratico

%include "asm_io.inc"

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
	
	indice       DD 0 ; Armazena indice do vetor

	testificate  DD 220 ;1 2 3 4 6 12 = 28
	testificate2 DD 284 ;1 2 4 7 14 28 = 56
	testificate3 DD 10
	;12 excessivo
	;28 perfeito
	;10 deficiente
	
segment .bss
	vetor_entrada           RESD 10
	vetor_soma_divisores    RESD 10
	
	vetor_primos            RESD 100
	vetor_divisores         RESD 100
	vetor_candidatos        RESD 100 ; armazena candidatos a numeros amigaveis ou sociaveis
	
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
	
check_excessivo:
	MOV EAX, 10011
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_perfeito:
	MOV EAX, 20022
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_deficiente:
	MOV EAX, 30033
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_amigavel:
	MOV EAX, 40044
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_sociavel:
	MOV EAX, 50055
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_primo:
	MOV EAX, 60066
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_fibonacci:
	MOV EAX, 70077
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
check_fatorial:
	MOV EAX, 80088
	CALL print_int
	CALL print_nl
	JMP imprime_menu
	
end:
	LEAVE
	RET
