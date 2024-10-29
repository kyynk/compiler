open A

let tokenize text =
  let b = { text; current = 0; last = -1 } in
  let rec loop () =
    b.last <- -1;  (* Initial last, not found token *)
    try
      start b;
    with
    | End_of_file -> print_endline "End of file reached."
    | Failure msg -> 
      (* if b.last = -1 then
        raise (Failure "Lexical error: No token recognized")
      else  *)
      begin
        (* take and show token *)
        let token = String.sub b.text b.current (b.last - b.current) in
        print_endline ("--> \"" ^ token ^ "\"");
        (* update current *)
        print_endline msg;
        b.current <- b.last;
        loop ()
      end
  in
  loop ()
(* a*b *)
let () =
  let test_string = "aaaabab" in
  print_endline ("Analyzing: " ^ test_string);
  tokenize test_string
