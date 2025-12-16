.data
msg: .asciiz "\nHello, World!\n"  

.text
main:
li $v0, 4
la $a0, msg
syscall

lb $t1, 6($a0)
addi $t1, $t1, 15
sb $t1, 6($a0)
syscall

li $v0, 10  # quit ()
syscall