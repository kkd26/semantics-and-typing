# Language L1

## Syntax

- Booleans `b ∈ B = {true, false}`
- Integers `n ∈ Z = {…, -1, 0, 1, …}`
- Locations `l ∈ L = {l, l₁, l₂, …}`
- Operations `op ::= + | ≥`
- Expressions `e ::= n | b | e₁ op e₂ | if e₁ then e₂ else e₃ | l:=e | !l | skip | e₁;e₂ | while e₁ do e₂`

## Operational Semantics

Stores `s` are partial functions from `L` to `Z`

Values `v` are expressions from the grammar `v ::= b|n|skip`

```text
(op+)       ⟨n₁+n₂,s⟩ → ⟨n,s⟩     if n=n₁+n₂

(op≥)       ⟨n₁≥n₂,s⟩ → ⟨b,s⟩     if b=(n₁≥n₂)

                  ⟨e₁,s⟩ → ⟨e₁',s'⟩
(op1)       ————————————————————————————
            ⟨e₁ op e₂,s⟩ → ⟨e₁' op e₂,s'⟩

                 ⟨e₂,s⟩ → ⟨e₂',s'⟩
(op2)       ——————————————————————————
            ⟨v op e₂,s⟩ → ⟨v op e₂',s'⟩

(deref)     ⟨!l,s⟩ → ⟨n,s⟩      if l ∈ dom(s) and s(l)=n

(assign1)   ⟨l:=n,s⟩ → ⟨skip,s + {l ↦ n}⟩     if l ∈ dom(s)

               ⟨e,s⟩ → ⟨e',s'⟩
(assign2)   ————————————————————
            ⟨l:=e,s⟩ → ⟨l:=e',s'⟩

(seq1)      ⟨skip;e,s⟩ → ⟨e,s⟩

               ⟨e₁,s⟩ → ⟨e₁',s'⟩
(seq2)      —————————————————————
            ⟨e₁;e₂,s⟩ → ⟨e₁';e₂,s⟩

(if1)       ⟨if true then e₂ else e₃,s⟩ → ⟨e₂,s⟩

(if2)       ⟨if false then e₂ else e₃,s⟩ → ⟨e₃,s⟩

                               ⟨e₁,s⟩ → ⟨e₁',s'⟩
(if3)       ——————————————————————————————————————————————————————
            ⟨if e₁ then e₂ else e₃,s⟩ → ⟨if e₁' then e₂ else e₃,s'⟩

(while)     ⟨while e₁ do e₂,s⟩ → ⟨if e₂ then (e₂;while e₁ do e₂) else skip,s⟩
```
