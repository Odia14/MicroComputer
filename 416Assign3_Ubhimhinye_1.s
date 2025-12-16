        .equ    count, 10
        .equ    taddress, 0x40002000

        .data
nums:   .word   507, 750, 3500, 504, 909, 177, 281, 490, 182, 3900

        .text
        .global start
start:
        MOV     R0, #0              @ sum = 0
        MOV     R1, #count          @ R1 = remaining elements
        LDR     R2, =nums           @ R2 = &nums[0]

sum_loop:
        LDR     R3, [R2], #4        @ R3 = *R2; R2 += 4  (post-indexed)
        ADD     R0, R0, R3          @ sum += R3
        SUBS    R1, R1, #1          @ --count
		CMP		R1, #0
        BNE     sum_loop

        MOV     R4, R0              @ R4 = numerator (sum)
        MOV     R5, #count          @ R5 = denominator (10)
        MOV     R6, #0              @ R6 = quotient (average)

div_loop:                            @ successive subtraction division
        CMP     R4, R5
        BLO     done                @ if remainder < denom, we're done
        SUB     R4, R4, R5          @ numerator -= denominator
        ADD     R6, R6, #1          @ ++quotient
        B       div_loop

done:
        LDR     R1, =taddress       @ R1 = destination address
        STR     R6, [R1]            @ store average to 0x40002000
stop:
        B       stop
