# Coding Standards and Practices

## 1. Abstractions Over Implementations

- Favor interfaces over concrete implementations.
- Depend on abstractions, not specific classes.
- Program to contracts that allow substitution and extension.

---

## 2. Testing Philosophy

- Test critical portions of code where failure would cause significant impact.
- Code coverage is not the goal; confidence is.
- Ensure integration tests validate application outcomes, even if external dependencies are mocked.
- Any refactoring must include tests that verify behavior remains unchanged.

---

## 3. Naming Conventions

### Functions / Methods

- Use clear, descriptive names that communicate intent.
- Prefer action-oriented names such as `getUser`, `setConfiguration`, `calculateTotal`.
- A function name should describe what it accomplishes, not how it works.

### Booleans

- Prefix boolean variables with `is`, `has`, `can`, or similar:
  - `isActive`
  - `hasPermission`
  - `canRetry`

### Variables

- Use explicit, meaningful names.
- Avoid ambiguous identifiers such as `i`, `x`, or `e`.

Examples:

- Use `index` instead of `i` in loops.
- Use `person` instead of `x` in `people.map(person => ...)`.
- Use `error` or `err` instead of `e` in exception handling.

---

## 4. Data Types

- Use the most appropriate data structure for the problem.
- Prefer specific types over generalized ones:
  - Use `Set` when uniqueness matters.
  - Use `Map` for key-value relationships.
- Avoid unnecessarily large numeric types.
- Choose types based on domain constraints.

---

## 5. Control Flow

### Guard Clauses

- Use guard clauses to validate input early.
- Fail fast when preconditions are not met.

### Early Returns

- Prefer early returns over deep nesting.
- Reduce cognitive complexity by avoiding excessive conditional layering.

### Conditional Depth

- Refactor when nesting exceeds two levels.
- Extract complex conditionals into well-named helper functions.

---

## 6. Design Patterns

- Use established patterns such as Builder, Factory, Repository where appropriate.
- Do not introduce patterns unless the benefit outweighs the added complexity.
- Avoid pattern-driven development.

---

## 7. Comments

- Write comments only when intent cannot be expressed clearly through naming and structure.
- Avoid redundant comments that restate obvious behavior.
- Use comments to explain why, not what.

---

## 8. Functional Programming Principles

- Favor pure functions where possible.
- Minimize side effects.
- Write deterministic, repeatable logic.
- Prefer immutability where feasible.

---

## 9. Tooling and Static Analysis

- Address LSP warnings and suggestions promptly.
- Modernize code when safe and appropriate.
- Treat tooling feedback as part of the development lifecycle.

---

## 10. Optimization Strategy

- Avoid premature optimization.
- Identify bottlenecks before optimizing.
- Optimize where measurable performance issues exist.

---

## 11. Logging

- Implement structured and meaningful logging.
- Use appropriate log levels:
  - Debug
  - Info
  - Warning
  - Error
  - Critical
- Avoid excessive logging in performance-sensitive paths.

---

## 12. Dependency Management

- Use external dependencies only when the benefit outweighs maintenance cost.
- Prefer standard language features over heavy libraries.
- Avoid large utility libraries when native alternatives suffice.
- Favor lightweight and focused libraries when necessary.
- Avoid bleeding-edge technologies for core systems.

---

## 13. Project Structure

- Follow idiomatic project structure for the chosen language or framework.
- Maintain consistent organization across modules.
- Group code by responsibility and domain where possible.

---

## 14. Extensibility

- Design systems to allow injection of cross-cutting concerns:
  - Observability
  - Feature flags
  - Configuration
- Enable extension without modifying core logic.

---

## 15. Feature Flags

- Use feature flags to introduce new functionality safely.
- Ensure flags can be toggled without redeployment where feasible.
- Remove stale flags after rollout completion.

---

## 16. Language Idioms

- Write idiomatic code aligned with the language’s philosophy.
- Embrace language-level features and patterns.
- Avoid writing one language in the style of another.

---

## 17. Maintainability and Readability

- Optimize for future maintainers.
- Prefer clarity over cleverness.
- Reduce mental overhead through structure and consistency.
- Code should be understandable without excessive context.
