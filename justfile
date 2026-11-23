# Cross-platform task runner for humans and agents. `just --list` shows every
# recipe. Each recipe delegates to an npm script or a Node script, so the logic
# lives in one place and works on Windows, macOS, and Linux.
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

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
fmt:
    mise exec -- biome format --write .

# Fail when a source is not Biome-formatted.
fmt-check:
    mise exec -- biome format .

# Run every linter over the tracked files.
lint:
    mise exec -- flint run --full

# Fix what the linters can fix.
lint-fix:
    mise exec -- flint run --fix

# Run the AI-slop gate.
aislop:
    npx --yes aislop@0.16.1 ci

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

# Install the guarded git hook.
hooks:
    git config --local core.hooksPath .githooks

# Check the .agents/skills tree and its .claude/skills links.
agent-files:
    mise exec -- node scripts/agent-files.mjs

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    mise exec -- node scripts/prune.mjs
