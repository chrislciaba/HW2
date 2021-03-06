type ('nonterminal, 'terminal) symbol =
| N of 'nonterminal
| T of 'terminal

let rec return_list list x = match list with
| [] -> []
| h::t -> match h with
  | (lhs, rhs) -> if x = lhs then 
    ([rhs]@(return_list t x)) else (return_list t x)

let convert_grammar gram1 = match gram1 with
| (lhs, rhs) -> (lhs, (fun x -> return_list rhs x))

(* process_rule: this function works by going through all of
the items at the current level, i.e. the array containing the
rule that we are examining *)
let rec process_rule rule_func cur_rule acc_func der frag =

(* if the current rule is empty, then we are out of options
and need to see if the acceptor will accept this derivation *)

 if cur_rule = [] then acc_func der frag else match frag with

(* if the fragment contains nothing, then we will not be able
to find a matching derivation. *)

  | [] -> None
  | h::t -> match cur_rule with

(* if the rule is nonterminal, then we need to go down a level
in the tree in order to try to find a matching terminal symbol.
The most important part of this process is updating the acceptor
function. We need to make sure that we run the process_rule function
for all of the symbols in the list, not just the first one, hence an
acceptor that processes the tail of the list after we reach an
acceptable derivation for the head of the list and this will also
return a list in the proper format since we process it from left to
right. If it's a terminal symbol and it's equal to the head of the
fragment, then process the rest of the rule on the current level.
Otherwise, this path doesn't work, so return None and the next function
will handle it. *)

    | (N a)::tl -> let v = (process_rule rule_func tl acc_func) in 
      try_rule a rule_func (rule_func a) v der frag
    | (T a)::tl -> if (a = h) then
      (process_rule rule_func tl acc_func der t) else None

(* try_rule: this function handles the list of rules that the
the grammar returns. If there are no rules in the list, we cannot
find a derivation, so return None. If there are rules in the list,
then try to see what happens if we use the current rule in the
derivation. If it works, return the derivation. If not, try
the current function with that rule removed so we can see if the
next one will work. *)

and try_rule cur rule_func cur_rule_list acc_func der frag = 
  match cur_rule_list with
  | [] -> None
  | h::t -> let v = (der@[(cur, h)]) in
    let u = (process_rule rule_func h acc_func v frag) in
    match u with
    | None -> (try_rule cur rule_func t acc_func der frag)
    | a -> a

let parse_prefix gram accept frag = match gram with
| (cur, rule_func) -> let v = (rule_func cur) in
  (try_rule cur rule_func v accept [] frag);;
