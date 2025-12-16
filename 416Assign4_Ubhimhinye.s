@ --- EQUATES (Memory-Mapped I/O Addresses for CPUlator) ---
.equ LED_PORT, 0xFFFF0000          @ LED Port Address
.equ HEX3_HEX0_BASE, 0xFF200020     @ 7-Segment displays (HEX3, HEX2, HEX1, HEX0)
.equ HEX5_HEX4_BASE, 0xFF200030     @ 7-Segment displays (HEX5, HEX4)

.data
    .align 4
howard_id_word:
    .word 0x03032402            
    
    .align 1
digit_buffer:
    .space 8                    @ Problem 1 Output: Storage for 8 separated hex digits

    .text
    .global split_hex_to_memory
split_hex_to_memory:
    
    MOV     R1, #8                  @ R1 = Loop counter (starts at 8)

split_loop:
    SUBS    R1, R1, #1              @ Decrement counter (process 7 down to 0)
    MOV     R12, R1                 @ Copy counter to temp register R12
    LSL     R12, R12, #2            @ Calculate shift amount: R12 = index * 4

    LSR     R0, R2, R12             @ Shift input right to move nibble to LSB (R0)
    AND     R0, R0, #0xF            @ Mask to isolate the lowest 4 bits (nibble)
    STRB    R0, [R3], #1            @ Store byte to buffer and increment address (R3)

    CMP     R1, #0                  @ Check if counter reached 0
    BNE     split_loop              @ If not, continue loop

    BX      LR                      @ Return from function

    .section .rodata
    .align 2
bar_lookup:
    .word 0x00000000   @ N=0
    .word 0x00000001   @ N=1
    .word 0x00000003   @ N=2
    .word 0x00000007   @ N=3
    .word 0x0000000F   @ N=4
    .word 0x0000001F   @ N=5
    .word 0x0000003F   @ N=6
    .word 0x0000007F   @ N=7
    .word 0x000000FF   @ N=8
    .word 0x000001FF   @ N=9

    .text
    .global generate_bar_chart
generate_bar_chart:    
    CMP     R2, #0
    BLT     gb_out_of_range         @ If R2 < 0, jump to error handler
    
    CMP     R2, #9
    BGT     gb_out_of_range         @ If R2 > 9, jump to error handler

    @ R2 is now verified to be a valid index (0-9)
    LDR     R1, =bar_lookup         @ R1 = Base address of lookup table
    LSL     R2, R2, #2              @ Convert index to offset: R2 = R2 * 4 (word size)
    ADD     R1, R1, R2              @ R1 = base + offset (R1 now points to the word)

    LDR     R0, [R1]                @ R0 = Load the bar pattern from the table
    B       gb_done                 @ Skip error handler

gb_out_of_range:
    MOV     R0, #0                  @ Set return value to 0 (no bars for invalid input)

gb_done:
    BX      LR                      @ Return from function

    .global _start
_start:
    @ --- Q1: Split ID ---
    LDR     R2, =howard_id_word     @ R2 = Address of the ID word
    LDR     R2, [R2]                @ R2 = Load the 32-bit ID (0x03032402)
    LDR     R3, =digit_buffer       @ R3 = Destination buffer address
    BL      split_hex_to_memory     @ CALL Problem 1 to separate ID into bytes

    @ --- Q3: Display Loop Setup ---
    LDR     R4, =LED_PORT           @ R4 = LED port address
    LDR     R5, =digit_buffer       @ R5 = Address of separated digits (start of buffer)
    MOV     R6, #8                  @ R6 = Loop counter for 8 digits

display_loop:
    @ --- Q2: Convert Digit and Display ---
    LDRB    R2, [R5], #1            @ Load next digit byte into R2, advance pointer R5
    
    BL      generate_bar_chart      @ Convert digit in r2 to bar pattern in r0
    
    STR     R0, [R4]                @ Write pattern to LEDs

    @ --- Delay ---
    BL      delay                   @ Wait for ~1 second
    
    @ --- Loop Control ---
    SUBS    R6, R6, #1              @ Decrement digit counter
    BNE     display_loop            @ If not zero, repeat loop

    B       .                       @ Infinite loop to stop program

delay:
    @ PUSH/POP removed as requested. Register R3 is modified.
    LDR     R3, =9500000            @ Loop count for ~1 second in CPUlator
delay_loop:
    SUBS    R3, R3, #1              @ Decrement delay counter
    BNE     delay_loop              
    BX      LR                      @ Return from function