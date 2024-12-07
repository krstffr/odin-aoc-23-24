package d2407

import "../../utils"
import "core:c/libc"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode/utf8"

S :: struct {
	target: int,
	ns:     [dynamic]int,
}

solver_part_2 :: proc(ns: [dynamic]int, offset: int, target: int, sum: int) -> bool {
	if sum > target do return false
	if offset == len(ns) do return sum == target

	sbuf1 : [16]u8
	r1 := strconv.itoa(sbuf1[:], sum)

	sbuf2 : [16]u8
	r2 := strconv.itoa(sbuf2[:], ns[offset])
	s2, _ := strconv.parse_int(string(sbuf2[:]))

	res := strings.concatenate({r1,r2,})
	defer delete(res)
	concat_sum, _ := strconv.parse_int(res)


	return solver_part_2(ns, offset + 1, target, sum + ns[offset]) || 
		   solver_part_2(ns, offset + 1, target, sum * ns[offset]) ||
		   solver_part_2(ns, offset + 1, target, concat_sum)
}

solver_part_1 :: proc(ns: [dynamic]int, offset: int, target: int, sum: int) -> bool {
	if sum > target do return false
	if offset == len(ns) do return sum == target

	return solver_part_1(ns, offset + 1, target, sum + ns[offset]) || 
		   solver_part_1(ns, offset + 1, target, sum * ns[offset])
}

day :: proc(input: string) {
	fmt.printf("day 24/07\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	to_solve : [dynamic]S

	defer {
		for s in to_solve do delete(s.ns)
		delete(to_solve)
	}

	for line in lines {
		s: S

		parts, _ := strings.split(line, ": ")
		defer delete(parts)

		s.target, _ = strconv.parse_int(parts[0])
		utils.get_numbers_in_string(parts[1], {" "}, &s.ns)
		append(&to_solve, s)
	}

	for s in to_solve {
		if solver_part_1(s.ns, 0, s.target, 0) do part_1 += s.target
		if solver_part_2(s.ns, 0, s.target, 0) do part_2 += s.target
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
