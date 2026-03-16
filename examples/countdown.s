init:
		MOV V2 9		; V2 is the register holding the countdown value
		MOV V3 5		; V3 is the register holding the drawing location for the x and y axis
		MOV V4 1		; V4 is the register holding the countdown decrement value
		CALL main_loop
end:
		JMP end
		
main_loop:
		CLS
		LDF V2			; Load the font sprite for the countdown value
		DRW V3 V3 5
		CALL one_second
		SUB V2 V4		; Decrement the countdown value and test the borrow flag
		SNE VF 0
		RET
		JMP main_loop

one_second:
		MOV V0 60		; Running at 60Hz so 1 second is 60 frames
		MOV DT V0
wait_loop:
		MOV V1 DT		; Use V1 to test the delay timer value
		SNE V1 0
		RET
		JMP wait_loop
