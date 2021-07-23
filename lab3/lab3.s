		.arch	 	armv8-a

		.data 					// Data segment with constant strings
em1:
		.string "Usage: "
		.equ 	em1len, .-em1	// Size of string (with '\0')
em2:	
		.string " filename\n"
		.equ 	em2len, .-em2
		
		.text					//  Code segment
		.align 	2
		.global _start
		.type 	_start, %function
_start:
		ldr 	x0, [sp]		// Check count of parametres placed in Stack
		cmp		x0, #2
		beq 	2f
		mov 	x0, #2			// Preparing system calling (window output; File descriptor = 2)
		adr		x1, em1			// x1 - Beginning of string "Usage: "	
		mov 	x2, em1len		// x2 - Lenght of the message (with '\0')
		mov 	x8, #64			// System calling (for writing message to file; in our case to screen)
		svc 	#0				// Calling SuperVisor (print "Usage: " on screen)
		mov 	x0, #2		
		ldr 	x1, [sp, #8]
		mov		x2, #0			// x2 - Lenght of filename string
0:								// 0 - Cycle for definition of the filename lenght
		ldrb	w3, [x1, x2]	
		cbz 	w3, 1f
		add 	x2, x2, #1
		b		0b
1:
		mov 	x8, #64			
		svc		#0				// Print filename on screen
		mov 	x0, #2
		adr		x1, em2
		mov 	x2, em2len
		mov 	x8, #64
		svc		#0				// Print finishing message " filename\n"
		mov 	x0, #1			// Exit with failed code  
		b		4f
2:
		ldr 	x0, [sp, #16]

		mov		x1, x0			// Trying to open the file
		mov		x0, #-100
		mov		x2, #0
		mov		x8, #56
		svc 	#0
		// If error of opening then error transition
		cmp 	x0, #0
		bge		3f
		bl		errors
		b		4f
3:
		bl 		work
4:
		mov 	x8, #93			// Exit
		svc 	#0
		
		.size	_start, .-_start


		.type	work, %function
		.text
		.align	2			
		// Dispacement for locale variables in Stack Frame
		.equ	fd , 16			// File descriptor
		.equ	tmp, 24
		.equ 	disp, 32
		.equ 	bufin, 40
		.equ 	bufout, 4136
		.equ 	size, 8232
		.equ 	bufsize, 10
work:
		mov 	x16, size		// Creating Stack Frame (x29, x30, filename address, file descriptor + bufer 4096b)
		sub 	sp, sp, x16		// Not #9132 (It's not in range of immediate values)
		stp		x29, x30, [sp]	// x29 - Frame Stack (always)
		mov 	x29, sp
		mov 	x10, bufsize
		str 	x0, [x29, fd]	// Save file descriptor to x0
		str 	xzr, [x29, tmp]
		str 	xzr, [x29, disp]
		mov 	x12, #0
0:								// Processing
		ldr		x0, [x29, fd]	// From where reading
		ldr 	x1, [x29, disp]
		//mov 	x20, #10
		//sub 	x1, x20, x1
		mov 	x2, bufsize
		sub 	x2, x2, x1		// Size of buffer

		mov 	x14, '\0'
		add 	x15, x29, bufin
		//ldr 	x2, [x29, disp]
		//add		x15, x15, x2
		//sub 	x15, x15, #1
		//str 	x14, [x15]
		
		mov 	x1, #0
		add 	x1, x1, x29
		add 	x1, x1, bufin	// Beginning of buffer
		ldr 	x0, [x29, disp]
		add 	x1, x1, x0
		ldr 	x0, [x29, fd]
		mov		x8, #63			// For reading from file
		svc 	#0				// Reading (copy to buffer addres 4096 bytes from file)
		cmp		x0, #0			// x0 - Size of bufin
		ble 	9f
		
		add 	x0, x0, x29
		add 	x0, x0, bufin	// Address of a bufin end
		ldr 	x1, [x29, disp]
		add 	x0, x0, x1
		mov 	x1, #0
		str 	x1, [x29, disp] // Flag of word	
		mov 	w3, #0
		mov 	w4, #0
		add 	x5, x29, bufin	// Displacement pointer in bufin
		mov 	x6, x5
		mov 	x7, bufout
		add 	x7, x7, x29
		mov 	w9, ' '
// New word
1:	
		cmp		x5, x0
		bgt 	7f
		ldrb 	w10, [x5], #1
		cbz 	w10, endbuf		// If it equal '\0' then go to the 2th label
		cmp 	w10, '\n'
		beq		newstring		// Similarly
		cmp		w10, ' '
		beq		3f				// If the letter equal ' ' or '\t' then go to th 3th label
		cmp 	w10, '\t'
		beq		3f
		b 		checkcut
endbuf:
		cbnz 	w1, checkcut
		strb 	w10, [x7], #1
		b 		norecord
3:
		cbz	w1, norecord		// Situation when we have been readed only space symbols
		cmp 	w3, w4			// Otherwise write to bufout a current word 
		bne 	norecord		// But only  if this word is suit us
		cbnz 	w12, space
		b 		record
newstring:
		cbnz 	w1, othersymbol	// If we should record last word
		cbz 	w12, norecord	// If 	
		strb	w10, [x7], #1
		mov 	w12, #0
		b 		norecord
emptystring:
		mov 	w14, '\n'
		strb 	w14, [x7], #1
		b 		norecord
othersymbol:
		mov 	w9, w10
		cmp 	w3,  w4
		bne		cont 	
		cbz 	w12, space 		// Checking for addition space symbol
		mov 	w14, ' '
		str 	w14, [x7], #1
space:
		cmp		w3, w4
		bne		emptystring
		cmp 	w9, '\n'
		beq 	record
		strb 	w9, [x7], #1
record:
		mov 	x13, x5
		sub 	x13, x13, #1
		cmp 	x6, x13
		beq 	endrecord
		ldrb 	w10, [x6], #1
		strb 	w10, [x7], #1
		b		record
endrecord:
		mov 	w12, #1
cont:
		cmp 	w9, '\n'
		bne 	norecord
		cbz 	w12, norecord
		strb	w9, [x7], #1
		mov 	w12, #0
norecord:
		mov 	x6, x5
		mov		w3, #0
		mov 	w4, #0
		mov 	w1, #0
		mov 	w9, ' '
		b		1b
// If we are at the end and the word hasn,t been recorded, there is a change we cut the word
checkcut:
		cmp 	x5, x0
		bgt		6f
		cbz 	w1, 4f			// If a current word is first then go to label 4
		b 		5f				// XOR go to the label 5
// the first letter in a new word
4:	
		mov 	x6, x5
		sub		x6, x6, #1
		mov 	w4, w10
		mov 	w3, w4
		mov 	w1,  #1
		b		1b				// Read the next symbol
// No first letter in an old word
5:
		mov 	w4, w10			// Cause we think the last reading letter is the last letter of a current word
		b 		1b
// There is a chance the word has been cut
6:
		sub		x11, x5, x6		// Define dispacement from start address
		sub 	x11, x11, #1
		str 	x11, [x29, disp]	
		mov 	x13, bufin
		add 	x13, x29, x13
L0:
		ldrb 	w10, [x6], #1
		strb 	w10, [x13], #1 
		cmp 	x5, x6
		bne 	L0	
// If we have finished processing the buffer
7:
		mov		x16, bufout
		add 	x1, x29, x16	// x1 - Start address of bufout
		sub		x2, x7, x1		// The lenth of bufout: x7 - x1
		cbz 	x2, 0b			// If the bufout is empty then we don't print  anything
		str 	x2, [x29, tmp]	// Save the bufout length in tmp (cause we could print less than expected )
// Print the bufout on screen and repeat the main cycle
8:	 
		mov		x0, #2
		mov 	x8, #64
		svc		#0				// Print the bufout on screen
		cmp 	x0, #0
		blt 	9f				// If an error then exit from procedure, recovery x29 and x30 and save error code 
		ldr 	x2, [x29, tmp]	// If it successfully then recovery a real length from Stack
		cmp 	x0, x2 
		beq 	0b				// if these lengths are equal then everything is fine
		mov 	x16, bufout		// If not then construct new data for recording
		add 	x1, x29, x16	// x1 - start addredd of bufout
		add 	x1, x1, x16		// Adding to x1 with count which was recorded in the last time
		sub 	x2, x2, x0		// x2 - Lenght of the record remainder
		str 	x2, [x29, tmp]	// Remember a current lenght of bufout to tmp
		b		8b				// Repeate record again
9:
		ldr 	x0, [x29, fd]
		mov 	x8, #57
		svc		#0
		ldp 	x29, x30, [sp]	// Recovery CP and Frame Pointer
		mov 	x16, size
		add 	sp, sp, x16		// 
		ret						// Exit from procedure
		.size 	work, .-work


		.type 	errors, %function
		.data
nofile:
		.string "No such file or derictory\n"
		.equ 	nofilelen, .-nofile
permission:
		.string "Permission denied\n"
		.equ 	permissionlen, .-permission
unknown:
		.string "Unknown error\n"
		.equ 	unknownlen, .-unknown
		.text
		.align 2
errors:
		cmp		x0, #-2			// No such file or directory
		bne 	0f
		adr		x1, nofile
		mov		x2, nofilelen
		b 		2f
0:
		cmp 	x0, #-13		// Permission denied
		bne 	1f
		adr		x1, permission
		mov 	x2, permissionlen
		b		2f
1:
		adr		x1, unknown		// Other type of error
		mov 	x2, unknownlen
2:
		mov 	x0, #2			// Print error on screen			
		mov 	x8, #64
		svc		#0
		ret
		.size errors, .-errors
