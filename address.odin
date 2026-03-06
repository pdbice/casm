package main

import "core:fmt"

Address_Map :: struct {
	line_address:  map[int]int,
	label_address: map[string]int,
	program_size:  int,
}

destroy_address_map :: proc(address_map: ^Address_Map) {
	delete(address_map.line_address)
	delete(address_map.label_address)
}

create_address_map :: proc(tokens: []Token) -> (Address_Map, bool) {
	address_map: Address_Map = {
		make(map[int]int),
		make(map[string]int),
		0,
	}
	address := 512

	for token in tokens {
		#partial switch token.kind {
		case .Instruction_Start..<.Instruction_End:
			address_map.line_address[token.line_number] = address
			address += 2
		}
	}

	directive_syntax_ok := true
	for token_index := 0; token_index < len(tokens); token_index += 1 {
		token := tokens[token_index]
		#partial switch token.kind {
		case .BYTE:
			byte_length, byte_ok := parse_byte_directive(tokens, &token_index)
			if byte_ok {
				address_map.line_address[token.line_number] = address
				address += byte_length
			} else {
				directive_syntax_ok = false
			}
		case .ASCII:
			ascii_length, ascii_ok := parse_ascii_directive(tokens, &token_index)
			if ascii_ok {
				address_map.line_address[token.line_number] = address
				address += ascii_length
			} else {
				directive_syntax_ok = false
			}
		}
	}

	if !directive_syntax_ok {
		destroy_address_map(&address_map)
		return Address_Map {}, false
	}

	address_map.program_size = address - 512

	for token_index in 0..<len(tokens) {
		if tokens[token_index].kind != .Definition {
			continue
		}
		label := tokens[token_index].text
		label_address_scan: for scan_index in token_index + 1..<len(tokens) {
			line_number := tokens[scan_index].line_number
			#partial switch tokens[scan_index].kind {
			case .Instruction_Start..<.Instruction_End, .Directive_Start..<.Directive_End:
				address_map.label_address[label] = address_map.line_address[line_number]
				break label_address_scan
			}
		}
	}

	return address_map, true
}

parse_byte_directive :: proc(tokens: []Token, token_index: ^int) -> (int, bool) {
	length := 0
	for token_index^ += 1; token_index^ < len(tokens); token_index^ += 1 {
		token := tokens[token_index^]
		#partial switch token.kind {
		case .UInt:
			length += 1
		case .EOL:
			return length, true
		case:
			fmt.printfln("Line %v: Expected unsigned integer, got %v", token.line_number, token.kind)
			token_index^ -= 1
			return 0, false
		}
	}
	return length, true
}

parse_ascii_directive :: proc(tokens: []Token, token_index: ^int) -> (int, bool) {
	length := 0
	for token_index^ += 1; token_index^ < len(tokens); token_index^ += 1 {
		token := tokens[token_index^]
		#partial switch token.kind {
		case .String:
			length += len(token.text)
		case .EOL:
			return length, true
		case:
			fmt.printfln("Line %v: Expected string, got %v", token.line_number, token.kind)
			token_index^ -= 1
			return 0, false
		}
	}
	return length, true
}
