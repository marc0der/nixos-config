---
name: start
description: Orientation for maintaining this NixOS config. Runs the read-only checks, reports what state the repo and host are actually in, then routes to the skill that fits. Use at the start of a maintenance session, when unsure which skill applies, or when the user asks what needs doing.
---

# Where to start

Read-only. This skill activates nothing and changes nothing. It gathers state,
says what that state means, and hands off to the skill that does the work.

Its value is that it answers a question the user cannot answer by looking: a
clean working tree does not mean there is nothing to apply, and a healthy host
does not mean the repo is in order. Those are separate questions with separate
commands.

## 1. Gather state

Three questions, three commands. Run all of them before saying anything, because
the recommendation depends on the combination, not on any one answer.

```bash
bin/nix-doctor                                # is the host healthy?
bin/nix-changed-layers --explain              # edited but not built
bin/nix-changed-layers --unapplied --explain  # committed but not live
```

Then, for work that exists but is unrecorded:

```bash
git status --porcelain
```

A modified `flake.lock` on its own means an upgrade was applied but never
committed, so the generation running has no record of which inputs produced it.

## 2. Report, briefly

Four lines at most, in this order. Lead with anything broken.

- **Health:** the `nix-doctor` summary line, and each `FAIL` named
- **To apply:** which layers are edited, or committed but not live, or neither
- **Inputs:** how stale, if any are
- **Uncommitted:** what is in the working tree

Do not paste the raw output of three commands. If everything is clean and
current, say exactly that in one line and go to step 3 anyway — the user asked
where to start, and "nothing needs doing" is a valid answer that still deserves
the menu.

## 3. Present the menu

Give the whole table every time, so the user can choose something other than
what you recommend:

| Skill | What it does | Reach for it when |
| --- | --- | --- |
| `/rebuild` | Infers which layers changed, builds and diffs, then switches system before home. Never touches `flake.lock`. | You edited a `.nix` file, or commits were never switched |
| `/upgrade` | Updates `flake.lock`, reports which inputs moved, builds both layers and shows an `nvd diff`, switches only on approval | You want newer packages |
| `/rollback` | Lists generations with dates and versions, activates an earlier one | A switch broke something |
| `/doctor` | Health check plus interpretation: untracked files, fmt drift, failed units, rollback availability, store usage, stale inputs | Something feels off, or before an upgrade |
| `/purge` | Previews then deletes old generations and collects the store, retaining the newest generation older than the active one per profile | `/nix` is filling up |
| `/host-parity` | Reports config duplicated across xenomorph and neomorph and proposes hoisting it | Checking drift between the two hosts |
| `/wallpaper` | Repoints the wallpaper, regenerates the pywal palette, reloads hyprpaper | Changing the desktop background |
| `/commit` | Atomic conventional commits | Work is tested and ready to record |

## 4. Recommend one, then hand off

Pick the single next action from the state you gathered, in this precedence:

1. **`nix-doctor` reported a problem** → `/doctor`. Fix the host before changing
   it. An untracked `.nix` file in particular means the next build would not
   reflect the file the user is editing (RULE-001).
2. **A layer is edited, or committed but not live** → `/rebuild`.
3. **Inputs are stale and nothing above applies** → `/upgrade`.
4. **Store is large and nothing above applies** → `/purge`.
5. **Everything clean and current** → say so, and offer `/host-parity` as the
   only remaining useful read-only check.

Then ask which the user wants and invoke it. Do not start the work yourself:
each of those skills has its own build-and-diff and approval gates, and
duplicating them here would bypass them.

## The one combination to refuse

**Never route to `/rebuild` and `/upgrade` in the same pass.** If the working
tree has config changes *and* the inputs are stale, apply the config change
first, let the user confirm it works, and only then upgrade. A switch that
carries both a config edit and an input bump has an unattributable failure mode:
when it breaks there is no way to tell which half broke it.

Say this out loud when it comes up, rather than silently picking one.

## Things this skill must not do

- Do not switch, build, or update anything. Every command it runs is read-only.
- Do not run `nix flake update`, which is `/upgrade`'s first step and rewrites
  `flake.lock`.
- Do not commit. Per RULE-106 nothing is confirmed working until the user says
  so, and `/commit` is how it gets recorded.
- Do not invoke `sudo`. `nix-doctor` is deliberately unprivileged; if a check
  needs root, hand the user the command with `! <command>`.
