# Claude Code Review Guide

> **Last updated:** YYYY-MM-DD | **Owner:** Your team
>
> This file is automatically injected into the Claude reviewer's prompt.
> Place it at `.github/claude-review-guide.md` and reference it via
> `review-guide-path: .github/claude-review-guide.md` in your workflow.

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

- Missing authorization checks on new endpoints
- Unvalidated user input (SQL injection, XSS, command injection)
- Secrets or credentials in code, error messages, or logs
- Missing tenant isolation (data leak between accounts/orgs)
- Hardcoded secrets (must come from environment or secret manager)

Flag these as **HIGH**:

- Overly permissive IAM/RBAC roles
- Missing rate limiting on public endpoints
- Sensitive data in debug/info logs
- Missing CSRF protection on state-changing endpoints

---

## Testing Expectations

- Missing tests for new functions/handlers → **BLOCKER**
- Missing tests for changes to existing logic → **HIGH**
- Coverage target: 80%+ for new code
- Verify test mocks match real function signatures
- Edge cases: empty arrays, null values, concurrent operations

---

## Error Handling

- All async operations must have error handling → **HIGH**
- User-facing error messages must be helpful, not technical → **MEDIUM**
- Don't swallow errors silently — log them at minimum → **HIGH**
- Distinguish between retryable and permanent failures → **MEDIUM**

---

<!-- ============================================================
     ADD YOUR DOMAIN-SPECIFIC SECTIONS BELOW
     ============================================================
     Examples of sections teams commonly add:

     ## API Design
     - REST conventions, naming, pagination patterns

     ## Database
     - Migration conventions, query patterns, indexing rules

     ## Architecture
     - Module boundaries, dependency rules, import conventions

     ## Deployment Readiness
     - Feature flags, config, monitoring, rollback plans

     ## Framework-Specific Patterns
     - React hooks rules, state management, component structure
     ============================================================ -->

## Code Style

<!-- Adjust to match your project's style guide -->

- Flag style violations only if 3+ instances in the same PR
- Prefer `const` over `let`
- `async/await` over raw promises
- Consistent naming: camelCase for variables, PascalCase for types
- Lines under 120 characters

---

## Package Manager

<!-- Pick one and enforce it -->
**Always use [yarn/npm/pnpm].** Flag the wrong package manager or lock file as a **BLOCKER**.
