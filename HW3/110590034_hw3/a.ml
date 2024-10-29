type buffer = { text: string; mutable current: int; mutable last: int }

let next_char b =
  if b.current = String.length b.text then raise End_of_file;
  let c = b.text.[b.current] in
  b.current <- b.current + 1;
  c

let rec state0 b =
  match next_char b with
  | _ -> failwith "lexical error"  (* actually not come this line , i don't know why need state0 *)

and state1 b =
  b.last <- b.current;
  failwith "found token"

and state2 b =
  match next_char b with
  | 'a' -> state2 b
  | 'b' -> state1 b
  | _ -> failwith "lexical error"

let start b = state2 b
