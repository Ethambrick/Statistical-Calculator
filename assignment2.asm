########################################################
# CDA3100 - Assignment 2			       #
#						       #
# DO NOT MODIFY any code above the STUDENT_CODE label. #
########################################################
	.data
	.align 0
msg1:	.asciiz "Statistical Calculator!\n-----------------------\n"
msg2:	.asciiz "Average: "
msg3:	.asciiz "Maximum: "
msg4:	.asciiz "Median:  "
msg5:	.asciiz "Minimum: "
msg6:	.asciiz "Sum:     "
msg7:	.asciiz "\n"
msg8:	.asciiz "Elapsed Time: "

	.align 2
array:	.word 91, 21, 10, 56, 35, 21, 99, 33, 13, 80, 79, 66, 52, 6, 4, 53, 67, 91, 67, 90
size:	.word 20 # Size of the array
	.text
	.globl main
	
	# Display the floating-point (%double) value in register (%register) to the user
	.macro display_double (%register)
		li $v0, 3		# Prepare the system for output
		mov.d $f12, %register	# Set the integer to display
		syscall			# System displays the specified integer
	.end_macro
	
	# Display the %integer value to the user
	.macro display_integer (%integer)
		li $v0, 1			# Prepare the system for output
		add $a0, $zero, %integer	# Set the integer to display
		syscall				# System displays the specified integer
	.end_macro
	
	# Display the %string to the user
	.macro display_string (%string)
		li $v0, 4		# Prepare the system for output
		la $a0, %string		# Set the string to display
		syscall			# System displays the specified string
	.end_macro

	# Perform floating-point division %value1 / %value2
	# Result stored in register specified by %register
        .macro fp_div (%register, %value1, %value2)
 		mtc1.d %value1, $f28		# Copy integer %value1 to floating-point processor
		mtc1.d %value2, $f30		# Copy integer %value2 to floating-point processor
		cvt.d.w $f28, $f28		# Convert integer %value1 to double
		cvt.d.w $f30, $f30		# Convert integer %value2 to double
		div.d %register, $f28, $f30	# Divide %value1 by %value2 (%value1 / %value2)
	.end_macro				# Quotient stored in the specified register (%register)
	
main: 	la $a0, array		# Store memory address of array in register $a0
	lw $a1, size		# Store value of size in register $a1
	jal calcAverage		# Call the calcAverage procedure (result is stored in floating-point register $f2
	jal getMax		# Call the getMax procedure
	add $s0, $v0, $zero	# Move maximum value to register $s0
	jal getMin		# Call the getMin procedure
	add $s1, $v0, $zero	# Move minimum value to register $s1
	jal calcSum		# Call the calcSum procedure
	add $s2, $v0, $zero	# Move sum value to register $s2
	jal sort		# Call the sort procedure
	jal calcMedian		# Call the calcMedian procedure (result is stored in floating-point register $f4
	add $a1, $s0, $zero	# Add maximum value to the argumetns for the displayStatistics procedure
	add $a2, $s1, $zero	# Add minimum value to the argumetns for the displayStatistics procedure
	add $a3, $s2, $zero	# Add sum value to the argumetns for the displayStatistics procedure
	jal displayStatistics	# Call the displayResults procedure
exit:	li $v0, 10		# Prepare to terminate the program
	syscall			# Terminate the program
	
# Display the computed statistics
# $a1 - Maximum value in the array
# $a2 - Minimum value in the array
# $a3 - Sum of the values in the array
displayStatistics:
	display_string msg1
	display_string msg6
	display_integer	$a3	# Sum
	display_string msg7
	display_string msg5
	display_integer $a2	# Minimum
	display_string msg7
	display_string msg3
	display_integer $a1	# Maximum
	display_string msg7
	display_string msg2
	display_double $f2	# Average
	display_string msg7
extra_credit:
	display_string msg4
	display_double $f4	# Median
	display_string msg7
	jr $ra
########################################################
# DO NOT MODIFY any code above the STUDENT_CODE label. #
########################################################

# Place all your code in the procedures provided below the student_code label
student_code:

# Calculate the average of the values stored in the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
# Result MUST be stored in floating-point register $f2
calcAverage:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal calcSum #Returned in $v0
	
	move $t0, $v0 #sum
	move $t1, $a1 #size

	fp_div $f2, $t0, $t1 
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	# Return to calling procedure
	
########################################################

# Return the maximum value in the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
# Result MUST be stored in register $v0
getMax:
	
	# max = array[0]
	lw $v0, 0($a0) #hold max
	
	li $t0, 1
	
getMax_loop:
	bge $t0, $a1, getMax_done #exits when x>= size
	
	sll $t1, $t0, 2
	add $t2, $a0, $t1 #address of array[x]
	lw $t3, 0($t2) #value = array[x]
	
	ble $t3, $v0, getMax_skip
	move $v0, $t3 #max = value
	
getMax_skip:
	addi $t0, $t0, 1 #++x
	j getMax_loop

getMax_done:
	jr $ra	# Return to calling procedure
	
########################################################

# Return the minimum value in the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
# Result MUST be stored in register $v0
getMin:
	
	#min = array[0]
	lw $v0, 0($a0) #v0 = min

	li $t0, 1
	
getMin_loop:
	bge $t0, $a1, getMin_done #exits when x>+ size
	
	sll $t1, $t0, 2
	add $t2, $a0, $t1 #address of array[x]
	lw $t3, 0($t2) #value = array[x]
	
	bge $t3, $v0, getMin_skip #when value >= min, skip
	move $v0, $t3 #min = value
	
getMin_skip:
	addi $t0, $t0, 1 #++x
	j getMin_loop

getMin_done:
	jr $ra	# Return to calling procedure

########################################################

# Calculate the sum of the values stored in the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
# Result MUST be stored in register $v0
calcSum:
	li $v0, 0 #sum =0
	li $t0, 0 #x = 0
	
calcSum_loop:
	bge $t0, $a1, calcSum_done #exit when x>= size
	
	sll $t1, $t0, 2
	add $t2, $a0, $t1 #address of array[x]
	lw $t3, 0($t2) #value  = array[x]
	
	add $v0, $v0, $t3 #sum += value
	
	addi $t0, $t0, 1 #++x
	j calcSum_loop
	
calcSum_done:
	jr $ra	# Return to calling procedure
	
########################################################

# Calculate the median of the values stored in the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
# Result MUST be stored in floating-point register $f4
calcMedian:

	jr $ra	# Return to calling procedure
	
########################################################

# Perform the Selection Sort algorithm to sort the array
# $a0 - Memory address of the array
# $a1 - Size of the array (number of values)
sort:
		
	jr $ra	# Return to calling procedure

########################################################

# Swap the values in the specified positions of the array
# $a0 - Memory address of the array
# $a1 - Index position of first value to swap
# $a2 - Index position of second value to swap
swap:
	
	jr $ra	# Return to calling procedure
