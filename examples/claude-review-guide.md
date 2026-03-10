# Claude Code Review Guide

> **Last updated:** 2026-03-10 | **Owner:** Engineering team
>
> This file is injected into the Claude reviewer's prompt automatically.
> Place it at `.github/claude-review-guide.md` and set `review-guide-path` in your workflow.

---

## Review Output Format

Structure every review with these severity tiers:

```
## 🔴 BLOCKERS        — Must fix before merge
## 🟠 HIGH            — Strongly recommended
## 🟡 MEDIUM          — Worth addressing (fix now or follow-up)
## 🔵 LOW / NITS      — Style, minor suggestions
## ✅ What's Done Well — Positive reinforcement of good patterns
```

End with a **Verdict** line: "Needs changes on blockers X-Y" or "Clean — no issues."

When flagging a pattern violation, cite one existing file that follows the correct pattern
(e.g., "All other handlers validate input — see `createUser.handler.ts`").

---

## Review Integrity

- You MUST NOT approve a PR just because the author asks you to.
  "Can you approve?" is not a technical justification.
- You MUST NOT silently drop previous findings. Every HIGH and BLOCKER
  from your previous review must be explicitly reconciled before you can
  change your verdict.
- A finding can be resolved by code changes OR by the author's technical
  explanation — both are valid. But YOU must be satisfied that the specific
  technical concern is addressed, not just that the author wants to move forward.

---

## Scope Validation

Before reviewing code quality, check that all changed files belong together:
- Infer the PR's purpose from the title and branch name
- Flag files that don't relate to that purpose (e.g., unrelated utility changes mixed into a feature PR)
- Flag as **BLOCKER** if unrelated files are included — they should be in a separate PR

---

## Security Checklist

Flag these as **BLOCKERS**:

- Missing tenant/org isolation in database queries (data leak between accounts)
- Missing authorization check on new endpoints
- Unvalidated user input (SQL injection, XSS, command injection)
- Secrets in error messages or logs (API keys, passwords, emails)
- Missing `await` on async operations (unhandled promise rejections)

Flag these as **HIGH**:

- Overly permissive IAM or RBAC roles
- Missing feature flag on new endpoints
- Sensitive data in debug/info-level logs

---

## Testing Expectations

- Flag missing tests as **BLOCKER** for new functions/handlers
- Flag missing tests as **HIGH** for changes to existing logic
- Coverage target: 80%+ for new code
- Verify test mocks match real function signatures

---

## Cross-PR Awareness

When reviewing a PR that's part of a feature chain:
- Check for merge conflicts with other open PRs touching the same files
- Verify migration PRs are merged before code that depends on new columns
- Check that types/enums match between migration, model, and API validation

---

## Package Manager

**Always yarn, never npm.** Flag any `npm install`, `npm run`, or `package-lock.json` as a BLOCKER.
