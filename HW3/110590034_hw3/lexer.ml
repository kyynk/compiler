open A

let tokenize text =
  let rec find_token string cur_pos =
    if cur_pos >= String.length string then ()
    else (
      let b = { text; current = cur_pos; last = -1 } in
      b.last <- -1;
      try
        start b;
      with
      | End_of_file -> print_endline "exception End_of_file"
      | Failure msg -> 
          if msg = "found token" then
            let token = String.sub b.text cur_pos (b.last - cur_pos) in
            print_endline ("--> \"" ^ token ^ "\"");
            b.current <- b.last;
            find_token b.text b.current
          else
            print_endline ("exception Failure(\"" ^ msg ^ "\")");
    )
  in
  find_token text 0


let () =
  let text = "abbaaab" in
  print_endline ("string: " ^ text);
  tokenize text;
  print_endline ""

let () =
  let text = "aba" in
  print_endline ("string: " ^ text);
  tokenize text;
  print_endline ""

let () =
  let text = "aac" in
  print_endline ("string: " ^ text);
  tokenize text;
  print_endline ""
