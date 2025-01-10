package d2417

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
import rl "vendor:raylib"

// set those up later...
regs: [3]int = {0, 0, 0}

INPUT_SIZE :: 16
ins: [INPUT_SIZE]int = {2, 4, 1, 5, 7, 5, 4, 5, 0, 3, 1, 6, 5, 5, 3, 0}

values: [1025]u8

get_combo_op :: proc(i: int) -> int {
	if i <= 3 do return i
	if i == 4 do return regs[0]
	if i == 5 do return regs[1]
	if i == 6 do return regs[2]
	fmt.panicf("Unknown op: {}\n", i)
}

pow_int :: proc(x, y: int) -> (z: int = 1) {
	for _ in 0 ..< y {
		z *= x
	}
	return z
}

cmp :: proc(a, b: []int) -> slice.Ordering {
	// fmt.printf("Cmp: {} and {} ({})\n", a, b)
	equal := true
	for i := 0; i < len(a); i += 1 {
		av := a[i]
		if av != b[i] do equal = false
	}
	if equal do return slice.Ordering.Equal
	// for i := len(a) -1 ; i >= 0; i -= 1 {
	for i := 0; i < len(a); i += 1 {
		av := a[i]
		if av < b[i] do return slice.Ordering.Less
		if av > b[i] do return slice.Ordering.Greater
	}
	return slice.Ordering.Equal

}

day :: proc(input: string) {
	fmt.printf("day 24/17\n")

	lines, _ := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2: int = 0

	output: [INPUT_SIZE]int
	iterations := 0

	part_1_input := 63281501

	main_loop : for i := part_1_input; i < max(int); i+=1 {
		iterations += 1
		regs[0] = int(i)
		regs[1] = 0
		regs[2] = 0
		ip: int = 0

		ouput_i := 0
		output = {}

		loop: for ip < int(len(ins)) {
			i := ins[ip]
			op := int(ins[ip + 1])

			switch i {
			case 0:
				// adv
				v := get_combo_op(op)
				div_res := pow_int(2, int(v))
				regs[0] = regs[0] / div_res
				ip += 2

			case 1:
				// bxl
				regs[1] ~= op
				ip += 2

			case 2:
				// bst
				regs[1] = get_combo_op(op) % 8
				ip += 2

			case 3:
				// jnz
				if regs[0] == 0 do ip += 2
				else do ip = op

			case 4:
				// bxc
				regs[1] ~= regs[2]
				ip += 2

			case 5:
				// out
				output[ouput_i] = get_combo_op(op) % 8
				ouput_i += 1
				ip += 2

			case 6:
				// bdv
				v := get_combo_op(op)
				div_res := pow_int(2, int(v))
				regs[1] = regs[0] / div_res
				ip += 2

			case 7:
				// cdv
				v := get_combo_op(op)
				div_res := pow_int(2, int(v))
				regs[2] = regs[0] / div_res
				ip += 2

			case:
				fmt.panicf("Unhandled: {}\n", i)

			}
		}

		// part one
		if i == part_1_input do fmt.printf("Part one: {}\n", output[:ouput_i])

		// part two
		if cmp(output[:], ins[:]) == .Equal {
			fmt.printf("Part two: {}\n", i)
			break
		}

		// for part 2:
		// Find first diffing int from the end,
		// append a large number to the current count to increase!
		// ...but not the full number as that sometimes skips the actual number...
		// Actually: this code is horrible and cursed, should look up how to actually do this!
		for idx := len(output) - 1; idx >= 0; idx-=1 {
			if output[idx] != ins[idx] {
				// R A N C I D
				i += max(0, pow_int(8, idx - 2) - (pow_int(8, idx - 3) + pow_int(8, idx - 4)))
				continue main_loop
			}
		}

	}
}