package main

Token_Kind :: enum {
	Definition,
	Instruction_Start,
		CLS,
		RET,
		JMP,
		CALL,
		SE,
		SNE,
		MOV,
		ADD,
		OR,
		AND,
		XOR,
		SUB,
		SHR,
		SUBN,
		SHL,
		LDA,
		RAND,
		DRW,
		SKP,
		SKNP,
		LDF,
		BCD,
		STR,
		LDR,
	Instruction_End,
	Directive_Start,
		BYTE,
		ASCII,
	Directive_End,
	V_Register_Start,
		V0,
		V1,
		V2,
		V3,
		V4,
		V5,
		V6,
		V7,
		V8,
		V9,
		VA,
		VB,
		VC,
		VD,
		VE,
		VF,
	V_Register_End,
	I,
	DT,
	ST,
	Label,
	UInt,
	String,
	EOL,
	EOF,
}

Token :: struct {
	text:        string,
	kind:        Token_Kind,
	line_number: int,
}

get_token_kind :: proc(token_text: string) -> Token_Kind {
	switch token_text {
	case  "cls",  "CLS": return .CLS
	case  "ret",  "RET": return .RET
	case  "jmp",  "JMP": return .JMP
	case "call", "CALL": return .CALL
	case   "se",   "SE": return .SE
	case  "sne",  "SNE": return .SNE
	case  "mov",  "MOV": return .MOV
	case  "add",  "ADD": return .ADD
	case   "or",   "OR": return .OR
	case  "and",  "AND": return .AND
	case  "xor",  "XOR": return .XOR
	case  "sub",  "SUB": return .SUB
	case  "shr",  "SHR": return .SHR
	case "subn", "SUBN": return .SUBN
	case  "shl",  "SHL": return .SHL
	case  "lda",  "LDA": return .LDA
	case "rand", "RAND": return .RAND
	case  "drw",  "DRW": return .DRW
	case  "skp",  "SKP": return .SKP
	case "sknp", "SKNP": return .SKNP
	case  "ldf",  "LDF": return .LDF
	case  "bcd",  "BCD": return .BCD
	case  "str",  "STR": return .STR
	case  "ldr",  "LDR": return .LDR
	case   "v0",   "V0": return .V0
	case   "v1",   "V1": return .V1
	case   "v2",   "V2": return .V2
	case   "v3",   "V3": return .V3
	case   "v4",   "V4": return .V4
	case   "v5",   "V5": return .V5
	case   "v6",   "V6": return .V6
	case   "v7",   "V7": return .V7
	case   "v8",   "V8": return .V8
	case   "v9",   "V9": return .V9
	case   "va",   "VA": return .VA
	case   "vb",   "VB": return .VB
	case   "vc",   "VC": return .VC
	case   "vd",   "VD": return .VD
	case   "ve",   "VE": return .VE
	case   "vf",   "VF": return .VF
	case    "i",    "I": return .I
	case   "dt",   "DT": return .DT
	case   "st",   "ST": return .ST
	}
	return .Label
}
