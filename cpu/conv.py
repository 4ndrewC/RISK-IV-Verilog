fin = open('../programs/program.in', 'r')
fmt = open('fmt.v', 'r')

fmt_map = {}

for f in fmt:
    line = f.split()
    if len(line)<3 : continue
    if "3'" in line[2] or "5'" in line[2]: line[2] = line[2][3:]
    fmt_map[line[1]] = line[2]

# for key in fmt_map:
    # print(key, " ", fmt_map[key])

def twoscomp(num):
    return str((1<<16) + int(num))

# read input program
fout = open("input.txt", 'w')
for l in fin:
    instr = ""
    line = l.split()
    opcode = fmt_map[line[0].upper()]
    reg1 = ""
    reg2 = ""
    filler = ""
    imm = ""
    if len(line) == 3: 
        reg1 = fmt_map[line[1][:-1]]
        reg2 = line[2]
        if reg2 in fmt_map:
            reg2 = fmt_map[reg2]
            filler = "00000"
            instr = opcode+reg1+reg2+filler
            imm = '0'*16
        else: 
            # handle negative numbers
            if int(reg2)<0:
                reg2 = twoscomp(reg2)
            imm = bin(int(reg2))[2:]
            imm = '0'*(16-len(imm)) + imm
            filler = "00000000"
            instr = opcode+reg1+filler
    elif len(line) == 2:
        reg1 = line[1]
        if reg1 in fmt_map:
            reg1 = fmt_map[reg1]
            filler = "00000000"
            instr = opcode+reg1+filler
            imm = '0'*16
        else:
            # handle negative number
            if int(reg1)<0:
                reg1 = twoscomp(reg1)
            imm = bin(int(reg1))[2:]
            # print("imm: ", bin(int(reg1)))
            imm = '0'*(16-len(imm)) + imm
            filler = "00000000000"
            instr = opcode+filler
            
    elif len(line) == 1:
        filler = "00000000000"
        instr = opcode+filler
        imm = '0'*16
    
    fout.write(instr+'\n')
    if len(imm)>0: fout.write(imm+'\n')

fout.close()

print("Program Data Converted to bin")
