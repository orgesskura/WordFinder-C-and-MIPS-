
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dict_idx:                 .space 4004    # maximum 1000 words but each word takes 4 bytes

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
 li $t4,0
count:          lb   $t1, grid($t4)          
                addi $v0, $0, 10                # newline \n
                beq  $t1, $v0, begin         # if(c_input == '\n')
                addi $t4, $t4, 1                # idx += 1
                j    count       
        addi $a0,$t4,1                 
begin:   li $t0,-1 # starting index in dictionary
         li $t1,-4 #offset of dict_idx
         li $s7,0  #if I have a match or not variable
         
storeidx: 
          addi $t0,$t0,1       # add 1 to dict idx
          addi $t1,$t1,4       # go to next index in dict_index
          sw $t0,dict_idx($t1) # store index of dictionary in dict_idx
          beq $t1,4000,strFind # if we reach limit of words, we are done
addN:     addi $t0,$t0,1       # add 1 to dict index
          lb $t3,dictionary($t0) # load word from dictionary to t3
          addi $s0,$0,10         # set $s0 to newline
          beq $t3,$s0,storeidx   # if word is newline we get next word on dictionary
          beq $t3,$0,strFind     # if word is '/0' we are done with dictionary
          j addN                 # jump back to get next word in dictionary
strFind: li $s0,-1               # grid idx
         
next:    
         

nextN:  
         addi $s0,$s0,1          # set grid idx to 0
         li $s2,0                # set offset to 0
         li $s1,0                # set dict idx to 0
         
remain:  
         lw $s4,dict_idx($s2)    # load position of offset to $s4  
         lb $s3,dictionary($s4)  # load char from dict idx
         lb $s5,grid($s0)
         addi $a1,$0,10        # load grid idx to $s5
         beq $s5,$a1,decide        # if grid idx is '/0' go to print function
         move $s6,$s0            # copy $s0 to $s6
                     
     
contain: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF      
         addi $s1,$s1,1      # add 1 to dict_idx
         addi $s6,$s6,1      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)
         addi $a0,$0,10
         beq $a0,$s3,print              # load byte from grid 
         beq $s5,$0,decide 
         j contain               # jump to see if words are equal

findF:  addi $t7,$0,10        # store '\n' in t7
        beq  $s3,$0,next      # if dict[idx] =='/0' => we go to next word in grid
        beq  $t7,$s3,print    # if dictionary[idx] is 'n' => go to print    
        addi $s2,$s2,4        # get next offset
        lw $t5,dict_idx($s2)
        add $s1,$t5,$0         # store index of next word in $s1
        j remain                 # check if grid contains next word in dictionary
print: 
       li $v0,1
       addi $a0,$s0,0              # put index of grid in a0
       syscall
       li $v0,11
       addi $a0,$0,32              #print newline 
       syscall
       lw $s1,dict_idx($s2)                                          #print a0
       lb $t6 , dictionary($s1)
       addi $a0,$t6,0
       addi $t3,$0,10 
printchar:   beq  $a0,$t3,newLine                              #procedure for printing the word from dictionary
             li $v0 ,11
             syscall
             addi $s1,$s1,1
             lb $a0 , dictionary($s1)
             j printchar
newLine:     li $v0,11                                           # after printing word print newline
             addi $s7,$s7,1
             addi $a0,$0,10
             syscall
             j remain                                             # check remaining letter in the grid
 decide: beq $s7,0,printN                                          # if my variable is 0 no match is found and -1 is printed
                                
         j main_end                                                 # end program
 printN: li $v0,1
         addi $a0,$0,-1                                             # print -1
         syscall
         li $v0,11
         addi $a0,$0,10             # print newline
         syscall       
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
