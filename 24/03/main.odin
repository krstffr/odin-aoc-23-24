package d2403

import "../../utils"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"
import "core:unicode/utf8"

day :: proc(input: string) {
	fmt.printf("day 24/03\n")

	part_1 := 0
	part_2 := 0

	slen := len(input)
	input_string := string(input)
	active := true
	for _, i in input {
		if string(input[i:i + 4]) == "do()" do active = true
		if string(input[i:i + 7]) == "don't()" do active = false
		if i + 12 == slen do break
		if string(input[i:i + 4]) == "mul(" {
			end := 0
			comma := 0
			j_loop: for j in i ..< i + 12 {
				if comma == 0 && input_string[j] == ',' do comma = j
				if input_string[j] == ')' {
					end = j
					break j_loop
				}
			}
			if end > 0 && comma > 0 {
				one, ok_1 := strconv.parse_int(string(input[i + 4:comma]))
				two, ok_2 := strconv.parse_int(string(input[comma+1:end]))
				part_1 += one * two
				if active do part_2 += one * two
			}
		}
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
