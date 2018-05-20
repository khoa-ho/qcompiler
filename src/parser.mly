%{
  open Lang
%}

%token TInc  
%token <int> TInt 
%token <string> TVar TStr
%token TLBrack TRBrack
%token TQreg TCreg
%token TPauliX TPauliY TPauliZ
%token THdm 
%token TCnot 
%token TMeasr
%token TPass TComma TArrow
%token TLParen TRParen TIf TEqual
%token TSColon
%token EOF

%start parse                  /* the entry point */
%type <Lang.exp list> parse

%%
parse:
  | stmt = statement EOF              { [stmt] }
  | stmt = statement m = parse        { stmt :: m }

statement:
  | i = init TSColon                  { i }
  | e = expr TSColon                  { e }
  | ce = c_expr TSColon               { ce }

init:
  | TInc s = TStr                     { EInc s }
  | TQreg r = reg                     { EQreg r }
  | TCreg r = reg                     { ECreg r }

c_expr:
  | TCnot e1 = expr TComma e2 = expr  { ECnot (e1, e2) }
  | TMeasr e1 = expr TArrow e2 = expr { EMeasr (e1, e2) }
  | TIf TLParen cr = reg TEqual i = TInt TRParen e = expr
    { EIf (cr, i, e) }

expr:
  | r = reg                           { r }
  | e = expr TPass TPauliX            { EPauliX e }
  | e = expr TPass TPauliY            { EPauliY e }
  | e = expr TPass TPauliZ            { EPauliZ e }
  | e = expr TPass THdm               { EHdm e }

reg:
  | x = TVar TLBrack i = TInt TRBrack { EReg (x, i) }