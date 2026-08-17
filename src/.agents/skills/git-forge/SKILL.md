---
name: git-forge
description: Rules for detecting GitHub vs GitLab and invoking the right forge CLI. Read whenever the user asks about issues or PRs/MRs, and as a reference for other workflow skills.
---

# Git Forge

## Detect

`git config --get remote.origin.url`. Host `github.com` → GitHub (`gh`). Any other host → GitLab (`glab`), typically self-hosted (e.g. `git.rgnets.com` — gitlab.com is not used here).

## glab: always pass an explicit host

Never let `glab` fall back to gitlab.com. On every `glab` command, pass `--repo <HOST>/<OWNER>/<REPO>` (e.g. `--repo git.rgnets.com/group/project`). Derive host/owner/repo from the origin URL. `GITLAB_HOST=<host>` also works if `--repo` is inconvenient for a given subcommand.

`gh` needs no equivalent — it reads the remote correctly.

## Comment collection is the fiddly part

Basic verbs (`view`, `checkout`, `create`) are safe to improvise. Collecting every comment on a PR/MR is not — GitHub splits issue comments, review submissions, and inline review comments across three endpoints; GitLab uses discussions/notes with a different shape. When completeness matters, prefer the API subcommand (`gh api`, `glab api`) over the higher-level `view --comments`, and dump raw JSON to a scratch file to read.

## Posting a multi-line comment (glab)

`glab api --field body@file` does NOT read files, and `--field` chokes on newlines. For a real review body, POST a JSON payload on stdin with an explicit content-type header:

```
python3 -c "import json;print(json.dumps({'body':open('REVIEW.md').read()}))" > /tmp/p.json
glab api -X POST "/projects/<id>/merge_requests/<iid>/discussions" \
  -H "Content-Type: application/json" --input /tmp/p.json
```

`discussions` starts a resolvable thread; use `/notes` for a plain comment. The header is required — without it glab sends no content-type and the API returns HTTP 415.
