package main

import "core:fmt"
import "core:strconv"

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
		WAIT,
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

tokenize_source :: proc(source: []u8) -> ([]Token, bool) {
	tokens: [dynamic]Token
	line_number := 1
	syntax_ok := true

	for source_index := 0; source_index < len(source); source_index += 1 {
		switch source[source_index] {
		case '_', 'a'..='z', 'A'..='Z':
			token_text, token_kind := scan_token(source, &source_index)
			append(&tokens, Token { token_text, token_kind, line_number })
		case '.':
			directive_text := scan_directive(source, &source_index)
			switch directive_text {
			case ".byte", ".BYTE":
				append(&tokens, Token { directive_text, .BYTE, line_number })
			case ".ascii", ".ASCII":
				append(&tokens, Token { directive_text, .ASCII, line_number })
			case:
				fmt.printfln("Line %v: Unknown directive %v", line_number, directive_text)
				syntax_ok = false
			}
		case '-', '0'..='9':
			uint_text := scan_uint(source, &source_index)
			uint_value, uint_ok := strconv.parse_uint(uint_text)
			switch {
			case !uint_ok:
				fmt.printfln("Line %v: Invalid unsigned integer %v", line_number, uint_text)
				syntax_ok = false
			case uint_value > 255:
				fmt.printfln("Line %v: Value %v is out of range 0..255", line_number, uint_value)
				syntax_ok = false
			case:
				append(&tokens, Token { uint_text, .UInt, line_number })
			}
		case '"':
			string_text, string_ok := scan_string_literal(source, &source_index)
			if string_ok {
				append(&tokens, Token { string_text, .String, line_number })
			} else {
				fmt.printfln("Line %v: Missing \" in string literal", line_number)
				syntax_ok = false
			}
		case ';':
			scan_comment(source, &source_index)
		case '\n':
			append(&tokens, Token { "EOL", .EOL, line_number })
			line_number += 1
		case ' ', '\t', ',':
		case:
			fmt.printfln("Line %v: Unexpected character %c", line_number, source[source_index])
			syntax_ok = false
		}
	}

	if !syntax_ok {
		delete(tokens)
		return nil, false
	}
	return tokens[:], true
}

scan_token :: proc(source: []u8, source_index: ^int) -> (string, Token_Kind) {
	token_text: string
	scan_index := source_index^ + 1
	token_scan: for ; scan_index < len(source); scan_index += 1 {
		switch source[scan_index] {
		case '_', 'a'..='z', 'A'..='Z', '0'..='9':
		case ':':
			token_text = string(source[source_index^:scan_index])
			source_index^ = scan_index
			return token_text, .Definition
		case:
			break token_scan
		}
	}
	token_text = string(source[source_index^:scan_index])
	source_index^ = scan_index - 1
	return token_text, get_token_kind(token_text)
}

scan_directive :: proc(source: []u8, source_index: ^int) -> string {
	scan_index := source_index^ + 1
	directive_scan: for ; scan_index < len(source); scan_index += 1 {
		switch source[scan_index] {
		case 'a'..='z', 'A'..='Z':
		case:
			break directive_scan
		}
	}
	token_text := string(source[source_index^:scan_index])
	source_index^ = scan_index - 1
	return token_text
}

scan_uint :: proc(source: []u8, source_index: ^int) -> string {
	scan_index := source_index^ + 1
	uint_scan: for ; scan_index < len(source); scan_index += 1 {
		switch source[scan_index] {
		case '.', 'a'..='z', 'A'..='Z', '0'..='9':
		case:
			break uint_scan
		}
	}
	token_text := string(source[source_index^:scan_index])
	source_index^ = scan_index - 1
	return token_text
}

scan_string_literal :: proc(source: []u8, source_index: ^int) -> (string, bool) {
	scan_index := source_index^ + 1
	string_scan: for ; scan_index < len(source); scan_index += 1 {
		switch source[scan_index] {
		case '"':
			token_text := string(source[source_index^ + 1:scan_index])
			source_index^ = scan_index
			return token_text, true
		case '\n', ';':
			break string_scan
		}
	}
	source_index^ = scan_index - 1
	return "", false
}

scan_comment :: proc(source: []u8, source_index: ^int) {
	scan_index := source_index^ + 1
	for ; scan_index < len(source); scan_index += 1 {
		if source[scan_index] == '\n' {
			break
		}
	}
	source_index^ = scan_index - 1
	return
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
	case "wait", "WAIT": return .WAIT
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
