### x86-64 code by Jean-Christophe Filliâtre for 
### resolve the n-queens problem read positive integer n
### manually compiled from the following C code
### int t(int a, int b, int c){
###   int f = 1;
###   if (a) {
###     int d, e = a & ~b & ~c;
###     f = 0;
###     while ( d = e & -e) {
###       f += t(a-d, (b + d) * 2, (c + d) / 2);
###       e -= d;
###     }
###   }
###   return f;
### }
###
### main() {
###   int n;
###   scanf("%d", &n);
###   printf("q(%d) = %d\n", n, t(~(~0 << n), 0, 0));
### }

	.text
	.globl main

	## t(a:rdi, b:rsi, c:rdx)
	##   e:rcx, d:r8,  f:rax
	
t:
	movq	$1, %rax	# f <- 1
	testq	%rdi, %rdi	# a = 0 ?
	jz	t_return
	subq	$48, %rsp	# allocate 6 words on the stack
	xorq	%rax, %rax	# f <- 0
	movq	%rdi, %rcx	# e <- a & ~b & ~c
	movq	%rsi, %r9
	notq	%r9
	andq	%r9, %rcx
	movq	%rdx, %r9
	notq	%r9
	andq	%r9, %rcx
	jmp	loop_test
loop_body:
	movq	%rdi,  0(%rsp)	# save a
	movq	%rsi,  8(%rsp)	# save b
	movq	%rdx, 16(%rsp)  # save c
	movq	%r8,  24(%rsp)	# save d
	movq	%rcx, 32(%rsp)	# save e
	movq	%rax, 40(%rsp)	# save f
	subq	%r8, %rdi	# a <- a - d
	addq	%r8, %rsi	# b <- (b + d) << 1
	salq	$1, %rsi
	addq	%r8, %rdx	# c <- (c+d) >> 1
	shrq	$1, %rdx
	call	t		# t(a-d, (b+d)<<1, (c+d)>>1)
	addq	40(%rsp), %rax	# f += t(...)
	movq	32(%rsp), %rcx	# restore e
	subq	24(%rsp), %rcx	#  -= d
	movq	16(%rsp), %rdx	# restore c
	movq	 8(%rsp), %rsi	# restore b
	movq	 0(%rsp), %rdi	# restore a
loop_test:
	movq	%rcx, %r8	# d <- e & -e
	movq	%rcx, %r9
	negq	%r9
	andq	%r9, %r8
	jnz	loop_body
	addq	$48, %rsp
t_return:
	ret
main:
	pushq	%rbp		
	movq	%rsp, %rbp
	movq	$input, %rdi	# first argument of scanf = format
	movq	$n, %rsi	# second argument of scanf = address for n
	xorq	%rax, %rax	# no other arguments
	call	scanf

	xorq	%rdi, %rdi	# a = ~(~0 << n)
	notq	%rdi
	movq	(n), %rcx
	salq	%cl, %rdi	# a calculated offset must use %cl
	notq	%rdi
	xorq	%rsi, %rsi	# b = 0
	xorq	%rdx, %rdx	# c = 0
	call	t

	movq	$msg, %rdi	# first argument of printf = format
	movq	(n), %rsi	# second argument = n
	movq	%rax, %rdx	# third argument = result
	xorq	%rax, %rax	# no other arguments
	call	printf
	xorq	%rax, %rax	# exit code 0 for exit
	popq	%rbp
	ret

	.data
n:
	.quad	0
input:
	.string	"%d"
msg:
	.string	"q(%d) = %d\n"	
