# RISK_IV-Verilog
Custom 16-bit architecture processor written in verilog

Write program into ```./programs/program.in```

Load program into memory by running ```./cpu/conv.py```

# Architecture:

**Instruction Types:**

- 5 bit opcode + 3 bit register 1 + 3 bit register 2
- 5 bit opcode + 16 bit immediate

**Instruction set:**

add (ra, rb) - add two registers ra+rb, store in ra     
addi (ra, x) - add immediate ra+x, store in ra          
sub (ra, rb) - subtract two registers ra-rb, store in ra 
subi (ra, x) - subtract ra-x, store in ra                
ldi (ra, x) - load immediate x into ra                 
lda (ra, x) - load from address x into ra               
ldw (ra, x) - load ra into address x                    
cmp (ra, rb) - rb-ra, if res is 0 -> Z flag set        
cmpi (ra, x) - x-ra, if res is 0 -> Z flag set          
jmp (x) - jump PC = x - 1                               
rjmp (x) - relative jump PC = PC + x - 1                
breq (x) - check Z flag, if Z flag then PC = PC + x - 1  
mov (ra, rb) - copies content of rb into ra         
clr (ra) - clears ra                                     
                                    

Flag instructions:

clc - clear carry                              
clz - clear zero                                      
cln - clear negative                                  
cls - clear signed                                      
cli - clear interrupt                                
slc - set carry                                     
slz - set zero                                          
sln - set negative                                      
sls - set signed                                       
sli - set interrupt                                  

Bit instructions:

and (ra, rb) - ra&rb, store in ra                    
andi (ra, rx) - ra&x, store in ra                    
or (ra, rb) - ra|rb, store in ra                   
ori (ra, x) - ra|x, store in ra                  
xor (ra, rb) - ra^rb, store in ra        
xori (ra, x) - ra^x, store in ra                         
