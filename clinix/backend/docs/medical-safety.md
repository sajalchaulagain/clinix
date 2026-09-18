# Medical-safety guardrails

CliniX provides HEALTH INFORMATION, NOT MEDICAL SERVICES. These guardrails are
coded in several layers and must not be weakened:

## AI assistants (Upachar Sathi / Baidyek Sathi)
* System prompts (`app/prompts/*`) forbid diagnoses, guaranteed cures, and
  individualized dosing — and require "consult a qualified healthcare
  professional" framing.
* Emergency + self-harm keyword screening (`services/safety_service.py`) runs
  BEFORE the model call and short-circuits it with deterministic escalation
  copy. Emergency numbers are configurable (`EMERGENCY_GUIDANCE_TEXT`) — the
  code hardcodes no phone numbers.

## Medicine analysis/identification
* Everything returned carries `is_ai_generated: true` so the app shows its
  AI-safety labeling.
* `dosage_information` is LABEL-level text only, never personalized dosing.
* Interaction info comes strictly from openFDA `drug_interactions` label text
  or AI interpretation labeled as such — the discontinued RxNav interaction
  endpoint is intentionally NOT used. Absence of a reported interaction is
  never presented as "no interaction".

## Mental-health screening
* Explicitly NON-DIAGNOSTIC: the result is a screening summary (`band`,
  suggestions, guidance). No disorder names appear in outputs
  (`test_mental_health.py::test_never_emits_diagnosis` guards this).
* Bands are computed deterministically from scores; elevated bands always
  carry professional-help guidance.

## Blood / donors
* Platform-meditated contact only; donor numbers/phones are never stored or
  returned. Units invariants and request lifecycles enforced server-side.
