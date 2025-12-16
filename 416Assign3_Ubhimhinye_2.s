.data
    @ Store name as an null-terminated string
    Nom: .asciz "MY NAME IS ODIA UBHIMHINYE"

.text
    .global _start
_start:
    MOV R0, #0          @ Initialize sum at 0 and store in R0
    LDR R1, =Nom        @ Load data (string) address into R1

loop:
    LDRB R2, [R1]       @ Load next byte (character)
    CMP R2, #0          @ Compare R2 to 0
    BEQ stop            @ If R2 = 0, go to stop

    CMP R2, #'M'        @ Compare letter in R2 to M
    BEQ ADD_M           @ If equal, go to ADD_M

    CMP R2, #'D'        @ Compare letter in R2 to D
    BEQ ADD_D           @ If equal, go to ADD_D

    CMP R2, #'C'        @ Compare letter in R2 to C
    BEQ ADD_C           @ If equal, go to ADD_C

    CMP R2, #'L'        @ Compare letter in R2 to L
    BEQ ADD_L           @ If equal, go to ADD_L

    CMP R2, #'X'        @ Compare letter in R2 to X
    BEQ ADD_X           @ If equal, go to ADD_X

    CMP R2, #'V'        @ Compare letter in R2 to V
    BEQ ADD_V           @ If equal, go to ADD_V

    CMP R2, #'I'        @ Compare letter in R2 to I
    BEQ ADD_I           @ If equal, go to ADD_I

    B NEXT_CHAR         @ Go to next character
ADD_M:
    ADD R0, R0, #1000   @ Add 1000 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_D:
    ADD R0, R0, #500    @ Add 500 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_C:
    ADD R0, R0, #100    @ Add 100 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_L:
    ADD R0, R0, #50     @ Add 50 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_X:
    ADD R0, R0, #10     @ Add 10 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_V:
    ADD R0, R0, #5      @ Add 5 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char

ADD_I:
    ADD R0, R0, #1      @ Add 1 to R0 and store in R0
    B NEXT_CHAR          @ Go to next char
NEXT_CHAR:
    ADD R1, R1, #1      @ Move to next character
    B loop              @ Go to loop
stop:
    B stop              @ Infinite loop (end program)
