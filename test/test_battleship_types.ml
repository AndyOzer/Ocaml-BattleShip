open Core
open OUnit2
open Battleship_types

let test_ship_size _ =
  assert_equal ~printer:string_of_int 5 (ship_size Carrier);
  assert_equal ~printer:string_of_int 4 (ship_size Battleship);
  assert_equal ~printer:string_of_int 3 (ship_size Cruiser);
  assert_equal ~printer:string_of_int 3 (ship_size Submarine);
  assert_equal ~printer:string_of_int 2 (ship_size Destroyer)

let test_cell_creation _ =
  let c = { x_coordinate = 1; y_coordinate = 2 } in
  let cell = { coordinate = c; cell_type = Empty } in
  assert_equal c cell.coordinate;
  assert_equal Empty cell.cell_type

let test_ship_structure _ =
  let c1 = { x_coordinate = 1; y_coordinate = 1 } in
  let c2 = { x_coordinate = 1; y_coordinate = 2 } in
  let ship = { battleship_type = Destroyer; orientation = Horizontal; coordinates = [c1; c2]; hits = [] } in
  assert_equal Destroyer ship.battleship_type;
  assert_equal ~printer:string_of_int 2 (List.length ship.coordinates)

let suite =
  "battleship_types" >::: [
    "test_ship_size" >:: test_ship_size;
    "test_cell_creation" >:: test_cell_creation;
    "test_ship_structure" >:: test_ship_structure;
  ]

let () = run_test_tt_main suite
