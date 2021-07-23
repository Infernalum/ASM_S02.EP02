	.arch	armv8-a
	.text	
	.align	2	

	.global applyGaussAsm
	.type 	applyGaussAsm, %function
applyGaussAsm:
	stp 	x19, x20, [sp, #-16]!
	stp 	x21, x22, [sp, #-16]!
	stp 	x23, x24, [sp, #-16]!
	stp 	x25, x26, [sp, #-16]!
	stp 	x27, x28, [sp, #-16]!
	stp 	x29, x30, [sp, #-16]!
	fmov 	d1, #0.125
	fmov 	d0, #2.0
	fdiv 	d0, d1, d0
	fmov 	d2, #0.250
	mov		x4, #0				// x
	mov 	x5, x1				// add_width - 1
	sub 	x5, x5, #1
	mov 	x6, #0				// y
	mov 	x7, x2				// add_height - 1
	sub 	x7, x7, #1
	mov 	x8, #0				// i
LY:
	
	add 	x6, x6, #1
	cmp 	x6, x7
	bge 	end
	mov 	x4, #0

	mov 	x10, x6
	mul 	x10, x10, x1
	mov 	x19, x10			// ker1y - add_width * y
	sub 	x10, x10, x1
	mov 	x18, x10			// ker0y - add_width * (y - 1)
	add 	x10, x10, x1
	add		x10, x10, x1
	mov 	x20, x10			// ker2y - add_width * (y + 1)
LX:
	add 	x4, x4, #1
	cmp 	x4, x5
	bge 	LY
	mov 	x8, #0

	mov 	x16, x4				// ker1x - x
	mov 	x10, x4
	sub 	x10, x10, #1
	mov 	x15, x10			// ker0x - (x - 1)
	add 	x10, x10, #2
	mov 	x17, x10			// ker2x - (x + 1)

	mov 	x10, x5
	sub 	x10, x10, #1		// add_width - 2
	mov 	x11, x6						
	sub 	x11, x11, #1		// y - 1
	mul 	x10, x10, x11		// (add_width - 2) * (y - 1)
	add 	x10, x10, x4		// (add_width - 2) * (y - 1) + x
	sub 	x10, x10, #1 		// (add_width - 2) * (y - 1) + x - ker_div 
	mov 	x11, #4
	mul 	x10, x10, x11		// 4 * ((add_width - 2) * (y - 1) + (x - ker_div))

	
	
	

LI:
	add 	x10, x10, x8	 	// 4 * (...) + i



	// ker[0][0]
	mov 	x11, x15
	mov 	x12, x18
	add 	x11, x11, x12
	mov		x12, #4
	mul 	x11, x11, x12
	add 	x11, x11, x8
	ldrb 	w13, [x0, x11]
	//ldruh		w15, [x0, x11]
	//lsl		w15, w15, #8
	ucvtf   d3,  w13
	fmul	d3, d3, d0
	fmov 	d10, d3 	

	// ker[0][1]
	mov 	x11, x16
	mov 	x12, x18
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d1
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4
	
	// ker[0][2]
	mov 	x11, x17
	mov 	x12, x18
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d0
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[1][0]
	mov 	x11, x15
	mov 	x12, x19
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d1
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[1][1]
	mov 	x11, x16
	mov 	x12, x19
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d2
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[1][2]
	mov 	x11, x17
	mov 	x12, x19	
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d1
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[2][0]
	mov 	x11, x15
	mov 	x12, x20
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d0
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[2][1]
	mov 	x11, x16
	mov 	x12, x20
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d1
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov 	d10, d4

	// ker[2][2]
	mov 	x11, x17
	mov 	x12, x20
	add 	x11, x11, x12
	mov 	x12, #4
	mul 	x11, x11, x12
	add		x11, x11, x8
	ldrb	w13, [x0, x11]
	ucvtf	d3, w13
	fmul 	d3, d3, d0
	fmov 	d4, d10
	fadd 	d4, d4, d3
	fmov	d10, d4

	
	fmov 	d3, d10
	fcvtzu	w11,d3
	strb	w11, [x3, x10]  	
		
	add 	x8, x8, #1
	cmp 	x8, #4
	bge 	LX
	b 		LI
end:
	ldp 	x29, x30, [sp], #16
	ldp 	x27, x28, [sp], #16
	ldp 	x25, x26, [sp], #16
	ldp 	x23, x24, [sp], #16
	ldp 	x21, x22, [sp], #16
	ldp 	x19, x20, [sp], #16
	ret
	.size 	applyGaussAsm, .-applyGaussAsm
