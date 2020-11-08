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

#include "p16f887.inc"

; CONFIG1
; __config 0xE0F5
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
GPR_VAR	UDATA
   SUMADOR1	RES 1
   SUMADOR2	RES 1	    ; VARIABLES DE DATOS
	
;--------------------------- INICIO DEL PROGRAMA -------------------------------
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
;-------------------------------------------------------------------------------
    
;--------------------------------- PRINCIPAL -----------------------------------
MAIN_PROG CODE                      ; let linker place main program
START
    CALL    CONFIG_IO		; PUERTOS Y PINES COMO SALIDAS
    CALL    CONFIG_RELOJ	; 4 MHz
    CALL    CONFIG_TIMER2	; CONFIGURACIÓN DEL TIMER2 PARA LOS SERVOS
    CALL    CONFIG_CCP		; CCP1 Y CCP2
    GOTO    LOOP		
;-------------------------------------------------------------------------------

;------------------------------- LOOP PRINCIPAL --------------------------------
LOOP
ADC_DIGITAL:
    ; CONVERSION PUERTO A0
    MOVLW   B'11000001'		; ADC Frc CLOCK
    MOVWF   ADCON0		; AN0, ON  
    CALL    DELAY_10MS
    CALL    CONFIG_ADC1
    CALL    DELAY_10MS
    BSF	    ADCON0, GO		; EMPIEZA LA CONVERSION
    BTFSC   ADCON0, GO		; REVISA SI TERMINO LA CONVERSION
    GOTO    $-1
    BCF	    PIR1, ADIF		; BORRAMOS LA BANDERA DEL ADC 
    MOVF    ADRESH, W
    MOVWF   SUMADOR1		; MUEVO EL ADRESH A SUMADOR2
    MOVWF   PORTB
    
    ; CONVERSION PUERTO A1
    MOVLW   B'11000101'		; ADC Frc CLOCK
    MOVWF   ADCON0		; AN0, ON  
    CALL    DELAY_10MS
    CALL    CONFIG_ADC2
    CALL    DELAY_10MS
    BSF	    ADCON0, GO		; EMPIEZA LA CONVERSION
    BTFSC   ADCON0, GO		; REVISA SI TERMINO LA CONVERSION
    GOTO    $-1
    BCF	    PIR1, ADIF		; BORRAMOS LA BANDERA DEL ADC 
    MOVF    ADRESH, W
    MOVWF   SUMADOR2		; MUEVO EL ADRESH A SUMADOR1
    MOVWF   PORTD
    
PASO_SERVOS:
    ; MUEVO LA VARIABLE SERVO1 A CCPR1L
    MOVF    SUMADOR1, W
    MOVWF   CCPR1L
    CALL    DELAY_10MS
    
    ; MUEVO LA VARIABLE SERVO2 A CCPR2L
    MOVF    SUMADOR2, W
    MOVWF   CCPR2L     
    CALL    DELAY_10MS
    
    GOTO    LOOP
;-------------------------------------------------------------------------------
    
;--------------------------------- SUBRUTINAS ----------------------------------
DELAY_10MS			; 10 us DE DELAY
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
    
CONFIG_ADC1
    BANKSEL ADCON1
    MOVLW   B'00000000'		; JUSTIFICADO A LA DERECHA, Vref en VDD y VSS
    MOVWF   ADCON1
    BANKSEL ADCON0
    BSF	    ADCON0, ADCS0
    BCF	    ADCON0, ADCS1	; ADCS -> Fosc/8
    BCF	    ADCON0, CHS0 
    BCF	    ADCON0, CHS1
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3	; CHS  -> CHANNEL 0
    BCF	    ADCON0, GO
    BSF	    ADCON0, ADON	; ADON -> 1 (ADC ACTIVADO)
    RETURN
    
CONFIG_ADC2
    BANKSEL ADCON1
    MOVLW   B'00000000'		; JUSTIFICADO A LA DERECHA, Vref en VDD y VSS
    MOVWF   ADCON1
    BANKSEL ADCON0
    BSF	    ADCON0, ADCS0
    BCF	    ADCON0, ADCS1	; ADCS -> Fosc/8
    BSF	    ADCON0, CHS0 
    BCF	    ADCON0, CHS1
    BCF	    ADCON0, CHS2
    BCF	    ADCON0, CHS3	; CHS  -> CHANNEL 1
    BCF	    ADCON0, GO
    BSF	    ADCON0, ADON	; ADON -> 1 (ADC ACTIVADO)
    RETURN
;-------------------------------------------------------------------------------
    
;------------------------------- CONFIGURACIONES -------------------------------
CONFIG_IO
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL		; ESPECIFICAMOS QUE USAREMOS ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA		; ACTIVAOS EL PUERTO DE NUESTROS POTENCIOMETROS
    CLRF    TRISC		; PORTC COMO SALIDA DE LOS SERVOS
    BANKSEL PORTA
    CLRF    PORTA		; VACIAMOS LOS PUERTOS A USAR
    BANKSEL SUMADOR1
    CLRF    SUMADOR1
    CLRF    SUMADOR2
    
    BANKSEL TRISB
    MOVLW   B'00000000'
    MOVWF   TRISB
    BANKSEL PORTB
    CLRF    PORTB
    
    BANKSEL TRISD
    MOVLW   B'00000000'
    MOVWF   TRISD
    BANKSEL PORTD
    CLRF    PORTD
    RETURN

CONFIG_RELOJ
    ; PROGRAMAMOS EL OSCILADOR
    BCF	    STATUS, RP1
    BSF	    STATUS, RP0		; Banco 1
    BCF	    OSCCON, IRCF0
    BSF	    OSCCON, IRCF1
    BSF	    OSCCON, IRCF2	; OSCILACON 4 MHz
    BCF	    OSCCON, OSTS
    BCF	    OSCCON, HTS
    BCF	    OSCCON, LTS
    BSF	    OSCCON, SCS		; USAMOS NUESTRO OSCILADOR COMO SISTEMA DE RELOJ
    MOVLW   B'00000000'		; JUSTIFICACION HACIA LA IZQUIERDA
    MOVWF   ADCON1
    RETURN
    
CONFIG_TIMER2
    BCF	    STATUS, RP1
    BCF	    STATUS, RP0		; BANCO 0
    MOVLW   B'11000001'		; ADC Frc CLOCK
    MOVWF   ADCON0		; AN0, ON
    BSF	    T2CON, TMR2ON	; TIMER2 ON BIT
    BSF	    T2CON, T2CKPS0
    BSF	    T2CON, T2CKPS1	;PRESCALER DE 16 
    
    BSF	    STATUS, RP1  
    BSF	    STATUS, RP0		; BANCO 1
    MOVLW   .155		; CARGO EL VALOR 155 A PR2
    MOVWF   PR2
    RETURN
    
CONFIG_CCP
    BCF	    STATUS, RP1
    BCF	    STATUS, RP0		; BANCO 0

    ; CONFIGURACION DE CCP1
    MOVLW   B'00001100'
    MOVWF   CCP1CON

    ; CONFIGURACION DE CCP2
    MOVLW   B'00001111'
    MOVWF   CCP2CON

    ; LIMPIO EL PUERTO C
    CLRF    PORTC
    RETURN
;-------------------------------------------------------------------------------
    
    END
    
    