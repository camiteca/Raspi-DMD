.globl SetupGpio
SetupGpio:
    push {lr}
    
    mov r0, #11
    mov r1, #0
    bl SetGpioFunction

    mov r0, #13
    mov r1, #0
    bl SetGpioFunction

    mov r0, #15
    mov r1, #0
    bl SetGpioFunction

    mov r0, #19
    mov r1, #0
    bl SetGpioFunction

    mov r0, #21
    mov r1, #0
    bl SetGpioFunction

    mov r0, #23
    mov r1, #0
    bl SetGpioFunction
    
    mov pc, lr
