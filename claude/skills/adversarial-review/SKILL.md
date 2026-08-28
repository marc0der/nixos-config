---
name: adversarial-review
description: Adversarially review a specification for defects, then walk the user through resolving them one by one and commit the amended spec. Use when the user wants a spec stress-tested, red-teamed, or hardened before implementation.
allowed-tools: Read, Grep, Glob, Edit, Bash, Agent, Task, AskUserQuestion, Skill
---

You run a hostile review of one specification document, then drive the user through fixing what it found.

The spec path is given as an argument. If no path was given, or the path does not resolve to a file, ask for it with AskUserQuestion before doing anything else.

Never review the spec yourself in your own context. The review is always delegated, so that it is uncoloured by whatever this conversation has already concluded about the design.

## Process

### 1. Frame the review

Read the spec once, only far enough to know its subject and to collect the context the reviewer will need: the repo root, the spec's sibling specs, the governing `CLAUDE.md`, and any submodule the spec is about. Do not form opinions about the spec's quality. That is the reviewer's job.

### 2. Dispatch the reviewer

Spawn exactly one subagent with the `Agent` tool:

- `subagent_type: "general-purpose"` (a fresh context: it must not inherit this conversation)
- `model: "fable"`
- `description: "adversarial spec review"`

Give it the prompt below verbatim, substituting the bracketed values. Do not add to it, soften it, or hint at conclusions you have already drawn: uniformity across runs depends on this prompt being stable.

<reviewer-prompt>
You are a hostile reviewer of the specification at [SPEC PATH]. Your job is to find where it is wrong, unclear, incomplete, or unbuildable. You are not here to endorse it.

Read the spec in full. You have read-only access to the repository at [REPO ROOT]: grep and read the code, sibling specs under [SPEC DIR], and [CLAUDE.md PATH] to check whether the spec's claims about the system are actually true. Do not modify any file. Do not implement anything.

Hunt for defects in these categories, and label each defect with exactly one of them:

- `contradiction` - two parts of the spec cannot both hold
- `ambiguity` - a load-bearing statement admits two implementations
- `gap` - a case, failure mode, or decision the spec silently omits
- `drift` - the spec asserts something about the codebase that the code contradicts
- `unverifiable` - a claim asserted with no stated evidence or source of truth
- `untestable` - a requirement with no observable pass or fail condition
- `feasibility` - the described approach will not work, or not at the stated cost
- `dependency` - relies on something unowned, unscheduled, or out of scope
- `scope` - in scope and out of scope are drawn inconsistently

Grade each defect with exactly one severity:

- `Critical` - implementing to this spec produces a wrong, unsafe, or unshippable result, or the spec contradicts observable reality of the codebase
- `Major` - a load-bearing decision is missing or ambiguous, and getting it wrong forces rework
- `Minor` - a real imprecision or inconsistency with a narrow blast radius
- `Nit` - wording, naming, or formatting, with no behavioural consequence

Rules:

- Report only defects you can substantiate by pointing at specific spec text or specific code. No speculation, no "consider also".
- Every `drift` defect must cite the file and line that contradicts the spec.
- Do not report a defect the spec explicitly acknowledges as an accepted trade-off, unless the acknowledgement is itself wrong.
- Report at most 15 defects. If you found more, keep the 15 most severe and state the number you dropped.
- Order by severity (Critical, Major, Minor, Nit), then by document order within a severity.
- Number them AR-01, AR-02, ... in that final order.

Your final message must be the report and nothing else: no preamble, no summary of what the spec does well, no closing remarks. Emit exactly this markdown:

## Adversarial review: [SPEC PATH]

**Verdict:** <one sentence: is this spec safe to implement as written, yes or no, and why>
**Defects:** N (C Critical, M Major, m Minor, n Nit)<, X dropped over the cap - include this clause only if you dropped any>

### AR-01 | Critical | <title, at most 60 characters>
- **Category:** <one category from the list>
- **Location:** <heading, or line range>
- **Defect:** <one or two sentences on what is wrong>
- **Impact:** <what breaks downstream if this ships unresolved>
- **Resolution:** <the concrete spec edit that fixes it>
- **Status:** Open

<repeat the block for every defect>

If you find no defects at all, emit the heading, the verdict, `**Defects:** 0`, and nothing further.
</reviewer-prompt>

### 3. Present the register

Relay the reviewer's report to the user exactly as returned. Do not re-order it, re-grade it, edit its wording, or append your own opinion of the findings. It is the run's artefact and its shape must be identical from run to run.

If the reviewer returned no defects, say so and stop. Nothing to resolve, nothing to commit.

### 4. Resolve, one defect at a time

Walk the register in order, starting at AR-01. For each defect, ask exactly one AskUserQuestion, never batching two defects into one call. Head the question with the defect ID and put the defect's own wording in the question, so the user is deciding on the reviewer's claim rather than your paraphrase of it.

Offer these options, in this order:

1. **Apply the resolution** - the reviewer's suggested edit, quoted concretely in the description so the user sees what lands in the spec. Mark it `(Recommended)` when you judge the finding sound.
2. **<a named alternative>** - a genuinely different, concrete edit, when one exists. Describe the actual alternative, never a placeholder like "something else". Omit this option when there is no real second way to fix it.
3. **Defer** - the finding is real but out of scope for now. The spec is not touched.
4. **Reject** - the reviewer is wrong. The spec is not touched.

On the answer:

- *Apply* or *alternative*: edit the spec immediately, before moving to the next defect. Keep the edit surgical and in the spec's existing voice, formatting, and heading structure. Set the status to `Fixed`.
- *Defer*: set the status to `Deferred`. Do not edit the spec, and do not leave a TODO in it.
- *Reject*: set the status to `Rejected`. Do not edit the spec.
- *Other* (free text): treat it as the instruction, apply it, and set the status to `Fixed`.

Do not revisit a resolved defect, and do not re-run the reviewer against your own edits.

### 5. Close out

Print the final register: one line per defect, `AR-nn | Severity | title | Status`, in the original order. State the counts of Fixed, Deferred, and Rejected.

Then commit:

- If at least one defect was Fixed, invoke the `commit` skill to commit the spec.
- If nothing was Fixed, skip the commit and say so plainly.
- If the spec lives inside a git submodule, commit inside that submodule, then tell the user the parent repo's submodule pointer still needs committing. Do not commit the pointer yourself unless asked.
