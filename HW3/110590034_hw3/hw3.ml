type ichar = char * int

type regexp =
  | Epsilon
  | Character of ichar
  | Union of regexp * regexp
  | Concat of regexp * regexp
  | Star of regexp

(* Exercise 1 *)
let rec null (r : regexp) : bool =
  match r with
  | Epsilon -> true
  | Character _ -> false
  | Union (r1, r2) -> null r1 || null r2
  | Concat (r1, r2) -> null r1 && null r2
  | Star _ -> true

(* Exercise 2 *)
module Cset = Set.Make(struct 
  type t = ichar 
  let compare = Stdlib.compare 
end)

let rec first (r : regexp) : Cset.t =
  match r with
  | Epsilon -> Cset.empty
  | Character c -> Cset.singleton c
  | Union (r1, r2) -> Cset.union (first r1) (first r2)
  | Concat (r1, r2) -> 
      if null r1 then Cset.union (first r1) (first r2)
      else first r1
  | Star r -> first r

let rec last (r : regexp) : Cset.t =
  match r with
  | Epsilon -> Cset.empty
  | Character c -> Cset.singleton c
  | Union (r1, r2) -> Cset.union (last r1) (last r2)
  | Concat (r1, r2) -> 
      if null r2 then Cset.union (last r1) (last r2)
      else last r2
  | Star r -> last r

(* Exercise 3 *)
let rec follow (c : ichar) (r : regexp) : Cset.t =
  match r with
  | Epsilon -> Cset.empty
  | Character _ -> Cset.empty
  | Union (r1, r2) -> Cset.union (follow c r1) (follow c r2)
  | Concat (r1, r2) -> 
      let result =
        if Cset.mem c (last r1) then first r2
        else Cset.empty in Cset.union result (Cset.union (follow c r1) (follow c r2))
  | Star r1 ->
      let result = 
        if Cset.mem c (last r1) then first r1
        else Cset.empty in Cset.union result (follow c r1)

(* Exercise 4 *)
type state = Cset.t  (* a state is a set of characters *)

module Cmap = Map.Make(Char)  (* dictionary whose keys are characters *)
module Smap = Map.Make(Cset)  (* dictionary whose keys are states *)

type autom = {
  start : state;
  trans : state Cmap.t Smap.t  (* state dictionary -> (character dictionary -> state) *)
}

let eof = ('#', -1)

let next_state (r : regexp) (q : Cset.t) (c : char) : Cset.t =
  Cset.fold (fun ci acc ->
    if fst ci = c then Cset.union (follow ci r) acc
    else acc
  ) q Cset.empty

let make_dfa (r : regexp) : autom =
  let r = Concat (r, Character eof) in
  let trans = ref Smap.empty in
  let empty_state = Cset.empty in
  (* calculate state transition *)
  let rec transitions q =
    if not (Smap.mem q !trans) then begin
      let char_map = 
        Cset.fold (fun (ch, _) cmap ->
          let q' = next_state r q ch in
          if not (Cset.is_empty q') then Cmap.add ch q' cmap
          else Cmap.add ch empty_state cmap  (* When the state is empty, add an empty state *)
        ) q Cmap.empty
      in
      trans := Smap.add q char_map !trans;
      Cmap.iter (fun _ q' -> transitions q') char_map
    end
  in

  let q0 = first r in
  transitions q0;
  { start = q0; trans = !trans }

(* Exercise 5 *)
(* Check if a state is accepting by checking for the presence of eof ('#') *)
let is_accepting_state (state : Cset.t) : bool =
  Cset.exists (fun (ch, _) -> ch = '#') state

(* Recognize function to determine if a word is accepted by the DFA *)
let recognize (a : autom) (word : string) : bool =
  let rec aux current_state i =
    if i = String.length word then
      is_accepting_state current_state
    else
      let char = word.[i] in
      match Smap.find_opt current_state a.trans with
      | Some transitions -> (
          match Cmap.find_opt char transitions with
          | Some next_state -> aux next_state (i + 1)
          | None -> false
        )
      | None -> false
  in
  aux a.start 0

(* Exercise 6 *)
type buffer = { text: string; mutable current: int; mutable last: int }

let next_char b =
  if b.current = String.length b.text then raise End_of_file;
  let c = b.text.[b.current] in
  b.current <- b.current + 1;
  c

let generate (filename : string) (a : autom) : unit =
  (* Assign a unique number to each state *)
  let state_numbers = ref Smap.empty in
  let counter = ref 0 in
  let get_state_number state =
    match Smap.find_opt state !state_numbers with
    | Some n -> n
    | None ->
        let n = !counter in
        counter := n + 1;
        state_numbers := Smap.add state n !state_numbers;
        n
  in

  let oc = open_out filename in
  let fmt = Format.formatter_of_out_channel oc in

  (* Write the type buffer and next_char function at the top *)
  Format.fprintf fmt "type buffer = { text: string; mutable current: int; mutable last: int }@\n@\n";
  Format.fprintf fmt "let next_char b =@\n";
  Format.fprintf fmt "  if b.current = String.length b.text then raise End_of_file;@\n";
  Format.fprintf fmt "  let c = b.text.[b.current] in@\n";
  Format.fprintf fmt "  b.current <- b.current + 1;@\n";
  Format.fprintf fmt "  c@\n@\n";

  (* Write the state function for each state *)
  Smap.iter (fun state transitions ->
    let state_num = get_state_number state in
    if state_num == 0 then Format.fprintf fmt "let rec state%d b =@\n" state_num
    else Format.fprintf fmt "and state%d b =@\n" state_num;
    if is_accepting_state state then (
      Format.fprintf fmt "  b.last <- b.current;@\n";
      Format.fprintf fmt "  failwith \"found token\"@\n@\n";)
    else (
      Format.fprintf fmt "  match next_char b with@\n";
      Cmap.iter (fun c next_state ->
        Format.fprintf fmt "  | '%c' -> state%d b@\n" c (get_state_number next_state)
      ) transitions;
      Format.fprintf fmt "  | _ -> failwith \"lexical error\"";
      if state_num == 0 then Format.fprintf fmt "  (* actually not com this line , i don't know why need state0 *)@\n"
      else Format.fprintf fmt "@\n";
      Format.fprintf fmt "@\n"
    )
  ) a.trans;

  (* Define the start function to begin the lexical analysis *)
  Format.fprintf fmt "let start b = state%d b@\n" (get_state_number a.start);

  close_out oc;
  print_endline ("Generate file " ^ filename)


(* Exercise 1 Test *)
let () =
  let a = Character ('a', 0) in
  assert (not (null a));
  assert (null (Star a));
  assert (null (Concat (Epsilon, Star Epsilon)));
  assert (null (Union (Epsilon, a)));
  assert (not (null (Concat (a, Star a))));
  print_endline "Exercise 1 passed."

(* Exercise 2 Test *)
let () =
  let ca = ('a', 0) and cb = ('b', 0) in
  let a = Character ca and b = Character cb in
  let ab = Concat (a, b) in
  let eq = Cset.equal in
  assert (eq (first a) (Cset.singleton ca));
  assert (eq (first ab) (Cset.singleton ca));
  assert (eq (first (Star ab)) (Cset.singleton ca));
  assert (eq (last b) (Cset.singleton cb));
  assert (eq (last ab) (Cset.singleton cb));
  assert (Cset.cardinal (first (Union (a, b))) = 2);
  assert (Cset.cardinal (first (Concat (Star a, b))) = 2);
  assert (Cset.cardinal (last (Concat (a, Star b))) = 2);
  print_endline "Exercise 2 passed."

(* Exercise 3 Test *)
let () =
  let ca = ('a', 0) and cb = ('b', 0) in
  let a = Character ca and b = Character cb in
  let ab = Concat (a, b) in
  assert (Cset.equal (follow ca ab) (Cset.singleton cb));
  assert (Cset.is_empty (follow cb ab));
  let r = Star (Union (a, b)) in
  assert (Cset.cardinal (follow ca r) = 2);
  assert (Cset.cardinal (follow cb r) = 2);
  let r2 = Star (Concat (a, Star b)) in
  assert (Cset.cardinal (follow cb r2) = 2);
  let r3 = Concat (Star a, b) in
  assert (Cset.cardinal (follow ca r3) = 2);
  print_endline "Exercise 3 passed."

(* Exercise 4 Test *)
(* Visualization with the dot tool *)
let fprint_state fmt q =
  Cset.iter (fun (c, i) ->
    if c = '#' then Format.fprintf fmt "# " else Format.fprintf fmt "%c%i " c i) q

let fprint_transition fmt q c q' =
  Format.fprintf fmt "\"%a\" -> \"%a\" [label=\"%c\"];@\n"
    fprint_state q
    fprint_state q'
    c

let fprint_autom fmt a =
  Format.fprintf fmt "digraph A {@\n";
  Format.fprintf fmt " @[\"%a\" [ shape = \"rect\"];@\n" fprint_state a.start;
  Smap.iter
    (fun q t -> Cmap.iter (fun c q' -> fprint_transition fmt q c q') t)
    a.trans;
  Format.fprintf fmt "@]@\n}@."

let save_autom filename a =
  let ch = open_out filename in
  Format.fprintf (Format.formatter_of_out_channel ch) "%a" fprint_autom a;
  close_out ch
(* (a|b)*a(a|b) *)
let r = Concat (Star (Union (Character ('a', 1), Character ('b', 1))),
                Concat (Character ('a', 2),
                        Union (Character ('a', 3), Character ('b', 2))))
let a = make_dfa r
let () =
  save_autom "autom.dot" a;
  print_endline "Exercise 4."

(* Exercise 5 Test *)
(* positive tests *)
let () = assert (recognize a "aa")
let () = assert (recognize a "ab")
let () = assert (recognize a "abababaab")
let () = assert (recognize a "babababab")
let () = assert (recognize a (String.make 1000 'b' ^ "ab"))
(* negative tests *)
let () = assert (not (recognize a ""))
let () = assert (not (recognize a "a"))
let () = assert (not (recognize a "b"))
let () = assert (not (recognize a "ba"))
let () = assert (not (recognize a "aba"))
let () = assert (not (recognize a "abababaaba"))
(* test with a regular expression characterizing an even number of b’s *)
let r = Star (Union (Star (Character ('a', 1)),
                     Concat (Character ('b', 1),
                             Concat (Star (Character ('a',2)),
                                     Character ('b', 2)))))
let a = make_dfa r
let () = save_autom "autom2.dot" a
(* positive tests *)
let () = assert (recognize a "")
let () = assert (recognize a "bb")
let () = assert (recognize a "aaa")
let () = assert (recognize a "aaabbaaababaaa")
let () = assert (recognize a "bbbbbbbbbbbbbb")
let () = assert (recognize a "bbbbabbbbabbbabbb")
(* negative tests *)
let () = assert (not (recognize a "b"))
let () = assert (not (recognize a "ba"))
let () = assert (not (recognize a "ab"))
let () = assert (not (recognize a "aaabbaaaaabaaa"))
let () = assert (not (recognize a "bbbbbbbbbbbbb"))
let () = assert (not (recognize a "bbbbabbbbabbbabbbb"))
let () = print_endline "Exercise 5 passed."

(* Exercise 6 Test *)
let r3 = Concat (Star (Character ('a', 1)), Character ('b', 1))
let a = make_dfa r3
let () = save_autom "autom3.dot" a
let () = generate "a.ml" a
let () = print_endline "Exercise 6."
