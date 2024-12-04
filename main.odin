package main

import "core:fmt"
import "core:mem"
import "core:os"
import "core:time"

import d2301 "23/01"
import d2302 "23/02"
import d2303 "23/03"
import d2304 "23/04"
import d2305 "23/05"
import d2306 "23/06"
import d2307 "23/07"
import d2308 "23/08"
import d2309 "23/09"
import d2310 "23/10"

// 2024
import d2401 "24/01"
import d2402 "24/02"
import d2403 "24/03"
import d2404 "24/04"

// EC 2024
import ec_d2401 "everybody.codes/24/01"
time_func :: proc(p: proc(filepath: string), filepath: string) {
	fmt.printf("\n")
	start := time.now()
	p(filepath)
	fmt.printf("time: {} ms\n", (time.now()._nsec - start._nsec) / 1_000_000)
}

main :: proc() {
	if len(os.args) < 2 {
		fmt.panicf("Usage: Run with all or 1/2/3 etc.")
	}
	// setup tracking allocator...
	fmt.printf("Setting up tracking allocator\n")
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
			}
		}
		if len(track.bad_free_array) > 0 {
			fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
			for entry in track.bad_free_array {
				fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
			}
		}
		mem.tracking_allocator_destroy(&track)
	}

	start_all := time.now()
	if os.args[1] == "all" || os.args[1] == "2301" do time_func(d2301.day, "23/01/input.txt")
	if os.args[1] == "all" || os.args[1] == "2302" do time_func(d2302.day, "23/02/input.txt")
	if os.args[1] == "all" || os.args[1] == "2303" do time_func(d2303.day, "23/03/input.txt")
	if os.args[1] == "all" || os.args[1] == "2304" do time_func(d2304.day, "23/04/input.txt")
	if os.args[1] == "all" || os.args[1] == "2305" {
		fmt.printf("\n")
		start := time.now()
		// silly, run this with true to run sloooooow part 2!
		d2305.day("23/05/input.txt", false)
		fmt.printf("time: {} ms\n", (time.now()._nsec - start._nsec) / 1_000_000)
	}
	if os.args[1] == "all" || os.args[1] == "2306" do time_func(d2306.day, "23/06/input.txt")
	if os.args[1] == "all" || os.args[1] == "2307" do time_func(d2307.day, "23/07/input.txt")
	if os.args[1] == "all" || os.args[1] == "2308" do time_func(d2308.day, "23/08/input.txt")
	if os.args[1] == "all" || os.args[1] == "2309" do time_func(d2309.day, "23/09/input.txt")
	if os.args[1] == "all" || os.args[1] == "2310" do time_func(d2310.day, "23/10/input.txt")

	// 2024
	if os.args[1] == "all" || os.args[1] == "2401" do time_func(d2401.day, "24/01/input.txt")
	if os.args[1] == "all" || os.args[1] == "2402" do time_func(d2402.day, "24/02/input.txt")
	if os.args[1] == "all" || os.args[1] == "2403" do time_func(d2403.day, "24/03/input.txt")
	if os.args[1] == "all" || os.args[1] == "2404" do time_func(d2404.day, "24/04/input.txt")

	// EC 2024
	if os.args[1] == "all" || os.args[1] == "ec_2401" do time_func(ec_d2401.day, "everybody.codes/24/01/input.txt")

	fmt.printf("\n\nRan all days in {} ms!\n", (time.now()._nsec - start_all._nsec) / 1_000_000)
}
