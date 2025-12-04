open Battleship_types
open Battleship_helper

let fire_at_coordinate (target_coordinate: Battleship_types.coordinate) (board: Battleship_types.board) : Battleship_types.board * string =
  let cell_opt = List.find_opt (fun cell -> coord_equal cell.coordinate target_coordinate) board.battleship_board in
  match cell_opt with
  | None -> (board, "Invalid coordinate: out of bounds")
  | Some cell ->
      match cell.cell_type with
      | Hit | Miss -> (board, "Coordinate already targeted")
      | ShipPart ship_type ->
          let updated_cells = List.map (fun c ->
            if coord_equal c.coordinate target_coordinate then
              { c with cell_type = Hit }
            else
              c
          ) board.battleship_board in
          let updated_ships = List.map (fun ship ->
            if List.exists (coord_equal target_coordinate) ship.coordinates then
              { ship with hits = target_coordinate :: ship.hits }
            else
              ship
          ) board.ships in
          let new_board = { board with battleship_board = updated_cells; ships = updated_ships } in

          let final_board = remove_sunk_ships new_board in
          (final_board, "Hit!")
      | Empty ->
          let updated_cells = List.map (fun c ->
            if coord_equal c.coordinate target_coordinate then
              { c with cell_type = Miss }
            else
              c
          ) board.battleship_board in
          let new_board = { board with battleship_board = updated_cells } in
          (new_board, "Miss!")


let check_if_game_over (board: Battleship_types.board) : bool =
  board.ships = []

