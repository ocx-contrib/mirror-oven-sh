# mirror-oven-sh

OCX mirror for [Bun](https://github.com/oven-sh/bun). One repository, one spec
directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [bun](https://github.com/oven-sh/bun) | [`bun/mirror.yml`](bun/mirror.yml) | `ghcr.io/ocx-contrib/oven-sh/bun` | `ocx.sh/oven-sh/bun` | `MIT AND LGPL-2.0-only AND LGPL-2.1-only` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/bun`, as `mirror-bun`. `oven-sh/bun` is the grouped successor — the
> namespace names Bun's GitHub org, which is also the company that builds it.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
bun/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`bun` publishes five platform entries: both Linux arches (glibc), both macOS
arches and `windows/amd64`.

**Linux is glibc-only, and that is a deliberate gap.** Upstream ships a
separate musl build per arch, and neither Linux build is static — each names
its own loader in `PT_INTERP`, so the mirrored keys carry an explicit
`+libc.glibc` and a bare key would be a lie. The musl builds are not mirrored
because no CI leg can load them: they additionally need `libstdc++.so.6` and
`libgcc_s.so.1`, bare Alpine ships neither, the container spec has **no
package-install hook**, and the renderer refuses any non-`*alpine*` image on a
`+libc.musl` platform (so a libstdc++-bearing Alpine image such as
`node:22-alpine3.20` — which does run bun — is rejected at spec load). The full
chain is recorded above `platforms:` in [`mirror-base.yml`](mirror-base.yml).
Adding musl is two `assets:` regexes and two platform keys, the day `ocx-mirror`
grows a container setup hook or a `containers[].libc` override.

`darwin/amd64` is **declared but held broken** for the whole version range: bun
SIGILLs under Rosetta 2 and GitHub has retired native Intel macOS runners, so
the slice cannot be CI-validated. The `severity: broken` exclude keeps it
visible as a documented 🔒 row rather than silently dropping it.

`windows/arm64` is not declared, though upstream does publish
`bun-windows-aarch64.zip` — this repository has never carried it.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `bun/mirror.yml` | hand | yes — see below |
| `bun/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `bun/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec bun/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Each bun zip wraps a single `bun` executable in a `bun-<platform>/` directory,
so `strip_components: 1` lands that executable **at** the bundle content root
and the only PATH entry is a bare `${installPath}`. `bin_scan` only looks
*below* an `${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec
load with exit 65. `mirror-base.yml` therefore sets `bin_scan: off` and
`bun/metadata.json` hand-lists `binaries: ["bun"]` — the blessed shape for this
layout. There is no `bunx` in the archive (npm creates that symlink at install
time), so it is not claimed.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md) —
including the **LGPL Corresponding Source pointers** bun's statically linked
JavaScriptCore requires.
