;  ****************************************************************************
;  Filaname:     lab -> P practic.asm                                          *
;  Date          21/07/2020                                                    *
;  File version: v.1                                                           *
; author :        Yefry Sajquiy - 18748                                        *
; company;        UVG                                                          *
; Description:   Incremente el pueto A, cada cierto retardo de tiempo.         *
;*******************************************************************************
    
#include "p16f887.inc"

; CONFIG1
; _config 0xF0F1
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
GPR_VAR    UDATA
    CONT1  RES 1  ; VARIABLE PARA REALIZAR DELAY
    CONT2  RES 1  ; VARIABLE PARA REALIZAR DELAY

;******************************************************************************
  
  RES_VECT CODE 0X0000     ;processor reset vector
      GOTO  START          ; go to begining of program
      
;*******************************************************************************
;         MAIN PROGRAM
;******************************************************************************

MAIN_PROG CODE 0x0100                  ; let linker place main program
 
START
 
 SETUP: 
    ; BANK STATUS 6,5
    BCF STATUS, 5
    BCF STATUS, 6     ;BANCO 0
    CLRF  PORTA       ; BORRA EL PUETO A
    CLRF  PORTC
    
    BSF STATUS, 5
    BSF STATUS, 6   ;BANCO 3
    CLRF   ANSEL    ;BORRA EL CONTROL DE ENTRADASANALOGICAS
    CLRF   ANSELH   ; BORRA EL CONTROL DE LAS ENTRADAS ANALOGICAS
    
    BCF STATUS,6
    BSF SATATUS,5   ;BANCO 1
    CLRF   TRISTA
    CLRF   TRISC
    
    BCF STATUS, 5   ;BANCO 0
    CLRF   PORTC
    
;*******************************************************************************
;        MAIN LOOP
;******************************************************************************
    
 LOOP: 
    INCF PORTA, 1   ;INCREMENTAR EL PUERO A Y GUARDAS EN F (1)
    CALL DELAY_BIG       ; LLAMAR A RUTINA DE DELAY
    
    GOTO LOOP       ; SALTO HACIA EL LOOP
    
 ;*****************************************************************************
 ;                SUBRUTINA PARA DELAY
 ;****************************************************************************
 
DELAY_BIG
 
   MOVLW .50
   MOVWF CONT2 
 CONFIG1:
    CALL  DELAY_SMALL
    DECFSZ  CONT2, F
    GOTO    CONFIG1
RETURN
    
DELAY_SMALL
    MOVLW   .150
    MOVWF   CONT1
    DECFSZ  CONT1, F
    GOTO    $-1        ; IR A PC - 1, REGRASAR A DECFSZ
RETURN

;*******************************************************************************

END