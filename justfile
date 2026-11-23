# Task runner for humans and agents. `just --list` shows every
# recipe. Each recipe delegates to an npm script or a Node script, so the logic
# lives in one place and works on Linux.

# List the recipes.
default:
    @just --list

# Install the pinned tools.
install:
    mise install

# Install the workspace dependencies from the lockfile.
deps:
    mise exec -- npm ci

# Format the sources with Biome.
fmt *files:
    mise exec -- node scripts/fmt.mjs {{files}}

# Fail when a source is not Biome-formatted.
fmt-check:
    mise exec -- biome format .

# Run every linter over the tracked files.
lint *files:
    mise exec -- flint run --full

# Fix what the linters can fix.
lint-fix:
    mise exec -- flint run --fix

# Run the AI-slop gate.
aislop:
    mise exec -- aislop ci

# Typecheck every package.
typecheck:
    mise exec -- npm run typecheck

# Build every package into dist/.
build:
    mise exec -- npm run build

# Run the test suite.
test:
    mise exec -- npm test

# Run the tests and write an lcov report to coverage/lcov.info.
coverage:
    mise exec -- npm ci
    mise exec -- npm run coverage

# Everything CI requires.
check: fmt-check lint typecheck build test

# Historical alias for `check`, kept for the support template.
verify: check

# Build, then run the installed-layout smoke test.
smoke:
    mise exec -- npm run smoke

# Preview a publish for all three packages.
publish-dry:
    mise exec -- npm run publish:dry-run

# Publish all three packages in dependency order.
publish:
    mise exec -- npm run publish:packages

# Run a collection through the built CLI. Example: just run postman-test-utils.config.json
run config: build
    mise exec -- node packages/postman-test-utils/dist/cli.js run --config '{{config}}'

# Write a collection with the validation prelude baked in.
# Example: just emit postman-test-utils.config.json collection.with-validation.json
emit config out: build
    mise exec -- node packages/postman-test-utils/dist/cli.js run --emit '{{out}}' --config '{{config}}'

# Install the shared Lefthook hooks and assert the merged jobs (C7.8).
hooks:
    mise exec -- node scripts/hooks.ts

# Check the .agents/skills tree and its .claude/skills links.
agent-files:
    mise exec -- node scripts/agent-files.mjs

# Staged secret scan (C7.10).
secrets-staged:
    mise exec -- gitleaks git --staged --redact --no-banner

# Reject env files, private keys, kubeconfigs and files over 5 MB (C7.10).
forbidden-files *files:
    mise exec -- node scripts/forbidden-files.ts {{files}}

# actionlint and zizmor over the given workflows, or every workflow (C7.10).
workflows *files:
    {{ if files == "" { "mise exec -- actionlint" } else { "mise exec -- actionlint -- " + files } }}
    {{ if files == "" { "mise exec -- zizmor --quiet .github/workflows" } else { "mise exec -- zizmor --quiet " + files } }}

# shellcheck over the given scripts; nothing to do when none are given (C7.10).
shellcheck *files:
    {{ if files == "" { "echo shellcheck: no files to check" } else { "mise exec -- shellcheck -- " + files } }}

# Advisory Conventional Commit check (C2.4); never fails the commit (C7.10).
commit-msg file:
    mise exec -- node scripts/commit-msg.ts {{quote(file)}}

# Read the pushed refs from stdin, refuse main, and scan the range (C7.10).
hook-pre-push:
    mise exec -- node scripts/git-hook.ts pre-push

# Fast pre-push subset, under 30 seconds (C7.10).
pre-push-check:
    just fmt-check
    just typecheck

# Refresh locked dependencies when a manifest changed (C7.10).
deps-refresh *files:
    {{ if files == "" { "mise exec -- node scripts/deps-refresh.ts mise.toml" } else { "mise exec -- node scripts/deps-refresh.ts " + files } }}

# Owner hook: fail when this checkout cannot sign commits (C2.7).
signing-check:
    mise exec -- node scripts/signing-check.mjs

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    mise exec -- node scripts/prune.mjs
