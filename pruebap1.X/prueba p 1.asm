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
    WTEMP RES 1 ;Leds Oscilantes
    STATUSTEMP	 RES 1
    BANDERA	 RES 1
    DEC_DELAY RES 1 ;Delay
    DEC_DELAYLARGO RES 1
    CONT_DISPLAYS RES 1 ;Multiplexado
    MIN_UNIDADES RES 1 ;DisplayHora
    MIN_DECENAS RES 1
    HORA_UNIDADES RES 1
    HORA_DECENAS RES 1
    MEDIOSEGUNDO RES 1
    W_TEMPMINUTOSUNIDADES RES 1
    NUMEROINTERRUPCIONES    RES 1
 
 ;-----------Inicio de codigo ---------------------------------------------------
RES_VECT CODE 0x0000 ; processor reset vector
    GOTO SETUP ; go to beginning of program
; TODO ADD INTERRUPTS HERE IF USED
 
;---------Interrupciones -------------------------------------------------------
INTERRUPCIONES	 code 0x0004
	 
PUSH: ;Agrega un valor al stack
    MOVWF WTEMP ;Agrega mi variable temporal de W a F
    SWAPF STATUS,W ;Cambia los nibbles, para no afectar el status
    MOVWF STATUSTEMP ;Guarda el valor de el nuevo status en la ram
    
INTERRUPCION:
    BANKSEL INTCON
    BCF INTCON, T0IF ;Limpio la bandera del Timer 0 interrup flag
    BANKSEL TMR0
    MOVLW .240 ;Agrega el valor de .240 a W
    MOVWF TMR0 ;Lo mueve al Timer0
    DECFSZ NUMEROINTERRUPCIONES ;Si es 0 salta la linea
    GOTO POP
    MOVLW B'00000010' ;Le agrega la literal del pin 2 a W
    XORWF PORTD, F ;Guardo para oscilar
    BSF BANDERA,.0 ;Activo la bandera de que ya paso medio segundo
    MOVLW .122 ;Le seteo el valor a W, 14 interrupciones
    MOVWF NUMEROINTERRUPCIONES
 
POP:;Ultimo en entrar, primero en salir
    SWAPF STATUSTEMP,W ;Regresa los nibbles a su orden original
    MOVWF STATUS ;Pasa el valor al status
    SWAPF WTEMP, F ;Guarda el nuevo valor
    SWAPF WTEMP, W ;
RETFIE ;Regreso a la direccion antes del interrupt
    
    
    
;---------Tablas----------------------------------------------------------------
NUMEROS
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
    
;-------------------------------------------------------------------------------
MAIN_PROG CODE ; let linker place main program
;-------------------------------------------------------------------------------
;----------Setup----------------------------------------------------------------
SETUP
    CALL CONFIG_IO
    CALL CONFIG_TIMER0
    CALL CONFIG_OSCI
    CALL CONFIG_INTERRUPCIONES
    CALL HORA_INICIAL
    ;CALL UNMINUTO
    BANKSEL PORTA
    GOTO LOOP
    
    ;-----Loop----------------------------------------------------------------------
LOOP
    BTFSC BANDERA,.0 ;Testea bandera mediosegundo
    CALL MINUTOS_U
    ;CALL OSCILAR
    BTFSC BANDERA, .1 ;Testea la bandera de un minuto
    CALL MINUTOS_U
    CALL MULTIPLEXADO
    GOTO LOOP ; loop forever
   
OSCILAR ;Enciende y apaga el led
    BCF BANDERA,.0 ;Apaga bandera de mediosegundo
    DECFSZ MEDIOSEGUNDO ;Decrementa mediosegundo
    GOTO $+2 ;Si es 0 salta esta linea
    BSF BANDERA,.1 ;Llamar a un minuto (ha pasado 1 min)
RETURN
  
UNMINUTO
    MOVLW .20
    MOVWF MEDIOSEGUNDO
    ;BANKSEL PORTA
    ;MOVLW B'11111111' ;Le agrega la literal para encender el puertoA
    ;XORWF PORTA, F ;Enciende el puertoA
RETURN

MULTIPLEXADO ;Case para cambiar de display
    CALL DISPLAY_0 ;Display MIN_UNIDADES
    CALL DISPLAY_1 ;Display MIN_DECENAS
    CALL DISPLAY_2 ;Display HORA_UNIDADES
    CALL DISPLAY_3 ;Display HORA_DECENAS
RETURN
    
DISPLAY_0
    CLRF PORTE ;Apaga todos los display
    CLRF PORTC
    MOVFW MIN_UNIDADES
    CALL NUMEROS ;Llama a mi tabla
    BANKSEL PORTA
    MOVWF PORTA ;Lo que regresa se va al portA, solo al D
    BSF PORTE, .0 ;Encendiende el correspondiente
    CALL DELAY_LARGO
    BCF PORTE, .0
    RETURN
    
DISPLAY_1
    CLRF PORTE
    CLRF PORTC
    MOVFW MIN_DECENAS
    CALL NUMEROS ;Llama a numeros
    BANKSEL PORTA
    MOVWF PORTA
    BSF PORTE, .1
    CALL DELAY_LARGO
    BCF PORTE, .1
RETURN
    
DISPLAY_2
    CLRF PORTC
    CLRF PORTE
    MOVFW HORA_UNIDADES
    CALL NUMEROS ;Llama a numeros
    BANKSEL PORTA
    MOVWF PORTA
    BSF PORTC, .1
    CALL DELAY_LARGO
    BCF PORTC, .1
RETURN
    
DISPLAY_3
    CLRF PORTC
    CLRF PORTE
    MOVFW HORA_DECENAS
    CALL NUMEROS ;Llama a numeros
    BANKSEL PORTA
    MOVWF PORTA
    BSF PORTC, .0
    CALL DELAY_LARGO
    BCF PORTC, .0
RETURN
    
;-----Otros subregistros--------------------------------------------------------
MINUTOS_U
    BCF BANDERA, .0 ;Apago bandera de 1 minuto
    INCF MIN_UNIDADES,1 ;Aumento las unidades de minutos
    BCF STATUS,.2 ;Limpia el status
    MOVFW MIN_UNIDADES ;Mueve Min unidades a W
    SUBLW .10 ;Le resto 10 a W y comparo si es 0
    BTFSC STATUS,.2 ;Si la resta NO es 0 salta la linea
    CALL MINUTOS_D ;Si SI es 0 llama a minutos decenas por overflow
RETURN
    
MINUTOS_D
    MOVLW B'00000000'
    MOVWF MIN_UNIDADES
    INCF MIN_DECENAS,1 ;Aumento las unidades de minutos
    BCF STATUS,.2 ;Limpia el status
    MOVFW MIN_DECENAS ;Mueve Min unidades a W
    SUBLW .6 ;Le resto 10 a W y comparo si es 0
    BTFSC STATUS,.2 ;Si la resta NO es 0 salta la linea
    CALL HORAS_U
RETURN
    
HORAS_U
    MOVLW B'00000000'
    MOVWF MIN_UNIDADES
    MOVWF MIN_DECENAS
    INCF HORA_UNIDADES,1 ;Aumento las unidades de minutos
    BCF STATUS,.2 ;Limpia el status
    MOVFW HORA_UNIDADES ;Mueve Min unidades a W
    SUBLW .10 ;Le resto 10 a W y comparo si es 0
    BTFSC STATUS,.2 ;Si la resta NO es 0 salta la linea
    CALL HORAS_D
RETURN
 
HORAS_D
    MOVLW B'00000000'
    MOVWF MIN_UNIDADES
    MOVWF MIN_DECENAS
    MOVWF HORA_UNIDADES
    INCF HORA_DECENAS,1 ;Aumento las unidades de minutos
    BCF STATUS,.2 ;Limpia el status
    MOVFW HORA_DECENAS ;Mueve Min unidades a W
    SUBLW .3 ;Le resto 10 a W y comparo si es 0
    BTFSC STATUS,.2 ;Si la resta NO es 0 salta la linea
    CLRF HORA_DECENAS
    BCF STATUS,.2
    MOVFW HORA_DECENAS
    SUBLW .2 ; STATUS ES CERO SI LA RESTA ES DISTINTA DE 0 Y ES 1 SI LA
    BTFSC STATUS,.2 ;Si el status es 0 salta la linea
    CALL REVISIONHORAS ;REVISA SI LLEGO A 24 HORAS
RETURN
    
REVISIONHORAS
    BCF STATUS,.2
    MOVFW HORA_UNIDADES ;REVISA SI HORAS UNIDADES ESTA EN 4, YA QUE HORAS DECENAS ESTA EN 2
    SUBLW .4 ; STATUS ES CERO SI LA RESTA ES DISTINTA DE 0 Y ES 1 SI LA RESTA ES 0
    BTFSC STATUS,.2 ;Si el status es 0 salta la linea
    CALL DAYS_U ;SI LLEGA A 24 HORAS SE LLAMAS DAYS_U PARA AUMENTAR UN DIA
RETURN
    
DAYS_U
    MOVLW B'00000000'
    MOVWF MIN_UNIDADES
    MOVWF MIN_DECENAS
    MOVWF HORA_UNIDADES
    MOVWF HORA_DECENAS
RETURN
    
;------Configuraciones----------------------------------------------------------
CONFIG_IO
    BANKSEL ANSELH
    CLRF ANSELH
    CLRF ANSEL
    BANKSEL TRISA
    CLRF TRISA
    CLRF TRISC
    CLRF TRISD
    CLRF TRISE
    MOVLW B'11111000' ;Configurar esos pines como entradas (botones)
    MOVWF TRISB
    BANKSEL PORTA
    CLRF PORTA
    CLRF PORTC
    CLRF PORTD
    CLRF MIN_UNIDADES
    CLRF MIN_DECENAS
    CLRF HORA_UNIDADES
    CLRF HORA_DECENAS
    CLRF MEDIOSEGUNDO
RETURN
    
HORA_INICIAL
    MOVLW .5
    MOVWF MIN_UNIDADES
    MOVLW .4
    MOVWF MIN_DECENAS
    MOVLW .3
    MOVWF HORA_UNIDADES
    MOVLW .1
    MOVWF HORA_DECENAS
RETURN
    
CONFIG_OSCI
    BANKSEL OSCCON
    MOVLW B'01100001' ;Frecuencia default de 4MHz
    MOVWF OSCCON
RETURN
    
CONFIG_TIMER0
    BANKSEL OPTION_REG
    BCF OPTION_REG, T0CS ;Reloj interno
    BCF OPTION_REG, PSA ;Asigno el Prescaler al timer 0
    BSF OPTION_REG, PS2 ;Prescaler en 256
    BSF OPTION_REG, PS1
    BSF OPTION_REG, PS0
    BANKSEL TMR0
    MOVLW .240 ;Agrego inicialmente un valor al timer0
    MOVWF TMR0
    BCF INTCON, T0IF
    MOVLW .122 ;Numero de interrupciones calculado
    MOVWF NUMEROINTERRUPCIONES
    MOVLW .20 ;Setear que medio segundo sea 120 oscilaciones
    MOVWF MEDIOSEGUNDO
    ;MOVLW .0
    ;MOVWF MIN_UNIDADES
    MOVLW .0
    MOVWF W_TEMPMINUTOSUNIDADES
RETURN
    
    
CONFIG_INTERRUPCIONES
    BSF INTCON,T0IE ;Activo las interrupciones
    BCF INTCON,T0IF ;Limpia la bandera por precaución
    BSF INTCON,GIE ;Activa todas las interrupciones
RETURN
    
;-------DELAY-------------------------------------------------------------------
DELAY
    MOVLW .255
    MOVWF DEC_DELAY
    DECFSZ DEC_DELAY
    GOTO $-1
RETURN
    
DELAY_LARGO
    MOVLW .255
    MOVWF DEC_DELAYLARGO
    GOTO DELAY
    DECFSZ DEC_DELAYLARGO
    GOTO $-2
RETURN
;-------FIN DEL PROGRAMA--------------------------------------------------------
END
    
    
    