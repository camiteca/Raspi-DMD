.section .text

.equ GPLEV0,0x20200034

.equ ROWDATAPIN, 0x800
.equ ROWCLOCKPIN, 0x200

.equ DOTCLOCKPIN, 0x400000
.equ SERIALDATAPIN, 0x8000000

.equ COLUMNLATCHPIN, 0x400

.globl CaptureDMD
CaptureDMD:

    pinLevels .req r5
    pinLevelAddress .req r6
    ldr pinLevelAddress, =GPLEV0

    // counters
    pixelCounter .req r7
    rowCounter .req r8

    waitNextFrame$:

    // initialize row counter
    mov rowCounter, #1

    // wait for row data pin high (frame start)
    rowDataPinMask .req r9
    ldr rowDataPinMask, =ROWDATAPIN
    waitRowDataPinHigh$:
        ldr pinLevels, [pinLevelAddress]
        tst pinLevels, rowDataPinMask
        bne waitRowDataPinHigh$
    .unreq rowDataPinMask
    
    waitNextLine$:

    columnLatchPinMask .req r9
    ldr columnLatchPinMask, =COLUMNLATCHPIN

    waitColumnLatchLow$:
    ldr pinLevels, [pinLevelAddress]
    tst pinLevels, columnLatchPinMask
    beq waitColumnLatchLow$

    .unreq columnLatchPinMask

    teq rowCounter, #32
    beq waitNextFrame$

    mov pixelCounter, #1

    dotClockPinMask .req r9
    ldr dotClockPinMask, =DOTCLOCKPIN

    serialDataPinMask .req r10
    ldr serialDataPinMask, =SERIALDATAPIN

    waitNextPixel$:

    ldr pinLevels, [pinLevelAddress]
    tst pinLevels, dotClockPinMask
    moveq r4, #0
    beq waitNextPixel$

    tst r4, #1
    bne waitNextPixel$

    // mark the clock witness
    mov r4, #1
    
    tst pinLevels, serialDataPinMask
    ldrne r0, =0xE140
    moveq r0, #0
    bl SetForeColor

    mov r0, pixelCounter
    mov r1, rowCounter
    bl DrawPixel

    add pixelCounter, #1
    teq pixelCounter, #128
    bne waitNextPixel$

    addeq rowCounter, #1
    beq waitNextLine$

    .unreq serialDataPinMask
    .unreq pinLevels
    .unreq pinLevelAddress
    .unreq pixelCounter
    .unreq rowCounter

    mov pc, lr
