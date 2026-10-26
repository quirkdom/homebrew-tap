# Releasing & Bottle Workflow Guide

This document explains how formula testing, bottling, and publishing work in `quirkdom/homebrew-tap`, along with formula-specific considerations.

---

## Architecture Overview

This tap uses standard Homebrew CI automation powered by GitHub Actions:

- **`.github/workflows/tests.yml` (`brew test-bot`)**:
  - Triggers on Pull Requests and direct pushes to `main`.
  - Runs tap syntax, style (`brew style`), and formula audit (`brew audit`) checks.
  - On **Pull Requests**, it automatically identifies which formulae in `Formula/` were added or modified, compiles them from source on macOS (`macos-26` Apple Silicon) and Linux (`ubuntu-latest` x86_64), runs formula tests (`brew test`), and uploads the resulting bottle files as workflow artifacts.
- **`.github/workflows/publish.yml` (`brew pr-pull`)**:
  - Triggered manually via `workflow_dispatch` with the PR number.
  - Downloads the bottle artifacts from the PR run.
  - Creates a GitHub Release on this repository (tagged `<formula>-<version>`) and uploads the bottle tarballs.
  - Writes the `bottle do ... sha256 ... end` block into the formula on `main`.
  - Pushes the commit to `main` with `Closes #<PR_NUMBER>`, which automatically merges and closes the PR.
- **`.github/workflows/autobump.yml`**:
  - Periodic automated version bumps for formulae that support `brew livecheck`.

---

## Step-by-Step Release Flow

When adding a new formula or updating an existing formula (e.g. `catpult`):

### 1. Test Locally

Make your edits in `Formula/<formula>.rb`. Run local audit and style checks:

```bash
# Check syntax and Homebrew style guidelines
brew style Formula/<formula>.rb

# Audit against Homebrew tap rules
brew audit --tap=quirkdom/tap Formula/<formula>.rb

# Test installing from source locally
brew install --build-from-source quirkdom/tap/<formula>

# Run formula test block
brew test quirkdom/tap/<formula>
```

### 2. Create a Feature Branch and PR

> [!IMPORTANT]
> **Never commit or push bottle updates directly to `main`.**
> `tests.yml` only compiles bottles on `pull_request` events. Direct pushes to `main` skip bottle compilation.

```bash
git checkout -b bump-<formula>-<version>
git add Formula/<formula>.rb
git commit -m "<formula>: update to <version>"
git push -u origin bump-<formula>-<version>
gh pr create --title "<formula>: update to <version>" --body "Updates <formula> to <version>."
```

### 3. Verify CI Builds Bottles

Watch the checks on the PR:
```bash
gh pr checks <PR_NUMBER>
```
The `brew test-bot` workflow will run matrix jobs for:
- `test-bot (macos-26)` (produces `bottles_macos-26`)
- `test-bot (ubuntu-latest)` (produces `bottles_ubuntu-latest`)

Wait until both jobs pass (`✓`) and verify artifacts are attached to the workflow run.

### 4. Dispatch the Publish Workflow

> [!WARNING]
> **Do NOT click "Merge" on GitHub or merge the PR manually!**
> `brew pr-pull` merges the PR for you while injecting the bottle checksums.

Run:
```bash
gh workflow run publish.yml -f pull_request=<PR_NUMBER>
```

`publish.yml` will:
1. Fetch bottle artifacts from PR #`<PR_NUMBER>`.
2. Create the GitHub Release and upload the bottle tarballs.
3. Commit the updated `bottle do` block to `main`.
4. Automatically close and mark the PR as merged.

### 5. Pull `main` Locally

```bash
git checkout main
git pull
```

---

## Formula Caveats & Guidelines

### `catpult`
- **Go Entrypoint**: The Go source files are located in `./cmd/catpult`, not in the archive root. The `go build` invocation in `Formula/catpult.rb` must explicitly target `./cmd/catpult`:
  ```ruby
system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}", tags: tags), "./cmd/catpult"
  ```
- **Bottling**: Fully supported and automated across macOS ARM64 and Linux x86_64.

---

### `calm`
- **Unbottled by Design**: `calm` is a Python virtualenv-based CLI assistant that relies on pre-compiled PyPI wheel resources (`mlx`, `hf-xet`) rather than compiling from native source.
- **Platform Restrictions**:
  ```ruby
depends_on arch: :arm64
depends_on :macos
  ```
  `calm` is Apple Silicon and macOS-only. It cannot build or run on Linux.
- **Excluded from CI Bottle Compilation**:
  In `.github/workflows/tests.yml`, bottle building explicitly excludes `calm`:
  ```bash
  FORMULAE=$(git -C "$TAP_DIR" diff --name-only "origin/${GITHUB_BASE_REF:-main}...HEAD" Formula/ | sed -E 's|^Formula/(.*)\.rb$|\1|' | grep -v '^calm$' || true)
  ```
  This prevents `brew test-bot` from attempting to build bottles on Linux (which would fail) or trying to bottle Python virtual environments with platform-specific wheels.
- **Livecheck / Autobump Skipped**:
  `calm.rb` contains:
  ```ruby
livecheck do
  skip "Formula dependencies and wheel resources must be updated manually"
end
  ```
  Because updating `calm` requires calculating updated SHA256 hashes and URLs for the wheel resources per macOS version, automated bumps are disabled. Updates must be tested and applied manually.
