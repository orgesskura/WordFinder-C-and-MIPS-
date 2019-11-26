
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid, including wrap-around
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
.align 4
dict_idx:                 .space 4004
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
 li $t4,0                   #nr of words in a row
 li $v1,0                   # variable to see if  i am checking horizontally,vertically or diagonal                
 
count:          lb   $t1, grid($t4)          
                addi $v0, $0, 10                # newline \n
                beq  $t1, $v0, begin         # if(c_input == '\n')
                addi $t4, $t4, 1                # idx += 1
                j    count    
                
             
  
                               
                            
                        
begin:   li $t0,-1 # starting index in dictionary
         li $t1,-4 #offset
         li $s7,0  #if I have a match or not variable
         
         li $a3,0      # store nr_rows in $a3
         move $t7,$t2
  nr_rows: beq $t7,0,storeidx
           sub $t7,$t7,1
           sub $t7,$t7,$t4
           addi $a3,$a3,1
           j nr_rows         
     
         

         
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
                         
next:    addi $t8,$t8,1           # increment row nr
         
nextN:   li $v1,0                 # variable to see if  i am checking horizontally,vertically or diagonal 
         addi $s0,$s0,1           # add 1 to grid index
                                 # set grid idx to 0
         li $s2,0                # set offset to 0
         li $s1,0                # set dict idx to 0
         
remain:  
         lw $s4,dict_idx($s2)    # load position of offset to $s4  
         lb $s3,dictionary($s4)  # load char from dict idx
         lb $s5,grid($s0)        
         addi $a0,$0,10
         beq $s5,$a0,next       # if char from grid is newline get next char in the grid
         addi $a1,$0,10        
          # load grid idx to $s5
               # if grid idx is '/0' go to print function
         beq $s5,$0,decide       
         move $s6,$s0          # copy $s0 to $s6
         beq  $v1,0,containH    # decide depending on v1 which dir we are going    
         beq  $v1,1,containV      
         j containD     
                     
containH: addi $a0,$0,10
          beq  $s5,$a0,h_wrap #if grid is newline we go to h_wrap
         bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF      
         addi $s1,$s1,1      # add 1 to dict_idx
        
         add $s6,$s6,1      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)      # load byte from grid 
         addi $a0,$0,10
         beq $a0,$s3,print        # if  dictionary lette is newline i print the word
        
         j containH          # loop back to containH
containV: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF      
         add $a0,$s6,$t4
         addi $a0,$a0,1      
         slt $v0,$a0,$t2
         beq $v0,0,v_wrap    # if i am on the last row go to v_wrap
         addi $s1,$s1,1      # add 1 to dict_idx
         add $s6,$s6,$t4
         add $s6,$s6,1      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)      # load byte from grid 
         addi $a0,$0,10
         beq $a0,$s3,print        # if  dictionary lette is newline i print the word       
       
         j containV               # jump to see if words are equal

containD: bne $s3,$s5,findF   # if dict[idx]!=grid[idx] => go to findF
          move $a1,$t4 
          addi $a1,$a1,1     # store nr of chars including newline in a row on a1
          div  $s6,$a1       #divide grid index with row lengrh so that i can store quotient in a0 and nr of row in t7
          mfhi $a0
          mflo $t7
         addi $a0,$a0,1     # add 1 to a1 so i can compare with t4 and determine if i am  on the last column
         addi $t7,$t7,1     # add 1 to t7 to determine if i am on the last row
         beq $t7,$a3,d_wrap  # if i am on the last row go to d_wrap
         
         beq $a0,$t4,d_wrap       # if i am on the last column go to d-wrap
         addi $s1,$s1,1      # add 1 to dict_idx
         add $s6,$s6,$t4
         add $s6,$s6,2      # add 1 to grid_idx
         lb $s3,dictionary($s1) # load byte from dictionary
         lb $s5,grid($s6)
         addi $a1,$0,10
         beq $a1,$s3,print              # load byte from grid 
       
         j containD       # loop back to containD
findF:  addi $a0,$0,10        # store '\n' in t7
        beq  $s3,$0,decideC      # if dict[idx] =='/0' we check if we have seen all dir
        beq  $a0,$s3,print    # if dictionary[idx] is 'n' => go to print    
        addi $s2,$s2,4        # get next offset
        lw $t5,dict_idx($s2)
        add $s1,$t5,$0         # store index of next word in $s1
        j remain              # check if i havent done vertical or diagonal
print: 
       li $v0,1
       addi $a0,$t8,0              # print y-coordinate
       syscall
       
       li $v0,11
       addi $a0,$0,44             # print ','
       syscall
       
      
       sub $a0,$s0,0
       move $a1,$a0
       move $t9,$t8
 findX:beq $t9,0,printx          # find x is a functoin to determine x-coordinate
       sub $a0,$a0,$t4
       addi $a0,$a0,-1
       addi $t9,$t9,-1
       j findX
 printx:  li $v0,1              #print x-coordinate
          syscall
          
       li $v0,11
       addi $a0,$0,32          # print space
       syscall 
       beq $v1,0,printH       # print v,h,d depending on value of v1
       beq $v1,1,printV
       j printD     
       
 printH:     li $v0,11
       addi $a0,$0,72
       syscall 
       j goM
printV:      
        li $v0,11
       addi $a0,$0,86
       syscall 
       j goM  
printD:       li $v0,11
       addi $a0,$0,68
       syscall 
       j goM
          
 goM:      li $v0,11
       addi $a0,$0,32           #print space
       syscall  


       lw $s1,dict_idx($s2)                                          #this procedure prints the character from the dictionary
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
             addi $s7,$s7,1                # add 1 to $s7 to indicate i have found a match              
             addi $a0,$0,10                # print newline
             syscall
             j remain
 decide:  
         beq $s7,0,printN           # if no match print -1
                                
         j main_end
 printN: li $v0,1 
         addi $a0,$0,-1           # print -1
         syscall
         li $v0,11
         addi $a0,$0,10          #print newline
         syscall
         j main_end            
 decideC: beq $v1,0,initV     # see if i have checked h or v
          beq $v1,1,initD
          j nextN            # if i have checked all dir get next word in grid

  initV:   li $s2,0                # set offset to 0
           li $s1,0   
           li $v1,1
           move $s6,$s0
           lb $s3,dictionary($s1) # load byte from dictionary
           lb $s5,grid($s6)
           j containV            # jump to containV
  initD:   li $s2,0                # set offset to 0
           li $s1,0   
           li $v1,2
           move $s6,$s0
           lb $s3,dictionary($s1) # load byte from dictionary
           lb $s5,grid($s6)
           j containD         #jump to containD
                   
                   
   h_wrap:   sub $s6,$s6,$t4
             lb  $s5,grid($s6)       # go to first word in grid
             j containH     
             
   v_wrap:   move $a0,$a3
   v_wrap1:  beq $a0,1,v_wrap2      # loop to go back to first row
             sub $s6,$s6,$t4
             addi $s6,$s6,-1
             addi $a0,$a0,-1
             j v_wrap1
   v_wrap2:  lb $s5,grid($s6)
             addi $s1,$s1,1
             lb $s3,dictionary($s1)
             j containV           # jump back to vertical contain
       
    
                            
                               
                         
d_wrap: 
        addi $a0,$a0,-1     # i incremented this variables before so i need to decrement them
        addi $t7,$t7,-1
        
       
d_wrap2:beq $t7,0,d_wrap3  # go back diagonally until i reach either the first row or first column
        beq $a0,0,d_wrap3
        sub $s6,$s6,$t4
        addi $s6,$s6,-2
        addi $a0,$a0,-1
        addi $t7,$t7,-1
        j d_wrap2
                                           
d_wrap3: lb $s5,grid($s6)
         addi $s1,$s1,1      # get next word in dictionary
         lb $s3,dictionary($s1)
         j containD  
         
                                          
         
         
          
                                                                                                                                             
#------------------------+------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
