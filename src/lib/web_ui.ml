open Core
open Battleship_types
open Battleship_helper
open Battleship_placement
open Battleship_gameplay
open Battleship_ai
open Option.Monad_infix

(* Serialization board and encode to BASE64 *)
let board_to_serialized (board : board) : string =
  board |> sexp_of_board |> Sexp.to_string |> Dream.to_base64url

(* Decode BASE64 and deserialize board *)
let board_to_deserialized (s : string) : board =
  match Dream.from_base64url s with
  | Some decoded -> decoded |> Sexp.of_string |> board_of_sexp
  | None -> failwith "BASE64 decoding failed"

(* Render board into HTML cells *)
let board_to_render_html (board : board) (side : string) (game_state : string) : string =
  match game_state with
  | "game" ->
    (match side with
    | "p1" ->
      (* State - Game, Side - P1: Cell should not take click, show ships *)
      List.map board.battleship_board
        ~f:(fun cell -> let html_class_color =
            match cell.cell_type with
            | Empty -> "bg-blue-400 opacity-50"
            | ShipPart _ -> "bg-gray-600 border-gray-700 shadow-inner opacity-50"
            | Hit -> "bg-red-600 animate-pulse shadow-[0_0_10px_rgba(220,38,38,0.7)]"
            | Miss -> "bg-white opacity-60"
          in
          Printf.sprintf "<div class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm transition-all duration-300\"></div>" html_class_color
        )
      |> String.concat
    | "p2" ->
      (* State - Game, Side - P2: Cell should take click, hide ships *)
      List.map board.battleship_board
        ~f:(fun cell -> let html_class_color =
            match cell.cell_type with
            | Empty -> "bg-blue-400 hover:bg-blue-300 hover:scale-105 hover:shadow-lg hover:z-10"
            | ShipPart _ -> "bg-blue-400 hover:bg-blue-300 hover:scale-105 hover:shadow-lg hover:z-10"
            | Hit -> "bg-red-600 shadow-[0_0_10px_rgba(220,38,38,0.7)]"
            | Miss -> "bg-white opacity-60"
          in
          Printf.sprintf
            "<div
              class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm cursor-pointer transition-all duration-200 active:scale-95\"
              hx-post=\"/game\"
              hx-include=\"#board-state-p1, #board-state-p2, #game-state, #game-diff\"
              hx-vals='{\"side\": \"p2\", \"x\": \"%d\", \"y\": \"%d\"}'
              hx-target=\"#boards\"
              hx-swap=\"outerHTML\"
            >
            </div>"
            html_class_color cell.coordinate.x_coordinate cell.coordinate.y_coordinate
        )
      |> String.concat
    | _ ->
      (* Parameter side invalid *)
      "Error: Invalid side"
    )
  | "end1" | "end2" ->
    (* State - End: Cell should not take click, show ships *)
    List.map board.battleship_board
      ~f:(fun cell -> let html_class_color =
          match cell.cell_type with
          | Empty -> "bg-blue-400 opacity-80"
          | ShipPart _ -> "bg-gray-600 border-gray-700 shadow-inner"
          | Hit -> "bg-red-600 shadow-[0_0_10px_rgba(220,38,38,0.7)]"
          | Miss -> "bg-white opacity-60"
        in
        Printf.sprintf "<div class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm\"></div>" html_class_color
      )
    |> String.concat
  | s when String.is_prefix s ~prefix:"place" ->
    (match side with
    | "p1" ->
      (* State - Placement, Side - P1: Cell should take click, show ship during placement *)
      (* Get coordinate of first placed position if exists *)
      let placed_coord_opt =
        try let game_state = 
            match String.contains game_state 'E' with
            | true -> String.filter game_state ~f:(fun c -> Char.(c <> 'E'))
            | false -> game_state 
          in Scanf.sscanf game_state "place%d(%d,%d)" (fun _ x y -> Some (x, y))
        with _ -> None
      in
      List.map board.battleship_board
        ~f:(fun cell ->
          let is_placed = 
            match placed_coord_opt with
            | Some (x, y) -> cell.coordinate.x_coordinate = x && cell.coordinate.y_coordinate = y
            | None -> false
          in
          match cell.cell_type with
          | ShipPart _ ->
            (* Existing ship: Not clickable *)
            let html_class_color = "bg-gray-600 border-gray-700 shadow-inner opacity-90" in
            Printf.sprintf "<div class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm\"></div>" html_class_color
          | _ ->
            (* Should be Empty or placed first point *)
            if is_placed then
              (* Placed first point: Highlighted *)
              let html_class_color = "bg-amber-400 border-amber-500 shadow-[0_0_15px_rgba(251,191,36,0.8)] z-20 scale-110 ring-2 ring-amber-300" in
              Printf.sprintf "<div class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm\"></div>" html_class_color
            else
              (* Empty cell: Clickable *)
              let html_class_color = "bg-blue-400 hover:bg-blue-300 hover:scale-105 hover:shadow-lg hover:z-10 cursor-pointer transition-all duration-200 active:scale-95" in
              Printf.sprintf
                "<div
                  class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm\"
                  hx-post=\"/game\"
                  hx-include=\"#board-state-p1, #board-state-p2, #game-state, #game-diff\"
                  hx-vals='{\"side\": \"p1\", \"x\": \"%d\", \"y\": \"%d\"}'
                  hx-target=\"#boards\"
                  hx-swap=\"outerHTML\"
                >
                </div>"
                html_class_color cell.coordinate.x_coordinate cell.coordinate.y_coordinate
        )
      |> String.concat
    | "p2" ->
      (* State - Placement, Side - P2: Cell should take click to trigger auto placement, hide ships *)
      List.map board.battleship_board
        ~f:(fun cell -> let html_class_color =
            match cell.cell_type with
            | Empty -> "bg-blue-400 opacity-50 hover:bg-blue-300 hover:scale-105 hover:shadow-lg hover:z-10 hover:opacity-100"
            | ShipPart _ -> "bg-blue-400 opacity-50 hover:bg-blue-300 hover:scale-105 hover:shadow-lg hover:z-10 hover:opacity-100"
            | _ -> "bg-white"
          in
          Printf.sprintf
            "<div
              class=\"w-8 h-8 %s border border-blue-300/30 rounded-sm cursor-pointer transition-all duration-200 active:scale-95\"
              hx-post=\"/game\"
              hx-include=\"#board-state-p1, #board-state-p2, #game-state, #game-diff\"
              hx-vals='{\"side\": \"p2\", \"x\": \"%d\", \"y\": \"%d\"}'
              hx-target=\"#boards\"
              hx-swap=\"outerHTML\"
            >
            </div>"
            html_class_color cell.coordinate.x_coordinate cell.coordinate.y_coordinate
        )
      |> String.concat
    | _ ->
      (* Parameter side invalid *)
      "Error: Invalid side"
    )
  | _ ->
    (* Parameter game_state invalid *)
    "Error: Invalid game state"

(* Render P1 & P2 boards into HTML *)
let boards_to_html (board_p1 : board) (board_p2 : board) (game_diff : string) (game_state : string): string =
  let html_cells_p1 = board_to_render_html board_p1 "p1" game_state in
  let html_cells_p2 = board_to_render_html board_p2 "p2" game_state in
  let html_title_p1 =
    match game_state with
    | "game" -> "Your Board"
    | "end1" -> "😭 You Lose! 😭"
    | "end2" -> "🎉 You Win! 🎉"
    | state when String.is_prefix state ~prefix:"place" ->
      let is_error = if String.contains state 'E' then "Invalid Placement!" else "" in
      let msg = match game_state with
        | state when String.is_prefix state ~prefix:"place1" -> "Place Your Carrier - 1 x 5"
        | state when String.is_prefix state ~prefix:"place2" -> "Place Your Battleship - 1 x 4"
        | state when String.is_prefix state ~prefix:"place3" -> "Place Your Cruiser - 1 x 3"
        | state when String.is_prefix state ~prefix:"place4" -> "Place Your Submarine - 1 x 3"
        | state when String.is_prefix state ~prefix:"place5" -> "Place Your Destroyer - 1 x 2"
        | _ -> "Error: Invalid placement state"
      in Printf.sprintf "🚢 %s %s 🚢" is_error msg
    | _ -> "Error: Invalid game state"
  in
  let html_title_p2 =
    match game_diff with
    | "dm" -> "😈 Enemy Board - Demon Mode 😈"
    | _ -> "Enemy Board"
  in
  Printf.sprintf
    "<div id=\"boards\" class=\"flex gap-8 flex-wrap justify-center\">
      <input type=\"hidden\" id=\"game-state\" name=\"game_state\" value=\"%s\">
      <input type=\"hidden\" id=\"game-diff\" name=\"game_diff\" value=\"%s\">
      <input type=\"hidden\" id=\"board-state-p1\" name=\"board_state_p1\" value=\"%s\">
      <input type=\"hidden\" id=\"board-state-p2\" name=\"board_state_p2\" value=\"%s\">
      <div id=\"board-p1\" class=\"flex flex-col items-center p-4 bg-white rounded-xl shadow-lg\">
        <h2 class=\"text-xl font-bold mb-2\">%s</h2>
        <div class=\"grid gap-1 p-2 bg-blue-50 rounded\" style=\"grid-template-columns: repeat(%d, minmax(0, 1fr));\">
          %s
        </div>
      </div>
      <div id=\"board-p2\" class=\"flex flex-col items-center p-4 bg-white rounded-xl shadow-lg\">
        <h2 class=\"text-xl font-bold mb-2\">%s</h2>
        <div class=\"grid gap-1 p-2 bg-blue-50 rounded\" style=\"grid-template-columns: repeat(%d, minmax(0, 1fr));\">
          %s
        </div>
      </div>
    </div>"
    game_state game_diff (board_to_serialized board_p1) (board_to_serialized board_p2)
    html_title_p1 board_p1.board_size html_cells_p1
    html_title_p2 board_p2.board_size html_cells_p2

(* Web GET request handler for route "/" *)
let hdlr_index _request =
  try
    Dream.html @@ In_channel.read_all "web/index.html"
  with _ ->
    Dream.html "<h1>Failed to load index.html</h1>"

(* Web GET request handler for route "/game" *)
let hdlr_game_get request =
  match Dream.header request "HX-Request" with
  | Some "true" ->
    (* HTMX GET request, start a new game *)
    let size_req = Dream.query request "size" in
    let diff_req = Dream.query request "diff" in
    let size_opt =
      try
        size_req
        >>= fun s -> Some (Int.of_string s)
        >>= fun x -> if x > 9 && x < 21 then Some x else None
      with _ -> None
    in
    let diff_opt =
      diff_req
      >>= (fun d -> match d with
      | "ez" | "md" | "hd" -> Some d
      | _ -> None)
      >>= (fun d -> match size_opt with
      | Some _ -> Some d
      | None -> None)
    in
    let size = Option.value size_opt ~default:10 in
    let diff = Option.value diff_opt ~default:"dm" in
    (* Create empty boards *)
    let board_p1 = make_empty_board size in
    let board_p2 = make_empty_board size in
    let html_boards = boards_to_html board_p1 board_p2 diff "place1()" in
    Dream.html html_boards
  | _ ->
    (* Static HTML request *)
    try
      Dream.html @@ In_channel.read_all "web/game.html"
    with _ ->
      Dream.html "<h1>Failed to load game.html</h1>"

(* Run game logic: Fire P2 then P1 *)
let run_game x y board_p1 board_p2 diff =
  let coord = { x_coordinate = x; y_coordinate = y } in
  let board_p2_fired, _ = fire_at_coordinate coord board_p2 in
  if check_if_game_over board_p2_fired then
    boards_to_html board_p1 board_p2_fired diff "end2"
  else
    let coord_p1 = 
      match diff with
      | "ez" -> easy_next_fire_coordinate board_p1
      | "md" -> medium_next_fire_coordinate board_p1
      | "hd" -> hard_next_fire_coordinate board_p1
      | _ -> optimal_next_fire_coordinate board_p1
    in
    let board_p1_fired, _ = fire_at_coordinate coord_p1 board_p1 in
    if check_if_game_over board_p1_fired then
      boards_to_html board_p1_fired board_p2_fired diff "end1"
    else
      boards_to_html board_p1_fired board_p2_fired diff "game"

(* Run placement logic *)
let run_placement x y board_p1 diff game_state =
  let size = board_p1.board_size in
  let board_p2 = make_empty_board size in
  try
    (* Prior coordinate exists: Place second coordinate *)
    Scanf.sscanf game_state "place%d(%d,%d)" (fun i x1 y1 ->
      let coord1 = { x_coordinate = x1; y_coordinate = y1 } in
      let coord2 = { x_coordinate = x; y_coordinate = y } in
      let (board_placed, msg) = place_ship_by_index_and_coords i coord1 coord2 board_p1 in
      match String.equal msg "Ship placed successfully" with
      | true ->
        (match i < 5 with
        | true -> boards_to_html board_placed board_p2 diff @@ Printf.sprintf "place%d()" (i + 1)
        | false -> boards_to_html board_placed (auto_place_all_ships board_p2) diff "game"
        )
      | false ->
        (* Placement failed: Set Error flag *)
        boards_to_html board_p1 board_p2 diff @@ Printf.sprintf "place%dE()" i
    )
  with _ ->
    try
      (* Prior coordinate empty: Place first coordinate *)
      let i =
        try Scanf.sscanf game_state "place%dE()" (fun i -> i)
        with _ -> Scanf.sscanf game_state "place%d()" (fun i -> i)
      in
      let state_placed = Printf.sprintf "place%d(%d,%d)" i x y in
      boards_to_html board_p1 board_p2 diff state_placed
    with _ ->
      (* Unknown state, we should not get here: Fail over to initial placement *)
      boards_to_html board_p1 board_p2 diff "place1()"
(* Web POST request handler for route "/game" *)
let hdlr_game_post request =
  match Dream.header request "HX-Request" with
  | Some "true" ->
    (* HTMX POST request, continue game *)
    let%lwt post_form = Dream.form ~csrf:false request in
    let post_params_find = match post_form with `Ok ps -> ps | _ -> [] in
    let post_get_param param_name =
      List.Assoc.find post_params_find param_name ~equal:String.equal
      |> Option.first_some (Dream.query request param_name)
    in
    let params =
      post_get_param "game_state" >>= fun game_state ->
      post_get_param "board_state_p1" >>= fun board_state_p1 ->
      post_get_param "board_state_p2" >>= fun board_state_p2 ->
      post_get_param "side" >>= fun side ->
      post_get_param "x" >>= fun x_str ->
      post_get_param "y" >>= fun y_str ->
      post_get_param "game_diff" >>= fun diff ->
      Some (game_state, board_state_p1, board_state_p2, side, x_str, y_str, diff)
    in
    (match params with
    | Some (game_state, board_state_p1, board_state_p2, side, x_str, y_str, diff) ->
      (try
        let x = Int.of_string x_str in
        let y = Int.of_string y_str in
        let board_p1 = board_to_deserialized board_state_p1 in
        let board_p2 = board_to_deserialized board_state_p2 in
        let size = board_p1.board_size in
        match game_state with
        | "game" ->
          (match side with
          | "p2" ->
            (* State - Game, Side - P2: Run game logic *)
            Dream.html @@ run_game x y board_p1 board_p2 diff 
          | _ ->
            (* Parameter side invalid or P1 clicked *)
            Dream.html "<p>Error: Invalid side</p>"
          )
        | s when String.is_prefix s ~prefix:"place" ->
          (match side with
          | "p1" ->
            (* State - Placement, Side - P1: Run placement logic *)
            Dream.html @@ run_placement x y board_p1 diff game_state
          | "p2" ->
            (* State - Placement, Side - P2: Trigger auto placement *)
            let board_p1_new = auto_place_all_ships (make_empty_board size) in
            let board_p2_new = auto_place_all_ships (make_empty_board size) in
            let html_boards = boards_to_html board_p1_new board_p2_new diff "game" in
            Dream.html html_boards
          | _ ->
            (* Parameter side invalid *)
            Dream.html "<p>Error: Invalid side</p>"
          )
        | _ ->
          (* For end or invalid state, we should not get POST request *)
          Dream.html "<h1>Error: POST request but state invalid</h1>"
      with _ ->
        (* Exception from Int.of_string *)
        Dream.html "<p>Error: Invalid coordinates</p>"
      )
    | None ->
      (* For valid POST request by cell clicking, we should not miss any parameters *)
      Dream.html "<p>Error: POST request missing parameters</p>"
    )
  | _ ->
    (* For POST request, we should not get here *)
    Dream.html "<h1>Error: POST request but not HTMX</h1>"