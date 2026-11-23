# Exceptions

One row per rule this repository cannot meet yet. The reason and the revisit date
are required. The shared `standard` job reads this file.

| Rule | Reason | Revisit |
| --- | --- | --- |
| `C5.1` | The median of the last 20 pull request runs at the audit snapshot was 95 s. The first run after this change took 41 s from the first job starting to the last required check finishing, so the split `typecheck`/`test` jobs and the npm cache bring the pull request path inside the 60 s budget. The historical median stays above it until 20 new runs land; re-measure it then and drop this row if it holds. | 2027-02-28 |
| `community/.aislop/config.yml` | The file matches `repo-standard` except for `security.audit: false`. `newman` is an optional peer dependency installed only for the integration test, and its transitive tree carries unfixable advisories that aislop reports as errors while suggesting a `newman` version that does not exist. The shared Trivy scan is the dependency gate for this repository. Remove the override when newman or its parents publish a fixed release. | 2027-02-28 |
| `C7.3` | The repository is three published npm workspaces built with `tsc`, tested with Vitest and formatted and linted with Biome. A Bun rewrite would change the published package layout, the `action.yml` runtime and the `node` engine range that consumers install, so the toolchain stays on npm and the recipes expose the work behind `fmt`, `fmt-check`, `typecheck`, `build`, `test` and `lint`. | 2027-05-31 |
| `C7.4` | `scripts/prune.mjs`, `scripts/smoke-install.mjs`, `scripts/publish.mjs`, `scripts/agent-files.mjs` and `.agents/skills/verify/scripts/drive.mjs` are still `.mjs` on Node. They move to Bun TypeScript with the C7.3 migration. | 2027-05-31 |
