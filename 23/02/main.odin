package day2302

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

Game :: [4]int

parse_game :: proc(game: string, g: ^Game) {
	parts, _ := strings.split(game, ": ")
	defer delete(parts)
	game_id_string, _ := strings.split(parts[0], " ")
	defer delete(game_id_string)
	g.a, _ = strconv.parse_int(game_id_string[1])
	sets_strings, _ := strings.split(parts[1], "; ")
	defer delete(sets_strings)
	for set_string in sets_strings {
		sets, _ := strings.split(set_string, ", ")
		defer delete(sets)
		for set in sets {
			n_name, _ := strings.split(set, " ")
			defer delete(n_name)
			n, _ := strconv.parse_int(n_name[0])
			if n_name[1] == "red" do g.r = max(n, g.r)
			if n_name[1] == "blue" do g.b = max(n, g.b)
			if n_name[1] == "green" do g.g = max(n, g.g)
		}
	}

}

day :: proc(input: string) {
	fmt.printf("day 23/02\n")

	lines, err_lines := strings.split_lines(string(input))
	defer delete(lines)

	part_1 := 0
	part_2 := 0

	for line in lines {
		game: Game
		parse_game(line, &game)
		// part 1
		if game.r <= 12 && game.g <= 13 && game.b <= 14 {
			part_1 += game.a
		}
		// part 2
		part_2 += game.r * game.b * game.g
	}
	fmt.printf("Part one: {}\n", part_1)
	fmt.printf("Part two: {}\n", part_2)

}
