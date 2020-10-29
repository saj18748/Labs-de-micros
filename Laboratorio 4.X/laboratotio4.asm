;******************************************************************************
;                                                                             *
;     Filaname:     lab -> laboratorio 42.asm                                 *
;     Date         21 /08/2020                                                *
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
    
GPR_VAR	    UDATA
   CONT1    RES 1
   CONT2   RES 1
   CONTA    RES 1
   CONTB    RES	1
   CONTOR   RES 1
   CONT1S   RES 1
   
   W_TEMP   RES 1
   STATUS_TEMP	RES 1
	
   TEMP1    RES 1
   TEMP2    RES 1
    
	
;------------------------------------------------------------------------------
    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT  CODE	 0x0004
  
PUSH:
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
    
ISR:
    BTFSS   INTCON, T0IF
    GOTO POP
    MOVLW   .60
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    INCF    CONT1S
    INCF    CONTOR
    DECFSZ  CONT2, 1
    BTFSS   STATUS, Z
    
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP,F
    SWAPF   W_TEMP, W
    RETFIE
    
;-------------------- TABLA ---------------------------------------------------

TABLA_7S
    ANDLW   B'00001111';1
    ADDWF   PCL
    RETLW   B'00111111';0
    RETLW   B'00000110';1
    RETLW   B'01011011';2
    RETLW   B'01001111';3
    RETLW   B'01100110';4
    RETLW   B'01101101';5
    RETLW   B'01111101';6
    RETLW   B'00000111';7
    RETLW   B'01111111';8
    RETLW   B'01101111';9
    RETLW   B'01110111';A
    RETLW   B'01111100';b
    RETLW   B'00111001';c
    RETLW   B'01011110';d
    RETLW   B'01111001';E
    RETLW   B'01110001';F

; -----------------------------------------------------------------------------
    
MAIN_PROG CODE                      ; let linker place main program

START
    BANKSEL TRISA
    CALL    CONFIG_IO
    CALL    CONFIG_TMR0
    CALL    CONFIG_INTERRUPT
    
    MOVLW   .2 ; EL CONTADOR INICIA EN 2
    MOVWF   CONTA
    GOTO    LOOP
    
    
LOOP
    CALL    INC_VAR
    CALL    DEC_VAR
    CALL    DISPLAY_1
    CALL    DISPLAY_0
    CALL    TMR1S
    
    MOVF    CONTB, W
    SUBWF   PORTB, W
    BTFSC   STATUS, Z
    CALL    RPSET
    GOTO LOOP
  
;------------------------------------------------------------------------------

TMR1S:
    MOVF    CONT1S, 0
    SUBLW   .10
    BTFSC   STATUS, Z
    CALL    LUZB
    RETURN
    
LUZB:
    INCF    PORTB
    CLRF    CONT1S
    RETURN
    
RPSET:
    BSF	    PORTA, RA5
    CLRF    CONTOR
    BTFSS   CONTOR, 0
    GOTO $-1
    
    CLRF    PORTB
    BCF	    PORTA, RA5
    RETURN
 
    
DISPLAY_0:
    BCF	PORTD, RD0
    SWAPF   CONTA, W
    MOVWF   TEMP1
    MOVLW   0X0F
    ANDWF   TEMP1, W
    CALL    TABLA_7S
    MOVWF   PORTC
    BSF	    PORTD, RD1
    RETURN
      
DISPLAY_1:
    BCF	    PORTD, RD1
    MOVLW   0X0F
    ANDWF   CONTA, W
    CALL    TABLA_7S
    MOVWF   PORTC
    BSF	    PORTD, RD0
    RETURN
    
    
INC_VAR:
    BCF	    STATUS, RP0
    BCF	    STATUS, RP1
    BTFSS   PORTA, RA0
    RETURN
    
    BTFSC   PORTA, RA0
    GOTO    $-1
    INCF    CONTA
    RETURN
    
DEC_VAR:
    BCF	    STATUS, RP0
    BCF	    STATUS, RP1
    BTFSS   PORTA, RA1
    
    BTFSC   PORTA, RA1
    GOTO    $-1
    DECF    CONTA
    RETURN
    
CONFIG_INTERRUPT:
    BSF	    INTCON, GIE
    BSF	    INTCON, T0IE
    BSF	    INTCON, T0IF
    RETURN
  
;  CONFIGURACION DE DELAY  -----------------------------------------
    
DELAY_SMALL:
    MOVLW   .250
    MOVWF   CONT1
    DECFSZ  CONT1
    GOTO    $-1
    RETURN

;-------------------- CONFIGURACIONES -----------------------------------------

CONFIG_IO
    BANKSEL TRISA
    
    MOVLW   B'0000011'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
  
    BANKSEL TRISB
    MOVLW   B'0000000'
    MOVWF   TRISB
    BANKSEL PORTB
    CLRF    PORTB
    
    BANKSEL TRISC
    MOVLW   B'00000000'
    MOVWF   TRISC
    BANKSEL PORTC
    CLRF    PORTC
    
    BANKSEL TRISD
    MOVLW   B'00000000'
    MOVWF   TRISD
    BANKSEL PORTD
    CLRF    PORTD

    RETURN
  
;-------- CONFIGURACION TIMER 0  ----------------------------------------------
CONFIG_TMR0
    BANKSEL TRISA
    BCF	    OPTION_REG, T0CS
    BCF	    OPTION_REG, PSA
    BSF	    OPTION_REG, PS2
    BSF	    OPTION_REG, PS1
    BSF	    OPTION_REG, PS0
    
    BANKSEL PORTA
    MOVLW   .60
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    RETURN
    
    END