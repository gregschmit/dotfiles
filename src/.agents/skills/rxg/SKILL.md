---
name: rxg
description: What the rXg is and how to work on one over SSH. Read whenever a task involves the rxg source tree, an rXg or lab box, or rgnets/rxg.
---

# rXg

The rXg is RG Nets' flagship product, a network gateway appliance. It is a FreeBSD box running two things from `/space/rxg`:

- `console/`: a Rails app that serves the admin UI at `https://<host>/admin`, the REST API and the captive portals.
- `rxgd/`: a Perl daemon that turns the configuration into config files for the system services it supervises (packet filter, DHCP, DNS, RADIUS, nginx, ...) and restarts them when the configuration changes.

Configuration lives in the PostgreSQL database `config`. Change it through Rails (the UI, the API or `rails runner`), never with raw SQL: saving a record queues a trigger that makes rxgd regenerate and restart the affected service, and a direct `UPDATE` skips that. Source: GitLab `git.rgnets.com`, project `rgnets/rxg`.

## On the box

- `cd /space/rxg/console && bin/rails runner '<ruby>'` works as the plain SSH user.
- Read-only SQL: `psql -U rails -d config -tA -c "..."` (unix socket only).
- Logs: `/var/log/rxgd.log` first, then `/space/rxg/console/log/production.log`. Rotated copies are gzipped.
- Version: `pkg info | grep rxg`. Admin homes: `/space/admins/<login>`.
- FreeBSD: no `sftp-server` (use `rsync`), no `tcpdump -i any`, `fetch` instead of `wget`.

## Access

In most environments you can `ssh $USER@<host>` straight in, with the key your keychain or ssh-agent offers: RG Nets staff keys ship in the product, and any rXg with Built-in Admin Sync enabled (`DeviceOption.sync_builtin_admins`, toggled in `rxgconfig`) creates a unix account for each staff member with their key.

Treat a box as a customer's unless told it is a lab. On a customer box stay read-only; show any write verbatim and get an explicit yes before running it.

## Root

Root is `su` (staff accounts are in `wheel`) with the per-box root password: the first long uppercase token in `/etc/issue`, also printed by `/space/rxg/rxgd/bin/print_iui`. Prefer the plain user; reads, `rails runner` and `psql` need no root. When root is needed, run one command, in a single shell call, and keep the password out of the transcript and out of files:

```
PW=$(ssh $USER@<host> /space/rxg/rxgd/bin/print_iui 2>/dev/null | grep -oE '[A-Z]{16,}' | head -1)
printf '%s\n' "$PW" | ssh -tt $USER@<host> "su -m root -c '<command>'" 2>&1 | tr -d '\r'
```

Anything longer than one command: stage a script in `/tmp` on the box and run `su -m root -c /tmp/x.sh`, because nested quoting through ssh and su hangs the pty. `su: Sorry` with the right password means the box is mid-upgrade; wait and retry.

## Syncing changes

Most of `/space/rxg` is root-owned, so stage as yourself, then copy as root. From the repo root, with repo-relative paths (they are the same paths under `/space/rxg`):

```
rsync -azR console/app/models/account.rb $USER@<host>:/tmp/sync/   # -R keeps the path
```

then, as root (pattern above): `cp -R /tmp/sync/. /space/rxg/`. Then activate: Perl under `rxgd/` or a migration needs `service rxgd restart` (rxgd applies pending migrations on start); console Ruby needs `service rxgd usr2` (re-execs puma); views reload on their own. Never signal puma directly.

## Builds and labs

- Builds come from `build.rgnets.com`: beta builds track master, alpha builds are branches. Upgrade a box with `upgrade_to_latest_build` on the box or the admin UI's upgrade-from-URL; rXg does not support downgrades.
- FreeBSD ports and kernel modules come from `rgnets/rxg-ports-overlay` at the commit pinned by `PORTS_REF` in `build/FreeBSD/14.4/build.conf`. A merged module MR reaches builds only after an rxg MR bumps that pin; `git show <tag>:build/FreeBSD/14.4/build.conf` tells you what a build ships.
- Test VMs need at least 8 cores, 16 GB RAM, 100 GB disk and 2 NICs (3 for a cluster node); a git-backed dev box needs 200 GB or more.
- Shared test labs are issues in `rgnets/labs` (one per lab; `lab::available|in-use|maintenance` and `cap:*` labels). Claim one there before changing it.
