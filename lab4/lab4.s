	.arch armv8-a
	.data
inputx:
	.string	"Input x:\n"
errx:
	.string "abs(x) should be less more 1. Try again.\n" 
inputa:
	.string "Input alpha:\n"
inputn:
	.string "Input accuracy (Natural number):\n"
errn:
	.string "n should be natural number. Try again.\n"
formint:
	.string "%d"
formdouble:
	.string	"%lf"
formchar:
	.string "%c"
preview:
	.string "(1 + %.10g)^(%.10g):\n"
expected:
	.string "Expected value:					 %.30g\n"
counted:
	.string "Using Taylor series (accuracy = %d):	 	 %.30g\n"
usage:
	.string "Usage: %s file\n"
warning:
	.string "Notice: this file already exists. Rewrite (Y/N)?\n"  
moder:
	.string "r"
modew:
	.string "w"
invin:
	.string "Invalid input. Try again.\n"
step:
	.string "Step #%d: cur. alpha: %.10g; cur. term: %.10g; result: %.20g\n"

	.text
	.align	2

	

	.global clearsky		
	.type 	clearsky, %function
	.equ	tmp, 16
	.equ 	size, 24
clearsky:
	sub		sp, sp, size
	stp		x29, x30, [sp]
	mov 	x29, sp
loop:
	adr 	x0, formchar
	add 	x1, x29, tmp
	bl 		scanf
	ldrb 	w0, [x29, tmp]
	cmp 	w0, '\n' 
	bne		loop

	mov 	w0, #0
	ldp 	x29, x30, [sp]
	add 	sp, sp, size
	ret
	.size 	clearsky, .-clearsky
	


	.global	taylor
	.type	taylor, %function
	.equ 	fd, 16
	.equ	one, 24
	.equ	x, 32
	.equ	al, 40
	.equ 	ac, 48
	.equ 	curn, 56
	.equ	term, 64
	.equ	res, 72
	.equ 	size, 80
taylor:
	sub 	sp, sp, size
	stp 	x29, x30, [sp]
	mov 	x29, sp
	str 	x1, [x29, fd]
	scvtf	d2, x0
	fmov 	d6, #1.0
	fadd 	d2, d2, d6
	str 	d0, [x29, x]
	str		d1, [x29, al]

	fmov 	d0, #1.0
	fmov 	d1, #10.0
	fmov 	d3, #1.0 
L0:
	fdiv 	d0, d0, d1
	fadd 	d3, d3, d6
	fcmp	d2, d3
	bge 	L0

	str		d0, [x29, ac]
	str 	d6, [x29, curn]
	str		d6, [x29, term]
	str		d6, [x29, res]
	str		d6, [x29, one]
series:
	ldr 	x0, [x29, fd]
	ldr 	d0, [x29, x]
	ldr 	d1, [x29, al]
	ldr 	d2, [x29, ac]
	ldr 	d3, [x29, curn]
	ldr 	d4, [x29, term]
	ldr 	d5, [x29, res]
	ldr 	d6, [x29, one]

	fmul	d4, d4, d0
	fmul 	d4, d4, d1
	fdiv	d4, d4, d3

	fabs 	d7, d4
	/*ldr 	d10, [x29, term]
	fabs 	d10, d10
	fsub 	d7, d10, d7
	fabs 	d7, d7		// For positive alpha*/
	fcmp 	d7, d2
	blt		exit

	str		d4, [x29, term]
	fadd 	d5, d5, d4
	str 	d5, [x29, res]
	fsub 	d1, d1, d6
	str 	d1, [x29, al]
	fadd 	d1, d1, d6
	fadd 	d3, d3, d6
	str	 	d3, [x29, curn]
	fsub 	d3, d3, d6

	ldr 	x0, [x29, fd]
	fcvtas	x2, d3
	adr 	x1, step
	ldr 	d0, [x29, al]
	ldr 	d1, [x29, term]
	ldr 	d2, [x29, res]
	bl	 	fprintf
	b		series
exit:
	ldp 	x29, x30, [sp]
	add		sp, sp, size
	fmov	d0, d5
	ret
	.size	taylor, .-taylor


	
	
	.global	main
	.type	main, %function
	.equ	progname, 16
	.equ 	filename, 24
	.equ 	fd, 32
	.equ	tmp, 40
	.equ	x, 48
	.equ 	al, 56 
	.equ	n, 64
	.equ 	res, 72
	.equ 	size, 80
main:
	sub 	sp,  sp, size
	stp		x29, x30, [sp]
	mov		x29, sp
	cmp 	w0,  #2
	beq 	exist
	ldr 	x2, [x1]
	adr 	x0, stderr
	ldr		x0, [x0]
	adr 	x1, usage
	bl 		fprintf
error:
	mov 	w0, #1
	ldp 	x29, x30, [sp]
	add 	sp, sp, size
	ret
invalid:
	adr 	x0, invin
	bl 		printf
	b 		error
exist:
	ldr 	x0, [x1]
	str 	x0, [x29, progname]
	ldr 	x0, [x1, #8]
	str 	x0, [x29, filename]
	adr 	x1, moder 
	bl 		fopen 
	cbz 	x0, open
	str 	x0, [x29, fd]
	bl 		fclose
	ldr		x0, [x29, fd]
	adr 	x0, warning
	bl 		printf
	adr 	x0, formchar
	add		x1, x29, tmp
	bl 		scanf
	bl      clearsky
	ldrb 	w0, [x29, tmp]
	cmp 	w0, 'Y'
	beq 	open
	cmp 	w0, 'y'
	beq 	open
	b		end 
open:
	ldr 	x0, [x29, filename]
	adr 	x1, modew
	bl 		fopen
	str 	x0, [x29, fd]
	cbnz 	x0, inx
	ldr 	x0, [x29, filename]
	bl 		perror
	ldr 	x0, [x29, fd]
	b 		error
inx:	
	adr		x0,  inputx
	bl		printf
	adr		x0, formdouble
	add		x1, x29, x
	bl		scanf
	cmp 	w0, #1
	bne		1f
	ldr 	d0, [x29, x]
	fmov 	d1, #1.0
	fmov 	d2, #-1.0
	fcmp 	d0, d1
	bge		2f
	fcmp 	d0, d2
	ble		2f
	bl 		clearsky
	b 		alpha
1:
	adr 	x0, invin
	bl 		printf
	bl 		clearsky
	b 		inx
2:
	adr 	x0, errx
	bl 		printf
	bl 		clearsky
	b		inx
alpha:
	adr 	x0, inputa
	bl		printf
	adr 	x0, formdouble
	add		x1, x29, al
	bl		scanf
	cmp 	w0, #1
	bne		1f
	bl 		clearsky
	b 		N
1:
	adr		x0, invin
	bl 		printf
	bl 		clearsky
	b 		alpha
N:
	adr		x0, inputn
	bl 		printf
	adr 	x0, formint
	add 	x1, x29, n
	bl 		scanf
	cmp 	w0, #1
	bne 	1f
	ldr 	x0, [x29, n]
	cmp 	w0, #0
	ble		2f
	bl 		clearsky
	b 		math
1:
	adr 	x0, invin
	bl		printf
	bl 		clearsky
	b   	N
2: 	
	adr 	x0, errn
	bl 		printf
	bl 		clearsky
	b 		N
math:
	adr 	x0, preview
	ldr 	d0, [x29, x]
	ldr 	d1, [x29, al]
	bl		printf

	ldr 	d0, [x29, x]
	fmov 	d5, #1.0
	fadd	d0, d0, d5
	ldr 	d1, [x29, al]	
	bl		pow
	str 	d0, [x29, res]

	adr 	x0, expected
	ldr 	d0, [x29, res]
	bl	 	printf

	ldr 	d0, [x29, x]
	ldr 	d1, [x29, al]
	ldr 	x0, [x29, n]
	ldr 	x1, [x29, fd]
	bl 		taylor
	str 	d0, [x29, res]
	
	adr		x0, counted
	ldr 	x1, [x29, n]
	ldr 	d0, [x29, res]
	bl		printf

	ldr 	x0, [x29, fd]
	bl		fclose
end:
	mov		w0, #0
	ldp		x29, x30, [sp]
	add		sp, sp, size
	ret
	.size	main, .-main
