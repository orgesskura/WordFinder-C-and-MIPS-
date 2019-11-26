
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
       
         
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dict_idx:                 .space 4004 # set up space for 1000 words 
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

        li $t2,0                        #counter for total nr of words in the grid
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
        addi $t0, $t0, 1                # idx += 1
        addi $t2,$t2,1                  #increase counter by 1
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


# You can add your code here!
 li $t4,0     #nr of words in a row
 li $v1,0     # variable to check if i am going horizontally,vertically or diagonal                              
 
count:          lb   $t1, grid($t4)          
                addi $v0, $0, 10                # newline \n
                beq  $t1, $v0, begin         # if(c_input == '\n')
                addi $t4, $t4, 1                # idx += 1
                j    count       
                        
begin:   li $t0,-1 # starting index in dictionary
         li $t1,-4 #offset
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
          j addN                  # jump back to get next word in dictionary

                        
strFind: li $s0,-1               # grid idx
         li $t8,-1                # y-coordinates
                         
next:    addi $t8,$t8,1          # increase y-coordinate
         
nextN:   li $v1,0                # variable to check if i am going horizontally,vertically or diagonal    
         addi $s0,$s0,1          # add 1 to grid index
                                 # set grid idx to 0
         li $s2,0                # set offset to 0
         li $s1,0                # set dict idx to 0
         
remain:  
         lw $s4,dict_idx($s2)    # load position of offset to $s4  
         lb $s3,dictionary($s4)  # load char from dict idx
         lb $s5,grid($s0)        # load char from grid
         addi $a0,$0,10
         beq $s5,$a0,next       # check if char of grid is newline. if it is get next letter
         addi $a1,$0,10        # load grid idx to $s5
               
         beq $s5,$0,decide       # if grid idx is '/0' jump to decide
         move $s6,$s0            # copy $s0 into $s6
         beq  $v1,0,containH     #depending on value of $v0, i check which direction i should go 
         beq  $v1,1,containV      
         j containD     
                     
containH: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF      
         addi $s1,$s1,1      # add 1 to dict_idx
        
         add $s6,$s6,1      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)       # load byte from grid 
         addi $a0,$0,10
         beq $a0,$s3,print      # if char from dictionary is newline print it        
        
         j containH             # set up for containH loop
containV: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF      
         add $a0,$s6,$t4      # $t4 store length of one row...i do this to check if i am on the last row
         addi $a0,$a0,1
         slt $v0,$a0,$t2      
         beq $v0,0,v_d_check  # if i am on the last row i check if i can print or not
         
         addi $s1,$s1,1      # add 1 to dict_idx
         
      
         add $s6,$s6,$t4
         add $s6,$s6,1      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)
         addi $a0,$0,10
         beq $a0,$s3,print              # load byte from grid 
       
         j containV               # jump to see if words are equal


containD: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF
           add $a0,$s6,$t4    
         addi $a0,$a0,2
         slt $v0,$a0,$t2     # check if i am in the last row
         beq $v0,0,v_d_check   # if i am  check if i can print 
         move $a1,$t4
         addi $a1,$a1,1      # store length of one row in a1
         div  $s6,$a1        # get division of current index with lenght of row
         mfhi $a0            # store quotient in a0
         addi $a0,$a0,1      # add 1 so i can compare with length of row without newline
         beq $a0,$t4,v_d_check # if i am ib the last column decide to print or not
         addi $s1,$s1,1      # add 1 to dict_idx
         add $s6,$s6,$t4
         add $s6,$s6,2      # add 2 to grid_idx because t4 is length of row wihtout newline
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)    # load byte from grid 
         addi $a0,$0,10
         beq $a0,$s3,print          # if char from dict is newline print it    
       
         j containD             # jump back to create a loop
findF:  addi $a0,$0,10        # store '\n' in t7
        beq  $s3,$0,decideC      # if dict[idx] =='/0' => we chek if we have seen all dir
        beq  $a0,$s3,print    # if dictionary[idx] is 'n' => go to print    
        addi $s2,$s2,4        # get next offset
        lw $t5,dict_idx($s2)
        add $s1,$t5,$0         # store index of next word in $s1
        j remain 
print: 
       li $v0,1
       addi $a0,$t8,0              # print y coordinate
       syscall
       
       li $v0,11
       addi $a0,$0,44            # print ','
       syscall
       
      
       sub $a0,$s0,0
       move $a1,$a0
       move $t9,$t8
 findX:beq $t9,0,printx           # find x is used to determine the xcoordinate of the grid
       sub $a0,$a0,$t4
       addi $a0,$a0,-1
       addi $t9,$t9,-1
       j findX
 printx:  li $v0,1
          syscall
          
       li $v0,11
       addi $a0,$0,32          # print newline
       syscall 
       beq $v1,0,printH        # check if i have completed diagonal,vertical or horizontal
       beq $v1,1,printV
       j printD     
       
 printH:     li $v0,11
       addi $a0,$0,72            # print H 
       syscall 
       j goM
printV:      
        li $v0,11
       addi $a0,$0,86          # print V
       syscall 
       j goM  
printD:       li $v0,11
       addi $a0,$0,68          #print D
       syscall 
       j goM
          
 goM:      li $v0,11
       addi $a0,$0,32          # print space
       syscall  


       lw $s1,dict_idx($s2)                                          #prints the words from dictionary
       lb $t6 , dictionary($s1)
       addi $a0,$t6,0
       addi $t3,$0,10 
printchar:   beq  $a0,$t3,newLine
             li $v0 ,11
             syscall
             addi $s1,$s1,1
             lb $a0 , dictionary($s1)
             j printchar
newLine:     li $v0,11
             addi $s7,$s7,1
             addi $a0,$0,10          # print newline
             syscall
             j remain
 decide:  
         beq $s7,0,printN           # if i have a match end program,otherwise print -1
                                
         j main_end
 printN: li $v0,1
         addi $a0,$0,-1            # print -1
         syscall
         li $v0,11
         addi $a0,$0,10            #print newline
         syscall
         j main_end            
 decideC: beq $v1,0,initV        # check if i have checked all dir
          beq $v1,1,initD
          j nextN

  initV:   li $s2,0                # set offset to 0
           li $s1,0   
           li $v1,1
           move $s6,$s0
           lb $s3,dictionary($s1) # load byte from dictionary
           lb $s5,grid($s6)
           j containV
  initD:   li $s2,0                # set offset to 0
           li $s1,0                # set dict index to 0
           li $v1,2                # variable used for printing
           move $s6,$s0
           lb $s3,dictionary($s1) # load byte from dictionary
           lb $s5,grid($s6)
           j containD         
   v_d_check: addi $s1,$s1,1       # add 1 to dictionary index
            lb $s3,dictionary($s1) # load byte
            addi $a3,$0,10
            beq $a3,$s3,print          # if char from dictionary is newline i print it
            beq  $s3,$0,decideC      # if dict[idx] =='/0' => we go to next word in grid
       # if dictionary[idx] is 'n' => go to print    
         addi $s2,$s2,4        # get next offset
         lw $t5,dict_idx($s2)
         add $s1,$t5,$0         # store index of next word in $s1
         j remain                 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
