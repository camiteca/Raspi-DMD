.section .text

.equ GPEDS0,0x20200040
.equ GPEDS1,0x20200044

.equ GPHEN0, 0x20200064
.equ GPHEN1, 0x20200068

.equ GPREN0, 0x2020004c
.equ GPREN1, 0x20200050

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

    rowDataPinMask .req r9
    ldr rowDataPinMask, =ROWDATAPIN

    waitRowDataPinHigh$:
    ldr pinLevels, [pinLevelAddress]
    tst pinLevels, rowDataPinMask
    bne waitRowDataPinHigh$

    .unreq rowDataPinMask

    mov rowCounter, #1
    
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
    movne r4, #0
    bne waitNextPixel$

    tst r4, #1
    bne waitNextPixel$

    // mark the clock witness
    mov r4, #1
    
    tst pinLevels, serialDataPinMask
    ldrne r0, =0xE140
    ldreq r0, =0x0000
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
