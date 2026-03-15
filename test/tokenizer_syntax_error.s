.BYTR 0		; Line 1: Unknown directive .BYTR
MOV V0, -100	; Line 2: Invalid unsigned integer -100
MOV V1, 256	; Line 3: Value 256 is out of range 0..255
.ASCII "Error	; Line 4: Missing " in string literal
!		; Line 5: Unexpected character !
