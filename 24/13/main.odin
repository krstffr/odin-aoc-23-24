package d2413

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

ClawMachine :: struct {
	a:        [2]f64,
	b:        [2]f64,
	prize_at: [2]f64,
}

cms: [dynamic]ClawMachine

day :: proc(input: string) {
	fmt.printf("day 24/13\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	// parse input and put in cms
	cm: ClawMachine
	append(&cms, cm)
	defer delete(cms)

	for line, y in lines {

		if len(line) < 2 {
			cm: ClawMachine
			append(&cms, cm)
			continue
		}

		cm := &cms[len(cms) - 1]
		parts := strings.split(line, " ")

		defer delete(parts)
		if line[:12] == "Button A: X+" {
			cm.a.x, _ = strconv.parse_f64(parts[2][2:])
			cm.a.y, _ = strconv.parse_f64(parts[3][2:])
		} else if line[:12] == "Button B: X+" {
			cm.b.x, _ = strconv.parse_f64(parts[2][2:])
			cm.b.y, _ = strconv.parse_f64(parts[3][2:])
		} else {
			cm.prize_at.x, _ = strconv.parse_f64(parts[1][2:])
			cm.prize_at.y, _ = strconv.parse_f64(parts[2][2:])
		}
	}

	for &cm in cms {
		// part 1
		res := find_best_path(cm)
		if res >= 0 do part_1 += res

		// part 2
		cm.prize_at.y += 10000000000000
		cm.prize_at.x += 10000000000000

		res = find_best_path(cm)
		if res >= 0 do part_2 += res
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}

find_best_path :: proc(c: ClawMachine, switched: bool = false) -> int {

	// so we want to push the b button as much as possible since it addes
	// less score than the a button...
	max_b := c.prize_at / c.b
	max_b_moves := max(max_b.x, max_b.y)

	// checking to see if "slope" (??) is more in x dir or y dir
	// basically: less than 45 degrees or not I guesss?
	// This is to know if we should move forwards or backwards in
	// bin search, but feels veeeeery weird when reading again now :()
	lowest := (c.prize_at - c.b) / c.a
	x_higher := lowest.x > lowest.y

	// hi lo for bin search
	hi := int(max_b_moves)
	lo := 0
	for lo <= hi {
		mid := lo + ((hi - lo) / 2)
		i := (c.prize_at - c.b * f64(mid)) / c.a

		// we are close enough!
		if math.round(i.x) == i.x && abs(i.x - i.y) < 0.001 {
			return mid + int(i.x) * 3
		} else {
			if x_higher && i.x < i.y || !x_higher && i.y < i.x {
				hi = mid - 1
			} else {
				lo = mid + 1
			}
		}
	}

	return -1
}