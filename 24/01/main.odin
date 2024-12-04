package d2401

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

day :: proc(input: string) {
	fmt.printf("day 24/01\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	// hold all data
	list_one : [dynamic]int
	list_two : [dynamic]int
	times_in_two : map[int]int
	defer {
		delete(list_one)
		delete(list_two)
		delete(times_in_two)
	}

	for line in lines {
		ns : [dynamic]int
		defer delete(ns)
		utils.get_numbers_in_string(line, {" ", "  ", "    ", "     "}, &ns)
		append(&list_one, ns[0])
		append(&list_two, ns[1])
		times_in_two[ns[1]] += 1
	}

	// sort for part one...
	slice.sort(list_one[:])
	slice.sort(list_two[:])

	for n, x in list_one {
		part_1 += abs(n - list_two[x])
		part_2 += n * times_in_two[n]
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
