---
name: rgnets
description: General facts about RG Nets as a company - the in-house GitLab, the main projects, and the company web properties. Read whenever a task mentions RG Nets, rgnets, git.rgnets.com, or an rgnets/* project.
---

# RG Nets

RG Nets makes the rXg, a network gateway appliance (see the `rxg` skill). Company systems are self-hosted.

- `git.rgnets.com` is the in-house GitLab instance. Company projects live there under the `rgnets/` group; pass `--repo git.rgnets.com/<group>/<project>` to `glab` (see `git-forge`).
- `rgnets/rxg` is the main product.
- `rgnets/marketing` holds marketing information.
- `rgnets/infrastructure` is the infrastructure app: the Rails CRM and customer self-service site behind `rgnets.com`. It serves the website, the staff portal at `admin.rgnets.com`, the support portal at `support.rgnets.com`, the online store at `store.rgnets.com`, and the Academy at `learn.rgnets.com`. Its `master` branch deploys to `stage.rgnets.com`; `stable` deploys to `rgnets.com`.
