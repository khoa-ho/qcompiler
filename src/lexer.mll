{
open Parser
open Lexing
open Lang

let string_of_token (t:token) : string =
  match t with
  | TInt n   -> string_of_int n
  | TQreg    -> "qreg"
  | TCreg    -> "creg"
  | THdm     -> "h"
  | TNot     -> "x"
  | TCnot    -> "cx"
  | TMeasr   -> "measure"
  | TPass    -> "|>"
  | TVar x   -> "$" ^ x
  | TLBrack  -> "["
  | TRBrack  -> "]"
  | TComma   -> ","
  | TArrow   -> "->"
  | TSColon  -> ";"
  | EOF      -> "EOF"

let string_of_token_list (toks:token list) : string =
  let toks_str = String.concat ", " (List.rev (List.map string_of_token toks)) in
  "[" ^ toks_str ^ "]"

exception SyntaxError of string

let curr_file lexbuf fname =
  let pos = lexbuf.lex_start_p in
  lexbuf.lex_curr_p <-
    { pos with pos_fname = fname;
               pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum
    }

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }

let position lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.sprintf "in file '%s', line %d, character %d" 
  pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol)
}

let digit = ['0'-'9']
let int = digit+

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let blank = white | newline

let alpha = ['a'-'z' 'A'-'Z']
let var = alpha ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule lex = 
  parse
  | int       { TInt (int_of_string (lexeme lexbuf)) }
  | "qreg"    { TQreg }
  | "creg"    { TCreg }
  | "h"       { THdm }
  | "x"       { TNot }
  | "cx"      { TCnot }
  | "measure" { TMeasr }
  | "|>"      { TPass }
  | "["       { TLBrack }
  | "]"       { TRBrack }
  | ","       { TComma }
  | "->"      { TArrow }
  | ";"       { TSColon }
  | var       { TVar (lexeme lexbuf) }
  | white     { lex lexbuf }
  | newline   { next_line lexbuf; lex lexbuf }
  | _         { raise (SyntaxError (Printf.sprintf "Unexpected char '%s' %s" (lexeme lexbuf) (position lexbuf))) }
  | eof       { EOF }
