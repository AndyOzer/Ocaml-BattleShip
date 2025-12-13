open Battleship_types
open Battleship_helper

let fire_at_coordinate (target_coordinate: Battleship_types.coordinate) (board: Battleship_types.board) : Battleship_types.board * string =
  let cell_opt = board.battleship_board |> List.find_opt (fun cell -> coord_equal cell.coordinate target_coordinate) in
  match cell_opt with
  | None -> (board, "Invalid coordinate: out of bounds")
  | Some cell ->
    match cell.cell_type with
    | Hit | Miss -> (board, "Coordinate already targeted")
    | ShipPart _ ->
      let updated_cells = board.battleship_board |> List.map (fun c ->
        match coord_equal c.coordinate target_coordinate with
        | true -> { coordinate = c.coordinate; cell_type = Hit }
        | false -> c
      )
      in
      let updated_ships = board.ships |> List.map (fun ship ->
          { battleship_type = ship.battleship_type; orientation = ship.orientation; coordinates = ship.coordinates; hits = target_coordinate :: ship.hits }
      )
      in
      let new_board = { board with battleship_board = updated_cells; ships = updated_ships } in
      let final_board = new_board |> remove_sunk_ships in
      (final_board, "Hit!")
    | Empty ->
      let updated_cells = board.battleship_board |> List.map (fun c ->
        match coord_equal c.coordinate target_coordinate with
        | true -> { coordinate = c.coordinate; cell_type = Miss }
        | false -> c
      )
      in
      let new_board = { board with battleship_board = updated_cells } in
      (new_board, "Miss!")

let check_if_game_over (board: Battleship_types.board) : bool =
  board.ships = []