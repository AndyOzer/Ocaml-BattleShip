(lang dune 3.16)
  (generate_opam_files true)
  (authors
    "Zhe Ou"
    "Ding Zhao"
  )
  (maintainers
    "zou6@jhu.edu"
    "dzhao29@jhu.edu"
  )
  (package
    (name Ocaml-Battleship)
    (allow_empty)
    (synopsis "A Battleship Game AI in OCaml")
    (description "A Battleship Game AI implemented in OCaml with Web UI")
    (depends
      ounit2
      core
      core_unix
      dream
    )
  )