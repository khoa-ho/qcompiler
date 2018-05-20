%{
  open Lang
%}

%token TInc  
%token <int> TInt 
%token <string> TVar TStr
%token TLBrack TRBrack
%token TQreg TCreg
%token TNot THdm TCnot TMeasr
%token TPass TComma TArrow
%token TSColon
%token EOF

%nonassoc TComma TArrow
%right TPass

%start parse                  /* the entry point */
%type <Lang.exp list> parse

%%
parse:
  | stmt = statement EOF              { [stmt] }
  | stmt = statement m = parse        { stmt :: m }

statement:
  | e = expr TSColon                  { e }
  | i = init TSColon                  { i }

init:
  | TQreg e = expr                    { EQreg e }
  | TCreg e = expr                    { ECreg e }

expr:
  | TInc s = TStr                     { EInc s }
  | x = TVar TLBrack i = TInt TRBrack { EReg (x, i) }
  | e = expr TPass TNot               { ENot e }
  | e = expr TPass THdm               { EHdm e }
  | TCnot e1 = expr TComma e2 = expr  { ECnot (e1, e2) }
  | TMeasr e1 = expr TArrow e2 = expr { EMeasr (e1, e2) }