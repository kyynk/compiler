.section .data
    fmt: .string "%d\n"      # format string for printf

.section .text
    .globl main

main:
    # 4 + 6
    xor %rsi, %rsi            # clear %rsi
    mov $4, %rsi              # %rsi = 4
    add $6, %rsi              # %rsi = %rsi + 6 = 10
    mov $fmt, %rdi            # format string
    xor %rax, %rax            # clear %rax
    call printf               # print result

    # 21 * 2
    xor %rsi, %rsi
    mov $21, %rsi             # %rsi = 21
    imul $2, %rsi             # %rsi = %rsi * 2 = 42
    mov $fmt, %rdi
    xor %rax, %rax
    call printf

    # 4 + 7 / 2
    xor %rax, %rax            # clear %rax for division
    mov $7, %rax              # %rax = 7 (dividend)
    xor %rdx, %rdx            # clear %rdx (important for idiv, high bits of dividend)
    mov $2, %rbx              # %rbx = 2 (divisor)
    idiv %rbx                 # %rax = %rdx:%rax / %rbx = 7 / 2 = 3 (quotient)
    mov $4, %rsi              # %rsi = 4
    add %rax, %rsi            # %rsi = %rsi + %rax = 7
    mov $fmt, %rdi
    xor %rax, %rax
    call printf               # print result

    # 3 - 6 * (10 /5)
    xor %rsi, %rsi
    mov $3, %rsi              # $rsi = 3
    mov $10, %rax             # %rax = 10 (dividend)
    xor %rdx, %rdx            # clear %rdx
    mov $5, %rbx              # %rbx = 5 (divisor)
    idiv %rbx                 # %rax = %rdx:%rax / %rbx = 10 / 5 = 2 (quotient)
    mov $6, %rdx              # %rdx = 6 (multiplier)
    imul %rax, %rdx           # %rdx = %rdx * %rax
    sub %rdx, %rsi            # %rsi = %rsi - %rdx
    mov $fmt, %rdi
    xor %rax, %rax
    call printf

    ret