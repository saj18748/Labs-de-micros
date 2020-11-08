;******************************************************************************
;                                                                             *
;     Filaname:     Practica #8                                               *
;     Date         25 /08/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   mover dos servos con portenciometros                     *
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
    W_TEMP    RES 1
    STATUS_TEMP RES 1
    DATO_PWM1   RES 1
    DATO_PWM2   RES 1
    DATO_PWM3   RES 1
    DATO_PWM4   RES 1
    DATO    RES 1
    DATO1    RES 1
    DATO2    RES 1
    DATO3    RES 1
    DATO4    RES 1
    CONTROL    RES 1
;------------------------------INICIO DEL PROGRAMA------------------------------
RES_VEC    CODE    0x0000
    GOTO    START  
ISR_VEC    CODE 0x0004    
PUSH:
    BCF    INTCON , GIE ; GUARDA LOS VALORES TEMPORALES
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
   
ISR:
    BTFSC   PIR1, TMR2IF
    CALL    FUE_TMR2
    BTFSC   INTCON, T0IF
    CALL    FUE_TMR0
    BTFSC PIR1, RCIF
    CALL INTRECEPTOR
POP:
    SWAPF   STATUS_TEMP, W ; VUELVE A CARGAR LOS VALORES TEMPORALES
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF    INTCON , GIE
    RETFIE
   
;------------------SUBRUTINAS DE LA INTERRUPCIÃ?N--------------------------------
FUE_TMR0
    BCF INTCON, T0IF
    MOVLW .206
    MOVWF TMR0
    DECFSZ DATO_PWM1,1
    GOTO PWM2
    BCF PORTB, 0
PWM2
    DECFSZ DATO_PWM2,1
    GOTO PWM3
    BCF PORTB, 1
 PWM3
    DECFSZ DATO_PWM3,1
    GOTO PWM4
    BCF PORTB, 2
PWM4
    DECFSZ DATO_PWM4,1
    RETURN
    BCF PORTB, 3
    RETURN
FUE_TMR2
    CLRF    TMR2
    BCF    PIR1, TMR2IF ; REINICIA EL TMR2
    MOVLW .255
    MOVWF PORTB
    MOVF DATO1, 0
    MOVWF DATO_PWM1
    MOVF DATO2, 0
    MOVWF DATO_PWM2
    MOVF DATO3,0
    MOVWF DATO_PWM3
    MOVF DATO4,0
    MOVWF DATO_PWM4
    RETURN
INTRECEPTOR
    BCF PIR1,RCIF
    MOVF RCREG, 0
    MOVWF DATO
    MOVWF PORTD
    BTFSC CONTROL,0
    MOVWF DATO1
    BTFSC CONTROL,1
    MOVWF DATO2
    BTFSC CONTROL,2
    MOVWF DATO3
    BTFSC CONTROL,3
    MOVWF DATO4
    BTFSC CONTROL,4
    CALL REINICIO
    RLF CONTROL, 1
    RETURN
REINICIO
    MOVLW .1
    MOVWF CONTROL
    RETURN
;--------------------------PRINCIPAL--------------------------------------------
MAIN_PROG   CODE
START
   CALL    CONFIG_IO
   CALL    CONFIG_RELOJ
   CALL    CONFIG_TMR0
   CALL    CONFIG_TMR2
   CALL    CONFIG_INTERRUPT
   CALL    CONFIG_RECEPCION
   MOVLW .15
   MOVWF DATO_PWM1
   MOVLW .30
   MOVWF DATO_PWM2
   MOVLW .40
   MOVWF DATO_PWM3
   MOVLW .50
   MOVWF DATO_PWM4
   CLRF DATO
   CLRF DATO
   CLRF DATO1
   CLRF DATO2
   CLRF DATO3
   CLRF DATO4
   MOVLW .1
   MOVWF CONTROL
;-------------------------LOOP PRINCIPAL----------------------------------------  
LOOP
   MOVLW .15
   MOVWF DATO1
   MOVLW .20
   MOVWF DATO2
   MOVLW .25
   MOVWF DATO3
   MOVLW .30
   MOVWF DATO4
   GOTO LOOP
;-------------------------SUBRUTINAS--------------------------------------------  
   
;-----------------------CONFIGURACIÃ?N-------------------------------------------
CONFIG_IO
   BANKSEL  TRISA ; PONEMOS COMO SALIDAS LOS PUERTOS
   CLRF    TRISA
   CLRF    TRISB
   CLRF    TRISC
   CLRF    TRISD
   CLRF    TRISE
   BSF TRISC, 7
   BANKSEL  ANSEL ; CONFIGURAR COMO DIGITAL
   CLRF    ANSEL
   CLRF    ANSELH
   BANKSEL  PORTA ; REINICIAS LOS PUERTOS
   CLRF    PORTA
   CLRF    PORTB
   CLRF    PORTC
   CLRF    PORTD
   CLRF    PORTE
   RETURN
CONFIG_RELOJ  
   BANKSEL OSCCON
   MOVLW B'01100001'
   MOVWF OSCCON
   RETURN
CONFIG_TMR0
   BANKSEL OPTION_REG
   BCF OPTION_REG, T0CS
   BSF OPTION_REG, PSA
   BCF OPTION_REG, PS2
   BCF OPTION_REG, PS1
   BCF OPTION_REG, PS0
   BANKSEL TMR0
   MOVLW .206
   MOVWF TMR0
   RETURN
CONFIG_TMR2
   BANKSEL  PORTA    
   MOVLW    B'11111111'    ; PRESCALER 1:16, POSTCALER 1:16, TMR2=ON
   MOVWF    T2CON
   BANKSEL  TRISA
   MOVLW    .78    ; VALOR DE COMPARACION Y CONTEO
   MOVWF    PR2
   BANKSEL  PORTA
   CLRF    TMR2    ; REINICIO DE TMR2, PRESCALER Y POSCALER
   BCF    PIR1, TMR2IF
   RETURN
CONFIG_INTERRUPT
   BANKSEL  PIE1
   BSF PIE1, TMR2IE
   BANKSEL  INTCON
   BSF INTCON, GIE    ; HABILITAMOS INTERRUPCIONES GLOBALES
   BSF INTCON, T0IE
   BSF INTCON, PEIE    ; HABILITAMOS INTERRUPCIONES PERIFERICAS
   BSF INTCON, PEIE
   BCF INTCON, T0IF
   BANKSEL PIR1
   BCF  PIR1, TMR2IF
   RETURN
CONFIG_RECEPCION
    BANKSEL TXSTA
    MOVLW B'00100100'
    MOVWF TXSTA
    MOVLW .25
    MOVWF SPBRG
    BSF PIE1, RCIE
    BCF STATUS, RP0
    MOVLW B'10010000'
    MOVWF RCSTA
    RETURN
    END