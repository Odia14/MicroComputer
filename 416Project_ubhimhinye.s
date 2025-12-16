        .text
        .global _start


@ EECE416 Project: BCD Decimal Down Counter with VGA Output


@DE1-SoC I/O Base Addresses
.equ SW_BASE,           0xFF200040      @ Switches SW9..SW0
.equ HEX3_HEX0_BASE,    0xFF200020      @ HEX3-HEX0 7-seg displays
.equ PIXEL_BASE,        0xC8000000      @ VGA pixel buffer (background)
.equ CHAR_BASE,         0xC9000000      @ VGA character buffer

@VGA Character Display Attribute (foreground/background colours)
.equ VGA_ATTR_COLOR,    0x72  @ White fg (7), green bg (2)


@RESET / ENTRY

_start:
        @Fill VGA background with ID-based colour (extra credit)
        BL      fill_background

        @Load base addresses
        LDR     R8, =seg_patterns       @ 7-segment patterns
        LDR     R9, =SW_BASE            @ switches
        LDR     R10,=HEX3_HEX0_BASE     @ HEX3-HEX0

        @Read SW7-SW0 once and decode to BCD digits
        @R7:R6:R5:R4 = th:hund:tens:ones
        LDR     R0, [R9]                @ read switches

        AND     R4, R0, #0x3            @ ones   = SW1..SW0
        LSR     R1, R0, #2
        AND     R5, R1, #0x3            @ tens   = SW3..SW2
        LSR     R1, R0, #4
        AND     R6, R1, #0x3            @ hund   = SW5..SW4
        LSR     R1, R0, #6
        AND     R7, R1, #0x3            @ thous  = SW7..SW6

@ MAIN LOOP – display, pause, delay, decrement

main_loop:
        @Stop when the number reaches 0000 (still displayed)
        MOV     R0, R4
        ORR     R0, R0, R5
        ORR     R0, R0, R6
        ORR     R0, R0, R7
        CMP     R0, #0
        BEQ     end_program

        @Update HEX 7-segment displays
        BL      display_digits

        @Update VGA character display (extra credit)
        BL      display_vga_digits

@Pause while SW9 is high
pause_check:
        LDR     R0, [R9]                @ read switches
        LSR     R1, R0, #9              @ isolate SW9
        AND     R1, R1, #1
        CMP     R1, #1
        BEQ     pause_check             @ stay paused if SW9 = 1

        @Delay between decrements
        BL      delay

        @Decimal decrement with borrow
        BL      dec_bcd

        B       main_loop

@ display_digits
@R7:R6:R5:R4  -> HEX3:HEX2:HEX1:HEX0 (via seg_patterns)
display_digits:
        PUSH    {R0-R3, R11, LR}

        @ HEX0 = ones
        MOV     R11, R4
        LDRB    R0, [R8, R11]

        @ HEX1 = tens
        MOV     R11, R5
        LDRB    R1, [R8, R11]

        @ HEX2 = hundreds
        MOV     R11, R6
        LDRB    R2, [R8, R11]

        @ HEX3 = thousands
        MOV     R11, R7
        LDRB    R3, [R8, R11]

        @ Pack [HEX3][HEX2][HEX1][HEX0] into R12
        MOV     R12, R3
        LSL     R12, R12, #8
        ORR     R12, R12, R2
        LSL     R12, R12, #8
        ORR     R12, R12, R1
        LSL     R12, R12, #8
        ORR     R12, R12, R0

        STR     R12, [R10]              @ write to HEX3-HEX0

        POP     {R0-R3, R11, PC}


@ display_vga_digits
@ Prints digits at (x=40..43, y=50) on VGA character buffer
@ CHAR_BASE layout: 80 columns x 60 rows, 2 bytes per cell
@ [char][attribute]
display_vga_digits:
        PUSH    {R0-R3, R11, LR}

        LDR     R11, =CHAR_BASE
        LDR     R3,  =VGA_ATTR_COLOR

        @ Compute byte address = CHAR_BASE + (y*80 + x)*2
        MOV     R0, #50                 @ y position
        MOV     R1, R0                  @ R1 = y
        LSL     R1, R1, #6              @ y * 64
        MOV     R2, R0
        LSL     R2, R2, #4              @ y * 16
        ADD     R1, R1, R2              @ y*80 = y*64 + y*16

        MOV     R0, #40                 @ x position
        ADD     R1, R1, R0              @ cell index
        LSL     R1, R1, #1              @ *2 (bytes per cell)
        ADD     R1, R1, R11             @ absolute address

        @ Thousands digit (R7)
        MOV     R2, R7
        ADD     R2, R2, #0x30           @ to ASCII
        STRB    R2, [R1]                @ char
        STRB    R3, [R1, #1]            @ attribute
        ADD     R1, R1, #2              @ next cell

        @ Hundreds digit (R6)
        MOV     R2, R6
        ADD     R2, R2, #0x30
        STRB    R2, [R1]
        STRB    R3, [R1, #1]
        ADD     R1, R1, #2

        @ Tens digit (R5)
        MOV     R2, R5
        ADD     R2, R2, #0x30
        STRB    R2, [R1]
        STRB    R3, [R1, #1]
        ADD     R1, R1, #2

        @ Ones digit (R4)
        MOV     R2, R4
        ADD     R2, R2, #0x30
        STRB    R2, [R1]
        STRB    R3, [R1, #1]

        POP     {R0-R3, R11, PC}

@ dec_bcd
@   Decimal decrement with borrow on R7:R6:R5:R4
dec_bcd:
        @ Ones
        CMP     R4, #0
        BGT     dec_ones_only
        MOV     R4, #9

        @ Tens
        CMP     R5, #0
        BGT     dec_tens_only
        MOV     R5, #9

        @ Hundreds
        CMP     R6, #0
        BGT     dec_hundreds_only
        MOV     R6, #9

        @ Thousands
        CMP     R7, #0
        BGT     dec_thousands_only
        BX      LR

dec_thousands_only:
        SUB     R7, R7, #1
        BX      LR

dec_hundreds_only:
        SUB     R6, R6, #1
        BX      LR

dec_tens_only:
        SUB     R5, R5, #1
        BX      LR

dec_ones_only:
        SUB     R4, R4, #1
        BX      LR

@==========================================================
@ delay – simple software delay loop (no SUBS)
@==========================================================
delay:
        PUSH    {R0, LR}
        LDR     R0, =0x10000

delay_loop:
        SUB     R0, R0, #1
        CMP     R0, #0
        BNE     delay_loop

        POP     {R0, PC}

@ fill_background – fill 320x240 VGA pixel buffer
@   with colour based on last 4 digits of Howard ID (2402)
fill_background:
        PUSH    {R0-R6, LR}

        LDR     R5, =PIXEL_BASE
        LDR     R6, =BACKGROUND_COLOR
        LDRH    R6, [R6]               @ 16-bit colour

        MOV     R0, #0                 @ y = 0
fb_row_loop:
        CMP     R0, #240
        BGE     fb_done

        MOV     R1, R0
        LSL     R1, R1, #10            @ y * 1024 (row offset)
        MOV     R2, #0                 @ x = 0

fb_col_loop:
        CMP     R2, #320
        BGE     fb_next_row

        MOV     R3, R2
        LSL     R3, R3, #1             @ x * 2 (16-bit pixel)

        ADD     R4, R5, R1             @ base + row
        ADD     R4, R4, R3             @ + column

        STRH    R6, [R4]               @ store pixel

        ADD     R2, R2, #1
        B       fb_col_loop

fb_next_row:
        ADD     R0, R0, #1
        B       fb_row_loop

fb_done:
        POP     {R0-R6, PC}

@ END – lock CPU in place once count reaches 0000
end_program:
        B       end_program

@ DATA SECTION
        .data
        .align 2

@ 7-segment encoding for digits 0-9 (common-cathode style)
@ bits: DP G F E D C B A  (DP unused here)
seg_patterns:
        .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F
@           0    1    2    3    4    5    6    7    8    9

@ Background colour from last four digits of Howard ID: 2402
BACKGROUND_COLOR:
        .hword 0x2402
