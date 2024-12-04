package d2403

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

find_valid_muls :: proc(s: string) -> (result: int) {
	splits, _ := strings.split(s, "mul(")
	defer delete(splits)

	for split in splits {
		parts, _ := strings.split(split, ")")
		defer delete(parts)
		if len(parts[0]) > 7 do continue

		ns, _ := strings.split(parts[0], ",")
		defer delete(ns)
		if len(ns) != 2   do continue
		if len(ns[0]) > 3 do continue
		if len(ns[1]) > 3 do continue

		one, ok1 := strconv.parse_int(ns[0])
		two, ok2 := strconv.parse_int(ns[1])

		if !ok1 || !ok2 do continue

		result += one * two
	}

	return result
}

day :: proc(filepath: string) {
day :: proc(input: string) {
	fmt.printf("day 24/03\n")

	part_1 := 0
	part_2 := 0

	// part 1
	part_1 = find_valid_muls(string(input))

	// part 2
	dos, _ := strings.split(string(input), "do()")
	defer delete(dos)
	for _do in dos {
		do_until, _ := strings.split(_do, "don't()")
		defer delete(do_until)
		part_2 += find_valid_muls(do_until[0])
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
