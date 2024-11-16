
/* Parsing for mini-Turtle */

%{
  open Ast
  open Turtle
%}

/* Declaration of tokens */
%token DEF IF ELSE REPEAT
%token PENUP PENDOWN FORWARD TURNLEFT TURNRIGHT COLOR
%token COLOR_BLACK COLOR_WHITE COLOR_RED COLOR_GREEN COLOR_BLUE
%token <int> INT
%token <string> IDENT
%token PLUS MINUS TIMES DIV
%token LBRACE RBRACE LPAREN RPAREN COMMA
%token EOF
/* To be completed */

/* Priorities and associativity of tokens */
%left PLUS MINUS
%left TIMES DIV
%nonassoc IF
%nonassoc ELSE
%nonassoc UMINUS  (* Unary minus *)
/* To be completed */

/* Axiom of the grammar */
%start prog

/* Type of values ​​returned by the parser */
%type <Ast.program> prog

%%

/* Production rules of the grammar */

prog:
  def_list=list(def) stmt_list=list(stmt) EOF
    { { defs = def_list; main = Sblock stmt_list } }
;

def:
  | DEF n=IDENT LPAREN params=separated_list(COMMA, IDENT) RPAREN s=stmt
    { { name = n; formals = params; body = Sblock [s] } }
;

stmt:
  | PENUP                   { Spenup }
  | PENDOWN                 { Spendown }
  | FORWARD expr            { Sforward $2 }
  | TURNLEFT expr           { Sturn $2 }
  | TURNRIGHT expr          { Sturn (Ebinop (Sub, Econst 0, $2)) }
  | COLOR color             { Scolor $2 }
  | func=IDENT LPAREN expr_list=separated_list(COMMA, expr) RPAREN
    { Scall (func, expr_list) }
  | IF expr stmt            { Sif ($2, $3, Sblock []) }
  | IF expr stmt ELSE stmt  { Sif ($2, $3, $5) }
  | REPEAT expr stmt        { Srepeat ($2, $3) }
  | LBRACE stmt_list=list(stmt) RBRACE
    { Sblock stmt_list }
;

expr:
  | INT                      { Econst $1 }
  | IDENT                    { Evar $1 }
  | expr PLUS expr           { Ebinop (Add, $1, $3) }
  | expr MINUS expr          { Ebinop (Sub, $1, $3) }
  | expr TIMES expr          { Ebinop (Mul, $1, $3) }
  | expr DIV expr            { Ebinop (Div, $1, $3) }
  | MINUS expr %prec UMINUS  { Ebinop (Sub, Econst 0, $2) }
  | LPAREN expr RPAREN       { $2 }
;

color:
  | COLOR_BLACK  { Turtle.black }
  | COLOR_WHITE  { Turtle.white }
  | COLOR_RED    { Turtle.red }
  | COLOR_GREEN  { Turtle.green }
  | COLOR_BLUE   { Turtle.blue }
;
