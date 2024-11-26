package day2303

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Game :: [4]int

day :: proc(filepath: string) {
	fmt.printf("day 23/03\n")

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	for line in lines {
		fmt.printf("line: {}\n", line)
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
