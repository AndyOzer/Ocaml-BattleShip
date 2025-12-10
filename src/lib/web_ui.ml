open Core
open Battleship_types
open Battleship_helper
open Battleship_placement
open Battleship_gameplay
open Battleship_ai
open Lwt.Infix

(* Serialization board and encode to BASE64 *)
let board_to_serialized (board : board) : string =
  board 
  |> sexp_of_board 
  |> Sexp.to_string 
  |> Dream.to_base64url

(* Decode BASE64 and deserialize board *)
let board_to_deserialized (s : string) : board =
  match Dream.from_base64url s with
  | Some decoded -> decoded |> Sexp.of_string |> board_of_sexp
  | None -> failwith "BASE64 decoding failed"

(* Render board into HTML cells *)
(* TODO Complete*)
let board_to_render_html (board : board) (side : string) (game_state : string) : string =
  match game_state with
  | "game" ->
    (match side with
    | "p1" ->
      List.map board.battleship_board ~f:(fun cell ->
        let html_class_color =
          match cell.cell_type with
          (* TODO Refine color*)
          | Empty -> "bg-blue-300"
          | ShipPart _ -> "bg-gray-600"
          | Hit -> "bg-red-500"
          | Miss -> "bg-white"
        in
        (* TODO Refine format*)
        Printf.sprintf "<div class=\"w-8 h-8 %s border border-blue-100\"></div>" html_class_color
        )
      |> String.concat
    | "p2" ->
      List.map board.battleship_board ~f:(fun cell ->
        let html_class_color =
          match cell.cell_type with
          (* TODO Refine color*)
          | Empty -> "bg-blue-300 hover:bg-blue-400"
          | ShipPart _ -> "bg-blue-300 hover:bg-blue-400"
          | Hit -> "bg-red-500"
          | Miss -> "bg-white"
        in
        Printf.sprintf
        (* TODO Refine format*)
          "<div
            class=\"w-8 h-8 %s border border-blue-100 cursor-pointer\"
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
    | _ -> ""
    )
  (* TODO *)
  | "place" -> ""
  | _ -> ""

(* Render P1 & P2 boards into HTML *)
(* TODO *)
let boards_to_html (board_p1 : board) (board_p2 : board) (game_state : string) ((game_diff : string)) : string =
  let html_cells_p1 = board_to_render_html board_p1 "p1" game_state in
  let html_cells_p2 = board_to_render_html board_p2 "p2" game_state in
  let html_title_p1 =
    match game_state with
    | "game" -> "Your Board"
    | "place" -> "Place Your Ships"
    | _ -> "Error"
  in
  let html_title_p2 = "Enemy Board" in
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

(* Web GET & POST request handler for route "/game" *)
let hdlr_game request =
  match Dream.header request "HX-Request" with
  | Some "true" ->
    (* HTMX request *)
    (match Dream.method_ request with
    | `POST ->
      (* HTMX POST request, continue game *)
      Dream.form ~csrf:false request >>= fun post_form_result ->
      let post_get_param name =
        match post_form_result with
        | `Ok params -> 
          (match List.Assoc.find params name ~equal:String.equal with
          | Some v -> Some v
          | None -> Dream.query request name)
        | _ -> Dream.query request name
      in
      let board_state_p1_req = post_get_param "board_state_p1" in
      let board_state_p2_req = post_get_param "board_state_p2" in
      let game_state_req = post_get_param "game_state" in
      let diff_req = post_get_param "game_diff" in
      let side_req = post_get_param "side" in
      let x_req = post_get_param "x" in
      let y_req = post_get_param "y" in
      (match game_state_req, board_state_p1_req, board_state_p2_req, side_req, x_req, y_req, diff_req with
      | Some game_state, Some board_state_p1, Some board_state_p2, Some side, Some x_str, Some y_str, Some diff ->
        (match side with
        | "p2" ->
          (try
            let x = Int.of_string x_str in
            let y = Int.of_string y_str in
            let board_p1 = board_to_deserialized board_state_p1 in
            let board_p2 = board_to_deserialized board_state_p2 in
            let coord = { x_coordinate = x; y_coordinate = y } in
            (* TOTOTODO *)
            let updated_enemy, enemy_msg = fire_at_coordinate coord board_p2 in
            let enemy_game_over = check_if_game_over updated_enemy in
            match enemy_game_over with
            | true ->
              let _state_msg = Printf.sprintf "You Win! 🎉 - %s" enemy_msg in
              let html = boards_to_html board_p1 updated_enemy "over" diff in
              Dream.html html
            | false ->
              let ai_coord = 
                match diff with
                | "ez" -> easy_next_fire_coordinate board_p1
                | "md" -> medium_next_fire_coordinate board_p1
                | "hd" | _ -> optimal_next_fire_coordinate board_p1
              in
              let updated_player, player_msg = fire_at_coordinate ai_coord board_p1 in
              let player_game_over = check_if_game_over updated_player in
              let _state_msg = 
                match player_game_over with
                | true -> "AI Wins! Game Over 😢"
                | false -> Printf.sprintf "Your attack: %s | AI fired at (%d,%d): %s" 
                  enemy_msg ai_coord.x_coordinate ai_coord.y_coordinate player_msg
              in
              let html = boards_to_html updated_player updated_enemy "game" diff in
              Dream.html html
          with _ -> Dream.html "<p>Error: Invalid coordinates</p>")
        | "p1" ->
          (match game_state with
          | "place" -> Dream.html "<p>TODO</p>"
          | _ -> Dream.html "<p>Error: P1 clicked</p>"
          )
        | _ -> Dream.html "<p>Error: Invalid side</p>"
        )
      | _ ->
        match diff_req with
        | Some _ ->
          Dream.html "<p>Error: Missing parameters except diff_req</p>"
        | _ ->
          Dream.html "<p>Error: Still missing parameters</p>"
      )
    | `GET ->
      (* HTMX GET request, start a new game *)
      let size_req = Dream.query request "size" in
      let diff_req = Dream.query request "diff" in
      let diff = Option.value diff_req ~default:"ez" in
      let size =
        (* TODO: Enhance size judge, add cheating code? *)
        match size_req with
        | Some s -> (try Int.of_string s with _ -> 10)
        | None -> 10
      in
      (* TODO: currently auto gen boards *)
      let board_p1 = auto_place_all_ships (make_empty_board size) in
      let board_p2 = auto_place_all_ships (make_empty_board size) in
      let html_boards = boards_to_html board_p1 board_p2 "game" diff in
      Dream.html html_boards
    | _ ->
      (* Invalid request method *)
      Dream.html "<p>Error: Invalid request method</p>"
    )
  | _ ->
    (* Regular request *)
    try
      Dream.html @@ In_channel.read_all "web/game.html"
    with _ ->
      Dream.html "<h1>Failed to load game.html</h1>"