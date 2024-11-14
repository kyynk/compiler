
(* Lexical analyser for mini-Turtle *)

{
  open Lexing
  open Parser

  (* raise exception to report a lexical error *)
  exception Lexing_error of string

  (* note : remember to call the Lexing.new_line function
at each carriage return ('\n' character) *)

}

rule token = parse
  (* spaces, tabs, and newlines are blanks *)
  | [' ' '\t' '\r']     { token lexbuf }
  | '\n'                { new_line lexbuf; token lexbuf }
  (* comment *)
  | "//" [^ '\n']* '\n' { token lexbuf } (* single-line comment *)
  | "(*"                { comment lexbuf } (* multi-line comment *)
  (* keywords *)
  | "def"               { DEF }
  | "if"                { IF }
  | "else"              { ELSE }
  | "repeat"            { REPEAT }
  | "penup"             { PENUP }
  | "pendown"           { PENDOWN }
  | "forward"           { FORWARD }
  | "turnleft"          { TURNLEFT }
  | "turnright"         { TURNRIGHT }
  | "color"             { COLOR }
  | "black"             { COLOR_BLACK }
  | "white"             { COLOR_WHITE }
  | "red"               { COLOR_RED }
  | "green"             { COLOR_GREEN }
  | "blue"              { COLOR_BLUE }
  (* identifier *)
  | ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as id { IDENT id }
  (* integer *)
  | '0' | ['1'-'9']['0'-'9']* as num   { INT (int_of_string num) }
  (* arithmetic operators *)
  | "+"                 { PLUS }
  | "-"                 { MINUS }
  | "*"                 { TIMES }
  | "/"                 { DIV }
  (* braces, parentheses, and comma *)
  | '{'                 { LBRACE }
  | '}'                 { RBRACE }
  | '('                 { LPAREN }
  | ')'                 { RPAREN }
  | ','                 { COMMA }
  (* eof *)
  | eof                 { EOF }
  (* other characters are illegal *)
  | _                   { raise (Lexing_error "illegal character") }

and comment = parse
  | "*)"                { token lexbuf } (* end of multi-line comment *)
  | _                   { comment lexbuf }
  | eof                 { raise (Lexing_error "unterminated comment") }
