---
name: rxg
description: Background on RG Nets' rXg product and how to reach rXg boxes over SSH as $USER. Read whenever a task involves the rxg source tree, an rXg or lab box, or the rgnets/rxg project on git.rgnets.com.
---

# rXg

The rXg is RG Nets' flagship product: a network gateway appliance: a FreeBSD box running a Rails app and a Perl daemon. GitLab: `git.rgnets.com`, project `rgnets/rxg`.

## On the box

- Code at `/space/rxg`. `cd /space/rxg/console && bin/rails runner '<ruby>'` works as the plain SSH user.
- PostgreSQL database `config`, role `rails`, unix socket only: `psql -U rails -d config -tA -c "..."`.
- Logs: `/var/log/rxgd.log` first, then `/space/rxg/console/log/production.log`. Rotated copies are gzipped.
- Version: `pkg info | grep rxg`. Admin UI: `https://<host>/admin`. Admin homes: `/space/admins/<login>`.
- After changing code: `service rxgd restart` (rxgd, and it runs pending migrations), `service rxgd usr2` (reloads console Ruby; views reload per request). Never signal puma directly.
- FreeBSD: no `sftp-server` (use `rsync`, or `ssh <host> 'cat > /tmp/f' < f`), no `tcpdump -i any`, `fetch` instead of `wget`.

## Access

In your environment you likely can ssh into rXgs as $USER using the system keychain. This requires the rXg to have admin sync enabled (`DeviceOption.sync_builtin_admins`).

Treat a box as a customer's unless told it is a lab. On a customer box stay read-only; show any write verbatim and get a very explicit yes before running it.

## Root Access

Root is `su` (wheel) with the per-box root password: the first long uppercase alpha token in `/etc/issue`, also printed by `/space/rxg/rxgd/bin/print_iui`. Prefer the plain user; reads, `rails runner` and `psql` need no root. When root is needed, run one command and keep the password out of the transcript and out of files:

```
PW=$(ssh $USER@<host> /space/rxg/rxgd/bin/print_iui 2>/dev/null | grep -oE '[A-Z]{16,}' | head -1)
printf '%s\n' "$PW" | ssh -tt $USER@<host> "su -m root -c '<command>'" 2>&1 | tr -d '\r'
```

Anything longer than one command: stage a script in `/tmp` on the box and `su -m root -c /tmp/x.sh`, because nested quoting through ssh and su hangs the pty. `su: Sorry` with the right password means the box is mid-upgrade; wait and retry.

Shared test labs are issues in `rgnets/labs` (one per lab; `lab::available|in-use|maintenance` and `cap:*` labels). Claim one there before using it.
