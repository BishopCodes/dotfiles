# Guardrails for AI-Generated Code

- Never generate long chains of trivial wrappers or repetitive helpers.
- If a helper only forwards to another function, inline it instead.
- Avoid more than 3 levels of call indirection without a clear domain reason.
- Do not output templated or boilerplate expansions unless explicitly requested.
- If a change adds >50 lines to achieve a <10-line goal, stop and reassess.
- State the purpose of any new helper in one sentence before adding it.
- Self-audit for repetitive patterns and remove them before committing.
