.section .data
.balign 4
delayMs: .int   500
delayIn: .int   3000
pin1:    .int   2
pin2:    .int   3
i:       .int   0
OUTPUT   =      1

message_intro: .asciz "Welcome to our Pedestrian-Crossing-System Project, Please enter the amount of time you need to cross the street in seconds: "
number_start : .asciz "Countdown from: %d\n"
integer: .asciz "%d"
timeup:  .asciz  "Time is almost up! Please cross the street now !\n"
output: .asciz "%d\n"

a: .skip 240 // array of 60 bytes (this just reserves us 100 bytes of space, no initialization done
int1: .word 0

.section .text
.balign 4
.global main

main:
	push {r4, lr}
	bl wiringPiSetup

	ldr r0, =message_intro
	bl printf

	ldr r0, =integer
	ldr r1, =int1
	bl scanf

	ldr r0, =number_start
	ldr r1, =int1
	ldr r1, [r1]
	bl printf

	ldr r0, =delayIn
   	ldr r0, [r0]
    	bl delay

	// let's populate our array a of 100 bytes (25 words - 4 bytes to a word)
	ldr r1, =a 	// r1 points to beginning of array - think of this in C++ as a[0]
	mov r2, #0
	mov r3, #0	// register source2, this will be the product of index * (data type size)
	bl a_loop

a_loop:
	ldr r4, =int1
	ldr r4, [r4]
	cmp r2, r4 	// 25 words filled?
	beq a_done 	// if equal, we're done
	//str r2, [r1,+r3]
	add r2, #1	// increment R2 by 1
	bal a_loop	// jump back up to start of loop

a_done:
	// let's output all of the elements of the array with a function named
	// output_array(int a[], int size)
	// R0 = pointer to start of array, R1=size or # of elements in the array
	ldr r0, =a	// R0 contains base address of array
	ldr r4, =int1	// R1 contains number of elements in the array
	ldr r4, [r4]
	//pop {r4}
	bl output_array

output_array:
	push {r4,r5,lr}
	mov r1, #0	// R4 contains starting index for output
	//mov r5, #0

oa_loop:
	cmp r4,#10
	beq light
	cmp r4, #-1 	// Is R4 equal to the number of elements to output?
	beq oa_done	// If so, we're done!
	//push {r0-r3}	// Save our current state of registers R0-R3 since printf won't
	//ldr r2, [r0,+r5]// R1 contains a[R0+R5]
	mov r1, r4	// output our index as well
	ldr r0, =output // R0 contains pointer to our output string
	bl printf

	ldr r0, =delayMs
    	ldr r0, [r0]
    	bl  delay

	//pop {r0-r3}	// Restore state of registers R0-R3 after printf call
	sub r4, #1	// increment our index by 1
	bal oa_loop	// jump back up to oa_loop for next element
oa_done:
	pop {r4,r5}
	//bl light

light:  push    {ip,lr} 
 
        ldr     r0, =timeup      
        bl      printf

        bl      wiringPiSetup
        mov     r1,#-1
        cmp     r0, r1
        bne     init

init:
        ldr     r0, =pin1
        ldr     r0, [r0]
        mov     r1, #OUTPUT
        bl      pinMode

	ldr	r0, =pin2
	ldr	r0, [r0]
	mov	r1, #OUTPUT
	bl	pinMode

       ldr     r4, =i
        ldr     r4, [r4]
        mov     r5, #10

forLoop:
        cmp     r4, r5
        bgt     done

ldr     r0, =pin1
        ldr     r0, [r0]
        mov     r1, #1
        bl      digitalWrite

	ldr	r0, =pin2
	ldr	r0, [r0]
	mov	r1, #1
	bl	digitalWrite

       ldr     r0, =delayMs
        ldr     r0, [r0]
        bl      delay

        ldr     r0, =pin1
        ldr     r0, [r0]
        mov     r1, #0
        bl      digitalWrite

	ldr	r0, =pin2
	ldr	r0, [r0]
	mov	r1, #0
	bl	digitalWrite


        ldr     r0, =delayMs
        ldr     r0, [r0]
        bl      delay

add     r4, #1
        b       forLoop
 
done:
        mov r0, #0
	pop  {r4,r5,ip,pc}
