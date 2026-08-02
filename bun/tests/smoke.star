# bun/tests/smoke.star — asserts the contract, never prose. Stable across
# upstream bun releases: a version SHAPE, computed results, and bun-specific
# tokens — no help text, no banner, nothing upstream may reword.

BUN = "bun.exe" if ocx.target_platform.os == ocx.os.Windows else "bun"

# Bun writes an install cache, a runtime cache and a config file under $HOME
# (or $BUN_INSTALL / the XDG dirs). Point every one of them at the sandbox so
# the test never touches the runner's real home — and so it still works in a
# bare container image, where $HOME may be unset or unwritable. USERPROFILE is
# the Windows spelling; setting both keeps one dict for all platforms.
ENV = {
    "HOME": ocx.scratch_root,
    "USERPROFILE": ocx.scratch_root,
    "BUN_INSTALL": ocx.scratch_root,
    "XDG_CACHE_HOME": ocx.scratch_root,
    "XDG_CONFIG_HOME": ocx.scratch_root,
    "XDG_DATA_HOME": ocx.scratch_root,
}

# Tier 1 + 2: liveness on the composed PATH + semver version SHAPE.
r = ocx.run(BUN, "--version", env = ENV)
expect.ok(r)
expect.matches(r.stdout, r"\d+\.\d+\.\d+")

# Tier 3: computed result from the evaluator, not a string it printed back.
r = ocx.run(BUN, "-e", "console.log(2 + 2)", env = ENV)
expect.ok(r)
expect.contains(r.stdout, "4")

# Tier 3: run a real script FROM DISK — exercises module loading, not just the
# -e fast path. The `Bun` global is the runtime's own contract token: node
# would run this file and print `undefined`.
ocx.write_file(
    "smoke.js",
    "const xs = [3, 1, 2].sort();\n" +
    "console.log(JSON.stringify({sum: xs.reduce((a, b) => a + b, 0), " +
    "sorted: xs.join(''), rt: typeof Bun}));\n",
)
r = ocx.run(BUN, "smoke.js", env = ENV)
expect.ok(r)
expect.contains(r.stdout, "\"sum\":6")
expect.contains(r.stdout, "\"sorted\":\"123\"")
expect.contains(r.stdout, "\"rt\":\"object\"")

# Tier 3: TypeScript executed directly, no build step. This is the bun contract
# that most distinguishes it from a plain JS runtime, and the annotation syntax
# is a parse error under one — so a green here proves the transpiler ran.
ocx.write_file(
    "smoke.ts",
    "const add = (a: number, b: number): number => a + b;\n" +
    "console.log(`ts:${add(19, 23)}`);\n",
)
r = ocx.run(BUN, "smoke.ts", env = ENV)
expect.ok(r)
expect.contains(r.stdout, "ts:42")
