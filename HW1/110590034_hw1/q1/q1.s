.data
    fmt: .string "n = %d\n"     # Format string for printf

.text
    .globl main

main:
    mov $fmt, %rdi              # Load address of format string into %rdi (1st argument)
    mov $42, %rsi               # Load integer value 42 into %rsi (2nd argument)
    xor %rax, %rax              # Clear %rax to indicate no vector arguments
    call printf                 # Call printf function

    mov $0, %rax                # Set return code to 0
    ret                         # Return from main
