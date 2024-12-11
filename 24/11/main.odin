package d2411

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

Cache_key :: struct {
	key:   string,
	depth: int,
}

solve_n :: proc(n: string, depth: int, cache: ^map[Cache_key]int) -> int {
	key: Cache_key = {
		key   = strings.clone_from(n),
		depth = depth,
	}
	if key in cache do return cache[key]

	// handle when no depth "left"
	if depth == 0 do return 1

	// handle "0"
	if n == "0" do return solve_n("1", depth - 1, cache)

	// handle string of even length
	if len(n) % 2 == 0 {
		f, s := split(n)
		cache[key] = solve_n(f, depth - 1, cache) + solve_n(s, depth - 1, cache)
		return cache[key]
	}

	// fall through: multiply by 2024
	val := strings.clone_from(n)

	n, _ := strconv.parse_int(val)
	buf: [16]u8
	r1 := strings.clone_from(strconv.itoa(buf[:], n * 2024))

	cache[key] = solve_n(r1, depth - 1, cache)
	return cache[key]
}


split :: proc(val: string) -> (string, string) {
	first_half := strings.clone_from(string(val[:len(val) / 2][:]))
	snd_half := strings.clone_from(string(val[len(val) / 2:][:]))

	n, _ := strconv.parse_int(first_half)
	buf: [16]u8
	first_half_str := strings.clone_from(strconv.itoa(buf[:], n))

	n, _ = strconv.parse_int(snd_half)
	buf2: [16]u8
	snd_half_str := strings.clone_from(strconv.itoa(buf2[:], n))

	return first_half_str, snd_half_str

}

day :: proc(input: string) {
	fmt.printf("day 24/11\n")

	part_1 := 0
	part_2 := 0

	input: []string = {"20", "82084", "1650", "3", "346355", "363", "7975858", "0"}

	default_allocator := context.allocator
	context.allocator = context.temp_allocator

	cache : map[Cache_key]int

	for i in input {
		part_1 += solve_n(i, 25, &cache)
		part_2 += solve_n(i, 75, &cache)
	}

	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

	// clean up temp allocator
	free_all(context.temp_allocator)

	delete(cache)

	// reset allocator
	context.allocator = default_allocator

}
