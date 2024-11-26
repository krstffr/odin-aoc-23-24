package day2301

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

num_keys: map[string]int = {
	"one"   = 1,
	"two"   = 2,
	"three" = 3,
	"four"  = 4,
	"five"  = 5,
	"six"   = 6,
	"seven" = 7,
	"eight" = 8,
	"nine"  = 9,
	"1"     = 1,
	"2"     = 2,
	"3"     = 3,
	"4"     = 4,
	"5"     = 5,
	"6"     = 6,
	"7"     = 7,
	"8"     = 8,
	"9"     = 9,
}

nums: []string = {
	"one",
	"two",
	"three",
	"four",
	"five",
	"six",
	"seven",
	"eight",
	"nine",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
}

find_string_digits :: proc(input: string) -> int {

	min_idx := len(input)
	max_idx := -1

	min_int_idx := 0
	max_int_idx := 0
	for n, idx in nums {
		res := strings.index(input, n)
		res_last := strings.last_index(input, n)
		if res >= 0 {
			if res_last > max_idx {
				max_idx = res_last
				max_int_idx = idx
			}
			if res < min_idx {
				min_idx = res
				min_int_idx = idx
			}
		}
	}

	return (num_keys[nums[min_int_idx]] * 10) + num_keys[nums[max_int_idx]]

}

day :: proc(filepath: string) {
	fmt.printf("day 23/01\n")

	defer delete(num_keys)

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1: int = 0
	n_string: [dynamic]rune
	defer delete(n_string)

	for line in lines {
		for r in line {
			if r >= '0' && r <= '9' {
				append(&n_string, r)
			}
		}
		s := utf8.runes_to_string({n_string[0], n_string[len(n_string) - 1]})
		defer delete(s)
		i, _ := strconv.parse_int(s)
		part_1 += i
		clear(&n_string)
	}

	fmt.printf("Part one: {}\n", part_1)

	part_2 := 0

	for line in lines do part_2 += find_string_digits(line)

	fmt.printf("Part two: {}\n", part_2)


}
