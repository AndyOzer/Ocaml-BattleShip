let () =
  Dream.run
  ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.router [
    Dream.get "/"     Web_ui.hdlr_index;
    Dream.get "/game" Web_ui.hdlr_game_get;
    Dream.post "/game" Web_ui.hdlr_game_post;
  ]