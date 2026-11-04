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

## Auth errors: stop and ask

If a forge CLI fails on authentication, authorization, or permissions — expired login session, missing or invalid token, 401/403, `gh auth`/`glab auth` complaints, SSO or 2FA prompts — stop and ask the user how to proceed. Do not work around it, retry with another path, or continue and report it at the end.

## Forge API workarounds

### Comment collection

Basic verbs (`view`, `checkout`, `create`) are safe to improvise. Collecting every comment on a PR/MR is not — GitHub splits issue comments, review submissions, and inline review comments across three endpoints; GitLab uses discussions/notes with a different shape. When completeness matters, prefer the API subcommand (`gh api`, `glab api`) over the higher-level `view --comments`, and dump raw JSON to a scratch file to read.

### Posting a multi-line comment

**gh** — straightforward, no workaround: `gh pr comment N --body-file <file>` for a top-level comment, `gh pr review N --comment --body-file <file>` for a review submission.

**glab** — `glab api --field body@file` does NOT read files, and `--field` chokes on newlines. POST a JSON payload on stdin with an explicit content-type header:

```
python3 -c "import json;print(json.dumps({'body':open('REVIEW.md').read()}))" > /tmp/p.json
glab api -X POST "/projects/<id>/merge_requests/<iid>/discussions" \
  -H "Content-Type: application/json" --input /tmp/p.json
```

`discussions` starts a resolvable thread; use `/notes` for a plain comment. The header is required — without it glab sends no content-type and the API returns HTTP 415.

### Attaching a file

**gh** — the API has no upload endpoint for issue or PR attachments. Link to a committed file or a release asset instead.

**glab** — upload through the per-project uploads API with curl, then paste the returned `markdown` field into the comment or description. `glab api --field "file=@…"` sends the file as a JSON string and fails with "file is invalid". Pipe the token in as a header so it stays out of argv, and use `--fail-with-body` so an HTTP error exits non-zero instead of saving the error JSON:

```
TOKEN=$(glab config get token --host <host>)   # --host, not -h: -h prints help text into the variable
printf 'PRIVATE-TOKEN: %s\n' "$TOKEN" | curl --fail-with-body -sS -H @- \
  --form "file=@shot.png" "https://<host>/api/v4/projects/<group>%2F<proj>/uploads"
```

The `markdown` value (`![shot](/uploads/<secret>/shot.png)`) only renders inside that project, so re-upload for each project you post in. SVGs do not render inline; convert to PNG first. To download someone else's attachment, GET `/api/v4/projects/<group>%2F<proj>/uploads/<secret>/<filename>` with the same header and `-fsS -o <filename>`; the web `/uploads/…` URL redirects to sign-in and the uploads list endpoint is 403 for non-maintainers.

### Inline suggested changes

Both forges support suggestion blocks that reviewers accept in one click. The comment must anchor to a line that exists in the PR/MR's current head SHA on the server — if you merged primary locally without pushing, the position will be rejected.

**gh** — POST to `/repos/{owner}/{repo}/pulls/{N}/reviews` with `event: "COMMENT"` and a `comments` array; each entry has `path`, `line` (or `start_line`+`line` for a range), `side: "RIGHT"`, and a body containing a fenced suggestion block:

    ```suggestion
    corrected line(s) here
    ```

**glab** — POST to `/projects/<id>/merge_requests/<iid>/discussions` with a `position` object (`base_sha`, `head_sha`, `start_sha`, `position_type: "text"`, `new_path`, `new_line`) and a note body containing a suggestion block. Same JSON-on-stdin dance as above — `--field` still chokes on newlines. The suggestion syntax `suggestion:-N+M` means replace `N` lines above the anchor and `M` below:

    ```suggestion:-0+0
    replacement for the anchor line only
    ```
