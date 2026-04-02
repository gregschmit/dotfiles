---
name: d2-diagrams
description: "Generate declarative diagrams using D2 (d2lang.com). Use this skill whenever the user asks to create, generate, or update a diagram, visualize architecture, draw flows, make ERDs, sequence diagrams, network topologies, system overviews, or any kind of visual representation of code, systems, or relationships. Also trigger when the user says things like 'diagram this', 'draw me a...', 'visualize the...', 'make a flowchart', 'show the relationship between...', or when creating documentation that would benefit from a diagram. If you're unsure whether a diagram is the right output format, ask the user."
---

# D2 Diagram Generation

You generate diagrams using [D2](https://d2lang.com), a modern declarative diagramming language. D2 turns text into diagrams — you describe *what* to diagram, and D2 handles layout and rendering.

## How to use this skill

1. **Understand the request** — figure out what the user wants to visualize. Read relevant code, schemas, configs, or docs in the project to gather context. The diagram should reflect the actual state of the system, not a guess.

2. **Choose the right diagram type:**
   - **Architecture / system overview** → containers, shapes, connections with `direction: right` or `direction: down`
   - **Database / ERD** → `sql_table` shapes with foreign key connections
   - **Sequence / interaction flow** → `sequence_diagram` shape
   - **Flowchart / decision tree** → shapes with `diamond` for decisions, directed connections
   - **Network topology** → nested containers for network zones, `cloud` shapes for external services
   - **Class diagram** → `class` shapes

3. **Write the `.d2` file** — save it in `docs/diagrams/` (create the directory if needed). Use a descriptive filename like `dhcp-flow.d2` or `database-erd.d2`.

4. **Offer to render** — after writing the file, give the user options to view it:

   **Option A: Local render** (if `d2` CLI is installed):
   ```bash
   # Check if d2 is available
   which d2

   # Render and open (SVG is the default, good for most cases)
   d2 docs/diagrams/my-diagram.d2 docs/diagrams/my-diagram.svg && open docs/diagrams/my-diagram.svg

   # For dark backgrounds
   d2 --theme 200 docs/diagrams/my-diagram.d2 docs/diagrams/my-diagram.svg

   # PNG if they need a raster format
   d2 docs/diagrams/my-diagram.d2 docs/diagrams/my-diagram.png
   ```

   **Option B: Open in D2 Playground** (always available, no install needed):
   ```bash
   python3 <skill-dir>/scripts/playground-url.py docs/diagrams/my-diagram.d2
   ```
   This prints a `https://play.d2lang.com/?script=...` URL. Open it with:
   ```bash
   open "$(python3 <skill-dir>/scripts/playground-url.py docs/diagrams/my-diagram.d2)"
   ```
   The playground lets the user interactively edit, preview, and export the diagram in their browser. Use this when `d2` isn't installed locally, or when the user wants to tweak the diagram interactively.

   Replace `<skill-dir>` with the actual path to this skill directory (the directory containing this SKILL.md file).

## Writing good D2

### Structure for clarity

Organize the file in sections: variables/classes first, then shapes, then connections. Use comments to separate logical groups.

```d2
# -- Config --
direction: right

# -- Classes --
classes: {
  service: {
    style: {
      fill: "#e3f2fd"
      stroke: "#1565c0"
      border-radius: 8
    }
  }
  database: {
    shape: cylinder
    style: {
      fill: "#e8f5e9"
      stroke: "#2e7d32"
    }
  }
}

# -- Services --
api: API Server { class: service }
auth: Auth Service { class: service }
pg: PostgreSQL { class: database }

# -- Connections --
api -> auth: validates tokens
api -> pg: reads/writes
auth -> pg: queries users
```

### Naming conventions

- Use lowercase, hyphenated keys for shape IDs: `api-server`, `auth-db`
- Use descriptive labels: `api-server: API Server`
- Keep connection labels short — they're annotations, not paragraphs

### Keep it readable

- Don't cram too many shapes into one diagram. If you're past ~20 shapes, consider splitting into multiple diagrams or using containers to group related items.
- Use containers to show logical grouping (services in a "Backend" container, databases in a "Data" container).
- Set `direction` to match the flow — `right` for pipelines/data flow, `down` for hierarchies.

### Use styles intentionally

- Color-code by category (services blue, databases green, external red)
- Use `style.stroke-dash: 5` for optional/planned connections
- Use `style.animated: true` sparingly — good for highlighting a specific flow path
- Use `style.multiple: true` to indicate "there are many of these" (e.g., worker pool)

## D2 syntax reference

Read `references/d2-syntax.md` for the complete language reference when you need specific syntax details. Key things to remember:

- Shapes: just write a key (`myShape` or `myShape: Label`)
- Connections: `->`, `<-`, `<->`, `--`
- Containers: `parent: { child1; child2 }`
- Styles: `shape.style.fill: "#hex"`
- SQL tables: `shape: sql_table` with typed columns and constraints
- Sequence diagrams: `shape: sequence_diagram` — order is preserved
- Variables: `vars: { key: value }` → `${key}`
- Globs: `*.style.fill: blue` applies to all shapes
- Classes: define in `classes: {}`, apply with `class: name`
- Icons: `icon: https://icons.terrastruct.com/...`

## Common pitfalls (important — read before writing D2)

These are real issues that cause compile failures. Internalize them.

### Block strings and pipe characters
D2 block strings are delimited by `|`. If your content contains literal `|` characters (e.g., `SHA-256(mac|prl|vendor)`), the parser will interpret them as block string terminators and fail. **Fix:** use double-pipe `||` delimiters instead:
```d2
# WRONG — will break if content has | characters
my_note: |md
  Hash: SHA-256(mac|prl|vendor)
|

# RIGHT — double-pipe delimiters
my_note: ||md
  Hash: SHA-256(mac|prl|vendor)
||
```
If content contains `||`, use `|||`, and so on. Always default to `||md ... ||` for markdown notes since pipe characters are common in technical diagrams.

### Connection labels can't use block strings with style blocks
In sequence diagrams, connection labels with markdown block strings (`|md ... |`) cannot also have inline style blocks (`{ style.stroke: red }`). The parser gets confused.
```d2
# WRONG — block string + style block on connection
a -> b: |md
  **bold label**
| {
  style.stroke: red
}

# RIGHT — use plain string labels when you need styles on connections
a -> b: "bold label" {
  style.stroke: red
  style.stroke-dash: 5
}
```
For detailed annotations in sequence diagrams, use **notes** (`.note` or `."label"`) with block strings instead of trying to put everything in connection labels.

### Sequence diagram notes pattern
Use quoted keys for notes on actors in sequence diagrams. These render as annotation boxes:
```d2
seq: {
  shape: sequence_diagram
  alice: Alice
  bob: Bob

  alice -> bob: "sends request"

  # Note on actor — use ."quoted key" syntax
  bob."processing": ||md
    **Steps:**
    - Validate input
    - Query database
    - Return result
  ||

  bob -> alice: "response"
}
```

### ERD with classes — apply class on the shape, not inline
For `sql_table` shapes, define the class with the style and apply it, but don't put `shape: sql_table` inside the class — set it on each table individually, or use the class just for colors:
```d2
classes: {
  blue-table: {
    shape: sql_table
    style.fill: "#e3f2fd"
    style.stroke: "#1565c0"
  }
}

users: {
  class: blue-table
  id: int {constraint: primary_key}
  name: varchar
}
```

### Key length limit
D2 has a maximum key length of 518 characters. Keep connection labels and shape labels under this limit. If you need more text, use a note instead of a label.

### Icons from icons.terrastruct.com
The free icon set at `icons.terrastruct.com` returns 403 for URL-encoded paths (e.g., `%2F` instead of `/`). If icons fail to bundle, either skip them or use a different icon source. Icons are nice-to-have but not worth blocking a diagram over — remove the `icon:` line and move on.

## Context-aware diagramming

When asked to diagram something from the codebase:

- **Database schema** → read `internal/ent/schema/` files, extract fields/edges, generate `sql_table` shapes with proper types and FK connections
- **Architecture** → read the project structure, identify services/components, show their relationships
- **API flow** → read handler code, trace the request path, generate a sequence diagram
- **Network topology** → read reconciler configs, VPP setup, show interfaces/VLANs/subnets
- **Reconciler flow** → show the DB → LISTEN/NOTIFY → reconciler → config file → service reload pipeline

Always read the actual code before generating — the diagram should be accurate, not aspirational.
