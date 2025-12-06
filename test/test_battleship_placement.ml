open Core
open OUnit2
open Battleship_types
open Battleship_helper
open Battleship_placement

let test_generate_ship_coordinates _ctx =
	let start = { x_coordinate = 1; y_coordinate = 1 } in
	let coords = generate_ship_coordinates start Carrier Horizontal in
	assert_equal ~printer:string_of_int 5 (List.length coords);
	assert_equal start (List.hd_exn coords);
	let last = List.nth_exn coords 4 in
	assert_equal { x_coordinate = 5; y_coordinate = 1 } last

let test_is_ship_within_bounds _ctx =
	let board = make_empty_board 5 in
	let good = generate_ship_coordinates { x_coordinate = 1; y_coordinate = 1 } Carrier Horizontal in
	let bad = generate_ship_coordinates { x_coordinate = 3; y_coordinate = 1 } Carrier Horizontal in
	assert_bool "within bounds" (is_ship_within_bounds good board);
	assert_bool "out of bounds" (not (is_ship_within_bounds bad board))

let test_does_ship_overlap_and_is_valid _ctx =
	let board = make_empty_board 5 in
	let (b2, msg) = place_ship_on_board { x_coordinate = 1; y_coordinate = 1 } Destroyer Horizontal board in
	assert_equal "Ship placed successfully" msg;
	assert_bool "overlap detected" (does_ship_overlap (generate_ship_coordinates { x_coordinate = 1; y_coordinate = 1 } Cruiser Vertical) b2);
	assert_bool "valid placement false for overlapping" (not (is_ship_coordinate_valid { x_coordinate = 1; y_coordinate = 1 } Destroyer Horizontal b2));
	assert_bool "valid placement true for non-overlap" (is_ship_coordinate_valid { x_coordinate = 3; y_coordinate = 3 } Cruiser Vertical b2)

let test_place_ship_on_board_updates_board _ctx =
	let board = make_empty_board 5 in
	let (b2, msg) = place_ship_on_board { x_coordinate = 2; y_coordinate = 2 } Cruiser Vertical board in
	assert_equal "Ship placed successfully" msg;
	assert_equal ~printer:string_of_int 1 (List.length b2.ships);
	assert_equal Cruiser (List.hd_exn b2.ships).battleship_type;
	let ship_coords = (List.hd_exn b2.ships).coordinates in
	List.iter ~f:(fun coord ->
		let cell = List.find_exn b2.battleship_board ~f:(fun c -> coord_equal c.coordinate coord) in
		match cell.cell_type with
		| ShipPart t -> assert_equal Cruiser t
		| _ -> assert_failure "Expected ShipPart"
	) ship_coords

let test_place_ship_on_board_invalid _ctx =
	let board = make_empty_board 5 in
	let (b2, msg) = place_ship_on_board { x_coordinate = 3; y_coordinate = 1 } Carrier Horizontal board in
	assert_equal "Invalid ship placement: out of bounds or overlaps existing ship" msg;
	assert_equal ~printer:string_of_int 0 (List.length b2.ships)

let test_auto_place_all_ships _ctx =
	let board = make_empty_board 5 in
	Random.init 42;
	let b2 = auto_place_all_ships board in
	assert_equal ~printer:string_of_int 5 (List.length b2.ships);
	let ship_cells = List.count b2.battleship_board ~f:(fun c -> match c.cell_type with ShipPart _ -> true | _ -> false) in
	assert_equal ~printer:string_of_int 17 ship_cells

let suite =
	"battleship_placement" >::: [
		"test_generate_ship_coordinates" >:: test_generate_ship_coordinates;
		"test_is_ship_within_bounds" >:: test_is_ship_within_bounds;
		"test_does_ship_overlap_and_is_valid" >:: test_does_ship_overlap_and_is_valid;
		"test_place_ship_on_board_updates_board" >:: test_place_ship_on_board_updates_board;
		"test_place_ship_on_board_invalid" >:: test_place_ship_on_board_invalid;
		"test_auto_place_all_ships" >:: test_auto_place_all_ships;
	]

let () = run_test_tt_main suite

