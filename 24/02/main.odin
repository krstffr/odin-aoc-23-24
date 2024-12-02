package d2402

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

validate_line :: proc(ns : [dynamic]int) -> bool {
	good := true
	last_val := ns[0]
	dir := 0
	for n in ns[1:] {
		// validate direction
		if n - last_val > 0 && dir == -1 do good = false
		if n - last_val < 0 && dir ==  1 do good = false

		// setup direction
		if n - last_val < 0 do dir = -1
		else do dir = 1

		// check range
		if abs(n - last_val) > 3 || abs(n - last_val) < 1 do good = false

		last_val = n
	}
	return good
}

day :: proc(filepath: string) {
	fmt.printf("day 24/02\n")
	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	for line in lines {
		ns : [dynamic]int
		defer delete(ns)

		// part 1
		utils.get_numbers_in_string(line, {" ", "  ", "   "}, &ns)
		if validate_line(ns) do part_1 += 1

		// part 2, permutations
		for _, x in ns {
			val := ns[x]
			ordered_remove(&ns, x)
			if validate_line(ns) {
				part_2 += 1
				break
			}
			inject_at(&ns, x, val)
		}

	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
