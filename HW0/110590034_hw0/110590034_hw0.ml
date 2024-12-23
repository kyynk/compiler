(* 1-a *)
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)

(* 1-b *)
let rec nb_bit_pos n =
  if n = 0 then 0
  else (n mod 2) + nb_bit_pos (n / 2)
(* ------------------------------------------------------- *)
(* 2 *)
let fibo n =
  let rec aux a b n =
    if n = 0 then a
    else aux b (a + b) (n - 1)
  in
  aux 0 1 n
(* ------------------------------------------------------- *)
(* 3-a *)
(* let palindrome m =
  let rec reverse_string s i =
    if i < 0 then ""
    else String.make 1 s.[i] ^ reverse_string s (i - 1)
  in
  m = reverse_string m (String.length m - 1) *)

let rec string_length s =
  let rec aux i =
    try
      let _ = s.[i] in aux (i + 1)
    with _ -> i
  in aux 0

let palindrome m =
  let len = string_length m in
  let rec check i =
    if i >= len / 2 then true
    else if m.[i] <> m.[len - 1 - i] then false
    else check (i + 1)
  in check 0

(* 3-b *)
(* let compare m1 m2 =
  String.compare m1 m2 < 0 *)
let compare m1 m2 =
    let rec aux i =
      try
        let c1 = m1.[i] in
        let c2 = m2.[i] in
        if c1 < c2 then true
        else if c1 > c2 then false
        else aux (i + 1)
      with _ ->
        string_length m1 < string_length m2
    in
    aux 0

(* 3-c *)
let factor m1 m2 =
  let len1 = string_length m1 in
  let len2 = string_length m2 in
  let rec is_substr i j =
    if i = len1 then true
    else if j = len2 then false
    else if m1.[i] = m2.[j] then is_substr (i + 1) (j + 1)
    else false
  in

  let rec aux i =
    if i + len1 > len2 then false
    else if is_substr 0 i then true
    else aux (i + 1)
  in aux 0
(* ------------------------------------------------------- *)
(* 4-a *)
let rec split lst =
  let rec reverse_list lst acc = match lst with
    | [] -> acc
    | x::xs -> reverse_list xs (x::acc)
  in

  let rec aux left right i = function
    | [] ->
      (* (List.rev left, List.rev right) *)
      (reverse_list left [], reverse_list right [])
    | x::xs ->
      if i mod 2 = 0 then aux (x::left) right (i+1) xs
      else aux left (x::right) (i+1) xs
  in aux [] [] 0 lst

(* 4-b *)
let rec merge l1 l2 = match l1, l2 with
  | [], l | l, [] -> l
  | x1::xs1, x2::xs2 ->
    if x1 <= x2 then x1 :: merge xs1 l2
    else x2 :: merge l1 xs2

(* 4-c *)
let rec sort lst = match lst with
  | [] | [_] -> lst
  | _ ->
    let (l1, l2) = split lst in
    merge (sort l1) (sort l2)
(* ------------------------------------------------------- *)
(* 5-a *)
let rec square_sum_rec l = match l with
  | [] -> 0
  | x::xs -> x * x + square_sum_rec xs

let square_sum_lib l = List.fold_left (fun acc x -> acc + x * x) 0 l

(* 5-b *)
let rec find_opt_5_b_rec x l =
  let rec aux i = function
    | [] -> None
    | y::ys -> if x = y then Some i else aux (i + 1) ys
  in aux 0 l

let find_opt_5_b_lib x l =
  try
    let indexed_list = List.mapi (fun i y -> (i, y)) l in
    let (i, _) = List.find (fun (_, y) -> y = x) indexed_list in
    Some i
  with Not_found -> None
(* ------------------------------------------------------- *)
(* 6 *)
let rev_6 l =
  let rec aux acc = function
    | [] -> acc
    | x::xs -> aux (x::acc) xs
  in aux [] l

let map_6 f l =
  let rec aux acc = function
    | [] -> rev_6 acc
    | x::xs -> aux (f x :: acc) xs
  in aux [] l
(* ------------------------------------------------------- *)

type 'a seq =
  | Elt of 'a
  | Seq of 'a seq * 'a seq

let (@@) x y = Seq(x, y)

(* 7-a *)
(* hd *)
let rec hd = function
  | Elt x -> x
  | Seq (s1, _) -> hd s1

(* tl *)
let rec tl = function
  | Elt _ -> failwith "No tail"
  | Seq (Elt _, s2) -> s2
  | Seq (s1, s2) -> Seq (tl s1, s2)

(* mem *)
let rec mem x = function
  | Elt y -> x = y
  | Seq (s1, s2) -> mem x s1 || mem x s2

(* rev *)
let rec rev = function
  | Elt x -> Elt x
  | Seq (s1, s2) -> Seq (rev s2, rev s1)

(* map *)
let rec map f = function
  | Elt x -> Elt (f x)
  | Seq (s1, s2) -> Seq (map f s1, map f s2)

(* fold_left *)
let rec fold_left f acc = function
  | Elt x -> f acc x
  | Seq (s1, s2) -> fold_left f (fold_left f acc s1) s2

(* fold_right *)
let rec fold_right f seq acc =
  match seq with
  | Elt x -> f x acc
  | Seq (s1, s2) -> fold_right f s1 (fold_right f s2 acc)

(* 7-b *)
let rec seq2list seq =
  match seq with
  | Elt x -> [x]
  | Seq (s1, s2) ->
      let l1 = seq2list s1 in
      let l2 = seq2list s2 in
      let rec append lst1 lst2 =
        match lst1 with
        | [] -> lst2
        | x :: xs -> x :: append xs lst2
      in
      append l1 l2

let seq2list_tail_recursive seq =
  let rec aux seq acc = match seq with
    | Elt x -> x :: acc
    | Seq (s1, s2) -> aux s1 (aux s2 acc)
  in aux seq []

(* 7-c *)
let rec seq_length = function
  | Elt _ -> 1
  | Seq (s1, s2) -> seq_length s1 + seq_length s2

let rec find_opt x seq =
  let rec aux idx = function
    | Elt y -> if x = y then Some idx else None
    | Seq (s1, s2) ->
        match aux idx s1 with
        | Some i -> Some i
        | None -> aux (idx + seq_length s1) s2
  in
  aux 0 seq

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

(* ------------------------------------------------------- *)
(* Test cases *)
let rec int_list_to_string = function
  | [] -> ""
  | [x] -> string_of_int x
  | x :: xs -> string_of_int x ^ " " ^ int_list_to_string xs

let rec print_seq s =
  let rec seq_to_string = function
    | Elt x -> string_of_int x
    | Seq (s1, s2) -> seq_to_string s1 ^ " " ^ seq_to_string s2
  in
  print_endline (seq_to_string s)

let exercise_1 =
  print_endline "1-a";
  print_endline "fact 5:";
  print_endline (string_of_int (fact 5));  (* Expected: 120 *)
  print_endline "====================";
  print_endline "1-b";
  print_endline "nb_bit_pos 5:";
  print_endline (string_of_int (nb_bit_pos 5));  (* Expected: 2 *)
  print_endline "====================";
;;

let exercise_2 =
  print_endline "2";
  print_endline "fibo 5:";
  print_endline (string_of_int (fibo 5));  (* Expected: 5 *)
  print_endline "====================";
;;

let exercise_3 =
  print_endline "3-a";
  print_endline "palindrome \"madam\":";
  print_endline (string_of_bool (palindrome "madam"));  (* Expected: true *)
  print_endline "palindrome \"hello\":";
  print_endline (string_of_bool (palindrome "hello"));  (* Expected: false *)
  print_endline "====================";
  print_endline "3-b";
  print_endline "compare \"hello\" \"world\":";
  print_endline (string_of_bool (compare "hello" "world"));  (* Expected: true *)
  print_endline "compare \"world\" \"hello\":";
  print_endline (string_of_bool (compare "world" "hello"));  (* Expected: false *)
  print_endline "====================";
  print_endline "3-c";
  print_endline "factor \"world\" \"hello world\":";
  print_endline (string_of_bool (factor "world" "hello world"));  (* Expected: true *)
  print_endline "factor \"world\" \"hello\":";
  print_endline (string_of_bool (factor "world" "hello"));  (* Expected: false *)
  print_endline "====================";
;;

let exercise_4 =
  print_endline "4-a";
  print_endline "(l1, l2) = split [1; 2; 3; 4; 5]";
  let (l1, l2) = split [1; 2; 3; 4; 5] in
  print_endline "l1:";
  print_endline (int_list_to_string l1);  (* Expected: 1 3 5 *)
  print_endline "l2:";
  print_endline (int_list_to_string l2);  (* Expected: 2 4 *)
  print_endline "====================";
  print_endline "4-b";
  print_endline "merge [1; 3; 5] [2; 4]:";
  print_endline (int_list_to_string (merge [1; 3; 5] [2; 4]));  (* Expected: 1 2 3 4 5 *)
  print_endline "====================";
  print_endline "4-c";
  print_endline "sort [3; 1; 5; 2; 4]:";
  print_endline (int_list_to_string (sort [3; 1; 5; 2; 4]));  (* Expected: 1 2 3 4 5 *)
  print_endline "====================";
;;

let exercise_5 =
  print_endline "5-a";
  print_endline "square_sum_rec [1; 2; 3]:";
  print_endline (string_of_int (square_sum_rec [1; 2; 3]));  (* Expected: 14 *)
  print_endline "square_sum_lib [1; 2; 3]:";
  print_endline (string_of_int (square_sum_lib [1; 2; 3]));  (* Expected: 14 *)
  print_endline "====================";
  print_endline "5-b";
  print_endline "find_opt_5_b_rec 2 [1; 2; 3]:";
  print_endline (string_of_int (match find_opt_5_b_rec 2 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: 1 *)
  print_endline "find_opt_5_b_rec 4 [1; 2; 3] (None will be printed as -1):";
  print_endline (string_of_int (match find_opt_5_b_rec 4 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: -1 *)
  print_endline "find_opt_5_b_lib 2 [1; 2; 3]:";
  print_endline (string_of_int (match find_opt_5_b_lib 2 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: 1 *)
  print_endline "find_opt_5_b_lib 4 [1; 2; 3] (None will be printed as -1):";
  print_endline (string_of_int (match find_opt_5_b_lib 4 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: -1 *)
  print_endline "====================";
;;

let exercise_6 =
  print_endline "6";
  print_endline "rev_6 [1; 2; 3]:";
  print_endline (int_list_to_string (rev_6 [1; 2; 3]));  (* Expected: 3 2 1 *)
  print_endline "map_6 (fun x -> x * x) [1; 2; 3]:";
  print_endline (int_list_to_string (map_6 (fun x -> x * x) [1; 2; 3]));  (* Expected: 1 4 9 *)
  print_endline "====================";
;;

let exercise_7 =
  print_endline "7-a";
  let seq = Seq (Elt 1, Seq (Elt 2, Elt 3)) in
  print_endline "seq:";
  print_seq seq;
  print_endline "hd seq:";
  print_endline (string_of_int (hd seq));  (* Expected: 1 *)
  print_endline "tl seq:";
  print_seq (tl seq);  (* Expected: 2 3 *)
  print_endline "mem 2 seq:";
  print_endline (string_of_bool (mem 2 seq));  (* Expected: true *)
  print_endline "mem 4 seq:";
  print_endline (string_of_bool (mem 4 seq));  (* Expected: false *)
  print_endline "rev seq:";
  print_seq (rev seq);  (* Expected: 3 2 1 *)
  print_endline "map (fun x -> x * x) seq:";
  print_seq (map (fun x -> x * x) seq);  (* Expected: 1 4 9 *)
  print_endline "fold_left (+) 0 seq:";  (* ((0 + 1) + 2) + 3 = 6 *)
  print_endline (string_of_int (fold_left (+) 0 seq));  (* Expected: 6 *)
  print_endline "fold_right (+) seq 1:";  (* 1 + (2 + (3 + 1)) = 7 *)
  print_endline (string_of_int (fold_right (+) seq 1));  (* Expected: 7 *)
  print_endline "====================";
  print_endline "7-b";
  let seq = Seq (Elt 1, Seq (Elt 2, Elt 3)) in
  print_endline "seq:";
  print_seq seq;
  print_endline "seq2list seq:";
  let l = seq2list seq in
  print_endline (int_list_to_string l);  (* Expected: 1 2 3 *)
  print_endline "seq2list_tail_recursive seq:";
  let l = seq2list_tail_recursive seq in
  print_endline (int_list_to_string l);  (* Expected: 1 2 3 *)
  print_endline "====================";
  print_endline "7-c";
  let seq = Seq (Elt 1, Seq (Elt 2, Elt 3)) in
  print_endline "seq:";
  print_seq seq;
  print_endline "find_opt 1 seq:";
  print_endline (string_of_int (match find_opt 1 seq with Some x -> x | None -> -1));  (* Expected: 0 *)
  print_endline "find_opt 4 seq (None will be printed as -1):";
  print_endline (string_of_int (match find_opt 4 seq with Some x -> x | None -> -1));  (* Expected: -1 *)
  print_endline "====================";
  print_endline "7-d";
  let seq = Elt 1 @@ (Elt 2 @@ Elt 3) in
  print_endline "seq:";
  print_seq seq;
  print_endline "nth seq 0:";
  print_endline (string_of_int (nth seq 0));  (* Expected: 1 *)
  print_endline "nth seq 1:";
  print_endline (string_of_int (nth seq 1));  (* Expected: 2 *)
  print_endline "nth seq 2:";
  print_endline (string_of_int (nth seq 2));  (* Expected: 3 *)
  print_endline "nth seq 3 (Exception will be printed as Index out of bounds):";
  try
    let _ = nth seq 3 in
    print_endline "not run this line";
  with
    Failure s -> print_endline s;  (* Expected: Index out of bounds *)
;;

let () =
  exercise_1;
  exercise_2;
  exercise_3;
  exercise_4;
  exercise_5;
  exercise_6;
  exercise_7;
