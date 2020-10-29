;******************************************************************************
;                                                                             *
;     Filaname:     proyecto 1 -> Proyecto 1.asm                                  *
;     Date         25 /08/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   proyecto 1. Reloj                                        *
;                                                                             
;******************************************************************************

    
; CONFIGURACION DEL PIC 16F887
    
#INCLUDE "p16f887.inc"
; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
;--------------------- DECLARACION DE VARIABLES--------------------------------
 
GPR_VAR  UDATA 
  
    W_TEMP       RES 1
    STATUS_TEMP  RES 1
  
    CONTA        RES 1
    CONTB        RES 1
    CONT1        RES 1
    CONT2        RES 1
    CONT3	RES 1
    CONT4	RES 1
	
    CONTADOR_1   RES 1
    CONTADOR_2   RES 1
    CONTADOR_3	 RES 1
    CONTADOR_4	 RES 1 
    TEMP1        RES 1 
    TEMP2        RES 1
    CONT_B       RES 1
     
    NIBBLEH	RES 1
    NIBBLEL	RES 1
    NIBBLEH2    RES 1
    NIBBLEL2    RES 1

RES_VECT  CODE    0x0000            
    GOTO    START                   

;----------------- CONFIRACION DE LAS INTERRUPCIONES  --------------------------
 
ISR_VEC CODE 0X004
 
PUSH:
    BCF   INTCON, GIE
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
ISR:
    BTFSC   PIR1, TMR2IF
    CALL    FUE_TIMR2
    BTFSC   PIR1, TMR1IF
    CALL    FUE_TIMR1  
    BTFSS   INTCON, T0IF 
    GOTO POP    
    CALL    FUE_TIMR0
POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    BSF   INTCON, GIE 
RETFIE
    
;----------------- SUBRUTINAS DE TIMERS --------------------------------------
FUE_TIMR0:
    BTFSS   INTCON, T0IF 
    GOTO POP
    MOVLW   .6
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    CALL    DISPLAY_INICIO
    
    RETURN 
    
FUE_TIMR1:
    MOVLW   .207 
    MOVWF   TMR1H
    MOVLW   .38  
    MOVWF   TMR1L
    BCF	    PIR1, TMR1IF
    INCF    CONTADOR_1
    INCF    CONTADOR_2
    RETURN 
    
FUE_TIMR2:
    CLRF  TMR2
    BCF   PIR1, TMR2IF
    INCF  CONTADOR_4
   RETURN 
    

;------------------------------------------------------------------------------
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

;------------------------- MAIN PROGRAM ---------------------------------------
MAIN_PROG CODE       0X100   

START
    CALL    CONFIG_IO
    CALL    CONFIG_TIMER0
    CALL    CONFIG_TIMER1
    CALL    CONFIG_TIMER2
    CALL    CONFIG_FLAG
    BANKSEL PORTA 
    CLRF    CONTADOR_1
    CLRF    CONTADOR_2
    CLRF    CONTADOR_3
    CLRF    CONTADOR_4
    CLRF    CONT1
    CLRF    NIBBLEL
    CLRF    NIBBLEH
    CLRF    NIBBLEL2
    CLRF    NIBBLEH2
    
;-------------------- LOOP -----------------------------------------------------
LOOP   
    CALL TIM_US
    CALL TIM_DS
    CALL INCREMENTO_1
    
    CALL TIM_2US
    CALL TIM_2DS
    CALL INCREMENTO_2
    
    CALL LEDS_INTER
    
    GOTO LOOP                        

;--------------- CONFIGURACION DE LOS CONTADORES------------------------------

TIM_US	; CONTADOR DE UNIDAD
    MOVF CONTADOR_1,0
    SUBLW .10
    BTFSC STATUS,Z
    GOTO VARIABLE1
RETURN 
    
VARIABLE1:
    INCF NIBBLEL
    CLRF CONTADOR_1
RETURN
    
TIM_DS	; CONTADOR DE DECENAS
    MOVF CONTADOR_2,0
    SUBLW .10
    BTFSC STATUS,Z
    GOTO VARIABLE2
RETURN 

VARIABLE2:
    INCF CONT2
    CLRF CONTADOR_2
RETURN 
 
INCREMENTO_1:
    MOVF NIBBLEL,W
    SUBLW .10
    BTFSC STATUS,Z
    CALL  INCREMENTOS_D10S
RETURN 
    
INCREMENTOS_D10S:
    INCF NIBBLEH
    CLRF NIBBLEL
    MOVF NIBBLEH,W
    SUBLW .6
    BTFSC STATUS,Z
    CALL CEROS
RETURN 


CEROS:
    CLRF NIBBLEL
    CLRF NIBBLEH
RETURN 

;------------------------------------------------------------------------------
  
TIM_2US	; CONTADOR DE UNIDAD
    MOVF CONTADOR_3,0
    SUBLW .10
    BTFSC STATUS,Z
    GOTO VARIABLE3
RETURN 
    
VARIABLE3:
    INCF NIBBLEL2
    CLRF CONTADOR_3
RETURN
    
TIM_2DS	; CONTADOR DE DECENAS
    MOVF CONTADOR_4,0
    SUBLW .10
    BTFSC STATUS,Z
    GOTO VARIABLE4
RETURN 

VARIABLE4:
    INCF CONT3
    CLRF CONTADOR_4
RETURN 
 
INCREMENTO_2:
    MOVF NIBBLEL2,W
    SUBLW .10
    BTFSC STATUS,Z
    CALL  INCREMENTOS_2
RETURN 
    
INCREMENTOS_2:
    INCF NIBBLEH2
    CLRF NIBBLEL2
    MOVF NIBBLEH2,W
    SUBLW .6
    BTFSC STATUS,Z
    CALL CEROS2
RETURN 


CEROS2:
    CLRF NIBBLEL2
    CLRF NIBBLEH2
RETURN 

;------------------- CONFIGURACION DE LED INTERMITENTES ------------------------
 
LEDS_INTER:
    BCF    PORTB, RB0
    BTFSC  CONT2,0
    GOTO   LEDON
LEDOFF:
    BCF   PORTB, RB0
    GOTO  TOGGLE
LEDON:  
    BSF   PORTB, RD0
    GOTO  TOGGLE

;-------------- TOGGLE 1 ---------------------------------------------------------
TOGGLE:
    BTFSS  CONT2, 0
    GOTO    TOG_0
TOG_1:
    BSF	    CONT2, 0
    RETURN
TOG_0:
    BCF	    CONT2, 0
RETURN
 
;------------------------------------------------------------------------------
       
CONFIG_FLAG
    BSF  INTCON, GIE
    BSF  INTCON, T0IE
    BCF  INTCON, T0IF 
    BANKSEL TRISA 
    BSF     PIE1, TMR1IE
    BSF     PIE1, TMR2IE 
    BANKSEL PORTA
    BSF     INTCON, GIE
    BSF     INTCON, PEIE
    BCF     PIR1, TMR1IF
    BCF     PIR1, TMR2IF 
RETURN 
 
;------------------- CONFIGURACION DE LOS TIMERS ------------------------------
CONFIG_TIMER0
    BANKSEL TRISA
    BCF OPTION_REG , T0CS
    BCF OPTION_REG , PSA
    BCF OPTION_REG , PS2
    BSF OPTION_REG , PS1
    BCF OPTION_REG , PS0
    BANKSEL PORTA
    MOVLW   .6
    MOVWF   TMR0
    BCF INTCON, T0IF
RETURN
 
CONFIG_TIMER1
    BANKSEL   PORTA
    BCF T1CON, TMR1GE
    BSF T1CON, T1CKPS1 
    BSF T1CON, T1CKPS0 
    BCF T1CON, T1OSCEN 
    BCF T1CON, TMR1CS 
    BSF T1CON, TMR1ON 
    MOVLW .207  ;
    MOVWF TMR1H
    MOVLW .38  ;
    MOVWF TMR1L
    BCF	  PIR1, TMR1IF
RETURN 
 
CONFIG_TIMER2
    BANKSEL PORTA
    MOVLW   B'11100111'
    MOVWF   T2CON
    BANKSEL TRISA
    MOVLW   .241
    MOVWF   PR2
    BANKSEL PORTA
    CLRF    TMR2
    BCF     PIR1, TMR2IF
RETURN 
 
 
;-------------- CONFIGURACION DE LOS DISPLAY ----------------------------------

DISPLAY_INICIO:
    BCF   PORTD, RD0
    BCF   PORTD, RD1
    BCF	  PORTD, RD2
    BCF	  PORTD, RD3
    BTFSC  CONTA,0
    GOTO  DISPLAY_2
    
DISPLAY_1:  
    MOVFW NIBBLEH
    CALL  TABLA_7S
    MOVWF PORTC
    BSF   PORTD, RD1
    GOTO  TOGGLE2

DISPLAY_2:
    MOVFW NIBBLEL
    CALL  TABLA_7S
    MOVWF PORTC
    BSF   PORTD, RD0
    GOTO  TOGGLE2
    
TOGGLE2:
    BTFSS  CONTA, 0
    GOTO    TOG_02
TOG_12:
    BCF	    CONTA, 0
    RETURN
TOG_02:
    BSF	    CONTA, 0
    RETURN 

    
DISPLAY_3:  
    MOVFW NIBBLEH2
    CALL  TABLA_7S
    MOVWF PORTC
    BSF   PORTD, RD2
    GOTO  TOGGLE2

DISPLAY_4:
    MOVFW NIBBLEL2
    CALL  TABLA_7S
    MOVWF PORTC
    BSF   PORTD, RD3
    GOTO  TOGGLE3
    
TOGGLE3:
    BTFSS  CONTB, 0
    GOTO    TOG_03
TOG_13:
    BCF	    CONTB, 0
    RETURN
TOG_03:
    BSF	    CONTB, 0
    RETURN
    
    
;------------ CONFIURACION DE LOS PUERTOS -----------------------------------
CONFIG_IO
    BANKSEL TRISA
    
    MOVLW   B'00011111'
    MOVWF   TRISA
    BANKSEL PORTA
    CLRF    PORTA
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH 
  
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
    
    BANKSEL TRISE
    MOVLW   B'00000000'
    MOVWF   TRISE
    BANKSEL PORTE
    CLRF    PORTE
    RETURN
 
END