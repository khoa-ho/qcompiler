{
open Parser
open Lexing
open Lang

let string_of_token (t:token) : string =
  match t with
  | TStr str -> str
  | TInt n   -> string_of_int n
  | TInc     -> "include"
  | TQreg    -> "qreg"
  | TCreg    -> "creg"
  | THdm     -> "h"
  | TPauliX  -> "x"
  | TPauliY  -> "y"
  | TPauliZ  -> "z"
  | TSqrtZC  -> "sdg"     
  | TSqrtZ   -> "s"
  | TSqrtSC  -> "tdg"
  | TSqrtS   -> "t"
  | TCnot    -> "cx"
  | TMeasr   -> "measure"
  | TPass    -> "|>"
  | TVar x   -> "$" ^ x
  | TLBrack  -> "["
  | TRBrack  -> "]"
  | TLParen  -> "("
  | TRParen  -> ")"
  | TLBrace  -> "{"
  | TRBrace  -> "}"
  | TIf      -> "if"
  | TEqual   -> "=="
  | TComma   -> ","
  | TArrow   -> "->"
  | TBarrier -> "barrier"
  | TGate    -> "gate"
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
  | '"'       { TStr (read_string (Buffer.create 17) lexbuf) }
  | "include" { TInc }
  | "qreg"    { TQreg }
  | "creg"    { TCreg }
  | 'h'       { THdm }
  | 'x'       { TPauliX }
  | 'y'       { TPauliY }
  | 'z'       { TPauliZ }
  | "sdg"     { TSqrtZC }     
  | 's'       { TSqrtZ }
  | "tdg"     { TSqrtSC }
  | 't'       { TSqrtS }
  | "cx"      { TCnot }
  | "measure" { TMeasr }
  | '>'       { TPass }
  | '['       { TLBrack }
  | ']'       { TRBrack }
  | '('       { TLParen }
  | ')'       { TRParen }
  | '{'       { TLBrace }
  | '}'       { TRBrace }
  | ','       { TComma }
  | "->"      { TArrow }
  | "if"      { TIf }
  | "=="      { TEqual }
  | "barrier" { TBarrier }
  | "gate"    { TGate }
  | ';'       { TSColon }
  | var       { TVar (lexeme lexbuf) }
  | white     { lex lexbuf }
  | newline   { next_line lexbuf; lex lexbuf }
  | _         { raise (SyntaxError (Printf.sprintf "Unexpected char '%s' %s" (lexeme lexbuf) (position lexbuf))) }
  | eof       { EOF }

and read_string buf =
  parse
  | '"'       { (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }
