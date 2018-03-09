%{
  open Lang
%}

%token <int> TInt 
%token <string> TVar
%token TLBrack TRBrack
%token TQreg TCreg
%token TNot THdm TCnot TMeasr
%token TComma TArrow
%token TSColon
%token EOF

%start parse                  /* the entry point */
%type <Lang.exp list> parse

%%
parse:
  | stmt = statement EOF              { [stmt] }
  | stmt = statement m = parse        { stmt :: m }

statement:
  | e = expr TSColon                  { e }

expr:
  | TQreg r = reg                     { EQreg r }
  | TCreg r = reg                     { ECreg r }
  | TNot r = reg                      { ENot r }
  | THdm r = reg                      { EHdm r }
  | TCnot r1 = reg TComma r2 = reg    { ECnot (r1, r2) }
  | TMeasr r1 = reg TArrow r2 = reg   { EMeasr (r1, r2) }

reg:
  | x = TVar TLBrack i = TInt TRBrack { EReg (x, i) }