	.arch armv8-a
/*
Var: 3
Insertion Sort
matrix str: 255*255
matrix element size: 4 bytes (word)
*/
		.data
		.align 	2
n:										// n - Count of matrix columns
		.byte 2
m:										// m - Count of matrix rows
		.byte 5
matrix:
		.word 	-8, 7
		.word   1, -9
		.word   5, 10 
		.word   2, 255
		.word 	1000, 666
		.text
		.align	2
		.global _start
		.type 	_start, %function
_start: 	
		adr 	x0, n					// x0 - Count of matrix columns
		ldrb 	w0, [x0]			
		adr 	x1, m					// x1 - Count of matrix rows
		ldrb 	w1, [x1]
		adr		x9, matrix				// x9 - Address of a current row 
		adr 	x10, matrix				// x10 - Address of the matrix begining
		mov 	x3, #0					// x3 - current index of row
newrow:
		mov		x2, #0					// x2 - Current index of cullumn (index of a current element) 
formation:
		add		x2, x2, #1				// Counter will be start at one 
		cmp 	x2, w0, uxtw
		bge 	transition				// The row has been sorted
		ldr 	w6, [x9, x2, lsl #2]	// w6 - Value of a current element
		mov 	x4, x2					// x4 - Decreasing counter 
search:	
		mov 	x5, x4					// x5 - Old counter value (previous element)  
		cbz		x4, insert				// If !x2 then our element should insert at the beginning
		sub 	x4, x4, #1				
		ldr  	w7, [x9, x4, lsl #2]	// w7 - Element with index x3
		cmp		w6, w7					// Compare current element and element with index x3
		ble		insert					// If we found needed place then insert current element there 
		str		w7, [x9, x5, lsl #2]	// Else push looking elements and continue search needed place 
		b		search
insert:
		str		w6, [x9, x5, lsl #2]
		b 		formation
transition:
		add 	x3, x3, #1 
		add 	x9, x9, x0, lsl#2
		cmp		x3, w1, uxtw
		blt 	newrow
access:
		mov 	x0, #0
		mov 	x8, #93
		svc		#0
		.size	_start, .-_start		
