; UNIVERSIDADE FEDERAL DA BAHIA
; MATA49-PROGRAMACAO DE SOFTWARE BASICO
; PROFESSOR: ALBERTO VIANNA
; ALUNO: SAULO RIBEIRO DE ANDRADE

; TRABALHO PRATICO 2015.2
; Rodar com make
; ./Saulo_TrabalhoPratico

%include "asm_io.inc"

segment .data
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
	
	i_vetor_soma_divisores  RESD 1
	param_crivo             RESD 1
	param_divisor           RESD 1
	param_soma              RESD 1
	divisor_param1          RESD 1   ; armazena soma dos divisores do 1o parametro de amigavel()
	divisor_param2          RESD 1   ; armazena soma dos divisores do 2o parametro de amigavel()

segment .text
	GLOBAL asm_main
	
;=======================================================================
;========================= PROCEDIMENTOS      ==========================
;=======================================================================

;-----------------------------------------------------------------------
; requer empilhar 1 valor na pilha
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
; requer empilhar 1 valor na pilha
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
; requer empilhar 1 valor na pilha
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
; requer empilhar 2 valores na pilha
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
; recebe como parametro um valor em EBX
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
; recebe como parametro um valor em EBX
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
; recebe como parametro um valor em EBX
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
; requer empilhar 1 valor na pilha
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
	
;	MOV EBX, [testificate2]
;	CALL soma_divisores
;	CALL print_int
;	CALL print_nl
	
	MOV EAX, [testificate]
	PUSH EAX
	MOV EAX, [testificate2]
	PUSH EAX
	CALL amigavel
	
	CALL print_int
	CALL print_nl
	
;	MOV ECX, 10
;	MOV ESI, vetor_divisores
;	
;lp:
;	LODSD
;	CALL print_int
;	CALL print_nl
;	LOOP lp
	
end:
	LEAVE
	RET
