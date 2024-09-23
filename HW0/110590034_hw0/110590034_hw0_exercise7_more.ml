(* 
type 'a seq =
  | Elt of 'a
  | Seq of 'a seq * 'a seq

let (@@) x y = Seq(x, y)

let rec seq_length = function
  | Elt _ -> 1
  | Seq (s1, s2) -> seq_length s1 + seq_length s2
 
(* 7-d *)
let rec nth s n = 
  let rec find_index_value idx = function
  | Elt x -> if idx = 0 then Some x else None
  | Seq (s1, s2) ->
    let len1 = seq_length s1 in
    if idx < len1 then find_index_value idx s1
    else find_index_value (idx - len1) s2
  in

  match find_index_value n s with
  | Some x -> x
  | None -> failwith "Index out of bounds"
 *)

(* 
How to enrich our sequence structure to potentially make the function nth more efficient?
*)
(* 
Answer:
We can add a field to the Seq constructor that stores the length of the sequence.
*)


(* 
Define the corresponding new type and redefine the functions (@@) and nth accordingly.
Are there any other functions that still need to be updated?
*)
(* 
Yes, we need to update the following functions:
  Efficiency updates: `nth` and `find_opt` benefit from the new length field,
  using it to improve performance when traversing or searching the sequence.

  Structure updates: All other functions ((@@), hd, tl, mem, rev, map,
  fold_left, fold_right) were updated to handle the enriched sequence structure
  properly by working with or ignoring the length field, but their functionality
  and performance are not significantly changed by the presence of the length.
*)
(* new type *)
type 'a seq =
  | Elt of 'a
  | Seq of int * 'a seq * 'a seq

let (@@) s1 s2 =
  let len1 = match s1 with
    | Elt _ -> 1
    | Seq (len, _, _) -> len
  in
  let len2 = match s2 with
    | Elt _ -> 1
    | Seq (len, _, _) -> len
  in
  Seq (len1 + len2, s1, s2)

(* 
By enriching the sequence structure with lengths, we can now implement the nth function more efficiently.
Original complexity: O(n)
New complexity: O(log n)
*)
(* 7-d *)
let rec nth s n =
  match s with
  | Elt x -> if n = 0 then x else failwith "Index out of bounds"
  | Seq (len, s1, s2) ->
      let len1 = match s1 with
        | Elt _ -> 1
        | Seq (l, _, _) -> l
      in
      if n < len1 then nth s1 n
      else nth s2 (n - len1)

(* seq_length *)
let rec seq_length = function
  | Elt _ -> 1
  | Seq (len, _, _) -> len

(* hd *)
let rec hd = function
  | Elt x -> x
  | Seq (_, s1, _) -> hd s1

(* tl *)
let rec tl = function
  | Elt _ -> failwith "No tail"
  | Seq (_, Elt _, s2) -> s2
  | Seq (_, s1, s2) ->
      let new_s1 = tl s1 in
      let len_s1 = match new_s1 with
        | Elt _ -> 1
        | Seq (len, _, _) -> len
      in
      Seq (len_s1 + seq_length s2, new_s1, s2)

(* mem *)
let rec mem x = function
  | Elt y -> x = y
  | Seq (_, s1, s2) -> mem x s1 || mem x s2

(* rev *)
let rec rev = function
  | Elt x -> Elt x
  | Seq (_, s1, s2) -> rev s2 @@ rev s1

(* map *)
let rec map f = function
  | Elt x -> Elt (f x)
  | Seq (len, s1, s2) -> Seq (len, map f s1, map f s2)

(* fold_left *)
let rec fold_left f acc = function
  | Elt x -> f acc x
  | Seq (_, s1, s2) -> fold_left f (fold_left f acc s1) s2

(* fold_right *)
let rec fold_right f seq acc =
  match seq with
  | Elt x -> f x acc
  | Seq (_, s1, s2) -> fold_right f s1 (fold_right f s2 acc)

(* seq2list_tail_recursive *)
let seq2list_tail_recursive seq =
  let rec aux s acc = match s with
    | Elt x -> x :: acc
    | Seq (_, s1, s2) -> aux s1 (aux s2 acc)
  in aux seq []
  
(* find_opt *)
let rec find_opt x seq =
  let rec aux idx = function
    | Elt y -> if x = y then Some idx else None
    | Seq (_, s1, s2) ->
        match aux idx s1 with
        | Some i -> Some i
        | None -> aux (idx + seq_length s1) s2
  in
  aux 0 seq



(* Test case *)
let rec int_list_to_string = function
  | [] -> ""
  | [x] -> string_of_int x
  | x :: xs -> string_of_int x ^ " " ^ int_list_to_string xs

let rec print_seq s =
  let rec seq_to_string = function
    | Elt x -> string_of_int x
    | Seq (_, s1, s2) -> seq_to_string s1 ^ " " ^ seq_to_string s2
  in
  print_endline (seq_to_string s)

let exercise_7_new_structure = 
  let seq = Elt 3 @@ (Elt 2 @@ Elt 1) @@ (Elt 9 @@ Elt 8 @@ Elt 7) in
  print_endline "seq:";
  print_seq seq;
  print_endline "nth seq 5:";
  print_endline (string_of_int (nth seq 5));  (* Expected: 7 *)
  try
    print_endline "nth seq 6:";
    print_endline (string_of_int (nth seq 6));  (* Expected: not run this line *)
  with
    Failure s -> print_endline s;  (* Expected: Index out of bounds *)
  print_endline "hd seq:";
  print_endline (string_of_int (hd seq));  (* Expected: 3 *)
  print_endline "tl seq:";
  print_seq (tl seq);  (* Expected: 2 1 9 8 7 *)
  print_endline "mem 3 seq:";
  print_endline (string_of_bool (mem 3 seq));  (* Expected: true *)
  print_endline "mem 4 seq:";
  print_endline (string_of_bool (mem 4 seq));  (* Expected: false *)
  print_endline "rev seq:";
  print_seq (rev seq);  (* Expected: 7 8 9 1 2 3 *)
  print_endline "map (fun x -> x * 2) seq:";
  print_seq (map (fun x -> x * 2) seq);  (* Expected: 6 4 2 18 16 14 *)
  print_endline "fold_left (+) 0 seq:";  (* (((((0 + 3) + 2) + 1) + 9) + 8) + 7 = 30 *)
  print_endline (string_of_int (fold_left (+) 0 seq));  (* Expected: 30 *)
  print_endline "fold_right (-) seq 0:";  (* 3 - (2 - (1 - (9 - (8 - (7 - 0))))) = -6 *)
  print_endline (string_of_int (fold_right (-) seq 0));  (* Expected: -6 *)
  print_endline "seq2list_tail_recursive seq:";
  print_endline (int_list_to_string (seq2list_tail_recursive seq));  (* Expected: 3 2 1 9 8 7 *)
  print_endline "find_opt 3 seq:";
  print_endline (match find_opt 3 seq with Some x -> string_of_int x | None -> "None");  (* Expected: 0 *)
  print_endline "find_opt 4 seq (None will be printed as None):";
  print_endline (match find_opt 4 seq with Some x -> string_of_int x | None -> "None");  (* Expected: None *)
;;

let () =
  exercise_7_new_structure;