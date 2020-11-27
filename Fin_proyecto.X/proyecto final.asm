;******************************************************************************
;                                                                             *
;     Filaname:     Proyecto final                                            *
;     Date         26 /11/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   proyeceto de apliacion de modulos                        *
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
   SUMA_1	RES 1
   SUMA_2	RES 1	    ; VARIABLES DE DATOS
	
;--------------------------- INICIO DEL PROGRAMA -------------------------------
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
;-------------------------------------------------------------------------------
    
;--------------------------------- PRINCIPAL -----------------------------------
MAIN_PROG CODE                      ; let linker place main program3
START
    CALL    CONFIG_IO		; PUERTOS Y PINES COMO SALIDAS
    CALL    CONFIG_RELOJ	; 4 MHz
    CALL    CONFIG_TIMER2	; CONFIGURACIÓN DEL TIMER2 PARA LOS SERVOS
    CALL    CONFIG_CCP		; CCP1 Y CCP2
    CALL    CONFIG_TMR0
    CALL    CONFIG_INTERRUPT
    CALL    CONFIG_EUSART
    GOTO    LOOP		
;-------------------------------------------------------------------------------

;------------------------------- LOOP PRINCIPAL --------------------------------
LOOP
    CALL    CONFIG_ADC_DI
    CALL    MOV_SERVOS
    
    CALL    CONFIG_READ
    
    BTFSC   PORTC, RC0
    GOTO    CONFIG_WRITE

    
    GOTO    LOOP
;-------------------------------------------------------------------------------
    
CONFIG_ADC_DI:
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
    MOVWF   SUMA_1		; MUEVO EL ADRESH A SUMADOR2
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
    MOVWF   SUMA_2		; MUEVO EL ADRESH A SUMADOR1
    
MOV_SERVOS:
    ; MUEVO LA VARIABLE SERVO1 A CCPR1L
    MOVF    SUMA_1, W
    MOVWF   CCPR1L
    CALL    DELAY_10MS
    
    ; MUEVO LA VARIABLE SERVO2 A CCPR2L
    MOVF    SUMA_2, W
    MOVWF   CCPR2L     
    CALL    DELAY_10MS
    
CONFIG_READ:
   
    BSF	    PORTC, RC5
    BCF	    STATUS, RP0
    BSF	    STATUS, RP1
    
    MOVF    SUMA_1,W
    MOVWF   EEADR
    BSF	    STATUS, RP0
    BCF	    EECON1, EEPGD
    BSF	    EECON1, RD
    BCF	    STATUS, RP0
    MOVF    EEDATA, W
    
    BCF	    STATUS, RP1
    
    MOVWF   PORTD

   RETURN
   
CONFIG_WRITE:
    CALL    DELAY_1
    
  
    BANKSEL EEADR
    
    BSF	    STATUS, RP0
    BSF	    STATUS, RP1
    BTFSC   EECON1, WR
    GOTO    $-1
    
    BCF	    STATUS, RP0
    MOVF    SUMA_1, W
    MOVWF   EEADR
    BCF	    STATUS, RP1
    MOVF    SUMA_1, W
    BSF	    STATUS, RP1
    MOVWF   EEDATA
    BSF	    STATUS, RP0
    BCF	    EECON1, EEPGD
    BSF	    EECON1, WREN
    
    MOVLW   55h		;
    MOVWF   EECON2	;Write 55h
    MOVLW   0xAA ;
    MOVWF   EECON2	;Write AAh
    
    BSF	    EECON1, WR	;Set WR bit to begin write
    BSF	    INTCON, GIE
    BCF	    EECON1, WREN	;Disable writes
    BCF	    STATUS, RP0	;Bank 0
    BCF	    STATUS, RP1
    
    
    GOTO    LOOP
;--------------------------------- SUBRUTINAS ----------------------------------
DELAY_10MS:			; 10 us DE DELAY
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
    
CONFIG_ADC1:
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
    
CONFIG_ADC2:
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
    
CONFIG_ADC3:
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
CONFIG_IO:
    
    BANKSEL ANSEL
    CLRF    ANSEL
    COMF    ANSEL		; ESPECIFICAMOS QUE USAREMOS ANSEL
    BANKSEL TRISA
    CLRF    TRISA
    COMF    TRISA		; ACTIVAOS EL PUERTO DE NUESTROS POTENCIOMETROS
    CLRF    TRISC		; PORTC COMO SALIDA DE LOS SERVOS
    BANKSEL PORTA
    CLRF    PORTA		; VACIAMOS LOS PUERTOS A USAR
    BANKSEL SUMA_1
    CLRF    SUMA_1
    CLRF    SUMA_2
    
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

CONFIG_RELOJ:
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
    
CONFIG_TIMER2:
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
    
CONFIG_CCP:
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
    
CONFIG_EUSART:
   BANKSEL  TXSTA
   BCF	    TXSTA,	SYNC	;MODO ASINCRÓNO
   BSF	    TXSTA,	TXEN	;HABILITO LA COMUNICACIÓN
   BCF	    TXSTA,	BRGH	;BAUDRATE
   
   ;BAUDRATE 9600
   BSF	    BAUDCTL,	BRG16	;BAUDRATE
   MOVLW    .25			;BAUDRATE
   MOVWF    SPBRG		;BAUDRATE
   
   BANKSEL  RCSTA
   BSF	    RCSTA,	SPEN	;HABILITO EL MÓDULO TX COMO SALIDA 

   BANKSEL  BAUDCTL
   BSF	    BAUDCTL,	BRG16	;BAUDRATE
 
   ;BANKSEL  PIE1
   ;BSF	    PIE1,	TXIE
   RETURN 
;-------------------------------------------------------------------------------
    
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
    
    
    
    