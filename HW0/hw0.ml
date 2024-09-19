(* 1-a *)
let rec fact n =
  if n = 0 then 1
  else n * fact (n - 1)

(* 1-b *)
let rec nb_bit_pos n =
  if n = 0 then 0
  else (n mod 2) + nb_bit_pos (n / 2)

(* 2 *)
let fibo n =
  let rec aux a b n =
    if n = 0 then a
    else aux b (a + b) (n - 1)
  in
  aux 0 1 n

(* 3-a *)
let palindrome m =
  let rec reverse_string s i =
    if i < 0 then ""
    else String.make 1 s.[i] ^ reverse_string s (i - 1)
  in
  m = reverse_string m (String.length m - 1)

(* 3-b *)
let compare m1 m2 =
  String.compare m1 m2 < 0

(* 3-c *)
let factor m1 m2 =
  let len1 = String.length m1 in
  let len2 = String.length m2 in
  let rec aux i =
    if i + len1 > len2 then false
    else if String.sub m2 i len1 = m1 then true
    else aux (i + 1)
  in aux 0

(* 4-a *)
let rec split lst =
  let rec aux left right i = function
    | [] ->
      (List.rev left, List.rev right)
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

(* 5-a *)
let square_sum l = List.fold_left (fun acc x -> acc + x * x) 0 l

(* 5-b *)
let rec find_opt x l =
  let rec aux i = function
    | [] -> None
    | y::ys -> if x = y then Some i else aux (i + 1) ys
  in aux 0 l

(* 6 *)
let rev l =
  let rec aux acc = function
    | [] -> acc
    | x::xs -> aux (x::acc) xs
  in aux [] l

let map f l =
  let rec aux acc = function
    | [] -> rev acc
    | x::xs -> aux (f x :: acc) xs
  in aux [] l

(* 7-a *)


(* 7-b *)


(* 7-c *)


(* 7-d *)


(* Test cases *)
let () =
  print_endline "1-a";
  print_endline (string_of_int (fact 5));  (* Expected: 120 *)
  print_endline "1-b";
  print_endline (string_of_int (nb_bit_pos 5));  (* Expected: 2 *)
  print_endline "2";
  print_endline (string_of_int (fibo 5));  (* Expected: 5 *)
  print_endline "3-a";
  print_endline (string_of_bool (palindrome "madam"));  (* Expected: true *)
  print_endline (string_of_bool (palindrome "hello"));  (* Expected: false *)
  print_endline "3-b";
  print_endline (string_of_bool (compare "hello" "world"));  (* Expected: true *)
  print_endline (string_of_bool (compare "world" "hello"));  (* Expected: false *)
  print_endline "3-c";
  print_endline (string_of_bool (factor "world" "hello world"));  (* Expected: true *)
  print_endline (string_of_bool (factor "world" "hello"));  (* Expected: false *)
  print_endline "4-a";
  let (l1, l2) = split [1; 2; 3; 4; 5] in
  print_endline (String.concat " " (List.map string_of_int l1));  (* Expected: 1 3 5 *)
  print_endline (String.concat " " (List.map string_of_int l2));  (* Expected: 2 4 *)
  print_endline "4-b";
  let l = merge [1; 3; 5] [2; 4] in
  print_endline (String.concat " " (List.map string_of_int l));  (* Expected: 1 2 3 4 5 *)
  print_endline "4-c";
  let l = sort [3; 1; 5; 2; 4] in
  print_endline (String.concat " " (List.map string_of_int l));  (* Expected: 1 2 3 4 5 *)
  print_endline "5-a";
  print_endline (string_of_int (square_sum [1; 2; 3]));  (* Expected: 14 *)
  print_endline "5-b";
  print_endline (string_of_int (match find_opt 2 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: 1 *)
  print_endline (string_of_int (match find_opt 4 [1; 2; 3] with Some i -> i | None -> -1));  (* Expected: -1 *)
  print_endline "6";
  let l = map (fun x -> x * x) [1; 2; 3] in
  print_endline (String.concat " " (List.map string_of_int l));  (* Expected: 1 4 9 *)