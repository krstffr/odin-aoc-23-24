package d2309

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

solve_ns :: proc(ns: []int, sum: ^int, sum_2: ^int) {
	levels: [dynamic][]int
	defer {
		for x in levels {
			delete(x)
		}
		delete(levels)
	}
	append(&levels, ns[:])
	for ns in levels {
		all_zeroes := true
		next_level : [dynamic]int
		for n, x in ns {
			if n != 0 do all_zeroes = false
			if x == 0 do continue
			append(&next_level, n - ns[x - 1])
		}
		append(&levels, next_level[:])
		if all_zeroes do break
	}

	last_val := 0
	#reverse for &l in levels {
		last_val = last_val + l[len(l) - 1]
	}
	sum^ += last_val

	first_val := 0
	#reverse for &l in levels {
		first_val = l[0] - first_val
	}
	sum_2^ += first_val
}

day :: proc(filepath: string) {
	fmt.printf("day 23/09\n")
	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0
	for line in lines {
		ns: [dynamic]int
		utils.get_numbers_in_string(line, {" "}, &ns)
		solve_ns(ns[:], &part_1, &part_2)
	}
	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
