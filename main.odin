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
import d2311 "23/11"

// 2024
import d2401 "24/01"
import d2402 "24/02"
import d2403 "24/03"
import d2404 "24/04"
import d2405 "24/05"
import d2406 "24/06"
import d2407 "24/07"
import d2408 "24/08"
import d2409 "24/09"
import d2410 "24/10"
import d2411 "24/11"
import d2412 "24/12"
import d2413 "24/13"
import d2418 "24/18"
import d2419 "24/19"
import d2420 "24/20"
import d2423 "24/23"
import d2425 "24/25"

// EC 2024
import ec_d2401 "everybody.codes/24/01"
time_func :: proc(p: proc(filepath: string), filepath: string) {
	fmt.printf("\n")
	
	// read input
	input, err := os.read_entire_file(filepath)
	defer delete(input)
	start := time.now()
	p(string(input))
	fmt.printf("time: %.2f ms\n", f32(time.now()._nsec - start._nsec) / 1_000_000)
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
	if os.args[1] == "all" || os.args[1] == "2311" do time_func(d2311.day, "23/11/input.txt")

	// 2024
	if os.args[1] == "all" || os.args[1] == "2401" do time_func(d2401.day, "24/01/input.txt")
	if os.args[1] == "all" || os.args[1] == "2402" do time_func(d2402.day, "24/02/input.txt")
	if os.args[1] == "all" || os.args[1] == "2403" do time_func(d2403.day, "24/03/input.txt")
	if os.args[1] == "all" || os.args[1] == "2404" do time_func(d2404.day, "24/04/input.txt")
	if os.args[1] == "all" || os.args[1] == "2405" do time_func(d2405.day, "24/05/input.txt")
	if os.args[1] == "all" || os.args[1] == "2406" do time_func(d2406.day, "24/06/input.txt")
	if os.args[1] == "all" || os.args[1] == "2407" do time_func(d2407.day, "24/07/input.txt")
	if os.args[1] == "all" || os.args[1] == "2408" do time_func(d2408.day, "24/08/input.txt")
	if os.args[1] == "all" || os.args[1] == "2409" do time_func(d2409.day, "24/09/input.txt")
	if os.args[1] == "all" || os.args[1] == "2410" do time_func(d2410.day, "24/10/input.txt")
	if os.args[1] == "all" || os.args[1] == "2411" do time_func(d2411.day, "24/11/input.txt")
	if os.args[1] == "all" || os.args[1] == "2412" do time_func(d2412.day, "24/12/input.txt")
	if os.args[1] == "all" || os.args[1] == "2413" do time_func(d2413.day, "24/13/input.txt")
	if os.args[1] == "all" || os.args[1] == "2418" do time_func(d2418.day, "24/18/input.txt")
	if os.args[1] == "all" || os.args[1] == "2419" do time_func(d2419.day, "24/19/input.txt")
	if os.args[1] == "all" || os.args[1] == "2420" do time_func(d2420.day, "24/20/input.txt")
	if os.args[1] == "all" || os.args[1] == "2423" do time_func(d2423.day, "24/23/input.txt")
	if os.args[1] == "all" || os.args[1] == "2425" do time_func(d2425.day, "24/25/input.txt")

	// EC 2024
	if os.args[1] == "all" || os.args[1] == "ec_2401" do time_func(ec_d2401.day, "everybody.codes/24/01/input.txt")

	fmt.printf("\n\nRan everything in %.2f ms!\n", f32(time.now()._nsec - start_all._nsec) / 1_000_000)
}
