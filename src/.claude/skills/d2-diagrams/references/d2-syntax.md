# D2 Language Reference

## Table of Contents
1. [Shapes](#shapes)
2. [Connections](#connections)
3. [Containers](#containers)
4. [Styles](#styles)
5. [Classes](#classes)
6. [Icons](#icons)
7. [SQL Tables](#sql-tables)
8. [Sequence Diagrams](#sequence-diagrams)
9. [Variables](#variables)
10. [Globs](#globs)
11. [Layout Configuration](#layout-configuration)

---

## Shapes

Declare shapes by writing a key. The key becomes the default label:

```d2
imAShape
im_a_shape
im a shape
```

Set a custom label with a colon:
```d2
pg: PostgreSQL
```

Set the shape type:
```d2
my_cloud: Cloud Services {
  shape: cloud
}
```

### Available shape types
`rectangle` (default), `square`, `circle`, `oval`, `diamond`, `hexagon`, `parallelogram`, `cylinder`, `queue`, `package`, `step`, `callout`, `stored_data`, `person`, `page`, `document`, `cloud`, `c4-person`, `image`, `class`, `sql_table`, `sequence_diagram`

Keys are **case-insensitive** — `postgresql` and `postgreSQL` reference the same shape.

`circle` and `square` maintain 1:1 aspect ratio automatically.

---

## Connections

Four connection operators:
```d2
a -> b        # directed (left to right)
a <- b        # directed (right to left)
a <-> b       # bidirectional
a -- b        # undirected
```

### Labels on connections
```d2
a -> b: sends data
```

### Chaining
```d2
a -> b -> c -> d
```

### Multiple connections
Repeated connections create new edges (they do NOT override):
```d2
a -> b: first
a -> b: second
```

### Arrowhead customization
```d2
a -> b: {
  source-arrowhead: diamond
  target-arrowhead: {
    shape: cf-many-required
    label: 1..*
  }
}
```

Arrowhead shapes: `triangle` (default), `arrow`, `diamond`, `circle`, `box`, `cf-one`, `cf-one-required`, `cf-many`, `cf-many-required`, `cross`

Diamond/circle/box support `filled: true/false`.

---

## Containers

Nest shapes inside containers with curly braces:
```d2
server: Backend {
  api: API Server
  db: Database

  api -> db: queries
}
```

### Dot notation (flat syntax)
```d2
server.api: API Server
server.db: Database
server.api -> server.db
```

### Container labels
```d2
server: My Backend {
  label: Backend Services
}
```

### Parent reference with underscore
```d2
server: {
  api: API
  api -> _.client: responds
}
client: Client
```

`_` refers to the parent scope.

---

## Styles

Apply via `style` block:
```d2
my_shape: {
  style: {
    fill: "#e3f2fd"
    stroke: "#1565c0"
    stroke-width: 2
    stroke-dash: 5
    border-radius: 8
    shadow: true
    opacity: 0.9
    font-size: 16
    font-color: "#333"
    bold: true
    italic: false
    underline: false
    text-transform: uppercase
  }
}
```

Shape-only properties: `fill`, `fill-pattern`, `shadow`, `3d`, `multiple`, `double-border`

`3d` works on rectangles/squares only. `multiple` renders a stacked duplicate behind the shape.

Connection styles:
```d2
a -> b: {
  style: {
    stroke: red
    stroke-width: 3
    stroke-dash: 5
    animated: true
    font-size: 14
    bold: true
  }
}
```

`animated` creates a dashed animation on connections.

For `sql_table` and `class` shapes: `stroke` applies as body fill; `fill` controls header color.

---

## Classes

Define reusable style sets:
```d2
classes: {
  primary: {
    style: {
      fill: "#1976d2"
      font-color: white
      border-radius: 8
    }
  }
  danger: {
    style: {
      fill: "#d32f2f"
      font-color: white
    }
  }
}

my_shape: Important {
  class: primary
}

alert: Warning {
  class: danger
}
```

### Multiple classes
```d2
my_shape.class: [primary, large]
```
Applied left-to-right; later classes override earlier ones. Object-level attributes override class attributes.

---

## Icons

Add icons from URLs or local paths:
```d2
server: Backend {
  icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}
```

### Standalone icon (image shape)
```d2
k8s: Kubernetes {
  shape: image
  icon: https://icons.terrastruct.com/azure%2F_Companies%2FKubernetes.svg
}
```

Free icons: https://icons.terrastruct.com

Local files work with the CLI: `icon: ./images/logo.png`

Icon placement is automatic. Container icons go top-left; non-container icons center.

---

## SQL Tables

```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  email: varchar(255) {constraint: unique}
  name: varchar(100)
  org_id: int {constraint: foreign_key}
}

orgs: {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar(100)
}

users.org_id -> orgs.id
```

Constraint abbreviations: `primary_key` → PK, `foreign_key` → FK, `unique` → UNQ.

Multiple constraints: `{constraint: [primary_key; unique]}`

---

## Sequence Diagrams

```d2
scenario: {
  shape: sequence_diagram

  alice: Alice
  bob: Bob
  server: Server

  alice -> bob: Hey
  bob -> server: Check auth
  server -> bob: OK
  bob -> alice: Authenticated

  # Notes
  alice."a]note": This is a note on Alice

  # Spans (activation boxes)
  bob."]span" -> server: nested call

  # Groups (frames/fragments)
  auth check: {
    bob -> server: verify token
    server -> bob: valid
  }
}
```

Key rules:
- Order is preserved (unlike normal D2)
- All actors share the same scope
- Actors appear when first referenced, or declare explicitly to set order
- Groups are containers that frame a subset of interactions

---

## Variables

```d2
vars: {
  primary-color: "#1976d2"
  app-name: My Application
  db: {
    type: PostgreSQL
    version: "16"
  }
}

title: ${app-name} Architecture
database: ${db.type} ${db.version} {
  style.fill: ${primary-color}
}
```

### Scoping
Inner scopes can access outer variables. Closest scope wins on conflict.

### Spread
```d2
vars: {
  shared-style: {
    style.fill: "#eee"
    style.border-radius: 8
  }
}
my_shape: {
  ...${shared-style}
}
```

### Literal (no substitution)
Use single quotes: `label: '${not-a-var}'`

---

## Globs

Apply styles to multiple shapes at once:
```d2
# All top-level shapes get blue fill
*.style.fill: "#e3f2fd"

# All connections get dashed style
(* -> *)[*].style.stroke-dash: 5

a: Shape A
b: Shape B
c: Shape C
a -> b -> c
```

Globs apply both backward and forward. They are scoped — a glob inside a container only affects that container's children.

---

## Layout Configuration

### Set direction
```d2
direction: right   # right | left | up | down
```

### Layout engines
Set via CLI flag `--layout=dagre` or env var `D2_LAYOUT=dagre`.

| Engine | Notes |
|--------|-------|
| dagre  | Default. Fast, hierarchical. Good for most diagrams. |
| elk    | More mature, supports container dimensions. |
| tala   | Best for software architecture. Proprietary. Supports `near`, absolute positioning, per-container direction. |

### Near (positioning)
```d2
title: My Diagram {
  near: top-center
}
legend: {
  near: bottom-right
}
```

Values: `top-left`, `top-center`, `top-right`, `center-left`, `center-right`, `bottom-left`, `bottom-center`, `bottom-right`

### Absolute positioning (TALA only)
```d2
my_shape: {
  top: 100
  left: 200
  width: 300
  height: 150
}
```
