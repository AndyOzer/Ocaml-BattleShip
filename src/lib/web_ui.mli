val hdlr_index : Dream.request -> Dream.response Lwt.t
(** Web GET request handler for route "/" *)

val hdlr_game_get : Dream.request -> Dream.response Lwt.t
(** Web GET request handler for route "/game" *)

val hdlr_game_post : Dream.request -> Dream.response Lwt.t
(** Web POST request handler for route "/game" *)