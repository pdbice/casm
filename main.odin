package main

import "core:fmt"
import "core:mem"
import "core:os"

main :: proc() {
	when ODIN_DEBUG {
		tracking_allocator: mem.Tracking_Allocator
		mem.tracking_allocator_init(&tracking_allocator, context.allocator)
		context.allocator = mem.tracking_allocator(&tracking_allocator)
		defer check_tracking_allocator(&tracking_allocator)
	}

	if len(os.args) < 2 {
		usage()
		return
	}

	source, read_file_ok := os.read_entire_file_from_filename(os.args[1])
	if !read_file_ok {
		fmt.eprintfln("Could not read source file %v", os.args[1])
		return
	}
	defer delete(source)

	tokens, tokenizer_syntax_ok := tokenize_source(source)
	if !tokenizer_syntax_ok {
		return
	}
	defer delete(tokens)

	address_map, address_map_ok := create_address_map(tokens)
	if !address_map_ok {
		return
	}
	defer destroy_address_map(&address_map)

	rom, rom_ok := assemble_rom(tokens, address_map)
	if !rom_ok {
		return
	}
	defer delete(rom)

	outfile: string
	if len(os.args) > 2 {
		outfile = os.args[2]
	} else {
		outfile = "out.ch8"
	}

	write_file_ok := os.write_entire_file(outfile, rom)
	if !write_file_ok {
		fmt.eprintfln("Could not write to file %v", outfile)
		return
	}
}

usage :: proc() {
	fmt.println("Usage:")
	fmt.println("\tcasm [source file] [output file] [flags]")
	fmt.println()
	fmt.println("\tFlags")
	fmt.println()
	fmt.println()
}
check_tracking_allocator :: proc(tracking_allocator: ^mem.Tracking_Allocator) {
	if len(tracking_allocator.allocation_map) > 0 {
		fmt.eprintfln("%v allocations not freed:", len(tracking_allocator.allocation_map))
		for _, entry in tracking_allocator.allocation_map {
			fmt.eprintfln("- %v bytes @ %v", entry.size, entry.location)
		}
	}
	mem.tracking_allocator_destroy(tracking_allocator)
}
