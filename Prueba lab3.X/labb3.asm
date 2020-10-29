;******************************************************************************
;                                                                             *
;     Filaname:     lab -> laboratorio #3.asm                                 *
;     Date          14/08/2020                                                *
;     File version: v.1                                                       *
;     author :        Yefry Sajquiy - 18748                                   *
;     ompany;        UVG                                                      *
;     Description:   contador con TMRO, contador de disply                    *
;                    y alarma                                                 *
;******************************************************************************

    #include "p16f887.inc" 
    
;CONFIG1
;__config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF &_CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
;CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
 
; VARIABLES------------------------------------------------
 
GPR_VAR	    UDATA
    CONT1	RES 1
    CONT50MS    RES 1
    W_TEMP	RES 1
    STATUS_TEMP RES 1
    VAR_DISPLAY RES 1
    NIBBLE_L	RES 1
    NIBBLE_H    RES 1
   
   
; RESTE DEL VECTOR ----
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of program

    

; VECTOR DE INTERRUPCIONES -------------------

ISR_VECT  CODE	0x0004
  PUSH:
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
  
  ISR:
    BTFSS   INTCON, T0IF
    GOTO    POP 
    BCF	    INTCON, T0IF
    MOVLW   .61
    MOVWF   TMR0
    INCF    INTCON, T0IF
    
  POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE
    
;******************************************************************************
;     MAIN PROGRAM
;******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

SETUP
    CALL CONFIG_IO
    CALL INIT_TMR0
    CALL CONFIG_INTERRUPT
    BANKSEL PORTA
 ;BANKSEL TRISA
 
 ;BSF	STATUS, RP0
 ;BCF	STATUS, RP1
 ;CLRF	TRISD
 
 ;BSF	STATUS, RP0
 ;BSF	STATUS, RP1
 
 ;CLRF	ANSEL
 ;CLRF	ANSELH
 ;BCF	STATUS, RP0
 ;BCF	STATUS, RP1
 ;CALL	INIT_TMR0
    
    
 ;BCF	INTCON, T0IF
 ;BSF	INTCON, T0IE
 ;BSF	INTCON, GIE
 
 ;CLRF	PORTD
 
 ;CLRF	CONT50MS
 
LOOP:
    BTFSC   PORTA, RA0
    CALL    INCRED
    BTFSC   PORTA, RA1
    CALL    DECRED
    GOTO    LOOP
    
;CHECHE:
   ; MOVF    CONT50MS, W
    ;SUBLW   .10
    ;BTFSS   STATUS, Z
    ;GOTO    CHECHE
    ;CLRF    CONT50MS
   ; GOTO LOOP

INCRED:    
    CALL    DELAY_SMALL
    BTFSS   PORTA, RA0
    GOTO    INCRED
    INCF    PORTC, F
    GOTO LOOP
    
DECRED:
    CALL    DELAY_SMALL
    BTFSC   PORTA, RA1
    GOTO    DECRED
    DECF    PORTD
    RETURN
    
;CONFIGURACIONES -------------------

CONFIG_IO
    BANKSEL TRISA
    
    MOVLW   B'00000011'
    MOVFW   TRISA
    
    CLRF    TRISB
    CLRF    TRISC
    CLRF    TRISD
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    
    BANKSEL PORTA
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    
    CLRF    CONT50MS
    
    RETURN
 
CONFIG_INTERRUPT
    BSF	INTCON, GIE
    BSF	INTCON, T0IE
    BCF	INTCON, T0IF
    
    
;   SUB RUTINA TMR0 ---------------------------------------
    
INIT_TMR0
    ;BSF	    STATUS, RP0
    ;BCF	    STATUS, RP1
    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS
    BCF	    OPTION_REG, PSA
    
    BSF	    OPTION_REG, PS2
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    
    ;BCF	    STATUS, RP0
    ;BCF	    STATUS, RP1
    BANKSEL PORTA
    
    MOVLW   .61
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    
    RETURN 
    
DELAY_SMALL
    MOVLW   .150
    MOVWF   CONT1
    DECFSZ  CONT1, F
    GOTO $-1                         ; loop forever

    END