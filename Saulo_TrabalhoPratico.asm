; UNIVERSIDADE FEDERAL DA BAHIA
; MATA49-PROGRAMACAO DE SOFTWARE BASICO
; PROFESSOR: ALBERTO VIANNA
; ALUNO: SAULO RIBEIRO DE ANDRADE

; TRABALHO PRATICO 2015.2
; Rodar com make
; ./Saulo_TrabalhoPratico

%include "asm_io.inc"

segment .data
	testificate dd 9
	
segment .bss
	vetor_primos            resd 100
	vetor_fatores_primos    resd 100
	vetor_divisores         resd 100
	param_crivo             resd 1
	param_divisor           resd 1

segment .text
	GLOBAL asm_main
	
;=======================================================================
;========================= PROCEDIMENTOS      ==========================
;=======================================================================

;-----------------------------------------------------------------------
; recebe como parametro um valor em EBX
divisor:
; dado um numero, preencher o vetor de primos
; dado um numero e o seu vetor de primos, preencher o vetor de fatores primos
; dado o vetor de fatores primos, preencher o vetor de divisores
	ENTER 0, 0
	
	MOV [param_divisor], EBX
	CALL crivo
;-----------------------------------------------------------------------


;-----------------------------------------------------------------------
; recebe como parametro um valor em EBX
crivo:
	ENTER 0, 0
	
	MOV EDI, vetor_primos

teste_crivo:
	MOV [param_crivo], EBX
	PUSH EBX
	CALL primo
	
	MOV EBX, [param_crivo]
	CMP EAX, 0
	JZ proximo
	MOV EAX, EBX
	STOSD

proximo:
	DEC EBX
	CMP EBX, 1
	JZ end
	JMP teste_crivo
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
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
	
	MOV EBX, [testificate]
	CALL crivo
	
	MOV ESI, vetor_primos
	MOV ECX, 10
	
lp:
	LODSD
	CALL print_int
	CALL print_nl
	LOOP lp
	JMP end
	
end:
	LEAVE
	RET
