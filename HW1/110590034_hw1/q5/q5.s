.section .data
    fmt_int: .string "%d\n"

.section .text
    .globl main

print_int:
    mov $fmt_int, %rdi
    xor %rax, %rax
    call printf
    ret

main:
    # (let x = 3 in x * x)
    call compute_x_square

    # (let x = 3 in (let y = x + x in x * y) + (let z = x + 3 in z / z))
    call compute_complex_expression

    movq $0, %rax
    ret

# print(let x = 3 in x * x)
compute_x_square:
    pushq %rbp
    movq %rsp, %rbp          # set new base pointer

    subq $8, %rsp            # allocate space for variables (8 * 1 = 8)
    movq $3, -8(%rbp)        # let x = 3, store x in stack

    movq -8(%rbp), %rsi      # load x into %rsi
    imulq %rsi, %rsi         # x * x

    call print_int
    addq $8, %rsp            # release variable space
    popq %rbp
    ret

# print(let x = 3 in (let y = x + x in x * y) + (let z = x + 3 in z / z))
compute_complex_expression:
    pushq %rbp
    movq %rsp, %rbp          # set new base pointer

    subq $24, %rsp           # allocate space for variables (8 * 3 = 24)
    movq $3, -8(%rbp)        # let x = 3, store x in stack

    movq -8(%rbp), %rdi      # load x into %rdi
    addq %rdi, %rdi          # y = x + x
    movq %rdi, -16(%rbp)     # store y in stack

    movq -8(%rbp), %rsi      # load x into %rsi
    imulq -16(%rbp), %rsi    # %rsi = x * y

    movq -8(%rbp), %rdi      # load x into %rdi
    addq $3, %rdi            # z = x + 3
    movq %rdi, -24(%rbp)     # store z in stack

    movq -24(%rbp), %rax     # load z into %rax
    xor %rdx, %rdx           # clear %rdx for division (high 64 bits)
    div %rax                 # %rax = z / z
    addq %rax, %rsi          # %rsi = x * y + z / z

    call print_int
    addq $24, %rsp           # release variable space
    popq %rbp                # restore base pointer
    ret
