import mathlib.logic
import mathlib.set
import measure_theory.measure.measure_space

open measure_theory set
open_locale ennreal

variables {α β : Type*} [measurable_space α] [measurable_space β] {μ : measure α} {f g : α → β}
  {s : set β}

namespace measure_theory
namespace measure

@[simp] lemma map_eq_zero_iff (hf : ae_measurable f μ) : μ.map f = 0 ↔ μ = 0 :=
begin
  refine ⟨λ h, _, _⟩,
  { replace h := congr_fun (congr_arg coe_fn h) set.univ,
    rwa [map_apply_of_ae_measurable hf measurable_set.univ, set.preimage_univ, coe_zero,
      pi.zero_apply, measure_univ_eq_zero] at h },
  { rintro rfl,
    exact measure.map_zero _ }
end

@[simp] lemma mapₗ_eq_zero_iff (hf : measurable f) : measure.mapₗ f μ = 0 ↔ μ = 0 :=
begin
  classical,
  rw [← map_eq_zero_iff hf.ae_measurable, map, dif_pos hf.ae_measurable,
    mapₗ_congr hf hf.ae_measurable.measurable_mk],
  exact hf.ae_measurable.ae_eq_mk,
end

lemma map_ne_zero_iff (hf : ae_measurable f μ) : μ.map f ≠ 0 ↔ μ ≠ 0 := (map_eq_zero_iff hf).not
lemma mapₗ_ne_zero_iff (hf : measurable f) : measure.mapₗ f μ ≠ 0 ↔ μ ≠ 0 :=
(mapₗ_eq_zero_iff hf).not

end measure

instance : measurable_space Prop := ⊤
instance : measurable_singleton_class Prop := ⟨λ _, trivial⟩
instance {α} : measurable_space (set α) := ⊤
instance {α} : measurable_singleton_class (set α) := ⟨λ _, trivial⟩

instance is_probability_measure_ne_zero {α : Type*} [measurable_space α] {μ : measure α}
  [is_probability_measure μ] : ne_zero μ :=
⟨is_probability_measure.ne_zero μ⟩

end measure_theory

-- Unused
@[simp] lemma set.preimage_symm_diff (f : α → β) (s t : set β) :
  f ⁻¹' (s ∆ t) = (f ⁻¹' s) ∆ (f ⁻¹' t) :=
by simp [symm_diff]

lemma ae_measurable.null_measurable_set_preimage (hf : ae_measurable f μ) (hs : measurable_set s) :
  null_measurable_set (f ⁻¹' s) μ :=
⟨hf.mk _ ⁻¹' s, hf.measurable_mk hs, hf.ae_eq_mk.preimage _⟩

namespace measure_theory

-- change `measure_compl` to `measurable_set.compl` in the `measure_theory` namespace
lemma null_measurable_set.measure_compl {s : set α} (h : null_measurable_set s μ) (hs : μ s ≠ ∞) :
  μ sᶜ = μ set.univ - μ s :=
begin
  rw [← measure_congr h.to_measurable_ae_eq, ← measure_compl (measurable_set_to_measurable _ _)],
  { exact measure_congr h.to_measurable_ae_eq.symm.compl },
  { rwa measure_congr h.to_measurable_ae_eq },
end

lemma null_measurable_set.prob_compl_eq_one_sub [is_probability_measure μ]
  {s : set α} (h : null_measurable_set s μ) :
  μ sᶜ = 1 - μ s :=
by rw [h.measure_compl (measure_ne_top _ _), measure_univ]

end measure_theory

namespace measurable_space

/-- The sigma-algebra generated by a single set `s` is `{∅, s, sᶜ, univ}`. -/
@[simp] lemma generate_from_singleton (s : set α) :
  generate_from {s} = measurable_space.comap (∈ s) ⊤ :=
begin
  classical,
  refine le_antisymm (generate_from_le $ λ t ht, ⟨{true}, trivial, by simp [ht.symm]⟩) _,
  rintro _ ⟨u, -, rfl⟩,
  by_cases hu₁ : true ∈ u; by_cases hu₀ : false ∈ u,
  { rw [(_ : u = univ), preimage_univ],
    { exact measurable_set.univ },
    { rw [eq_univ_iff_forall, Prop.forall_iff],
      exact ⟨hu₁, hu₀⟩ } },
  { rw [(_ : u = {true}), preimage_mem_singleton_true],
    { exact generate_measurable.basic _ (mem_singleton _) },
    { simp [eq_singleton_iff_unique_mem, Prop.forall_iff, hu₁, hu₀] } },
  { rw [(_ : u = {false}), preimage_mem_singleton_false],
    { exact generate_measurable.compl _ (generate_measurable.basic _ $ mem_singleton _) },
    { simp [eq_singleton_iff_unique_mem, Prop.forall_iff, hu₁, hu₀] } },
  { rw [(_ : u = ∅), preimage_empty],
    { exact @measurable_set.empty _ (generate_from _) },
    { simp [eq_empty_iff_forall_not_mem, Prop.forall_iff, hu₁, hu₀] } }
end

end measurable_space
