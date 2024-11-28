package utils

import "core:strings"
import "core:strconv"
import "core:mem"
import "core:fmt"

get_numbers_in_string :: proc(s: string, splitter: []string, a: ^[dynamic]int) {
	winning, err := strings.split_multi(s, splitter)
	if err != mem.Allocator_Error.None do fmt.panicf("Error in get_numbers_in_string using: {} and {}", s, splitter)
	defer delete(winning)
	for s in winning {
		if s == "" do continue
		n, _ := strconv.parse_int(s)
		append(a, n)
	}
}