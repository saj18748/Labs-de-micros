;******************************************************************************
;                                                                             *
;     Filaname:     lab -> laboratorio #2.asm                                 *
;     Date          07/08/2020                                                *
;     File version: v.1                                                       *
;     author :        Yefry Sajquiy - 18748                                   *
;     ompany;        UVG                                                      *
;     Description:   contador de 4 bits                                       *
;      suma de los contadores                                                 *
;******************************************************************************

    #include "p16f887.inc" 
    
;CONFIG1
;__config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF &_CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
;CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

 
; -------------------- MACROS -----------------------------------------------

INPUT MACRO FILE, BIT
    BSF FILE, BIT
    ENDM 

; -------------------- EQU-----------------------------------------------

BUTTON_A    EQU RA1
LED         EQU RA7
    
;******************************************************************************

GPR_VAR	    UDATA
   CONT1   RES 1    ; VARIABLE PARA LLAMAR AL DELAY
   CONT2   RES 1    ; VARIABLE PARA LLAMAR AL DELAY 
   FLAGS   RES 1

;******************************************************************************
   
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE         0x100             ; let linker place main program

START


;SETUP
 
    ; BNAK STATUS BITS 6,5
    BANKSEL	PORTA	;BANCO 0
    CLRF	PORTA	;BORRA EL PUERTO A
    
	
    ;***********************************************************************
	
    BANKSEL	ANSEL	; BANCO 3
    CLRF	ANSEL	; DIGITAL PORTA Y PORTE
    CLRF	ANSELH	; DIGITAL PORTB
    ; BSF	ANSEL, .4 ;ANALOGIO AN4
	
    ;***********************************************************************
    BANKSEL TRISA     ; BANCO 2
    CLRF    TRISA
    BSF	    TRISA, BUTTON_A 
    CLRF    TRISC
    
    ; PULL UPS
    MOVLW	h'08' ; EACH PULL UPS  ON
    MOVWF	WPUB 
	
    BCF	OPTION_REG, .7  ;HABILITAR PULL UPS
	
    MOVLW h'FF'
    MOVWF TRISB  ;PORTB IS INPUT
    CLRF  TRISE
	
    ;BSF	TRISA, .5
     ;CLRF  TRISA 
    ;BSF TRISA, .0
	
    ;**********************************************************************
	
    BANKSEL	PORTA 
    CLRF	PORTA 
    CLRF	PORTE 
    CLRF	PORTC

;******************************************************************************
;     MAIN LOOP
;******************************************************************************

LOOP:
   BTFSS    PORTA, BUTTON_A
   GOTO	    LOOP
   CALL	    DELAY_SMALL
DEBOUNCE:
    BTFSC   PORTA, BUTTON_A
    GOTO    DEBOUNCE
    CALL	    DELAY_SMALL
    INCF    PORTC   , F
    GOTO    LOOP 
    
    ; INCF PORTA, 1 ; INCREMENTAR PUERTO A Y GUARDAR EN F
    ;CALL    DELAY_BIG
    ;BCF	    PORTA, LED
    ;BTFSC   PORTA, BUTTON_A 
    ;INCF    PORTC
    ;GOTO    LOOP

;******************************************************************************
;     SUB RUTINA PARA DELAY
;******************************************************************************
    
DELAY_BIG:
    MOVLW   .50	    ;0X100
    MOVWF    CONT2  ;0X100
CONFIG1:
    CALL    DELAY_SMALL	    ;0X10E
    DECFSZ  CONT2, F	    ;0X10F
    GOTO CONFIG1
RETURN 

DELAY_SMALL:
    MOVLW   .150
    MOVWF   CONT1
    DECFSZ  CONT1, F 
    GOTO    $-1		; IR A PC  -1 ,REGRESAR A DECFSZ    
RETURN 

;******************************************************************************
   
    END