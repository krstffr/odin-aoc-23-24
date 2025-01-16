package d2422

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

// TODO: Store all the patterns in each number as a map,
//       and just look into that instead of brute forcing
//       every time!!

mix :: proc(i, secret: int) -> int {
	return i ~ secret
}

prune :: proc(i: int) -> int {
	return i % 16777216
}

patterns: map[[4]int]struct {}
changes: [2000]int

solve_secret :: proc(n: int) -> int {
	secret := n
	mult_res := n * 64
	secret = mix(mult_res, secret)
	secret = prune(secret)
	div_res := secret / 32
	secret = mix(div_res, secret)
	secret = prune(secret)
	mult_res_2 := secret * 2048
	secret = mix(mult_res_2, secret)
	secret = prune(secret)
	return secret
}

setup_changes :: proc(nums: ^[dynamic]int) {
	for _num in nums {
		num := _num
		// num, _ := strconv.parse_int(l)
		// fmt.printf("N: {}\n", num)
		last := num
		price := abs(num) % 10
		changes = {}
		for i in 0 ..< 2000 {
			// for _ in 0 ..< 2000 {
			num = solve_secret(num)
			one := abs(num) % 10
			last_one := abs(last) % 10
			change := one - last_one
			price = price + change
			// fmt.printf("now: {} vs {}. change: {} price: {}\n", num, last, change, price)
			changes[i] = change
			last = num
			if i >= 3 {
				pkey: [4]int = {changes[i - 3], changes[i - 2], changes[i - 1], changes[i - 0]}
				patterns[pkey] = {}
			}
		}
		// fmt.printf("Changes: {}\n", patterns)
		// // part_1 += num
		// fmt.printf("solved: {}\n", num)
	}
}

nums: [dynamic]int

get_prices :: proc(nums: ^[dynamic]int, pattern: [4]int) -> (res: int) {
	for _num in nums {
		num := _num
		last := num
		price := abs(num) % 10
		changes = {}
		inner: for i in 0 ..< 2000 {
			// for _ in 0 ..< 2000 {
			num = solve_secret(num)
			one := abs(num) % 10
			last_one := abs(last) % 10
			change := one - last_one
			price = price + change
			// fmt.printf("now: {} vs {}. change: {} price: {}\n", num, last, change, price)
			changes[i] = change
			last = num
			if i >= 3 {
				if changes[i - 3] == pattern[0] &&
				   changes[i - 2] == pattern[1] &&
				   changes[i - 1] == pattern[2] &&
				   changes[i - 0] == pattern[3] {
					// fmt.printf("Found: {}\n", price)
					res += price
					break inner
				}
			}
		}
	}
	return res
}

day :: proc(input: string) {
	fmt.printf("day 24/22\n")

	assert(prune(100000000) == 16113920)
	assert(mix(42, 15) == 37)

	defer {
		delete(nums)
		delete(patterns)
	}

	part_1 := 0
	part_2 := 0

	lines, _ := strings.split_lines(input)
	defer delete(lines)

	for l in lines {
		num, _ := strconv.parse_int(l)
		append(&nums, num)
	}

	setup_changes(&nums)

	fmt.printf("Ps len = {}\n", len(patterns))

	p_len := len(patterns)
	i := 0
	for p in patterns {
		i += 1
		fmt.printf("{} of {}\n", i, p_len)
		part_2 = max(part_2, get_prices(&nums, p))
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
