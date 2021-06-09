(* Locations *)
type loc = string

(* Operations *)
type op = Plus | Gteq

(* Values *)
type v = N of int | B of bool | Skip

(* Expressions *)
type e =
  | V of v
  | Op of e * op * e
  | If of e * e * e
  | Assign of loc * e
  | Deref of loc
  | Seq of e * e
  | While of e * e

(* Evaluate operator *)
let eval_op op =
  match op with
  | Plus -> fun (N a, N b) -> V (N (a + b))
  | Gteq -> fun (N a, N b) -> V (B (a >= b))

type store = (loc * int) list

(* Store lookup function *)
let rec lookup (s : store) (l : loc) =
  match s with
  | [] -> None
  | (l', n') :: s' -> if l = l' then Some (N n') else lookup s' l

(* Update store function *)
let rec aux_update (s : store) (l, n) acc r : store option =
  match s with
  | [] -> if r then Some acc else None
  | (l', n') :: s' ->
      if l = l' then aux_update s' (l, n) ((l', n) :: acc) true
      else aux_update s' (l, n) ((l', n') :: acc) r

let update s (l, n) = aux_update s (l, n) [] false

(* One reduction step *)
let rec step (e, s) =
  match e with
  | V v -> None
  | Op (e1, op, e2) -> (
    match (e1, e2) with
    | V v1, V v2 -> Some ((eval_op op) (v1, v2), s)
    | V v, _ -> (
      match step (e2, s) with
      | Some (e', s') -> Some (Op (V v, op, e'), s')
      | None -> None )
    | _, _ -> (
      match step (e1, s) with
      | Some (e', s') -> Some (Op (e', op, e2), s')
      | None -> None ) )
  | If (e1, e2, e3) -> (
    match e1 with
    | V (B b) -> if b then Some (e2, s) else Some (e3, s)
    | _ -> (
      match step (e1, s) with
      | Some (e', s') -> Some (If (e', e2, e3), s')
      | None -> None ) )
  | Assign (loc, e) -> (
    match e with
    | V (N n) -> (
      match update s (loc, n) with
      | Some s' -> Some (V Skip, s')
      | None -> None )
    | _ -> (
      match step (e, s) with
      | Some (e', s') -> Some (Assign (loc, e'), s')
      | None -> None ) )
  | Deref loc -> (
    match lookup s loc with Some (N n) -> Some (V (N n), s) | _ -> None )
  | Seq (e1, e2) -> (
    match e1 with
    | V Skip -> Some (e2, s)
    | _ -> (
      match step (e1, s) with
      | Some (e', s') -> Some (Seq (e', e2), s')
      | None -> None ) )
  | While (e1, e2) -> Some (If (e1, Seq (e2, While (e1, e2)), V Skip), s)

(* Evaluate expression *)
let rec evaluate c =
  match step c with Some (e, s) -> evaluate (e, s) | None -> c
