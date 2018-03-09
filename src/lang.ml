open Printf

type exp =
  | EReg   of string * int
  | EQreg  of exp
  | ECreg  of exp
  | ENot   of exp
  | EHdm   of exp
  | ECnot  of exp * exp
  | EMeasr of exp * exp

let error err_msg =
  fprintf stderr "Error: %s\n" err_msg; exit 1

let rec string_of_exp (e:exp) : string =
  match e with
  | EReg (x, n)     -> sprintf "%s[%d]" x n
  | EQreg q         -> sprintf "qreg %s" (string_of_exp q)
  | ECreg c         -> sprintf "creg %s" (string_of_exp c)
  | ENot r          -> string_of_gate "x" r
  | EHdm r          -> string_of_gate "h" r
  | ECnot (r1, r2)  -> sprintf "cx %s, %s" (string_of_exp r1) (string_of_exp r2)
  | EMeasr (r1, r2) -> sprintf "measure %s -> %s" (string_of_exp r1) (string_of_exp r2)
and string_of_gate g r =
  sprintf "%s %s" g (string_of_exp r)

let string_of_statement (e:exp) : string =
  sprintf "%s;" (string_of_exp e)

let string_of_stmt_list (el:exp list) : string list =
  List.map string_of_statement el