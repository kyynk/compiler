.data
    fmt_true:  .string "true\n"
    fmt_false: .string "false\n"
    fmt_int:   .string "%d\n"

.text
    .globl main

print_bool:
    cmpq $1, %rsi
    je print_true
    jmp print_false
    ret

print_true:
    mov $fmt_true, %rdi
    xor %rax, %rax
    call printf
    ret

print_false:
    mov $fmt_false, %rdi
    xor %rax, %rax
    call printf
    ret

print_int:
    mov $fmt_int, %rdi
    xor %rax, %rax
    call printf
    ret

main:
    # true && false (1 && 0)
    call true_and_false

    # if 3 <> 4 then 10 * 2 else 14
    call if_expression

    # 2 == 3 || 4 <= 2 * 3
    call or_expression

    mov $0, %rax
    ret

# true && false (1 && 0)
true_and_false:
    pushq %rbp
    movq $1, %rdi      # %rdi = true (1)
    movq $0, %rsi      # %rdi = false (0)
    andq %rsi, %rdi    # true && false
    call print_bool
    popq %rbp
    ret

# if 3 <> 4 then 10 * 2 else 14
if_expression:
    pushq %rbp
    movq $3, %rdi
    movq $4, %rsi
    cmpq %rsi, %rdi
    jne not_equal      # if 3 != 4 then goto not_equal
    movq $14, %rsi
    jmp end_if

not_equal:
    movq $10, %rsi
    imulq $2, %rsi

end_if:
    call print_int
    popq %rbp
    ret

# 2 == 3 || 4 <= 2 * 3
or_expression:
    pushq %rbp
    movq $2, %rdi
    movq $3, %rsi
    cmpq %rsi, %rdi
    xor %rax, %rax    # clear %rax
    sete %al          # if 2 == 3 then %al = 1 else %al = 0
    movq $4, %rdi
    movq $2, %rsi
    imulq $3, %rsi
    cmpq %rsi, %rdi
    xor %rbx, %rbx    # clear %rbx
    setle %bl         # if 4 <= 2 * 3 then %bl = 1 else %bl = 0
    orq %rbx, %rax    # %al || %bl
    movq %rbx, %rsi
    call print_bool
    popq %rbp
    ret
