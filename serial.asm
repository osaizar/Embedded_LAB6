SECTION	.data
EXTERN	inbound_queue	; (defined in main.C)
data		DB	0		; put rcvd byte here

SECTION	.text
ALIGN	16
BITS	32

BASE_PORT	EQU	3F8h		; we have this in our lab

LSR_PORT	EQU	BASE_PORT+5
RBR_PORT	EQU	BASE_PORT
THR_PORT	EQU	BASE_PORT


; ---------------------------------------------------------------------
; void SerialPut(char ch)
; ---------------------------------------------------------------------
; This function uses programmed waiting loop I/O
; to output the ASCII character 'ch' to the UART.

GLOBAL	SerialPut

SerialPut:

; (1) Wait for THRE = 1
enable:
MOV DX, LSR_PORT
IN AL, DX
TEST AX, 0x20
JZ enable

; (2) Output character to UART
MOV DX, THR_PORT
MOV AL, [ESP + 4]
OUT DX, AL

; (3) Return to caller
RET


; ---------------------------------------------------------------------
; void interrupt SerialISR(void)
; ---------------------------------------------------------------------
; This is an Interrupt Service Routine (ISR) for
; serial receive interrupts.  Characters received
; are placed in a queue by calling Enqueue(char).

GLOBAL	SerialISR
EXTERN	QueueInsert	; (provided by LIBPC)

SerialISR:	STI             	; Enable (higher-priority) IRQs

; (1) Preserve all registers
PUSHA

; look if RBF is 1
MOV DX, LSR_PORT
IN AL, DX

TEST AX, 0x01
JZ _Eoi

; (2) Get character from UART
MOV DX, RBR_PORT
IN AL, DX

; (3) Put character into queue
MOV [data], AL ; write to queue

; Param #2: address of data
PUSH data

; Param #1: address of queue
PUSH DWORD [inbound_queue]

CALL	QueueInsert
ADD	ESP,8


_Eoi:
; (4) Enable lower priority interrupts
MOV AL, 0x20
OUT 0x20, AL
; <your code here>	;       (Send Non-Specific EOI to PIC)
; <your code here>	; (5) Restore all registers
POPA
; <your code here>	; (6) Return to interrupted code
RET
