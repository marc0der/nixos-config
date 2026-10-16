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
- `model: "opus"`
- `effort: "max"`
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

Write for a reader who has not read the spec and does not know the codebase:

- Use plain words and short sentences. When you use a term the spec coins, or the name of a component, say what it is the first time it appears in a defect.
- Every `Example` must be a concrete scenario with real-looking values: two developers who both follow the spec and build different things, or a specific input that leads to a specific wrong outcome. Never restate the defect in general terms.
- Quote the spec's own words wherever the defect turns on them.
- No filler, no hedging, no throat-clearing.

Your final message must be the report and nothing else: no preamble, no summary of what the spec does well, no closing remarks. Emit exactly this markdown:

## Adversarial review: [SPEC PATH]

**Verdict:** <one sentence: is this spec safe to implement as written, yes or no, and why>
**Defects:** N (C Critical, M Major, m Minor, n Nit)<, X dropped over the cap - include this clause only if you dropped any>

### AR-01 | Critical | <plain-language title, at most 60 characters>
- **Category:** <one category from the list>
- **Location:** <heading, or line range>
- **Background:** <one or two sentences: what this part of the spec is about and what it is trying to achieve, for someone who has not read it>
- **Defect:** <one or two sentences on what is wrong, quoting the spec text at fault>
- **Example:** <a concrete scenario that shows the defect causing a real difference or failure>
- **Impact:** <what breaks downstream if this ships unresolved>
- **Resolution:** <the concrete spec edit that fixes it: the current text and the text that replaces it>
- **Status:** Open

<repeat the block for every defect>

If you find no defects at all, emit the heading, the verdict, `**Defects:** 0`, and nothing further.
</reviewer-prompt>

### 3. Present the overview

Do not dump the full report. Show the reviewer's **Verdict** and **Defects** lines exactly as returned, then a table with one row per defect, in the reviewer's order:

| ID | Severity | Title |
|----|----------|-------|
| AR-01 | Critical | <reviewer's title> |

Do not re-order, re-grade, or re-title the defects, and do not add your own opinion of the findings. The full detail of each defect is shown when you reach it in step 4.

If the reviewer returned no defects, say so and stop. Nothing to resolve, nothing to commit.

### 4. Resolve, one defect at a time

Walk the register in order, starting at AR-01. Every defect gets the same two parts: a briefing printed in the chat, then exactly one AskUserQuestion call. Never batch two defects into one call.

The loop for each defect is: print briefing (4a), ask (4b), act on the answer (4c), then go back to 4a for the next defect. The briefing for AR-02 onwards is printed after the previous defect's edit, so it comes after a tool result. That is the point where it gets skipped, so check it there every time:

- An AskUserQuestion with header `AR-nn` must always come right after a text block that starts with `### AR-nn of N`, in the same message. If that text is not there, write the briefing first.
- Never go from an Edit result straight to the next AskUserQuestion. The briefing has to come between them.
- The overview from step 3 does not count as AR-01's briefing. Print AR-01's briefing as its own block, the same way as every later one.

#### 4a. Briefing

Print this, filled from the reviewer's fields, immediately before the question:

```
### AR-nn of N · <Severity> · <title>
<Location>

**What this part of the spec does**
<Background>

**The problem**
<Defect>

**Example**
<Example>

**Why it matters**
<Impact>

**Original text**
*<the current spec text at the location, verbatim>*
```

Use the reviewer's wording so the user decides on the reviewer's claim, not your paraphrase. You may add one short clarifying phrase where a field still assumes knowledge the user lacks, such as an undefined term or a reference to another section. Do not drop or soften anything.

The **Original text** is the exact text the fix would replace, read from the spec itself, in italics. Wrap each paragraph or list item in its own `*...*` so the italics hold across line breaks. When the defect is a gap and there is no text to replace, quote the text the fix would be inserted next to.

#### 4b. Question

Every AskUserQuestion call has the same shape:

- `header`: the defect ID, e.g. `AR-03`.
- `question`: the reviewer's severity, then one plain sentence that names the actual decision, e.g. "Major: How many times should the sync job retry before giving up?" The severity word is always the first word, exactly as the reviewer graded it (`Critical`, `Major`, `Minor` or `Nit`). Never "How do you want to resolve AR-03?"
- `options`, in this order:
  1. **Apply the fix**: the reviewer's resolution. The description says in one sentence what changes. Mark it `(Recommended)` when you judge the finding sound.
  2. **<a named alternative>**: a genuinely different, concrete edit, when one exists. The label names it (e.g. "Retry forever, back off"). Omit this option when there is no real second way to fix it.
  3. **Defer**: the problem is real but not for now. The spec is not touched.
  4. **Reject**: the reviewer is wrong. The spec is not touched.
- `preview` on every option, so the layout stays the same from question to question:
  - Apply and the alternative show only the proposed new text, exactly as it would be written. The original is already in the briefing, so do not repeat it.
  - Defer and Reject show `Spec unchanged.` and nothing else.

#### 4c. Act on the answer

- *Apply* or *alternative*: edit the spec immediately, before moving to the next defect. Keep the edit surgical and in the spec's existing voice, formatting, and heading structure, matching the preview you showed. Set the status to `Fixed`.
- *Defer*: set the status to `Deferred`. Do not edit the spec, and do not leave a TODO in it.
- *Reject*: set the status to `Rejected`. Do not edit the spec.
- *Other* (free text): treat it as the instruction, apply it, and set the status to `Fixed`.

Then return to 4a and print the next defect's briefing before anything else. Do not revisit a resolved defect, and do not re-run the reviewer against your own edits.

### 5. Close out

Commit first, so the report can say what was committed:

- If at least one defect was Fixed, invoke the `commit` skill to commit the spec.
- If nothing was Fixed, skip the commit.
- If the spec lives inside a git submodule, commit inside that submodule. Do not commit the parent repo's submodule pointer yourself unless asked.

Then print the final report using exactly this template, every time:

```
## Adversarial review summary: <spec path>

| ID | Severity | Title | Outcome | What changed in the spec |
|----|----------|-------|---------|--------------------------|
| AR-01 | Critical | <reviewer's title> | Fixed | <one plain line, e.g. "Retry limit set to 3 tries, 1s apart"> |
| AR-02 | Major | <reviewer's title> | Fixed (alternative) | <one plain line> |
| AR-03 | Minor | <reviewer's title> | Deferred | Nothing |
| AR-04 | Nit | <reviewer's title> | Rejected | Nothing |

**Totals:** N defects: F Fixed, D Deferred, R Rejected

**Deferred, still to do:**
- AR-03: <one sentence on the problem the spec still has>

**Commit:** <short hash and subject, or "None: nothing was fixed">
```

Rules for the report:

- One row per defect, in the original order, with the reviewer's titles.
- `Outcome` is exactly one of `Fixed`, `Fixed (alternative)`, `Fixed (your instruction)`, `Deferred`, `Rejected`.
- `What changed in the spec` says in plain words what the spec now says. Do not write "applied the resolution". Use `Nothing` for Deferred and Rejected.
- Leave out the **Deferred, still to do** section when nothing was deferred. It exists because a deferral leaves no trace in the spec.
- When the spec is in a submodule, add one line after **Commit:**: `**Parent repo:** submodule pointer still needs committing.`
