;******************************************************************************
;                                                                             *
;     Filaname:     proyecto 2                                                *
;     Date         25 /08/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   proyecto 3                                               *
;                                                                             *
;******************************************************************************

    
#INCLUDE "p16f887.inc"
; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;------------- VARIABLES CON 1 ESPACIO -----------------------------------------
 
GPR_VAR  UDATA
    CONT1      RES 1     
    CONTA      RES 1
    CONTB      RES 1
    CONTOR     RES 1
    CONT1S     RES 1
    CONTADOR   RES 1 
   
    V_VOLT      RES 1
    VALOR_ADC	RES 1
 
    W_TEMP	RES 1
    STATUS_TEMP	RES 1 
    TEMP1	RES 1
    TEMP2	RES 1

;----------------------- CONFIGURACION DE INTERUPCIONES ------------------------
    
 RES_VECT  CODE    0x0000           
 GOTO   START  
 
ISR_VECT  CODE    0X0004
  
PUSH:
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
ISR:
    BTFSS INTCON, T0IF 
    GOTO POP
    MOVLW   .60
    MOVWF   TMR0
    BCF	    INTCON, T0IF
  
    DECFSZ  CONTOR,1
    BTFSS   STATUS, Z
    GOTO POP
    
POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
;---------------------------------TABLA----------------------------------------
TABLA_7S:
    
    ANDLW   B'00001111';1
    ADDWF   PCL, F
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


;------------------------------------------------------------------------------
;	    MAIN PROGRAM
;------------------------------------------------------------------------------
     
MAIN_PROG CODE  0X100 
 
START
    BANKSEL TRISA
    
   
    CALL   CONFIG_IO
    CALL   CONFIG_TMR0
    CALL   CONFIG_INTERRUPT

    GOTO   LOOP
  
;--------------------   LOOP   -------------------------------------------------
    
LOOP
   
    CALL  ADC_INICIO
    
    CALL  DISPLAY_1
    CALL  DISPLAY_0
    CALL  CONFIG_TR


    GOTO    LOOP   

;------------------------- OPERACIONES DE LOS BLOQUES -------------------------
 
ADC_INICIO:
    CALL    DELAY_1
    BSF	    ADCON0,GO	
    BTFSC   ADCON0,GO
    GOTO    $-1
    
    MOVF    ADRESH,W
    MOVWF   CONTA
    MOVWF   TXREG
    
; ------------- DISPLAYS --------------------------------------------
  
DISPLAY_0:
    BCF   PORTD, RD6
    SWAPF CONTA, W
    MOVWF TEMP1
    MOVLW 0X0F
    ANDWF TEMP1, W
    CALL  TABLA_7S
    MOVWF PORTB 
    BSF   PORTD, RD7
    RETURN
 
DISPLAY_1:
    BCF   PORTD, RD7
    MOVLW 0X0F
    ANDWF CONTA,W
    CALL  TABLA_7S
    MOVWF PORTB 
    BSF   PORTD, RD6
    RETURN 
    
; ------------- CONFIGURACION IO --------------------------------------------
  
CONFIG_TR:
    BSF	    STATUS, RP0
    MOVLW   .31
    MOVWF   SPBRG
    BCF	    TXSTA,4
    BCF	    TXSTA,2
    BCF	    TXSTA,6
    BSF	    TXSTA, 5
    BSF	    PIR1, RCIE
    
    BCF	    STATUS, RP0
    BSF	    RCSTA,7
    BSF	    RCSTA,4
    BCF	    RCSTA,6 
    
    BCF	    PIR1, RCIF
 
    RETURN

    
    
CONFIG_IO:
    
    BANKSEL ADCON1
    MOVLW   B'00000000'
    MOVWF   ADCON1
    
    BANKSEL TRISA
    BSF	    TRISA,0
    
    BANKSEL ANSEL
    BSF	    ANSEL,0
    
    BANKSEL ADCON0
    MOVLW   B'01000011'
    MOVWF   ADCON0
    
    
    BANKSEL TRISB
    MOVLW   B'00000000'
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
    
    

;-------------------- TIMER 0 ----------------------------------------------
CONFIG_TMR0:
    BANKSEL TRISA
    BCF OPTION_REG , T0CS
    BCF OPTION_REG , PSA
    BSF OPTION_REG , PS2
    BSF OPTION_REG , PS1
    BCF OPTION_REG , PS0
 
    BANKSEL PORTA
    MOVLW .50
    MOVWF TMR0
    BCF INTCON, T0IF
    RETURN
 
CONFIG_INTERRUPT:
    BSF  INTCON, GIE
    BSF  INTCON, T0IE
    BCF  INTCON, T0IF 
    RETURN 

DELAY_1:
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
    
END
    
    