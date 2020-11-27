;******************************************************************************
;                                                                             *
;     Filaname:     lab -> laboratorio 9.asm                                  *
;     Date         25 /08/2020                                                *
;     File version: v.2                                                       *
;     author :       Yefry Sajquiy - 18748                                    *
;     ompany;        UVG                                                      *
;     Description:   memoria EEPROM                                            *
;                                                                              *
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
   

    W_TEMP	RES 1
    STATUS_TEMP	RES 1 
    TEMP1	RES 1
    TEMP2	RES 1
	
    NUMERO	    RES 1

;----------------------------------- MACRO -------------------------------------
	    
DEBOUNCE MACRO PORT, PIN    ;MACRO PARA ANTIREBOTE 
    CALL   DELAY_1	
    BTFSC  PORT, PIN
    GOTO   $-1		 
ENDM
	
 RES_VECT  CODE    0x0000           
 GOTO   START  

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
    
    CALL    ADC_INICIO
    CALL    CONFIG_READ
    
    BTFSC   PORTC, RC0
    GOTO    CONFIG_WRITE
    
    GOTO    LOOP   

;------------------------- OPERACIONES DE LOS BLOQUES -------------------------
 
ADC_INICIO:
    CALL    DELAY_1
    BSF	    ADCON0,GO	
    BTFSC   ADCON0,GO
    GOTO    $-1
    
    MOVF    ADRESH,W
    MOVWF   PORTB
    MOVWF   NUMERO
    RETURN
    
CONFIG_WRITE:
    CALL    DELAY_1
    
    BSF	    PORTC, RC4
    
    BANKSEL EEADR
    
    BSF	    STATUS, RP0
    BSF	    STATUS, RP1
    BTFSC   EECON1, WR
    GOTO    $-1
    
    BCF	    STATUS, RP0
    MOVF    NUMERO, W
    MOVWF   EEADR
    BCF	    STATUS, RP1
    MOVF    NUMERO, W
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
    
    BCF	    PORTC, RC4
    
    GOTO    LOOP

   
CONFIG_READ:
   
    BSF	    PORTC, RC5
    BCF	    STATUS, RP0
    BSF	    STATUS, RP1
    
    MOVF    NUMERO,W
    MOVWF   EEADR
    BSF	    STATUS, RP0
    BCF	    EECON1, EEPGD
    BSF	    EECON1, RD
    BCF	    STATUS, RP0
    MOVF    EEDATA, W
    
    BCF	    STATUS, RP1
    
    MOVWF   PORTD

   RETURN
    
; ------------- CONFIGURACION IO --------------------------------------------
  
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
    MOVLW   B'00000001'
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
    