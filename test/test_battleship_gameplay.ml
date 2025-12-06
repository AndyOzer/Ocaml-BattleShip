open Core
open OUnit2
open Battleship_types
open Battleship_helper
open Battleship_placement
open Battleship_gameplay

let test_fire_hit _ctx =
  let board = make_empty_board 5 in
  let (b1, msg1) = place_ship_on_board { x_coordinate = 1; y_coordinate = 1 } Destroyer Horizontal board in
  assert_equal "Ship placed successfully" msg1;
  let (b2, msg2) = fire_at_coordinate { x_coordinate = 1; y_coordinate = 1 } b1 in
  assert_equal "Hit!" msg2;
  assert_equal ~printer:string_of_int 1 (List.length b2.ships);
  let cell = List.find_exn b2.battleship_board ~f:(fun c -> coord_equal c.coordinate { x_coordinate = 1; y_coordinate = 1 }) in
  (match cell.cell_type with
   | Hit -> ()
   | _ -> assert_failure "Expected Hit")

let test_fire_miss _ctx =
  let board = make_empty_board 5 in
  let (b1, _) = place_ship_on_board { x_coordinate = 1; y_coordinate = 1 } Destroyer Horizontal board in
  let (b2, msg) = fire_at_coordinate { x_coordinate = 5; y_coordinate = 5 } b1 in
  let (b3, msg_already) = fire_at_coordinate { x_coordinate = 5; y_coordinate = 5 } b2 in
  let (b4, msg_already_hit) = fire_at_coordinate { x_coordinate = 1; y_coordinate = 1 } b3 in
  let (_, msg_already_hit2) = fire_at_coordinate { x_coordinate = 1; y_coordinate = 1 } b4 in
  assert_equal "Miss!" msg;
  assert_equal "Coordinate already targeted" msg_already;
  assert_equal "Hit!" msg_already_hit;
  assert_equal "Coordinate already targeted" msg_already_hit2;
  let cell = List.find_exn b2.battleship_board ~f:(fun c -> coord_equal c.coordinate { x_coordinate = 5; y_coordinate = 5 }) in
  (match cell.cell_type with
   | Miss -> ()
   | _ -> assert_failure "Expected Miss")

let test_fire_out_of_bounds _ctx =
  let board = make_empty_board 5 in
  let (_b, msg) = fire_at_coordinate { x_coordinate = 6; y_coordinate = 1 } board in
  assert_equal "Invalid coordinate: out of bounds" msg

let test_game_over_after_sinking _ctx =
  let board = make_empty_board 5 in
  let (b1, _) = place_ship_on_board { x_coordinate = 1; y_coordinate = 1 } Destroyer Horizontal board in
  let (b2, m1) = fire_at_coordinate { x_coordinate = 1; y_coordinate = 1 } b1 in
  assert_equal "Hit!" m1;
  let (b3, m2) = fire_at_coordinate { x_coordinate = 2; y_coordinate = 1 } b2 in
  assert_equal "Hit!" m2;
  assert_bool "no ships remain" (check_if_game_over b3)

let suite =
  "battleship_gameplay" >::: [
    "test_fire_hit" >:: test_fire_hit;
    "test_fire_miss" >:: test_fire_miss;
    "test_fire_out_of_bounds" >:: test_fire_out_of_bounds;
    "test_game_over_after_sinking" >:: test_game_over_after_sinking;
  ]

let () = run_test_tt_main suite
