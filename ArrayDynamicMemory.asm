# Assembly directives
.data														# Holds memory that has been allocated to the program just as it starts
unsorted_converted_int_to_string: .space 512				# Bytes alloted for string version of the number
sorted_converted_int_to_string: .space 512					# Bytes alloted for string version of the number
unsorted_destination_string: .space 512
sorted_destination_string: .space 512

msg_greeting:
	.ascii "********************************************************************************\n"
	.ascii "This program will display 3 sorting algorithms using array dynamic memory.\n"
	.asciiz "********************************************************************************\n"

msg_newline: .asciiz "\n"
msg_space: .asciiz " "

msg_instruction:
	.ascii "-- The next screen will ask you enter the array size --\n\n"
	.ascii "** RULES! **\n"
	.ascii "1. Input has to be greater than 0.\n"
	.ascii "2. Input cannot have characters.\n"
	.ascii "3. Input cannot be blank.\n"
	.asciiz "4. Have FUN!\n"

msg_algorithm_choice:
	.ascii "-- Choose sorting algorithm --\n\n"
	.ascii "1. MergeSort\n"
	.ascii "2. QuickSort\n"
	.asciiz "3. SelectionSort\n"

msg_input_cannot_be_negative: .asciiz "Try again. Input has to be greater than 0 :D "
msg_input_cannot_have_characters: .asciiz "Try again. Input cannot have characters ;)"
msg_input_cannot_be_blank: .asciiz "Try again. Input cannot be blank :p"
msg_enter_array_length: .asciiz "Enter array size:"
msg_enter_array_element: .asciiz "Enter array element:"
msg_enter_valid_choice: .asciiz "Enter from valid choice:\n1, 2, or 3\n"

msg_unsorted_array: .asciiz "-- UNSORTED ARRAY --\n"
msg_sorted_array: .asciiz "-- SORTED ARRAY --\n"
msg_mergesort: .asciiz "-- Items will be sorted using MERGESORT --\n"
msg_quicksort: .asciiz "-- Items will be sorted using QUICKSORT --\n"
msg_selectionsort: .asciiz "-- Items will be sorted using SELECTIONSORT --\n"

.text
main:
	jal procedureWelcomeMenu
	
	# Request array length
	# Input: none
	# Output: $v0 -> array length
	jal procedureUserInput
	
	# Move $v0 (array length) to argument register
	move $a0, $v0

	# Input: $a0 -> array length
	# Output: $v0 -> array start address
	jal procedureCreateDynamicArray

	# Move $v0 (array start address) to temporary register
	move $t0, $v0
	# Move $a0 (array length) to argument1 register
	move $a1, $a0
	# Move $t0 (array start address) to argument register
	move $a0, $t0
	
	# Initialize temporary flag to 0 before running procedurePrintIntegerArray
	li $t8, 0
	# Input: $a0 -> array start address
	# Input: $a1 -> array length
	# Input: $t8 -> 0
	jal procedurePrintIntegerArray
	
	# Move (array start address) to temporary register
	move $t0, $a0
	# Move (array length) to temporary register
	move $t1, $a1

	# Caller-save $t0 (array start address) and $t1 (array length) to stack before calling procedure
	# Add to stack
	addi $sp, $sp, -12										# Allocate memory in stack: $sp = $sp + (-12)
	sw $ra, 8($sp)											# Push return address register to stack: 8($sp) = $ra
	sw $t1, 4($sp)											# Push temporary to stack: 4($sp) = $t1
	sw $t0, 0($sp)											# Push temporary to stack: 0($sp) = $t0

	# Input: none
	# Output: $v0 -> selected choice
	jal procedureChooseAlgorithm
	
	###############################################################################

	##########################
	#       MergeSort        #
	##########################
	# if ($v0 == 1) then go to run_merge_sort
	beq $v0, 1, run_merge_sort
		j exit_run_merge_sort

	run_merge_sort:
		# Multiply array length by 4 to get the size of the elements
		sll $a1, $a1, 2										# Shift left logical: $a1 = $a1 * 2^2
		# Calculate the array end address
		add $a1, $a0, $a1

		# Input: $a0 -> array start address
		# Input: $a1 -> array end address
		jal procedureMergeSort
		j exit_choice_algorithm
	
	exit_run_merge_sort:

	##########################
	#       QuickSort        #
	##########################
	# if ($v0 == 2) then go to run_selection_sort
	beq $v0, 2, run_quick_sort
		j exit_run_quick_sort
	
	run_quick_sort:
		# This will be the "high" which is the last index
		addi $a3, $a1, -1
		# Move (array start address) to argument1 register
		move $a1, $a0
		# This will be the "low" which is index 0
		addi $a2, $0, 0

		# Input: $a1 -> array start address
		# Input: $a2 -> low which is index 0
		# Input: $a3 -> high which is the last index
		jal procedureQuickSort
		j exit_choice_algorithm
	
	exit_run_quick_sort:

	##########################
	#      SelectionSort     #
	##########################
	# if ($v0 == 3) then go to run_selection_sort
	beq $v0, 3, run_selection_sort
		j exit_run_selection_sort
	
	run_selection_sort:
		# Input: $a0 -> array start address
		# Input: $a1 -> array length
		jal SelectionSort
		j exit_choice_algorithm

	exit_run_selection_sort:

	###############################################################################

	exit_choice_algorithm:
		# Caller-restore $t0 (array start address) and $t1 (array length) from stack after calling procedure
		# Remove from stack
		lw $t0, 0($sp)										# Pop temporary register from stack: $t1 = 0($sp)
		lw $t1, 4($sp)										# Pop temporary register from stack: $t1 = 4($sp)
		lw $ra, 8($sp)										# Pop return address register from stack: $ra = 8($sp)
		addi $sp, $sp, 12									# Deallocate memory in stack: $sp = $sp + 12
		
		# Move (array start address) to argument register
		move $a0, $t0
		# Move (array length) to argument register
		move $a1, $t1
	
	# Initialize temporary flag to 1 before running procedurePrintIntegerArray
	li $t8, 1
	# Input: $a0 -> array start address
	# Input: $a1 -> array length
	# Input: $t8 -> 1
	jal procedurePrintIntegerArray

	jal procedureExitMain


procedureWelcomeMenu:
	# Print msg_greeting
	la $a0, msg_greeting									# Load address: $a0 = @msg_greeting
	la $a1, 1												# Load address: $a1 = 1 (display information message with information icon)
	li $v0, 55												# Load immediate code 55: print MessageDialog service for $a0
	syscall													# Issue a system call to print

	jr $ra													# Jump register: return to caller


procedureUserInput:
	# Add to stack
	addi $sp, $sp, -8										# Allocate memory in stack: $sp = $sp + (-8)
	sw $ra, 4($sp)											# Push value to stack: 4($sp) = $ra
	sw $a0, 0($sp)											# Push value to stack: 0($sp) = $a0

	# Print msg_instruction
	la $a0, msg_instruction									# Load address: $a0 = @msg_instruction
	la $a1, 1												# Load address: $a1 = 1 (display information message with information icon)
	li $v0, 55												# Load immediate code 55: print MessageDialog service for $a0
	syscall													# Issue a system call to print
	
	# Initialize temporary FLAG to 0 before running procedureInputValidation
	li $t8, 0

	jal procedureInputValidation

	# Remove from stack
	lw $a0, 0($sp)											# Pop value from stack: $a0 = 0($sp)
	lw $ra, 4($sp)											# Pop value from stack: $ra = 4($sp)
	addi $sp, $sp, 8										# Deallocate memory in stack: $sp = $sp + 8
	
	jr $ra													# Jump register: return to caller


procedureInputValidation:
	# Add to stack
	addi $sp, $sp, -12										# Allocate memory in stack: $sp = $sp + (-12)
	sw $ra, 8($sp)											# Push return address register to stack: 8($sp) = $ra
	sw $a1, 4($sp)											# Push argument register to stack: 4($sp) = $a1
	sw $a0, 0($sp)											# Push argument register to stack: 0($sp) = $a0
	
	input_validation_loop:
		# For flag $t8 value:
		# 0 = ask for array length
		# 1 = ask for array element
		# 2 = ask for valid choice for sorting algorithm
		beq $t8, 0, array_length_question					# Branch if equals: if ($t8 == 0) then go to label array_length_question
			j exit_array_length_question
		array_length_question:
			# Print msg_enter_array_length
			la $a0, msg_enter_array_length					# Load address: $a0 = @msg_enter_array_length
			li $v0, 51										# Load immediate code 51: print string service for $a0 and return status value in $a1
			syscall											# Issue a system call to print
			j exit_validation_question

		exit_array_length_question:
		
		beq $t8, 1, element_question						# Branch if equals: if ($t8 == 1) then go to label element_question
			j exit_element_question
		element_question:
			# Print msg_enter_array_element
			la $a0, msg_enter_array_element					# Load address: $a0 = @msg_enter_array_element
			li $v0, 51										# Load immediate code 51: print string service for $a0 and return status value in $a1
			syscall											# Issue a system call to print
			j exit_validation_question

		exit_element_question:

		beq $t8, 2, valid_choice_question					# Branch if equals: if ($t8 == 2) then go to label valid_choice_question
			j exit_valid_choice_question

		valid_choice_question:
			# Print msg_algorithm_choice
			la $a0, msg_algorithm_choice					# Load address: $a0 = @msg_algorithm_choice
			li $v0, 51										# Load immediate code 51: print string service for $a0 and return status value in $a1
			syscall											# Issue a system call to print
			bgt $a0, 3, greater_than_three
				j exit_validation_question
			greater_than_three:
				# Print msg_enter_valid_choice
				la $a0, msg_enter_valid_choice				# Load address: $a0 = @msg_enter_valid_choice
				la $a1, 2									# Load address: $a1 = 2 (display warning message with warning icon)
				li $v0, 55									# Load immediate code 55: print MessageDialog service for $a0
				syscall										# Issue a system call to 
				j valid_choice_question
			j exit_validation_question

		exit_valid_choice_question:

		exit_validation_question:

		# Check InputDialog status for $a1:
		# 0 = OK status
		# -1 = input data cannot be correctly parsed
		# -2 = cancel
		# -3 OK was chosen but no data had been input into field
		beq $a1, 0, is_input_valid							# Branch if equals 0: if ($a1 == 0) then go to label is_input_valid
			beq $a1, -1, input_has_characters				# Branch if equals 0: if ($a1 == -1) then go to label input_has_characters
				j exit_input_has_characters					# Jump to exit_input_has_characters

			input_has_characters:
				# Print msg_input_cannot_have_characters
				la $a0, msg_input_cannot_have_characters	# Load address: $a0 = @msg_input_cannot_have_characters
				la $a1, 2									# Load address: $a1 = 2 (display warning message with warning icon)
				li $v0, 55									# Load immediate code 55: print MessageDialog service for $a0
				syscall										# Issue a system call to print
				j input_validation_loop						# Jump back to the loop and request input again

			exit_input_has_characters:
	
			beq $a1, -2, input_is_cancel					# Branch if equals -2: if ($a1 == -2) then go to label input_is_cancel
				j exit_input_is_cancel						# Jump to exit_input_is_cancel
			input_is_cancel:
				j procedureExitMain							# Jump to procedureExitMain

			exit_input_is_cancel:

			beq $a1, -3, input_is_blank						# Branch if equals 0: if ($a1 == -3) then go to label input_is_blank
			input_is_blank:
				# Print msg_input_cannot_be_blank
				la $a0, msg_input_cannot_be_blank			# Load address: $a0 = @msg_input_cannot_be_blank
				la $a1, 2									# Load address: $a1 = 2 (display warning message with warning icon)
				li $v0, 55									# Load immediate code 55: print MessageDialog service for $a0
				syscall										# Issue a system call to print
				j input_validation_loop						# Jump back to the loop and request input again

		# Test if the input is a nondecreasing integer
		is_input_valid:
			bgtz $a0, input_is_greater_than_zero			# Branch if greater than 0: if ($a0 > 0) then go to label input_is_greater_than_zero
				# Print msg_input_cannot_be_negative
				la $a0, msg_input_cannot_be_negative		# Load address: $a0 = @msg_input_cannot_be_negative
				la $a1, 2									# Load address: $a1 = 2 (display warning message with warning icon)
				li $v0, 55									# Load immediate code 55: print MessageDialog service for $a0
				syscall										# Issue a system call to print
				j input_validation_loop						# Jump back to the loop and request input again
			
			input_is_greater_than_zero:
				# Move validated number to value register location 
				move $v0, $a0								# Move: $v0 = $a0
				j exit_input_validation_loop				# Jump to exit_input_validation_loop	

	exit_input_validation_loop:

	# Remove from stack
	lw $a0, 0($sp)											# Pop argument register from stack: $a0 = 0($sp)
	lw $a1, 4($sp)											# Pop argument register from stack: $a1 = 4($sp)
	lw $ra, 8($sp)											# Pop return address register from stack: $ra = 8($sp)
	addi $sp, $sp, 12										# Deallocate memory in stack: $sp = $sp + 12
	
	jr $ra													# Jump register: return to caller


# Input: $a0 -> array length
procedureCreateDynamicArray:
	# Add to stack
	addi $sp, $sp, -8										# Allocate memory in stack: $sp = $sp + (-8)
	sw $ra, 4($sp)											# Push return address register to stack: 4($sp) = $ra
	sw $a0, 0($sp)											# Push argument register to stack: 0($sp) = $a0

	# Move array length argument to temporary register location
	move $t9, $a0											# Move: $t9 = $a0 (array length)

	# Calculate the length (in bytes) of the dynamic array
	sll $t0, $a0, 2											# Shift left logical: $t0 = $a0 * 2^2
	
	# Dynamic array memory allocation (reserve total bytes)
	move $a0, $t0											# Move: $a0 = $t0
	li $v0, 9												# Load immediate code 9: dynamic memory allocation service for $a0
	syscall													# Issue a system call to reserve memory space
	
	# Move dynamic array base@ to saved register location
	move $s1, $v0											# Move: $s1 = $v0
	
	# Initialize iterator i = 0
	li $t1, 0												# Load immediate: $t1 = 0

	# Initialize temporary FLAG to 1 before running procedureInputValidation
	li $t8, 1

	loop:
		# for (i = 0; i < array length; i++)
		beq $t1, $t9, exit
		
		jal procedureInputValidation						# Jump and link to procedureInputValidation

		move $t2, $v0
		
		sll $t3, $t1, 2										# $t3 = i * 4 offset
		add $s2, $t3, $s1									# $s2 is new base address = offset + original base @
		sw $t2, 0($s2)										# Save element in memory location
		# i++
		addi $t1, $t1, 1									# $t1 = $t1 + 1
		j loop
	exit:

	# Remove from stack
	lw $a0, 0($sp)											# Pop argument register from stack: $a0 = 0($sp)
	lw $ra, 4($sp)											# Pop return address register from stack: $ra = 4($sp)
	addi $sp, $sp, 8										# Deallocate memory in stack: $sp = $sp + 12
	
	# Move dynamic array base@ from saved register to value register
	move $v0, $s1											# Move: $v0 = $s1
	
	jr $ra													# Jump register: return to caller


# Input: $a0 -> array start address
# Input: $a1 -> array length
procedurePrintIntegerArray:
	# Add to stack
	addi $sp, $sp, -12										# Allocate memory in stack: $sp = $sp + (-12)
	sw $ra, 8($sp)											# Push return address register to stack: 8($sp) = $ra
	sw $a1, 4($sp)											# Push argument register to stack: 4($sp) = $a1
	sw $a0, 0($sp)											# Push argument register to stack: 0($sp) = $a0

	# Move array start address argument register to temporary register
	move $t0, $a0											# Move: $t0 = $a0 (@array)
	# Initialize iterator p
	li $t1, 0												# Load immediate: $t1 = 0
	li $t3, 0
	# Move array length argument location to temporary register location
	move $t2, $a1											# Move: $t2 = $a1 (array_length)

	# Choose destination string from pseudo-boolean $t8
	# Load the string address where converted number will be kept
	beq $t8, 1, choose_sorted_converted_int_to_string
		la $a1, unsorted_converted_int_to_string			# Load address: $a1 = @unsorted_converted_int_to_string
		j exit_choose_sorted_converted_int_to_string

	choose_sorted_converted_int_to_string:
		la $a1, sorted_converted_int_to_string				# Load address: $a1 = @sorted_converted_int_to_string
			
	exit_choose_sorted_converted_int_to_string:
	
	for_loop_p:
		# For loop
		blt $t1, $t2, then_p								# for (p = 0; p < array_length), go to then_p
			j exit_for_loop_p								# (else case)
		
		then_p:
			sll $t3, $t1, 2									# Shift left logical: $t3 (offset of @int_array = p * 2^2
			add $t3, $t3, $t0								# Add: $t3 (new base @int_array) = $t3 + @int_array
			

			# Load the number that will be converted to a String
			# Passing $a0 -> integer to convert
			# Passing $a1 -> address of String where converted number will be kept
			lw $a0, 0($t3)									# Load word: $a0 = new @int_array[p * 4]
			
			# Caller save $t0 (array start address), $t1 (iterator p) & $t2 (array length) to stack before calling procedure
			# Add to stack
			addi $sp, $sp, -20								# Allocate memory in stack: $sp = $sp + (-20)
			sw $ra, 16($sp)									# Push return address register to stack: 16($sp) = $ra
			sw $t8, 12($sp)									# Push temporary register to stack: 12($sp) = $t8
			sw $t2, 8($sp)									# Push temporary register to stack: 8($sp) = $t2
			sw $t1, 4($sp)									# Push temporary register to stack: 4($sp) = $t1
			sw $t0, 0($sp)									# Push temporary register to stack: 0($sp) = $t0
			
			jal procedureIntegerToString					# Jump and link to procedureIntegerToString

			lw $t8, 12($sp)									# Pop temporary register from stack: $t8 = 12($sp)
			
			# Choose destination string from pseudo-boolean $t8
			beq $t8, 1, choose_sorted_destination_string
				la $a0, unsorted_destination_string			# Load address: $a0 = @unsorted_destination_string
				la $a1, unsorted_converted_int_to_string	# Load address: $a1 = @unsorted_converted_int_to_string
				j exit_choose_sorted_destination_string

			choose_sorted_destination_string:
				la $a0, sorted_destination_string			# Load address: $a0 = @sorted_destination_string
				la $a1, sorted_converted_int_to_string		# Load address: $a1 = @sorted_converted_int_to_string
			
			exit_choose_sorted_destination_string:
			
			# String concatenation
			# Destination: $a0
			# Source1: $a1
			# Source2: $a2
			la $a2, msg_space
			
			# Caller save $t0, $t1 & $t2 to stack before calling procedure
			# Add to stack
			addi $sp, $sp, -16								# Allocate memory in stack: $sp = $sp + (-16)
			sw $ra, 12($sp)									# Push return address register to stack: 12($sp) = $ra
			sw $t2, 8($sp)									# Push temporary register to stack: 8($sp) = $t2
			sw $t1, 4($sp)									# Push temporary register to stack: 4($sp) = $t1
			sw $t0, 0($sp)									# Push temporary register to stack: 0($sp) = $t0
			
			jal procedureStringConcatenation				# Jump and link to procedureStringConcatenation
			
			# Caller restore $t0, $t1 & $t2 from stack after calling procedure
			# Remove from stack
			lw $t0, 0($sp)									# Pop temporary register from stack: $t0 = 0($sp)
			lw $t1, 4($sp)									# Pop temporary register from stack: $t1 = 4($sp)
			lw $t2, 8($sp)									# Pop temporary register from stack: $t2 = 8($sp)
			lw $ra, 12($sp)									# Pop return address register from stack: $ra = 12($sp)
			addi $sp, $sp, 16								# Deallocate memory in stack: $sp = $sp + 16


			# Caller restore $t0, $t1 & $t2 from stack after calling procedure
			# Remove from stack
			lw $t0, 0($sp)									# Pop temporary register from stack: $t0 = 0($sp)
			lw $t1, 4($sp)									# Pop temporary register from stack: $t1 = 4($sp)
			lw $t2, 8($sp)									# Pop temporary register from stack: $t2 = 8($sp)
			lw $t8, 12($sp)									# Pop temporary register from stack: $t8 = 12($sp)
			lw $ra, 16($sp)									# Pop return address register from stack: $ra = 16($sp)
			addi $sp, $sp, 20								# Deallocate memory in stack: $sp = $sp + 20
			
			# p++
			addi $t1, $t1, 1								# Add immediate: $t1 = $t1 + 1

			j for_loop_p									# Jump back to for_loop_p to test condition

		exit_for_loop_p:
			beq $t8, 1, print_sorted						# If ($t8 == true) then go to print_sorted
				# Load the string address where converted number is kept
				la $a1, unsorted_destination_string			# Load address: $a1 = @unsorted_destination_string
				# Print msg_unsorted_array
				la $a0, msg_unsorted_array					# Load address: $a0 = @msg_unsorted_array
				li $v0, 59									# Load immediate code 59: print MessageDialogString service for $a0 & $a1
				syscall										# Issue a system call to print
				j exit_print_sorted

			print_sorted:
				# Load the string address where converted number is kept
				la $a1, sorted_destination_string			# Load address: $a1 = @sorted_destination_string
				# Print msg_sorted_array
				la $a0, msg_sorted_array					# Load address: $a0 = @msg_sorted_array
				li $v0, 59									# Load immediate code 59: print MessageDialogString service for $a0 & $a1
				syscall										# Issue a system call to print

			exit_print_sorted:
				

	# Remove from stack
	lw $a0, 0($sp)											# Pop argument register from stack: $a0 = 0($sp)
	lw $a1, 4($sp)											# Pop argument register from stack: $a1 = 4($sp)
	lw $ra, 8($sp)											# Pop return address register from stack: $ra = 8($sp)
	addi $sp, $sp, 12										# Deallocate memory in stack: $sp = $sp + 12

	jr $ra													# Jump register: return to caller


# Input: $a0 -> Destination
# Input: $a1 -> Source1
# Input: $a2 -> Source2
procedureStringConcatenation:
	# Add to stack
	addi $sp, $sp, -4										# Allocate memory in stack: $sp = $sp + (-4)
	sw $ra, 0($sp)											# Push value to stack: 0($sp) = $ra

	# Concatenate first part of string
	string_concatenation_first:
		lb $t0, ($a1)										# Load byte: $t0 = 0($a1)
		beqz $t0, string_concatenation_second				# Branch if equal zero: if ($t0 == 0) then go to string_concatenation_second
			sb $t0, ($a0)									# Store byte: 0($a0) = $t0
			addi $a1, $a1, 1
        	addi $a0, $a0, 1
			j string_concatenation_first

	# Concatenate second part of string
	string_concatenation_second:
		lb $t0,($a2)										# Load byte: $t0 = 0($a2)
		beqz $t0, exit_string_concatenation					# Branch if equal zero: if ($t0 == 0) then go to exit_string_concatenation
			sb $t0, ($a0)
			addi $a2, $a2, 1
			addi $a0, $a0, 1
			j string_concatenation_second
	
	exit_string_concatenation:

	# Remove from stack
	lw $ra, 0($sp)											# Pop value from stack: $ra = 0($sp)
	addi $sp, $sp, 4										# Deallocate memory in stack: $sp = $sp + 4

	jr $ra


# Input: $a0 -> [integer to convert]
# Input: $a1 -> @converted_int_to_string (address of string where converted number will be kept)
procedureIntegerToString:
	# Add to stack
	addi $sp, $sp, -16										# Allocate memory in stack: $sp = $sp + (-16)
	sw $ra, 12($sp)											# Push return address register to stack: 12($sp) = $ra
	sw $a1, 8($sp)											# Push argument register to stack: 8($sp) = $a1
	sw $a0, 4($sp)											# Push argument register to stack: 4($sp) = $a0
	sw $t0, 0($sp)											# Push temporary register to stack: 0($sp) = $t0

	# Convert nunber to string
	bltz $a0, negative_number								# Branch if less than 0: if ($a0 < 0) then go to label negative_number
		j next0												# else, goto 'next0'

	# Convert negative number if found in array
	negative_number:
		li $t0, '-'											# Load immediate: $t0 = '-'
		sb $t0, ($a1)										# Store byte: @convertedString = $t0 (ASCII of '-')
		addi $a1, $a1, 1									# Add immediate: $a1 = $a1 + 1 (@convertedString++)
		li $t0, -1											# Load immediate: $t0 = -1 (prepare for negative multiplication)
		mul $a0, $a0, $t0									# Multiply: $a0 = $a0 * $t0 (num *= -1)

	next0:
		li $t0, -1											# Load immediate: $t0 = -1
		addi $sp, $sp, -4									# Allocate memory in stack: $sp = $sp + (-4)
		sw $t0, ($sp)										# Push temporary register to stack: 0($sp) = $t0

	push_digits:
		blez $a0, next1										# if([integer to convert] < 0) then go to label next1
			li $t0, 10										# Load immediate: $t0 = 10
			div $a0, $t0									# [integer to convert] / 10
			# Remainder
			mfhi $t0										# $t0 = [integer to convert] % 10
			# Quotient
			mflo $a0										# [integer to convert] = [integer to convert] / 10  
			addi $sp, $sp, -4								# Allocate memory in stack: $sp = $sp + (-4)
			sw $t0, ($sp)									# Push temporary register to stack: 0($sp) = $t0
			j push_digits

		next1:
			lw $t0, ($sp)									# Pop temporary register from stack: $t0 = 0($sp)
			addi $sp, $sp, 4								# Deallocate memory in stack: $sp = $sp + 4
			bltz $t0, neg_digit								# Branch if less than 0: (if ([integer to convert] < 0) then go to neg_digit
				j pop_digits

		neg_digit:
			li $t0, '0'
			sb $t0, ($a1)									
			addi $a1, $a1, 1								# str++
			j next2

		pop_digits:
			bltz $t0, next2									# if([integer to convert] < 0) then go to label next2
				# Add the ASCII 
				addi $t0, $t0, '0'							# Add immediate: $t0 = $t0 + '0'
				sb $t0, ($a1)								# Store byte: 0($a1) = char
				addi $a1, $a1, 1							# str++
				lw $t0, ($sp)								# Pop temporary register from stack: $t0 = 0($sp)
				addi $sp, $sp, 4							# Deallocate memory in stack: $sp = $sp + 4
				j pop_digits

		next2:
			sb $zero, ($a1)									# Store byte: 0($a1) = 0
			
			# Concatenate space after number gets converted
			li $t0, ' '
        	sb $t0, 0($a1)
        	addi $a1, $a1, 1
	
	# Remove from stack
	lw $t0, 0($sp)											# Pop temporary register from stack: $t0 = 0($sp)
	lw $a0, 4($sp)											# Pop argument register from stack: $a0 = 4($sp)
	lw $a1, 8($sp)											# Pop argument register from stack: $a1 = 8($sp)
	lw $ra, 12($sp)											# Pop return address register from stack: $ra = 12($sp)
	addi $sp, $sp, 16										# Deallocate memory in stack: $sp = $sp + 16
	
	jr $ra													# jump to caller


# Input: none
# Output: $v0 -> selected choice
procedureChooseAlgorithm:
	# Add to stack
	addi $sp, $sp, -12										# Allocate memory in stack: $sp = $sp + (-12)
	sw $ra, 8($sp)											# Push return address register to stack: 8($sp) = $ra
	sw $a1, 4($sp)											# Push argument register to stack: 4($sp) = $a1
	sw $a0, 0($sp)											# Push argument register to stack: 0($sp) = $a0

	# Initialize temporary FLAG to 2 before running procedureInputValidation
	li $t8, 2

	jal procedureInputValidation
	
	# Move (input choice) to temporary register
	move $t0, $v0
	
	#############################################
	# Test $t0 value to display message         #
	# 1=mergesort, 2=quicksort, 3=selectionsort #
	#############################################
	
	beq $t0, 1, selected_MergeSort
		j exit_selected_MergeSort
	selected_MergeSort:
		# Print msg_mergesort
		la $a0, msg_mergesort
		la $a1, 1											# Load address: $a1 = 1 (display information message with information icon)
		li $v0, 55											# Load immediate code 55: print MessageDialog service for $a0
		syscall												# Issue a system call to print
		j exit_selection_choice_algorithm

	exit_selected_MergeSort:
	
	beq $t0, 2, selected_QuickSort
		j exit_selected_QuickSort
	selected_QuickSort:
		# Print msg_quicksort
		la $a0, msg_quicksort
		la $a1, 1											# Load address: $a1 = 1 (display information message with information icon)
		li $v0, 55											# Load immediate code 55: print MessageDialog service for $a0
		syscall												# Issue a system call to print
		j exit_selection_choice_algorithm
	
	exit_selected_QuickSort:

	beq $t0, 3, selected_SelectionSort
		j exit_selected_SelectionSort
	selected_SelectionSort:
		# Print msg_selectionsort
		la $a0, msg_selectionsort
		la $a1, 1											# Load address: $a1 = 1 (display information message with information icon)
		li $v0, 55											# Load immediate code 55: print MessageDialog service for $a0
		syscall												# Issue a system call to print
		j exit_selection_choice_algorithm
	
	exit_selected_SelectionSort:
	
	exit_selection_choice_algorithm:
	
	# Move temporary register (input choice) to return to caller
	move $v0, $t0

	# Remove from stack
	lw $a0, 0($sp)											# Pop argument register from stack: $a0 = 0($sp)
	lw $a1, 4($sp)											# Pop argument register from stack: $a1 = 4($sp)
	lw $ra, 8($sp)											# Pop return address register from stack: $ra = 8($sp)
	addi $sp, $sp, 12										# Deallocate memory in stack: $sp = $sp + 12
	
	jr $ra													# jump to caller


# Input: $a0 -> array start address
# Input: $a1 -> array end address
procedureMergeSort:
	# Add to stack
	addi $sp, $sp, -16										# Allocate memory in stack: $sp = $sp + (-16)
	sw $ra, 0($sp)											# Push return address register to stack: 0($sp) = $ra
	sw $a0, 4($sp)											# Push argument register to stack: 4($sp) = $a0
	sw $a1, 8($sp)											# Push argument register to stack: 8($sp) = $a1

	# Calculate middle = [start address + (end address - start address)/2]
	# (end address - start address)
	sub $t0, $a1, $a0										# Subtract: $t0 = $a1 - $a0	

	# Base case when array contains one element
	ble $t0, 4, base_case									# Branch if less than or equal to: $t0 <= 1 (4 bytes)
		# Divide array address by half (8 bytes) -> (end address - start address)/2
		srl $t0, $t0, 3										# Shift right logical: $t0 = $t0 / 2^3
		sll $t0, $t0, 2										# Multiple that number by 4 to get half of the array size (shift left 2 bits)
		# Calculate middle address of array
		add $a1, $a0, $t0									# Add: $a1 = $a0 + $t0

		# Add to stack
		# Save middle address of array
		sw $a1, 12($sp)										# Push argument register to stack: 12($sp) = $a1
	
		jal procedureMergeSort								# Jump and link to procedureMergeSort

		# Remove from stack
		# Restore $a0 (middle address) and $a1 (end address) of array
		lw $a0, 12($sp)										# Pop argument register from stack: $a0 = 12($sp)
		lw $a1, 8($sp)										# Pop argument register from stack: $a1 = 8($sp)

		jal procedureMergeSort								# Jump and link to procedureMergeSort

		# Remove from stack
		# Restore $a0 (start address), $a1 (middle address), and $a2 (end address) of array
		lw $a0, 4($sp)										# Pop argument register from stack: $a0 = 4($sp)
		lw $a1, 12($sp)										# Pop argument register from stack: $a1 = 12($sp)
		lw $a2, 8($sp)										# Pop argument register from stack: $a2 = 8($sp)

		jal procedureMerge									# Jump and link to procedureMerge

	base_case:
		# Remove from stack
		lw $ra, 0($sp)										# Pop return address register from stack: $ra = 0($sp)
		addi $sp, $sp, 16									# Deallocate memory in stack: $sp = $sp + 16
		jr $ra												# Jump register: return to caller


# Input: $a0 -> first array start address
# Input: $a1 -> second array start address
# Input: $a2 -> second array end address
procedureMerge:
	# Add to stack
	addi $sp, $sp, -16										# Allocate memory in stack: $sp = $sp + (-16)
	sw $ra, 0($sp)											# Push return address register to stack: 0($sp) = $ra
	sw $a0, 4($sp)											# Push argument register to stack: 4($sp) = $a0
	sw $a1, 8($sp)											# Push argument register to stack: 8($sp) = $a1
	sw $a2, 12($sp)											# Push argument register to stack: 12($sp) = $a2

	# Move ($a0) first half array start address to save register
	move $s0, $a0											# Move: $s0 = $a0
	# Move ($a1) second half array start address to save register
	move $s1, $a1											# Move: $s1 = $a1

		merge_loop:
			# Load first half of array
			la $t0, 0($s0)
			# Load second half of array
			la $t1, 0($s1)		
			# Load value of first half
			lw $t0, 0($t0)
			# Load value of second half
			lw $t1, 0($t1)

			# If the lower value is already first, don't shift
			bgt $t1, $t0, do_not_shift						# Branch if greater than: if ($t1 > $t0) go to do_not_shift
				move $a0, $s1								# Load the argument for the element to move
				move $a1, $s0								# Load the argument for the address to move it to
	
				# Shift the element to the new position
				jal procedureShift
	
				# Increment the second half index
				addi $s1, $s1, 4							
			do_not_shift:
				# Increment the first half index
				addi $s0, $s0, 4							
	
				lw $a2, 12($sp)								# Pop argument register from stack: $a2 = 12($sp)
				bge $s0, $a2, exit_merge_loop_at_end		# End the loop when both halves are empty
				bge $s1, $a2, exit_merge_loop_at_end		# End the loop when both halves are empty
					j merge_loop
	
				exit_merge_loop_at_end:
					lw $ra, 0($sp)							# Load the return address
					addi $sp, $sp, 16						# Deallocate memory in stack: $sp = $sp + 16
					jr $ra									# Jump register: return to caller


# Shift an array element to another position, at a lower address
# Input: $a0 -> address of element to shift
# Input: $a1 -> destination address of element
procedureShift:
	shift_loop:
		li $t0, 10
		# Stop shift if at location
		ble $a0, $a1, exit_shift_loop						# Branch if equal: ($a0 == $a1) then go to exit_shift_loop
			addi $t6, $a0, -4								# Find the previous address in the array
			lw $t7, 0($a0)									# Get the current pointer
			lw $t8, 0($t6)									# Get the previous pointer
			sw $t7, 0($t6)									# Save the current pointer to the previous address
			sw $t8, 0($a0)									# Save the previous pointer to the current address
			move $a0, $t6									# Shift the current position back
			j shift_loop									# Loop again

		exit_shift_loop:

		jr $ra												# Jump register: return to caller


# Input: $a1 -> array start address
# Input: $a2 -> low which is index 0
# Input: $a3 -> high which is the last index
procedureQuickSort:
	addi $sp, $sp, -8										# make space in the stack
	sw $s0, 4($sp)											# push $s0 to the stack
	sw $ra, 0($sp)											# push $ra to the stack
	
	bge $a2, $a3, lowNotLessThanHigh						# if the low is greater than or equal to the high, go to lowNotLessThanHigh 
	
		jal procedurePartition
		
		move $s0, $a3										# temporarilty store the third argument in $s0
		addi $a3, $v1, -1									# subtract one from returned value of partition and make it the third argument
		jal procedureQuickSort
		
		move $a3, $s0										# restore the old third argument
		addi $a2, $v1, 1									# add one to the returned value of partition and make it the second argument
		jal procedureQuickSort
	
	lowNotLessThanHigh:
	
	lw $ra, 0($sp)											# pop $ra from the stack
	lw $s0, 4($sp)											# pop $s0 from the stack
	addi $sp, $sp, 8										# restore stack pointer
	
	jr $ra													# jump back to caller


procedurePartition:
	addi $sp, $sp, -28										# make nickspace in the stack
	sw $t0, 24($sp)											# push $t0 to the stack
	sw $t1, 20($sp)											# push $t1 to the stack
	sw $t2, 16($sp)											# push $t2 to the stack
	sw $s0, 12($sp)											# push $s0 to the stack
	sw $s1, 8($sp)											# push $s1 to the stack
	sw $s2, 4($sp)											# push $s2 to the stack
	sw $ra, 0($sp)											# push $ra to the stack
	
	sll $s1, $a3, 2											# calculate offset for high index of array, high*4
	add $s1, $a1, $s1 										# calculate base plus offset for array, base + high*4
	lw $s1, 0($s1)											# load element at high index of array, which will be the pivot, $s1 = arr[high]
	
	addi $t1, $a2, -1										# calculate the index of the smaller element, $t1 = low-1
	
	move $t0, $a2											# instantiate iteration counter as the low index, $t0 = low
	for_loop:
		bge $t0, $a3, end_for_loop							# if $t0 >= high index then jump to end_for_loop 
	
		sll $s0, $t0, 2										# calculate offset, $t0*4
		add $s0, $s0, $a1									# caluclate offset plus base, base + $t0*4
		lw $s0, 0($s0)										# load element at index $t0 from the array into $s0

		# if element at index $t0 is greater than the pivot, go to currentElementNotLessThanOrEqualPivot
		bgt $s0, $s1, currentElementNotLessThanOrEqualPivot
			addi $t1, $t1, 1								# increment $t1 by 1
			
			sll $s2, $t1, 2									# calculate offset, $t1*4
			add $t2, $s2, $a1								# calculate offset plus base, $t1*4 + base
			lw $s2, 0($t2)									# load array element at index $t1 into $s2
			
			sw $s0, 0($t2)									# save $s0 into array element of index $t1
			
			sll $s0, $t0, 2									# calculate offset, $t0*4
			add $s0, $s0, $a1								# caluclate offset plus base, $t0*4 + base
			sw $s2, 0($s0)									# save $s2 in array index of $t0
			
		currentElementNotLessThanOrEqualPivot:
		
		addi $t0, $t0, 1									# increment iteration counter by 1, $t0 = $t0 + 1
		j for_loop											# jump to for_loop
	end_for_loop:
	
	addi $t1, $t1, 1										# increment $t1 by 1
	
	sll $s2, $t1, 2											# calculate offset, $t1*4
	add $t2, $s2, $a1										# calculate offset plus base, $t1*4 + base
	lw $s2, 0($t2)											# load array element at $t1 into $s2
	
	sll $s1, $a3, 2											# calculate offset for high index of array, high*4
	add $s0, $a1, $s1 										# calculate base plus offset for array, base + high*4
	lw $s1, 0($s0)											# load element at high index of array into $s1, which will be the pivot, $s1 = arr[high]

	sw $s1, 0($t2)											# store pivot element into index $t1
	sw $s2, 0($s0)											# store $s2 into high index of array
	
	move $v1, $t1											# return $t1

	lw $ra, 0($sp)											# pop $ra from the stack
	lw $s2, 4($sp)											# pop $s2 from the stack
	lw $s1, 8($sp)											# pop $s1 from the stack
	lw $s0, 12($sp)											# pop $s0 from the stack
	lw $t2, 16($sp)											# pop $t2 from the stack
	lw $t1, 20($sp)											# pop $t1 from the stack
	sw $t0, 24($sp)											# pop $t0 from the stack
	addi $sp, $sp, 28										# restore stack pointer

	jr $ra													# jump back to caller


# Input: $a0 -> array start address
# Input: $a1 -> array length
SelectionSort:
 			# Add to stack
			addi $sp, $sp, -12								# Allocate memory in stack: $sp = $sp + (-12)
			sw $ra, 8($sp)									# Push return address register to stack: 8($sp) = $ra
			sw $a1, 4($sp)									# Push argument register to stack: 4($sp) = $a1
			sw $a0, 0($sp)
 
 			li $t0, 0										# make $t0 as a index i and initilize 0
 			
 			sortArrayOutterLoop:
				beq $t0, $a1, exitSortArrayOutterLoop
				sll $t1, $t0, 2 							# index i * 4
				addi $t3, $t0, 1							# $t3 = j (for inner loop)
				
				sortArrayInnerLoop:
		 			beq $t3, $a1, exitSortArrayInnerLoop
		 			
		 			add $t2, $a0, $t1						# $t2 is a new base address for element i
					lw $s4, 0($t2)							# Save the current element in the array in $s4
		 			
		 			sll $t4, $t3, 2							# make $t4 = 4 * j
		 			add $t5, $t4, $a0						# make $t5 as a new base address for the next element	 	
		 			lw $s5, 0($t5) 							# Load the next element from Array in $s5

		 			blt  $s5, $s4, swap				# If the next element is less than current element then go to swap
					j dontSwap
					
						swap:
							sw $s5, 0($t2)					# Store the lowest value in the lowest address
							sw $s4, 0($t5)					# Store the highest value in highest address
						
					dontSwap:
					
     						addi $t3, $t3, 1				# Increment the index for inner loop
     						j sortArrayInnerLoop
     			
     				exitSortArrayInnerLoop:
     		
     						addi $t0, $t0, 1				# Increment outter loop index
     						j sortArrayOutterLoop
     		
     			exitSortArrayOutterLoop:

 		exitSelectionsortArray:
 			
 				# Remove from stack
				lw $a0, 0($sp)								# Pop argument register from stack: $a0 = 0($sp)
				lw $a1, 4($sp)								# Pop argument register from stack: $a1 = 4($sp)
				lw $ra, 8($sp)								# Pop return address register from stack: $ra = 8($sp)
				addi $sp, $sp, 12							# Deallocate memory in stack: $sp = $sp + 12

				jr $ra										# Jump register: return to caller
 		
 		
procedureExitMain:
	# Exit program
	li $v0, 10												# Load immediate code 10: exit service for system
	syscall													# Issue a system call to stop program from running

# End of ArrayDynamicMemory.asm
