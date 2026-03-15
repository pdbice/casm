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
