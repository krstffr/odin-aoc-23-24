package ec_d2401

import "../../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

add_scores :: proc(ns: []u8, to_add: int) -> (sum: int) {
	for n in ns {
		if n == 'A' do sum += 0 + to_add
		if n == 'B' do sum += 1 + to_add
		if n == 'C' do sum += 3 + to_add
		if n == 'D' do sum += 5 + to_add
	}
	return sum
}

day :: proc(filepath: string) {
	fmt.printf("EC day 24/01\n")
	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0
	part_3 := 0

	for c in lines[0] do part_1 += add_scores({u8(c)}, 0)

	p2in := lines[1]
	for i := 0; i < len(p2in); i += 2 {
		all: [2]u8 = {p2in[i], p2in[i + 1]}
		slice.sort(all[:])
		hi := all[1]
		lo := all[0]

		if hi == 'x' do part_2 += add_scores(all[:], 0)
		else do part_2 += add_scores(all[:], 1)
	}

	p3in := lines[2]
	for i := 0; i < len(p3in); i += 3 {
		all: [3]u8 = {p3in[i], p3in[i + 1], p3in[i + 2]}
		slice.sort(all[:])
		hi := all[2]
		mid := all[1]
		lo := all[0]

		if mid == 'x' do part_3 += add_scores(all[:], 0)
		else if hi == 'x' do part_3 += add_scores(all[:], 1)
		else do part_3 += add_scores(all[:], 2)
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)
	fmt.printf("Part three: {}\n", part_3)

}
