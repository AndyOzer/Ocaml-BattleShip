open Core
open Battleship_helper
open Battleship_placement
open Battleship_gameplay
open Battleship_ai

let simulate_once ~strategy ~board_size ~seed =
	Random.init seed;
	let board = make_empty_board board_size |> auto_place_all_ships in
	let rec aux b count =
		if check_if_game_over b then count
		else
			let coord = strategy b in
			let (b', _) = fire_at_coordinate coord b in
			aux b' (count + 1)
	in
	aux board 0

let simulate_many ~strategy ~board_size ~trials ~seed_start =
	let rec go i acc =
		if i > trials then List.rev acc
		else
			let count = simulate_once ~strategy ~board_size ~seed:(seed_start + i) in
			go (i + 1) (count :: acc)
	in
	go 1 []

let stats_of_counts counts =
	let len = List.length counts in
	if len = 0 then (0, 0, 0.0)
	else
		let sorted = List.sort counts ~compare:Int.compare in
		let min_v = List.hd_exn sorted in
		let max_v = List.hd_exn (List.rev sorted) in
		let sum = List.fold sorted ~init:0 ~f:(+) in
		let avg = (Float.of_int sum) /. (Float.of_int len) in
		(min_v, max_v, avg)

let run_and_print ~name ~strategy ~board_size ~trials ~seed_start =
	Stdio.printf "Running strategy: %s (trials=%d, board_size=%d)\n%!" name trials board_size;
	let counts = simulate_many ~strategy ~board_size ~trials ~seed_start in
	let (min_v, max_v, avg) = stats_of_counts counts in
	Stdio.printf "Results for %s: min=%d max=%d avg=%.2f\n%!" name min_v max_v avg;
	let results_dir = "results" in
	(if not (Stdlib.Sys.file_exists results_dir) then Core_unix.mkdir ~perm:0o755 results_dir else ());
	let file_path = Filename.concat results_dir (name ^ "_counts.txt") in
	Out_channel.with_file file_path ~f:(fun oc ->
		List.iter counts ~f:(fun c -> Out_channel.output_string oc (Printf.sprintf "%d\n" c));
		Out_channel.flush oc
	);
	Stdio.printf "Wrote counts to %s\n%!" file_path;
	counts

let () =
	let trials = 10000 in
	let board_size = 10 in
	let seed_start = 42 in
	(* run easy *)
	let _easy = run_and_print ~name:"easy" ~strategy:easy_next_fire_coordinate ~board_size ~trials ~seed_start in
	(* run medium *)
	let _medium = run_and_print ~name:"medium" ~strategy:medium_next_fire_coordinate ~board_size ~trials ~seed_start in

	(* let _hard = run_and_print ~name:"hard" ~strategy:hard_next_fire_coordinate ~board_size ~trials ~seed_start in *)
	()