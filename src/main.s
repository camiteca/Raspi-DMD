.section .init
.globl _start
_start:

b Main

.section .text
.globl Main
Main:

    // set the stack point to 0x8000.
    mov sp, #0x8000

    @ // enable read mode in the GPIO
    bl SetupGpio

    // enable frame buffer
	mov r0, #128
	mov r1, #32
	mov r2, #16
	bl InitialiseFrameBuffer
	bl SetGraphicsAddress
	
	bl CaptureDMD
	