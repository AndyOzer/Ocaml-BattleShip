open Battleship_types
open Battleship_helper

let fire_at_coordinate (target_coordinate: Battleship_types.coordinate) (board: Battleship_types.board) : Battleship_types.board * string =
  let cell_opt = List.find_opt (fun cell -> coord_equal cell.coordinate target_coordinate) board.battleship_board in
  match cell_opt with
  | None -> (board, "Invalid coordinate: out of bounds")
  | Some cell ->
      match cell.cell_type with
      | Hit | Miss -> (board, "Coordinate already targeted")
      | ShipPart _ ->
          let updated_cells = List.map (fun c ->
            if coord_equal c.coordinate target_coordinate then
              { coordinate = c.coordinate; cell_type = Hit }
            else
              c
          ) board.battleship_board in
          let updated_ships = List.map (fun ship ->
            if List.exists (coord_equal target_coordinate) ship.coordinates then
              { battleship_type = ship.battleship_type; orientation = ship.orientation; coordinates = ship.coordinates; hits = target_coordinate :: ship.hits }
            else
              ship
          ) board.ships in
          let new_board = { board_size = board.board_size; battleship_board = updated_cells; ships = updated_ships } in

          let final_board = remove_sunk_ships new_board in
          (final_board, "Hit!")
      | Empty ->
          let updated_cells = List.map (fun c ->
            if coord_equal c.coordinate target_coordinate then
              { coordinate = c.coordinate; cell_type = Miss }
            else
              c
          ) board.battleship_board in
          let new_board = { board_size = board.board_size; battleship_board = updated_cells; ships = board.ships } in
          (new_board, "Miss!")


let check_if_game_over (board: Battleship_types.board) : bool =
  board.ships = []

