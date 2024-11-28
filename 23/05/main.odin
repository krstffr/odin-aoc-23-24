package day2305

import "../../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Range :: struct {
	from:   int,
	to:     int,
	target: int,
}

SeedMap :: struct {
	ranges: [dynamic]Range,
}

day :: proc(filepath: string, run_part_2: bool) {
	fmt.printf("day 23/05\n")

	input, err := os.read_entire_file(filepath)
	defer delete(input)

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	maps: [dynamic]SeedMap
	defer {
		for m in maps {
			delete(m.ranges)
		}
		delete(maps)
	}

	part_1 := max(int)
	part_2 := max(int)
	last_map := -1
	generating_map := false
	for line in lines {
		if strings.contains(line, "map:") {
			generating_map = true
			append(&maps, SeedMap{})
			last_map += 1
			continue
		}
		if line == "" {
			generating_map = false
		}
		if generating_map {
			ns: [dynamic]int
			utils.get_numbers_in_string(line, {" ", "  ", "   "}, &ns)
			r: Range = {
				from   = ns[1],
				to     = ns[1] + ns[2] - 1,
				target = ns[0],
			}
			append(&maps[last_map].ranges, r)
			defer delete(ns)
		}
	}

	// Test values...
	starting_values: []int = {79, 14, 55, 13}
	starting_values = {
		565778304,
		341771914,
		1736484943,
		907429186,
		3928647431,
		87620927,
		311881326,
		149873504,
		1588660730,
		119852039,
		1422681143,
		13548942,
		1095049712,
		216743334,
		3671387621,
		186617344,
		3055786218,
		213191880,
		2783359478,
		44001797,
	}

	for m in maps {
		// fmt.printf("{}\n", m)
	}

	for v in starting_values {
		mut_v := v
		for m in maps {
			r_loop: for r in m.ranges {
				if mut_v >= r.from && mut_v <= r.to {
					mut_v = mut_v - r.from + r.target
					break r_loop
				}
			}
		}
		part_1 = min(part_1, mut_v)
	}
	fmt.printf("Part one: {}\n", part_1)

	if run_part_2 {


		// calc total...
		total_to_check := 0
		for v, x in starting_values {
			if x % 2 == 0 {
				total_to_check += starting_values[x + 1]
			}
		}
		fmt.printf("Total to check: {}\n", total_to_check)

		checked := 0
		for v, x in starting_values {
			if x % 2 == 0 {
				fmt.printf("Checking: {}/{}\n", v, starting_values[x + 1])
				for i in v ..< v + starting_values[x + 1] {
					mut_v := i
					for m in maps {
						r_loop_part_2: for r in m.ranges {
							if mut_v >= r.from && mut_v <= r.to {
								mut_v = mut_v - r.from + r.target
								break r_loop_part_2
							}
						}
					}
					checked += 1
					if checked % 50_000_000 == 0 do fmt.printf("Progress: {}%%\n", f32(checked) / f32(total_to_check) * 100)
					part_2 = min(part_2, mut_v)
				}
			}
		}

		fmt.printf("Part two: {}\n", part_2)

	}


}
