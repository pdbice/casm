L0:	
	CLS error		; Line 2: Expected EOL, found Label
	RET error		; Line 3: Expected EOL, found Label
	JMP L0 error		; Line 4: Expected EOL, found Label
	JMP L1			; Line 5: Label L1 not defined
	JMP V0 L0 error		; Line 6: Expected EOL, found Label
	JMP V0 L1		; Line 7: Label L1 not defined
	CALL L0 error		; Line 8: Expected EOL, found Label
	CALL L1			; Line 9: Label L1 not defined
	SE V0 0 error		; Line 10: Expected EOL, found Label
	SE 0 V0			; Line 11: Expected V0..VF, found UInt
	SE V0 error		; Line 12: Expected unsigned integer or V0..VF, found Label
	SNE V0 0 error		; Line 13: Expected EOL, found Label
	SNE 0 V0		; Line 14: Expected V0..VF, found UInt
	SNE V0 error		; Line 15: Expected unsigned integer or V0..VF, found Label
	MOV V0 0 error		; Line 16: Expected EOL, found Label
	MOV V0 error		; Line 17: Expected unsigned integer, V0..VF, or DT, found Label
	MOV DT error		; Line 18: Expected V0..VF, found Label
	MOV ST error		; Line 19: Expected V0..VF, found Label
	ADD V0 0 error		; Line 20: Expected EOL, found Label
	ADD error V0		; Line 21: Expected V0..VF or I, found Label
	ADD V0 error		; Line 22: Expected unsigned integer or V0..VF, found Label
	ADD I error		; Line 23: Expected V0..VF, found Label
	OR 0 V0			; Line 24: Expected V0..VF, found UInt
	OR V0 0			; Line 25: Expected V0..VF, found UInt
	OR V0 V1 error		; Line 26: Expected EOL, found Label
	LDA 0			; Line 27: Expected label, found UInt
	LDA L0 error		; Line 28: Expected EOL, found Label
	LDA L1			; Line 29: Label L1 not defined
	RAND 0 V0		; Line 30: Expected V0..VF, found UInt
	RAND V0 error		; Line 31: Expected unsigned integer, found Label
	RAND V0 0 error		; Line 32: Expected EOL, found Label
	DRW error V0 1		; Line 33: Expected V0..VF, found Label
	DRW V0 error 1		; Line 34: Expected V0..VF, found Label
	DRW V0 V1 error		; Line 35: Expected unsigned integer, found Label
	DRW V0 V1 16		; Line 36: Value 16 out of range 0..15
	DRW V0 V1 15 error	; Line 37: Expected EOL, found Label
	SKP 0			; Line 38: Expected V0..VF, found UInt
	SKP V0 error		; Line 39: Expected EOL, found Label
	BCD 0			; Line 40: Expected V0..VF, found UInt
	BCD V0 error		; Line 41: Expected EOL, found Label
