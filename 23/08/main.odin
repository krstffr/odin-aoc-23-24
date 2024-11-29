package d2308

import "../../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:math"
import "core:unicode/utf8"

Path :: struct {
	left: string,
	right: string
}

day :: proc(filepath: string) {
	fmt.printf("day 23/08\n")

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	paths : map[string]Path
	defer delete(paths)

	part_2_start_paths : [dynamic]string
	defer delete(part_2_start_paths)

	for line in lines[2:] {
		parts, _ := strings.split(line, " = ")
		defer delete(parts)
		left_right, _ := strings.split(parts[1], ", ")
		defer delete(left_right)
		p : Path
		p.left = left_right[0][1:]
		p.right = left_right[1][:3]
		paths[parts[0]] = p

		if parts[0][2] == 'A'  {
			append(&part_2_start_paths, parts[0])
		}
	}

	curr_key := "AAA"
	curr := paths[curr_key]
	i: = 0
	steps := 0
	ins_len := len(lines[0])
	for true {
		if curr_key == "ZZZ" do break
		r := lines[0][i % ins_len]
		if r == 'L' do curr_key = curr.left
		if r == 'R' do curr_key = curr.right
		curr = paths[curr_key]
		i += 1
		steps+=1
	}

	fmt.printf("Part 1: {}\n", steps)


	results : [dynamic]int
	defer delete(results)
	for start in part_2_start_paths {
		curr_key := start
		curr = paths[curr_key]
		i = 0
		steps = 0
		for true {
			if curr_key[2] == 'Z' {
				append(&results, steps)
				break
			}
			r := lines[0][i % ins_len]
			if r == 'L' do curr_key = curr.left
			if r == 'R' do curr_key = curr.right
			curr = paths[curr_key]
			i += 1
			steps+=1
		}
	}

	part_2 := 1
	for n in results do part_2 = math.lcm(part_2, n)
	fmt.printf("Part 2: {}\n", part_2)

}
