# Homework 1
# Name: MY_FIRSTNAME MY_LASTNAME (e.g., John Doe)
# Net ID: MY_NET_ID (e.g., jdoe)
# SBU ID: MY_SBU_ID (e.g., 111999888)

.data
# include the file with the test case information
.include "Struct1.asm"  # change this line to test with other inputs

.align 2  # word alignment 

numargs: .word 0
AddressOfNetId: .word 0
AddressOfId: .word 0
AddressOfGrade: .word 0
AddressOfRecitation: .word 0
AddressOfFavTopics: .word 0
AddressOfPercentile: .word 0

err_string: .asciiz "ERROR\n"

newline: .asciiz "\n"

updated_NetId: .asciiz "Updated NetId\n"
updated_Id: .asciiz "Updated Id\n"
updated_Grade: .asciiz "Updated Grade\n"
updated_Recitation: .asciiz "Updated Recitation\n"
updated_FavTopics: .asciiz "Updated FavTopics\n"
updated_Percentile: .asciiz "Updated Percentile\n"
unchanged_Percentile: .asciiz "Unchanged Percentile\n"
unchanged_NetId: .asciiz "Unchanged NetId\n"
unchanged_Id: .asciiz "Unchanged Id\n"
unchanged_Grade: .asciiz "Unchanged Grade\n"
unchanged_Recitation: .asciiz "Unchanged Recitation\n"
unchanged_FavTopics:  .asciiz "Unchanged FavTopics\n"

# Any new labels in the .data section should go below this 

# Helper macro for accessing command line arguments via Label
.macro load_args
    sw $a0, numargs
    lw $t0, 0($a1)
    sw $t0, AddressOfNetId
    lw $t0, 4($a1)
    sw $t0, AddressOfId
    lw $t0, 8($a1)
    sw $t0, AddressOfGrade
    lw $t0, 12($a1)
    sw $t0, AddressOfRecitation
    lw $t0, 16($a1)
    sw $t0, AddressOfFavTopics
    lw $t0, 20($a1)
    sw $t0, AddressOfPercentile
.end_macro

.globl main
.text
main:
    load_args()     # Only do this once
    # Your .text code goes below here
    
    li $t1, 6
    beq $a0, $t1, continue
    
    continue:
    #conversion of ID from string to integer				
    lw $a0, AddressOfId
    li $v0, 84
    syscall
    
    #checking for Student_id to be within [0,999999999]   
    li $t2, 999999999	
    bltz $v0, error     		#if less than zero go to error
    bgt $v0, $t2, error			#if greater than 999999999 go to error
   
    #checking for grades
    lw $a0, AddressOfGrade
    lb $t2, 0($a0) 
    bgt  $t2, 70, error			#if greater than 70 go to error
    blt	 $t2, 65, error  		#if less than 65 go to error

    lb $t2, 1($a0)
    beq $t2, 45, checkRecitation			#checking for the next char to be + or -
    bne $t2, 43, error
  
    

    #checking for recitation being within {8,9,10,11,12,13,14}
    checkRecitation:
    lw $a0, AddressOfRecitation
    li $v0, 84
    syscall 
  
    li $t2, 8	
    li $t3, 14
    blt $v0, $t2, error     		#if less than 8 go to error
    bgt $v0, $t3, error			#if greater than 14 go to error
   
    
    #checking for the validity of Fav Topics 
    lw $a0, AddressOfFavTopics
    lb $t2, 4($a0)
    bnez $t2, error
  
    lb $t2, 0($a0) 
    bne $t2, 48, nextLine1 
    nextLine1: bne $t2, 49, error  
    
    lb $t3, 1($a0)
    bne $t3, 48, nextLine2
    nextLine2: bne $t2, 49, error  
    
    lb $t4, 2($a0)
    bne $t4, 48, nextLine3
    nextLine3: bne $t2, 49, error  
    
    lb $t5, 3($a0)
    bne $t5, 48, nextLine4
    nextLine4: bne $t2, 49, error  
    
    
    #checking for value of percentile 
    lw $a0, AddressOfPercentile
    li $v0, 85
    syscall
    
    #checking for Percentile to be within [0.0, 100.0]   
    li $t2, 0x42c80000	
    bltz $v0, error     		#if less than zero go to error
    bgt $v0, $t2, error			#if greater than 100.0 go to error
   
   
    # part 2
    #checking for updation of data.
    
    #checking for NetId updation
    li $t0, 0				#to store i value
    lw $t1, AddressOfNetId 
    la $t2, NetId
    move $t6, $t1
    
    forLoop: 
    	lb $t3, 0($t1)			#loads the next character in String 1.
    	lb $t4, 0($t2)			#loads the next character in String 2.
    	
    	addi $t1, $t1, 1		#increments the value by one.
    	addi $t2, $t2, 1
    	bne $t3, $t4, printNetidUpdation#if not equal prints updation message.
    	beq $t3, 0, endLoop		#if reached null character ends loop.
    	beq $t4, 0, endLoop
  	j forLoop 
    endLoop:
  
    la $a0, unchanged_NetId
    li $v0, 4
    syscall
    move $s1, $t1
    b Id
   
    printNetidUpdation:
    la $a0, updated_NetId
    li $v0, 4
    syscall
    					#saving the changed value to the address
    la $a0, Student_Data
    sw $t6, 4($a0)
    move $s1, $t1
   
    Id:
    #checking for Id updation
    lw $a0, AddressOfId
    li $v0, 84
    syscall
    move $t6, $v0
   
    la $a0, Student_Data
    lw $t3, 0($a0)
    bne $t3, $v0, printIdUpdation		#print the updation message if id is not the same 
    la $a0, unchanged_Id
    li $v0, 4
    syscall
    move $s2, $t6
    b percentile 
      
    
    printIdUpdation:
    la $a0, updated_Id
    li $v0, 4
    syscall
    la $a0, Student_Data
    sw $t6, 0($a0)
    move $s2, $t6
   
   
    percentile:
    #checking for percentile updation 
    lw $a0, AddressOfPercentile
    li $v0, 85
    syscall
    move $t6, $v0
    
    la $a0, Student_Data
    lw $t3, 8($a0)
    bne $t3, $v0, printPercentileUpdation
    la $a0, unchanged_Percentile
    li $v0, 4
    syscall
    move $s3, $t6
    b grade
    
    
    printPercentileUpdation:
    la $a0, updated_Percentile
    li $v0, 4
    syscall
    la $a0, Student_Data
    sw $t6, 8($a0)
    move $s3, $t6
    
    #checking for Grade Updation
    grade:
    lw $a1, AddressOfGrade
    lb $t3, 0($a1)
    lb $t4, 1($a1)
    move $t6, $t3
    move $t7, $t4
    
    la $a0, Student_Data
    lb $t1, 12($a0)
    bne $t1, $t3, printGradeUpdation
    
    lb $t2, 13($a0)
    bne $t2, $t4, printGradeUpdation
    la $a0, unchanged_Grade
    li $v0, 4
    syscall
    move $s4, $t6
    move $s5, $t7
    b recitation
    
    
    printGradeUpdation:
    la $a0, updated_Grade
    li $v0, 4
    syscall
    la $a0, Student_Data
    sb $t6, 12($a0)
    sb $t7, 13($a0)
    move $s4, $t6
    move $s5, $t7
   
    
    recitation:
    lw $a0, AddressOfRecitation
    li $v0, 84
    syscall 
    move $t3, $v0
    
    la $a0, Student_Data
    lb $t1, 14($a0)
    li $v0, 84
    syscall
    move $t1, $v0
    move $s6, $t1
    sll $t1, $t1, 12			 
    srl $t2, $t1, 12
    
    bne $v0, $t2, printRecitationUpdation
    la $a0, unchanged_Recitation
    li $v0, 4
    syscall
    b favTopics 
    
    printRecitationUpdation:
    la $a0, updated_Recitation
    li $v0, 4
    syscall
    
   favTopics:
   lw $a0, AddressOfFavTopics
    li $v0, 84
    syscall 
    move $t3, $v0
    
    la $a0, Student_Data
    lb $t1, 14($a0)
    li $v0, 84
    syscall
    move $t1, $v0
    
    sll $t1, $t1, 12			 
    srl $t2, $t1, 12
    move $s7, $t1
    
    bne $v0, $t2, printFavTopicsUpdation
    la $a0, unchanged_FavTopics
    li $v0, 4
    syscall
    b toEnd 
    
    printFavTopicsUpdation:
    la $a0, updated_FavTopics
    li $v0, 4
    syscall
      
    toEnd:
   
   
   move $a0, $s1 
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s2
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s3 
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s4 
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s5 
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s6 
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
   
   move $a0, $s4
   li $v0, 34
   syscall
   la $a0, newline
   li $v0, 4
   syscall
  
    b exit
    error:
    li $v0, 4
    la	$a0, err_string
    syscall
     
    exit: 
    li $v0, 10
    syscall 
    
    
    

