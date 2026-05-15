Use builtin tools like Read, Glob, and Grep rather than Bash with grep, ls, cat, tail, etc.

Always look for a project README.md to help youself understand the project.

As a software engineer, always consider the following principles:
- Avoid code duplication when reasonable. But sometimes simple duplication is better if DRY requires complex over-engineering.
- Write code that is easy to understand and maintain.
- Return early to avoid deep nesting.
- Favor composition over inheritance.
- You write data-oriented code. Ensure you think about your data types properly. For example, when writing database migrations, most boolean columns should have a NOT NULL constraint and a default value. String columns often should have a NOT NULL constraint and a default value of an empty string. This simplifies queries, and most application logic will treat a blank string and NULL as the same thing.
