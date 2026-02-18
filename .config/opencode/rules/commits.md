# Commit Standards and Practices

## 1. Commit Philosophy

- Each commit should represent a single logical change.
- Commits must be small, focused, and reviewable.
- A commit should compile and pass tests.
- Avoid mixing refactors, formatting, and feature work in the same commit.

---

## 2. Conventional Commits

All commits must follow the Conventional Commits specification:

```
<type>(optional scope): <description>

[optional body]

[optional footer(s)]
```

### Format Rules

- Use lowercase for `type`.
- Use present tense, imperative mood in the description (e.g., "add", "fix", "refactor").
- Do not end the description with a period.
- Keep the subject line under 72 characters.
- Separate subject and body with a blank line.

---

## 3. Allowed Types

### `feat`

A new feature.

Example:

```
feat(auth): add token refresh endpoint
```

### `fix`

A bug fix.

Example:

```
fix(api): handle null response from user service
```

### `refactor`

Code change that neither fixes a bug nor adds a feature.

Example:

```
refactor(order): extract price calculation into service
```

### `perf`

Performance improvement.

### `test`

Adding or updating tests.

### `docs`

Documentation only changes.

### `build`

Changes that affect the build system or external dependencies.

### `ci`

Changes to CI configuration files and scripts.

### `chore`

Maintenance tasks that do not modify src or test files.

---

## 4. Breaking Changes

Breaking changes must be clearly indicated.

### Option 1: Exclamation Mark

```
feat(api)!: change response format for user endpoint
```

### Option 2: Footer

```
feat(api): change response format

BREAKING CHANGE: user endpoint now returns paginated results
```

- Always describe what changed and how to migrate.

---

## 5. Scope Usage

- Use scope to clarify the area of impact.
- Scope should reflect domain or module (e.g., `auth`, `billing`, `api`, `ui`).
- Avoid overly granular scopes.
- Keep naming consistent across commits.

---

## 6. Commit Body Guidelines

- Explain why the change was made.
- Describe context and tradeoffs.
- Avoid restating what the code clearly shows.
- Reference relevant tickets or issue IDs when applicable.

Example:

```
fix(payment): prevent duplicate charge on retry

Retry logic did not account for idempotency keys,
causing duplicate transactions under network failure.
```

---

## 7. Footers

Use footers for:

- Breaking changes
- Issue references
- Co-authorship

Examples:

```
Closes #123
Refs #456
Co-authored-by: Jane Doe <jane@example.com>
```

---

## 8. Atomic Commits

- Do not bundle unrelated changes.
- Separate formatting-only changes.
- Separate dependency upgrades from feature work.
- Separate refactors from behavioral changes where possible.

---

## 9. Rewriting History

- Rebase locally before merging.
- Squash trivial or fixup commits before pushing to shared branches.
- Do not rewrite published history on shared branches unless coordinated.

---

## 10. Commit Message Anti-Patterns

Avoid:

- "fix stuff"
- "update"
- "changes"
- "misc"
- Vague or contextless messages
- Auto-generated messages without meaningful edits

---

## 11. Pull Request Alignment

- Pull request title should follow Conventional Commits format.
- PR description should expand on the commit body if needed.
- Ensure commit history tells a coherent story.

---

## 12. Automation and Tooling

- Enforce commit format using commit linting tools.
- Use pre-commit hooks where appropriate.
- Integrate semantic versioning automation when possible.

---

## 13. Versioning Strategy

- `feat` increments minor version.
- `fix` increments patch version.
- Breaking changes increment major version.
- Use automated release tooling where practical.

---

## 14. Long-Term Maintainability

- Commit history should explain system evolution.
- Messages should remain clear months or years later.
- Optimize for future maintainers reading `git blame`.

---

## 15. Professional Standard

- Treat commit history as permanent documentation.
- Write messages as if they will be read during a production incident.
- Avoid emotional or sarcastic commentary in commits.
