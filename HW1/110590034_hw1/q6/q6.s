.data
    fmt: .string "sqrt(%2d) = %2d\n"

.text
    .globl main

print_result:
    mov $fmt, %rdi
    xor %rax, %rax
    call printf
    ret

isqrt:
    pushq %rbp
    movq %rsp, %rbp

    subq $16, %rsp                 # allocate space for variables
    movq $0, -8(%rbp)              # c = 0
    movq $1, -16(%rbp)             # s = 1

isqrt_loop:
    cmpq %rsi, -16(%rbp)           # compare s and n
    jg isqrt_done                  # if s > n, done

    addq $1, -8(%rbp)              # c++

    # s = s + 2 * c + 1
    leaq 1(-16(%rbp), -8(%rbp), 2), -16(%rbp)

    jmp isqrt_loop

isqrt_done:
    movq -8(%rbp), %rax            # load c into %rax
    addq $16, %rsp                 # release variable space
    popq %rbp
    ret

main:
    pushq %rbp
    movq %rsp, %rbp

    subq $8, %rsp                  # allocate space for variables
    movq $0, -8(%rbp)              # n = 0

main_loop:
    movq -8(%rbp), %rsi            # load n into %rsi
    cmpq $20, %rsi
    jg end_main_loop               # if n > 20, done

    call isqrt
    movq %rax, %rdx                # save result

    movq -8(%rbp), %rsi            # load n into %rsi
    call print_result

    addq $1, -8(%rbp)              # n++

    jmp main_loop

end_main_loop:
    addq $8, %rsp                  # release variable space
    popq %rbp
    movq $0, %rax
    ret
