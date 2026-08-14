Check for a project README.md to orient yourself.

Follow these software development guidelines when practical:
- Avoid duplication, but prefer simple duplication over complex DRY abstractions.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- Write data-oriented code: think carefully about your data types.
- In database migrations, most boolean and string columns should have a NOT NULL constraint and a default value (empty string for strings). This simplifies queries, and application logic usually treats blank strings and NULL the same way.
- Lean on ASD-STE100 Simplified Technical English as a guide (not a strict rule — deviate when it reads better) and write with clarity, simplicity, brevity, and humanity (Zinsser).
- Keep comments terse. Explain WHY, not WHAT — unless the code is genuinely hard to follow.
- Don't reference old behavior unless writing an upgrade/migration guide.
- Commit messages: terse, 50/72 line length. Body is a short paragraph unless the commit warrants more.
