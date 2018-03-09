let main () =
  Sys.argv.(1)
  |> open_in
  |> Lexing.from_channel
  |> Parser.parse Lexer.lex
  |> Lang.string_of_stmt_list
  |> (List.iter print_endline)

let _ = if !Sys.interactive then () else main ()