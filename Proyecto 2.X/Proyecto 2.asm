;******************************************************************************
;                                                                             *
;     Filaname:     lab -> laboratorio 4.asm                                  *
;     Date         25 /08/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   contador de 8 bits   HEXAGECIMAL                         *
;                                                *
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
    CONT2	RES 1
    CONT3	RES 1
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
	
    INDICADOR	RES 1
    INDICADOR2  RES 1
    NIBLE_H	RES 1
    NIBLE_L	RES 1
    DISPLAY_0   RES 1
    DISPLAY_1	RES 1
    DISPLAY_2	RES 1
    DISPLAY_3	RES 1
    X		RES 1
    Y		RES 1
    RECIBIDOX	RES 1
    RECIBIDOY	RES 1
		
    
;----------------------- CONFIGURACION DE INTERUPCIONES ------------------------
    
 RES_VECT  CODE    0x0000           
 GOTO   START  
 
ISR_VECT  CODE    0X0004
  
PUSH:
    BCF	  INTCON, GIE
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
ISR:
    BTFSC   INTCON, T0IF
    CALL    INTER_TMR0
    BTFSC   PIR1, ADIF
    CALL    INTER_ADC
    BTFSC   PIR1, TMR2IF
    CALL    INTER_TMR2
    BTFSC   PIR1, RCIF	
    CALL    INTER_RECIBIR
    
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF	    INTCON, GIE
    RETFIE
   
;------------------------------------------------------------------------------

INTER_TMR0:
    MOVLW   .248
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    CALL    DISPLAY_VAR
    CALL    SEP_NIBLES
    RETURN
    
INTER_ADC:
    BTFSS   CONT3, 0
    GOTO    INTE_Y
    
INTER_X:
    CALL    CONFIG_INTE_X
    MOVWF   ADRESH, W
    MOVWF   X
    BCF	    PIR1, ADIF
    BSF     ADCON0,1
    BCF	    CONT3,0
    RETURN
    
INTER_Y:
    CALL    CONFIG_ADC_Y
    MOVWF   ADRESH,W
    MOVWF   Y
    BCF	    PIR1, ADIF
    BSF	    ADCON0,1
    BSF	    CONT3,0
    RETURN 
    
INTER_RECIBIR:
    BTSC    CONT3,0
    GOTO    RECIBIR_X
    
RECIBIR_X:
    MOVFW   RCREG
    MOVWF   RECIBIDOX
    BSF	    CONT3,0
    RETURN  
    
RECIBIR_Y:
    MOVFW   RCREG
    MOVWF   RECIBIDOY
    BCF	    CONT3,0
    RETURN
    
INTER_TMR2:
    BCF	    PIR1, TMR2IF
    BTFSC   PIR1, TXIF
    CALL    INTER_TX
    RETURN
    
    
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
   
    CALL    CONFIG_IO
    CALL    CONFIG_TMR0
    CALL    CONFIG_TMR2
    CALL    CONFIG_INTERRUPT
    CALL    CONFIG_ADC
    CALL    CONFIG_TX_9600
    CALL    CONFIG_RX

  
;--------------------   LOOP   -------------------------------------------------
    
LOOP
    ;CALL  ADC_INICIO
    
    ;CALL  DISPLAY_1
    ;CALL  DISPLAY_0

    GOTO    LOOP   

;------------------------- OPERACIONES DE LOS BLOQUES -------------------------
 
ADC_INICIO:
    CALL    DELAY_1
    BSF	    ADCON0,GO	
    BTFSC   ADCON0,GO
    GOTO    $-1
    
    MOVF    ADRESH,W
    MOVWF   CONTA
    
; ------------- DISPLAYS --------------------------------------------
 
    
DISPLAY:
    BCF	    PORTA,1
    BCF	    PORTA,2
    BCF	    PORTA,3
    BCF	    PORTA,4
    BCF	    PORTA,5
    BTFSC   FLAG, 0
    GOTO CY
    
    CX:
	BTFSC	FLAG,1
	GOTO	OP1X
	
	OP0X:
	    MOVFW   DISPLAY_H
	    CALL    TABLA_7S
	    MOVWF   PORTD
	    BSF	    PORTA,1
	    BSF	    FLAG, 1
	    RETURN
	    
	OP1X:
	    MOVFW   DISPLAY_L
	    CALL    TABLA_7S
	    MOVWF   PORTD
	    BSF	    PORTA, 2
	    BSF	    FLAG, 0
	    BCF	    FLAG,1
	    RETURN
    
    CY:
	BTFSC	FLAG,1
	GOTO	OP1Y
	
	OP0Y:
	    MOVFW   DISPLAY_H
	    CALL    TABLA_7S
	    MOVWF   PORTD
	    BSF	    PORTA, 4
	    BSF	    FLAG, 1
	    RETURN
	    
	OP1Y:
	    MOVFW   DISPLAY_L
	    CALL    TABLA_7S
	    MOVWF   PORTD
	    BSF	    PORTA, 5
	    BCF	    FLAG, 0
	    BSF	    FLAG, 1
	    RETURN
	    
	  

;------------------------------------------------------------------------------
	    
NIB_SEP:
    MOVFW   COMUNICACION
    MOVWF   DISPLAY_L
    SWAPF   COMUNICACION, W
    MOVWF   DISPLAY_H
RETURN
    
;------------------------------------------------------------------------------	    
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
  
CONFIG_IO:
    
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
    
CONFIG_ADC:
    BANKSEL ADCON1
    CLRF    ADCON1
    
    BANKSEL PORTA
    BSF	    TRISA,0
    BSF	    TRISA,5
    
    BANKSEL ADCON0
    BSF	    ADCON0,7
    BSF	    ADCON0,ADON
    BSF	    ADCON0,GO
    BCF	    ADCON0, 6
    BCF	    ADCON0, 5
    BCF	    ADCON0, 3
    BCF	    ADCON0, 2
    
    BANKSEL ANSEL
    BSF	    ANSEL,0
    BSF	    ANSEL,5
    
    BANKSEL PORTA
    BSF	    INTCON,GIE
    BCF	    INTCON, T0IF
    
    RETURN
    
CONFIGURACION_ADCX:
    BANKSEL ADCON0
    BCF	    ADCON0, 2
    BCF	    ADCON0, 3
    RETURN

 CONFIGURACION_ADCY:
    BANKSEL ADCON0
    BCF	    ADCON0, 2
    BCF	    ADCON0, 3
    RETURN
    
CONFIG_TX_9600:
    BANKSEL TRISA
    BCF	    TXSTA, TX9
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, BRGH
    
    BANKSEL ANSEL
    BCF	    BAUDCTL, BRG16
    
    BANKSEL TRISA
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BSF	    TXSTA, TXEN
    BANKSEL PORTA
    RETURN
    
CONFIG_RX:
    BANKSEL PORTA
    BSF	    RCSTA, SPEN
    BSF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    
    
;-------------------- TIMER 0 ----------------------------------------------
CONFIG_TMR0:
    BANKSEL TRISA
    CLRWDT
    MOVLW   B'11010111'
    MOVWF   OPTION_REG
    RETURN
    
CONFIG_TMR2:
    BANKSEL PORTA
    MOVLW   B'11111111'
    MOVWF   T2CON
    RETURN
    
CONFIG_INTERRUPT:
    BANKSEL TRISA
    BSF	    PIE1, TMR2IE
    BSF	    PIE1, ADIE
    BSF	    PIE1, RCIE
    BSF	    PIE1, TXIE
    BSF	    INTCON, PEIE
    BSF	    INTCON, T0IF
    MOVLW   .20
    MOVWF   PR2
    
    BANKSEL PORTA
    BSF	    INTCON, GIE
    BCF	    INTCON, T0IF
    
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