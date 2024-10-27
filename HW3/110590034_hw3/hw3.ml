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
    if fst ci = c then Cset.union (follow ci r) acc else acc
  ) q Cset.empty

let make_dfa (r : regexp) : autom =
  let r = Concat (r, Character eof) in
  let trans = ref Smap.empty in

  (* calculate state transition *)
  let rec transitions q =
    if not (Smap.mem q !trans) then begin
      let char_map = 
        Cset.fold (fun (ch, _) cmap ->
          let q' = next_state r q ch in
          if not (Cset.is_empty q') then Cmap.add ch q' cmap else cmap
        ) q Cmap.empty
      in
      trans := Smap.add q char_map !trans;
      Cmap.iter (fun _ q' -> transitions q') char_map
    end
  in

  let q0 = first r in
  transitions q0;
  { start = q0; trans = !trans }



(* Exercise 1 Test*)
let () =
  let a = Character ('a', 0) in
  assert (not (null a));
  assert (null (Star a));
  assert (null (Concat (Epsilon, Star Epsilon)));
  assert (null (Union (Epsilon, a)));
  assert (not (null (Concat (a, Star a))));
  print_endline "Exercise 1 passed."

(* Exercise 2 Test*)
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

(* Exercise 3 Test*)
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

(* Exercise 4 Test*)
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