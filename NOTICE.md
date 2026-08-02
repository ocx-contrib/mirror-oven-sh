# NOTICE

This repository packages and redistributes upstream software published by
[Oven](https://github.com/oven-sh). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `bun` | `ghcr.io/ocx-contrib/oven-sh/bun` | `MIT AND LGPL-2.0-only AND LGPL-2.1-only` |

---

## `bun`

Upstream: <https://github.com/oven-sh/bun>
Published to `ghcr.io/ocx-contrib/oven-sh/bun`.

| Component | SPDX | Holder |
|---|---|---|
| Bun itself (`bun`) | **MIT** | Copyright (c) Oven Inc. |
| JavaScriptCore / WebKit (statically linked) | **LGPL-2.0-only** | Apple Inc. and the WebKit contributors |
| `tinycc` (statically linked) | **LGPL-2.1-only** | Fabrice Bellard and contributors |
| boringssl, brotli, libarchive, lol-html, ls-hpack, ls-qpack, lsquic, mimalloc, picohttpparser, zstd, simdutf, uSockets, zlib-ng, c-ares, libicu, libbase64, libuv, libdeflate, libjpeg-turbo, libspng, libwebp, highway, uucode, uWebSockets, TigerBeetle IO, LLVM libc++abi (statically linked) | MIT / BSD-2-Clause / BSD-3-Clause / Apache-2.0 / Apache-2.0-with-LLVM-exception / Zlib / ICU | respective holders |

**`gh api repos/oven-sh/bun/license` answers `NOASSERTION`** — GitHub cannot
match bun's `LICENSE` to a standard template, so it was classified by hand. It
is **not plain MIT**. Verbatim from upstream's
[`LICENSE`](https://github.com/oven-sh/bun/blob/main/LICENSE):

> Bun itself is MIT-licensed.
>
> Bun statically links JavaScriptCore (and WebKit) which is LGPL-2 licensed.
> WebCore files from WebKit are also licensed under LGPL2.

and, in the linked-library table, `tinycc` → LGPL v2.1. The mirrored binary
therefore embeds weak-copyleft code, and the SPDX expression above is the one
that covers the bytes actually shipped.

### Corresponding Source (LGPL §6 / §4)

Redistributing a binary with statically linked LGPL code obliges us to convey
the Corresponding Source for the LGPL parts and to leave relinking possible.
Both are satisfied:

- **Relinking.** This mirror republishes the upstream binary **byte-for-byte**
  inside an OCX bundle; nothing is modified, recompiled or relinked. Upstream
  documents the relink procedure in the same `LICENSE` file (clone
  `oven-sh/WebKit`, `bun sync-webkit-source`, `bun run build:local`).
- **Source, per version.** For a mirrored version `X.Y.Z`:
  - bun (incl. build scripts and the WebKit pin):
    `https://github.com/oven-sh/bun/releases/tag/bun-vX.Y.Z`
  - JavaScriptCore / WebKit as built into that release: the patched fork at
    <https://github.com/oven-sh/webkit>, at the commit pinned by
    `WEBKIT_VERSION` in `scripts/build/deps/webkit.ts` **of that same tag**.
  - `tinycc`: <https://github.com/tinycc/tinycc>, at the revision vendored by
    that tag.

Upstream keeps every release tag public, which is what makes the per-version
pointers above sufficient. If a tag is ever deleted upstream, this mirror must
switch to archiving the exact-tag source alongside the artifact.

### Trademark

The Bun name and logo are used for catalog identification under nominative
fair use. They remain Oven's marks; no affiliation or endorsement is implied.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
