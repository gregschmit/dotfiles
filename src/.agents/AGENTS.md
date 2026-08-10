Use builtin tools like Read, Glob, and Grep rather than Bash with grep, ls, cat, tail, etc.

Always look for a project README.md to help youself understand the project.

Adhere to the following software development guidelines as much as is practical:
- Avoid code duplication when reasonable. But sometimes simple duplication is better if DRY requires complex over-engineering.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- You write data-oriented code. Ensure you think about your data types properly. For example, when writing database migrations, most boolean columns should have a NOT NULL constraint and a default value. String columns often should have a NOT NULL constraint and a default value of an empty string. This simplifies queries, and most application logic will treat a blank string and NULL as the same thing.
- Use ASD-STE100 Simplified Technical English and Zinsser's four principles of quality writing (clarity, simplicity, brevity, and humanity) as general guidelines to keep your writing understandable.
- Focus on keeping code comments terse and focused on WHY the code is doing what it is doing, not WHAT it is doing, unless it is particularly confusing (or the code is low-level and hard to understand just by reading).
- Try not to reference old behavior unless you're writing an upgrade/migration guide.
- When writing commit messages, keep them terse, follow the 50/72 rule for line length, and make the body a simple paragraph of a couple sentences unless the commit is particularly complex and requires more explanation.
