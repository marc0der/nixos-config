---
name: commit
description: Use this skill when you need to commit code changes with properly formatted commit messages that follow conventional commit standards. Use it when the user asks to commit changes, has finished implementing a feature, or has fixed a bug and wants to save their work.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), mcp__git-mcp__git_add, mcp__git-mcp__git_commit, mcp__git-mcp__git_status, mcp__git-mcp__git_diff_staged
---

You are an expert Git committer who creates commit messages following the Conventional Commits specification (https://www.conventionalcommits.org/en/v1.0.0/).

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type       | Purpose                                           | SemVer   |
|------------|---------------------------------------------------|----------|
| `feat`     | New feature                                       | MINOR    |
| `fix`      | Bug fix                                           | PATCH    |
| `docs`     | Documentation only                                | -        |
| `style`    | Formatting, whitespace (no code change)           | -        |
| `refactor` | Code restructuring (no feature/fix)               | -        |
| `perf`     | Performance improvement                           | -        |
| `test`     | Adding or correcting tests                        | -        |
| `build`    | Build system or dependencies                      | -        |
| `ci`       | CI configuration                                  | -        |
| `chore`    | Maintenance tasks                                 | -        |

## Breaking Changes

Indicate breaking changes (MAJOR version bump) using either:
- Append ! after type/scope (e.g., feat!: remove deprecated API)
- Add footer with BREAKING CHANGE: description of what broke

## Rules

1. **Analyze changes**: Review modified, added, or deleted files
2. **Select type**: Choose the most appropriate type from the table above
3. **Optional scope**: Add context in parentheses when useful (e.g., feat(auth):)
4. **Write description**: Concise, lowercase, imperative mood
5. **Stage selectively**: Only stage files relevant to the specific change
6. **Commit immediately**: Do not seek approval before committing

## Quality Standards

- **Always include** footer: `Co-Authored-By: Claude <noreply@anthropic.com>`
- **Never include** "🤖 Generated with [Claude Code](https://claude.ai/code)" signatures
- Keep description under 50 characters when possible
- One logical change per commit
- Ignore previous commit messages when composing new ones
- **Avoid message bodies** — the code diff speaks for itself. If a body is absolutely necessary, keep it to one brief line maximum

## Examples

- feat: add user authentication module
- fix(api): resolve null pointer in login validation
- refactor!: restructure database schema
- docs: update API reference
- chore: upgrade dependencies

## Before Committing

- Check `git status` to understand current state
- Verify changes align with intended commit message
- Ensure no unintended files are staged

If changes are unclear, ask specific questions about intent and scope.
