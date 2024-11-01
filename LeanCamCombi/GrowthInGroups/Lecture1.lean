import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Combinatorics.Additive.DoublingConst
import Mathlib.GroupTheory.Nilpotent
import Mathlib.LinearAlgebra.Matrix.SpecialLinearGroup
import Mathlib.Tactic.Positivity.Finset

open Finset Fintype Group Matrix MulOpposite Real
open scoped Combinatorics.Additive MatrixGroups Pointwise

namespace GrowthInGroups.Lecture1
variable {G : Type*} [Group G] [DecidableEq G] {A X : Finset G} {n : ℕ} {K : ℝ}

lemma card_pow_lt_card_pow_succ_of_pow_ne_closure (hX : X.Nonempty)
    (hXclosure : (X ^ n : Set G) ≠ Subgroup.closure (X : Set G)) : #(X ^ n) < #(X ^ (n + 1)) := by
  refine (hX.card_pow_mono <| Order.le_succ _).lt_of_ne fun h ↦ hXclosure ?_
  dsimp at h
  sorry

lemma card_pow_strictMonoOn (hX : X.Nonempty) :
    StrictMonoOn (fun n ↦ #(X ^ n))
      {n | (X ^ (n - 1) : Set G) ≠ Subgroup.closure (X : Set G)} := by
  refine strictMonoOn_of_lt_add_one ⟨fun _ _ m hm n ⟨_, hmn⟩ hn ↦ hm ?_⟩ fun n _ hn hn' ↦
    card_pow_lt_card_pow_succ_of_pow_ne_closure hX hn'
  sorry

lemma card_pow_strictMono (hXclosure : (Subgroup.closure (X : Set G) : Set G).Infinite) :
    StrictMono fun n ↦ #(X ^ n) := by
  obtain rfl | hX := X.eq_empty_or_nonempty
  · simp at hXclosure
  have h n : (X ^ (n - 1) : Set G) ≠ Subgroup.closure (X : Set G) :=
    fun h ↦ by simp [← h, ← coe_pow] at hXclosure
  simpa [h] using card_pow_strictMonoOn hX

/-- The growth of a generating set in an infinite group is at least linear. -/
lemma fact_3_1_1 [Infinite G] (hXgen : Subgroup.closure (X : Set G) = ⊤) : n ≤ #(X ^ n) :=
  (card_pow_strictMono (by simp [hXgen, Set.infinite_univ])).le_apply

/-- The growth of a set is at most exponential. -/
lemma fact_3_1_2 : #(X ^ n) ≤ #X ^ n := card_pow_le

variable (G) in
/-- A group **has polynomial growth** if any (equivalently, all) of its finite symmetric sets
has polynomial growth. -/
def HasPolynomialGrowth : Prop :=
  ∃ X : Finset G, X⁻¹ = X ∧ Subgroup.closure (X : Set G) = ⊤ ∧ ∃ d, ∀ n ≥ 2, #(X ^ n) ≤ n ^ d

/-- Gromov. -/
lemma theorem_3_2 : HasPolynomialGrowth G ↔ IsVirtuallyNilpotent G := sorry

lemma fact_3_3 [Fintype G] (hn : X ^ n = univ) : log (card G) / log #X ≤ n := by
  obtain rfl | hX := X.eq_empty_or_nonempty
  · simp
  refine div_le_of_le_mul₀ (log_nonneg <| by simpa) (by positivity) ?_
  rw [← log_pow, ← Nat.cast_pow, ← card_univ, ← hn]
  gcongr
  exact card_pow_le

/-- **Babai's conjecture**. -/
lemma conjecture_3_4 :
    ∃ Cᵤ ≥ 0, ∃ dᵤ ≥ 0,
      ∀ {G} [Group G] [IsSimpleGroup G] [Fintype G] [DecidableEq G] (X : Finset G),
        ∃ m : ℕ, m ≤ Cᵤ * log (card G) ^ dᵤ ∧ X ^ m = univ := sorry

-- Not even trying to state the collar lemma

open scoped Classical in
lemma proposition_3_7 :
    ∃ ε > 0, ∀ X : Finset SL(2, ℝ), #(X ^ 2) ≤ 1000 * #X → (∀ M ∈ X, ∀ i j, |M i j| ≤ ε) →
      ∃ A : Subgroup SL(2, ℝ), A.IsCommutative ∧
        ∃ a : Fin 10000000 → SL(2, ℝ), (X : Set SL(2, ℝ)) ⊆ ⋃ i, a i • A := sorry

/-- The **Breuillard-Green-Tao theorem**. -/
lemma theorem_3_8 (hK : 0 ≤ K) :
    ∃ C > 0, ∀ {G} [Group G] [DecidableEq G] (A : Finset G) (hA : σₘ[A] ≤ K),
      ∃ (N : Subgroup G) (D : Subgroup N) (hD : D.Normal),
        upperCentralSeries (N⧸ D) C = ⊤ ∧ ((↑) '' (D : Set N) : Set G) ⊆ (A / A) ^ 4 ∧
          ∃ a : Fin C → G, (A : Set G) ⊆ ⋃ i, a i • N := sorry

open scoped Classical in
/-- Breuillard-Green-Tao, Pyber-Szabo. -/
lemma theorem_3_9 :
    ∃ δ > 0, ∃ ε > 0,
      ∀ k [Field k] [Fintype k] [DecidableEq k] (A : Finset SL(n, k))
        (hAgen : Subgroup.closure (A : Set SL(n, k)) = ⊤),
          #A ^ (1 + δ) ≤ #(A ^ 3) ∨ card SL(n, k) ^ (1 - ε) ≤ #A := sorry

lemma fact_3_10 (hA : σₘ[A] ≤ 1) :
    ∃ H : Subgroup G, ∀ a ∈ A, a • (H : Set G) = A ∧ op a • (H : Set G) = A := sorry

open scoped Classical in
lemma lemma_3_11 (hA : σₘ[A] < 3 / 2) :
    ∃ (H : Subgroup G) (_ : Fintype H),
      card H < 3 / 2 * #A ∧ ∀ a ∈ A, (A : Set G) ⊆ a • H ∧ a • (H : Set G) = op a • H := sorry

end GrowthInGroups.Lecture1
