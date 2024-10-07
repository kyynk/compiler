.data
fmt: .string "solution = %d\n"
m:
	.long	7
	.long	53
	.long	183
	.long	439
	.long	863
	.long	497
	.long	383
	.long	563
	.long	79
	.long	973
	.long	287
	.long	63
	.long	343
	.long	169
	.long	583
	.long	627
	.long	343
	.long	773
	.long	959
	.long	943
	.long	767
	.long	473
	.long	103
	.long	699
	.long	303
	.long	957
	.long	703
	.long	583
	.long	639
	.long	913
	.long	447
	.long	283
	.long	463
	.long	29
	.long	23
	.long	487
	.long	463
	.long	993
	.long	119
	.long	883
	.long	327
	.long	493
	.long	423
	.long	159
	.long	743
	.long	217
	.long	623
	.long	3
	.long	399
	.long	853
	.long	407
	.long	103
	.long	983
	.long	89
	.long	463
	.long	290
	.long	516
	.long	212
	.long	462
	.long	350
	.long	960
	.long	376
	.long	682
	.long	962
	.long	300
	.long	780
	.long	486
	.long	502
	.long	912
	.long	800
	.long	250
	.long	346
	.long	172
	.long	812
	.long	350
	.long	870
	.long	456
	.long	192
	.long	162
	.long	593
	.long	473
	.long	915
	.long	45
	.long	989
	.long	873
	.long	823
	.long	965
	.long	425
	.long	329
	.long	803
	.long	973
	.long	965
	.long	905
	.long	919
	.long	133
	.long	673
	.long	665
	.long	235
	.long	509
	.long	613
	.long	673
	.long	815
	.long	165
	.long	992
	.long	326
	.long	322
	.long	148
	.long	972
	.long	962
	.long	286
	.long	255
	.long	941
	.long	541
	.long	265
	.long	323
	.long	925
	.long	281
	.long	601
	.long	95
	.long	973
	.long	445
	.long	721
	.long	11
	.long	525
	.long	473
	.long	65
	.long	511
	.long	164
	.long	138
	.long	672
	.long	18
	.long	428
	.long	154
	.long	448
	.long	848
	.long	414
	.long	456
	.long	310
	.long	312
	.long	798
	.long	104
	.long	566
	.long	520
	.long	302
	.long	248
	.long	694
	.long	976
	.long	430
	.long	392
	.long	198
	.long	184
	.long	829
	.long	373
	.long	181
	.long	631
	.long	101
	.long	969
	.long	613
	.long	840
	.long	740
	.long	778
	.long	458
	.long	284
	.long	760
	.long	390
	.long	821
	.long	461
	.long	843
	.long	513
	.long	17
	.long	901
	.long	711
	.long	993
	.long	293
	.long	157
	.long	274
	.long	94
	.long	192
	.long	156
	.long	574
	.long	34
	.long	124
	.long	4
	.long	878
	.long	450
	.long	476
	.long	712
	.long	914
	.long	838
	.long	669
	.long	875
	.long	299
	.long	823
	.long	329
	.long	699
	.long	815
	.long	559
	.long	813
	.long	459
	.long	522
	.long	788
	.long	168
	.long	586
	.long	966
	.long	232
	.long	308
	.long	833
	.long	251
	.long	631
	.long	107
	.long	813
	.long	883
	.long	451
	.long	509
	.long	615
	.long	77
	.long	281
	.long	613
	.long	459
	.long	205
	.long	380
	.long	274
	.long	302
	.long	35
	.long	805

.bss
memo:
    .space	2097152

.text
	.globl	main

# L = 4
# N = 15
f:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp

    movl %edi, -4(%rbp)    # store i
    movl %esi, -8(%rbp)    # store c

    cmpl $15, -4(%rbp)     # if i == N
    je return_zero

    movl -8(%rbp), %r8d    # load c to %r8d (key)
    sall $4, %r8d          # c << L
    orl -4(%rbp), %r8d     # key = c << L | i

    movl memo(,%r8,4), %ebx    # load memo[key] to %ebx (r)

    testl %ebx, %ebx       # if r != 0
    jne return_r

    xorl %r9d, %r9d        # s = 0
    movl $0, %ecx          # j = 0, according to the exercise7, j place in %rcx

for_loop:
    cmpl $15, %ecx         # compare j, N
    je end_for_loop        # if j == N, end loop

    movl $1, %r10d         # col = 1
    sall %cl, %r10d        # col = 1 << j

    testl %r10d, -8(%rbp)  # if c & col
    jz skip_col

    movl %r8d, -16(%rbp)   # store key
    movl %r9d, -20(%rbp)   # store s
    movl %ecx, -24(%rbp)   # store j

    addl $1, %edi          # i + 1 (pass to f)
    subl %r10d, %esi       # c - col (pass to f)
    call f

    # restore i, c, key, s, j
    movl -4(%rbp), %edi
    movl -8(%rbp), %esi
    movl -16(%rbp), %r8d
    movl -20(%rbp), %r9d
    movl -24(%rbp), %ecx

    movl -4(%rbp), %r11d
    imull $15, %r11d           # i * N
    addl %ecx, %r11d           # i * N + j
    movl m(,%r11,4), %r11d     # load m[i * N + j] to %r11d (x)
    addl %eax, %r11d           # x = m[i * N + j] + f(i + 1, c - col)

    cmpl %r9d, %r11d           # if x > s
    jg update_s

    addl $1, %ecx          # j++
    jmp for_loop

skip_col:
    addl $1, %ecx          # j++
    jmp for_loop

update_s:
    movl %r11d, %r9d       # s = x
    addl $1, %ecx          # j++
    jmp for_loop

end_for_loop:
    movl %r9d, memo(,%r8,4)    # memo[key] = s
    jmp return_s

return_s:
    movl %r9d, %eax
    addq $32, %rsp
    popq %rbp
    ret

return_r:
    movl %ebx, %eax
    addq $32, %rsp
    popq %rbp
    ret

return_zero:
    xorl %eax, %eax
    addq $32, %rsp
    popq %rbp
    ret

main:
    pushq %rbp
    movq %rsp, %rbp
    
    movl $0, %edi       # i = 0
    movl $1, %esi       # c = 1
    sall $15, %esi      # c = 1 << N
    subl $1, %esi       # c = 1 << N - 1
    # movl $32767, %esi
    call f

    movl %eax, %esi
    movq $fmt, %rdi
    xorq %rax, %rax
    call printf

    popq %rbp
    xorq %rax, %rax
    ret

## Local Variables:
## compile-command: "gcc matrix.s && ./a.out"
## End:
