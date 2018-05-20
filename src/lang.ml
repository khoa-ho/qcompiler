open Printf

type exp =
  | EInc    of string
  | EReg    of string * int
  | EQreg   of exp
  | ECreg   of exp
  | EPauliX of exp
  | EPauliY of exp
  | EPauliZ of exp
  | EHdm    of exp
  | ECnot   of exp * exp
  | EMeasr  of exp * exp
  | EIf     of exp * int * exp

let error err_msg =
  fprintf stderr "Error: %s\n" err_msg; exit 1

let rec string_of_exp (e:exp) : string =
  match e with
  | EInc s           -> sprintf "include \"%s\"" s
  | EReg (x, n)      -> sprintf "%s[%d]" x n
  | EQreg q          -> sprintf "qreg %s" (string_of_exp q)
  | ECreg c          -> sprintf "creg %s" (string_of_exp c)
  | ECnot (r1, r2)   -> sprintf "cx %s, %s" (string_of_exp r1) (string_of_exp r2)
  | EMeasr (r1, r2)  -> sprintf "measure %s -> %s" (string_of_exp r1) (string_of_exp r2)
  | EIf (c, i, e') -> sprintf "if(%s==%s) %s" 
                        (string_of_exp c) (string_of_int i) (string_of_exp e')
  | _ -> 
    let app_lst, reg = find_gate_app_list e in
    app_lst 
    |> List.rev 
    |> String.concat ";\n"

and find_gate_app_list (e:exp) : string list * string =
  match e with
  | EReg (_, _) -> [], string_of_exp e
  | _ ->
    let gate, e' = string_of_gate e in
    let app_lst, reg = find_gate_app_list e' in
    (sprintf "%s %s" gate reg) :: app_lst, reg

and string_of_gate (e:exp) : string * exp =
  match e with
  | EPauliX e' -> "x", e'  
  | EPauliY e' -> "y", e'  
  | EPauliZ e' -> "z", e'  
  | EHdm e'    -> "h", e'
  | _          -> error "Expected a gate!"

let string_of_statement (e:exp) : string =
  sprintf "%s;" (string_of_exp e)

let string_of_stmt_list (el:exp list) : string list =
  List.map string_of_statement el
