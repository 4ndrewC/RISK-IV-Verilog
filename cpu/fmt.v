`define PC 3'b000
`define SREG 3'b001
`define ra 3'b010
`define rb 3'b011
`define rc 3'b100
`define rx 3'b101
`define ry 3'b110
`define ri 3'b111

`define WORD 16
`define MEMSIZE 65536
`define REGISTERS 8
`define OPSIZE 5

`define Cf 0
`define Zf 1
`define If 2
`define Nf 3

`define ADD 5'b00000
`define ADDI 5'b00001
`define SUB 5'b00010
`define SUBI 5'b00011
`define AND 5'b00100
`define ANDI 5'b00101
`define OR 5'b00110
`define ORI 5'b00111
`define XOR 5'b01000
`define XORI 5'b01001

`define CMP 5'b01010
`define CMPI 5'b01011
`define LDI 5'b01100
`define LDA 5'b01101
`define LDW 5'b01110
`define JMP 5'b01111
`define RJMP 5'b10000
`define BREQ 5'b10001
`define MOV 5'b10010
`define CLR 5'b10011
`define CLC 5'b10100
`define CLZ 5'b10101
`define CLN 5'b10110
`define CLS 5'b10111
`define CLI 5'b11000
`define SLC 5'b11001
`define SLZ 5'b11010
`define SLN 5'b11011
`define SLS 5'b11100
`define SLI 5'b11101

