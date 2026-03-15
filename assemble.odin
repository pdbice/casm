package main

import "core:fmt"
import "core:strconv"

assemble_rom :: proc(tokens: []Token, address_map: Address_Map) -> ([]u8, bool) {
	rom := make([]u8, address_map.program_size)
	syntax_ok := true

	for token_index := 0; token_index < len(tokens); token_index += 1 {
		token := tokens[token_index]
		address, address_ok := address_map.line_address[token.line_number]
		if !address_ok {
			continue
		}
		opcode: [2]u8
		opcode_ok: bool
		#partial switch token.kind {
		case .CLS:
			opcode_ok = parse_0x00(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = 0x00
				rom[address - 511] = 0xE0
				token_index += 1
			} else {
				syntax_ok = false
			}
		case .RET:
			opcode_ok = parse_0x00(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = 0x00
				rom[address - 511] = 0xEE
				token_index += 1
			} else {
				syntax_ok = false
			}
		case .JMP:
			opcode, opcode_ok = assemble_jump(tokens, token_index, address_map.label_address)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				if opcode[0] & 0xF0 == 0xB0 {
					token_index += 3
				} else {
					token_index += 2
				}
			} else {
				syntax_ok = false
			}
		case .CALL:
			opcode, opcode_ok = assemble_call(tokens, token_index, address_map.label_address)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .SE:
			opcode, opcode_ok = assemble_skip_equal(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .SNE:
			opcode, opcode_ok = assemble_skip_not_equal(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .MOV:
			opcode, opcode_ok = assemble_move(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .ADD:
			opcode, opcode_ok = assemble_add(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .OR:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x1)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .AND:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x2)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .XOR:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x3)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .SUB:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x5)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .SHR:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x6)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .SUBN:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0x7)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .SHL:
			opcode, opcode_ok = assemble_0x80(tokens, token_index, 0xE)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .LDA:
			opcode, opcode_ok = assemble_load_address(tokens, token_index, address_map.label_address)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .RAND:
			opcode, opcode_ok = assemble_rand(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 3
			} else {
				syntax_ok = false
			}
		case .DRW:
			opcode, opcode_ok = assemble_draw(tokens, token_index)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 4
			} else {
				syntax_ok = false
			}
		case .SKP:
			opcode, opcode_ok = assemble_0xE0(tokens, token_index, 0x9E)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .SKNP:
			opcode, opcode_ok = assemble_0xE0(tokens, token_index, 0xA1)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .WAIT:
			opcode, opcode_ok = assemble_0xF0(tokens, token_index, 0x0A)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .LDF:
			opcode, opcode_ok = assemble_0xF0(tokens, token_index, 0x29)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .BCD:
			opcode, opcode_ok = assemble_0xF0(tokens, token_index, 0x33)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .STR:
			opcode, opcode_ok = assemble_0xF0(tokens, token_index, 0x55)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .LDR:
			opcode, opcode_ok = assemble_0xF0(tokens, token_index, 0x65)
			if opcode_ok {
				rom[address - 512] = opcode[0]
				rom[address - 511] = opcode[1]
				token_index += 2
			} else {
				syntax_ok = false
			}
		case .ASCII:
			ascii_address := address - 512
			ascii_index := token_index + 1
			assemble_ascii: for ; ascii_index < len(tokens); ascii_index += 1 {
				#partial switch tokens[ascii_index].kind {
				case .String:
					ascii_value := tokens[ascii_index].text
					copy(rom[ascii_address:], ascii_value[:])
					ascii_address += len(ascii_value)
				case:
					break assemble_ascii
				}
			}
			token_index = ascii_index - 1
		case .BYTE:
			byte_address := address - 512
			byte_index := token_index + 1
			assemble_byte: for ; byte_index < len(tokens); byte_index += 1 {
				#partial switch tokens[byte_index].kind {
				case .UInt:
					byte_value, _ := strconv.parse_uint(tokens[byte_index].text)
					rom[byte_address] = u8(byte_value)
					byte_address += 1
				case:
					break assemble_byte
				}
			}
			token_index = byte_index - 1
		}
	}

	if !syntax_ok {
		delete(rom)
		return nil, false
	}
	return rom, true
}

parse_0x00 :: proc(tokens: []Token, token_index: int) -> bool {
	operand := peek_token_kind(tokens, token_index + 1)
	line_number := tokens[token_index].line_number
	if operand != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operand)
		return false
	}
	return true
}

assemble_jump :: proc(tokens: []Token, token_index: int, label_address_map: map[string]int) -> ([2]u8, bool) {
	operands: [3]Token_Kind
	operands[0] = peek_token_kind(tokens, token_index + 1)
	operands[1] = peek_token_kind(tokens, token_index + 2)
	
	line_number := tokens[token_index].line_number

	jump_op: u8
	jump_label: string

	#partial switch operands[0] {
	case .Label:
		if operands[1] != .EOL {
			fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[1])
			return {}, false
		}
		jump_op = 0x10
		jump_label = tokens[token_index + 1].text
	case .V0:
		operands[2] = peek_token_kind(tokens, token_index + 3)
		if operands[1] != .Label {
			fmt.printfln("Line %v: Expected label, found %v", line_number, operands[1])
			return {}, false
		}
		if operands[2] != .EOL {
			fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
			return {}, false
		}
		jump_op = 0xB0
		jump_label = tokens[token_index + 2].text
	case:
		fmt.printfln("Line %v: Expected label or V0, found %v", line_number, operands[0])
		return {}, false
	}

	label_address, label_address_ok := label_address_map[jump_label]
	if !label_address_ok {
		fmt.printfln("Line %v: Label %v is not defined", line_number, jump_label)
		return {}, false
	}

	return { jump_op | u8(label_address & 0xF00 >> 8), u8(label_address & 0xFF) }, true
}

assemble_call :: proc(tokens: []Token, token_index: int, label_address_map: map[string]int) -> ([2]u8, bool) {
	operands: [2]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
	}

	line_number := tokens[token_index].line_number

	if operands[0] != .Label {
		fmt.printfln("Line %v: Expected label, found %v", line_number, operands[0])
		return {}, false
	}

	if operands[1] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[1])
		return {}, false
	}

	call_label := tokens[token_index + 1].text
	label_address, label_address_ok := label_address_map[call_label]
	if !label_address_ok {
		fmt.printfln("Line %v: Label %v is not defined", line_number, call_label)
		return {}, false
	}

	return { 0x20 | u8(label_address & 0xF00 >> 8), u8(label_address & 0xFF) }, true
}

assemble_skip_equal :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	compare_a, compare_a_ok := get_v_register_index(operands[0])
	if !compare_a_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	#partial switch operands[1] {
	case .UInt:
		compare_uint, _ := strconv.parse_uint(tokens[token_index + 2].text)
		return { 0x30 | compare_a, u8(compare_uint) }, true
	case .V_Register_Start..<.V_Register_End:
		compare_register, _ := get_v_register_index(operands[1])
		return { 0x50 | compare_a, compare_register << 4 }, true
	}

	fmt.printfln("Line %v: Expected unsigned integer or V0..VF, , found %v", line_number, operands[1])
	return {}, false
}

assemble_skip_not_equal :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	compare_a, compare_a_ok := get_v_register_index(operands[0])
	if !compare_a_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	#partial switch operands[1] {
	case .UInt:
		compare_uint, _ := strconv.parse_uint(tokens[token_index + 2].text)
		return { 0x40 | compare_a, u8(compare_uint) }, true
	case .V_Register_Start..<.V_Register_End:
		compare_register, _ := get_v_register_index(operands[1])
		return { 0x90 | compare_a, compare_register << 4 }, true
	}

	fmt.printfln("Line %v: Expected unsigned integer or V0..VF, , found %v", line_number, operands[1])
	return {}, false
}

assemble_move :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	source_register: u8
	source_register_ok: bool

	#partial switch operands[0] {
	case .V_Register_Start..<.V_Register_End:
		destination, _ := get_v_register_index(operands[0])
		#partial switch operands[1] {
		case .UInt:
			source_uint, _ := strconv.parse_uint(tokens[token_index + 2].text)
			return { 0x60 | destination, u8(source_uint) }, true
		case .V_Register_Start..<.V_Register_End:
			source_register, _ = get_v_register_index(operands[1])
			return { 0x80 | destination, source_register << 4 }, true
		case .DT:
			return { 0xF0 | destination, 0x07 }, true
		}
		fmt.printfln("Line %v: Expected unsigned integer, V0..VF, or DT, found %v", line_number, operands[1])
		return {}, false
	case .DT:
		source_register, source_register_ok = get_v_register_index(operands[1])
		if !source_register_ok {
			fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[1])
			return {}, false
		}
		return { 0xF0 | source_register, 0x15 }, true
	case .ST:
		source_register, source_register_ok = get_v_register_index(operands[1])
		if !source_register_ok {
			fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[1])
			return {}, false
		}
		return { 0xF0 | source_register, 0x18 }, true
	}

	fmt.printfln("Line %v: Expected V0..VF, DT, or ST, found %v", line_number, operands[0])
	return {}, false
}

assemble_add :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	addend_register: u8
	addend_register_ok: bool

	#partial switch operands[0] {
	case .V_Register_Start..<.V_Register_End:
		destination, _ := get_v_register_index(operands[0])
		#partial switch operands[1] {
		case .UInt:
			addend_uint, _ := strconv.parse_uint(tokens[token_index + 2].text)
			return { 0x70 | destination, u8(addend_uint) }, true
		case .V_Register_Start..<.V_Register_End:
			addend_register, _ = get_v_register_index(operands[1])
			return { 0x80 | destination, addend_register << 4 | 0x4 }, true
		}
		fmt.printfln("Line %v: Expected unsined integer or V0..VF, found %v", line_number, operands[1])
		return {}, false
	case .I:
		addend_register, addend_register_ok = get_v_register_index(operands[1])
		if !addend_register_ok {
			fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[1])
			return {}, false
		}
		return { 0xF0 | addend_register, 0x1E }, true
	}

	fmt.printfln("Line %v: Expected V0..VF or I, found %v", line_number, operands[0])
	return {}, false
}

assemble_0x80 :: proc(tokens: []Token, token_index: int, math_op: u8) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	destination, destination_ok := get_v_register_index(operands[0])
	if !destination_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	term, term_ok := get_v_register_index(operands[1])
	if !term_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[1])
		return {}, false
	}

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	return { 0x80 | destination, term << 4 | math_op }, true
}

assemble_load_address :: proc(tokens: []Token, token_index: int, label_address_map: map[string]int) -> ([2]u8, bool) {
	operands: [2]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
	}

	line_number := tokens[token_index].line_number

	if operands[0] != .Label {
		fmt.printfln("Line %v: Expected label, found %v", line_number, operands[0])
		return {}, false
	}

	if operands[1] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[1])
		return {}, false
	}

	load_label := tokens[token_index + 1].text
	label_address, label_address_ok := label_address_map[load_label]
	if !label_address_ok {
		fmt.printfln("Line %v: Label %v is not defined", line_number, load_label)
		return {}, false
	}

	return { 0xA0 | u8(label_address & 0xF00 >> 8), u8(label_address & 0xFF) }, true
}

assemble_rand :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [3]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
	}

	line_number := tokens[token_index].line_number

	destination, destination_ok := get_v_register_index(operands[0])
	if !destination_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	if operands[1] != .UInt {
		fmt.printfln("Line %v: Expected unsigned integer, found %v", line_number, operands[1])
		return {}, false
	}

	if operands[2] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[2])
		return {}, false
	}

	mask, _ := strconv.parse_uint(tokens[token_index + 2].text)

	return { 0xC0 | destination, u8(mask) }, true
}

assemble_draw :: proc(tokens: []Token, token_index: int) -> ([2]u8, bool) {
	operands: [4]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
		peek_token_kind(tokens, token_index + 3),
		peek_token_kind(tokens, token_index + 4),
	}

	line_number := tokens[token_index].line_number

	x_register, x_register_ok := get_v_register_index(operands[0])
	if !x_register_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	y_register, y_register_ok := get_v_register_index(operands[1])
	if !y_register_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[1])
		return {}, false
	}

	if operands[2] != .UInt {
		fmt.printfln("Line %v: Expected unsigned integer, found %v", line_number, operands[2])
		return {}, false
	}

	height, _ := strconv.parse_uint(tokens[token_index + 3].text)
	if height > 15 {
		fmt.printfln("Line %v: Value %v out of range 0..15", line_number, height)
		return {}, false
	}

	if operands[3] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[3])
		return {}, false
	}

	return { 0xD0 | x_register, y_register << 4 | u8(height) }, true
}

assemble_0xE0 :: proc(tokens: []Token, token_index: int, opcode_low: u8) -> ([2]u8, bool) {
	operands: [2]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
	}

	line_number := tokens[token_index].line_number

	key_register, key_register_ok := get_v_register_index(operands[0])
	if !key_register_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	if operands[1] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[0])
		return {}, false
	}

	return { 0xE0 | key_register, opcode_low }, true
}

assemble_0xF0 :: proc(tokens: []Token, token_index: int, opcode_low: u8) -> ([2]u8, bool) {
	operands: [2]Token_Kind = {
		peek_token_kind(tokens, token_index + 1),
		peek_token_kind(tokens, token_index + 2),
	}

	line_number := tokens[token_index].line_number

	v_register, v_register_ok := get_v_register_index(operands[0])
	if !v_register_ok {
		fmt.printfln("Line %v: Expected V0..VF, found %v", line_number, operands[0])
		return {}, false
	}

	if operands[1] != .EOL {
		fmt.printfln("Line %v: Expected EOL, found %v", line_number, operands[0])
		return {}, false
	}

	return { 0xF0 | v_register, opcode_low }, true
}

get_v_register_index :: proc(token_kind: Token_Kind) -> (u8, bool) {
	#partial switch token_kind {
	case .V0: return  0, true
	case .V1: return  1, true
	case .V2: return  2, true
	case .V3: return  3, true
	case .V4: return  4, true
	case .V5: return  5, true
	case .V6: return  6, true
	case .V7: return  7, true
	case .V8: return  8, true
	case .V9: return  9, true
	case .VA: return 10, true
	case .VB: return 11, true
	case .VC: return 12, true
	case .VD: return 13, true
	case .VE: return 14, true
	case .VF: return 15, true
	}
	return 0, false
}

peek_token_kind :: proc(tokens: []Token, token_index: int) -> Token_Kind {
	if token_index < len(tokens) {
		return tokens[token_index].kind
	}
	return .EOF
}

