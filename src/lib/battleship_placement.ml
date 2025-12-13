open Battleship_types
open Battleship_helper

let generate_ship_coordinates (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) : Battleship_types.coordinate list =
  let size = ship_size ship_type in
  let rec aux coord acc n =
    match n = 0 with
    | true -> List.rev acc
    | false ->
      (* Add next coordinate to the list *)
      let next_coordinate =
        match input_orientation with
        | Horizontal -> { x_coordinate = coord.x_coordinate + 1; y_coordinate = coord.y_coordinate }
        | Vertical -> { x_coordinate = coord.x_coordinate; y_coordinate = coord.y_coordinate + 1 }
      in
      aux next_coordinate (coord :: acc) (n - 1)
  in
  aux start_coordinate [] size

let is_ship_within_bounds (coordinate_list: Battleship_types.coordinate list) (board: Battleship_types.board) : bool =
  List.for_all (fun coord ->
    coord.x_coordinate >= 1 && coord.x_coordinate <= board.board_size &&
    coord.y_coordinate >= 1 && coord.y_coordinate <= board.board_size
  ) coordinate_list

let does_ship_overlap (coordinate_list: Battleship_types.coordinate list) (board: Battleship_types.board) : bool =
  board.ships |> List.exists (fun ship ->
    coordinate_list |> List.exists (fun coord -> ship_contains_coordinate ship coord)
  )

let is_ship_coordinate_valid (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) (board: Battleship_types.board) : bool =
  let ship_coords = generate_ship_coordinates start_coordinate ship_type input_orientation in
  let within = ship_coords |> fun coords -> is_ship_within_bounds coords board in
  let overlap = ship_coords |> fun coords -> does_ship_overlap coords board in
  within && not overlap

let place_ship_on_board (start_coordinate: Battleship_types.coordinate) (ship_type: Battleship_types.ship_type) (input_orientation: Battleship_types.ship_orientation) (board: Battleship_types.board) : Battleship_types.board * string =
  match (is_ship_coordinate_valid start_coordinate ship_type input_orientation board) with
  | false -> (board, "Invalid ship placement: out of bounds or overlaps existing ship")
  | true ->
    let ship_coords = generate_ship_coordinates start_coordinate ship_type input_orientation in
    let new_ship =
      {
        battleship_type = ship_type;
        orientation = input_orientation;
        coordinates = ship_coords;
        hits = [];
      }
    in
    let updated_board_cells = board.battleship_board |> List.map (fun cell ->
      match coord_in_list cell.coordinate ship_coords with
      | true -> { coordinate = cell.coordinate; cell_type = ShipPart ship_type }
      | false -> cell
    )
    in
    let new_board = { board with battleship_board = updated_board_cells; ships = new_ship :: board.ships } in
    (new_board, "Ship placed successfully")

let auto_place_all_ships (board: Battleship_types.board) : Battleship_types.board =
  let ship_types = [Carrier; Battleship; Cruiser; Submarine; Destroyer] in
  let orientations = [Horizontal; Vertical] in
  let rec place_ships b ships_to_place =
    match ships_to_place with
    | [] -> b
    | ship_type :: rest ->
      let rec try_place b =
        let x = Random.int board.board_size + 1 in
        let y = Random.int board.board_size + 1 in
        let orientation = Random.int (List.length orientations) |> (fun idx -> List.nth orientations idx) in
        let start_coord = { x_coordinate = x; y_coordinate = y } in
        match is_ship_coordinate_valid start_coord ship_type orientation b with
        | true ->
          (let (new_board, msg) = place_ship_on_board start_coord ship_type orientation b in
            match msg with
            | "Ship placed successfully" -> new_board
            | _ -> try_place b)
        | false -> try_place b
      in
      let new_board = try_place b in
      place_ships new_board rest
  in
  place_ships board ship_types

let place_ship_by_index_and_coords (index: int) (coord1: Battleship_types.coordinate) (coord2: Battleship_types.coordinate) (board: Battleship_types.board) : Battleship_types.board * string =
  let get_ship_by_index i =
    match i with
    | 1 -> Some Carrier
    | 2 -> Some Battleship
    | 3 -> Some Cruiser
    | 4 -> Some Submarine
    | 5 -> Some Destroyer
    | _ -> None
  in
  match get_ship_by_index index with
  | Some ship ->
    let x1, y1 = coord1.x_coordinate, coord1.y_coordinate in
    let x2, y2 = coord2.x_coordinate, coord2.y_coordinate in
    let length = ship_size ship in
    let valid_placement =
      match x1 = x2 with
      | true ->
        (match abs (y1 - y2) + 1 = length with
        | true -> Some (Vertical, { x_coordinate = x1; y_coordinate = min y1 y2 })
        | false ->
          match y1 = y2 with
          | true ->
            (match abs (x1 - x2) + 1 = length with
            | true -> Some (Horizontal, { x_coordinate = min x1 x2; y_coordinate = y1 })
            | false -> None
            )
          | false -> None
        )
      | false -> None
    in
    (match valid_placement with
    | Some (orientation, start_coord) ->
      place_ship_on_board start_coord ship orientation board
    | None -> (board, "Invalid ship placement: incorrect length or not straight")
    )
  | None -> (board, "Invalid ship index")