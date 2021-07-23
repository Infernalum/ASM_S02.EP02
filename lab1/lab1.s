		.arch armv8-a
 /*		Var: 21;
 		res = ((a+b)^2-(c-d)^2)/(a+e^3-c);
		Data size: signed half words;
*/
		.data						// Data segment
		.align  3					// Double word alignment
 res:
 		.skip   8					// Hold a place for result
 a:
 		.short 	8
 b:
 		.short 	2
 c:
 		.short 	-2
 d:
 		.short 	2
 e:		
 		.short 	2
 		.text						// Code segment
 		.align  2					// Word alignment (for operations)
 		.global _start			  	// Program entry label
		.type   _start, %function	// Define label type
_start:
		adr		x0, a
		ldrsh	w1, [x0]
		adr		x0, b
		ldrsh	w2, [x0]
		adr		x0, c
		ldrsh	w3, [x0]
		adr		x0, d
		ldrsh   w4, [x0]
		adr		x0, e
		ldrsh   w5, [x0]				
		mul		w6, w5, w5			// e^2
		smull 	x6, w6, w5			// e^3
		add 	x6, x6, x1			// a + e^3
		sub		x6, x6, w3, sxtw	// a + e^3 - c
		add 	w1, w1, w2			// a + b
		smull 	x1, w1, w1			//(a + b)^2
		sub 	w3, w3, w4			// c - d
		smull 	x3, w3, w3 			//(c - d)^2
		subs 	x1, x1, x3			// (a + b)^2 - (c - d)^2
		beq 	error
		sdiv 	x1, x1, x6			// Result
		adr 	x0, res				// Storage x0 to res
		str		x1, [x0]
		mov 	x0, #0
		b 		exit
error:
		mov 	x0, #-1
exit:
		mov		x8, #93
		svc		#0
		.size	_start, .-_start	 // Determining the size of the function
