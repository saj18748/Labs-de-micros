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

BUTTON_A    EQU RA0
BUTTON_B    EQU RA1
BUTTON_C    EQU RA2
BUTTON_D    EQU RA3
BUTTON_P    EQU RA5


    
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
    CLRF	PORTC
    CLRF	PORTB
    CLRF	PORTD
    CLRF	PORTE
 
    
    BANKSEL	ANSEL
    CLRF	ANSEL
    CLRF	ANSELH	
    
    ;***********************************************************************
    BANKSEL TRISA     
    CLRF    TRISA
    MOVLW   B'00111111'
    MOVWF   TRISA
   
    
    CLRF    TRISC
    MOVLW   B'11110000'
    MOVWF   TRISC
    
    CLRF    TRISD
    MOVLW   B'11110000'
    MOVWF   TRISD
    
    CLRF    TRISB
    MOVLW   B'11110000'
    MOVWF   TRISB 
   
    ;**********************************************************************
	
    BANKSEL	PORTA 
    CLRF	PORTA 
    CLRF	PORTE 
    CLRF	PORTC
    CLRF	PORTE

;******************************************************************************
;     MAIN LOOP
;******************************************************************************

LOOP:
   BANKSEL  PORTA
   BTFSS    PORTA, BUTTON_A
   GOTO	    LOOP2
   
   BSF	    PORTA, BUTTON_A
   GOTO	    INCRE
   CALL	    DELAY_SMALL
   
   
LOOP2:
   BTFSS    PORTA, BUTTON_B
   GOTO	    LOOP3
   
   BSF	    PORTA, BUTTON_B
   GOTO	    DECRE
   CALL	    DELAY_SMALL

LOOP3:
   BTFSS    PORTA, BUTTON_C
   GOTO	    LOOP4
   
   BSF	    PORTA, BUTTON_C
   GOTO	    INCRE2
   CALL	    DELAY_BIG
   
LOOP4:
   BTFSS    PORTA, BUTTON_D
   GOTO	    LOOP5
   
   BSF	    PORTA, BUTTON_D
   GOTO	    DECRE2
   CALL	    DELAY_BIG
   
LOOP5:
   BTFSS    PORTA, BUTTON_P
   GOTO	    LOOP
   
   BSF	    PORTA, BUTTON_P
   GOTO	    YEFRY
   CALL	    DELAY_SMALL
   
;---------------------------------------------------------------------------
    
INCRE:  ;INCREMENTO 1
    BTFSC   PORTA, BUTTON_A
    GOTO    INCRE
    CALL    DELAY_SMALL
    INCF    PORTC  , F
    GOTO    LOOP 

DECRE: ; DECREMENTO 2
    BTFSC   PORTA, BUTTON_B
    GOTO    DECRE
    CALL    DELAY_SMALL
    DECF    PORTC, F
    GOTO    LOOP
   
INCRE2:
    CALL    DELAY_BIG
    BTFSC   PORTA, BUTTON_C
    GOTO    INCRE2
    CALL    DELAY_BIG
    INCF    PORTD , F
    CALL    DELAY_BIG
    GOTO    LOOP 

DECRE2:
    CALL    DELAY_BIG
    BTFSC   PORTA, BUTTON_D
    GOTO    DECRE2
    DECF    PORTD, F
    GOTO    LOOP
    CALL    DELAY_SMALL

YEFRY:
    BTFSC   PORTA, BUTTON_P
    GOTO    YEFRY
    INCF    PORTB, F
    GOTO    LOOP
    CALL    DELAY_SMALL
    
    
   
;******************************************************************************
;     SUB RUTINA PARA DELAY
;******************************************************************************
    
DELAY_BIG:
    MOVLW   .50	    ;0X100
    MOVWF   CONT2  ;0X100
CONFIG1:
    CALL    DELAY_SMALL	    ;0X10E
    DECFSZ  CONT2, F	    ;0X10F
    GOTO    CONFIG1
RETURN 

DELAY_SMALL:
    MOVLW   .150
    MOVWF   CONT1
    DECFSZ  CONT1, F 
    GOTO    $-1		; IR A PC  -1 ,REGRESAR A DECFSZ    
RETURN 

;******************************************************************************
   
    END