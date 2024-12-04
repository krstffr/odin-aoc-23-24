package d2306

import "../../utils"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

day :: proc(input: string) {
	fmt.printf("day 23/06\n")

	// input:
	// Time:        60     80     86     76
	// Distance:   601   1163   1559   1300

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	times: []int = {7, 15, 30}
	distances: []int = {9, 40, 200}
	times = {60, 80, 86, 76, 60808676}
	distances = {601, 1163, 1559, 1300, 601116315591300}

	part_1 := 1

	for t, x in times[:4] {
		winning := 0
		for i in 1 ..< t {
			if i * (t - i) > distances[x] do winning += 1
		}
		part_1 *= winning
	}

	part_2 := 0
	t := 60808676

	// Brute force...
	found_lo_val := 0
	found_hi_val := 0

	// Let's try bin search, find the smallest
	lo := 1
	hi := 60808676
	for true {
		mid := lo + ((hi - lo) / 2)
		one := (mid + 0) * (t - (mid + 0)) > 601116315591300
		two := (mid + 1) * (t - (mid + 1)) > 601116315591300
		if !one && two {
			found_lo_val = mid + 1
			break
		}
		if two {
			hi = mid - 1
		} else {
			lo = mid + 1
		}
	}

	// Start over, find the largest...
	lo = 1
	hi = 60808676
	for lo <= hi {
		mid := lo + ((hi - lo) / 2)
		one := (mid + 0) * (t - (mid + 0)) > 601116315591300
		two := (mid - 1) * (t - (mid - 1)) > 601116315591300
		if lo == hi {
			found_hi_val = hi
			break
		}
		if one && !two || lo == hi {
			found_hi_val = mid
			break
		}
		if two {
			lo = mid + 1
		} else {
			hi = mid - 1
		}
	}

	fmt.printf("Part 1: {}\n", part_1)
	fmt.printf("Part 2: {}\n", found_hi_val - found_lo_val)


}
