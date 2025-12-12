open Core
open OUnit2
open Battleship_helper
open Battleship_types

let test_coord_equal _ctx =
  let a = { x_coordinate = 1; y_coordinate = 2 } in
  let b = { x_coordinate = 1; y_coordinate = 2 } in
  let c = { x_coordinate = 2; y_coordinate = 3 } in
  assert_bool "coords equal" (coord_equal a b);
  assert_bool "coords not equal" (not (coord_equal a c))

let test_coord_in_list _ctx =
  let c1 = { x_coordinate = 1; y_coordinate = 1 } in
  let c2 = { x_coordinate = 1; y_coordinate = 2 } in
  let lst = [c1; c2] in
  assert_bool "in list" (coord_in_list c1 lst);
  assert_bool "not in list" (not (coord_in_list { x_coordinate = 3; y_coordinate = 3 } lst))

let test_make_cell_and_board _ctx =
  let cell = make_cell 2 3 in
  assert_equal { x_coordinate = 2; y_coordinate = 3 } cell.coordinate;
  assert_equal Empty cell.cell_type;
  let board = make_empty_board 4 in
  assert_equal 16 (List.length board.battleship_board);
  assert_equal [] board.ships

let test_ship_contains_and_sunk _ctx =
  let c1 = { x_coordinate = 1; y_coordinate = 1 } in
  let c2 = { x_coordinate = 1; y_coordinate = 2 } in
  let ship = { battleship_type = Destroyer; orientation = Horizontal; coordinates = [c1; c2]; hits = [] } in
  assert_bool "contains c1" (ship_contains_coordinate ship c1);
  assert_bool "not sunk initially" (not (ship_is_sunk ship));
  let ship_with_hits = { ship with hits = [c1; c2] } in
  assert_bool "now sunk" (ship_is_sunk ship_with_hits)

let test_remove_sunk_ships _ctx =
  let c1 = { x_coordinate = 1; y_coordinate = 1 } in
  let c2 = { x_coordinate = 1; y_coordinate = 2 } in
  let sunk = { battleship_type = Destroyer; orientation = Horizontal; coordinates = [c1; c2]; hits = [c1; c2] } in
  let alive = { battleship_type = Cruiser; orientation = Vertical; coordinates = [{ x_coordinate = 3; y_coordinate = 3 }]; hits = [] } in
  let board = { board_size = 5; battleship_board = []; ships = [sunk; alive] } in
  let board' = remove_sunk_ships board in
  assert_equal 1 (List.length board'.ships);
  assert_equal Cruiser (List.hd_exn board'.ships).battleship_type

let suite =
  "battleship_helper" >::: [
    "test_coord_equal" >:: test_coord_equal;
    "test_coord_in_list" >:: test_coord_in_list;
    "test_make_cell_and_board" >:: test_make_cell_and_board;
    "test_ship_contains_and_sunk" >:: test_ship_contains_and_sunk;
    "test_remove_sunk_ships" >:: test_remove_sunk_ships;
  ]

let () = run_test_tt_main suite
