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
%token TBarrier
%token TGate TLBrace TRBrace
%token TSColon
%token EOF

%start parse                  /* the entry point */
%type <Lang.exp list> parse

%%
parse:
  | gs = gen_stmt EOF                 { [gs] }
  | gs = gen_stmt m = parse           { gs :: m }

gen_stmt:
  | i = init TSColon                  { i }
  | gd = gate_def                     { gd }
  | stmt = statement                  { stmt }

init:
  | TInc s = TStr                     { EInc s }
  | TQreg r = reg                     { EQreg r }
  | TCreg r = reg                     { ECreg r }

gate_def:
  | TGate g_id = TVar r_id = TVar TLBrace stmt_lst = list(statement) TRBrace
    { EGate (g_id, r_id, stmt_lst) }

statement:
  | e = expr TSColon                  { e }
  | ce = c_expr TSColon               { ce }

c_expr:
  | TCnot e1 = expr TComma e2 = expr  { ECnot (e1, e2) }
  | TMeasr e1 = expr TArrow e2 = expr { EMeasr (e1, e2) }
  | TIf TLParen cr = reg TEqual i = TInt TRParen e = expr
    { EIf (cr, i, e) }
  | TBarrier reg_lst = separated_list(TComma, gen_reg)
    { EBarrier reg_lst }

expr:
  | gr = gen_reg                      { gr }
  | e = expr TPass TPauliX            { EPauliX e }
  | e = expr TPass TPauliY            { EPauliY e }
  | e = expr TPass TPauliZ            { EPauliZ e }
  | e = expr TPass THdm               { EHdm e }

gen_reg:
  | x = TVar                          { EGReg (x) }
  | r = reg                           { r }

reg:
  | x = TVar TLBrack i = TInt TRBrack { EReg (x, i) }