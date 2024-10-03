.data
    x:   .quad 2
    y:   .quad 0
    fmt: .string "%d\n"

.text
    .globl main

main:
    # (let x = 2 on .data)
    # let y = x * x
    movq x(%rip), %rdi
    imulq %rdi, %rdi    # y = x * x
    movq %rdi, y(%rip)

    # Load y and add x
    movq y(%rip), %rsi
    movq x(%rip), %rdi

    addq %rdi, %rsi     # y + x

    movq $fmt, %rdi
    xor %rax, %rax
    call printf

    movq $0, %rax
    ret
