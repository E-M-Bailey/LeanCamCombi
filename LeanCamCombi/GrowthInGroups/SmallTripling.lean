import Mathlib.Combinatorics.Additive.PluenneckeRuzsa
import Mathlib.Data.Fin.VecNotation
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Positivity.Finset
import Mathlib.Tactic.Ring

/-!
# Small tripling implies small powers
-/

open Fin
open List hiding tail
open scoped Pointwise

namespace Finset
variable {G : Type*} [DecidableEq G] [CommGroup G] {A : Finset G} {k K : ℝ} {m : ℕ}

-- TODO: Generalise to non-commutative groups
private lemma pluennecke_ruzsa (U V W : Finset G) : #U * #(V⁻¹ * W) ≤ #(U * V) * #(U * W) := by
  rw [mul_comm, inv_mul_eq_div, mul_comm _ W, mul_comm #(U * V)]
  exact ruzsa_triangle_inequality_div_mul_mul ..

private lemma inductive_claim (hm : 3 ≤ m)
    (h : ∀ ε : Fin 3 → ℤ, (∀ i, |ε i| = 1) → #((finRange 3).map fun i ↦ A ^ ε i).prod ≤ k * #A)
    (ε : Fin m → ℤ) (hε : ∀ i, |ε i| = 1) :
    #((finRange m).map fun i ↦ A ^ ε i).prod ≤ k ^ (m - 2) * #A := by
  induction' m, hm using Nat.le_induction with m hm ih
  · simpa using h ε hε
  obtain _ | m := m
  · simp at hm
  have hm₀ : m ≠ 0 := by simp at hm; positivity
  have hε₀ i : ε i ≠ 0 := fun h ↦ by simpa [h] using hε i
  obtain rfl | hA := A.eq_empty_or_nonempty
  · simp [hε₀]
  have hk : 0 ≤ k :=
    nonneg_of_mul_nonneg_left ((h 1 (by simp)).trans' (by positivity)) (by positivity)
  let π {n} (δ : Fin n → ℤ) : Finset G := ((finRange _).map fun i ↦ A ^ δ i).prod
  let V : Finset G := π ![-ε 1, -ε 0]
  let W : Finset G := π <| tail <| tail ε
  refine le_of_mul_le_mul_left ?_ (by positivity : (0 : ℝ) < #A)
  calc
    (#A * #(π ε) : ℝ)
      = #A * #(V⁻¹ * W) := by
      simp [π, V, W, List.finRange_succ_eq_map, Fin.tail, Function.comp_def, mul_assoc]
    _ ≤ #(A * V) * #(A * W) := by norm_cast; exact pluennecke_ruzsa ..
    _ = #(π ![1, -ε 1, -ε 0]) * #(π <| Fin.cons 1 <| tail <| tail ε) := by
      simp [π, V, W, List.finRange_succ_eq_map, Fin.tail, Function.comp_def]
    _ ≤ (k * #A) * (k ^ (m - 1) * #A) := by
      gcongr
      · exact h ![1, -ε 1, -ε 0] fun i ↦ by fin_cases i <;> simp [hε]
      · exact ih (Fin.cons 1 <| tail <| tail ε) <| Fin.cons (by simp) (by simp [hε, Fin.tail])
    _ = #A * (k ^ m * #A) := by rw [← pow_sub_one_mul hm₀]; ring

private lemma small_neg_pos_pos (hA : #(A ^ 3) ≤ K * #A) : #(A⁻¹ * A ^ 2) ≤ K ^ 2 * #A := by
  obtain rfl | hA₀ := A.eq_empty_or_nonempty
  · simp
  have : 0 ≤ K := nonneg_of_mul_nonneg_left (hA.trans' <| by positivity) (by positivity)
  refine le_of_mul_le_mul_left ?_ (by positivity : (0 : ℝ) < #A)
  calc
    (#A * #(A⁻¹ * A ^ 2) : ℝ) ≤ #(A * A) * #(A * A ^ 2) := by
      norm_cast; exact pluennecke_ruzsa A A (A ^ 2)
    _ = #(A ^ 2) * #(A ^ 3) := by simp [pow_succ']
    _ ≤ (K * #A) * (K * #A) := by
      gcongr
      calc
        (#(A ^ 2) : ℝ) ≤ #(A ^ 3) := mod_cast hA₀.card_pow_mono (by norm_num)
        _ ≤ K * #A := hA
    _ = #A * (K ^ 2 * #A) := by ring

private lemma small_neg_neg_pos (hA : #(A ^ 3) ≤ K * #A) : #(A⁻¹ ^ 2 * A) ≤ K ^ 2 * #A := by
  rw [← card_inv]
  simpa using small_neg_pos_pos (A := A) (K := K) (by simpa)

private lemma small_pos_neg_neg (hA : #(A ^ 3) ≤ K * #A) : #(A * A⁻¹ ^ 2) ≤ K ^ 2 * #A := by
  obtain rfl | hA₀ := A.eq_empty_or_nonempty
  · simp
  have : 0 ≤ K := nonneg_of_mul_nonneg_left (hA.trans' <| by positivity) (by positivity)
  refine le_of_mul_le_mul_left ?_ (by positivity : (0 : ℝ) < #A)
  calc
    (#A * #(A * A⁻¹ ^ 2) : ℝ) ≤ #(A * A) * #(A ^ 2 * A) := by
      norm_cast
      have := pluennecke_ruzsa A⁻¹ A⁻¹ (A⁻¹ ^ 2)
      simpa only [card_inv, inv_inv, inv_pow, ← mul_inv_rev] using this
    _ = #(A ^ 2) * #(A ^ 3) := by simp [pow_succ]
    _ ≤ (K * #A) * (K * #A) := by
      gcongr
      calc
        (#(A ^ 2) : ℝ) ≤ #(A ^ 3) := mod_cast hA₀.card_pow_mono (by norm_num)
        _ ≤ K * #A := hA
    _ = #A * (K ^ 2 * #A) := by ring

private lemma small_pos_pos_neg (hA : #(A ^ 3) ≤ K * #A) : #(A ^ 2 * A⁻¹) ≤ K ^ 2 * #A := by
  rw [← card_inv]
  simpa using small_pos_neg_neg (A := A) (K := K) (by simpa)

private lemma small_pos_neg_pos (hA : #(A ^ 3) ≤ K * #A) : #(A * A⁻¹ * A) ≤ K ^ 3 * #A := by
  obtain rfl | hA₀ := A.eq_empty_or_nonempty
  · simp
  have : 0 ≤ K := nonneg_of_mul_nonneg_left (hA.trans' <| by positivity) (by positivity)
  refine le_of_mul_le_mul_left ?_ (by positivity : (0 : ℝ) < #A)
  calc
    (#A * #(A * A⁻¹ * A) : ℝ) ≤ #(A * (A * A⁻¹)) * #(A * A) := by
      norm_cast; simpa using pluennecke_ruzsa A (A * A⁻¹) A
    _ = #(A ^ 2 * A⁻¹) * #(A ^ 2) := by simp [pow_succ, mul_assoc]
    _ ≤ (K ^ 2 * #A) * (K * #A) := by
      gcongr
      · exact small_pos_pos_neg hA
      calc
        (#(A ^ 2) : ℝ) ≤ #(A ^ 3) := mod_cast hA₀.card_pow_mono (by norm_num)
        _ ≤ K * #A := hA
    _ = #A * (K ^ 3 * #A) := by ring

private lemma small_neg_pos_neg (hA : #(A ^ 3) ≤ K * #A) : #(A⁻¹ * A * A⁻¹) ≤ K ^ 3 * #A := by
  rw [← card_inv]
  simpa [mul_assoc] using small_pos_neg_pos (A := A) (K := K) (by simpa)

/-- If `A` has small tripling, say with constant `K`, then `A` has small alternating powers, in the
sense that `|A^±1 * ... * A^±1|` is at most `|A|` times a constant exponential in the number of
terms in the product.

When `A` is symmetric (`A⁻¹ = A`), the base of the exponential can be lowered from `K ^ 3` to `K`,
where `K` is the tripling constant. See `Finset.small_pow_of_small_tripling`. -/
lemma small_alternating_pow_of_small_tripling (hm : 3 ≤ m) (hA : #(A ^ 3) ≤ K * #A) (ε : Fin m → ℤ)
    (hε : ∀ i, |ε i| = 1) :
    #((finRange m).map fun i ↦ A ^ ε i).prod ≤ K ^ (3 * (m - 2)) * #A := by
  have hm₀ : m ≠ 0 := by positivity
  have hε₀ i : ε i ≠ 0 := fun h ↦ by simpa [h] using hε i
  obtain rfl | hA₀ := A.eq_empty_or_nonempty
  · simp [hm₀, hε₀]
  have hK₁ : 1 ≤ K :=
    one_le_of_le_mul_right₀ (by positivity)
      (hA.trans' <| by norm_cast; exact card_le_card_pow (by norm_num))
  rw [pow_mul]
  refine inductive_claim hm (fun δ hδ ↦ ?_) ε hε
  simp only [finRange_succ_eq_map, Nat.reduceAdd, isValue, finRange_zero, map_nil, List.map_cons,
    succ_zero_eq_one, succ_one_eq_two, List.prod_cons, prod_nil, mul_one, ← mul_assoc]
  simp only [zero_le_one, abs_eq, Int.reduceNeg, forall_iff_succ, isValue, succ_zero_eq_one,
    succ_one_eq_two, IsEmpty.forall_iff, and_true] at hδ
  have aux₁₃ : K * #A ≤ K ^ 3 * #A :=
    calc
      _ = K ^ 1 * #A := by simp
      _ ≤ K ^ 3 * #A := by
        gcongr
        · exact hK₁
        · norm_num
  have aux₂₃ : K ^ 2 * #A ≤ K ^ 3 * #A := by
    gcongr
    · exact hK₁
    · norm_num
  obtain ⟨hδ₀ | hδ₀, hδ₁ | hδ₁, hδ₂ | hδ₂⟩ := hδ
  · calc
      _ = (#(A ^ 3) : ℝ) := by simp [*, pow_succ]
      _ ≤ K * #A := hA
      _ ≤ K ^ 3 * #A := aux₁₃
  · calc
      _ = (#(A ^ 2 * A⁻¹) : ℝ) := by simp [*, sq]
      _ ≤ K ^ 2 * #A := small_pos_pos_neg hA
      _ ≤ K ^ 3 * #A := aux₂₃
  · calc
      _ = (#(A * A⁻¹ * A) : ℝ) := by simp [*]
      _ ≤ K ^ 3 * #A := small_pos_neg_pos hA
  · calc
      _ = (#(A * A⁻¹ ^ 2) : ℝ) := by simp [*, sq, mul_assoc]
      _ ≤ K ^ 2 * #A := small_pos_neg_neg hA
      _ ≤ K ^ 3 * #A := aux₂₃
  · calc
      _ = (#(A⁻¹ * A ^ 2) : ℝ) := by simp [*, sq, mul_assoc]
      _ ≤ K ^ 2 * #A := small_neg_pos_pos hA
      _ ≤ K ^ 3 * #A := aux₂₃
  · calc
      _ = (#(A⁻¹ * A * A⁻¹) : ℝ) := by simp [*]
      _ ≤ K ^ 3 * #A := small_neg_pos_neg hA
  · calc
      _ = (#(A⁻¹ ^ 2 * A) : ℝ) := by simp [*, sq]
      _ ≤ K ^ 2 * #A := small_neg_neg_pos hA
      _ ≤ K ^ 3 * #A := aux₂₃
  · calc
      _ = (#(A ^ 3) : ℝ) := by simp [*, pow_succ', ← mul_inv_rev]
      _ ≤ K * #A := hA
      _ ≤ K ^ 3 * #A := aux₁₃

/-- If `A` is symmetric (`A⁻¹ = A`) and has small tripling, then `A` has small powers,
in the sense that `|A ^ m|` is at most `|A|` times a constant exponential in `m`.

See also `Finset.small_alternating_pow_of_small_tripling` for a version with a weaker constant but
which encompasses non-symmetric sets. -/
lemma small_pow_of_small_tripling (hm : 3 ≤ m) (hA : #(A ^ 3) ≤ K * #A) (hAsymm : A⁻¹ = A) :
    #(A ^ m) ≤ K ^ (m - 2) * #A := by
  have (ε : ℤ) (hε : |ε| = 1) : A ^ ε = A := by
    obtain rfl | rfl := eq_or_eq_neg_of_abs_eq hε <;> simp [hAsymm]
  calc
    (#(A ^ m) : ℝ) = #((finRange m).map fun i ↦ A ^ 1).prod := by simp
    _ ≤ K ^ (m - 2) * #A :=
      inductive_claim hm (fun δ hδ ↦ by simpa [this _ (hδ _), pow_succ'] using hA) _
        (by simp)
