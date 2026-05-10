# Contributing Guidelines

When contributing to this repository, please ensure you follow the standard **GitHub Flow** and use **Conventional Commits** for your commit messages.

## Conventional Commits

This project uses [Release Please](https://github.com/googleapis/release-please) to automate versioning and changelog generation via "Release PRs". For this to work, all commits must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

A conventional commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

The `<type>` must be one of the following:

- **`feat`**: A new feature (corresponds to a **MINOR** version bump).
- **`fix`**: A bug fix (corresponds to a **PATCH** version bump).
- **`docs`**: Documentation only changes.
- **`style`**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
- **`refactor`**: A code change that neither fixes a bug nor adds a feature.
- **`perf`**: A code change that improves performance.
- **`test`**: Adding missing tests or correcting existing tests.
- **`build`**: Changes that affect the build system or external dependencies.
- **`ci`**: Changes to our CI configuration files and scripts.
- **`chore`**: Other changes that don't modify `src` or test files.

### Breaking Changes

If your commit introduces a breaking change, it must contain `BREAKING CHANGE:` at the beginning of the footer or an `!` after the type/scope (e.g., `feat!: rewrite core logic`). This will trigger a **MAJOR** version bump.

### Examples

**Feature commit (Minor Release):**
```
feat: add new docker installation option
```

**Bug fix commit (Patch Release):**
```
fix: correct typo in bash script invocation
```

**Breaking change (Major Release):**
```
feat!: completely replace bash script with go application

BREAKING CHANGE: The old setup.sh script has been removed.
```

**Documentation update (No Release):**
```
docs: add conventional commits guide to CONTRIBUTING.md
```

## Pull Requests

1. Fork or branch off `main`.
2. Make your changes and commit them using the conventional commits format.
3. Open a Pull Request against `main`.
4. Ensure your PR title also follows the conventional commit format, as this is often used for squash commits.
