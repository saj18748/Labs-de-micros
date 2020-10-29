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

    
; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
    #INCLUDE "p16f887.inc"
; CONFIG1
; __config 0xF0F1
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;-----------------------------------------------------------------------------
 
 GPR_VAR  UDATA 
 CONTF        RES 1
 CONT1        RES 1
 CONT2        RES 1
 CONTADOR1    RES 1
 CONTADOR2    RES 1 
 TEMP1        RES 1 ;PARA EL SAWPF DE LOS DYPLAY 
 TEMP2        RES 1
 CONTDE_4     RES 1
     
NIBBLEH RES 1
NIBBLEL RES 1
     
 ; VARIABLES TEPORALES 
 W_TEMP       RES 1
 STATUS_TEMP  RES 1
 

RES_VECT  CODE    0x0000            ; processor reset vector
 GOTO    START                   ; go to beginning of program

;***********TODO ADD INTERRUPTS HERE IF USED
ISR_VEC CODE 0X004
 PUSH:
    BCF   INTCON, GIE
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
 ISR:
    BTFSC PIR1, TMR2IF
    CALL FUE_TIMR2
    BTFSC PIR1, TMR1IF
    CALL FUE_TIMR1  
    BTFSS INTCON, T0IF 
    GOTO POP    
    CALL FUE_TIMR0
 POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS 
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    BSF   INTCON, GIE 
RETFIE
;----------------- SUBRUTINAS DE TIMERS --------------------------------------
FUE_TIMR0
    BTFSS INTCON, T0IF 
    GOTO POP
    MOVLW .6
    MOVWF TMR0
    BCF INTCON, T0IF
    CALL DISPLAY_GE
    RETURN 
    
FUE_TIMR1
    MOVLW .207  ;PRESCALER HIGH 
    MOVWF TMR1H
    MOVLW .38  ;PRESCALER LOW
    MOVWF TMR1L
    BCF  PIR1, TMR1IF
    INCF CONTADOR1
    RETURN 
    
FUE_TIMR2
    CLRF TMR2
    BCF PIR1, TMR2IF 
    INCF CONTADOR2
    RETURN 
;------------------------------------------------------------------------------
SEV_SEG:
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
 
MAIN_PROG CODE       0X100   
START
CALL    CONFIG_IO
CALL    CONFIG_TIMER0
CALL    CONFIG_TIMER1
CALL    CONFIG_TIMER2
CALL    CONFIG_FLAG
BANKSEL PORTA 
CLRF    CONTADOR1
CLRF    CONTADOR2
CLRF    CONT1
CLRF    NIBBLEL
CLRF    NIBBLEH
BCF   PORTA, RA4
BCF   PORTA, RA5

 GOTO LOOP  
;*****loop forever****
;*********
 LOOP:
    
 CALL TIMER1S
 CALL TIMER1_2S
 CALL INCREMENTUNOS
 CALL PISHLEDS
GOTO LOOP                        
;*********    
;****OPERACIONES****
 
 PISHLEDS
BCF   PORTA, RA4
BCF   PORTA, RA5
BTFSC  CONT2,0
GOTO SHOWON
SHOWOFF:
BCF   PORTA, RA4
BSF   PORTA, RA5
GOTO TOGGLE2
SHOWON:  
BSF   PORTA, RA4
BCF   PORTA, RA5
GOTO TOGGLE2
 TOGGLE2
    BTFSS  CONT2, 0
    GOTO    TOG_00
TOG_11:
    BSF	    CONT2, 0
    RETURN
TOG_00:
    BCF	    CONT2, 0
RETURN
 
    
    
TIMER1_2S
MOVF CONTADOR2,0
SUBLW .10
BTFSC STATUS,Z
GOTO VAP2
RETURN 
 VAP2
INCF CONT2
CLRF CONTADOR2
RETURN 
 
 
 
INCREMENTUNOS 
MOVF NIBBLEL,W
SUBLW .10
BTFSC STATUS,Z
CALL  INCREMENT10S
RETURN 
 INCREMENT10S
 INCF NIBBLEH
 CLRF NIBBLEL
 MOVF NIBBLEH,W
 SUBLW .6
 BTFSC STATUS,Z
 CALL CEROS
 RETURN 
 CEROS
 CLRF NIBBLEL
 CLRF NIBBLEH
 RETURN 
 
TIMER1S
MOVF CONTADOR1,0
SUBLW .10
BTFSC STATUS,Z
GOTO VAP1
RETURN 
 VAP1:
INCF NIBBLEL
CLRF CONTADOR1
RETURN 
 
    
CONFIG_FLAG
 ;TIMER0
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
 BSF T1CON, T1CKPS1 ;PRESCALER 
 BSF T1CON, T1CKPS0 ;PRESCALER 
 BCF T1CON, T1OSCEN ;TIMER INTERNO  
 BCF T1CON, TMR1CS 
 BSF T1CON, TMR1ON 
 MOVLW .207  ;PRESCALER HIGH 
 MOVWF TMR1H
 MOVLW .38  ;PRESCALER LOW
 MOVWF TMR1L
 BCF PIR1, TMR1IF
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
 
 
 ;****DISPLAY 7 SEGMENTOS ****

 DISPLAY_GE
 BCF   PORTD, RD0
 BCF   PORTD, RD1
 BTFSC  CONTF,0
 GOTO  DISPLAY_D2
 DISPLAY_D1:  
    
 MOVFW NIBBLEH
 CALL SEV_SEG
 MOVWF PORTC
 BSF   PORTD, RD1
 GOTO TOGGLE
 DISPLAY_D2:
 MOVFW NIBBLEL
 CALL  SEV_SEG
 MOVWF PORTC 
 BSF   PORTD, RD0
 GOTO TOGGLE

TOGGLE:
    BTFSS  CONTF, 0
    GOTO    TOG_0
TOG_1:
    BCF	    CONTF, 0
    RETURN
TOG_0:
    BSF	    CONTF, 0
    RETURN
 
 
 
 ;**********
 ;**********
 ;**********
CONFIG_IO
    BANKSEL TRISA
    
    MOVLW   B'0000000'
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
 DELAY
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
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 RETURN
END