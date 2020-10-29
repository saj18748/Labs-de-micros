;  *****************************************************************************
;                                                                              *
;   Filaname:     lab -> Sumador 4 bits                                        *
;   Date          21/07/2020                                                   *
;   File version: v.1                                                          *
;   author :        Yefry Sajquiy - 18748                                      *
;   company;        UVG                                                        *
;   Description:   Incremente el pueto A, cada cierto retardo de tiempo.       *
;                                                                              *
;*******************************************************************************

#include "p16f887.inc"

; CONFIG1
; _config 0xF0F1
__CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
GPR_VAR	    UDATA 
	    CONT1 RES 1
	    CONT2 RES 1

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START
    CALL    CONFIG_IO
    BANKSEL PORTA
    CLRF    PORTA   ; 0 ENETRAD Y 1 SALIDA 

LOOP 
    INCF    PORTA	;INCREMETNA PORTA Y LO GUADAR EN PORTA
    CALL DELAY
    GOTO LOOP                         ; loop forever
    
DELAY_50MS
    MOVLW   .100
    MOVWF   CONT2
    CALL    DELLAY_500US
    DECFSZ  CONT2	;DECREMENTA CONT1
    GOTO    $-2		;IRA ALA POSICION DE PC - 2
RETURN
    
  
DELAY_500US
    MOVLW   .250
    MOVWF   CONT1
    DECFSZ  CONT1	;DECREMENTA CONT1
    GOTO    $-1		;IRA ALA POSICION DE PC - 1
RETURN
    
CONFIG_IO 
    
    BANKSEL TRISA
    CLRF    TRISA	; 0 ES DIGITAL, 1 ANALOGO
    BANKSEL ANSEL 
    CLRF    ANSEL	; 0 ES DIGITAL, 1 ANALOGO
    CLRF    ANSELH
RETURN
    

    END