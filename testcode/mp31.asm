ORIGIN 4x0000
SEGMENT CodeSegment:

ONE:    DATA2 4x0001
TWO:    DATA2 4x0002
NEGTWO: DATA2 4xFFFE
TEMP1:  DATA2 4x0001
GOOD:   DATA2 4x600D
BADD:   DATA2 4xBADD

ADD R1, R1, 3
NOP
NOP
NOP
NOP
AND R1, R1, 0
NOP
NOP
NOP
NOP
NOT R1, R1
NOP
NOP
NOP
NOP
NOT R1, R1
NOP
NOP
NOP
NOP
ADD R1, R1, 3
NOP
NOP
NOP
NOP
ADD R1, R1, 3
NOP
NOP
NOP
NOP
LDR  R4, R0, ONE     ; R4 <= 1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
ADD R4, R4, 3
NOP
NOP
NOP
NOP
STR  R4, R0, TEMP1     ; R4 <= 4
NOP
NOP
NOP
NOP
NOP
NOP
NOP
LDR  R5, R0, TEMP1     ; R4 <= 1
NOP
NOP
NOP
NOP
NOP
NOP
NOP

HALT:
    BRnzp HALT
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
