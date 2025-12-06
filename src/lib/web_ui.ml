open Core
open Battleship_types

let serialize_board board =
  board 
  |> sexp_of_board 
  |> Sexp.to_string 
  |> String.to_list 
  |> List.map ~f:(fun c -> Printf.sprintf "%02x" (Char.to_int c)) 
  |> String.concat

let deserialize_board s =
  let len = String.length s in
  let res = Buffer.create (len / 2) in
  let rec loop i =
    if i >= len then ()
    else
      let hex = String.sub s ~pos:i ~len:2 in
      let char_code = int_of_string ("0x" ^ hex) in
      Buffer.add_char res (Char.of_int_exn char_code);
      loop (i + 2)
  in
  loop 0;
  Buffer.contents res |> Sexp.of_string |> board_of_sexp

let board2html ?(oob=false) ?(debug_msg="") (board : board) (side : string) : string =
  let serialized = serialize_board board in
  let size = board.board_size in
  let input_name = "board_state_" ^ side in
  let input_id = "board-state-" ^ side in
  let title = if String.equal side "player" then "Player Board" else "Enemy Board" in
  let grid_cells =
    List.map board.battleship_board ~f:(fun cell ->
      let x = cell.coordinate.x_coordinate in
      let y = cell.coordinate.y_coordinate in
      let color_class = match cell.cell_type with
        | Empty -> "bg-blue-300 hover:bg-blue-400"
        | ShipPart _ -> if String.equal side "player" then "bg-gray-600" else "bg-blue-300 hover:bg-blue-400"
        | Hit -> "bg-red-500"
        | Miss -> "bg-white"
      in
      Printf.sprintf
        "<div class=\"w-8 h-8 %s border border-blue-100 cursor-pointer\"
              hx-get=\"/game?side=%s&x=%d&y=%d\"
              hx-include=\"#board-state-player, #board-state-enemy\"
              hx-target=\"#board-%s\"
              hx-swap=\"outerHTML\"></div>"
        color_class side x y side
    )
    |> String.concat
  in
  let oob_attr = if oob then "hx-swap-oob=\"true\"" else "" in
  let debug_html = if String.is_empty debug_msg then "" else Printf.sprintf "<div class=\"text-xs text-red-500 mt-2\">%s</div>" debug_msg in
  Printf.sprintf
    "<div id=\"board-%s\" %s class=\"flex flex-col items-center p-4 bg-white rounded-xl shadow-lg\">
       <h2 class=\"text-xl font-bold mb-2\">%s</h2>
       <div class=\"grid gap-1 p-2 bg-blue-50 rounded\" style=\"grid-template-columns: repeat(%d, minmax(0, 1fr));\">
         <input type=\"hidden\" id=\"%s\" name=\"%s\" value=\"%s\">
         %s
       </div>
       %s
     </div>"
    side oob_attr title size input_id input_name serialized grid_cells debug_html

let hdlr_index _request =
  try
    Dream.html @@ In_channel.read_all "web/index.html"
  with _ ->
    Dream.html "<h1>Failed to read index.html</h1>"

let hdlr_game request =
  match Dream.header request "HX-Request" with
  | Some "true" ->
      let param_side = Dream.query request "side" in
      let state_player = Dream.query request "board_state_player" in
      let state_enemy = Dream.query request "board_state_enemy" in
      (match state_player, state_enemy, param_side with
      | Some p_str, Some e_str, Some side_clicked ->
          let player_board = deserialize_board p_str in
          let enemy_board = deserialize_board e_str in
          let x_opt = Dream.query request "x" |> Option.map ~f:Int.of_string in
          let y_opt = Dream.query request "y" |> Option.map ~f:Int.of_string in
          let (new_player_board, new_enemy_board, debug_msg) = 
            match x_opt, y_opt with
            | Some x, Some y ->
                let coord = { x_coordinate = x; y_coordinate = y } in
                if String.equal side_clicked "enemy" then
                  let (updated_enemy, msg) = Battleship_gameplay.fire_at_coordinate coord enemy_board in
                  (* TODO: AI turn to attack player *)
                  (player_board, updated_enemy, Printf.sprintf "Attacked (%d, %d): %s" x y msg)
                else
                  (player_board, enemy_board, Printf.sprintf "Clicked own board at (%d, %d)" x y)
            | _ -> (player_board, enemy_board, "")
          in
          if String.equal side_clicked "player" then
             Dream.html ((board2html ~debug_msg new_player_board "player") ^ (board2html ~oob:true new_enemy_board "enemy"))
          else
             Dream.html ((board2html ~debug_msg new_enemy_board "enemy") ^ (board2html ~oob:true new_player_board "player"))
      | _ ->
          let side =
            match param_side with
            | Some side -> side
            | None -> "player"
          in
          match Dream.query request "size" with
          | Some size_str ->
              let size_int =
                try Some (Int.of_string size_str)
                with _ -> None
              in
              (match size_int with
              | None -> Dream.html "<h1>Size invalid</h1>"
              | Some s ->
                  let size = 
                    if s > 20 then 20
                    else if s < 10 then 10
                    else s
                  in
                  let board = Battleship_helper.make_empty_board size in
                  Dream.html (board2html board side))
          | None -> Dream.html "<h1>No size provided</h1>")
  | _ ->
      try
        Dream.html @@ In_channel.read_all "web/game.html"
      with _ ->
        Dream.html "<h1>Failed to read game.html</h1>"