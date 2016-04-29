; UNIVERSIDADE FEDERAL DA BAHIA
; MATA49-PROGRAMACAO DE SOFTWARE BASICO
; PROFESSOR: ALBERTO VIANNA
; ALUNO: SAULO RIBEIRO DE ANDRADE

; TRABALHO PRATICO 2015.2
; Rodar com make
; ./Saulo_TrabalhoPratico

%include "asm_io.inc"

segment .data
	; Mensagens de prompt
	text_prompt1     DB ">> Insira 10 numeros.", 0
	
	; Mensagens de texto do menu inicial
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
	
	; Mensagens de resposta das funcoes
	text_res_excessivo   DB ">> Numeros Excessivos : ", 0
	text_res_perfeito    DB ">> Numeros Perfeitos  : ", 0
	text_res_deficiente  DB ">> Numeros Deficientes: ", 0
	text_res_amigavel    DB ">> Pares de numeros amigaveis: ", 0
	text_res_sociavel    DB ">> Ciclos de numeros sociaveis: ", 0
	text_res_primo       DB ">> Numeros Primos     : ", 0
	text_res_fibonacci   DB ">> Fibonacci", 0
	text_res_fatorial    DB ">> Fatorial", 0
	
	; Mensagens de erro
	text_erro_overflow   DB "Valor grande demais.", 0
	
	; Caracteres especiais
	colchete_abre  DB "[ ", 0
	colchete_fecha DB " ]", 0
	nulo           DB "---", 0
	espaco         DB " , ", 0
	igual          DB " = ", 0
	
	indice       DD 0 ; Armazena indice do vetor
	indice2      DD 0 ; Armazena indice do vetor
	
	vetor_entrada TIMES 10 DD -1         ; Armazena os valores de entrada especificados no inicio do programa
	vetor_soma_divisores TIMES 10 DD -1  ; Armazena a soma dos divisores dos valores de entrada
	
segment .bss
	vetor_primos            RESD 100 ; Armazena os numeros primos de um determinado parametro de entrada
	vetor_divisores         RESD 100 ; Armazena os diviroes de um determinado parametro de entrada
	vetor_candidatos        RESD 100 ; Armazena candidatos a numeros amigaveis ou sociaveis
	
	vetor_emCiclo           RESD 10  ; Indica se a entrada da posicao i ja se encontra em algum ciclo
	
	inicio_ciclo            RESD 1   ; Armazena valor que comeca ciclo sociavel
	param_crivo             RESD 1   ; Armazena o parametro de entrada da funcao crivo()
	param_divisor           RESD 1   ; Armazena o parametro de entrada da funcao divisor()
	param_soma              RESD 1   ; Armazena o parametro de entrada da funcao soma_divisores()
	divisor_param1          RESD 1   ; Armazena a soma dos divisores do 1o parametro de amigavel()
	divisor_param2          RESD 1   ; Armazena a soma dos divisores do 2o parametro de amigavel()
	contador                RESD 1   ; Armazena o valor de ECX durante loop calcula_divisores()

segment .text
	GLOBAL asm_main
	
;=======================================================================
;========================= PROCEDIMENTOS      ==========================
;=======================================================================

;-----------------------------------------------------------------------
; Indica quais numeros do vetor de entrada sao excessivos
; (soma dos divisores > entrada)
; Entrada:
;    vetor_entrada
; Saida:
;    Padrao: imprime vetor de entrada, destacando quais elementos do vetor
;    sao numeros excessivos
excessivo:
	ENTER 0, 0
	
	; Imprime prompt de resposta da funcao
	MOV EAX, text_res_excessivo
	CALL print_string
	
	MOV ECX, 10 ; Inicializa o contador
	MOV EDX, 0  ; Indice para entrada e soma
	
lp_excessivo:
	; Dado indice EDX, verifique se (soma_divisores[EDX] > entrada[EDX])
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JG insere_excessivo
	
	; Se nao for maior, imprima na tela uma string dizendo que entrada[EDX]
	; nao eh um numero excessivo
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice e repita o loop ate varrer todo o vetor
	ADD EDX, 4
	LOOP lp_excessivo
	
	JMP end
	
insere_excessivo:
	; Se for maior, imprima na tela entrada[EDX]
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice e repita o loop ate varrer todo o vetor
	ADD EDX, 4
	LOOP lp_excessivo
	
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; Indica quais elementos do vetor de entrada sao perfeitos
; (soma dos divisores = entrada)
; Entrada:
;    vetor_entrada
; Saida:
;    Padrao: imprime vetor de entrada, destacando quais elementos do vetor
;    sao numeros perfeitos
perfeito:
	ENTER 0, 0
	
	; Imprime prompt de resposta da funcao
	MOV EAX, text_res_perfeito
	CALL print_string
	
	MOV ECX, 10 ; Contador
	MOV EDX, 0  ; Indice para entrada e soma
	
lp_perfeito:
	; Dado indice EDX, verifique se (soma_divisores[EDX] == entrada[EDX])
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JZ insere_perfeito
	
	; Se nao forem iguais, imprima string indicando que entrada[EDX]
	; nao eh numero perfeito
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice, repita o loop ate varrer todo vetor de entrada
	ADD EDX, 4
	LOOP lp_perfeito
	
	JMP end
	
insere_perfeito:
	; Se forem iguais, imprima entrada[EDX]
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice, repita o loop ate varrer todo vetor de entrada
	ADD EDX, 4
	LOOP lp_perfeito
	
	JMP end

;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; Indica quais elementos do vetor de entrada sao numeros deficientes
; (soma dos divisores < entrada)
; Entrada:
;    vetor_entrada
; Saida:
;    Padrao: imprime vetor de entrada, destacando quais elementos
;    sao numeros deficientes
;    EAX = 1, se o numero eh deficiente
deficiente:
	ENTER 0, 0
	
	; Imprime na tela prompt de resposta da funcao
	MOV EAX, text_res_deficiente
	CALL print_string
	
	MOV ECX, 10 ; Contador do loop
	MOV EDX, 0  ; Indice para entrada e soma
	
lp_deficiente:
	; Dado indice EDX, verifique se (soma_divisores[EDX] < entrada[EDX])
	MOV EAX, [vetor_entrada + EDX]
	MOV EBX, [vetor_soma_divisores + EDX]
	
	CMP EBX, EAX
	JL insere_deficiente
	
	; Se nao for menor, imprima string informando que entrada[EDX]
	; nao eh numero deficiente
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice, repita o loop ate varrer todo vetor de entrada
	ADD EDX, 4
	LOOP lp_deficiente
	
	JMP end
	
insere_deficiente:
	; Se for menor, imprima entrada[EDX]
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + EDX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice, repita o loop ate varrer todo vetor de entrada
	ADD EDX, 4
	LOOP lp_deficiente
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; Procura por pares de elementos do vetor de entrada que sejam amigaveis
; (soma dos divisores de n1 = n2) &&
; (soma dos divisores de n2 = n1)
; Entrada:
;    vetor_entrada
; Saida:
;    padrao: imprime na tela os pares de numeros amigaveis que pertencem ao vetor de entrada
amigavel:
	ENTER 0, 0

	; Imprima mensagem de resposta da funcao
	MOV EAX, text_res_amigavel
	CALL print_string
	
	MOV ECX, 0 ; Indice para elemento A do vetor_entrada [0~36]
	MOV EDX, 4 ; Indice para elemento B do vetor_entrada [0~36]
	
teste_amigavel:
	; Usa-se dois indices A e B nesta funcao (representados por ECX e EDX)
	; A eh fixado no comeco do vetor.
	; B eh fixado na posicao seguinte apontada por A.
	; B varre o vetor soma_divisores, procurando por um elemento que seja igual a A.
	; Ao encontrar (entrada[A] == soma_divisores[B])
	; Verifica se (entrada[B] == soma_divisores[A])
	; Se as duas igualdades sao satisfeitas, entao entrada[A] e entrada[B] sao amigaveis.
	
	MOV EAX, [vetor_soma_divisores + ECX] ; EAX = soma_divisores[A]
	MOV EBX, [vetor_soma_divisores + EDX] ; EBX = soma_divisores[B]
	
	CMP EAX, [vetor_entrada + EDX] ; Verifique se soma_divisores[A] == B
	JNZ prox                       ; Se forem diferentes, descarte B
	CMP EBX, [vetor_entrada + ECX] ; Verifique se soma_divisores[B] == A
	JNZ prox                       ; Se forem diferentes, descarte B
	JMP insere_amigavel            ; Se as duas igualdades satisfazerem, A e B sao amigaveis
	
prox:
	; Avance indice B.
	; Se B chegar ao final do vetor, reinicia B e avanca A.
	ADD EDX, 4
	CMP EDX, 40
	JGE reiniciar
	JMP teste_amigavel
	
reiniciar:
	; Avance indice A e reinicia indice B
	; Se A chegar ao final do vetor, encerra a funcao
	ADD ECX, 4
	CMP ECX, 40
	JGE end
	MOV EDX, ECX
	ADD EDX, 4
	JMP teste_amigavel
	
insere_amigavel:
	; Imprima na tela os elementos encontrados que sao amigaveis
	; Avanca indice B
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
; Retorna a soma dos divisores do argumento de entrada
; Entrada:
;    1 valor em EBX
; Saida:
;    EAX = soma dos divisores de EBX
;    EAX = 0 se EBX = 0
soma_divisores:
	ENTER 0, 0
	
	; Verifique se o parametro de entrada eh 0
	; Se sim, a funcao retorna 0
	; Tecnicamente, 0 nao tem divisores e deveria retornar NaN.
	CMP EBX, 0
	JZ encerra_somatorio
	
	; Salva o parametro de entrada
	MOV [param_soma], EBX
	
	; Passa EBX como parametro de entrada da funcao divisor
	; Essa funcao ira calcular os divisores do parametro de entrada
	; e salvara os divisores em um vetor
	CALL divisor
	
	; Preenchido o vetor de divisores, hora de calcular a soma.
	; Mova ESI para o inicio do vetor e inicialize EBX para receber a soma
	MOV ESI, vetor_divisores
	MOV EBX, 0
	
somatorio:
	LODSD                 ; Carrega elemento do vetor em EAX
	CMP EAX, [param_soma] ; Verifica se o elemento carregado eh o parametro de entrada
	JZ encerra_somatorio  ; Se sim, encerra o somatorio
	ADD EBX, EAX          ; Se nao, soma EAX ao valor atual do somatorio
	JMP somatorio         ; Repete o somatorio
	
encerra_somatorio:
	XCHG EBX, EAX         ; Transfere o resultado do somatorio para ser retornado em EAX
	JMP end               ; Encerre a funcao
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; Retorna os divisores do argumento de entrada
; Entrada:
;    1 valor em EBX
; Saida:
;    vetor_divisores = lista dos divisores de EBX
divisor:
	ENTER 0, 0
	
	MOV [param_divisor], EBX ; Salva o parametro de entrada
	MOV EAX, EBX             ; EAX: dividendo / quociente
	MOV ECX, EBX             ; ECX: divisor
	MOV EDI, vetor_divisores ; EDI aponta para o inicio do vetor de divisores
	
teste_divisao:
	; Verifique quais numeros entre 1 e [param_divisor] dividem [param_divisor]
	; Ao achar um numero cujo resto da divisao com [param_divisor] seja zero
	; insira no vetor de divisores.
	; Repita o loop ate [param_divisor]
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
; Retorna todos os numeros primos entre 0 e o argumento de entrada
; Aplica logica do crivo de Eratostenes
; Entrada:
;    1 valor em EBX
; Saida:
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
; Indica se o parametro de entrada eh um numero primo
; Entrada:
;    1 valor na pilha
; Saida:
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
; Imprime na tela a sequencia de fibonacci de N elementos
; onde N eh o parametro de entrada
; Entrada:
;    1 valor na pilha
; Saida:
;    padrao: imprime na tela sequencia de fibonacci com N elementos
;    A funcao encerra imediatamente em caso de overflow numerico
fibonacci:
	ENTER 4, 0
	
	MOV ECX, [EBP + 8] ; Numero de elementos a imprimir
	
	MOV EAX, 0 ; numero atual
	MOV EBX, 0 ; numero anterior
	MOV EDX, 0 ; numero anterior do anterior
	
	; Imprima o elemento 0
	; Se a entrada for 0, encerre
	CALL print_int
	CMP ECX, 0
	JZ end
	
	; Imprima o elemento 1
	; Se a entrada for 1, encerre
	MOV EAX, espaco
	CALL print_string
	MOV EAX, 1
	CALL print_int
	CMP ECX, 1
	JZ end
	
	DEC ECX

insere_fibonacci:
	; Salve o valor atual e o valor anterior
	MOV EDX, EBX ; Agora o valor atual passa a ser o valor anterior
	MOV EBX, EAX ; e o valor anterior passa a ser o valor anterior do anterior
	
	; Imprima ","
	MOV EAX, espaco
	CALL print_string
	
	; Inicialize EAX para receber a soma dos valores
	MOV EAX, 0
	
	; Efetue a soma. Se a qualquer momento a soma estourar, encerre imediatamente
	; Imprima o resultado
	ADD EAX, EBX
	JO end
	ADD EAX, EDX
	JO end
	CALL print_int
	
	; Repita ate esgotar ECX. Encerre a funcao.
	LOOP insere_fibonacci
	JMP end
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
; Retorna o fatorial do parametro de entrada
; Entrada:
;    1 valor na pilha
; Saida:
;    EAX = fatorial do parametro de entrada
;    EAX = -1 se houver overflow numerico durante o calculo
fatorial:
	ENTER 4, 0
	
	; Verifique se o parametro de entrada eh 0 ou 1.
	; Se sim, retorne 1
	MOV EAX, [EBP + 8]
	CMP EAX, 0
	JZ fat_zero
	CMP EAX, 1
	JZ fat_zero
	
	; Inicialize EAX e ECX para calcular o fatorial
	MOV EAX, 1
	MOV ECX, [EBP + 8]
	
fat_lp:
	; Calcule o fatorial de tras para frente
	; n * (n-1) * (n-2) * ... * 3 * 2 * 1
	; Caso haja overflow numerico, interrompa o calculo e retorne -1
	IMUL EAX, ECX
	JO fat_overflow
	LOOP fat_lp
	JMP end
	
fat_zero:
	; Retorne 1 se o parametro de entrada for 0 ou 1
	MOV EAX, 1
	JMP end
	
fat_overflow:
	; Retorne -1 se houver overflow numerico durante o calculo do fatorial
	MOV EAX, -1
	JMP end
;-----------------------------------------------------------------------

;=======================================================================
;========================= PROGRAMA PRINCIPAL ==========================
;=======================================================================
	
asm_main:
	; Inicializacao
	ENTER 0, 0
	PUSHA
	
	; Prompt, insira 10 numeros
inicializacao:
	MOV EAX, text_prompt1
	CALL print_string
	CALL print_nl
	
	MOV EDI, vetor_entrada
	MOV ECX, 10
	
	MOV EAX, 0
	
	JMP ler_numeros
	
	; Leia da entrada os 10 numeros inseridos.
ler_numeros:
	CALL read_int
	STOSD
	LOOP ler_numeros
	
	MOV ECX, 10
	CALL print_nl
	JMP calcula_divisores
	
	; Calcule para cada numero a soma de seus divisores
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
	JMP inicializa_emCiclo
	
	; Inicializa vetor emCiclo, para registrar elementos que ja pertencem a algum ciclo sociavel
inicializa_emCiclo:
	MOV EDI, vetor_emCiclo
	MOV EAX, -1
	MOV ECX, 10
	REP STOSD
	JMP imprime_menu
	
	; Entre no menu (imprima o menu na tela)
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
	
	JMP menu

	; Aguarde entrada do usuario
menu:
	CALL read_int      ;switch (input) {
	CMP EAX, 1         ;    case 1:
	JZ check_excessivo ;        excessivo();
                       ;        break;
	CMP EAX, 2         ;    case 2:
	JZ check_perfeito  ;        perfeito();
                       ;        break;
	CMP EAX, 3         ;    case 3:
	JZ check_deficiente;        deficiente();
                       ;        break;
	CMP EAX, 4         ;    case 4:
	JZ check_amigavel  ;        amigavel();
                       ;        break;
	CMP EAX, 5         ;    case 5:
	JZ check_sociavel  ;        sociavel();
                       ;        break;
	CMP EAX, 6         ;    case 6:
	JZ check_primo     ;        primo();
                       ;        break;
	CMP EAX, 7         ;    case 7:
	JZ check_fibonacci ;        fibonacci();
                       ;        break;
	CMP EAX, 8         ;    case 8:
	JZ check_fatorial  ;        fatorial();
                       ;        break
	JMP end            ;    default:
                       ;        exit();
                       ;        break;
                       ;}
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_excessivo:
	; Chamada da funcao excessivo
	CALL excessivo
	JMP voltar_menu

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_perfeito:
	; Chamada da funcao perfeito
	CALL perfeito
	JMP voltar_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_deficiente:
	; Chamada da funcao deficiente
	CALL deficiente
	JMP voltar_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_amigavel:
	; Chamada da funcao amigavel
	CALL amigavel
	JMP voltar_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_sociavel:
	MOV ECX, 0 ;[0~36] navega por vetor_entrada (loop externo)
	MOV EDX, 0 ;[0~36] navega por vetor_entrada (loop interno)
	MOV EBX, 0 ;numero de candidatos
	MOV EDI, vetor_candidatos ; Armazena possiveis candidatos a numeros sociaveis
	
	; Imprime na tela prompt de resposta
	MOV EAX, text_res_sociavel
	CALL print_string
	
ja_tem_ciclo:
	; Verifica se o elemento atual ja pertence a um ciclo previamtente detectado
	; Se sim, avanca imediatamente para o proximo elemento a analizar
	MOV EAX, [vetor_emCiclo + ECX]
	CMP EAX, -1
	JNZ reiniciar_emciclo
	
	; Assuma que o elemento atual pertence a algum ciclo de numeros sociaveis
	; Insira ele no vetor_candidatos como 1o elemento deste ciclo
	MOV EAX, [vetor_entrada + ECX]
	STOSD
	INC EBX
	MOV [vetor_emCiclo + ECX], EAX
	
	; Salva o 1o elemento do ciclo
	MOV [inicio_ciclo], EAX
	MOV EAX, [vetor_soma_divisores + ECX]
	
busca_sociavel:
	; Procure por um elemento em vetor_entrada que seja igual
	; a soma dos divisores do elemento atual
	; Se encontrar tal elemento, insira como candidato
	; Se nao, avance para o proximo indice do vetor e repita
	; Se varrer o vetor em vao, entao nao ha ciclo de numeros sociaveis
	; Reinicie a busca, nesse caso
	CMP EAX, [vetor_entrada + EDX]
	JZ insere_candidato
	ADD EDX, 4
	CMP EDX, 40
	JGE reiniciar_emciclo
	JMP busca_sociavel
	
insere_candidato:
	; Insira no vetor_candidatos, possiveis elementos de um ciclo de numeros sociaveis
	; Se o elemento a ser inserido for o 1o elemento do ciclo, entao o ciclo foi fechado
	; Verifique se o ciclo eh, de fato, um ciclo de numeros sociaveis
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
	; Para um ciclo ser um ciclo de numeros sociaveis, este deve conter
	; no minimo, 3 elementos
	; Se o ciclo tiver 2 elementos, entao os dois elementos sao amigaveis
	; Descarte este ciclo e tente de novo
	CMP EBX, 3
	JL reiniciar_emciclo

	; Caso contrario, o ciclo em questao eh de numeros sociaveis
	; Imprima este ciclo na tela
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
	
reiniciar_sociavel:
	; Avanca para o proximo elemento do vetor a ser analizado
	; Reinicia registradores e ponteiros
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	MOV EDX, 0
	MOV EBX, 0
	MOV EDI, vetor_candidatos
	JMP ja_tem_ciclo
	
reiniciar_emciclo:
	; Reinicia o vetor emCiclo
	XCHG ECX, EBX
	MOV EDI, vetor_candidatos
	MOV EAX, -1
	MOV ECX, 10
	REP STOSD
	XCHG ECX, EBX
	JMP reiniciar_sociavel
	
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
check_primo:
	MOV ECX, 0 ; ECX = 0~36
	
	; Imprime na tela prompt de resposta
	MOV EAX, text_res_primo
	CALL print_string

primo_lp:
	; Passa o elemento atual do vetor de entrada como parametro para funcao primo()
	; Esta funcao ira verificar se [vetor_entrada + ECX] eh ou nao primo
	MOV EAX, [vetor_entrada + ECX]
	PUSH EAX
	CALL primo
	
	; primo() retorna em EAX 1 se o parametro de entrada eh primo, 0 caso contrario
	CMP EAX, 1
	JZ insere_primo
	
	; se retornar 0, imprima string indicando que [vetor_entrada + ECX] nao eh primo
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, nulo
	CALL print_string
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice. Encerre ao terminar de varrer o vetor.
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP primo_lp
	
insere_primo:
	; se retornar 1, imprima [vetor_entrada + ECX]
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	MOV EAX, colchete_fecha
	CALL print_string
	
	; Avance para o proximo indice. Encerre ao terminar de varrer o vetor.
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
	; Imprima na tela texto de resposta
	MOV EAX, text_res_fibonacci
	CALL print_string
	
	; Imprima na tela o numero que esta sendo analizado
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	
	; Passe este numero como parametro da funcao fibonacci()
	PUSH EAX
	MOV EAX, colchete_fecha
	CALL print_string
	MOV EAX, igual
	CALL print_string
	MOV [indice], ECX
	
	; Chame a funcao, espere ela imprimir o resultado
	CALL fibonacci
	
	; Avance para o proximo indice, encerre ao terminar de varrer o vetor
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
	; Imprima na tela texto de resposta
	MOV EAX, text_res_fatorial
	CALL print_string
	
	; Imprima na tela numero a ser analizado
	MOV EAX, colchete_abre
	CALL print_string
	MOV EAX, [vetor_entrada + ECX]
	CALL print_int
	
	; Empilhe este numero para passagem de parametro para funcao fatorial()
	PUSH EAX
	MOV EAX, colchete_fecha
	CALL print_string
	MOV EAX, igual
	CALL print_string
	MOV [indice], ECX
	
	; Chame a funcao
	CALL fatorial
	
	; Fatorial retornara fatorial(n) ou -1 caso haja overflow numerico
	CMP EAX, -1
	JZ check_fat_erro
	
	; Se nao houver overflow numerico, imprima o resultado do fatorial
	CALL print_int
	CALL print_nl
	JMP check_fat_reset
	
check_fat_erro:
	; Se houver overflow numerico, imprima mensagem de erro
	MOV EAX, text_erro_overflow
	CALL print_string
	CALL print_nl
	JMP check_fat_reset
	
check_fat_reset:
	; Avance para o proximo indice, encerre caso tenha varrido todo o vetor
	MOV ECX, [indice]
	ADD ECX, 4
	CMP ECX, 40
	JGE voltar_menu
	JMP check_fat_lp
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
voltar_menu:
	; Ao termino de uma funcao, imprima novamente o menu e aguarde entrada
	CALL print_nl
	JMP imprime_menu
	
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
	
end:
	; Use para encerrar a chamada de alguma funcao ou o programa em si.
	LEAVE
	RET
